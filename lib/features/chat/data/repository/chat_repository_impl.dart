import 'package:fpdart/fpdart.dart';
import 'package:repair_shop/core/common/entities/user_entities.dart';
import 'package:repair_shop/core/error/failure.dart';
import 'package:repair_shop/core/error/server_execptions.dart';
import 'package:repair_shop/core/network/connection_checker.dart';
import 'package:repair_shop/core/utils/sp_service.dart';
import 'package:repair_shop/features/chat/data/datasources/chat_local_source.dart';
import 'package:repair_shop/features/chat/data/datasources/chat_remote_data_source.dart';
import 'package:repair_shop/features/chat/data/datasources/chat_socket_service.dart';
import 'package:repair_shop/features/chat/data/models/message_model.dart';
import 'package:repair_shop/features/chat/domain/entities/chat_conversation_entity.dart';
import 'package:repair_shop/features/chat/domain/entities/message_entity.dart';
import 'package:repair_shop/features/chat/domain/repository/chat_repository.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource chatRemoteDataSource;
  final ChatLocalSource chatLocalSource;
  final ChatSocketService socketService;
  final ConnectionChecker connectionChecker;
  final SpService spService;

  ChatRepositoryImpl({
    required this.chatRemoteDataSource,
    required this.chatLocalSource,
    required this.socketService,
    required this.connectionChecker,
    required this.spService,
  });

  @override
  Future<Either<Failure, Stream<MessageEntity>>> get messageStream async {
    try {
      if (await connectionChecker.isConnected) {
        final token = await spService.getToken();
        final myUserId = await chatLocalSource.getUserIdByToken(token!);

        final streamOfMessages = socketService.messageStream.map((data) {
          try {
            return MessageModel.fromJson(data, myUserId);
          } catch (e) {
            throw Exception("Model parsing failed");
          }
        });

        return right(streamOfMessages);
      } else {
        return left(Failure(message: "No Internet Connection"));
      }
    } on ServerExecptions catch (e) {
      return left(Failure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, Unit>> connectSocket() async {
    try {
      if (await connectionChecker.isConnected) {
        final token = await spService.getToken();
        final userId = await chatLocalSource.getUserIdByToken(token!);

        socketService.connect(userId, '');

        return right(unit);
      } else {
        return left(Failure(message: "No Internet Connection"));
      }
    } on ServerExecptions catch (e) {
      return left(Failure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, Unit>> disconnectSocket() async {
    try {
      if (await connectionChecker.isConnected) {
        socketService.diconnect();

        return right(unit);
      } else {
        return left(Failure(message: "No Internet Connection"));
      }
    } on ServerExecptions catch (e) {
      return left(Failure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, List<UserEntities>>> searchUsers(String query) async {
    try {
      if (await connectionChecker.isConnected) {
        final token = await spService.getToken();
        // Check if token is null safely
        if (token == null) {
          return left(Failure(message: "User is not authenticated"));
        }
        final users = await chatRemoteDataSource.searchUsers(query, token);

        if (users.isEmpty) {
          return left(Failure(message: "No users found"));
        }

        return right(users);
      } else {
        return left(Failure(message: "No Internet Connection"));
      }
    } on ServerExecptions catch (e) {
      return left(Failure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, MessageEntity>> sendMessage({
    required String receiverId,
    required String content,
  }) async {
    try {
      if (await connectionChecker.isConnected) {
        final token = await spService.getToken();
        if (token == null) return left(Failure(message: "Not authenticated"));

        final myUserId = await chatLocalSource.getUserIdByToken(token);

        final message = await chatRemoteDataSource.sendMessage(
          receiverId: receiverId,
          content: content,
          myUserId: myUserId,
          token: token,
        );

        return right(message);
      } else {
        return left(Failure(message: "No Internet Connection"));
      }
    } on ServerExecptions catch (e) {
      return left(Failure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, List<MessageEntity>>> getChatHistory(
    String otherUserId,
  ) async {
    try {
      if (await connectionChecker.isConnected) {
        final token = await spService.getToken();
        if (token == null) return left(Failure(message: "Not authenticated"));

        final myUserId = await chatLocalSource.getUserIdByToken(token);

        final chatHistory = await chatRemoteDataSource.getChatHistory(
          otherUserId,
          myUserId,
          token,
        );

        if (chatHistory.isEmpty) {
          return Left(Failure(message: "Failed to get chat history"));
        }

        return right(chatHistory);
      } else {
        return left(Failure(message: "No Internet Connection"));
      }
    } on ServerExecptions catch (e) {
      return left(Failure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, List<ChatConversationEntity>>>
  getAllConversations() async {
    try {
      if (await connectionChecker.isConnected) {
        final token = await spService.getToken();
        if (token == null) return left(Failure(message: "Not authenticated"));

        final conversations = await chatRemoteDataSource.getAllConversations(
          token,
        );

        if (conversations.isEmpty) {
          return Left(Failure(message: "Failed to get conversations"));
        }

        return right(conversations);
      } else {
        return left(Failure(message: "No Internet Connection"));
      }
    } on ServerExecptions catch (e) {
      return left(Failure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, String>> deleteChat(String id) async {
    try {
      if (await connectionChecker.isConnected) {
        final token = await spService.getToken();

        final deletedUser = await chatRemoteDataSource.deleteChat(id, token!);

        if (deletedUser.isEmpty) {
          return Left(
            Failure(
              message: "Failed to delete chat history something went wrong",
            ),
          );
        }

        return right(deletedUser);
      } else {
        return Left(Failure(message: "Failed to delete chat history"));
      }
    } on ServerExecptions catch (e) {
      return left(Failure(message: e.message));
    }
  }
}
