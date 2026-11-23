import 'package:flutter/material.dart';
import '../services/terminal_engine.dart';

class TerminalScreen extends StatefulWidget {
  const TerminalScreen({super.key});

  @override
  State<TerminalScreen> createState() => _TerminalScreenState();
}

/// Session du terminal conservée pendant la vie de l'application : passer
/// à l'onglet SOC puis revenir ne réinitialise ni les fichiers ni l'écran.
class TerminalSession {
  TerminalSession._();
  static TerminalEngine engine = TerminalEngine();
  static final List<TermLine> lines = [];

  /// Repart de zéro (tests).
  static void reset() {
    engine = TerminalEngine();
    lines.clear();
  }
}

class _TerminalScreenState extends State<TerminalScreen> {
  TerminalEngine get _engine => TerminalSession.engine;

  @override
  void initState() {
    super.initState();
    if (TerminalSession.lines.isEmpty) {
      TerminalSession.lines.add(
        TermLine(
          text:
              'CyberLab Terminal Simulé : un vrai shell pédagogique sur un '
              'système de fichiers VIRTUEL. Rien n\'est exécuté sur votre '
              'appareil.\n'
              'Explorez ~/logs, ~/notes.txt, /etc/passwd ; essayez les tubes : '
              'grep "Failed" ~/logs/auth.log | wc -l\n'
              'Boucles, conditions et fonctions sont prises en charge : '
              'for i in 1 2 3; do echo \$i; done\n'
              'Command Guard : règle pédagogique qui refuse les commandes '
              'destructrices (rm -rf, dd of=…).\n'
              '« help » liste les commandes, « labreset » restaure les fichiers.',
          type: TermLineType.banner,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Terminal (simulé)'),
        actions: [
          TextButton.icon(
            onPressed: () =>
                setState(() => _engine.guardEnabled = !_engine.guardEnabled),
            icon: Icon(
              _engine.guardEnabled ? Icons.shield : Icons.shield_outlined,
              color: _engine.guardEnabled ? Colors.greenAccent : Colors.orange,
            ),
            label: Text(_engine.guardEnabled ? 'Guard ON' : 'Guard OFF'),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            color: Colors.amber.withValues(alpha: 0.15),
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
            child: const Row(
              children: [
                Icon(Icons.science, color: Colors.amber, size: 16),
                SizedBox(width: 6),
                Expanded(
                  // Une seule ligne : la règle du Command Guard est rappelée
                  // dans le message d'accueil du terminal.
                  child: Text(
                    'TERMINAL SIMULÉ : rien n\'est exécuté sur l\'appareil',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: TerminalConsole(
              engine: _engine,
              lines: TerminalSession.lines,
            ),
          ),
        ],
      ),
    );
  }
}

/// Console du terminal (sortie + saisie), réutilisée par le Lab et par les
/// exercices vérifiés des cours.
class TerminalConsole extends StatefulWidget {
  const TerminalConsole({
    super.key,
    required this.engine,
    required this.lines,
    this.onCommand,
  });

  final TerminalEngine engine;
  final List<TermLine> lines;

  /// Appelé après chaque commande (pour vérifier un exercice).
  final void Function(String command, CommandResult result)? onCommand;

  @override
  State<TerminalConsole> createState() => _TerminalConsoleState();
}

class _TerminalConsoleState extends State<TerminalConsole> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scroll = ScrollController();
  int _historyCursor = -1;

  TerminalEngine get _engine => widget.engine;
  List<TermLine> get _lines => widget.lines;

  @override
  void initState() {
    super.initState();
    _scrollToBottom();
  }

  @override
  void dispose() {
    _controller.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _recall() {
    final h = _engine.history;
    if (h.isEmpty) return;
    _historyCursor = _historyCursor <= 0 ? h.length - 1 : _historyCursor - 1;
    _controller.text = h[_historyCursor];
    _controller.selection = TextSelection.collapsed(
      offset: _controller.text.length,
    );
  }

  void _run(String input) {
    _historyCursor = -1;
    late CommandResult result;
    setState(() {
      _lines.add(
        TermLine(text: '${_engine.prompt} $input', type: TermLineType.input),
      );
      result = _engine.run(input);
      if (result.clear) {
        _lines.clear();
      } else if (result.output.isNotEmpty) {
        _lines.add(
          TermLine(
            text: result.output,
            type: result.blocked ? TermLineType.warning : TermLineType.output,
          ),
        );
      }
    });
    widget.onCommand?.call(input, result);
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Container(
            color: const Color(0xFF101218),
            child: ListView.builder(
              controller: _scroll,
              padding: const EdgeInsets.all(12),
              itemCount: _lines.length,
              itemBuilder: (context, i) {
                final line = _lines[i];
                final color = switch (line.type) {
                  TermLineType.input => Colors.lightBlueAccent,
                  TermLineType.warning => Colors.orange,
                  TermLineType.banner => Colors.grey,
                  TermLineType.output => Colors.greenAccent,
                };
                final text = SelectableText(
                  line.text,
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 13,
                    color: color,
                    height: 1.4,
                  ),
                );
                // Le résultat de la dernière commande est annoncé par le
                // lecteur d'écran.
                final isResult =
                    i == _lines.length - 1 && line.type != TermLineType.input;
                return isResult
                    ? Semantics(liveRegion: true, child: text)
                    : text;
              },
            ),
          ),
        ),
        Container(
          color: Colors.black87,
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              Flexible(
                // Invite courte (dossier courant) : l'invite complète figure
                // sur chaque ligne de commande affichée.
                child: Text(
                  '${_engine.shortPrompt} ',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    color: Colors.greenAccent,
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: TextField(
                  key: const ValueKey('terminal-input'),
                  controller: _controller,
                  autofocus: false,
                  // Les claviers Android corrigent « auth.log » en
                  // « Auth. log » : on désactive toute aide à la saisie.
                  autocorrect: false,
                  enableSuggestions: false,
                  textCapitalization: TextCapitalization.none,
                  smartQuotesType: SmartQuotesType.disabled,
                  smartDashesType: SmartDashesType.disabled,
                  keyboardType: TextInputType.visiblePassword,
                  textInputAction: TextInputAction.send,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    color: Colors.greenAccent,
                    fontSize: 14,
                  ),
                  decoration: const InputDecoration(
                    isDense: true,
                    // Zone tactile d'au moins 48 dp.
                    constraints: BoxConstraints(minHeight: 48),
                    contentPadding: EdgeInsets.symmetric(vertical: 14),
                    hintText: 'commande (ex. help, ls)',
                    hintStyle: TextStyle(color: Colors.grey),
                    border: InputBorder.none,
                    filled: false,
                  ),
                  onSubmitted: (v) {
                    if (v.trim().isNotEmpty) {
                      _run(v.trim());
                      _controller.clear();
                    }
                  },
                ),
              ),
              IconButton(
                tooltip: 'Commande précédente',
                onPressed: _recall,
                icon: const Icon(Icons.history, color: Colors.grey),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

enum TermLineType { input, output, warning, banner }

class TermLine {
  final String text;
  final TermLineType type;
  TermLine({required this.text, required this.type});
}
