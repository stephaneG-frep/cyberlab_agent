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

class UserState {
  String name;
  int level;
  int xp;
  int streak;
  List<String> completedCourses;
  Map<String, int> quizResults; // questionId -> 1 success, 0 fail
  Map<String, int> courseAttempts;
  List<String> solvedChallenges;
  Set<String> badgesEarned;
  Map<String, SkillProgress> skills;
  int learningMinutes;
  String selectedPath;

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
    this.learningMinutes = 0,
    this.selectedPath = 'fundamentals',
  }) : completedCourses = completedCourses ?? [],
       quizResults = quizResults ?? {},
       courseAttempts = courseAttempts ?? {},
       solvedChallenges = solvedChallenges ?? [],
       badgesEarned = badgesEarned ?? {},
       skills = skills ?? {};

  int get xpForNextLevel => level * 500;

  int get progressToNext {
    int prev = (level - 1) * 500;
    double p = (xp - prev) / (xpForNextLevel - prev);
    if (p < 0) p = 0;
    if (p > 1) p = 1;
    return (p * 100).round();
  }

  int get levelFromXp {
    int lvl = 1;
    int remaining = xp;
    while (remaining >= lvl * 500) {
      remaining -= lvl * 500;
      lvl++;
    }
    return lvl;
  }

  void addXp(int amount) {
    xp += amount;
    level = levelFromXp;
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'level': level,
      'xp': xp,
      'streak': streak,
      'completedCourses': completedCourses,
      'quizResults': quizResults,
      'courseAttempts': courseAttempts,
      'solvedChallenges': solvedChallenges,
      'badgesEarned': badgesEarned.toList(),
      'skills': skills.map((k, v) => MapEntry(k, v.toJson())),
      'learningMinutes': learningMinutes,
      'selectedPath': selectedPath,
    };
  }

  factory UserState.fromJson(Map<String, dynamic> j) {
    Map<String, SkillProgress> skills = {};
    (j['skills'] as Map<String, dynamic>? ?? {}).forEach((k, v) {
      skills[k] = SkillProgress.fromJson(v as Map<String, dynamic>);
    });
    return UserState(
      name: j['name'] ?? '',
      level: j['level'] ?? 1,
      xp: j['xp'] ?? 0,
      streak: j['streak'] ?? 0,
      completedCourses: (j['completedCourses'] as List?)?.cast<String>() ?? [],
      quizResults: (j['quizResults'] as Map<String, dynamic>? ?? {}).map(
        (k, v) => MapEntry(k, (v as num).toInt()),
      ),
      courseAttempts: (j['courseAttempts'] as Map<String, dynamic>? ?? {}).map(
        (k, v) => MapEntry(k, (v as num).toInt()),
      ),
      solvedChallenges: (j['solvedChallenges'] as List?)?.cast<String>() ?? [],
      badgesEarned: (j['badgesEarned'] as List?)?.cast<String>().toSet() ?? {},
      skills: skills,
      learningMinutes: j['learningMinutes'] ?? 0,
      selectedPath: j['selectedPath'] ?? 'fundamentals',
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
    name: j['name'] ?? '',
    level: j['level'] ?? 0,
    xp: j['xp'] ?? 0,
  );
}
