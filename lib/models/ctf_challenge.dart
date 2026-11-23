import 'answer_matcher.dart';

class CtfChallenge {
  final String id;
  final String title;
  final String
  category; // linux | web | réseau | crypto | forensic | scripting | logs | osint | pratique
  final String difficulty; // Très facile | Facile | Moyen | Difficile | Expert
  final int xp;
  final String objective;
  final String environment;
  final String puzzle;
  final List<String> hints;
  final String answer;
  final String explanation;

  /// Variantes explicitement acceptées (aucune équivalence implicite).
  final List<String> acceptedAnswers;

  /// Vrai pour les commandes : sous Linux, la casse est significative.
  final bool caseSensitive;

  /// Commande qui, tapée dans le terminal simulé du Lab (depuis le dossier
  /// personnel), affiche de quoi trouver la réponse. Montrée avec la
  /// solution ; les tests vérifient qu'elle fonctionne réellement.
  final String? terminalCommand;

  CtfChallenge({
    required this.id,
    required this.title,
    required this.category,
    required this.difficulty,
    required this.xp,
    required this.objective,
    required this.environment,
    required this.puzzle,
    required this.hints,
    required this.answer,
    required this.explanation,
    this.acceptedAnswers = const [],
    this.caseSensitive = false,
    this.terminalCommand,
  });

  bool isCorrect(String input) => AnswerMatcher.matches(
    input,
    answer,
    variants: acceptedAnswers,
    caseSensitive: caseSensitive,
  );

  int get difficultyRank {
    switch (difficulty) {
      case 'Très facile':
        return 1;
      case 'Facile':
        return 2;
      case 'Moyen':
        return 3;
      case 'Difficile':
        return 4;
      case 'Expert':
        return 5;
      default:
        return 3;
    }
  }
}
