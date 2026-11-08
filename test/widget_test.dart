import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cyberlab_agent/data/course_library.dart';
import 'package:cyberlab_agent/main.dart';
import 'package:cyberlab_agent/models/coach_message.dart';
import 'package:cyberlab_agent/models/course.dart';
import 'package:cyberlab_agent/screens/coach_screen.dart';
import 'package:cyberlab_agent/screens/course_view.dart';
import 'package:cyberlab_agent/screens/ctf_screen.dart';
import 'package:cyberlab_agent/screens/notes_screen.dart';
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

Future<void> _smallScreen(WidgetTester tester) async {
  tester.view.physicalSize = const Size(320, 480);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('l\'app se construit et affiche la navigation', (tester) async {
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
}
