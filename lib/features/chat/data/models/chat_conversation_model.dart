import 'package:repair_shop/features/chat/domain/entities/chat_conversation_entity.dart';

class ChatConversationModel extends ChatConversationEntity {
  ChatConversationModel({
    required super.id,
    required super.otherUserId,
    required super.otherUserName,
    required super.lastMessage,
    required super.createdAt,
    super.unreadCount,
  });

  factory ChatConversationModel.fromJson(Map<String, dynamic> json) {
    return ChatConversationModel(
      id: json['id'] ?? '',
      otherUserId: json['otherUserId'] ?? '',
      otherUserName: json['otherUserName'] ?? 'Unknown',
      lastMessage: json['lastMessage'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
      unreadCount: json['unreadCount'] ?? 0,
    );
  }

  // Helper to convert Model to Entity
  ChatConversationEntity toEntity() {
    return ChatConversationEntity(
      id: id,
      otherUserId: otherUserId,
      otherUserName: otherUserName,
      lastMessage: lastMessage,
      createdAt: createdAt,
      unreadCount: unreadCount,
    );
  }

  ChatConversationModel copyWith({
    String? id,
    String? otherUserId,
    String? otherUserName,
    String? lastMessage,
    DateTime? time,
    int? unreadCount,
  }) {
    return ChatConversationModel(
      id: id ?? this.id,
      otherUserId: otherUserId ?? this.otherUserId,
      otherUserName: otherUserName ?? this.otherUserName,
      lastMessage: lastMessage ?? this.lastMessage,
      createdAt: createdAt ?? this.createdAt,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "otherUserId": otherUserId,
      "otherUserName": otherUserName,
      "lastMessage": lastMessage,
      "createdAt": createdAt.toIso8601String(),
      "unreadCount": unreadCount,
      "isSynced": 1,
    };
  }
}
