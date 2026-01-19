class ChatConversationEntity {
  final String id;
  final String otherUserId;
  final String otherUserName;
  final String lastMessage;
  final DateTime createdAt;
  final int unreadCount;

  ChatConversationEntity({
    required this.id,
    required this.otherUserId,
    required this.otherUserName,
    required this.lastMessage,
    required this.createdAt,
    this.unreadCount = 0,
  });
}
