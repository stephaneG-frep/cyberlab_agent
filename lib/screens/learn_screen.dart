import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/course_library.dart';
import '../services/app_state.dart';
import '../widgets/common.dart';
import 'course_view.dart';

class LearnScreen extends StatefulWidget {
  const LearnScreen({super.key});

  @override
  State<LearnScreen> createState() => _LearnScreenState();
}

class _LearnScreenState extends State<LearnScreen> {
  String _category = 'fundamentals';
  String _query = '';

  static const _cats = [
    ('fundamentals', 'Fondamentaux', Icons.auto_stories),
    ('linux', 'Linux', Icons.terminal),
    ('networking', 'Réseau', Icons.hub),
    ('bash', 'Bash', Icons.code),
    ('python', 'Python', Icons.smart_toy),
    ('web_security', 'Web', Icons.language),
  ];

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    var courses = CourseLibrary.byCategory(_category);
    if (_query.isNotEmpty) {
      courses = courses
          .where((c) => c.title.toLowerCase().contains(_query.toLowerCase()))
          .toList();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Apprendre'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _showSearch(context, app),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (final (id, label, icon) in _cats)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: ChoiceChip(
                        avatar: Icon(
                          icon,
                          size: 18,
                          color: _category == id
                              ? Colors.white
                              : categoryColor(id),
                        ),
                        label: Text(label),
                        selected: _category == id,
                        onSelected: (_) => setState(() => _category = id),
                      ),
                    ),
                ],
              ),
            ),
          ),
          if (_query.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Text(
                    'Résultats pour "$_query"',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => setState(() => _query = ''),
                    child: const Text('Effacer'),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 4),
          Expanded(
            child: courses.isEmpty
                ? const Center(child: Text('Aucun cours trouvé.'))
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: courses.length,
                    itemBuilder: (context, i) {
                      final course = courses[i];
                      final done = app.user.completedCourses.contains(
                        course.id,
                      );
                      return Card(
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: categoryColor(
                              course.category,
                            ).withValues(alpha: 0.2),
                            child: Icon(
                              Icons.lock_open,
                              color: categoryColor(course.category),
                            ),
                          ),
                          title: Text(course.title),
                          subtitle: Text(course.level),
                          trailing: done
                              ? const Icon(
                                  Icons.check_circle,
                                  color: Colors.greenAccent,
                                )
                              : Text('${course.xp} XP'),
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => CourseView(course: course),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _showSearch(BuildContext context, AppState app) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Rechercher un cours',
                  prefixIcon: Icon(Icons.search),
                ),
                onSubmitted: (v) {
                  setState(() => _query = v);
                  Navigator.pop(ctx);
                },
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                  },
                  child: const Text('Rechercher'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
