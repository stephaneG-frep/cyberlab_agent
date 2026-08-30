import 'package:flutter/material.dart' hide Badge;
import 'package:provider/provider.dart';
import '../data/badges.dart';
import '../data/course_library.dart';
import '../data/ctf_library.dart';
import '../models/user_state.dart';
import '../services/app_state.dart';
import '../widgets/common.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final user = app.user;
    final defs = badgeDefs();
    final earned = defs.where((d) => _badgeEarned(d, user)).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        child: Text(
                          (user.name.isNotEmpty ? user.name[0] : 'A')
                              .toUpperCase(),
                          style: const TextStyle(fontSize: 24),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.name.isNotEmpty ? user.name : 'Apprenant',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text('Niveau ${user.level} · ${user.xp} XP'),
                            Text(
                              'Chemin : ${_pathLabel(user.selectedPath)}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: user.progressToNext / 100,
                    minHeight: 10,
                    color: CyberLabSeed.blue,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${user.progressToNext}% vers le niveau ${user.level + 1}',
                  ),
                ],
              ),
            ),
          ),
          const SectionTitle('Compétences'),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: user.skills.isEmpty
                  ? const Text(
                      'Terminez des cours pour faire progresser vos compétences.',
                    )
                  : Column(
                      children: [
                        for (final s
                            in user.skills.values.toList()
                              ..sort((a, b) => b.xp.compareTo(a.xp)))
                          SkillBar(label: s.name, level: s.level),
                      ],
                    ),
            ),
          ),
          const SectionTitle('Statistiques'),
          Row(
            children: [
              Expanded(
                child: StatTile(
                  icon: Icons.check_circle_outline,
                  value: '${user.completedCourses.length}',
                  label: 'Cours',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: StatTile(
                  icon: Icons.flag_outlined,
                  value: '${user.solvedChallenges.length}',
                  label: 'CTF',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: StatTile(
                  icon: Icons.local_fire_department,
                  value: '${user.streak}',
                  label: 'Série',
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.timer_outlined),
              title: const Text('Temps d\'apprentissage'),
              trailing: Text('${user.learningMinutes} min'),
            ),
          ),
          const SectionTitle('Badges'),
          if (earned.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Aucun badge pour l\'instant. Continuez à apprendre !',
                ),
              ),
            )
          else
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [for (final d in earned) _badgeRow(d.badge)],
                ),
              ),
            ),
          const SectionTitle('Badges à débloquer'),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  for (final d in defs.where((d) => !_badgeEarned(d, user)))
                    _badgeRow(d.badge, locked: true),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _pathLabel(String p) {
    switch (p) {
      case 'fundamentals':
        return 'Fondamentaux';
      case 'linux':
        return 'Linux';
      case 'networking':
        return 'Réseau';
      case 'web_security':
        return 'Sécurité Web';
      default:
        return p;
    }
  }
}

IconData _badgeIcon(String name) {
  switch (name) {
    case 'terminal':
      return Icons.terminal;
    case 'router':
      return Icons.router;
    case 'language':
      return Icons.language;
    case 'code':
      return Icons.code;
    case 'search':
      return Icons.search;
    case 'fingerprint':
      return Icons.fingerprint;
    case 'flag':
      return Icons.flag;
    case 'workspace_premium':
      return Icons.workspace_premium;
    case 'stars':
      return Icons.stars;
    default:
      return Icons.emoji_events;
  }
}

Color _badgeColor(String hex) {
  final h = hex.replaceFirst('#', '');
  final v = int.tryParse(h, radix: 16) ?? 0xFF66D9EF;
  return Color(0xFF000000 | (v & 0xFFFFFF));
}

Widget _badgeRow(Badge b, {bool locked = false}) {
  return ListTile(
    dense: true,
    leading: Icon(
      _badgeIcon(b.icon),
      color: locked ? Colors.grey : _badgeColor(b.color),
    ),
    title: Text(b.name, style: TextStyle(color: locked ? Colors.grey : null)),
    subtitle: Text(b.description),
    trailing: Icon(
      locked ? Icons.lock_outline : Icons.emoji_events,
      color: locked ? Colors.grey : Colors.amber,
    ),
  );
}

bool _badgeEarned(BadgeDef d, UserState user) {
  switch (d.type) {
    case 'courses':
      final cat = d.category;
      final count = CourseLibrary.all
          .where((c) => c.category == cat)
          .where((c) => user.completedCourses.contains(c.id))
          .length;
      return count >= d.threshold;
    case 'ctf':
      final solvedIds = user.solvedChallenges;
      if (d.category == 'all') {
        return solvedIds.length >= d.threshold;
      }
      final count = ctfChallenges()
          .where((c) => c.category == d.category)
          .where((c) => solvedIds.contains(c.id))
          .length;
      return count >= d.threshold;
    case 'level':
      return user.level >= d.threshold;
    default:
      return false;
  }
}
