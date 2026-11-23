import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/packet_capture.dart';
import '../data/scenarios.dart';
import '../models/user_state.dart';
import '../services/app_state.dart';
import '../services/display_filter.dart';
import '../services/terminal_engine.dart';
import 'terminal_screen.dart';
import 'wireshark_screen.dart';

/// Liste des enquêtes guidées (onglet « Enquêtes » du Lab).
class ScenariosView extends StatelessWidget {
  const ScenariosView({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Enquêtes guidées',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        const Text(
          'Chaque enquête enchaîne terminal, capture réseau et décisions sur '
          'les données simulées du Lab. Jusqu\'à ${Scenario.maxXp} XP : une '
          'mauvaise décision en coûte ${Scenario.errorCost} (minimum '
          '${Scenario.minXp}).',
        ),
        const SizedBox(height: 12),
        for (final s in scenarios) _card(context, app, s),
      ],
    );
  }

  Widget _card(BuildContext context, AppState app, Scenario s) {
    final done = app.isRewarded(RewardKeys.scenario(s.id));
    final step = min(app.scenarioProgress(s.id).step, s.steps.length);
    final status = done
        ? 'Terminée'
        : step == 0
        ? 'À commencer'
        : 'Étape ${min(step + 1, s.steps.length)} sur ${s.steps.length}';
    return Card(
      child: ListTile(
        key: ValueKey('scenario-${s.id}'),
        leading: Icon(
          done ? Icons.check_circle : Icons.policy_outlined,
          color: done ? Colors.green : Colors.amber,
          semanticLabel: done ? 'terminée' : null,
        ),
        title: Text(s.title),
        subtitle: Text('${s.difficulty} · ${s.steps.length} étapes · $status'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => ScenarioScreen(scenario: s))),
      ),
    );
  }
}

/// Déroulement d'une enquête, étape par étape.
class ScenarioScreen extends StatefulWidget {
  const ScenarioScreen({super.key, required this.scenario, this.random});

  final Scenario scenario;

  /// Mélange des options (injectable pour les tests).
  final Random? random;

  @override
  State<ScenarioScreen> createState() => _ScenarioScreenState();
}

class _ScenarioScreenState extends State<ScenarioScreen> {
  late final Random _random = widget.random ?? Random();
  late int _step;
  bool _stepDone = false;
  bool _hint = false;
  int? _gained;

  // Terminal
  TerminalEngine _engine = TerminalEngine();
  final List<TermLine> _lines = [];
  List<bool> _checks = [];

  // Filtre, réponse, décision
  final TextEditingController _input = TextEditingController();
  List<Packet> _shown = LabCapture.packets;
  String? _error;
  String? _feedback;
  List<int> _order = [];
  final Set<int> _tried = {};

  Scenario get _s => widget.scenario;
  bool get _finished => _step >= _s.steps.length;

