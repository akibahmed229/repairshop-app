part of 'chat_bloc.dart';

@immutable
sealed class ChatState {}

final class ChatInitial extends ChatState {}

final class ChatLoading extends ChatState {}

final class ChatFailure extends ChatState {
  final String error;
  ChatFailure(this.error);
}

// State when "Search Page" has results
final class ChatUsersLoaded extends ChatState {
  final List<UserEntities> users;
  ChatUsersLoaded(this.users);
}

final class ChatConversationsLoaded extends ChatState {
  final List<ChatConversationEntity> conversations;

  ChatConversationsLoaded(this.conversations);
}

// State when "Chat Room Page" is active
final class ChatRoomLoaded extends ChatState {
  final List<MessageEntity> messages;

  // We keep track of the messages list here.
  // Note: Optimistic updates will modify this list directly.
  ChatRoomLoaded(this.messages);
}

final class ChatDisconnected extends ChatState {}
