import 'package:flutter/material.dart';
import '../widgets/common.dart';
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
                ButtonSegment(value: 2, label: Text('Labs')),
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
              2 => const LabManagerView(),
              _ => const WiresharkScreen(),
            },
          ),
        ],
      ),
    );
  }
}

class LabManagerView extends StatelessWidget {
  const LabManagerView({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        _InfoBanner(),
        SizedBox(height: 14),
        Text(
          'CyberLab Manager',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 4),
        Text(
          'Gestion des laboratoires. Les boutons ne sont actifs que si l\'environnement le permet réellement.',
        ),
        SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _LabTile(
              name: 'Simulation (intégré)',
              type: 'Simulation',
              difficulty: 'Facile',
              status: 'Disponible',
              available: true,
              icon: Icons.phone_android,
            ),
            _LabTile(
              name: 'Docker Labs',
              type: 'Docker',
              difficulty: 'Moyen',
              status: 'Non détecté',
              available: false,
              icon: Icons.storage,
            ),
            _LabTile(
              name: 'Machines virtuelles',
              type: 'VirtualBox/VMware',
              difficulty: 'Moyen',
              status: 'Non détecté',
              available: false,
              icon: Icons.desktop_windows,
            ),
            _LabTile(
              name: 'SSH Lab',
              type: 'Connexion distante',
              difficulty: 'Moyen',
              status: 'Non configuré',
              available: false,
              icon: Icons.dns,
            ),
          ],
        ),
      ],
    );
  }
}

class _InfoBanner extends StatelessWidget {
  const _InfoBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Row(
        children: [
          Icon(Icons.shield, color: Colors.orange),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              '100% mode simulation sur cet appareil, sans laboratoire externe. '
              'Les vrais labs (Docker, VM, SSH) s\'activeraient sur une machine qui les supporte. '
              'On ne se connecte jamais automatiquement à une machine inconnue.',
            ),
          ),
        ],
      ),
    );
  }
}

class _LabTile extends StatelessWidget {
  final String name;
  final String type;
  final String difficulty;
  final String status;
  final bool available;
  final IconData icon;

  const _LabTile({
    required this.name,
    required this.type,
    required this.difficulty,
    required this.status,
    required this.available,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 170,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    icon,
                    color: available ? CyberLabSeed.green : Colors.grey,
                    size: 28,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _row(type),
                    const SizedBox(height: 2),
                    _row(difficulty),
                    const SizedBox(height: 2),
                    _row(status),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _btn('Démarrer', available),
                  _btn('Arrêter', false),
                  _btn('Réinit.', false),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _row(String value) {
    final color = available ? CyberLabSeed.green : Colors.grey;
    return Text(
      value,
      style: TextStyle(fontSize: 12, color: color),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _btn(String label, bool active) {
    return Expanded(
      child: active
          ? FilledButton.tonal(
              onPressed: () {},
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                minimumSize: Size.zero,
              ),
              child: Text(
                label,
                style: const TextStyle(fontSize: 11),
                maxLines: 1,
              ),
            )
          : AbsorbPointer(
              absorbing: true,
              child: Opacity(
                opacity: 0.35,
                child: FilledButton.tonal(
                  onPressed: () {},
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 8,
                    ),
                    minimumSize: Size.zero,
                  ),
                  child: Text(
                    label,
                    style: const TextStyle(fontSize: 11),
                    maxLines: 1,
                  ),
                ),
              ),
            ),
    );
  }
}
