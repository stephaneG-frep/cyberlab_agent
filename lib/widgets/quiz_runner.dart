import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/course.dart';
import '../services/app_state.dart';
import '../widgets/common.dart';

/// A reusable quiz runner that tracks answers, awards XP and shows explanations.
class QuizRunner extends StatefulWidget {
  final List<QuizQuestion> questions;
  final int xpPerCorrect;

  const QuizRunner({
    super.key,
    required this.questions,
    this.xpPerCorrect = 15,
  });

  @override
  State<QuizRunner> createState() => _QuizRunnerState();
}

class _QuizRunnerState extends State<QuizRunner> {
  int _index = 0;
  bool _answered = false;
  String? _selected;
  String _freeAnswer = '';
  int _score = 0;
  bool _hintShown = false;

  QuizQuestion get _q => widget.questions[_index];

  @override
  Widget build(BuildContext context) {
    final q = _q;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Question ${_index + 1}/${widget.questions.length}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        LinearProgressIndicator(
          value: (_index + 1) / widget.questions.length,
          minHeight: 6,
          color: CyberLabSeed.blue,
        ),
        const SizedBox(height: 12),
        if (q.codeSnippet != null)
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
              'Indice : la réponse est "${_reviewHint(q)}" (répondez et validez pour voir l\'explication)',
              Icons.tips_and_updates,
              Colors.amber,
            ),
          ),
        const Spacer(),
        const SizedBox(height: 16),
        if (_answered)
          _explanationBox(q, context)
        else
          FilledButton.icon(
            onPressed: _canSubmit ? () => _submit(q) : null,
            icon: const Icon(Icons.check),
            label: const Text('Valider'),
          ),
      ],
    );
  }

  String _reviewHint(QuizQuestion q) {
    if (q.type == QuizType.qcm && q.options != null) {
      final idx = int.tryParse(q.correct) ?? 0;
      if (idx < q.options!.length) {
        return q.options![idx];
      }
    }
    return q.correct;
  }

  bool get _canSubmit {
    return !_answered &&
        (_selected != null ||
            (_q.type != QuizType.qcm && _freeAnswer.trim().isNotEmpty));
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
      default:
        return [
          TextField(
            enabled: !_answered,
            decoration: const InputDecoration(hintText: 'Votre réponse...'),
            onChanged: (v) => _freeAnswer = v,
          ),
        ];
    }
  }

  void _submit(QuizQuestion q) {
    final answer = q.type == QuizType.qcm || q.type == QuizType.trueFalse
        ? _selected ?? ''
        : _freeAnswer;
    final correct = q.isCorrect(answer);
    if (correct) _score++;
    final app = context.read<AppState>();
    app.recordQuizResult(q.id, correct);
    if (correct) app.addXp(widget.xpPerCorrect);
    setState(() {
      _answered = true;
      _selected = correct
          ? (q.type == QuizType.trueFalse ? answer : answer)
          : _selected;
    });
  }

  Widget _explanationBox(QuizQuestion q, BuildContext context) {
    final correct = _isCorrect;
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
            subtitle: Text(
              correct ? '${q.xp} XP gagnés' : 'La bonne réponse : ${q.correct}',
            ),
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
          onPressed: () {
            if (_index + 1 < widget.questions.length) {
              setState(() {
                _index++;
                _answered = false;
                _selected = null;
                _freeAnswer = '';
                _hintShown = false;
              });
            } else {
              _finish();
            }
          },
          icon: Icon(
            _index + 1 < widget.questions.length
                ? Icons.navigate_next
                : Icons.flag,
          ),
          label: Text(
            _index + 1 < widget.questions.length
                ? 'Question suivante'
                : 'Terminer',
          ),
        ),
      ],
    );
  }

  bool get _isCorrect {
    final answer = _q.type == QuizType.qcm || _q.type == QuizType.trueFalse
        ? _selected ?? ''
        : _freeAnswer;
    return _q.isCorrect(answer);
  }

  void _finish() {
    final pct = ((_score / widget.questions.length) * 100).round();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Quiz terminé'),
        content: Text(
          'Score : $_score/${widget.questions.length}\n\n'
          '$pct% de réussite.',
        ),
        actions: [
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
