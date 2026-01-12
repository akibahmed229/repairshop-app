import 'package:fpdart/fpdart.dart';
import 'package:repair_shop/core/error/failure.dart';
import 'package:repair_shop/core/usecase/usecase.dart';
import 'package:repair_shop/features/chat/domain/entities/message_entity.dart';
import 'package:repair_shop/features/chat/domain/repository/chat_repository.dart';

class SendMessage implements Usecase<MessageEntity, SendMessageParams> {
  final ChatRepository chatRepository;
  const SendMessage({required this.chatRepository});

  @override
  Future<Either<Failure, MessageEntity>> call(SendMessageParams params) async {
    return await chatRepository.sendMessage(
      receiverId: params.receiverId,
      content: params.content,
    );
  }
}

class SendMessageParams {
  final String receiverId;
  final String content;
  const SendMessageParams({required this.receiverId, required this.content});
}
