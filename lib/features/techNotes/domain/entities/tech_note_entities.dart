class TechNoteEntities {
  final String id;
  final String userId;
  final String title;
  final String content;
  final bool completed;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? userName;
  final String? userEmail;
  final bool? isSynced;

  const TechNoteEntities({
    required this.id,
    required this.userId,
    required this.title,
    required this.content,
    required this.completed,
    required this.createdAt,
    required this.updatedAt,
    this.userName,
    this.userEmail,
    this.isSynced,
  });
}
