import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/note.dart';
import '../services/app_state.dart';

class NotesScreen extends StatelessWidget {
  const NotesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cyber Notes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Nouvelle note',
            onPressed: () => _openEditor(context, app, null),
          ),
        ],
      ),
      body: app.notes.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Aucune note. Utilisez "+" pour en créer une et garder vos commandes, astuces et découvertes.',
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: app.notes.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, i) {
                final n = app.notes[i];
                return Card(
                  child: ListTile(
                    leading: Icon(
                      n.favorite ? Icons.star : Icons.sticky_note_2_outlined,
                      color: n.favorite ? Colors.amber : null,
                    ),
                    title: Text(
                      n.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      '${n.category} · ${n.content.replaceAll('\n', ' ')}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    isThreeLine: n.content.contains('\n'),
                    onTap: () => _openEditor(context, app, n),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline),
                      tooltip: 'Supprimer',
                      onPressed: () => app.deleteNote(n.id),
                    ),
                  ),
                );
              },
            ),
    );
  }

  void _openEditor(BuildContext context, AppState app, Note? existing) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _NoteEditor(note: existing, app: app),
      ),
    );
  }
}

class _NoteEditor extends StatefulWidget {
  final Note? note;
  final AppState app;
  const _NoteEditor({required this.note, required this.app});

  @override
  State<_NoteEditor> createState() => _NoteEditorState();
}

class _NoteEditorState extends State<_NoteEditor> {
  late final TextEditingController _title;
  late final TextEditingController _content;
  late String _category;
  late bool _favorite;

  static const _cats = [
    'Général',
    'Linux',
    'Réseau',
    'Bash',
    'Python',
    'Web',
    'CTF',
  ];

  @override
  void initState() {
    super.initState();
    final n = widget.note;
    _title = TextEditingController(text: n?.title ?? '');
    _content = TextEditingController(text: n?.content ?? '');
    _category = n?.category ?? 'Général';
    _favorite = n?.favorite ?? false;
  }

  @override
  void dispose() {
    _title.dispose();
    _content.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final title = _title.text.trim();
    if (title.isEmpty) return;
    final n = widget.note;
    if (n == null) {
      final note = Note(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        title: title,
        content: _content.text,
        category: _category,
        favorite: _favorite,
      );
      await widget.app.addNote(note);
    } else {
      n.title = title;
      n.content = _content.text;
      n.category = _category;
      n.favorite = _favorite;
      await widget.app.updateNote(n);
    }
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.note == null ? 'Nouvelle note' : 'Modifier la note'),
        actions: [
          IconButton(
            icon: const Icon(Icons.star),
            color: _favorite ? Colors.amber : null,
            onPressed: () => setState(() => _favorite = !_favorite),
          ),
          IconButton(icon: const Icon(Icons.check), onPressed: _save),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _title,
            decoration: const InputDecoration(
              labelText: 'Titre',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _category,
            decoration: const InputDecoration(
              labelText: 'Catégorie',
              border: OutlineInputBorder(),
            ),
            items: [
              for (final c in _cats) DropdownMenuItem(value: c, child: Text(c)),
            ],
            onChanged: (v) => setState(() => _category = v ?? 'Général'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _content,
            maxLines: 12,
            decoration: const InputDecoration(
              labelText: 'Contenu (commandes, astuces...)',
              border: OutlineInputBorder(),
              alignLabelWithHint: true,
            ),
          ),
        ],
      ),
    );
  }
}
