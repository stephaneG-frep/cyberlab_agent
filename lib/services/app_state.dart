import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../data/badges.dart';
import '../data/course_library.dart';
import '../data/course_prerequisites.dart';
import '../data/learning_paths.dart';
import '../models/coach_message.dart';
import '../models/course.dart';
import '../models/note.dart';
import '../models/user_state.dart';
import 'ai_service.dart';
import 'backup_service.dart';
import 'badge_service.dart';
import 'reminder_service.dart';
import 'secret_store.dart';
import 'storage_service.dart';

/// Résultat d'une réponse de quiz.
class QuizOutcome {
  final bool correct;
  final int xpGained;

  /// Bonne réponse déjà récompensée auparavant (aucun nouveau gain).
  final bool alreadyRewarded;
  const QuizOutcome({
    required this.correct,
    required this.xpGained,
    required this.alreadyRewarded,
  });
}

/// Avancement du quiz d'un cours vers la condition de fin de cours.
class CourseQuizStatus {
  final int correct;
  final int required;
  final int total;
  const CourseQuizStatus({
    required this.correct,
    required this.required,
    required this.total,
  });
  bool get passed => correct >= required;
}

/// Profil de configuration d'un fournisseur IA (hors secret).
class AiProfile {
  final String model;
  final String baseUrl;
  const AiProfile({this.model = '', this.baseUrl = ''});
}

/// État applicatif et règles métier (récompenses, série, temps, coach).
/// Les écrans ne modifient jamais directement les XP : tout passe ici.
class AppState extends ChangeNotifier {
  AppState({
    StorageService? storage,
    SecretStore? secrets,
    this.httpClient,
    DateTime Function()? clock,
    BadgeService? badges,
    List<Course>? courses,
    this.hostResolver,
    ReminderScheduler? reminders,
  }) : storage = storage ?? StorageService(),
       secrets = secrets ?? SecureSecretStore(),
       reminders = reminders ?? LocalReminderScheduler(),
       _clock = clock ?? DateTime.now,
       badgeService = badges ?? BadgeService(),
       _courses = {for (final c in courses ?? CourseLibrary.all) c.id: c},
       user = UserState() {
    ready = _init();
  }

  static const coachSystemPrompt = '''
Tu es le CyberCoach, un professeur de cybersécurité bienveillant et pédagogue.
Règles impératives :
- Tu aides à APPRENDRE. Tu ne donnes JAMAIS directement la réponse complète.
- Fournis des indices progressifs (1, 2, 3) et des explications pour guider l'utilisateur vers la solution.
- Tiens compte des échanges précédents de la conversation pour graduer les indices.
- Encourage à chercher et tester par soi-même dans un environnement autorisé.
- Si l'utilisateur demande la solution brute, propose plutôt de l'amener à la découvrir, ou donne la solution seulement s'il insiste fortement.
- Encadre ton texte avec du markdown simple si utile. Réponds en français.
- Rappelle toujours : on n'attaque que ce qui nous appartient ou nous est explicitement autorisé.
''';

  /// Nombre maximal de messages conservés localement pour le coach.
  static const maxStoredCoachMessages = 200;

  final StorageService storage;
  final SecretStore secrets;
  final BadgeService badgeService;

  /// Client HTTP injectable (tests) ; null = client par défaut.
  final http.Client? httpClient;

  /// Résolution DNS injectable (tests) ; null = résolution système.
  final HostResolver? hostResolver;

  /// Notifications de rappel (injectable pour les tests).
  final ReminderScheduler reminders;
  final DateTime Function() _clock;

  /// Catalogue des cours (pour la condition de quiz de fin de cours).
  final Map<String, Course> _courses;

  late final Future<void> ready;

  UserState user;
  List<Note> notes = [];
  Map<String, dynamic> settings = {};
  List<CoachMessage> coachMessages = [];
  bool coachBusy = false;
  bool loaded = false;

  /// Dernière erreur de sauvegarde (affichée à l'utilisateur), sinon null.
  String? saveError;

