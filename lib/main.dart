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
        return LearningTimeTracker(
          child: MaterialApp(
            title: 'CyberLab Agent',
            debugShowCheckedModeBanner: false,
            theme: CyberLabTheme.light(),
            darkTheme: CyberLabTheme.dark(),
            themeMode: app.darkMode ? ThemeMode.dark : ThemeMode.light,
            home: const RootShell(),
          ),
        );
      },
    );
  }
}

/// Compte le temps d'apprentissage uniquement quand l'application est au
/// premier plan (le temps en arrière-plan ou écran verrouillé est exclu).
class LearningTimeTracker extends StatefulWidget {
  final Widget child;
  const LearningTimeTracker({super.key, required this.child});

  @override
  State<LearningTimeTracker> createState() => _LearningTimeTrackerState();
}

class _LearningTimeTrackerState extends State<LearningTimeTracker>
    with WidgetsBindingObserver {
  late final AppState _app;

  @override
  void initState() {
    super.initState();
    _app = context.read<AppState>();
    WidgetsBinding.instance.addObserver(this);
    final state = WidgetsBinding.instance.lifecycleState;
    if (state == null || state == AppLifecycleState.resumed) {
      _app.onAppResumed();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _app.onAppResumed();
    } else {
      _app.onAppPaused();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
