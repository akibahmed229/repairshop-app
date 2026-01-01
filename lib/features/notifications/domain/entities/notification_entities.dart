class NotificationEntities {
  final String id;
  final String userId;
  final String title;
  final String body;
  final String type;
  final String? noteId;
  final bool isRead;
  final DateTime? createdAt;

  const NotificationEntities({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.type,
    this.noteId,
    required this.isRead,
    this.createdAt,
  });
}
