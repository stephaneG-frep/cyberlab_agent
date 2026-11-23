import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cyberlab_agent/data/course_library.dart';
import 'package:cyberlab_agent/data/ctf_library.dart';
import 'package:cyberlab_agent/data/packet_capture.dart';
import 'package:cyberlab_agent/data/scenarios.dart';
import 'package:cyberlab_agent/models/course.dart';
import 'package:cyberlab_agent/models/note.dart';
import 'package:cyberlab_agent/models/user_state.dart';
import 'package:cyberlab_agent/screens/learn_screen.dart';
import 'package:cyberlab_agent/screens/scenarios_screen.dart';
import 'package:cyberlab_agent/screens/search_screen.dart';
import 'package:cyberlab_agent/screens/stats_screen.dart';
import 'package:cyberlab_agent/services/app_state.dart';
import 'package:cyberlab_agent/services/backup_service.dart';
import 'package:cyberlab_agent/services/display_filter.dart';
import 'package:cyberlab_agent/services/reminder_service.dart';
import 'package:cyberlab_agent/services/search_service.dart';
import 'package:cyberlab_agent/services/secret_store.dart';
import 'package:cyberlab_agent/services/terminal_engine.dart';
import 'package:cyberlab_agent/widgets/quiz_runner.dart';

Future<AppState> _app({DateTime Function()? clock}) async {
  final app = AppState(
    secrets: MemorySecretStore(),
    reminders: MemoryReminderScheduler(),
    clock: clock,
  );
  await app.ready;
  return app;
}

Widget _wrap(Widget child, AppState app) =>
    ChangeNotifierProvider<AppState>.value(
      value: app,
      child: MaterialApp(home: child),
    );

