import '../data/cheat_sheets.dart';
import '../data/course_library.dart';
import '../data/ctf_library.dart';
import '../models/course.dart';
import '../models/ctf_challenge.dart';
import '../models/note.dart';

enum SearchKind { course, sheet, ctf, note }

/// Un résultat : l'élément trouvé, où, et un extrait autour du mot.
class SearchHit {
  final SearchKind kind;
  final String title;

  /// Partie où le mot a été trouvé (« Titre », nom de la section…).
  final String where;
  final String snippet;
  final int score;

  /// Élément d'origine : Course, CheatSheet, CtfChallenge ou Note.
  final Object item;

  const SearchHit({
    required this.kind,
    required this.title,
    required this.where,
    required this.snippet,
    required this.score,
    required this.item,
  });
}

class _Field {
  _Field(this.label, this.text, this.weight)
    : folded = SearchService.fold(text);
  final String label;
  final String text;
  final String folded;
  final int weight;
}

class _Doc {
  _Doc(this.kind, this.title, this.item, this.fields);
  final SearchKind kind;
  final String title;
  final Object item;
  final List<_Field> fields;
}

/// Recherche hors ligne dans les cours, fiches, challenges et notes.
///
/// Les RÉPONSES ne sont jamais indexées : ni questions de quiz (et leurs
/// explications), ni indices, réponses ou solutions de CTF.
class SearchService {
  SearchService({
    List<Course>? courses,
    List<CheatSheet>? sheets,
    List<CtfChallenge>? challenges,
  }) : _static = [
         for (final c in courses ?? CourseLibrary.all) _course(c),
         for (final s in sheets ?? cheatSheets()) _sheet(s),
         for (final c in challenges ?? ctfChallenges()) _ctf(c),
       ];

  final List<_Doc> _static;

  static const _accents = {
    'à': 'a', 'â': 'a', 'ä': 'a', 'á': 'a', 'ã': 'a', 'å': 'a', //
    'ç': 'c', 'é': 'e', 'è': 'e', 'ê': 'e', 'ë': 'e',
    'î': 'i', 'ï': 'i', 'í': 'i', 'ì': 'i', 'ñ': 'n',
    'ô': 'o', 'ö': 'o', 'ó': 'o', 'ò': 'o', 'õ': 'o',
    'ù': 'u', 'û': 'u', 'ü': 'u', 'ú': 'u', 'ÿ': 'y', '’': "'",
  };

  /// Minuscules sans accents. La longueur est conservée : une position dans
  /// le texte replié est la même dans le texte d'origine (extraits).
  static String fold(String s) {
    final b = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      final low = s[i].toLowerCase();
      final c = low.length == 1 ? low : s[i];
      b.write(_accents[c] ?? c);
    }
    return b.toString();
  }

  static _Doc _course(Course c) => _Doc(SearchKind.course, c.title, c, [
    _Field('Titre', c.title, 100),
    _Field('Résumé', c.summary, 30),
    _Field('Objectifs', c.objectives.join(' · '), 25),
    for (final s in c.sections) ...[
      _Field(s.title, s.title, 40),
      _Field(s.title, s.blocks.map((b) => b.text).join('\n'), 15),
    ],
    _Field('Erreurs fréquentes', c.commonMistakes.join(' · '), 10),
    _Field('Exercices', c.exercises.map((e) => e.instruction).join(' · '), 8),
  ]);

  static _Doc _sheet(CheatSheet s) => _Doc(SearchKind.sheet, s.title, s, [
    _Field('Titre', s.title, 80),
    for (final e in s.entries)
      _Field(e.topic, '${e.topic} : ${e.syntax} — ${e.description}', 20),
  ]);

  static _Doc _ctf(CtfChallenge c) => _Doc(SearchKind.ctf, c.title, c, [
    _Field('Titre', c.title, 80),
    _Field('Objectif', c.objective, 20),
    _Field('Catégorie', c.category, 15),
  ]);

  static _Doc _note(Note n) => _Doc(SearchKind.note, n.title, n, [
    _Field('Titre', n.title, 90),
    _Field('Contenu', n.content, 20),
    _Field('Catégorie', n.category, 10),
  ]);

  /// Tous les mots de [query] doivent se trouver dans l'élément (dans
  /// n'importe quelle partie). Résultats du plus au moins pertinent.
  List<SearchHit> search(String query, {List<Note> notes = const []}) {
    final words = fold(
      query.trim(),
    ).split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toSet().toList();
    if (words.isEmpty || words.join().length < 2) return const [];
    final hits = <SearchHit>[];
    for (final doc in [..._static, ...notes.map(_note)]) {
      final hit = _match(doc, words);
      if (hit != null) hits.add(hit);
    }
    hits.sort((a, b) {
      final s = b.score.compareTo(a.score);
      return s != 0 ? s : a.title.compareTo(b.title);
    });
    return hits;
  }

  static SearchHit? _match(_Doc doc, List<String> words) {
    var score = 0;
    _Field? best;
    var bestWeight = -1, bestAt = 0;
    for (final w in words) {
      var found = false;
      for (final f in doc.fields) {
        final at = _find(f.folded, w);
        if (at < 0) continue;
        found = true;
        // Un mot entier compte bien plus qu'un fragment (« symétrique »
        // dans « asymétrique »).
        final whole = _isWhole(f.folded, at, w.length);
        score += whole ? f.weight * 2 : f.weight ~/ 4;
        final body = f.label == 'Titre' ? 0 : f.weight;
        if (body > bestWeight) {
          bestWeight = body;
          best = f;
          bestAt = at;
        }
      }
      if (!found) return null;
    }
    final f = best!;
    // Mot trouvé dans un titre de section : l'extrait le répéterait.
    final repeats = f.label == 'Titre' || f.text == f.label;
    return SearchHit(
      kind: doc.kind,
      title: doc.title,
      where: f.label,
      snippet: repeats ? '' : _snippet(f.text, bestAt),
      score: score,
      item: doc.item,
    );
  }

  static final _wordChar = RegExp(r'[a-z0-9]');

  static bool _isWhole(String s, int at, int len) {
    final before = at == 0 || !_wordChar.hasMatch(s[at - 1]);
    final end = at + len;
    return before && (end >= s.length || !_wordChar.hasMatch(s[end]));
  }

  /// Première occurrence, de préférence en mot entier.
  static int _find(String s, String w) {
    final first = s.indexOf(w);
    for (var at = first; at >= 0; at = s.indexOf(w, at + 1)) {
      if (_isWhole(s, at, w.length)) return at;
    }
    return first;
  }

  static String _snippet(
    String text,
    int at, {
    int before = 40,
    int after = 90,
  }) {
    var a = at - before, b = at + after;
    if (a < 0) a = 0;
    if (b > text.length) b = text.length;
    // Ne pas couper un mot.
    while (a > 0 && !RegExp(r'\s').hasMatch(text[a - 1])) {
      a--;
    }
    while (b < text.length && !RegExp(r'\s').hasMatch(text[b])) {
      b++;
    }
    final s = text.substring(a, b).replaceAll(RegExp(r'\s+'), ' ').trim();
    return '${a > 0 ? '… ' : ''}$s${b < text.length ? ' …' : ''}';
  }
}
