import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../models/course.dart';
import '../widgets/common.dart';
import '../widgets/path_picker.dart';
import 'course_view.dart';
import 'review_screen.dart';

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
    final nextCourse = app.nextCourse;

    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (context) => IconButton(
            tooltip: 'Menu',
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
          _pathCard(context, app),
          const SizedBox(height: 8),
          if (nextCourse != null)
            _continueCard(context, app, nextCourse)
          else
            const Card(
              child: ListTile(
                leading: Icon(Icons.emoji_events, color: Colors.amber),
                title: Text('Tous les cours sont terminés !'),
                subtitle: Text(
                  'Rejouez les quiz, attaquez les CTF ou entraînez-vous au Lab.',
                ),
              ),
            ),
          const SizedBox(height: 16),
          if (app.mistakes.isNotEmpty) ...[
            Card(
              key: const ValueKey('home-review'),
              color: Colors.orange.withValues(alpha: 0.12),
              child: ListTile(
                leading: const Icon(Icons.replay, color: Colors.orange),
                title: Text('${app.mistakes.length} question(s) à revoir'),
                subtitle: const Text('Les réussir rapporte encore leurs XP.'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (_) => const ReviewScreen())),
              ),
            ),
            const SizedBox(height: 8),
          ],
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
                Expanded(
                  child: Text(
                    'Niveau ${user.level}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    '${user.xp} XP',
                    textAlign: TextAlign.end,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                semanticsLabel: 'Progression vers le niveau ${user.level + 1}',
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

  Widget _pathCard(BuildContext context, AppState app) {
    final path = app.currentPath;
    final progress = app.pathProgress;
    return Card(
      key: const ValueKey('home-path'),
      child: ListTile(
        leading: Icon(path.icon, color: categoryColor(path.id)),
        title: Text('Parcours ${path.label}'),
        subtitle: Text('${progress.done}/${progress.total} cours terminés'),
        trailing: TextButton(
          onPressed: () => showPathPicker(context),
          child: const Text('Changer'),
        ),
      ),
    );
  }

  Widget _continueCard(BuildContext context, AppState app, Course next) {
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
