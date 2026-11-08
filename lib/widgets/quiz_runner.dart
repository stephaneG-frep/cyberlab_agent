import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/course.dart';
import '../services/app_state.dart';
import '../widgets/common.dart';

/// Quiz réutilisable : suit les réponses, attribue les XP via la couche
/// métier (une fois par question réussie) et affiche les explications.
class QuizRunner extends StatefulWidget {
  final List<QuizQuestion> questions;

  /// Identifiant du cours : les questions sont identifiées par
  /// `<scopeId>/<id question>` (les ids « q1 »… se répètent entre cours).
  final String scopeId;

  /// Compétence créditée avec les XP.
  final String? skill;

  const QuizRunner({
    super.key,
    required this.questions,
    required this.scopeId,
    this.skill,
  });

  @override
  State<QuizRunner> createState() => _QuizRunnerState();
}

class _QuizRunnerState extends State<QuizRunner> {
  int _index = 0;
  String? _selected;
  final TextEditingController _free = TextEditingController();
  int _score = 0;
  bool _hintShown = false;
  bool _submitting = false;
  QuizOutcome? _outcome;

  bool get _answered => _outcome != null;

  @override
  void dispose() {
    _free.dispose();
    super.dispose();
  }

  bool _isChoice(QuizQuestion q) =>
      q.type == QuizType.qcm || q.type == QuizType.trueFalse;

  String _currentAnswer(QuizQuestion q) =>
      _isChoice(q) ? (_selected ?? '') : _free.text;

