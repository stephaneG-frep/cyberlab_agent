import 'package:flutter/material.dart';
import 'scenarios_screen.dart';
import 'terminal_screen.dart';
import '../widgets/soc_simulator.dart';
import 'wireshark_screen.dart';

class LabScreen extends StatefulWidget {
  const LabScreen({super.key});

  @override
  State<LabScreen> createState() => _LabScreenState();
}

class _LabScreenState extends State<LabScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Laboratoire')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: SegmentedButton<int>(
              showSelectedIcon: false,
              style: ButtonStyle(
                visualDensity: VisualDensity.compact,
                textStyle: WidgetStatePropertyAll(
                  const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                ),
              ),
              segments: const [
                ButtonSegment(value: 0, label: Text('Terminal')),
                ButtonSegment(value: 1, label: Text('SOC')),
                ButtonSegment(value: 2, label: Text('Enquêtes')),
                ButtonSegment(value: 3, label: Text('Réseau')),
              ],
              selected: {_tab},
              onSelectionChanged: (s) => setState(() => _tab = s.first),
            ),
          ),
          Expanded(
            child: switch (_tab) {
              0 => const TerminalScreen(),
              1 => const SocSimulator(),
              2 => const ScenariosView(),
              _ => const WiresharkScreen(),
            },
          ),
        ],
      ),
    );
  }
}
