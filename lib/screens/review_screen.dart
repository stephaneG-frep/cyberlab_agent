import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/course.dart';
import '../services/app_state.dart';
import '../widgets/common.dart';
import '../widgets/quiz_runner.dart';

/// Révision : les questions ratées (une réussite rapporte encore leurs XP),
/// ou un entraînement aléatoire sur les cours terminés.
class ReviewScreen extends StatefulWidget {
  const ReviewScreen({super.key, this.random});

  /// Générateur injectable (tests).
  final Random? random;

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  static const sessionSize = 10;
  late final Random _random = widget.random ?? Random();

  /// Session en cours (liste figée au démarrage), sinon null.
  List<(Course, QuizQuestion)>? _session;
  String _title = '';
  int _run = 0;

  void _start(String title, List<(Course, QuizQuestion)> pool) {
    final picked = List.of(pool)..shuffle(_random);
    setState(() {
      _title = title;
      _session = picked.take(sessionSize).toList();
      _run++;
    });
  }

  @override
  Widget build(BuildContext context) {
    final session = _session;
    return Scaffold(
      appBar: AppBar(
        title: Text(session == null ? 'Révision' : _title),
        leading: session == null
            ? null
            : IconButton(
                tooltip: 'Retour au choix',
                icon: const Icon(Icons.arrow_back),
                onPressed: () => setState(() => _session = null),
              ),
      ),
      body: session == null ? _menu(context) : _quiz(session),
    );
  }

  Widget _quiz(List<(Course, QuizQuestion)> session) => QuizRunner(
    key: ValueKey('review-$_run'),
    questions: [for (final (_, q) in session) q],
    scopeId: 'revision',
    origins: [
      for (final (c, _) in session)
        (scopeId: c.id, title: c.title, skill: categoryLabel(c.category)),
    ],
  );

  Widget _menu(BuildContext context) {
    final app = context.watch<AppState>();
    final mistakes = app.mistakes;
    final pool = app.practicePool;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Revenir sur ce qui n\'est pas encore acquis est le moyen le plus '
          'efficace de mémoriser.',
        ),
        const SizedBox(height: 16),
        Card(
          child: ListTile(
            key: const ValueKey('review-mistakes'),
            leading: const Icon(Icons.replay, color: Colors.orange),
            title: Text('Mes erreurs (${mistakes.length})'),
            subtitle: Text(
              mistakes.isEmpty
                  ? 'Aucune question ratée en attente : bravo !'
                  : 'Questions ratées pas encore réussies. Les réussir '
                        'rapporte toujours leurs XP. Jusqu\'à $sessionSize '
                        'par session.',
            ),
            enabled: mistakes.isNotEmpty,
            onTap: mistakes.isEmpty
                ? null
                : () => _start('Mes erreurs', mistakes),
          ),
        ),
        Card(
          child: ListTile(
            key: const ValueKey('review-practice'),
            leading: const Icon(Icons.shuffle, color: Colors.blue),
            title: const Text('Entraînement aléatoire'),
            subtitle: Text(
              pool.isEmpty
                  ? 'Terminez au moins un cours pour vous entraîner sur ses '
                        'questions.'
                  : '${min(sessionSize, pool.length)} questions tirées des '
                        '${app.user.completedCourses.length} '
                        'cours terminés.',
            ),
            enabled: pool.isNotEmpty,
            onTap: pool.isEmpty ? null : () => _start('Entraînement', pool),
          ),
        ),
      ],
    );
  }
}
