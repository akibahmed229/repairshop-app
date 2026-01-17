part of 'chat_bloc.dart';

enum ChatStatus {
  initial,
  loading,
  success,
  failure,
  actionSuccess, // For things like "Message Sent" or "Chat Deleted"
}

final class ChatState {
  final ChatStatus status;
  final List<ChatConversationEntity> conversations;
  final List<MessageEntity> messages; // Current chat room messages
  final List<UserEntities> users; // Search results
  final String? errorMessage;

  const ChatState({
    this.status = ChatStatus.initial,
    this.conversations = const [],
    this.messages = const [],
    this.users = const [],
    this.errorMessage,
  });

  ChatState copyWith({
    ChatStatus? status,
    List<ChatConversationEntity>? conversations,
    List<MessageEntity>? messages,
    List<UserEntities>? users,
    String? errorMessage,
  }) {
    return ChatState(
      status: status ?? this.status,
      conversations: conversations ?? this.conversations,
      messages: messages ?? this.messages,
      users: users ?? this.users,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
