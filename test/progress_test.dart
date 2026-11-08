import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cyberlab_agent/data/course_library.dart';
import 'package:cyberlab_agent/data/ctf_library.dart';
import 'package:cyberlab_agent/models/course.dart';
import 'package:cyberlab_agent/models/user_state.dart';
import 'package:cyberlab_agent/services/app_state.dart';
import 'package:cyberlab_agent/services/badge_service.dart';
import 'package:cyberlab_agent/services/secret_store.dart';

QuizQuestion _qcm(String id, {int xp = 10}) => QuizQuestion(
  id: id,
  type: QuizType.qcm,
  question: 'Q',
  options: ['a', 'b'],
  correctAnswer: '1',
  explanation: 'e',
  xp: xp,
);

Future<AppState> _app({DateTime Function()? clock}) async {
  final app = AppState(secrets: MemorySecretStore(), clock: clock);
  await app.ready;
  return app;
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('Attribution unique des XP (couche métier)', () {
    test('cours : completeCourse est l\'unique point d\'attribution', () async {
      final app = await _app();
      expect(await app.completeCourse('c1', 100, skill: 'Linux'), 100);
      expect(app.user.xp, 100, reason: 'pas de double gain');
      expect(await app.completeCourse('c1', 100, skill: 'Linux'), 0);
      expect(app.user.xp, 100);
      expect(app.user.completedCourses, ['c1']);
    });

    test('exercices : une récompense par exercice identifié', () async {
      final app = await _app();
      expect(
        await app.completeExercise('c1', 0, 50),
        0,
        reason: 'cours non terminé',
      );
      await app.completeCourse('c1', 100);
      expect(await app.completeExercise('c1', 0, 50), 50);
      expect(await app.completeExercise('c1', 0, 50), 0);
      expect(await app.completeExercise('c1', 1, 50), 50);
      expect(app.user.xp, 200);
    });

    test(
      'quiz : une récompense par question, ids distingués par cours',
      () async {
        final app = await _app();
        final q = _qcm('q1');
        final first = await app.answerQuiz('c1', q, '1');
        expect(first.correct, isTrue);
        expect(first.xpGained, 10);
        expect(first.alreadyRewarded, isFalse);
        final again = await app.answerQuiz('c1', q, '1');
        expect(again.xpGained, 0);
        expect(again.alreadyRewarded, isTrue);
        // « q1 » d'un autre cours est une autre question.
        expect((await app.answerQuiz('c2', q, '1')).xpGained, 10);
        expect(app.user.xp, 20);
      },
    );

    test('quiz : échec puis réussite rapporte encore les XP', () async {
      final app = await _app();
      final q = _qcm('q1', xp: 15);
      final fail = await app.answerQuiz('c1', q, '0');
      expect(fail.correct, isFalse);
      expect(fail.xpGained, 0);
      expect(app.user.quizResults['c1/q1'], 0);
      final ok = await app.answerQuiz('c1', q, '1');
      expect(ok.xpGained, 15);
      expect(app.user.quizResults['c1/q1'], 1);
      // Une erreur après réussite ne rétrograde pas la question.
      await app.answerQuiz('c1', q, '0');
      expect(app.user.quizResults['c1/q1'], 1);
    });

    test('SOC : une récompense par alerte, uniquement si correcte', () async {
      final app = await _app();
      expect(await app.resolveSocAlert('s1', false, 25), 0);
      expect(await app.resolveSocAlert('s1', true, 25), 25);
      expect(await app.resolveSocAlert('s1', true, 25), 0);
      expect(await app.resolveSocAlert('s2', true, 25), 25);
      expect(app.user.skills['Blueteam']!.xp, 50);
    });

    test('CTF : une récompense par challenge', () async {
      final app = await _app();
      expect(await app.solveChallenge('ctf-1', 50), 50);
      expect(await app.solveChallenge('ctf-1', 50), 0);
      expect(app.user.solvedChallenges, ['ctf-1']);
    });

    test('répétition après redémarrage : aucune nouvelle récompense', () async {
      var app = await _app();
      await app.completeCourse('c1', 100);
      await app.completeExercise('c1', 0, 50);
      await app.answerQuiz('c1', _qcm('q1'), '1');
      await app.resolveSocAlert('s1', true, 25);
      await app.solveChallenge('ctf-1', 50);
      await app.storage.flush();
      final xp = app.user.xp;
      expect(xp, 235);

      // « Redémarrage » : nouvel AppState relisant les mêmes préférences.
      app = await _app();
      expect(app.user.xp, xp);
      expect(await app.completeCourse('c1', 100), 0);
      expect(await app.completeExercise('c1', 0, 50), 0);
      expect((await app.answerQuiz('c1', _qcm('q1'), '1')).xpGained, 0);
      expect(await app.resolveSocAlert('s1', true, 25), 0);
      expect(await app.solveChallenge('ctf-1', 50), 0);
      expect(app.user.xp, xp);
    });
  });

  group('Série quotidienne (dates locales)', () {
    test('pas de double comptage le même jour, +1 le lendemain', () {
      final u = UserState();
      expect(u.registerActivity(DateTime(2026, 11, 8, 9)), isTrue);
      expect(u.streak, 1);
      expect(u.registerActivity(DateTime(2026, 11, 8, 23, 59)), isFalse);
      expect(u.streak, 1);
      u.registerActivity(DateTime(2026, 11, 9, 0, 1));
      expect(u.streak, 2);
      u.registerActivity(DateTime(2026, 11, 10, 12));
      expect(u.streak, 3);
    });

    test('un jour manqué remet la série à 1', () {
      final u = UserState()..registerActivity(DateTime(2026, 11, 1));
      u.registerActivity(DateTime(2026, 11, 2));
      u.registerActivity(DateTime(2026, 11, 4));
      expect(u.streak, 1);
    });

    test('changement de mois et passage à l\'heure d\'hiver', () {
      final u = UserState()..registerActivity(DateTime(2026, 10, 24, 22));
      u.registerActivity(DateTime(2026, 10, 25, 8)); // jour de 25 h (Europe)
      u.registerActivity(DateTime(2026, 10, 26, 8));
      u.registerActivity(DateTime(2026, 10, 31, 23));
      expect(u.streak, 1);
      u.registerActivity(DateTime(2026, 11, 1, 0, 30));
      expect(u.streak, 2);
    });

    test('série affichée : conservée la veille, 0 après un jour manqué', () {
      final u = UserState()..registerActivity(DateTime(2026, 11, 8));
      expect(u.currentStreak(DateTime(2026, 11, 8, 20)), 1);
      expect(u.currentStreak(DateTime(2026, 11, 9, 20)), 1);
      expect(u.currentStreak(DateTime(2026, 11, 10, 0, 1)), 0);
    });

    test('horloge reculée : rien n\'est modifié', () {
      final u = UserState()..registerActivity(DateTime(2026, 11, 8));
      expect(u.registerActivity(DateTime(2026, 11, 7)), isFalse);
      expect(u.streak, 1);
      expect(u.lastActiveDay, '2026-11-08');
    });

    test('AppState compte la série lors des activités', () async {
      var now = DateTime(2026, 11, 8, 10);
      final app = await _app(clock: () => now);
      await app.answerQuiz('c1', _qcm('q1'), '0');
      await app.recordAttempt('c1');
      expect(app.currentStreak, 1);
      now = DateTime(2026, 11, 9, 10);
      await app.recordAttempt('c1');
      expect(app.currentStreak, 2);
    });
  });

  group('Temps d\'apprentissage actif', () {
    test('seul le temps au premier plan est compté', () async {
      var now = DateTime(2026, 11, 8, 10);
      final app = await _app(clock: () => now);
      app.onAppResumed();
      now = now.add(const Duration(minutes: 5));
      await app.onAppPaused();
      expect(app.user.learningSeconds, 300);
      now = now.add(const Duration(hours: 3)); // arrière-plan : ignoré
      expect(app.learningMinutes, 5);
      app.onAppResumed();
      now = now.add(const Duration(minutes: 2));
      expect(app.learningMinutes, 7, reason: 'session en cours incluse');
      await app.onAppPaused();
      expect(app.user.learningSeconds, 420);
    });
  });

  group('Badges : source de vérité commune', () {
    test('les catégories des badges existent dans le contenu', () {
      final service = BadgeService();
      final courseCats = CourseLibrary.all.map((c) => c.category).toSet();
      final ctfCats = ctfChallenges().map((c) => c.category).toSet();
      for (final d in service.definitions) {
        if (d.type == 'courses') {
          expect(courseCats, contains(d.category), reason: d.badge.id);
        }
        if (d.type == 'ctf' && d.category != 'all') {
          expect(ctfCats, contains(d.category), reason: d.badge.id);
        }
      }
    });

    test('accueil et profil lisent la même liste, sauvegardée', () async {
      final app = await _app();
      final linux = CourseLibrary.byCategory('linux').take(5).toList();
      for (final c in linux) {
        await app.completeCourse(c.id, c.xp);
      }
      final ids = app.earnedBadges.map((d) => d.badge.id).toSet();
      expect(ids, contains('b-linux'));
      expect(app.user.badgesEarned, ids);
      expect(
        app.earnedBadges.length + app.lockedBadges.length,
        app.badgeService.definitions.length,
      );
    });
  });

  group('Migration des données v1.0.0', () {
    test(
      'conserve XP, notes, cours, CTF et n\'en redonne pas les XP',
      () async {
        SharedPreferences.setMockInitialValues({
          'user_state': jsonEncode({
            'name': 'Ada',
            'level': 7, // incohérent en v1 : recalculé
            'xp': 1600,
            'streak': 0,
            'completedCourses': ['c-old'],
            'quizResults': {'q1': 1},
            'courseAttempts': {'c-old': 3},
            'solvedChallenges': ['ctf-linux-1'],
            'badgesEarned': [],
            'skills': {
              'Linux': {'name': 'Linux', 'level': 10, 'xp': 100},
            },
            'learningMinutes': 12,
            'selectedPath': 'linux',
          }),
          'notes': jsonEncode([
            {
              'id': 'n1',
              'title': 'Ma note',
              'content': 'x',
              'category': 'Linux',
            },
          ]),
        });
        final app = await _app();
        expect(app.user.name, 'Ada');
        expect(app.user.xp, 1600);
        expect(app.user.level, 3);
        expect(app.user.learningSeconds, 720);
        expect(app.user.courseAttempts['c-old'], 3);
        expect(app.notes.single.title, 'Ma note');
        expect(await app.completeCourse('c-old', 100), 0);
        expect(await app.solveChallenge('ctf-linux-1', 50), 0);
        expect(app.user.xp, 1600);
        expect(app.user.schemaVersion, UserState.currentSchema);
      },
    );

    test('données illisibles : copie de secours, rien n\'est écrasé', () async {
      SharedPreferences.setMockInitialValues({'user_state': '{pas du json'});
      final app = await _app();
      expect(app.warnings, isNotEmpty);
      final prefs = await SharedPreferences.getInstance();
      final backups = prefs.getKeys().where(
        (k) => k.startsWith('user_state_corrupt_'),
      );
      expect(backups, hasLength(1));
      expect(prefs.getString(backups.first), '{pas du json');
    });
  });
}