  @override
  void initState() {
    super.initState();
    _step = min(
      context.read<AppState>().scenarioProgress(_s.id).step,
      _s.steps.length,
    );
    _setupStep();
    // Dernière étape réussie mais XP pas encore attribués (app fermée).
    if (_finished) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _reward());
    }
  }

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  void _setupStep() {
    _stepDone = false;
    _hint = false;
    _feedback = null;
    _error = null;
    _tried.clear();
    _input.clear();
    _shown = LabCapture.packets;
    _engine = TerminalEngine();
    _lines.clear();
    if (_finished) return;
    switch (_s.steps[_step]) {
      case TerminalStep(:final checks):
        _checks = List.filled(checks.length, false);
      case ChoiceStep(:final options):
        _order = List.generate(options.length, (i) => i)..shuffle(_random);
      case FilterStep() || AnswerStep():
        break;
    }
  }

  Future<void> _succeed() async {
    if (_stepDone) return;
    setState(() {
      _stepDone = true;
      _feedback = null;
    });
    await context.read<AppState>().completeScenarioStep(_s.id, _step);
  }

  Future<void> _next() async {
    setState(() {
      _step++;
      _setupStep();
    });
    if (_finished) await _reward();
  }

  Future<void> _reward() async {
    if (!mounted || _gained != null) return;
    final app = context.read<AppState>();
    final gained = await app.solveScenario(
      _s.id,
      Scenario.xpFor(app.scenarioProgress(_s.id).errors),
    );
    if (mounted) setState(() => _gained = gained);
  }

  Future<void> _restart() async {
    await context.read<AppState>().restartScenario(_s.id);
    if (!mounted) return;
    setState(() {
      _step = 0;
      _gained = null;
      _setupStep();
    });
  }

  void _onCommand(TerminalStep step, String command, CommandResult result) {
    if (_stepDone) return;
    setState(() {
      for (var i = 0; i < step.checks.length; i++) {
        final c = step.checks[i];
        final ok = c.test(_engine, command, result.output);
        _checks[i] = c.latched ? (_checks[i] || ok) : ok;
      }
    });
    if (_checks.every((c) => c)) _succeed();
  }

  void _applyFilter(FilterStep step, String text) {
    setState(() {
      _feedback = null;
      try {
        _shown = DisplayFilter.parse(text).apply(LabCapture.packets);
        _error = null;
      } on FilterError catch (e) {
        _error = e.message;
      }
    });
  }

  void _checkFilter(FilterStep step) {
    final got = _shown.map((p) => p.no).toSet();
    final want = DisplayFilter.parse(
      step.solution,
    ).apply(LabCapture.packets).map((p) => p.no).toSet();
    if (got.length == want.length && got.containsAll(want)) {
      _succeed();
    } else {
      setState(
        () => _feedback =
            'Pas encore : ${got.length} paquet(s) affiché(s), '
            '${want.length} attendu(s).',
      );
    }
  }

  void _checkAnswer(AnswerStep step) {
    if (_input.text.trim().isEmpty) return;
    if (step.isCorrect(_input.text)) {
      _succeed();
    } else {
      setState(() => _feedback = 'Pas encore. Vérifiez dans les données.');
    }
  }

  Future<void> _choose(ChoiceStep step, int option) async {
    if (_stepDone || _tried.contains(option)) return;
    if (option == step.correct) {
      await _succeed();
      return;
    }
    setState(() {
      _tried.add(option);
      _feedback = step.options[option].feedback;
    });
    final app = context.read<AppState>();
    // Une fois les XP obtenus, rejouer est un entraînement sans pénalité.
    if (!app.isRewarded(RewardKeys.scenario(_s.id))) {
      await app.scenarioError(_s.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_s.title),
        actions: [
          IconButton(
            tooltip: 'Recommencer l\'enquête',
            onPressed: _step == 0 && !_stepDone ? null : _restart,
            icon: const Icon(Icons.restart_alt),
          ),
        ],
      ),
      body: _finished ? _end(context) : _body(context, _s.steps[_step]),
    );
  }

  Widget _body(BuildContext context, ScenarioStep step) {
    if (step is TerminalStep) {
      return Column(
        children: [
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ..._header(context, step),
                  for (var i = 0; i < step.checks.length; i++)
                    Row(
                      children: [
                        Icon(
                          _checks[i]
                              ? Icons.check_circle
                              : Icons.radio_button_unchecked,
                          size: 18,
                          color: _checks[i] ? Colors.green : Colors.grey,
                          semanticLabel: _checks[i] ? 'fait' : 'à faire',
                        ),
                        const SizedBox(width: 6),
                        Expanded(child: Text(step.checks[i].label)),
                      ],
                    ),
                  ..._footer(step),
                ],
              ),
            ),
          ),
          Expanded(
            child: TerminalConsole(
              key: ValueKey('scenario-console-$_step'),
              engine: _engine,
              lines: _lines,
              onCommand: (c, r) => _onCommand(step, c, r),
            ),
          ),
        ],
      );
    }
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      children: [
        ..._header(context, step),
        ...switch (step) {
          FilterStep() => _filterInput(step),
          AnswerStep() => _answerInput(step),
          ChoiceStep() => _choiceInput(step),
          TerminalStep() => const <Widget>[],
        },
        ..._footer(step),
        if (step is FilterStep) ...[
          const SizedBox(height: 8),
          Text(
            '${_shown.length} / ${LabCapture.packets.length} paquets affichés '
            '· touchez un paquet pour le détail',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          for (final p in _shown) PacketRow(packet: p),
        ],
      ],
    );
  }

  List<Widget> _header(BuildContext context, ScenarioStep step) => [
    LinearProgressIndicator(
      semanticsLabel: 'Étape ${_step + 1} sur ${_s.steps.length}',
      value: _step / _s.steps.length,
      minHeight: 4,
    ),
    const SizedBox(height: 8),
    if (_step == 0) ...[
      Text(_s.context, style: const TextStyle(fontStyle: FontStyle.italic)),
      const SizedBox(height: 8),
    ],
    Text(
      'Étape ${_step + 1}/${_s.steps.length} · ${step.title}',
      key: const ValueKey('scenario-step'),
      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
    ),
    const SizedBox(height: 4),
    Text(step.instruction),
    const SizedBox(height: 8),
  ];

  List<Widget> _filterInput(FilterStep step) => [
    TextField(
      key: const ValueKey('scenario-input'),
      controller: _input,
      enabled: !_stepDone,
      onChanged: (t) => _applyFilter(step, t),
      onSubmitted: (_) => _error == null ? _checkFilter(step) : null,
      autocorrect: false,
      enableSuggestions: false,
      keyboardType: TextInputType.visiblePassword,
      style: const TextStyle(fontFamily: 'monospace'),
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.filter_alt),
        hintText: 'Filtre d\'affichage…',
        errorText: _error,
        errorMaxLines: 3,
      ),
    ),
    const SizedBox(height: 8),
    if (!_stepDone)
      FilledButton(
        key: const ValueKey('scenario-check'),
        onPressed: _error == null ? () => _checkFilter(step) : null,
        child: const Text('Vérifier'),
      ),
  ];

  List<Widget> _answerInput(AnswerStep step) => [
    TextField(
      key: const ValueKey('scenario-input'),
      controller: _input,
      enabled: !_stepDone,
      onChanged: (_) => setState(() => _feedback = null),
      onSubmitted: (_) => _checkAnswer(step),
      autocorrect: false,
      enableSuggestions: false,
      decoration: const InputDecoration(labelText: 'Votre réponse'),
    ),
    const SizedBox(height: 8),
    if (!_stepDone)
      FilledButton(
        key: const ValueKey('scenario-check'),
        onPressed: _input.text.trim().isEmpty ? null : () => _checkAnswer(step),
        child: const Text('Vérifier'),
      ),
  ];

  List<Widget> _choiceInput(ChoiceStep step) => [
    for (final i in _order)
      Card(
        child: ListTile(
          key: ValueKey('choice-$i'),
          enabled: !_stepDone && !_tried.contains(i),
          leading: Icon(
            _stepDone && i == step.correct
                ? Icons.check_circle
                : _tried.contains(i)
                ? Icons.cancel
                : Icons.radio_button_unchecked,
            color: _stepDone && i == step.correct
                ? Colors.green
                : _tried.contains(i)
                ? Colors.orange
                : null,
            semanticLabel: _stepDone && i == step.correct
                ? 'bonne décision'
                : _tried.contains(i)
                ? 'déjà essayée'
                : null,
          ),
          title: Text(step.options[i].text),
          onTap: () => _choose(step, i),
        ),
      ),
  ];

  List<Widget> _footer(ScenarioStep step) => [
    if (_feedback != null)
      Semantics(
        liveRegion: true,
        child: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(
            _feedback!,
            key: const ValueKey('scenario-feedback'),
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ),
    if (_stepDone) ...[
      const SizedBox(height: 8),
      Semantics(
        liveRegion: true,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.green.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text('Étape réussie. ${step.explanation}'),
        ),
      ),
      const SizedBox(height: 8),
      FilledButton(
        key: const ValueKey('scenario-next'),
        onPressed: _next,
        child: Text(
          _step + 1 == _s.steps.length ? 'Voir le bilan' : 'Étape suivante',
        ),
      ),
    ] else if (_hint)
      Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Text('Indice : ${step.hint}'),
      )
    else
      TextButton.icon(
        onPressed: () => setState(() => _hint = true),
        icon: const Icon(Icons.lightbulb_outline),
        label: const Text('Indice'),
      ),
  ];

  Widget _end(BuildContext context) {
    final app = context.watch<AppState>();
    final errors = app.scenarioProgress(_s.id).errors;
    final gained = _gained;
    return ListView(
      key: const ValueKey('scenario-end'),
      padding: const EdgeInsets.all(16),
      children: [
        const Icon(Icons.emoji_events, size: 56, color: Colors.amber),
        const SizedBox(height: 8),
        Text(
          gained == null
              ? 'Enquête terminée'
              : gained > 0
              ? 'Enquête résolue ! (+$gained XP)'
              : 'Enquête résolue (XP déjà obtenus)',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          errors == 0
              ? 'Aucune mauvaise décision.'
              : 'Mauvaises décisions : $errors.',
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        const Text('Bilan', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(_s.debrief),
        const SizedBox(height: 16),
        OutlinedButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Retour aux enquêtes'),
        ),
      ],
    );
  }
}
