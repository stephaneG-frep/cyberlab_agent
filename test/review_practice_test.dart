import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cyberlab_agent/data/course_library.dart';
import 'package:cyberlab_agent/data/learning_paths.dart';
import 'package:cyberlab_agent/data/terminal_exercises.dart';
import 'package:cyberlab_agent/models/user_state.dart';
import 'package:cyberlab_agent/screens/course_view.dart';
import 'package:cyberlab_agent/screens/review_screen.dart';
import 'package:cyberlab_agent/screens/terminal_practice_screen.dart';
import 'package:cyberlab_agent/services/app_state.dart';
import 'package:cyberlab_agent/services/reminder_service.dart';
import 'package:cyberlab_agent/services/secret_store.dart';

Future<AppState> _app() async {
  final app = AppState(
    secrets: MemorySecretStore(),
    reminders: MemoryReminderScheduler(),
  );
  await app.ready;
  return app;
}

Widget _wrap(Widget child, AppState app) =>
    ChangeNotifierProvider<AppState>.value(
      value: app,
      child: MaterialApp(home: child),
    );

Future<void> _enter(WidgetTester tester, String command) async {
  await tester.enterText(find.byKey(const ValueKey('terminal-input')), command);
  await tester.testTextInput.receiveAction(TextInputAction.send);
  await tester.pumpAndSettle();
}

void main() {
  setUp(
    () => SharedPreferences.setMockInitialValues({
      'settings': jsonEncode({'onboardingDone': true}),
    }),
  );

  group('Nouveaux niveaux', () {
    test('niveaux 5, 7, 8, 9 et OWASP complet présents', () {
      final counts = <String, int>{};
      for (final c in CourseLibrary.all) {
        counts[c.category] = (counts[c.category] ?? 0) + 1;
      }
      expect(counts['network_security'], 10);
      expect(counts['crypto'], 8);
      expect(counts['incident_response'], 8);
      expect(counts['windows'], 8);
      expect(counts['web_security'], 18);
      expect(CourseLibrary.all.length, 135);
      for (final cat in [
        'network_security',
        'crypto',
        'incident_response',
        'windows',
      ]) {
        expect(LearningPaths.isValid(cat), isTrue, reason: cat);
      }
    });

    test(
      'le renvoi au « niveau 5 - Sécurité réseau » mène à un vrai niveau',
      () {
        final levels = CourseLibrary.all.map((c) => c.level).toSet();
        expect(levels, contains('Niveau 5 - Sécurité réseau'));
        final osi = CourseLibrary.all.firstWhere((c) => c.id == 'ns-osi');
        expect(osi.levelNumber, 5);
      },
    );

    test('chaque nouveau cours a au moins 3 questions et un résumé', () {
      for (final c in CourseLibrary.all.where(
        (c) => const {
          'network_security',
          'crypto',
          'incident_response',
          'windows',
        }.contains(c.category),
      )) {
        expect(c.quiz.length, greaterThanOrEqualTo(3), reason: c.id);
        expect(c.sections.length, greaterThanOrEqualTo(3), reason: c.id);
        expect(c.summary, isNotEmpty);
        final ids = c.quiz.map((q) => q.id).toSet();
        expect(ids.length, c.quiz.length, reason: '${c.id} : ids de questions');
      }
    });
  });

  group('Révision', () {
    test(
      'une erreur entre en révision, une réussite l\'en sort (avec XP)',
      () async {
        final app = await _app();
        final course = CourseLibrary.all.firstWhere((c) => c.id == 'cr-hash');
        final q = course.quiz.first;
        final wrong = q.correct == '0' ? '1' : '0';
        expect(app.mistakes, isEmpty);
        await app.answerQuiz(course.id, q, wrong);
        expect(app.mistakes.map((m) => m.$2.id), [q.id]);
        final ok = await app.answerQuiz(course.id, q, q.correct);
        expect(ok.xpGained, q.xp);
        expect(app.mistakes, isEmpty);
      },
    );

    test('l\'entraînement puise dans les cours terminés', () async {
      SharedPreferences.setMockInitialValues({
        'user_state': jsonEncode({
          'schemaVersion': 2,
          'completedCourses': ['cr-hash', 'cr-tls'],
        }),
      });
      final app = await _app();
      expect(app.practicePool.map((p) => p.$1.id).toSet(), {
        'cr-hash',
        'cr-tls',
      });
    });

    testWidgets(
      'session « Mes erreurs » : réponse juste créditée au bon cours',
      (tester) async {
        final app = await _app();
        final course = CourseLibrary.all.firstWhere((c) => c.id == 'ns-osi');
        final q = course.quiz.first; // QCM, bonne réponse : index 0
        await app.answerQuiz(course.id, q, '1');
        await tester.pumpWidget(_wrap(ReviewScreen(random: Random(1)), app));
        await tester.pumpAndSettle();
        expect(find.text('Mes erreurs (1)'), findsOneWidget);
        await tester.tap(find.byKey(const ValueKey('review-mistakes')));
        await tester.pumpAndSettle();
        expect(find.text('Cours : ${course.title}'), findsOneWidget);
        await tester.tap(find.text(q.options!.first));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const ValueKey('quiz-submit')));
        await tester.pumpAndSettle();
        expect(find.text('Bonne réponse !'), findsOneWidget);
        expect(app.isRewarded(RewardKeys.quiz(course.id, q.id)), isTrue);
        expect(app.mistakes, isEmpty);
      },
    );
  });

  group('Pratique vérifiée', () {
    testWidgets('la carte apparaît dans les exercices du cours', (
      tester,
    ) async {
      final app = await _app();
      final course = CourseLibrary.all.firstWhere((c) => c.id == 'lin-chmod');
      await tester.pumpWidget(_wrap(CourseView(course: course), app));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Exercices'));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('practice-card')), findsOneWidget);
      expect(find.textContaining('Protéger un fichier'), findsOneWidget);
    });

    testWidgets('critères cochés au fil des commandes, XP une seule fois', (
      tester,
    ) async {
      final app = await _app();
      final ex = terminalExercises['lin-navigation']!;
      await tester.pumpWidget(
        _wrap(TerminalPracticeScreen(exercise: ex, skill: 'Linux'), app),
      );
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('practice-success')), findsNothing);

      await _enter(tester, 'mkdir -p rapports/2026');
      expect(find.byKey(const ValueKey('practice-success')), findsNothing);
      await _enter(tester, 'cp notes.txt rapports/2026/');
      expect(find.byKey(const ValueKey('practice-success')), findsOneWidget);
      expect(find.textContaining('+15 XP'), findsOneWidget);
      expect(app.user.xp, 15);

      // Recommencer : fichiers neufs, pas de nouveaux XP.
      await tester.tap(find.byTooltip('Recommencer avec des fichiers neufs'));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('practice-success')), findsNothing);
      await _enter(
        tester,
        'mkdir -p rapports/2026 && cp notes.txt rapports/2026/',
      );
      expect(find.textContaining('XP déjà obtenus'), findsOneWidget);
      expect(app.user.xp, 15);
    });
  });
}
