import 'dart:convert';

class Badge {
  final String id;
  final String name;
  final String description;
  final String icon; // material icon codepoint name resolved in UI
  final String color;
  bool earned;

  Badge({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
    this.earned = false,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'icon': icon,
    'color': color,
    'earned': earned,
  };
}

/// Calcul des niveaux : le niveau n commence à 500 × (n−1) × n / 2 XP
/// (0, 500, 1500, 3000, 5000…). Le passage du niveau n au niveau n+1
/// demande donc n × 500 XP.
class LevelMath {
  LevelMath._();

  static int startXp(int level) => level <= 1 ? 0 : 250 * (level - 1) * level;

  static int levelFor(int xp) {
    var lvl = 1;
    while (xp >= startXp(lvl + 1)) {
      lvl++;
    }
    return lvl;
  }
}

/// Clés stables identifiant chaque récompense attribuable une seule fois.
class RewardKeys {
  RewardKeys._();
  static String course(String courseId) => 'course:$courseId';
  static String exercise(String exerciseId) => 'exercise:$exerciseId';
  static String quiz(String courseId, String questionId) =>
      'quiz:$courseId/$questionId';
  static String soc(String alertId) => 'soc:$alertId';
  static String ctf(String challengeId) => 'ctf:$challengeId';
}

/// Jour local au format AAAA-MM-JJ.
String localDayKey(DateTime t) {
  final d = t.toLocal();
  String two(int v) => v.toString().padLeft(2, '0');
  return '${d.year.toString().padLeft(4, '0')}-${two(d.month)}-${two(d.day)}';
}

/// Écart en jours calendaires entre deux clés de jour (insensible aux
/// changements d'heure, car calculé en UTC sur des dates pures).
int? daysBetweenKeys(String from, String to) {
  DateTime? parse(String k) {
    final p = k.split('-');
    if (p.length != 3) return null;
    final y = int.tryParse(p[0]),
        m = int.tryParse(p[1]),
        d = int.tryParse(p[2]);
    if (y == null || m == null || d == null) return null;
    return DateTime.utc(y, m, d);
  }

  final a = parse(from), b = parse(to);
  if (a == null || b == null) return null;
  return b.difference(a).inDays;
}

class UserState {
  /// Version du schéma de sauvegarde. 1 = données v1.0.0 (sans versions).
  static const currentSchema = 2;

  String name;
  int level;
  int xp;
  int streak;
  List<String> completedCourses;
  Map<String, int> quizResults; // '<cours>/<question>' -> 1 réussi, 0 échec
  Map<String, int> courseAttempts;
  List<String> solvedChallenges;
  Set<String> badgesEarned;
  Map<String, SkillProgress> skills;
  int learningSeconds;
  String selectedPath;

  /// Récompenses déjà attribuées (voir [RewardKeys]).
  Set<String> rewardedKeys;

  /// Dernier jour local d'activité (AAAA-MM-JJ) pour la série.
  String? lastActiveDay;

  int schemaVersion;

  UserState({
    this.name = '',
    this.level = 1,
    this.xp = 0,
    this.streak = 0,
    List<String>? completedCourses,
    Map<String, int>? quizResults,
    Map<String, int>? courseAttempts,
    List<String>? solvedChallenges,
    Set<String>? badgesEarned,
    Map<String, SkillProgress>? skills,
    this.learningSeconds = 0,
    this.selectedPath = 'fundamentals',
    Set<String>? rewardedKeys,
    this.lastActiveDay,
    this.schemaVersion = currentSchema,
  }) : completedCourses = completedCourses ?? [],
       quizResults = quizResults ?? {},
       courseAttempts = courseAttempts ?? {},
       solvedChallenges = solvedChallenges ?? [],
       badgesEarned = badgesEarned ?? {},
       skills = skills ?? {},
       rewardedKeys = rewardedKeys ?? {} {
    level = LevelMath.levelFor(xp);
  }

  // ---------------------------------------------------------------- Niveaux

  int get learningMinutes => learningSeconds ~/ 60;

  int get levelFromXp => LevelMath.levelFor(xp);

  /// XP cumulés nécessaires pour atteindre le niveau suivant.
  int get xpForNextLevel => LevelMath.startXp(level + 1);

