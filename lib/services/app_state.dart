import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../data/badges.dart';
import '../models/coach_message.dart';
import '../models/course.dart';
import '../models/note.dart';
import '../models/user_state.dart';
import 'ai_service.dart';
import 'badge_service.dart';
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
  }) : storage = storage ?? StorageService(),
       secrets = secrets ?? SecureSecretStore(),
       _clock = clock ?? DateTime.now,
       badgeService = badges ?? BadgeService(),
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
  final DateTime Function() _clock;

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

  Future<void> _init() async {
    try {
      final u = await storage.loadUserState();
      if (u.value != null) user = UserState.fromJson(u.value!);
      if (u.backupKey != null) {
        warnings.add(
          'Données de progression illisibles : une copie a été conservée '
          '(${u.backupKey}) et une progression vierge a été ouverte.',
        );
      }
      final n = await storage.loadNotes();
      notes = n.value.map(Note.fromJson).toList();
      if (n.backupKey != null) {
        warnings.add('Notes illisibles : copie conservée (${n.backupKey}).');
      }
      final s = await storage.loadSettings();
      settings = s.value;
      final h = await storage.loadCoachHistory();
      coachMessages = h.value
          .map(CoachMessage.fromJson)
          .whereType<CoachMessage>()
          .toList();
      await _migrateLegacyAiSettings();
      user.badgesEarned = badgeService.earnedIds(user);
    } catch (e) {
      warnings.add('Chargement incomplet des données locales : $e');
    }
    loaded = true;
    notifyListeners();
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

    final legacyProvider =
        (s['aiLegacyKeyProvider'] ?? s['aiProvider'] ?? AiProviders.ollama)
            as String;
    final provider = (s['aiProvider'] ?? AiProviders.ollama) as String;
    final profiles = _profilesMap();
    final existing = Map<String, dynamic>.from(
      (profiles[provider] as Map?) ?? const {},
    );
    if (s.containsKey('aiModel') || s.containsKey('aiBaseUrl')) {
      profiles[provider] = {
        'model': existing['model'] ?? s['aiModel'] ?? '',
        'baseUrl': existing['baseUrl'] ?? s['aiBaseUrl'] ?? '',
      };
    }

    final next = Map<String, dynamic>.from(s)
      ..['aiProfiles'] = profiles
      ..remove('aiModel')
      ..remove('aiBaseUrl');

    final legacyKey = (s['aiApiKey'] as String?)?.trim() ?? '';
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
          'Elle reste utilisable mais stockée comme avant ; une nouvelle '
          'tentative aura lieu au prochain démarrage.',
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
    user.registerActivity(_clock());
    await _persistUser();
    return gained;
  }

  /// Termine un cours : unique point d'attribution des XP du cours.
  Future<int> completeCourse(String courseId, int xp, {String? skill}) =>
      _reward(() => user.completeCourse(courseId, xp, skill: skill));

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

  Future<int> solveChallenge(String challengeId, int xp) =>
      _reward(() => user.solveChallenge(challengeId, xp));

  bool isRewarded(String key) => user.isRewarded(key);

  Future<void> recordAttempt(String courseId) async {
    await ready;
    user.courseAttempts[courseId] = (user.courseAttempts[courseId] ?? 0) + 1;
    user.registerActivity(_clock());
    await _persistUser();
  }

  /// Activité d'apprentissage sans récompense (ex. CTF tenté).
  Future<void> registerActivity() async {
    await ready;
    if (user.registerActivity(_clock())) await _persistUser();
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

  Future<void> setPath(String path) async {
    await ready;
    user.selectedPath = path;
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
        final service = AiService(config, client: httpClient);
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
