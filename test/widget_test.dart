import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cyberlab_agent/data/course_library.dart';
import 'package:cyberlab_agent/data/ctf_library.dart';
import 'package:cyberlab_agent/main.dart';
import 'package:cyberlab_agent/models/coach_message.dart';
import 'package:cyberlab_agent/models/course.dart';
import 'package:cyberlab_agent/screens/coach_screen.dart';
import 'package:cyberlab_agent/screens/course_view.dart';
import 'package:cyberlab_agent/screens/ctf_screen.dart';
import 'package:cyberlab_agent/screens/notes_screen.dart';
import 'package:cyberlab_agent/screens/profile_screen.dart';
import 'package:cyberlab_agent/screens/settings_screen.dart';
import 'dart:math';
import 'package:cyberlab_agent/data/soc_alerts.dart';
import 'package:cyberlab_agent/screens/terminal_screen.dart';
import 'package:cyberlab_agent/screens/wireshark_screen.dart';
import 'package:cyberlab_agent/widgets/soc_simulator.dart';
import 'package:cyberlab_agent/services/backup_service.dart';
import 'package:cyberlab_agent/services/app_state.dart';
import 'package:cyberlab_agent/services/secret_store.dart';
import 'package:cyberlab_agent/widgets/quiz_runner.dart';

AppState _state({http.Client? client}) =>
    AppState(secrets: MemorySecretStore(), httpClient: client);

Widget _app() =>
    ChangeNotifierProvider(create: (_) => _state(), child: const CyberLabApp());

Widget _wrapped(Widget child, {AppState? app}) =>
    ChangeNotifierProvider<AppState>(
      create: (_) => app ?? _state(),
      child: MaterialApp(home: child),
    );