  /// Avertissements de chargement / migration (affichés une fois).
  final List<String> warnings = [];

  final Map<String, String> _keyCache = {};
  DateTime? _activeSince;
  int _coachGeneration = 0;

  UserState get userState => user;

  // ------------------------------------------------------------ Chargement

  /// Chaque section (progression, notes, réglages, coach) est chargée
  /// indépendamment : l'échec de l'une n'empêche pas le chargement des
  /// autres. Si une section n'est relue que partiellement, sa valeur brute
  /// est d'abord copiée sous `<clé>_corrupt_<horodatage>` : une écriture
  /// ultérieure de cette section ne peut donc plus faire perdre de données.
  Future<void> _init() async {
    await _loadSection('Progression', StorageService.kUserState, () async {
      final u = await storage.loadUserState();
      if (u.backupKey != null) {
        warnings.add(
          'Données de progression illisibles : une copie a été conservée '
          '(${u.backupKey}) et une progression vierge a été ouverte.',
        );
      }
      if (u.value != null) user = UserState.fromJson(u.value!);
    });

    await _loadSection('Notes', StorageService.kNotes, () async {
      final n = await storage.loadNotes();
      if (n.backupKey != null) {
        warnings.add('Notes illisibles : copie conservée (${n.backupKey}).');
      }
      final parsed = <Note>[];
      var invalid = 0;
      for (final raw in n.value) {
        try {
          final note = Note.fromJson(Map<String, dynamic>.from(raw as Map));
          parsed.add(
            note.id.isEmpty
                ? Note(
                    id: 'n${DateTime.now().microsecondsSinceEpoch}_${parsed.length}',
                    title: note.title,
                    content: note.content,
                    category: note.category,
                    favorite: note.favorite,
                    createdAt: note.createdAt,
                    updatedAt: note.updatedAt,
                  )
                : note,
          );
        } catch (_) {
          invalid++;
        }
      }
      if (invalid > 0) {
        final backup = await storage.backupRaw(StorageService.kNotes);
        warnings.add(
          '$invalid note(s) illisible(s) ignorée(s) ; les autres sont '
          'chargées. Copie complète conservée ($backup).',
        );
      }
      notes = parsed;
    });

    await _loadSection('Réglages', StorageService.kSettings, () async {
      final s = await storage.loadSettings();
      if (s.backupKey != null) {
        warnings.add('Réglages illisibles : copie conservée (${s.backupKey}).');
      }
      settings = s.value;
      await _migrateLegacyAiSettings();
    });

    await _loadSection(
      'Historique du coach',
      StorageService.kCoachHistory,
      () async {
        final h = await storage.loadCoachHistory();
        final parsed = <CoachMessage>[];
        var invalid = 0;
        for (final raw in h.value) {
          final m = raw is Map
              ? CoachMessage.fromJson(Map<String, dynamic>.from(raw))
              : null;
          m == null ? invalid++ : parsed.add(m);
        }
        if (invalid > 0) {
          final backup = await storage.backupRaw(StorageService.kCoachHistory);
          warnings.add(
            '$invalid message(s) du coach illisible(s) ignoré(s). Copie '
            'conservée ($backup).',
          );
        }
        coachMessages = parsed;
      },
    );

    user.badgesEarned = badgeService.earnedIds(user);
    loaded = true;
    notifyListeners();
    await syncReminder();
  }

