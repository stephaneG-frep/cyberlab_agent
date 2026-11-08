/// Comparaison prudente des réponses libres (quiz et CTF).
///
/// Règles :
/// - les espaces de début/fin sont ignorés ;
/// - les suites d'espaces HORS guillemets sont réduites à un seul espace
///   (à l'intérieur de guillemets, les espaces sont significatifs) ;
/// - la casse est ignorée sauf si [caseSensitive] est vrai (commandes Linux,
///   par exemple, où `LS` n'est pas `ls`) ;
/// - seules les variantes explicitement listées sont acceptées : aucune
///   équivalence entre commandes n'est déduite automatiquement.
class AnswerMatcher {
  AnswerMatcher._();

  static String normalize(String input, {bool caseSensitive = false}) {
    final buf = StringBuffer();
    String? quote;
    var pendingSpace = false;
    for (final ch in input.trim().split('')) {
      if (quote != null) {
        buf.write(ch);
        if (ch == quote) quote = null;
        continue;
      }
      if (ch == ' ' || ch == '\t' || ch == '\n' || ch == '\r') {
        pendingSpace = true;
        continue;
      }
      if (pendingSpace && buf.isNotEmpty) buf.write(' ');
      pendingSpace = false;
      if (ch == '"' || ch == "'") quote = ch;
      buf.write(ch);
    }
    final out = buf.toString();
    return caseSensitive ? out : out.toLowerCase();
  }

  static bool matches(
    String answer,
    String expected, {
    List<String> variants = const [],
    bool caseSensitive = false,
  }) {
    final given = normalize(answer, caseSensitive: caseSensitive);
    if (given.isEmpty) return false;
    for (final candidate in [expected, ...variants]) {
      if (candidate.trim().isEmpty) continue;
      if (normalize(candidate, caseSensitive: caseSensitive) == given) {
        return true;
      }
    }
    return false;
  }
}
