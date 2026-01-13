class ChatConversationEntity {
  final String otherUserId;
  final String otherUserName;
  final String lastMessage;
  final DateTime time;
  final int unreadCount;

  ChatConversationEntity({
    required this.otherUserId,
    required this.otherUserName,
    required this.lastMessage,
    required this.time,
    this.unreadCount = 0,
  });
}
