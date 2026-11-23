import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/learning_paths.dart';
import '../services/app_state.dart';
import 'common.dart';

/// Liste des parcours ; [selected] est mis en évidence.
class PathList extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onSelected;
  const PathList({super.key, required this.selected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final p in LearningPaths.all)
          Card(
            key: ValueKey('path-${p.id}'),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: p.id == selected
                    ? categoryColor(p.id)
                    : Colors.transparent,
                width: 2,
              ),
            ),
            child: ListTile(
              leading: Icon(p.icon, color: categoryColor(p.id)),
              title: Text(p.label),
              subtitle: Text(
                '${p.description} · ${p.courses.length} cours',
                style: const TextStyle(fontSize: 12),
              ),
              trailing: p.id == selected
                  ? Icon(Icons.check_circle, color: categoryColor(p.id))
                  : null,
              onTap: () => onSelected(p.id),
            ),
          ),
      ],
    );
  }
}

/// Feuille de choix du parcours (profil, accueil).
Future<void> showPathPicker(BuildContext context) {
  final app = context.read<AppState>();
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (ctx) => SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Choisir un parcours',
              style: Theme.of(ctx).textTheme.titleLarge,
            ),
            const SizedBox(height: 4),
            const Text(
              'Le parcours guide l\'accueil et l\'onglet Apprendre. Tous les '
              'cours restent accessibles, et votre progression est conservée.',
              style: TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 12),
            PathList(
              selected: app.user.selectedPath,
              onSelected: (id) async {
                Navigator.of(ctx).pop();
                await app.setPath(id);
              },
            ),
          ],
        ),
      ),
    ),
  );
}
