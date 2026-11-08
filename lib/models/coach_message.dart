/// Message affiché dans le CyberCoach.
///
/// - `user` : question de l'apprenant ;
/// - `assistant` : réponse réellement générée par le modèle configuré ;
/// - `notice` : information de l'application (mode hors ligne, erreur…),
///   jamais présentée comme une génération IA ni transmise au fournisseur.
enum CoachRole { user, assistant, notice }

class CoachMessage {
  final CoachRole role;
  final String text;
  final DateTime at;

  CoachMessage(this.role, this.text, {DateTime? at})
    : at = at ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'role': role.name,
    'text': text,
    'at': at.toIso8601String(),
  };

  static CoachMessage? fromJson(Map<String, dynamic> j) {
    final role = CoachRole.values.where((r) => r.name == j['role']).firstOrNull;
    final text = j['text'];
    if (role == null || text is! String) return null;
    return CoachMessage(
      role,
      text,
      at: DateTime.tryParse('${j['at']}') ?? DateTime.now(),
    );
  }
}
