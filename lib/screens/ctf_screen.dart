import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/ctf_library.dart';
import '../models/ctf_challenge.dart';
import '../services/app_state.dart';
import '../widgets/common.dart';

class CtfScreen extends StatefulWidget {
  const CtfScreen({super.key});

  @override
  State<CtfScreen> createState() => _CtfScreenState();
}

class _CtfScreenState extends State<CtfScreen> {
  String _category = 'Tous';

  static const _cats = [
    'Tous',
    'Linux',
    'Web',
    'Réseau',
    'Crypto',
    'Logs',
    'OSINT',
  ];

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final all = ctfChallenges();
    final solved = app.user.solvedChallenges;
    final shown = _category == 'Tous'
        ? all
        : all.where((c) => c.category == _category).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Challenges CTF')),
      body: Column(
        children: [
          SizedBox(
            height: 52,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              children: [
                for (final c in _cats)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(c),
                      selected: _category == c,
                      onSelected: (_) => setState(() => _category = c),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: shown.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, i) {
                final c = shown[i];
                final isSolved = solved.contains(c.id);
                return Card(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ChallengeView(challenge: c),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          Icon(
                            isSolved ? Icons.emoji_events : Icons.flag_outlined,
                            color: isSolved ? Colors.amber : CyberLabSeed.blue,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  c.title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${c.category} · ${c.difficulty} · ${c.xp} XP',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                          if (isSolved)
                            const Icon(Icons.check_circle, color: Colors.green),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ChallengeView extends StatefulWidget {
  final CtfChallenge challenge;
  const ChallengeView({super.key, required this.challenge});

  @override
  State<ChallengeView> createState() => _ChallengeViewState();
}

class _ChallengeViewState extends State<ChallengeView> {
  int _hintLevel = 0;
  bool _revealed = false;
  bool _solved = false;
  final TextEditingController _controller = TextEditingController();

  CtfChallenge get c => widget.challenge;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _check() {
    final app = context.read<AppState>();
    final ok =
        _controller.text.trim().toLowerCase() == c.answer.trim().toLowerCase();
    setState(() {
      _solved = ok;
    });
    if (ok) {
      if (!app.user.solvedChallenges.contains(c.id)) {
        app.solveChallenge(c.id, c.xp);
      }
      setState(() {
        _revealed = true;
        _hintLevel = c.hints.length;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(c.title)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Wrap(
            spacing: 8,
            children: [
              Chip(label: Text(c.category)),
              Chip(label: Text(c.difficulty)),
              Chip(label: Text('${c.xp} XP')),
            ],
          ),
          const SizedBox(height: 12),
          const Text('Objectif', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(c.objective),
          const SizedBox(height: 12),
          const Text(
            'Environnement',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(c.environment),
          const SizedBox(height: 12),
          Card(
            color: Colors.black54,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: SelectableText(
                c.puzzle,
                style: const TextStyle(fontFamily: 'monospace'),
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            enabled: !_revealed,
            decoration: const InputDecoration(
              hintText: 'Votre commande/réponse...',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          if (!_revealed)
            FilledButton.icon(
              onPressed: _controller.text.trim().isEmpty ? null : _check,
              icon: const Icon(Icons.check),
              label: const Text('Valider'),
            ),
          const SizedBox(height: 12),
          if (!_revealed) _hintsBuilder(),
          if (_revealed) _solution(context),
        ],
      ),
    );
  }

  Widget _hintsBuilder() {
    final available = c.hints.length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.lightbulb_outline, color: Colors.amber),
            const SizedBox(width: 6),
            const Text(
              'Indices',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 8),
        for (var i = 0; i < _hintLevel && i < available; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text('Indice ${i + 1} : ${c.hints[i]}'),
          ),
        const SizedBox(height: 8),
        if (_hintLevel < available)
          TextButton.icon(
            onPressed: () => setState(() => _hintLevel++),
            icon: const Icon(Icons.add),
            label: const Text('Révéler un indice'),
          )
        else if (_hintLevel < c.hints.length + 1)
          TextButton.icon(
            onPressed: () => setState(() {
              _hintLevel = c.hints.length;
              _revealed = true;
            }),
            icon: const Icon(Icons.visibility),
            label: const Text('Voir la solution'),
          ),
      ],
    );
  }

  Widget _solution(BuildContext context) {
    final done = _solved;
    return Card(
      color: done
          ? Colors.green.withValues(alpha: 0.15)
          : Colors.orange.withValues(alpha: 0.12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              done ? 'Bravo, challenge réussi ! (+${c.xp} XP)' : 'Solution',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            const SizedBox(height: 8),
            Text('Réponse : ${c.answer}'),
            const SizedBox(height: 8),
            Text(c.explanation),
          ],
        ),
      ),
    );
  }
}
