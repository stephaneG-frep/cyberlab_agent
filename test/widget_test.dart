import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cyberlab_agent/main.dart';
import 'package:cyberlab_agent/screens/ctf_screen.dart';
import 'package:cyberlab_agent/screens/notes_screen.dart';
import 'package:cyberlab_agent/services/app_state.dart';

Widget _app() => ChangeNotifierProvider(
      create: (_) => AppState(),
      child: const CyberLabApp(),
    );

Widget _wrapped(Widget child) => ChangeNotifierProvider(
      create: (_) => AppState(),
      child: MaterialApp(home: child),
    );

void main() {
  testWidgets('l\'app se construit et affiche la navigation', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();

    expect(find.text('Accueil'), findsWidgets);
    expect(find.text('Apprendre'), findsWidgets);
    expect(find.text('Lab'), findsWidgets);
    expect(find.text('CTF'), findsWidgets);
    expect(find.text('Profil'), findsWidgets);
  });

  testWidgets('l\'écran CTF se construit', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(_wrapped(const CtfScreen()));
    await tester.pumpAndSettle();
    expect(find.text('Challenges CTF'), findsOneWidget);
  });

  testWidgets('l\'écran Notes affiche l\'état vide', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(_wrapped(const NotesScreen()));
    await tester.pumpAndSettle();
    expect(find.text('Cyber Notes'), findsOneWidget);
  });
}
