import 'package:repair_shop/features/chat/domain/entities/message_entity.dart';

class MessageModel extends MessageEntity {
  MessageModel({
    required super.id,
    required super.senderId,
    required super.receiverId,
    required super.content,
    required super.createdAt,
    required super.isMine,
  });

  factory MessageModel.fromJson(Map<String, dynamic> map, String myUserId) {
    return MessageModel(
      id: map['id'] ?? '',
      senderId: map['senderId'] ?? '',
      receiverId: map['receiverId'] ?? '',
      content: map['content'] ?? '',
      createdAt: DateTime.parse(map['createdAt']),
      isMine: map['senderId'] == myUserId,
    );
  }
}
