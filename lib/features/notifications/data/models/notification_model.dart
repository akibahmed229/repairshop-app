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
    required super.createdAt,
    super.isSynced,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'],
      userId: json['userId'] ?? '',
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      type: json['type'] ?? 'task_assigned',
      noteId: json['noteId'],
      isRead: json['isRead'] is int
          ? json["isRead"] == 1
          : json["isRead"] == true,
      createdAt: DateTime.parse(json['createdAt']),
      isSynced: json['isSynced'] == 1 || json['isSynced'] == true,
    );
  }

  NotificationModel copyWith({
    String? id,
    String? userId,
    String? title,
    String? body,
    String? type,
    String? noteId,
    bool? isRead,
    DateTime? createdAt,
    bool? isSynced,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      noteId: noteId ?? this.noteId,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      isSynced: isSynced ?? this.isSynced,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "userId": userId,
      "title": title,
      "body": body,
      "type": type,
      "noteId": noteId,
      "isRead": isRead ? 1 : 0,
      "createdAt": createdAt.toIso8601String(),
      "isSynced": (isSynced ?? false) ? 1 : 0,
    };
  }
}
