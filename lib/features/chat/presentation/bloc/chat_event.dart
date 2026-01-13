part of 'chat_bloc.dart';

@immutable
sealed class ChatEvent {}

// 1. Connection Management
class ChatConnectSocket extends ChatEvent {}

class ChatDisconnectSocket extends ChatEvent {}

// 2. User Search
class ChatSearchUsers extends ChatEvent {
  final String query;
  ChatSearchUsers(this.query);
}

// 3. Chat Room Actions
class ChatGetHistory extends ChatEvent {
  final String otherUserId;
  ChatGetHistory(this.otherUserId);
}

final class ChatConversations extends ChatEvent {
  final bool isSilent;

  // Default to false so normal behavior works as expected
  ChatConversations({this.isSilent = false});
}

class ChatSendMessage extends ChatEvent {
  final String receiverId;
  final String content;

  ChatSendMessage({required this.receiverId, required this.content});
}

class ChatDeleteMessage extends ChatEvent {
  final String messageId;
  ChatDeleteMessage(this.messageId);
}

// 4. Internal Event (Triggered by the Socket Stream)
class _ChatReceiveMessage extends ChatEvent {
  final MessageEntity message;
  _ChatReceiveMessage(this.message);
}
