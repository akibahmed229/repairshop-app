import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:repair_shop/core/common/entities/user_entities.dart';
import 'package:repair_shop/core/usecase/usecase.dart';
import 'package:repair_shop/features/chat/domain/entities/chat_conversation_entity.dart';
import 'package:repair_shop/features/chat/domain/entities/message_entity.dart';
import 'package:repair_shop/features/chat/domain/usecases/connect_chat_socket.dart';
import 'package:repair_shop/features/chat/domain/usecases/delete_chat.dart';
import 'package:repair_shop/features/chat/domain/usecases/disconnect_chat_socket.dart';
import 'package:repair_shop/features/chat/domain/usecases/get_all_conversations.dart';
import 'package:repair_shop/features/chat/domain/usecases/get_chat_history.dart';
import 'package:repair_shop/features/chat/domain/usecases/get_message_stream.dart';
import 'package:repair_shop/features/chat/domain/usecases/search_users.dart';
import 'package:repair_shop/features/chat/domain/usecases/send_message.dart';

part 'chat_event.dart';
part 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ConnectChatSocket _connectChatSocket;
  final DisconnectChatSocket _disconnectChatSocket;
  final GetMessageStream _getMessageStream;
  final SearchUsers _searchUsers;
  final GetChatHistory _getChatHistory;
  final GetAllConversations _getAllConversations;
  final SendMessage _sendMessage;
  final DeleteChat _deleteChat;

  StreamSubscription<MessageEntity>? _socketSubscription;

  ChatBloc({
    required ConnectChatSocket connectChatSocket,
    required DisconnectChatSocket disconnectChatSocket,
    required GetMessageStream getMessageStream,
    required SearchUsers searchUsers,
    required GetChatHistory getChatHistory,
    required GetAllConversations getAllConversations,
    required SendMessage sendMessage,
    required DeleteChat deleteChat,
  }) : _connectChatSocket = connectChatSocket,
       _disconnectChatSocket = disconnectChatSocket,
       _getMessageStream = getMessageStream,
       _searchUsers = searchUsers,
       _getChatHistory = getChatHistory,
       _getAllConversations = getAllConversations,
       _sendMessage = sendMessage,
       _deleteChat = deleteChat,
       super(ChatInitial()) {
    on<ChatConnectSocket>(_onConnectSocket);
    on<ChatDisconnectSocket>(_onDisconnectSocket);
    on<ChatSearchUsers>(_onSearchUsers);
    on<ChatGetHistory>(_onGetHistory);
    on<ChatConversations>(_onChatConversations);
    on<ChatSendMessage>(_onSendMessage);
    on<ChatDeleteMessage>(_onDeleteMessage);
    on<_ChatReceiveMessage>(_onReceiveMessage);
  }

  // 1. Connect and Subscribe to Stream
  void _onConnectSocket(
    ChatConnectSocket event,
    Emitter<ChatState> emit,
  ) async {
    if (_socketSubscription != null) {
      return;
    }
    // Attempt connection
    final result = await _connectChatSocket.call(NoParams());

    result.fold((l) => emit(ChatFailure(l.message)), (r) async {
      // If connection successful, subscribe to the stream
      final streamResult = await _getMessageStream.call(NoParams());

      streamResult.fold((l) => emit(ChatFailure(l.message)), (stream) {
        _socketSubscription?.cancel();
        _socketSubscription = stream.listen((message) {
          add(_ChatReceiveMessage(message));
        });
      });
    });
  }

  // 2. Search Users
  void _onSearchUsers(ChatSearchUsers event, Emitter<ChatState> emit) async {
    emit(ChatLoading());
    final res = await _searchUsers.call(SearchUsersParams(query: event.query));

    res.fold(
      (l) => emit(ChatFailure(l.message)),
      (r) => emit(ChatUsersLoaded(r)),
    );
  }

  // 3. Load Chat History
  void _onGetHistory(ChatGetHistory event, Emitter<ChatState> emit) async {
    emit(ChatLoading());
    final res = await _getChatHistory.call(
      GetChatHistoryParams(otherUserId: event.otherUserId),
    );

    res.fold(
      (l) => emit(ChatFailure(l.message)),
      (r) => emit(ChatRoomLoaded(r)),
    );
  }

  void _onChatConversations(
    ChatConversations event,
    Emitter<ChatState> emit,
  ) async {
    // ONLY show loading if it's NOT a silent request
    if (!event.isSilent) {
      emit(ChatLoading());
    }

    final res = await _getAllConversations.call(NoParams());

    res.fold(
      (l) => emit(ChatFailure(l.message)),
      (conversations) => emit(ChatConversationsLoaded(conversations)),
    );
  }

  // 4. Send Message
  void _onSendMessage(ChatSendMessage event, Emitter<ChatState> emit) async {
    // We don't emit Loading here to prevent the UI from flickering.
    // We rely on the result to update the list or show error via SnackBar in UI.

    final res = await _sendMessage.call(
      SendMessageParams(receiverId: event.receiverId, content: event.content),
    );

    res.fold((l) => emit(ChatFailure(l.message)), (newMessage) {
      // If successful, append to current list
      if (state is ChatRoomLoaded) {
        final currentMessages = (state as ChatRoomLoaded).messages;
        emit(ChatRoomLoaded([newMessage, ...currentMessages]));
      }
    });
  }

  // 5. Receive Real-time Message (Internal)
  void _onReceiveMessage(_ChatReceiveMessage event, Emitter<ChatState> emit) {
    // Case 1: User is inside a Chat Room
    if (state is ChatRoomLoaded) {
      final currentState = state as ChatRoomLoaded;

      // OPTIONAL: Check if the message belongs to the current conversation
      // If you are chatting with User A, but User B sends a message,
      // you might not want to inject it into User A's chat room.
      final isRelevant =
          currentState.messages.isEmpty ||
          event.message.senderId == currentState.messages.first.receiverId ||
          event.message.senderId == currentState.messages.first.senderId;

      if (isRelevant) {
        emit(ChatRoomLoaded([event.message, ...currentState.messages]));
      }
    }

    // Case 2: User is looking at the Conversation List
    if (state is ChatConversationsLoaded) {
      // final currentList = (state as ChatConversationsLoaded).conversations;

      // You would need logic here to:
      // 1. Find the conversation this message belongs to
      // 2. Update its 'lastMessage' and 'time'
      // 3. Move it to index 0
      // 4. emit(ChatConversationsLoaded(newList));

      // For now, the easiest way is to just re-fetch the list silently:
      add(ChatConversations(isSilent: true));
    }
  }

  // 6. Delete Message
  void _onDeleteMessage(
    ChatDeleteMessage event,
    Emitter<ChatState> emit,
  ) async {
    final res = await _deleteChat.call(DeleteChatParams(id: event.messageId));

    res.fold((l) => emit(ChatFailure(l.message)), (r) {
      if (state is ChatRoomLoaded) {
        final currentMessages = (state as ChatRoomLoaded).messages;
        // Remove the message locally
        final updatedList = currentMessages
            .where((msg) => msg.id != event.messageId)
            .toList();
        emit(ChatRoomLoaded(updatedList));
      }
    });
  }

  // 7. Cleanup
  void _onDisconnectSocket(
    ChatDisconnectSocket event,
    Emitter<ChatState> emit,
  ) async {
    _socketSubscription?.cancel();
    final res = await _disconnectChatSocket.call(NoParams());

    res.fold(
      (failure) => emit(ChatFailure(failure.message)),
      (_) => emit(ChatDisconnected()),
    );
  }

  @override
  Future<void> close() {
    _socketSubscription?.cancel();
    return super.close();
  }
}
