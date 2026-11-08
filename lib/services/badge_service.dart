import '../data/badges.dart';
import '../data/course_library.dart';
import '../data/ctf_library.dart';
import '../models/course.dart';
import '../models/ctf_challenge.dart';
import '../models/user_state.dart';

/// Source de vérité unique des badges (accueil, profil, sauvegarde).
class BadgeService {
  BadgeService({List<Course>? courses, List<CtfChallenge>? challenges})
    : _courses = courses ?? CourseLibrary.all,
      _challenges = challenges ?? ctfChallenges();

  final List<Course> _courses;
  final List<CtfChallenge> _challenges;
  final List<BadgeDef> definitions = badgeDefs();

  bool isEarned(BadgeDef d, UserState user) {
    switch (d.type) {
      case 'courses':
        final count = _courses
            .where((c) => c.category == d.category)
            .where((c) => user.completedCourses.contains(c.id))
            .length;
        return count >= d.threshold;
      case 'ctf':
        final solved = user.solvedChallenges.toSet();
        if (d.category == 'all') return solved.length >= d.threshold;
        final count = _challenges
            .where((c) => c.category == d.category)
            .where((c) => solved.contains(c.id))
            .length;
        return count >= d.threshold;
      case 'level':
        return user.level >= d.threshold;
      default:
        return false;
    }
  }

  List<BadgeDef> earned(UserState user) =>
      definitions.where((d) => isEarned(d, user)).toList();

  List<BadgeDef> locked(UserState user) =>
      definitions.where((d) => !isEarned(d, user)).toList();

  Set<String> earnedIds(UserState user) =>
      earned(user).map((d) => d.badge.id).toSet();
}
