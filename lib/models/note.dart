class Note {
  final String id;
  String title;
  String content;
  String category;
  bool favorite;
  final DateTime createdAt;
  DateTime updatedAt;

  Note({
    required this.id,
    required this.title,
    required this.content,
    this.category = 'Général',
    this.favorite = false,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'content': content,
    'category': category,
    'favorite': favorite,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  /// Lecture tolérante : un champ de type inattendu est converti ou remplacé
  /// par sa valeur par défaut au lieu de faire échouer tout le chargement.
  factory Note.fromJson(Map<String, dynamic> j) {
    String str(Object? v, String fallback) =>
        v == null ? fallback : (v is String ? v : '$v');
    DateTime date(Object? v) =>
        (v is String ? DateTime.tryParse(v) : null) ?? DateTime.now();
    return Note(
      id: str(j['id'], ''),
      title: str(j['title'], ''),
      content: str(j['content'], ''),
      category: str(j['category'], 'Général'),
      favorite: j['favorite'] == true,
      createdAt: date(j['createdAt']),
      updatedAt: date(j['updatedAt']),
    );
  }
}
