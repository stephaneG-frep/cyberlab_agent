import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/cheat_sheets.dart';
import '../models/course.dart';
import '../models/ctf_challenge.dart';
import '../models/note.dart';
import '../services/app_state.dart';
import '../services/search_service.dart';
import '../widgets/common.dart';
import 'course_view.dart';
import 'ctf_screen.dart';
import 'docs_screen.dart';
import 'notes_screen.dart';

/// Recherche dans le contenu des cours, fiches, challenges et notes.
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  /// Index construit une seule fois (contenu statique).
  static final SearchService _service = SearchService();
  static const _maxShown = 60;

  final TextEditingController _controller = TextEditingController();
  SearchKind? _kind;

  static const _labels = {
    SearchKind.course: ('Cours', Icons.menu_book),
    SearchKind.sheet: ('Fiches', Icons.description_outlined),
    SearchKind.ctf: ('CTF', Icons.flag_outlined),
    SearchKind.note: ('Notes', Icons.sticky_note_2_outlined),
  };

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _open(SearchHit hit) {
    final app = context.read<AppState>();
    final Widget screen = switch (hit.item) {
      final Course c => CourseView(course: c),
      final CheatSheet s => DocsScreen(openSheetId: s.id),
      final CtfChallenge c => ChallengeView(challenge: c),
      final Note n => NoteEditor(note: n, app: app),
      _ => const DocsScreen(),
    };
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final query = _controller.text;
    final hits = _service.search(query, notes: app.notes);
    final counts = <SearchKind, int>{};
    for (final h in hits) {
      counts[h.kind] = (counts[h.kind] ?? 0) + 1;
    }
    // Un filtre devenu vide ne doit pas masquer tous les résultats.
    final kind = counts.containsKey(_kind) ? _kind : null;
    final shown = kind == null
        ? hits
        : hits.where((h) => h.kind == kind).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Rechercher')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: TextField(
              key: const ValueKey('search-field'),
              controller: _controller,
              autofocus: true,
              textInputAction: TextInputAction.search,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Un mot, une commande, une notion…',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: query.isEmpty
                    ? null
                    : IconButton(
                        tooltip: 'Effacer',
                        icon: const Icon(Icons.clear),
                        onPressed: () => setState(_controller.clear),
                      ),
              ),
            ),
          ),
          if (hits.isNotEmpty)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ChoiceChip(
                      label: Text('Tout (${hits.length})'),
                      selected: kind == null,
                      onSelected: (_) => setState(() => _kind = null),
                    ),
                  ),
                  for (final e in _labels.entries)
                    if (counts[e.key] case final n?)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: ChoiceChip(
                          label: Text('${e.value.$1} ($n)'),
                          selected: kind == e.key,
                          onSelected: (_) => setState(() => _kind = e.key),
                        ),
                      ),
                ],
              ),
            ),
          Expanded(
            child: hits.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        query.trim().length < 2
                            ? 'Cherchez dans le texte des cours, les fiches, '
                                  'les challenges et vos notes. Les réponses '
                                  'des quiz et des CTF ne sont pas incluses.'
                            : 'Aucun résultat pour « ${query.trim()} ».',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: shown.length > _maxShown
                        ? _maxShown + 1
                        : shown.length,
                    itemBuilder: (context, i) {
                      if (i == _maxShown) {
                        return Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            '${shown.length - _maxShown} autres résultats : '
                            'précisez la recherche.',
                            textAlign: TextAlign.center,
                          ),
                        );
                      }
                      return _tile(context, shown[i]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _tile(BuildContext context, SearchHit hit) {
    final (label, icon) = _labels[hit.kind]!;
    final item = hit.item;
    final origin = item is Course ? categoryLabel(item.category) : label;
    return Card(
      child: ListTile(
        leading: Icon(icon, semanticLabel: label),
        title: Text(hit.title.isEmpty ? '(sans titre)' : hit.title),
        subtitle: Text(
          hit.snippet.isEmpty
              ? (hit.where == 'Titre' ? origin : '$origin · ${hit.where}')
              : '$origin · ${hit.where}\n${hit.snippet}',
          maxLines: 4,
          overflow: TextOverflow.ellipsis,
        ),
        onTap: () => _open(hit),
      ),
    );
  }
}
