import 'package:flutter/material.dart';

class CyberLabSeed {
  static const blue = Color(0xFF5B8DEF);
  static const green = Color(0xFFA6E22E);
  static const amber = Color(0xFFE2B93D);
  static const red = Color(0xFFF44747);
  static const purple = Color(0xFF8B90F0);
}

class StatTile extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const StatTile({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
        child: Column(
          children: [
            Icon(icon, color: CyberLabSeed.blue),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class SkillBar extends StatelessWidget {
  final String label;
  final int level; // 0-100
  final Color? color;

  const SkillBar({
    super.key,
    required this.label,
    required this.level,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? CyberLabSeed.blue;
    final blocks = (level / 10).round().clamp(0, 10);
    final bar = '█' * blocks + '░' * (10 - blocks);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(width: 110, child: Text(label)),
          Expanded(
            child: Text(
              bar,
              style: TextStyle(fontSize: 12, color: c, letterSpacing: 0),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 36,
            child: Text(
              '$level%',
              textAlign: TextAlign.right,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String title;
  const SectionTitle(this.title, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }
}

Color categoryColor(String category) {
  switch (category) {
    case 'fundamentals':
      return CyberLabSeed.blue;
    case 'linux':
      return CyberLabSeed.amber;
    case 'networking':
      return CyberLabSeed.purple;
    case 'bash':
      return CyberLabSeed.green;
    case 'python':
      return CyberLabSeed.blue;
    case 'web_security':
      return CyberLabSeed.red;
    default:
      return CyberLabSeed.blue;
  }
}

String categoryLabel(String category) {
  switch (category) {
    case 'fundamentals':
      return 'Fondamentaux';
    case 'linux':
      return 'Linux';
    case 'networking':
      return 'Réseau';
    case 'bash':
      return 'Bash';
    case 'python':
      return 'Python';
    case 'web_security':
      return 'Web Security';
    default:
      return category;
  }
}
