import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/terminal_exercises.dart';
import '../models/user_state.dart';
import '../services/app_state.dart';
import '../services/terminal_engine.dart';
import 'terminal_screen.dart';

/// Exercice d'un cours vérifié automatiquement : un terminal neuf (fichiers
/// d'origine) et des critères qui se cochent au fil des commandes.
class TerminalPracticeScreen extends StatefulWidget {
  const TerminalPracticeScreen({super.key, required this.exercise, this.skill});

  final TerminalExercise exercise;

  /// Compétence créditée avec les XP.
  final String? skill;

  @override
  State<TerminalPracticeScreen> createState() => _TerminalPracticeScreenState();
}

class _TerminalPracticeScreenState extends State<TerminalPracticeScreen> {
  late TerminalEngine _engine;
  final List<TermLine> _lines = [];
  late List<bool> _done;
  bool _hint = false;
  bool _success = false;
  int _gained = 0;
  int _session = 0;

  TerminalExercise get _ex => widget.exercise;

  @override
  void initState() {
    super.initState();
    _restart();
  }

  void _restart() {
    _engine = TerminalEngine();
    _lines
      ..clear()
      ..add(
        TermLine(
          text:
              'Terminal neuf pour l\'exercice : fichiers d\'origine, dossier '
              'personnel ~. Les critères se cochent au fil de vos commandes.',
          type: TermLineType.banner,
        ),
      );
    _done = List.filled(_ex.checks.length, false);
    _success = false;
    _gained = 0;
    _session++;
  }

  Future<void> _onCommand(String command, CommandResult result) async {
    for (var i = 0; i < _ex.checks.length; i++) {
      final c = _ex.checks[i];
      final ok = c.test(_engine, command, result.output);
      _done[i] = c.latched ? (_done[i] || ok) : ok;
    }
    if (!_success && _done.every((d) => d)) {
      final gained = await context.read<AppState>().solveTerminalExercise(
        _ex.courseId,
        _ex.xp,
        skill: widget.skill,
      );
      if (!mounted) return;
      setState(() {
        _success = true;
        _gained = gained;
      });
      return;
    }
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final alreadyRewarded = app.isRewarded(RewardKeys.terminal(_ex.courseId));
    return Scaffold(
      appBar: AppBar(
        title: Text(_ex.title),
        actions: [
          IconButton(
            tooltip: 'Recommencer avec des fichiers neufs',
            onPressed: () => setState(_restart),
            icon: const Icon(Icons.restart_alt),
          ),
        ],
      ),
      body: Column(
        children: [
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_ex.instruction),
                  const SizedBox(height: 6),
                  for (var i = 0; i < _ex.checks.length; i++)
                    Row(
                      key: ValueKey('check-$i'),
                      children: [
                        Icon(
                          _done[i]
                              ? Icons.check_circle
                              : Icons.radio_button_unchecked,
                          size: 18,
                          color: _done[i] ? Colors.greenAccent : Colors.grey,
                          semanticLabel: _done[i] ? 'fait' : 'à faire',
                        ),
                        const SizedBox(width: 6),
                        Expanded(child: Text(_ex.checks[i].label)),
                      ],
                    ),
                  if (_success)
                    Semantics(
                      liveRegion: true,
                      child: Container(
                        key: const ValueKey('practice-success'),
                        width: double.infinity,
                        margin: const EdgeInsets.only(top: 8),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _gained > 0
                                  ? 'Exercice réussi ! (+$_gained XP)'
                                  : 'Exercice réussi (XP déjà obtenus).',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text('Une solution possible :'),
                            SelectableText(
                              _ex.solution,
                              style: const TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else ...[
                    if (alreadyRewarded)
                      const Padding(
                        padding: EdgeInsets.only(top: 4),
                        child: Text(
                          'Déjà réussi : vous pouvez le refaire pour vous entraîner.',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ),
                    if (_hint)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          'Indice : ${_ex.hint}',
                          style: const TextStyle(color: Colors.amber),
                        ),
                      )
                    else
                      TextButton.icon(
                        onPressed: () => setState(() => _hint = true),
                        icon: const Icon(Icons.lightbulb_outline, size: 18),
                        label: const Text('Indice'),
                      ),
                  ],
                ],
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: TerminalConsole(
              key: ValueKey('practice-console-$_session'),
              engine: _engine,
              lines: _lines,
              onCommand: _onCommand,
            ),
          ),
        ],
      ),
    );
  }
}