  /// XP cumulés au début du niveau actuel.
  int get xpForCurrentLevel => LevelMath.startXp(level);

  /// Progression (0–100) entre le début du niveau actuel et le suivant.
  int get progressToNext {
    final start = xpForCurrentLevel;
    final span = xpForNextLevel - start;
    if (span <= 0) return 0;
    final p = ((xp - start) / span).clamp(0.0, 1.0);
    // floor : on n'affiche jamais 100 % avant d'avoir réellement changé de niveau.
    return (p * 100).floor();
  }

  // ------------------------------------------------------------ Récompenses

  bool isRewarded(String key) => rewardedKeys.contains(key);

  /// Attribue [amount] XP une seule fois pour [key]. Retourne les XP gagnés
  /// (0 si la récompense a déjà été attribuée).
  int grant(String key, int amount, {String? skill}) {
    if (amount <= 0 || rewardedKeys.contains(key)) return 0;
    rewardedKeys.add(key);
    _addXp(amount, skill: skill);
    return amount;
  }

  void _addXp(int amount, {String? skill}) {
    xp += amount;
    level = LevelMath.levelFor(xp);
    if (skill != null) {
      skills.putIfAbsent(skill, () => SkillProgress(name: skill)).addXp(amount);
    }
  }

  /// Termine un cours : seul point d'attribution de la récompense du cours.
  int completeCourse(String courseId, int amount, {String? skill}) {
    if (!completedCourses.contains(courseId)) completedCourses.add(courseId);
    return grant(RewardKeys.course(courseId), amount, skill: skill);
  }

  /// Valide un exercice (une récompense par exercice, cours terminé requis).
  int completeExercise(
    String courseId,
    String exerciseId,
    int amount, {
    String? skill,
  }) {
    if (!completedCourses.contains(courseId)) return 0;
    return grant(RewardKeys.exercise(exerciseId), amount, skill: skill);
  }

  /// Enregistre une réponse de quiz. Une réponse fausse ne consomme pas la
  /// récompense : une réussite ultérieure rapporte encore ses XP.
  int answerQuiz(
    String courseId,
    String questionId,
    bool correct,
    int amount, {
    String? skill,
  }) {
    final scoped = '$courseId/$questionId';
    if (correct) {
      quizResults[scoped] = 1;
      return grant(RewardKeys.quiz(courseId, questionId), amount, skill: skill);
    }
    // On ne rétrograde pas une question déjà réussie.
    quizResults.putIfAbsent(scoped, () => 0);
    if (quizResults[scoped] != 1) quizResults[scoped] = 0;
    return 0;
  }

  int resolveSocAlert(String alertId, bool correct, int amount) {
    if (!correct) return 0;
    return grant(RewardKeys.soc(alertId), amount, skill: 'Blueteam');
  }

  int solveChallenge(String challengeId, int amount) {
    if (!solvedChallenges.contains(challengeId)) {
      solvedChallenges.add(challengeId);
    }
    return grant(RewardKeys.ctf(challengeId), amount, skill: 'CTF');
  }

  // ------------------------------------------------------------------ Série

  /// Enregistre une activité d'apprentissage. Retourne vrai si la série a
  /// changé. Un seul comptage par jour local.
  bool registerActivity(DateTime now) {
    final today = localDayKey(now);
    final last = lastActiveDay;
    if (last == today) return false;
    final diff = last == null ? null : daysBetweenKeys(last, today);
    if (diff != null && diff < 0) {
      // Horloge reculée (fuseau, réglage manuel) : on ne touche à rien.
      return false;
    }
    streak = diff == 1 ? streak + 1 : 1;
    lastActiveDay = today;
    return true;
  }

  /// Série affichée : remise à 0 si plus d'un jour sans activité.
  int currentStreak(DateTime now) {
    final last = lastActiveDay;
    if (last == null) return 0;
    final diff = daysBetweenKeys(last, localDayKey(now));
    if (diff == null) return 0;
    return diff <= 1 ? streak : 0;
  }

  // ----------------------------------------------------------- Sérialisation

