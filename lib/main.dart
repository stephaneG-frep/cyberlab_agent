import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/app_state.dart';
import 'screens/root_shell.dart';
import 'theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppState(),
      child: const CyberLabApp(),
    ),
  );
}

class CyberLabApp extends StatelessWidget {
  const CyberLabApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, app, _) {
        final themeMode = app.settings['darkMode'] == false
            ? ThemeMode.light
            : ThemeMode.dark;
        return MaterialApp(
          title: 'CyberLab Agent',
          debugShowCheckedModeBanner: false,
          theme: CyberLabTheme.light(),
          darkTheme: CyberLabTheme.dark(),
          themeMode: themeMode,
          home: const RootShell(),
        );
      },
    );
  }
}
