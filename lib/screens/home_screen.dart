import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../data/course_library.dart';
import '../widgets/common.dart';
import 'course_view.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  String get _greeting {
    final h = DateTime.now().hour;
    if (h < 12) return 'Bonjour';
    if (h < 18) return 'Bon après-midi';
    return 'Bonsoir';
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final courses = CourseLibrary.all;
    final nextCourse = courses.firstWhere(
      (c) => !app.user.completedCourses.contains(c.id),
      orElse: () => courses.first,
    );

    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: Text(
          '$_greeting, ${app.user.name.isNotEmpty ? app.user.name : 'Apprenant'}',
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _levelCard(context, app),
          const SizedBox(height: 16),
          _continueCard(context, app, nextCourse),
          const SizedBox(height: 16),
          _statsGrid(app),
          if (app.user.skills.isNotEmpty) ...[
            const SizedBox(height: 16),
            _topSkill(app),
          ],
        ],
      ),
    );
  }

  Widget _levelCard(BuildContext context, AppState app) {
    final user = app.user;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.military_tech, color: Colors.amber),
                const SizedBox(width: 8),
                Text(
                  'Niveau ${user.level}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  '${user.xp} XP',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: user.progressToNext / 100,
                minHeight: 10,
                color: CyberLabSeed.blue,
                backgroundColor: Colors.white10,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${user.progressToNext}% vers le niveau ${user.level + 1} '
              '(${user.xp}/${user.xpForNextLevel} XP)',
            ),
          ],
        ),
      ),
    );
  }

  Widget _continueCard(BuildContext context, AppState app, dynamic next) {
    return Card(
      color: CyberLabSeed.blue.withValues(alpha: 0.15),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => CourseView(course: next))),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Icon(
                Icons.play_circle_fill,
                color: CyberLabSeed.blue,
                size: 40,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Continuer ma formation',
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      next.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      next.level,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statsGrid(AppState app) {
    final user = app.user;
    return Row(
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
            icon: Icons.local_fire_department,
            value: '${app.currentStreak}',
            label: 'Série',
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
            icon: Icons.stars_outlined,
            value: '${app.earnedBadges.length}',
            label: 'Badges',
          ),
        ),
      ],
    );
  }

  Widget _topSkill(AppState app) {
    final skills = app.user.skills.values.toList()
      ..sort((a, b) => b.level.compareTo(a.level));
    final top = skills.first;
    return Card(
      child: ListTile(
        leading: const Icon(Icons.trending_up, color: Colors.greenAccent),
        title: Text('Compétence forte : ${top.name}'),
        subtitle: Text('Niveau ${top.level}/100'),
        trailing: Text('${top.xp} XP'),
      ),
    );
  }
}