/// Fait défiler la liste principale jusqu'à [target] puis le centre.
Future<void> _reveal(WidgetTester tester, Finder target) async {
  await tester.scrollUntilVisible(
    target,
    200,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.ensureVisible(target);
  await tester.pumpAndSettle();
}

Future<void> _smallScreen(WidgetTester tester) async {
  tester.view.physicalSize = const Size(320, 480);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('l\'app se construit et affiche la navigation', (tester) async {
    SharedPreferences.setMockInitialValues({
      'settings': jsonEncode({'onboardingDone': true}),
    });
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();

    expect(find.text('Accueil'), findsWidgets);
    expect(find.text('Apprendre'), findsWidgets);
    expect(find.text('Lab'), findsWidgets);
    expect(find.text('CTF'), findsWidgets);
    expect(find.text('Profil'), findsWidgets);
  });

  testWidgets('l\'écran CTF se construit', (tester) async {
    await tester.pumpWidget(_wrapped(const CtfScreen()));
    await tester.pumpAndSettle();
    expect(find.text('Challenges CTF'), findsOneWidget);
  });

  testWidgets('l\'écran Notes affiche l\'état vide', (tester) async {
    await tester.pumpWidget(_wrapped(const NotesScreen()));
    await tester.pumpAndSettle();
    expect(find.text('Cyber Notes'), findsOneWidget);
  });

  testWidgets('ouverture du quiz d\'un cours et défilement sur petit écran', (
    tester,
  ) async {
    await _smallScreen(tester);
    final course = CourseLibrary.all.first;
    await tester.pumpWidget(_wrapped(CourseView(course: course)));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Quiz'));
    await tester.pumpAndSettle();
    expect(
      tester.takeException(),
      isNull,
      reason: 'plus de Spacer en ListView',
    );
    expect(
      find.text('Question 1/${course.quiz.length} · 10 XP'),
      findsOneWidget,
    );
    final submit = find.byKey(const ValueKey('quiz-submit'));
    await tester.scrollUntilVisible(
      submit,
      100,
      scrollable: find.descendant(
        of: find.byKey(const ValueKey('quiz-list')),
        matching: find.byType(Scrollable),
      ),
    );
    expect(submit, findsOneWidget);
    expect(tester.widget<FilledButton>(submit).onPressed, isNull);
  });

  testWidgets(
    'saisie libre : Valider s\'active, champ vidé à la question suivante',
    (tester) async {
      final app = _state();
      final questions = [
        QuizQuestion(
          id: 'f1',
          type: QuizType.free,
          question: 'Quel protocole sécurise HTTPS ?',
          correctAnswer: 'TLS',
          explanation: 'HTTPS = HTTP + TLS',
          xp: 12,
        ),
        QuizQuestion(
          id: 'f2',
          type: QuizType.practical,
          question: 'Commande ?',
          correctAnswer: 'ls -a',
          explanation: 'e',
        ),
      ];
      await tester.pumpWidget(
        _wrapped(
          Scaffold(
            body: QuizRunner(questions: questions, scopeId: 'test'),
          ),
          app: app,
        ),
      );
      await tester.pumpAndSettle();

      FilledButton submit() => tester.widget<FilledButton>(
        find.byKey(const ValueKey('quiz-submit')),
      );
      final field = find.byKey(const ValueKey('quiz-free-answer'));

      expect(submit().onPressed, isNull, reason: 'réponse vide');
      await tester.enterText(field, '   ');
      await tester.pump();
      expect(submit().onPressed, isNull, reason: 'espaces seuls');
      await tester.enterText(field, 'tls');
      await tester.pump();
      expect(submit().onPressed, isNotNull);

      await tester.tap(find.byKey(const ValueKey('quiz-submit')));
      await tester.pumpAndSettle();
      expect(find.text('Bonne réponse !'), findsOneWidget);
      expect(find.text('+12 XP gagnés'), findsOneWidget);
      expect(app.user.xp, 12);

      await tester.tap(find.byKey(const ValueKey('quiz-next')));
      await tester.pumpAndSettle();
      expect(find.text('Commande ?'), findsOneWidget);
      expect(tester.widget<TextField>(field).controller!.text, isEmpty);
      expect(submit().onPressed, isNull);
    },
  );

  testWidgets(
    'quitter le coach pendant une requête ne provoque pas d\'erreur',
    (tester) async {
      final pending = Completer<http.Response>();
      final app = _state(client: MockClient((_) => pending.future));
      await tester.runAsync(() async {
        await app.ready;
        await app.saveAiConfig(
          provider: 'ollama',
          model: 'llm',
          baseUrl: 'http://192.168.1.10:11434',
        );
      });

      await tester.pumpWidget(
        _wrapped(
          Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: TextButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const CoachScreen()),
                  ),
                  child: const Text('ouvrir'),
                ),
              ),
            ),
          ),
          app: app,
        ),
      );
      await tester.tap(find.text('ouvrir'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const ValueKey('coach-input')),
        'Aide ?',
      );
      await tester.tap(find.byKey(const ValueKey('coach-send')));
      await tester.pump();
      await tester.pump();
      expect(app.coachBusy, isTrue);

      // L'utilisateur quitte l'écran avant la réponse.
      tester.state<NavigatorState>(find.byType(Navigator)).pop();
      await tester.pumpAndSettle();
      expect(find.byType(CoachScreen), findsNothing);

      pending.complete(
        http.Response.bytes(
          utf8.encode(
            jsonEncode({
              'message': {'content': 'Indice 1'},
            }),
          ),
          200,
        ),
      );
      // Laisse la réponse simulée traverser la pile HTTP (vraie boucle).
      await tester.runAsync(() async {
        for (var i = 0; i < 20 && app.coachBusy; i++) {
          await Future<void>.delayed(const Duration(milliseconds: 10));
        }
      });
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(app.coachBusy, isFalse);
      expect(app.coachMessages.last.role, CoachRole.assistant);
      expect(app.coachMessages.last.text, 'Indice 1');
    },
  );

  testWidgets('fin de cours : quiz requis avant de gagner les XP', (
    tester,
  ) async {
    final app = _state();
    await app.ready;
    final course = CourseLibrary.all.first;
    await tester.pumpWidget(_wrapped(CourseView(course: course), app: app));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Exercices'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('course-quiz-required')),
      300,
    );
    expect(find.textContaining('Réussissez le quiz'), findsOneWidget);
    expect(find.textContaining('Terminer le cours'), findsNothing);
  });

  testWidgets('Paramètres : avertissement HTTP en clair', (tester) async {
    await tester.pumpWidget(_wrapped(const SettingsScreen()));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('ai-network-warning')), findsNothing);
    await tester.enterText(
      find.byKey(const ValueKey('ai-base-url')),
      'http://192.168.1.20:11434',
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('ai-network-warning')), findsOneWidget);
    expect(find.textContaining('messages transitent en clair'), findsOneWidget);
  });

  testWidgets('CTF : la solution demande confirmation et reste consultée', (
    tester,
  ) async {
    final app = _state();
    await app.ready;
    final challenge = ctfChallenges().first;
    await tester.pumpWidget(
      _wrapped(ChallengeView(challenge: challenge), app: app),
    );
    await tester.pumpAndSettle();
    for (var i = 0; i < challenge.hints.length; i++) {
      await tester.scrollUntilVisible(
        find.text('Révéler un indice'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.ensureVisible(find.text('Révéler un indice'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Révéler un indice'));
      await tester.pumpAndSettle();
    }
    await tester.scrollUntilVisible(
      find.text('Voir la solution'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.ensureVisible(find.text('Voir la solution'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Voir la solution'));
    await tester.pumpAndSettle();
    expect(find.text('Voir la solution ?'), findsOneWidget);
    await tester.tap(find.text('Voir la solution').last);
    await tester.pumpAndSettle();
    expect(app.isSolutionRevealed(challenge.id), isTrue);

    // Nouvelle visite (nouvel état d'écran) : la solution est toujours
    // affichée, sans XP possible.
    await tester.pumpWidget(
      _wrapped(
        ChallengeView(key: UniqueKey(), challenge: challenge),
        app: app,
      ),
    );
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.textContaining('Solution (consultée'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.textContaining('Solution (consultée'), findsOneWidget);
  });

  testWidgets('premier lancement : prénom et parcours, puis accueil', (
    tester,
  ) async {
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();
    expect(find.text('Bienvenue dans CyberLab Agent'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('onboarding-next')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('onboarding-name')),
      'Ada',
    );
    await tester.tap(find.byKey(const ValueKey('onboarding-next')));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const ValueKey('path-linux')));
    await tester.tap(find.byKey(const ValueKey('path-linux')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('onboarding-next')));
    await tester.pumpAndSettle();

    expect(find.textContaining('Ada'), findsWidgets);
    expect(find.text('Parcours Linux'), findsOneWidget);
    expect(find.text('Accueil'), findsWidgets);
  });

  testWidgets('premier lancement : « Passer » ouvre directement l\'app', (
    tester,
  ) async {
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('onboarding-skip')));
    await tester.pumpAndSettle();
    expect(find.text('Parcours Fondamentaux'), findsOneWidget);
  });

  testWidgets('profil : changement de parcours', (tester) async {
    final app = _state();
    await app.ready;
    await tester.pumpWidget(_wrapped(const ProfileScreen(), app: app));
    await tester.pumpAndSettle();
    expect(find.text('Parcours : Fondamentaux'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('change-path')));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const ValueKey('path-python')));
    await tester.tap(find.byKey(const ValueKey('path-python')));
    await tester.pumpAndSettle();
    expect(app.currentPath.id, 'python');
    expect(find.text('Parcours : Python'), findsOneWidget);
  });

  testWidgets('Paramètres : export puis import d\'une sauvegarde', (
    tester,
  ) async {
    final files = _FakeFiles();
    final app = _state();
    await app.ready;
    await app.completeOnboarding(name: 'Ada', path: 'bash');
    await tester.pumpWidget(_wrapped(SettingsScreen(files: files), app: app));
    await tester.pumpAndSettle();

    await _reveal(tester, find.byKey(const ValueKey('export-button')));
    await tester.tap(find.byKey(const ValueKey('export-button')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('export-confirm')));
    await tester.pumpAndSettle();
    expect(files.savedName, startsWith('cyberlab-sauvegarde-'));
    expect(files.saved, contains('"name": "Ada"'));
    expect(find.text('Sauvegarde exportée.'), findsOneWidget);
    // Laisse le message d'export disparaître (les messages sont en file).
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();

    // Import d'une autre sauvegarde.
    files.toOpen = files.saved!.replaceFirst('"name": "Ada"', '"name": "Bob"');
    await _reveal(tester, find.byKey(const ValueKey('import-button')));
    await tester.tap(find.byKey(const ValueKey('import-button')));
    await tester.pumpAndSettle();
    expect(find.text('Remplacer la progression ?'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('import-confirm')));
    await tester.pumpAndSettle();
    expect(app.user.name, 'Bob');
    expect(find.text('Progression importée.'), findsOneWidget);
  });

  testWidgets('Paramètres : fichier invalide refusé sans rien modifier', (
    tester,
  ) async {
    final files = _FakeFiles()..toOpen = '{"kind":"autre"}';
    final app = _state();
    await app.ready;
    await app.completeOnboarding(name: 'Ada');
    await tester.pumpWidget(_wrapped(SettingsScreen(files: files), app: app));
    await tester.pumpAndSettle();
    await _reveal(tester, find.byKey(const ValueKey('import-button')));
    await tester.tap(find.byKey(const ValueKey('import-button')));
    await tester.pumpAndSettle();
    expect(find.textContaining('n\'est pas un export'), findsOneWidget);
    expect(app.user.name, 'Ada');
  });

  testWidgets('terminal : commandes réelles et session conservée', (
    tester,
  ) async {
    TerminalSession.reset();
    addTearDown(TerminalSession.reset);
    await tester.pumpWidget(const MaterialApp(home: TerminalScreen()));
    await tester.enterText(
      find.byKey(const ValueKey('terminal-input')),
      'cd logs',
    );
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    expect(find.text(r'~/logs$ '), findsWidgets);
    await tester.enterText(
      find.byKey(const ValueKey('terminal-input')),
      'grep -c Failed auth.log',
    );
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    expect(find.text('7'), findsOneWidget);

    // Écran recréé (ex. passage par l'onglet SOC) : rien n'est perdu.
    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(const MaterialApp(home: TerminalScreen()));
    await tester.pumpAndSettle();
    expect(find.text('7'), findsOneWidget);
    expect(find.text(r'~/logs$ '), findsWidgets);
  });

  testWidgets('SOC : bonne analyse récompensée, progression mise à jour', (
    tester,
  ) async {
    final app = _state();
    await app.ready;
    await tester.pumpWidget(
      _wrapped(
        Scaffold(body: SocSimulator(random: Random(1))),
        app: app,
      ),
    );
    await tester.pumpAndSettle();
    expect(
      find.text('Alertes réussies : 0 / ${SocCatalog.alerts.length}'),
      findsOneWidget,
    );

    final title = tester
        .widget<Text>(find.byKey(const ValueKey('soc-title')))
        .data!;
    final alert = SocCatalog.alerts.firstWhere((a) => a.title == title);
    await _reveal(tester, find.widgetWithText(ChoiceChip, alert.severity));
    await tester.tap(find.widgetWithText(ChoiceChip, alert.severity));
    await _reveal(tester, find.widgetWithText(ChoiceChip, alert.decision));
    await tester.tap(find.widgetWithText(ChoiceChip, alert.decision));
    await tester.pump();
    await _reveal(tester, find.byKey(const ValueKey('soc-submit')));
    await tester.tap(find.byKey(const ValueKey('soc-submit')));
    await tester.pumpAndSettle();

    expect(
      find.textContaining('Excellente analyse ! (+25 XP)'),
      findsOneWidget,
    );
    expect(find.textContaining(alert.action), findsOneWidget);
    expect(app.user.xp, 25);
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('soc-progress')),
      -200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(
      find.text('Alertes réussies : 1 / ${SocCatalog.alerts.length}'),
      findsOneWidget,
    );
  });

  testWidgets('SOC : la nouvelle alerte n\'est jamais la même', (tester) async {
    await tester.pumpWidget(
      _wrapped(Scaffold(body: SocSimulator(random: Random(3)))),
    );
    await tester.pumpAndSettle();
    for (var i = 0; i < 5; i++) {
      final before = tester
          .widget<Text>(find.byKey(const ValueKey('soc-title')))
          .data;
      await _reveal(tester, find.byKey(const ValueKey('soc-next')));
      await tester.tap(find.byKey(const ValueKey('soc-next')));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.byKey(const ValueKey('soc-title')),
        -200,
        scrollable: find.byType(Scrollable).first,
      );
      final after = tester
          .widget<Text>(find.byKey(const ValueKey('soc-title')))
          .data;
      expect(after, isNot(before));
    }
  });

  testWidgets('Wireshark : filtre en direct, erreur, exercice validé', (
    tester,
  ) async {
    final app = _state();
    await app.ready;
    await tester.pumpWidget(
      _wrapped(const Scaffold(body: WiresharkScreen()), app: app),
    );
    await tester.pumpAndSettle();
    await tester.tap(
      find.descendant(
        of: find.byType(SegmentedButton<int>),
        matching: find.text('Capture'),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('32 / 32 paquets'), findsOneWidget);

    // Filtre invalide : message d'erreur, bouton désactivé.
    await tester.enterText(
      find.byKey(const ValueKey('ws-filter')),
      'ip.addr = 1',
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('=='), findsWidgets);
    expect(
      tester
          .widget<FilledButton>(find.byKey(const ValueKey('ws-check')))
          .onPressed,
      isNull,
    );

    // Exercice 1 : une autre écriture que la référence est acceptée.
    await tester.enterText(
      find.byKey(const ValueKey('ws-filter')),
      'ip.src == 192.168.56.10 or ip.dst == 192.168.56.10',
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('7 / 32 paquets'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('ws-check')));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Bravo ! Filtre correct (+20 XP)'),
      findsOneWidget,
    );
    expect(app.user.xp, 20);

    // Exercice suivant : un filtre faux est expliqué.
    await tester.tap(find.byKey(const ValueKey('ws-next')));
    await tester.pumpAndSettle();
    // (« udp » serait accepté : ici, tout l'UDP est du DNS.)
    await tester.enterText(find.byKey(const ValueKey('ws-filter')), 'arp');
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('ws-check')));
    await tester.pumpAndSettle();
    expect(find.textContaining('Pas encore'), findsOneWidget);
  });

  testWidgets('Wireshark : le détail du paquet 17 révèle le mot de passe', (
    tester,
  ) async {
    await tester.pumpWidget(_wrapped(const Scaffold(body: CaptureLab())));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('ws-filter')),
      'http.request.method == "POST"',
    );
    await tester.pumpAndSettle();
    await _reveal(tester, find.byKey(const ValueKey('packet-17')));
    await tester.tap(find.byKey(const ValueKey('packet-17')));
    await tester.pumpAndSettle();
    expect(find.textContaining('Printemps2026!'), findsOneWidget);
  });
}

class _FakeFiles implements BackupFiles {
  String? saved;
  String? savedName;
  String? toOpen;

  @override
  Future<bool> save(String fileName, String content) async {
    savedName = fileName;
    saved = content;
    return true;
  }

  @override
  Future<String?> open() async => toOpen;
}
