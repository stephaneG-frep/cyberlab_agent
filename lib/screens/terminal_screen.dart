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
  static int _historyCursor = -1;

  /// Repart de zéro (tests).
  static void reset() {
    engine = TerminalEngine();
    lines.clear();
    _historyCursor = -1;
  }
}

class _TerminalScreenState extends State<TerminalScreen> {
  TerminalEngine get _engine => TerminalSession.engine;
  List<TermLine> get _lines => TerminalSession.lines;
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    if (_lines.isEmpty) _banner();
    _scrollToBottom();
  }

  void _banner() {
    _lines.add(
      TermLine(
        text:
            'CyberLab Terminal Simulé : un vrai shell pédagogique sur un système '
            'de fichiers VIRTUEL. Rien n\'est exécuté sur votre appareil.\n'
            'Explorez ~/logs, ~/notes.txt, /etc/passwd ; essayez les tubes : '
            'grep "Failed" ~/logs/auth.log | wc -l\n'
            'Command Guard : règle pédagogique qui refuse les commandes '
            'destructrices (rm -rf, dd of=…).\n'
            '« help » liste les commandes, « labreset » restaure les fichiers.',
        type: TermLineType.banner,
      ),
    );
  }

  void _recall() {
    final h = _engine.history;
    if (h.isEmpty) return;
    var c = TerminalSession._historyCursor;
    c = c <= 0 ? h.length - 1 : c - 1;
    TerminalSession._historyCursor = c;
    _controller.text = h[c];
    _controller.selection = TextSelection.collapsed(
      offset: _controller.text.length,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _run(String input) {
    TerminalSession._historyCursor = -1;
    setState(() {
      _lines.add(
        TermLine(text: '${_engine.prompt} $input', type: TermLineType.input),
      );
      final result = _engine.run(input);
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
                  child: Text(
                    'TERMINAL SIMULÉ — rien n\'est exécuté. Le Command Guard est une règle pédagogique, pas une protection système.',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
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
                  return SelectableText(
                    line.text,
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 13,
                      color: color,
                      height: 1.4,
                    ),
                  );
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
                  child: Text(
                    '${_engine.prompt} ',
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
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      color: Colors.greenAccent,
                      fontSize: 14,
                    ),
                    decoration: const InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(vertical: 8),
                      hintText: 'commande (ex: help, ls, nmap localhost)',
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
                  visualDensity: VisualDensity.compact,
                  onPressed: _recall,
                  icon: const Icon(Icons.history, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

enum TermLineType { input, output, warning, banner }

class TermLine {
  final String text;
  final TermLineType type;
  TermLine({required this.text, required this.type});
}