  Future<void> _loadSection(
    String label,
    String key,
    Future<void> Function() load,
  ) async {
    try {
      await load();
    } catch (e) {
      String? backup;
      try {
        backup = await storage.backupRaw(key);
      } catch (_) {
        backup = null;
      }
      warnings.add(
        '$label : chargement incomplet ($e). '
        '${backup != null ? 'Copie des données d\'origine conservée ($backup).' : 'Aucune donnée d\'origine à conserver.'}',
      );
    }
  }

  /// Migration des réglages IA v1 (champs plats + clé en clair) vers des
  /// profils par fournisseur et une clé en stockage sécurisé. L'ancienne
  /// clé n'est supprimée qu'après écriture ET relecture réussies.
  Future<void> _migrateLegacyAiSettings() async {
    final s = settings;
    final hasLegacy =
        s.containsKey('aiModel') ||
        s.containsKey('aiBaseUrl') ||
        s.containsKey('aiApiKey');
    if (!hasLegacy) return;

    String? str(Object? v) => v is String && v.isNotEmpty ? v : null;
    String validProvider(Object? v) {
      final p = str(v);
      return p != null && AiProviders.all.contains(p) ? p : AiProviders.ollama;
    }

    final provider = validProvider(s['aiProvider']);
    final legacyProvider = validProvider(
      s['aiLegacyKeyProvider'] ?? s['aiProvider'],
    );
    final profiles = _profilesMap();
    final rawExisting = profiles[provider];
    final existing = rawExisting is Map
        ? Map<String, dynamic>.from(rawExisting)
        : <String, dynamic>{};
    if (s.containsKey('aiModel') || s.containsKey('aiBaseUrl')) {
      profiles[provider] = {
        'model': str(existing['model']) ?? str(s['aiModel']) ?? '',
        'baseUrl': str(existing['baseUrl']) ?? str(s['aiBaseUrl']) ?? '',
      };
    }

    final next = Map<String, dynamic>.from(s)
      ..['aiProfiles'] = profiles
      ..remove('aiModel')
      ..remove('aiBaseUrl');

    final legacyKey = s['aiApiKey'] is String
        ? (s['aiApiKey'] as String).trim()
        : '';
    if (legacyKey.isEmpty) {
      next
        ..remove('aiApiKey')
        ..remove('aiLegacyKeyProvider');
    } else {
      final slot = apiKeySlot(legacyProvider);
      var migrated = false;
      try {
        await secrets.write(slot, legacyKey);
        migrated = (await secrets.read(slot)) == legacyKey;
      } catch (_) {
        migrated = false;
      }
      if (migrated) {
        _keyCache[legacyProvider] = legacyKey;
        next
          ..remove('aiApiKey')
          ..remove('aiLegacyKeyProvider');
      } else {
        next['aiLegacyKeyProvider'] = legacyProvider;
        warnings.add(
          'La clé API n\'a pas pu être déplacée vers le stockage sécurisé. '
          'Elle reste utilisable mais stockée comme avant, en clair dans les '
          'préférences : elle peut donc figurer dans la sauvegarde Android de '
          'l\'appareil. Une nouvelle tentative aura lieu au prochain '
          'démarrage ; vous pouvez aussi la supprimer dans Paramètres.',
        );
      }
    }
    settings = next;
    await _saveSettings();
  }

  // ------------------------------------------------------------ Sauvegarde

  Future<void> _guard(Future<void> Function() op) async {
    try {
      await op();
      if (saveError != null) saveError = null;
    } catch (e) {
      saveError =
          'Sauvegarde impossible ($e). Vos dernières actions restent en '
          'mémoire et seront réenregistrées à la prochaine action.';
    }
  }

  Future<void> _persistUser() async {
    _accumulateActiveTime();
    user.badgesEarned = badgeService.earnedIds(user);
    await _guard(() => storage.saveUserState(user.toJson()));
    notifyListeners();
  }

  Future<void> _saveNotes() =>
      _guard(() => storage.saveNotes(notes.map((e) => e.toJson()).toList()));

  Future<void> _saveSettings() => _guard(() => storage.saveSettings(settings));

  Future<void> _saveCoach() {
    if (coachMessages.length > maxStoredCoachMessages) {
      coachMessages = coachMessages.sublist(
        coachMessages.length - maxStoredCoachMessages,
      );
    }
    return _guard(
      () => storage.saveCoachHistory(
        coachMessages.map((m) => m.toJson()).toList(),
      ),
    );
  }

  void dismissWarnings() {
    warnings.clear();
    notifyListeners();
  }

  // -------------------------------------------------------- Récompenses

  Future<int> _reward(int Function() mutation) async {
    await ready;
    final gained = mutation();
    final newDay = user.registerActivity(_clock());
    await _persistUser();
    if (newDay) await syncReminder();
    return gained;
  }

  List<String> _quizIds(String courseId) =>
      _courses[courseId]?.quiz.map((q) => q.id).toList() ?? const [];

  /// Avancement du quiz du cours vers la condition de fin de cours.
  CourseQuizStatus courseQuizStatus(String courseId) {
    final ids = _quizIds(courseId);
    return CourseQuizStatus(
      correct: user.quizCorrectCount(courseId, ids),
      required: UserState.requiredQuizCorrect(ids.length),
      total: ids.length,
    );
  }

  /// Termine un cours : unique point d'attribution des XP du cours. Exige
  /// que le quiz du cours soit réussi (voir [UserState.courseQuizPassRatio]) ;
  /// sinon retourne 0 sans terminer le cours.
  Future<int> completeCourse(String courseId, int xp, {String? skill}) =>
      _reward(
        () => user.completeCourse(
          courseId,
          xp,
          skill: skill,
          quizQuestionIds: _quizIds(courseId),
        ),
      );

  Future<int> completeExercise(
    String courseId,
    int index,
    int xp, {
    String? skill,
  }) => _reward(
    () => user.completeExercise(
      courseId,
      exerciseId(courseId, index),
      xp,
      skill: skill,
    ),
  );

  Future<QuizOutcome> answerQuiz(
    String courseId,
    QuizQuestion q,
    String answer, {
    String? skill,
  }) async {
    await ready;
    final correct = q.isCorrect(answer);
    final already = user.isRewarded(RewardKeys.quiz(courseId, q.id));
    final gained = await _reward(
      () => user.answerQuiz(courseId, q.id, correct, q.xp, skill: skill),
    );
    return QuizOutcome(
      correct: correct,
      xpGained: gained,
      alreadyRewarded: correct && already,
    );
  }

  Future<int> resolveSocAlert(String alertId, bool correct, int xp) =>
      _reward(() => user.resolveSocAlert(alertId, correct, xp));

  Future<int> solveTerminalExercise(String courseId, int xp, {String? skill}) =>
      _reward(() => user.solveTerminalExercise(courseId, xp, skill: skill));

  Future<int> solveFilterExercise(String exerciseId, int xp) =>
      _reward(() => user.solveFilterExercise(exerciseId, xp));

  Future<int> solveChallenge(String challengeId, int xp) =>
      _reward(() => user.solveChallenge(challengeId, xp));

  /// Affiche la solution d'un challenge : il ne rapportera plus d'XP
  /// (enregistré durablement, même après fermeture de l'écran).
  Future<void> revealChallengeSolution(String challengeId) async {
    await ready;
    if (user.revealChallenge(challengeId)) await _persistUser();
  }

  bool isSolutionRevealed(String challengeId) =>
      user.isSolutionRevealed(challengeId);

  bool isRewarded(String key) => user.isRewarded(key);

  Future<void> recordAttempt(String courseId) async {
    await ready;
    user.courseAttempts[courseId] = (user.courseAttempts[courseId] ?? 0) + 1;
    final newDay = user.registerActivity(_clock());
    await _persistUser();
    if (newDay) await syncReminder();
  }

  /// Activité d'apprentissage sans récompense (ex. CTF tenté).
  Future<void> registerActivity() async {
    await ready;
    if (user.registerActivity(_clock())) {
      await _persistUser();
      await syncReminder();
    }
  }

  // --------------------------------------------------- Rappel quotidien

  ReminderSettings get reminder =>
      ReminderSettings.fromJson(settings['reminder']);

  /// Dernier problème de planification du rappel (affiché), sinon null.
  String? reminderIssue;

  /// Active, règle ou désactive le rappel. Retourne un message d'erreur, ou
  /// null en cas de succès.
  Future<String?> setReminder({
    required bool enabled,
    int? hour,
    int? minute,
  }) async {
    await ready;
    final current = reminder;
    final next = ReminderSettings(
      enabled: enabled,
      hour: hour ?? current.hour,
      minute: minute ?? current.minute,
    );
    if (enabled && !current.enabled) {
      bool granted;
      try {
        granted = await reminders.requestPermission();
      } catch (_) {
        granted = false;
      }
      if (!granted) {
        return 'Notifications refusées : autorisez-les pour CyberLab Agent '
            'dans les réglages Android, puis réessayez.';
      }
    }
    settings = {...settings, 'reminder': next.toJson()};
    await _saveSettings();
    if (!enabled) {
      try {
        await reminders.cancel();
        reminderIssue = null;
      } catch (_) {
        reminderIssue = 'Le rappel n\'a pas pu être annulé.';
      }
    } else {
      await syncReminder();
    }
    notifyListeners();
    return reminderIssue;
  }

  /// (Re)planifie le rappel selon le réglage et l'activité du jour.
  Future<void> syncReminder() async {
    final r = reminder;
    if (!r.enabled) return;
    final now = _clock();
    final when = nextReminder(
      r,
      now: now,
      activeToday: user.lastActiveDay == localDayKey(now),
    );
    final text = reminderText(hasStreak: user.currentStreak(now) > 0);
    try {
      await reminders.scheduleDaily(when, text.title, text.body);
      reminderIssue = null;
    } catch (_) {
      reminderIssue = 'Le rappel n\'a pas pu être programmé sur cet appareil.';
    }
  }

  // ------------------------------------------------- Série, temps, badges

  int get currentStreak => user.currentStreak(_clock());

  List<BadgeDef> get earnedBadges => badgeService.earned(user);
  List<BadgeDef> get lockedBadges => badgeService.locked(user);

  /// Minutes d'apprentissage actif, session en cours comprise.
  int get learningMinutes {
    var seconds = user.learningSeconds;
    final since = _activeSince;
    if (since != null) {
      final s = _clock().difference(since).inSeconds;
      if (s > 0) seconds += s;
    }
    return seconds ~/ 60;
  }

  void _accumulateActiveTime({bool stop = false}) {
    final since = _activeSince;
    if (since == null) return;
    final now = _clock();
    final s = now.difference(since).inSeconds;
    if (s > 0) user.learningSeconds += s;
    _activeSince = stop ? null : now;
  }

  /// Application au premier plan : le chronomètre démarre.
  void onAppResumed() {
    _activeSince ??= _clock();
    // Nouveau jour depuis la dernière ouverture : replanifier le rappel.
    if (loaded) syncReminder();
  }

  /// Application en arrière-plan : le temps n'est plus compté.
  Future<void> onAppPaused() async {
    if (_activeSince == null) return;
    _accumulateActiveTime(stop: true);
    await ready;
    await _persistUser();
  }

  // ------------------------------------------------------------- Profil

  Future<void> setName(String name) async {
    await ready;
    user.name = name;
    await _persistUser();
  }

  /// Choisit le parcours (identifiant inconnu ignoré).
  Future<void> setPath(String path) async {
    await ready;
    if (!LearningPaths.isValid(path)) return;
    user.selectedPath = path;
    await _persistUser();
  }

  /// Parcours actuel (le parcours par défaut si la valeur est inconnue).
  LearningPath get currentPath => LearningPaths.byId(user.selectedPath);

  /// Cours terminés / total du parcours actuel.
  ({int done, int total}) get pathProgress {
    final courses = currentPath.courses;
    return (
      done: courses.where((c) => user.completedCourses.contains(c.id)).length,
      total: courses.length,
    );
  }

  // ------------------------------------------------------- Révision

  /// Questions ratées et pas encore réussies, dans l'ordre des cours.
  List<(Course, QuizQuestion)> get mistakes => [
    for (final c in _courses.values)
      for (final q in c.quiz)
        if (user.quizResults['${c.id}/${q.id}'] == 0) (c, q),
  ];

  /// Questions des cours terminés (entraînement libre).
  List<(Course, QuizQuestion)> get practicePool => [
    for (final c in _courses.values)
      if (user.completedCourses.contains(c.id))
        for (final q in c.quiz) (c, q),
  ];

  /// Cours conseillés avant [courseId] (prérequis structurés).
  List<Course> prerequisitesOf(String courseId) => [
    for (final id in coursePrerequisites[courseId] ?? const <String>[])
      ?_courses[id],
  ];

  /// Prérequis de [courseId] pas encore terminés.
  List<Course> missingPrerequisites(String courseId) => prerequisitesOf(
    courseId,
  ).where((c) => !user.completedCourses.contains(c.id)).toList();

  /// Prochain cours conseillé : dans le parcours, le premier cours non
  /// terminé dont les prérequis sont faits (sinon le premier non terminé) ;
  /// puis de même dans toute la bibliothèque ; null si tout est terminé.
  Course? get nextCourse {
    bool open(Course c) => !user.completedCourses.contains(c.id);
    bool ready(Course c) => open(c) && missingPrerequisites(c.id).isEmpty;
    for (final pool in [currentPath.courses, _courses.values.toList()]) {
      final candidates = pool.where(open).toList();
      if (candidates.isEmpty) continue;
      return candidates.firstWhere(ready, orElse: () => candidates.first);
    }
    return null;
  }

  // ------------------------------------------------- Premier lancement

  /// Vrai au premier lancement : accueil non encore vu ET aucune donnée
  /// existante (un utilisateur qui a déjà progressé ne le voit jamais).
  bool get needsOnboarding {
    if (!loaded || settings['onboardingDone'] == true) return false;
    final hasData =
        user.xp > 0 ||
        user.name.isNotEmpty ||
        user.completedCourses.isNotEmpty ||
        user.quizResults.isNotEmpty ||
        user.solvedChallenges.isNotEmpty ||
        notes.isNotEmpty;
    return !hasData;
  }

  /// Termine l'accueil : enregistre le prénom (facultatif) et le parcours.
  Future<void> completeOnboarding({String name = '', String? path}) async {
    await ready;
    user.name = name.trim();
    if (path != null && LearningPaths.isValid(path)) user.selectedPath = path;
    settings = {...settings, 'onboardingDone': true};
    await _saveSettings();
    await _persistUser();
  }

  Future<void> resetProgress() async {
    await ready;
    user = UserState(name: user.name);
    notes = [];
    _activeSince = _activeSince == null ? null : _clock();
    await _persistUser();
    await _saveNotes();
    notifyListeners();
  }

  // ------------------------------------------------ Export / import

  /// Export JSON : progression, notes, réglages non secrets et, si
  /// [includeCoach], l'historique du coach. Aucune clé API.
  Future<String> exportData({
    bool includeCoach = false,
    String appVersion = '',
  }) async {
    await ready;
    _accumulateActiveTime();
    return BackupFormat.encode(
      user: user,
      notes: notes,
      settings: settings,
      coachHistory: includeCoach ? coachMessages : null,
      appVersion: appVersion,
      now: _clock(),
    );
  }

  /// Remplace la progression et les notes par celles de [backup]. Les
  /// réglages exportables sont repris ; les clés API restent celles de cet
  /// appareil. L'historique du coach n'est remplacé que s'il figure dans
  /// l'export. Avant tout remplacement, l'état actuel est copié sous des
  /// clés `*_corrupt_<horodatage>` : l'import est donc réversible.
  /// Retourne null en cas de succès, sinon un message d'erreur.
  Future<String?> importBackup(BackupPreview backup) async {
    await ready;
    await storage.flush();
    try {
      for (final key in [
        StorageService.kUserState,
        StorageService.kNotes,
        StorageService.kSettings,
        if (backup.coachHistory != null) StorageService.kCoachHistory,
      ]) {
        await storage.backupRaw(key);
      }
    } catch (_) {
      return 'Import annulé : impossible de conserver une copie des données '
          'actuelles. Rien n\'a été modifié.';
    }
    user = backup.user;
    notes = List.of(backup.notes);
    settings = {...settings, ...backup.settings};
    if (backup.coachHistory != null) {
      _coachGeneration++;
      coachBusy = false;
      coachMessages = List.of(backup.coachHistory!);
      await _saveCoach();
    }
    _activeSince = _activeSince == null ? null : _clock();
    await _saveSettings();
    await _saveNotes();
    await _persistUser();
    return saveError;
  }

  // -------------------------------------------------------------- Notes

  Future<void> addNote(Note n) async {
    await ready;
    notes.insert(0, n);
    await _saveNotes();
    notifyListeners();
  }

  Future<void> updateNote(Note n) async {
    await ready;
    final i = notes.indexWhere((e) => e.id == n.id);
    if (i >= 0) {
      n.updatedAt = DateTime.now();
      notes[i] = n;
      await _saveNotes();
      notifyListeners();
    }
  }

  Future<void> deleteNote(String id) async {
    await ready;
    notes.removeWhere((e) => e.id == id);
    await _saveNotes();
    notifyListeners();
  }

  Future<void> toggleNoteFavorite(String id) async {
    await ready;
    final i = notes.indexWhere((e) => e.id == id);
    if (i >= 0) {
      notes[i].favorite = !notes[i].favorite;
      await _saveNotes();
      notifyListeners();
    }
  }

  // ----------------------------------------------------------- Réglages

  bool get darkMode => settings['darkMode'] != false;

  Future<void> setDarkMode(bool value) async {
    await ready;
    settings = {...settings, 'darkMode': value};
    await _saveSettings();
    notifyListeners();
  }

  String get aiProvider {
    final p = settings['aiProvider'];
    return p is String && AiProviders.all.contains(p) ? p : AiProviders.ollama;
  }

  Map<String, dynamic> _profilesMap() {
    final raw = settings['aiProfiles'];
    return raw is Map ? Map<String, dynamic>.from(raw) : <String, dynamic>{};
  }

  AiProfile aiProfile(String provider) {
    final p = _profilesMap()[provider];
    if (p is! Map) return const AiProfile();
    return AiProfile(
      model: p['model'] is String ? p['model'] as String : '',
      baseUrl: p['baseUrl'] is String ? p['baseUrl'] as String : '',
    );
  }

  /// Clé du fournisseur [provider] uniquement (jamais celle d'un autre).
  Future<String> readApiKey(String provider) async {
    if (!AiProviders.usesKey(provider)) return '';
    final cached = _keyCache[provider];
    if (cached != null) return cached;
    try {
      final v = await secrets.read(apiKeySlot(provider));
      if (v != null && v.isNotEmpty) {
        _keyCache[provider] = v;
        return v;
      }
    } catch (_) {
      // Stockage sécurisé indisponible : repli éventuel ci-dessous.
    }
    // Repli : clé v1 non encore migrée, uniquement pour son fournisseur.
    final legacy = settings['aiApiKey'];
    if (legacy is String &&
        legacy.isNotEmpty &&
        settings['aiLegacyKeyProvider'] == provider) {
      return legacy;
    }
    return '';
  }

  Future<bool> hasApiKey(String provider) async =>
      (await readApiKey(provider)).isNotEmpty;

  Future<AiSettings> currentAiSettings() async {
    await ready;
    final provider = aiProvider;
    final profile = aiProfile(provider);
    return AiSettings(
      provider: provider,
      model: profile.model,
      baseUrl: profile.baseUrl,
      apiKey: await readApiKey(provider),
    );
  }

  /// Enregistre la configuration d'un fournisseur.
  /// [apiKey] : null = inchangée, '' = suppression, sinon nouvelle clé.
  /// Retourne un message d'erreur, ou null en cas de succès.
  Future<String?> saveAiConfig({
    required String provider,
    required String model,
    required String baseUrl,
    String? apiKey,
  }) async {
    await ready;
    if (!AiProviders.all.contains(provider)) return 'Fournisseur inconnu.';
    final url = baseUrl.trim();
    if (url.isNotEmpty || AiProviders.defaultBaseUrl(provider) == null) {
      final check = buildEndpoint(
        AiSettings(
          provider: provider,
          model: model.trim().isEmpty ? 'modele' : model.trim(),
          baseUrl: url,
        ),
      );
      if (check.error != null) {
        if (url.isEmpty) {
          return 'Une adresse de serveur est obligatoire pour ce fournisseur.';
        }
        return AiResult.fail(check.error!).message;
      }
    }

    String? keyError;
    if (apiKey != null && AiProviders.usesKey(provider)) {
      final slot = apiKeySlot(provider);
      try {
        if (apiKey.trim().isEmpty) {
          await secrets.delete(slot);
          _keyCache.remove(provider);
        } else {
          await secrets.write(slot, apiKey.trim());
          if ((await secrets.read(slot)) != apiKey.trim()) {
            throw Exception('relecture différente');
          }
          _keyCache[provider] = apiKey.trim();
        }
      } catch (_) {
        _keyCache.remove(provider);
        keyError =
            'La clé n\'a pas pu être enregistrée dans le stockage sécurisé. '
            'Elle n\'a été écrite nulle part ailleurs.';
      }
    }

    final profiles = _profilesMap()
      ..[provider] = {'model': model.trim(), 'baseUrl': url};
    settings = {...settings, 'aiProvider': provider, 'aiProfiles': profiles};
    await _saveSettings();
    notifyListeners();
    return keyError ?? saveError;
  }

  // -------------------------------------------------------------- Coach

  bool get hasCoachConversation =>
      coachMessages.any((m) => m.role != CoachRole.notice);

  Future<void> sendCoachMessage(String text) async {
    await ready;
    final question = text.trim();
    if (question.isEmpty || coachBusy) return;
    final generation = _coachGeneration;
    coachMessages.add(CoachMessage(CoachRole.user, question));
    coachBusy = true;
    notifyListeners();
    await _saveCoach();

    CoachMessage reply;
    try {
      final config = await currentAiSettings();
      if (!config.isConfigured) {
        reply = CoachMessage(
          CoachRole.notice,
          'Mode hors ligne : aucun modèle IA n\'est configuré ou accessible, '
          'donc aucune réponse n\'a été générée. Les cours, quiz, CTF, '
          'cheat sheets et simulateurs restent entièrement disponibles. '
          'Pour activer le coach : Paramètres → CyberCoach / IA.',
        );
      } else {
        final history = coachMessages
            .where((m) => m.role != CoachRole.notice)
            .map(
              (m) => ChatTurn(
                m.role == CoachRole.user ? ChatRole.user : ChatRole.assistant,
                m.text,
              ),
            )
            .toList();
        final service = AiService(
          config,
          client: httpClient,
          resolver: hostResolver,
        );
        try {
          final result = await service.chat(coachSystemPrompt, history);
          reply = result.isOk
              ? CoachMessage(CoachRole.assistant, result.text!)
              : CoachMessage(CoachRole.notice, result.message);
        } finally {
          service.close();
        }
      }
    } catch (_) {
      reply = CoachMessage(
        CoachRole.notice,
        const AiResult.fail(AiErrorKind.unknown).message,
      );
    }

    // Conversation effacée pendant la requête : la réponse est ignorée.
    if (generation == _coachGeneration) {
      coachBusy = false;
      coachMessages.add(reply);
      await _saveCoach();
    }
    notifyListeners();
  }

  Future<void> clearCoachConversation() async {
    await ready;
    _coachGeneration++;
    coachMessages = [];
    coachBusy = false;
    await _saveCoach();
    notifyListeners();
  }
}
