import 'package:flutter/material.dart';
import '../services/terminal_engine.dart';

class TerminalScreen extends StatefulWidget {
  const TerminalScreen({super.key});

  @override
  State<TerminalScreen> createState() => _TerminalScreenState();
}

class _TerminalScreenState extends State<TerminalScreen> {
  final TerminalEngine _engine = TerminalEngine();
  final List<_TermLine> _lines = [];
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _banner();
  }

  void _banner() {
    _lines.add(
      _TermLine(
        text:
            'CyberLab Terminal Simulé.\nCe terminal imite Linux : aucune commande n\'est exécutée sur votre appareil.\n'
            'Command Guard : règle pédagogique qui refuse les commandes destructrices (rm -rf, dd of=…).\n'
            'Tapez "help" pour la liste des commandes.\nTapez "man <cmd>" pour la documentation d\'une commande.',
        type: _LineType.banner,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _run(String input) {
    setState(() {
      _lines.add(
        _TermLine(text: '${_engine.prompt} $input', type: _LineType.input),
      );
      final result = _engine.run(input);
      if (result.clear) {
        _lines.clear();
      } else if (result.output.isNotEmpty) {
        _lines.add(
          _TermLine(
            text: result.output,
            type: result.blocked ? _LineType.warning : _LineType.output,
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
                    _LineType.input => Colors.lightBlueAccent,
                    _LineType.warning => Colors.orange,
                    _LineType.banner => Colors.grey,
                    _LineType.output => Colors.greenAccent,
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
                Text(
                  '${_engine.prompt} ',
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    color: Colors.greenAccent,
                  ),
                ),
                Expanded(
                  child: TextField(
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}

enum _LineType { input, output, warning, banner }

class _TermLine {
  final String text;
  final _LineType type;
  _TermLine({required this.text, required this.type});
}
