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

  factory Note.fromJson(Map<String, dynamic> j) => Note(
    id: j['id'] ?? '',
    title: j['title'] ?? '',
    content: j['content'] ?? '',
    category: j['category'] ?? 'Général',
    favorite: j['favorite'] ?? false,
    createdAt: DateTime.tryParse(j['createdAt'] ?? '') ?? DateTime.now(),
    updatedAt: DateTime.tryParse(j['updatedAt'] ?? '') ?? DateTime.now(),
  );
}