  Map<String, dynamic> toJson() {
    return {
      'schemaVersion': schemaVersion,
      'name': name,
      'level': level,
      'xp': xp,
      'streak': streak,
      'lastActiveDay': lastActiveDay,
      'completedCourses': completedCourses,
      'quizResults': quizResults,
      'courseAttempts': courseAttempts,
      'solvedChallenges': solvedChallenges,
      'badgesEarned': badgesEarned.toList(),
      'skills': skills.map((k, v) => MapEntry(k, v.toJson())),
      'learningSeconds': learningSeconds,
      // Conservé pour compatibilité de lecture par une ancienne version.
      'learningMinutes': learningMinutes,
      'selectedPath': selectedPath,
      'rewardedKeys': rewardedKeys.toList()..sort(),
    };
  }

  /// Lecture tolérante + migration depuis le schéma 1 (v1.0.0).
  ///
  /// Schéma 1 → 2 :
  /// - XP, niveau (recalculé depuis les XP), cours, CTF, notes : conservés ;
  /// - les récompenses identifiables (cours terminés, CTF résolus) sont
  ///   marquées comme déjà attribuées pour ne pas être redonnées ;
  /// - limites : la v1 ne gardait aucune trace fiable des exercices validés
  ///   ni des alertes SOC réussies, et ses résultats de quiz étaient indexés
  ///   par un identifiant ambigu (« q1 » existe dans presque tous les cours).
  ///   Ces récompenses pourront donc être obtenues UNE fois de plus.
  factory UserState.fromJson(Map<String, dynamic> j) {
    int asInt(Object? v, int fallback) => v is num ? v.toInt() : fallback;
    Map<String, int> intMap(Object? v) => v is Map
        ? v.map((k, val) => MapEntry('$k', asInt(val, 0)))
        : <String, int>{};
    List<String> strList(Object? v) =>
        v is List ? v.map((e) => '$e').toList() : <String>[];

    final skills = <String, SkillProgress>{};
    final rawSkills = j['skills'];
    if (rawSkills is Map) {
      rawSkills.forEach((k, v) {
        if (v is Map<String, dynamic>) {
          skills['$k'] = SkillProgress.fromJson(v);
        }
      });
    }

    final version = asInt(j['schemaVersion'], 1);
    final completed = strList(j['completedCourses']);
    final solved = strList(j['solvedChallenges']);
    final rewarded = strList(j['rewardedKeys']).toSet();
    if (version < 2) {
      rewarded.addAll(completed.map(RewardKeys.course));
      rewarded.addAll(solved.map(RewardKeys.ctf));
    }

    final seconds = j.containsKey('learningSeconds')
        ? asInt(j['learningSeconds'], 0)
        : asInt(j['learningMinutes'], 0) * 60;

    final lastDay = j['lastActiveDay'];

    return UserState(
      name: j['name'] is String ? j['name'] as String : '',
      xp: asInt(j['xp'], 0),
      streak: asInt(j['streak'], 0),
      completedCourses: completed,
      quizResults: intMap(j['quizResults']),
      courseAttempts: intMap(j['courseAttempts']),
      solvedChallenges: solved,
      badgesEarned: strList(j['badgesEarned']).toSet(),
      skills: skills,
      learningSeconds: seconds,
      selectedPath: j['selectedPath'] is String
          ? j['selectedPath'] as String
          : 'fundamentals',
      rewardedKeys: rewarded,
      lastActiveDay: lastDay is String ? lastDay : null,
      schemaVersion: currentSchema,
    );
  }

  String toJsonString() => jsonEncode(toJson());
}

class SkillProgress {
  final String name;
  int level; // 0-100
  int xp;

  SkillProgress({required this.name, this.level = 0, this.xp = 0});

  void addXp(int amount) {
    xp += amount;
    level = (xp / 10).clamp(0, 100).round();
  }

  Map<String, dynamic> toJson() => {'name': name, 'level': level, 'xp': xp};

  factory SkillProgress.fromJson(Map<String, dynamic> j) => SkillProgress(
    name: j['name'] is String ? j['name'] as String : '',
    level: j['level'] is num ? (j['level'] as num).toInt() : 0,
    xp: j['xp'] is num ? (j['xp'] as num).toInt() : 0,
  );
}
