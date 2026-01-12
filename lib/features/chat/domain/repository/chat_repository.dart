import 'package:fpdart/fpdart.dart';
import 'package:repair_shop/core/common/entities/user_entities.dart';
import 'package:repair_shop/core/error/failure.dart';
import 'package:repair_shop/features/chat/domain/entities/message_entity.dart';

abstract class ChatRepository {
  // Socket Connection
  Future<Either<Failure, Unit>> connectSocket();
  Future<Either<Failure, Unit>> disconnectSocket();
  Future<Either<Failure, Stream<MessageEntity>>>
  get messageStream; // Listen for incoming messages

  // API Actions
  Future<Either<Failure, List<UserEntities>>> searchUsers(String query);
  Future<Either<Failure, MessageEntity>> sendMessage({
    required String receiverId,
    required String content,
  });
  Future<Either<Failure, List<MessageEntity>>> getChatHistory(
    String otherUserId,
  );

  Future<Either<Failure, String>> deleteChat(String id);
}