  bool _canSubmit(QuizQuestion q) =>
      !_answered && !_submitting && _currentAnswer(q).trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    if (widget.questions.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text('Aucune question disponible pour ce quiz.'),
        ),
      );
    }
    final q = widget.questions[_index];
    final total = widget.questions.length;
    // ListView : défilement garanti sur petit écran et clavier ouvert.
    return ListView(
      key: const ValueKey('quiz-list'),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: [
        Text(
          'Question ${_index + 1}/$total · ${q.xp} XP',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: (_index + 1) / total,
          minHeight: 6,
          color: CyberLabSeed.blue,
        ),
        const SizedBox(height: 12),
        if (q.codeSnippet != null) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(8),
            ),
            child: SelectableText(
              q.codeSnippet!,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
            ),
          ),
          const SizedBox(height: 8),
        ],
        Text(q.question, style: const TextStyle(fontSize: 16, height: 1.4)),
        const SizedBox(height: 16),
        ..._buildInput(q),
        if (!_answered && !_hintShown)
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () => setState(() => _hintShown = true),
              icon: const Icon(Icons.lightbulb_outline),
              label: const Text('Indice'),
            ),
          ),
        if (_hintShown && !_answered)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: _callout(
              'Indice : ${q.hintText}',
              Icons.tips_and_updates,
              Colors.amber,
            ),
          ),
        const SizedBox(height: 16),
        if (_answered)
          _explanationBox(q, context)
        else
          FilledButton.icon(
            key: const ValueKey('quiz-submit'),
            onPressed: _canSubmit(q) ? () => _submit(q) : null,
            icon: const Icon(Icons.check),
            label: const Text('Valider'),
          ),
      ],
    );
  }

  List<Widget> _buildInput(QuizQuestion q) {
    switch (q.type) {
      case QuizType.qcm:
        return [
          RadioGroup<String>(
            groupValue: _selected,
            onChanged: (value) {
              if (!_answered) setState(() => _selected = value);
            },
            child: Column(
              children: [
                for (var i = 0; i < (q.options?.length ?? 0); i++)
                  RadioListTile<String>(
                    title: Text(q.options![i]),
                    value: '$i',
                    dense: true,
                    enabled: !_answered,
                  ),
              ],
            ),
          ),
        ];
      case QuizType.trueFalse:
        return [
          RadioGroup<String>(
            groupValue: _selected,
            onChanged: (value) {
              if (!_answered) setState(() => _selected = value);
            },
            child: Column(
              children: [
                RadioListTile<String>(
                  title: const Text('Vrai'),
                  value: 'Vrai',
                  dense: true,
                  enabled: !_answered,
                ),
                RadioListTile<String>(
                  title: const Text('Faux'),
                  value: 'Faux',
                  dense: true,
                  enabled: !_answered,
                ),
              ],
            ),
          ),
        ];
      case QuizType.free:
      case QuizType.practical:
        return [
          TextField(
            key: const ValueKey('quiz-free-answer'),
            controller: _free,
            enabled: !_answered,
            decoration: InputDecoration(
              hintText: q.type == QuizType.practical
                  ? 'Votre commande...'
                  : 'Votre réponse...',
              border: const OutlineInputBorder(),
            ),
            // Actualise l'état du bouton Valider à chaque saisie.
            onChanged: (_) => setState(() {}),
            onSubmitted: (_) {
              if (_canSubmit(q)) _submit(q);
            },
          ),
        ];
    }
  }

  Future<void> _submit(QuizQuestion q) async {
    final answer = _currentAnswer(q);
    if (answer.trim().isEmpty) return; // jamais de réponse vide
    setState(() => _submitting = true);
    final outcome = await context.read<AppState>().answerQuiz(
      widget.scopeId,
      q,
      answer,
      skill: widget.skill,
    );
    if (!mounted) return;
    setState(() {
      _submitting = false;
      _outcome = outcome;
      if (outcome.correct) _score++;
    });
  }

  void _resetQuestionState() {
    _outcome = null;
    _selected = null;
    _free.clear(); // vide aussi le champ visible
    _hintShown = false;
    _submitting = false;
  }

  Widget _explanationBox(QuizQuestion q, BuildContext context) {
    final outcome = _outcome!;
    final correct = outcome.correct;
    final String subtitle;
    if (correct) {
      subtitle = outcome.xpGained > 0
          ? '+${outcome.xpGained} XP gagnés'
          : 'Question déjà réussie auparavant : pas de nouveaux XP.';
    } else {
      subtitle =
          'La bonne réponse : ${q.displayCorrect}\n'
          'Vous pourrez encore gagner ${q.xp} XP en la réussissant plus tard.';
    }
    final last = _index + 1 >= widget.questions.length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          color: correct
              ? Colors.green.withValues(alpha: 0.2)
              : Colors.red.withValues(alpha: 0.2),
          child: ListTile(
            leading: Icon(
              correct ? Icons.check_circle : Icons.cancel,
              color: correct ? Colors.greenAccent : Colors.redAccent,
            ),
            title: Text(correct ? 'Bonne réponse !' : 'Réponse incorrecte'),
            subtitle: Text(subtitle),
          ),
        ),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Explication',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                Text(q.explanation),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        FilledButton.icon(
          key: const ValueKey('quiz-next'),
          onPressed: () {
            if (!last) {
              setState(() {
                _index++;
                _resetQuestionState();
              });
            } else {
              _finish();
            }
          },
          icon: Icon(last ? Icons.flag : Icons.navigate_next),
          label: Text(last ? 'Terminer' : 'Question suivante'),
        ),
      ],
    );
  }

  void _restart() {
    setState(() {
      _index = 0;
      _score = 0;
      _resetQuestionState();
    });
  }

  void _finish() {
    final total = widget.questions.length;
    final pct = ((_score / total) * 100).round();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Quiz terminé'),
        content: Text(
          'Score : $_score/$total\n\n$pct% de réussite.\n\n'
          'Les XP ne sont attribués qu\'une fois par question réussie ; '
          'vous pouvez recommencer pour vous entraîner.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _restart();
            },
            child: const Text('Recommencer'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }
}

Widget _callout(String text, IconData icon, Color color) {
  return Container(
    margin: const EdgeInsets.symmetric(vertical: 6),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.10),
      borderRadius: BorderRadius.circular(8),
      border: Border(left: BorderSide(color: color, width: 4)),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Expanded(child: Text(text)),
      ],
    ),
  );
}