Future<void> _phone(WidgetTester tester, double scale) async {
  tester.view.physicalSize = const Size(360, 740);
  tester.view.devicePixelRatio = 1.0;
  tester.platformDispatcher.textScaleFactorTestValue = scale;
  addTearDown(tester.view.reset);
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('Quiz : options mélangées', () {
    test('la position ne trahit plus la bonne réponse', () {
      final qcm = [
        for (final c in CourseLibrary.all)
          for (final q in c.quiz)
            if (q.type == QuizType.qcm) q,
      ];
      final rnd = Random(7);
      var first = 0;
      for (final q in qcm) {
        final order = QuizRunner.displayOrder(q.options!, rnd);
        expect(order.toSet(), {for (var i = 0; i < q.options!.length; i++) i});
        if ('${order.first}' == q.correct) first++;
      }
      // Environ 1 sur 4 attendu (contre 88 % dans l'ordre des données).
      expect(first / qcm.length, lessThan(0.40));
      expect(first / qcm.length, greaterThan(0.10));
    });

    test('« Aucune », « Rien… », « Toutes… » restent en dernier', () {
      for (var seed = 0; seed < 20; seed++) {
        expect(
          QuizRunner.displayOrder([
            'a',
            'Rien de tout ça',
            'b',
            'c',
          ], Random(seed)).last,
          1,
        );
      }
    });

    testWidgets('la réponse choisie reste la bonne malgré le mélange', (
      tester,
    ) async {
      for (final seed in [1, 2, 3]) {
        final app = await _app();
        final course = CourseLibrary.all.firstWhere((c) => c.id == 'ns-osi');
        final q = course.quiz.first;
        await tester.pumpWidget(
          _wrap(
            Scaffold(
              body: QuizRunner(
                key: ValueKey(seed),
                questions: [q],
                scopeId: course.id,
                random: Random(seed),
              ),
            ),
            app,
          ),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text(q.displayCorrect));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const ValueKey('quiz-submit')));
        await tester.pumpAndSettle();
        expect(find.text('Bonne réponse !'), findsOneWidget);
      }
    });
  });

  group('Recherche', () {
    final service = SearchService();

    test('sans accents ni casse, tous les mots exigés', () {
      final a = service.search('CHIFFREMENT SYMETRIQUE');
      final b = service.search('chiffrement symétrique');
      expect(a.map((h) => h.title), b.map((h) => h.title));
      expect(a.first.title, 'Le chiffrement symétrique');
      expect(service.search('chiffrement motquinexistepas'), isEmpty);
      expect(service.search(''), isEmpty);
      expect(service.search('x'), isEmpty);
    });

    test('trouve dans le texte, avec un extrait contenant le mot', () {
      final hit = service
          .search('Argon2id')
          .firstWhere((h) => h.kind == SearchKind.course);
      expect(hit.title, 'Stocker les mots de passe correctement');
      expect(hit.snippet, contains('Argon2id'));
      expect(
        service.search('nmap').map((h) => h.kind).toSet(),
        containsAll([SearchKind.course, SearchKind.sheet]),
      );
    });

    test('un titre passe devant une simple mention', () {
      expect(service.search('kerberos').first.title, 'Kerberos et NTLM');
    });

    test('les notes de l\'utilisateur sont incluses', () {
      final hits = service.search(
        'pamplemousse',
        notes: [Note(id: 'n', title: 'Courses', content: 'Un pamplemousse')],
      );
      expect(hits.single.kind, SearchKind.note);
    });

    test('aucune réponse de CTF ni de quiz n\'est indexée', () {
      // Une explication de quiz et une solution de CTF, propres à ces champs.
      for (final c in ctfChallenges()) {
        for (final h in service.search(c.explanation)) {
          expect(h.item, isNot(same(c)), reason: c.id);
        }
      }
      expect(
        service
            .search('FLAG{root_lit_tout_mais_ne_touche_a_rien}')
            .where((h) => h.kind == SearchKind.ctf),
        isEmpty,
      );
      expect(
        service
            .search('FLAG{base64_nest_pas_du_chiffrement}')
            .where((h) => h.kind == SearchKind.ctf),
        isEmpty,
      );
      final quizOnly = CourseLibrary.all
          .firstWhere((c) => c.id == 'ns-vpn')
          .quiz
          .last
          .explanation;
      expect(service.search(quizOnly), isEmpty);
    });

    test('le repli des accents conserve la longueur', () {
      const s = 'Événement d’Été — ŒUVRE ça';
      expect(SearchService.fold(s).length, s.length);
    });

    testWidgets('écran : résultats en direct, filtre, ouverture', (
      tester,
    ) async {
      final app = await _app();
      await tester.pumpWidget(_wrap(const LearnScreen(), app));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('open-search')));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const ValueKey('search-field')),
        'kerberos',
      );
      await tester.pumpAndSettle();
      expect(find.textContaining('Tout ('), findsOneWidget);
      await tester.tap(find.text('Kerberos et NTLM'));
      await tester.pumpAndSettle();
      expect(find.text('Objectifs'), findsOneWidget);
    });

    testWidgets('écran : aucun résultat annoncé clairement', (tester) async {
      final app = await _app();
      await tester.pumpWidget(_wrap(const SearchScreen(), app));
      await tester.enterText(
        find.byKey(const ValueKey('search-field')),
        'zzzzqq',
      );
      await tester.pumpAndSettle();
      expect(find.text('Aucun résultat pour « zzzzqq ».'), findsOneWidget);
    });
  });

  group('Enquêtes : données', () {
    test('identifiants uniques, étapes complètes', () {
      expect(scenarios.map((s) => s.id).toSet().length, scenarios.length);
      for (final s in scenarios) {
        expect(s.steps.length, greaterThanOrEqualTo(4), reason: s.id);
        expect(s.debrief, isNotEmpty);
        for (final st in s.steps) {
          for (final t in [st.title, st.instruction, st.hint, st.explanation]) {
            expect(t.trim(), isNotEmpty, reason: s.id);
          }
        }
      }
    });

    test('chaque étape se réussit avec sa solution, et pas sans travail', () {
      for (final s in scenarios) {
        for (final step in s.steps) {
          final where = '${s.id} / ${step.title}';
          switch (step) {
            case TerminalStep(:final checks, :final solution):
              List<bool> play(List<String> commands) {
                final e = TerminalEngine();
                final done = List.filled(checks.length, false);
                for (final c in commands) {
                  final r = e.run(c);
                  for (var i = 0; i < checks.length; i++) {
                    final ok = checks[i].test(e, c, r.output);
                    done[i] = checks[i].latched ? (done[i] || ok) : ok;
                  }
                }
                return done;
              }

              expect(
                play(solution.split('\n')).every((d) => d),
                isTrue,
                reason: where,
              );
              expect(
                play(['ls', 'pwd', 'help']).every((d) => d),
                isFalse,
                reason: where,
              );
            case FilterStep(:final solution):
              final n = DisplayFilter.parse(
                solution,
              ).apply(LabCapture.packets).length;
              expect(n, greaterThan(0), reason: where);
              expect(n, lessThan(LabCapture.packets.length), reason: where);
            case AnswerStep():
              expect(step.isCorrect(step.answer), isTrue, reason: where);
              expect(step.isCorrect('mauvaise réponse'), isFalse);
              expect(step.isCorrect(''), isFalse);
            case ChoiceStep(:final options, :final correct):
              expect(options.length, 4, reason: where);
              expect(correct, inInclusiveRange(0, 3));
              for (final o in options) {
                expect(o.feedback, isNotEmpty, reason: where);
              }
          }
        }
      }
    });

    test('les faits cités existent dans la capture', () {
      final p32 = LabCapture.packets.firstWhere((p) => p.no == 32);
      expect(p32.info, contains('08:00:27:66:66:66'));
      final p17 = LabCapture.packets.firstWhere((p) => p.no == 17);
      expect(p17.fields['http.file_data'], contains('Printemps2026!'));
      expect(p32.time, greaterThan(p17.time), reason: 'ordre du bilan');
    });

    test('barème : 100 XP, −10 par erreur, 50 au minimum', () {
      expect([0, 1, 3, 5, 99].map(Scenario.xpFor), [100, 90, 70, 50, 50]);
    });
  });

  group('Enquêtes : progression', () {
    test('avancement conservé, XP une seule fois', () async {
      var app = await _app();
      await app.completeScenarioStep('sc-dns', 0);
      await app.completeScenarioStep('sc-dns', 1);
      await app.completeScenarioStep('sc-dns', 0); // ne recule pas
      await app.scenarioError('sc-dns');
      await app.storage.flush();
      app = await _app();
      expect(app.scenarioProgress('sc-dns').step, 2);
      expect(app.scenarioProgress('sc-dns').errors, 1);
      expect(await app.solveScenario('sc-dns', 90), 90);
      expect(await app.solveScenario('sc-dns', 100), 0);
    });

    test('recommencer n\'efface pas les erreurs avant les XP', () async {
      final app = await _app();
      await app.completeScenarioStep('sc-web', 0);
      await app.scenarioError('sc-web');
      await app.restartScenario('sc-web');
      expect(app.scenarioProgress('sc-web').step, 0);
      expect(app.scenarioProgress('sc-web').errors, 1);
      await app.solveScenario('sc-web', 90);
      await app.restartScenario('sc-web');
      expect(app.scenarioProgress('sc-web').errors, 0);
    });

    test('badge Enquêteur après 3 enquêtes', () async {
      final app = await _app();
      for (final s in scenarios.take(2)) {
        await app.solveScenario(s.id, 100);
      }
      expect(
        app.earnedBadges.map((b) => b.badge.id),
        isNot(contains('b-scenario')),
      );
      await app.solveScenario(scenarios[2].id, 100);
      expect(app.earnedBadges.map((b) => b.badge.id), contains('b-scenario'));
    });

    Future<void> tapKey(WidgetTester t, String key) async {
      final f = find.byKey(ValueKey(key));
      await t.ensureVisible(f);
      await t.pumpAndSettle();
      await t.tap(f);
      await t.pumpAndSettle();
    }

    testWidgets('enquête complète : une erreur, puis 90 XP', (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      final app = await _app();
      final s = scenarios.firstWhere((s) => s.id == 'sc-dns');
      await tester.pumpWidget(
        _wrap(ScenarioScreen(scenario: s, random: Random(1)), app),
      );
      await tester.pumpAndSettle();
      var failed = false;
      for (final step in s.steps) {
        expect(
          tester.widget<Text>(find.byKey(const ValueKey('scenario-step'))).data,
          contains(step.title),
        );
        switch (step) {
          case TerminalStep(:final solution):
            for (final c in solution.split('\n')) {
              await tester.enterText(
                find.byKey(const ValueKey('terminal-input')),
                c,
              );
              await tester.testTextInput.receiveAction(TextInputAction.send);
              await tester.pumpAndSettle();
            }
          case FilterStep(:final solution):
            await tester.enterText(
              find.byKey(const ValueKey('scenario-input')),
              'arp',
            );
            await tester.pumpAndSettle();
            await tapKey(tester, 'scenario-check');
            expect(find.textContaining('Pas encore'), findsOneWidget);
            await tester.enterText(
              find.byKey(const ValueKey('scenario-input')),
              solution,
            );
            await tester.pumpAndSettle();
            await tapKey(tester, 'scenario-check');
          case AnswerStep(:final answer):
            await tester.enterText(
              find.byKey(const ValueKey('scenario-input')),
              answer,
            );
            await tester.pumpAndSettle();
            await tapKey(tester, 'scenario-check');
          case ChoiceStep(:final options, :final correct):
            if (!failed) {
              failed = true;
              final wrong = correct == 0 ? 1 : 0;
              await tapKey(tester, 'choice-$wrong');
              expect(find.text(options[wrong].feedback), findsOneWidget);
              // Une option déjà essayée ne coûte pas deux fois.
              await tapKey(tester, 'choice-$wrong');
            }
            await tapKey(tester, 'choice-$correct');
        }
        await tapKey(tester, 'scenario-next');
      }
      expect(find.textContaining('+90 XP'), findsOneWidget);
      expect(app.user.xp, 90);
    });
  });

  group('Statistiques', () {
    test('XP, actions et temps datés ; minuit réparti', () async {
      var now = DateTime(2026, 11, 23, 23, 50);
      final app = await _app(clock: () => now);
      app.onAppResumed();
      await app.solveChallenge('ctf-1', 50);
      now = DateTime(2026, 11, 24, 0, 20);
      await app.onAppPaused();
      final a = app.user.dailyLog['2026-11-23']!;
      final b = app.user.dailyLog['2026-11-24']!;
      expect((a.xp, a.actions, a.seconds), (50, 1, 600));
      expect((b.xp, b.seconds), (0, 1200));
      expect(app.user.learningSeconds, 1800, reason: 'total inchangé');
    });

    test(
      'série continue, jours vides à zéro, session en cours incluse',
      () async {
        var now = DateTime(2026, 11, 23, 10);
        final app = await _app(clock: () => now);
        await app.solveChallenge('ctf-1', 50);
        now = DateTime(2026, 11, 25, 10);
        app.onAppResumed();
        now = DateTime(2026, 11, 25, 10, 5);
        final days = app.activity(7);
        expect(days.length, 7);
        expect(days.last.day, DateTime(2026, 11, 25));
        expect(days.map((d) => d.stats.xp), [0, 0, 0, 0, 50, 0, 0]);
        expect(days.last.stats.minutes, 5);
      },
    );

    test(
      'journal borné, lecture tolérante, export et réinitialisation',
      () async {
        final u = UserState();
        for (var i = 0; i < UserState.maxLoggedDays + 30; i++) {
          u.logDay(localDayKey(DateTime(2025, 1, 1 + i)), xp: 1);
        }
        expect(u.dailyLog.length, UserState.maxLoggedDays);
        expect(u.dailyLog.containsKey('2025-01-01'), isFalse);

        final r = UserState.fromJson({
          'dailyLog': {
            '2026-11-23': {'xp': 5, 's': 60, 'a': 1},
            'pas une date': {'xp': 9},
            '2026-11-24': 'x',
          },
          'scenarios': {
            'sc-dns': 'x',
            'sc-web': {'step': 2},
          },
        });
        expect(r.dailyLog.keys, ['2026-11-23']);
        expect(r.scenarios.keys, ['sc-web']);

        final app = await _app(clock: () => DateTime(2026, 11, 23, 10));
        await app.solveChallenge('ctf-1', 50);
        final back = BackupFormat.decode(await app.exportData());
        expect(back.user.dailyLog['2026-11-23']!.xp, 50);
        await app.resetProgress();
        expect(app.user.dailyLog, isEmpty);
      },
    );

    test('une sauvegarde antérieure à la 1.6.0 se charge sans journal', () {
      final u = UserState.fromJson({'schemaVersion': 2, 'xp': 120});
      expect(u.xp, 120);
      expect(u.dailyLog, isEmpty);
    });

    test('axe rond et regroupement par semaine', () {
      expect([0, 1, 2, 3, 7, 11, 95, 101, 1500].map(niceMax), [
        2, 2, 2, 4, 8, 20, 100, 200, 2000, //
      ]);
      final days = [
        for (var i = 0; i < 90; i++)
          (day: DateTime(2026, 8, 26 + i), stats: DayStats(xp: 1, seconds: 30)),
      ];
      final b = bucketize(days, 7);
      expect(b.length, 13);
      expect(b.last.to, days.last.day);
      expect(b.fold(0, (a, x) => a + x.xp), 90);
      expect(b.last.minutes, 3, reason: '7 × 30 s = 3 min 30');
    });

    testWidgets('écran : lecture au toucher, périodes, tableau', (
      tester,
    ) async {
      var now = DateTime(2026, 11, 23, 10);
      final app = await _app(clock: () => now);
      await app.solveChallenge('ctf-1', 50);
      now = DateTime(2026, 11, 25, 10);
      await app.solveChallenge('ctf-2', 70);
      await tester.pumpWidget(_wrap(const StatsScreen(), app));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('stats-7')));
      await tester.pumpAndSettle();
      final plot = find.byKey(const ValueKey('stats-plot'));
      final box = tester.getRect(plot);
      await tester.tapAt(Offset(box.right - 5, box.center.dy));
      await tester.pumpAndSettle();
      expect(find.text('70 XP · 25 nov.'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('stats-90')));
      await tester.pumpAndSettle();
      expect(find.text('XP gagnés par semaine'), findsOneWidget);
      expect(find.textContaining('Touchez une colonne'), findsOneWidget);
    });

    testWidgets('écran vide : message, pas de graphique', (tester) async {
      final app = await _app();
      await tester.pumpWidget(_wrap(const StatsScreen(), app));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('stats-plot')), findsNothing);
      expect(find.textContaining('Aucune activité'), findsOneWidget);
    });
  });

  group('Police à 200 % et règles d\'accessibilité', () {
    final screens = <(String, Widget)>[
      ('statistiques', const StatsScreen()),
      ('recherche', const SearchScreen()),
      ('enquêtes', const Scaffold(body: ScenariosView())),
      for (final s in scenarios) (s.id, ScenarioScreen(scenario: s)),
    ];
    for (final (name, screen) in screens) {
      testWidgets(name, (tester) async {
        final handle = tester.ensureSemantics();
        SharedPreferences.setMockInitialValues({
          'user_state': jsonEncode({
            'schemaVersion': 2,
            'dailyLog': {
              localDayKey(DateTime.now()): {'xp': 1250, 's': 3600, 'a': 4},
            },
          }),
        });
        final app = await _app();
        await _phone(tester, 2.0);
        await tester.pumpWidget(_wrap(screen, app));
        await tester.pumpAndSettle();
        await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
        await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
        handle.dispose();
      });
    }
  });
}
