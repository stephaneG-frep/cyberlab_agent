import 'package:flutter/material.dart';
import '../models/course.dart';
import '../models/user_state.dart';
import '../services/app_state.dart';
import 'package:provider/provider.dart';
import '../widgets/common.dart';
import '../widgets/quiz_runner.dart';

class CourseView extends StatefulWidget {
  final Course course;
  const CourseView({super.key, required this.course});

  @override
  State<CourseView> createState() => _CourseViewState();
}

class _CourseViewState extends State<CourseView> {
  int _tab = 0; // 0 cours, 1 quiz, 2 exercices

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final app = context.read<AppState>();
      app.recordAttempt(widget.course.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final course = widget.course;
    return Scaffold(
      appBar: AppBar(
        title: Text(course.title, maxLines: 2, overflow: TextOverflow.ellipsis),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${course.level} · ${categoryLabel(course.category)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 8),
                Chip(
                  label: Text('${course.xp} XP à la fin'),
                  avatar: const Icon(Icons.military_tech, size: 16),
                ),
              ],
            ),
          ),
          SegmentedButton<int>(
            segments: const [
              ButtonSegment(
                value: 0,
                label: Text('Cours'),
                icon: Icon(Icons.menu_book),
              ),
              ButtonSegment(
                value: 1,
                label: Text('Quiz'),
                icon: Icon(Icons.quiz),
              ),
              ButtonSegment(
                value: 2,
                label: Text('Exercices'),
                icon: Icon(Icons.fitness_center),
              ),
            ],
            selected: {_tab},
            onSelectionChanged: (s) => setState(() => _tab = s.first),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: switch (_tab) {
              0 => _CourseContent(course: course),
              1 => _QuizTab(course: course),
              _ => _ExercisesTab(course: course),
            },
          ),
        ],
      ),
    );
  }
}

class _CourseContent extends StatelessWidget {
  final Course course;
  const _CourseContent({required this.course});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        _Section(
          title: 'Objectifs',
          child: Column(
            children: course.objectives
                .map(
                  (o) => _bullet(
                    o,
                    icon: Icons.check_circle_outline,
                    color: Colors.greenAccent,
                  ),
                )
                .toList(),
          ),
        ),
        if (course.prerequisites.isNotEmpty) ...[
          _Section(
            title: 'Prérequis',
            child: Column(
              children: course.prerequisites
                  .map((p) => _bullet(p, icon: Icons.info_outline))
                  .toList(),
            ),
          ),
        ],
        ...course.sections.map((s) => _ContentSectionView(section: s)),
        _Section(
          title: 'Erreurs fréquentes',
          child: Column(
            children: course.commonMistakes
                .map(
                  (m) => _bullet(
                    m,
                    icon: Icons.warning_amber,
                    color: Colors.orange,
                  ),
                )
                .toList(),
          ),
        ),
        _Section(
          title: 'Résumé',
          child: Card(
            color: CyberLabSeed.blue.withValues(alpha: 0.12),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Text(course.summary),
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final Widget child;
  const _Section({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}

Widget _bullet(String text, {IconData icon = Icons.arrow_right, Color? color}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 3),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: color ?? CyberLabSeed.blue),
        const SizedBox(width: 8),
        Expanded(child: Text(text)),
      ],
    ),
  );
}

class _ContentSectionView extends StatelessWidget {
  final ContentSection section;
  const _ContentSectionView({required this.section});

  @override
  Widget build(BuildContext context) {
    return _Section(
      title: section.title,
      child: Column(children: section.blocks.map(_blockWidget).toList()),
    );
  }
}

Widget _blockWidget(ContentBlock block) {
  switch (block.type) {
    case BlockType.code:
      return Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (block.label != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  block.label!,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ),
            SelectableText(
              block.text,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 13,
                color: Colors.greenAccent,
                height: 1.3,
              ),
            ),
          ],
        ),
      );
    case BlockType.list:
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Text(block.text, style: const TextStyle(height: 1.5)),
      );
    case BlockType.warning:
      return _callout(block.text, Icons.warning_amber, Colors.orange);
    case BlockType.tip:
      return _callout(block.text, Icons.lightbulb_outline, Colors.greenAccent);
    case BlockType.note:
      return _callout(block.text, Icons.info_outline, CyberLabSeed.blue);
    default:
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Text(block.text, style: const TextStyle(height: 1.5)),
      );
  }
}

