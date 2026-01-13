import 'package:repair_shop/features/chat/domain/entities/chat_conversation_entity.dart';

class ChatConversationModel extends ChatConversationEntity {
  ChatConversationModel({
    required super.otherUserId,
    required super.otherUserName,
    required super.lastMessage,
    required super.time,
    super.unreadCount,
  });

  factory ChatConversationModel.fromJson(Map<String, dynamic> json) {
    return ChatConversationModel(
      otherUserId: json['otherUserId'] ?? '',
      otherUserName: json['otherUserName'] ?? 'Unknown',
      lastMessage: json['lastMessage'] ?? '',
      time: json['time'] != null
          ? DateTime.parse(json['time'])
          : DateTime.now(),
      unreadCount: json['unreadCount'] ?? 0,
    );
  }

  // Helper to convert Model to Entity
  ChatConversationEntity toEntity() {
    return ChatConversationEntity(
      otherUserId: otherUserId,
      otherUserName: otherUserName,
      lastMessage: lastMessage,
      time: time,
      unreadCount: unreadCount,
    );
  }
}
