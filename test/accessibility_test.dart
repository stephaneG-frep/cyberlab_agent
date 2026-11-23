import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cyberlab_agent/data/course_library.dart';
import 'package:cyberlab_agent/data/ctf_library.dart';
import 'package:cyberlab_agent/main.dart';
import 'package:cyberlab_agent/screens/course_view.dart';
import 'package:cyberlab_agent/screens/ctf_screen.dart';
import 'package:cyberlab_agent/screens/onboarding_screen.dart';
import 'package:cyberlab_agent/screens/profile_screen.dart';
import 'package:cyberlab_agent/screens/settings_screen.dart';
import 'package:cyberlab_agent/screens/terminal_screen.dart';
import 'package:cyberlab_agent/services/app_state.dart';
import 'package:cyberlab_agent/services/reminder_service.dart';
import 'package:cyberlab_agent/services/secret_store.dart';
import 'package:cyberlab_agent/widgets/common.dart';

AppState _state() => AppState(
  secrets: MemorySecretStore(),
  reminders: MemoryReminderScheduler(),
);

Widget _wrap(Widget child, {AppState? app}) => ChangeNotifierProvider<AppState>(
  create: (_) => app ?? _state(),
  child: MaterialApp(home: child),
);

/// Petit téléphone (360 × 740 dp) et texte agrandi.
Future<void> _phone(WidgetTester tester, {double textScale = 2.0}) async {
  tester.view.physicalSize = const Size(360, 740);
  tester.view.devicePixelRatio = 1.0;
  tester.platformDispatcher.textScaleFactorTestValue = textScale;
  addTearDown(tester.view.reset);
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({
      'settings': jsonEncode({'onboardingDone': true}),
    });
    TerminalSession.reset();
  });

  group('Texte agrandi à 200 % sur petit écran : aucun débordement', () {
    testWidgets('onglets principaux', (tester) async {
      await _phone(tester);
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => _state(),
          child: const CyberLabApp(),
        ),
      );
      await tester.pumpAndSettle();
      for (final tab in ['Apprendre', 'Lab', 'CTF', 'Profil', 'Accueil']) {
        await tester.tap(find.text(tab).last);
        await tester.pumpAndSettle();
      }
    });

    testWidgets('Lab : terminal, SOC, labs, réseau', (tester) async {
      await _phone(tester);
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => _state(),
          child: const CyberLabApp(),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Lab').last);
      await tester.pumpAndSettle();
      for (final tab in ['SOC', 'Labs', 'Réseau', 'Terminal']) {
        await tester.tap(find.text(tab).first);
        await tester.pumpAndSettle();
      }
    });

    testWidgets('accueil du premier lancement', (tester) async {
      await _phone(tester);
      await tester.pumpWidget(_wrap(const OnboardingScreen()));
      await tester.pumpAndSettle();
      for (var i = 0; i < 2; i++) {
        await tester.tap(find.byKey(const ValueKey('onboarding-next')));
        await tester.pumpAndSettle();
      }
    });

    for (final (name, build) in <(String, Widget Function())>[
      ('paramètres', () => const SettingsScreen()),
      ('profil', () => const ProfileScreen()),
      (
        'cours',
        () => CourseView(
          course: CourseLibrary.all.firstWhere((c) => c.id == 'lin-chmod'),
        ),
      ),
      ('challenge', () => ChallengeView(challenge: ctfChallenges().first)),
    ]) {
      testWidgets(name, (tester) async {
        await _phone(tester);
        await tester.pumpWidget(_wrap(build()));
        await tester.pumpAndSettle();
      });
    }
  });

  group('Règles d\'accessibilité Flutter', () {
    for (final (name, screen) in <(String, Widget)>[
      ('paramètres', const SettingsScreen()),
      ('profil', const ProfileScreen()),
      ('premier lancement', const OnboardingScreen()),
      ('terminal', const TerminalScreen()),
    ]) {
      testWidgets('$name : zones tactiles ≥ 48 dp et boutons libellés', (
        tester,
      ) async {
        final handle = tester.ensureSemantics();
        await tester.pumpWidget(_wrap(screen));
        await tester.pumpAndSettle();
        await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
        await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
        handle.dispose();
      });
    }

    testWidgets('statistiques et compétences lues en clair', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                StatTile(icon: Icons.flag, value: '3', label: 'CTF'),
                SkillBar(label: 'Linux', level: 40),
                SectionTitle('Compétences'),
              ],
            ),
          ),
        ),
      );
      expect(find.bySemanticsLabel('CTF : 3'), findsOneWidget);
      expect(
        find.bySemanticsLabel('Linux : niveau 40 sur 100'),
        findsOneWidget,
      );
      expect(
        tester.getSemantics(find.text('Compétences')),
        matchesSemantics(label: 'Compétences', isHeader: true),
      );
      handle.dispose();
    });
  });
}
