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
  bool _isFetching = false;

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
       super(const ChatState()) {
    on<ChatConnectSocket>(_onConnectSocket);
    on<ChatDisconnectSocket>(_onDisconnectSocket);
    on<ChatSearchUsers>(_onSearchUsers);
    on<ChatGetHistory>(_onGetHistory);
    on<ChatConversations>(_onChatConversations);
    on<ChatSendMessage>(_onSendMessage);
    on<ChatDeleteMessage>(_onDeleteMessage);
    on<_ChatReceiveMessage>(_onReceiveMessage);
  }

  // 1. Socket Connection
  void _onConnectSocket(
    ChatConnectSocket event,
    Emitter<ChatState> emit,
  ) async {
    if (_socketSubscription != null) return;

    final result = await _connectChatSocket.call(NoParams());

    await result.fold(
      (l) async => emit(
        state.copyWith(status: ChatStatus.failure, errorMessage: l.message),
      ),
      (r) async {
        final streamResult = await _getMessageStream.call(NoParams());
        streamResult.fold(
          (l) => emit(
            state.copyWith(status: ChatStatus.failure, errorMessage: l.message),
          ),
          (stream) {
            _socketSubscription?.cancel();
            _socketSubscription = stream.listen(
              (message) => add(_ChatReceiveMessage(message)),
            );
          },
        );
      },
    );
  }

  // 2. Search Users
  void _onSearchUsers(ChatSearchUsers event, Emitter<ChatState> emit) async {
    emit(state.copyWith(status: ChatStatus.loading));
    final res = await _searchUsers.call(SearchUsersParams(query: event.query));

    res.fold(
      (l) => emit(
        state.copyWith(status: ChatStatus.failure, errorMessage: l.message),
      ),
      (r) => emit(state.copyWith(status: ChatStatus.success, users: r)),
    );
  }

  // 3. Load Chat History
  void _onGetHistory(ChatGetHistory event, Emitter<ChatState> emit) async {
    emit(state.copyWith(status: ChatStatus.loading));
    final res = await _getChatHistory.call(
      GetChatHistoryParams(otherUserId: event.otherUserId),
    );

    res.fold(
      (l) => emit(
        state.copyWith(status: ChatStatus.failure, errorMessage: l.message),
      ),
      (r) => emit(state.copyWith(status: ChatStatus.success, messages: r)),
    );
  }

  // 4. All Conversations List
  void _onChatConversations(
    ChatConversations event,
    Emitter<ChatState> emit,
  ) async {
    if (_isFetching) return;
    _isFetching = true;

    try {
      if (!event.isSilent) emit(state.copyWith(status: ChatStatus.loading));

      final res = await _getAllConversations.call(NoParams());
      res.fold(
        (l) => emit(
          state.copyWith(status: ChatStatus.failure, errorMessage: l.message),
        ),
        (conversations) => emit(
          state.copyWith(
            status: ChatStatus.success,
            conversations: conversations,
          ),
        ),
      );
    } finally {
      _isFetching = false;
    }
  }

  // 5. Send Message (Optimistic Update)
  void _onSendMessage(ChatSendMessage event, Emitter<ChatState> emit) async {
    final res = await _sendMessage.call(
      SendMessageParams(receiverId: event.receiverId, content: event.content),
    );

    res.fold(
      (l) => emit(
        state.copyWith(status: ChatStatus.failure, errorMessage: l.message),
      ),
      (newMessage) {
        // Append new message to existing messages list
        final updatedMessages = [newMessage, ...state.messages];
        emit(
          state.copyWith(
            status: ChatStatus.actionSuccess,
            messages: updatedMessages,
          ),
        );
      },
    );
  }

  // 6. Receive Real-time Message
  void _onReceiveMessage(_ChatReceiveMessage event, Emitter<ChatState> emit) {
    // Check if message belongs to current room to avoid injecting wrong messages
    bool isRelevant =
        state.messages.isEmpty ||
        event.message.senderId == state.messages.first.receiverId ||
        event.message.senderId == state.messages.first.senderId;

    List<MessageEntity> updatedMessages = state.messages;
    if (isRelevant) {
      updatedMessages = [event.message, ...state.messages];
    }

    // Always refresh conversations silently when a message arrives
    add(ChatConversations(isSilent: true));

    emit(state.copyWith(status: ChatStatus.success, messages: updatedMessages));
  }

  // 7. Delete Message
  void _onDeleteMessage(
    ChatDeleteMessage event,
    Emitter<ChatState> emit,
  ) async {
    final res = await _deleteChat.call(DeleteChatParams(id: event.messageId));

    res.fold(
      (l) => emit(
        state.copyWith(status: ChatStatus.failure, errorMessage: l.message),
      ),
      (r) {
        final updatedList = state.messages
            .where((msg) => msg.id != event.messageId)
            .toList();
        emit(
          state.copyWith(
            status: ChatStatus.actionSuccess,
            messages: updatedList,
          ),
        );
      },
    );
  }

  // 8. Cleanup
  void _onDisconnectSocket(
    ChatDisconnectSocket event,
    Emitter<ChatState> emit,
  ) async {
    _socketSubscription?.cancel();
    _socketSubscription = null;
    await _disconnectChatSocket.call(NoParams());
    emit(state.copyWith(status: ChatStatus.initial));
  }

  @override
  Future<void> close() {
    _socketSubscription?.cancel();
    return super.close();
  }
}
