import 'package:repair_shop/features/notifications/domain/entities/notification_entities.dart';

class NotificationModel extends NotificationEntities {
  const NotificationModel({
    required super.id,
    required super.userId,
    required super.title,
    required super.body,
    required super.type,
    super.noteId,
    required super.isRead,
    super.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['notification_id'] ?? json['id'],
      userId: json['user_id'] ?? '',
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      type: json['type'] ?? 'task_assigned',
      noteId: json['note_id'],
      isRead: json['is_read'] ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }
}