Widget _callout(String text, IconData icon, Color color) {
  return Container(
    margin: const EdgeInsets.symmetric(vertical: 6),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.10),
      borderRadius: BorderRadius.circular(8),
      border: Border(left: BorderSide(color: color, width: 4)),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Expanded(child: Text(text)),
      ],
    ),
  );
}

class _QuizTab extends StatelessWidget {
  final Course course;
  const _QuizTab({required this.course});

  @override
  Widget build(BuildContext context) {
    if (course.quiz.isEmpty) {
      return const Center(child: Text('Aucun quiz pour ce cours.'));
    }
    return QuizRunner(
      key: ValueKey('quiz-${course.id}'),
      questions: course.quiz,
      scopeId: course.id,
      skill: _skillFor(course.category),
    );
  }
}

class _ExercisesTab extends StatelessWidget {
  final Course course;
  const _ExercisesTab({required this.course});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Exercices pratiques',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'Terminez ce cours pour valider les exercices. Chaque exercice '
          'rapporte ${course.xp ~/ 2} XP une seule fois ; vous pouvez le refaire '
          'autant que vous voulez pour vous entraîner.',
        ),
        const SizedBox(height: 16),
        for (var i = 0; i < course.exercises.length; i++)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Chip(
                        label: Text('${i + 1}'),
                        backgroundColor: CyberLabSeed.blue.withValues(
                          alpha: 0.2,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          course.exercises[i].title,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(course.exercises[i].instruction),
                  const SizedBox(height: 8),
                  _ExerciseButton(course: course, index: i),
                ],
              ),
            ),
          ),
        const SizedBox(height: 8),
        _MarkCompleteButton(course: course),
      ],
    );
  }
}

String _skillFor(String category) {
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
      return 'Web';
    default:
      return 'Général';
  }
}

class _MarkCompleteButton extends StatelessWidget {
  final Course course;
  const _MarkCompleteButton({required this.course});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, app, _) {
        final done = app.user.completedCourses.contains(course.id);
        if (done) {
          return Card(
            color: Colors.green.withValues(alpha: 0.15),
            child: const ListTile(
              leading: Icon(Icons.check_circle, color: Colors.greenAccent),
              title: Text('Cours terminé !'),
              subtitle: Text('Vous avez gagné les XP de ce cours.'),
            ),
          );
        }
        return FilledButton.icon(
          onPressed: () async {
            final messenger = ScaffoldMessenger.of(context);
            final gained = await app.completeCourse(
              course.id,
              course.xp,
              skill: _skillFor(course.category),
            );
            messenger.showSnackBar(
              SnackBar(
                content: Text(
                  gained > 0
                      ? 'Cours terminé ! +$gained XP'
                      : 'Cours terminé (XP déjà obtenus).',
                ),
              ),
            );
          },
          icon: const Icon(Icons.emoji_events),
          label: Text('Terminer le cours (+${course.xp} XP)'),
        );
      },
    );
  }
}

class _ExerciseButton extends StatelessWidget {
  final Course course;
  final int index;
  const _ExerciseButton({required this.course, required this.index});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final courseDone = app.user.completedCourses.contains(course.id);
    final rewarded = app.isRewarded(
      RewardKeys.exercise(exerciseId(course.id, index)),
    );
    final xp = course.xp ~/ 2;
    if (rewarded) {
      return const Chip(
        avatar: Icon(Icons.check_circle, color: Colors.greenAccent, size: 18),
        label: Text('Exercice validé (XP obtenus)'),
      );
    }
    return FilledButton.tonalIcon(
      onPressed: courseDone
          ? () async {
              final messenger = ScaffoldMessenger.of(context);
              final gained = await app.completeExercise(
                course.id,
                index,
                xp,
                skill: _skillFor(course.category),
              );
              messenger.showSnackBar(
                SnackBar(
                  content: Text(
                    gained > 0
                        ? '+$gained XP (exercice validé)'
                        : 'Exercice déjà validé : pas de nouveaux XP.',
                  ),
                ),
              );
            }
          : null,
      icon: const Icon(Icons.fitness_center),
      label: Text('Valider l\'exercice (+$xp XP)'),
    );
  }
}
