import 'package:fpdart/fpdart.dart';
import 'package:repair_shop/core/error/failure.dart';
import 'package:repair_shop/core/usecase/usecase.dart';
import 'package:repair_shop/features/chat/domain/entities/message_entity.dart';
import 'package:repair_shop/features/chat/domain/repository/chat_repository.dart';

class GetChatHistory
    implements Usecase<List<MessageEntity>, GetChatHistoryParams> {
  final ChatRepository chatRepository;
  const GetChatHistory({required this.chatRepository});

  @override
  Future<Either<Failure, List<MessageEntity>>> call(
    GetChatHistoryParams params,
  ) async {
    return await chatRepository.getChatHistory(params.otherUserId);
  }
}

class GetChatHistoryParams {
  final String otherUserId;
  const GetChatHistoryParams({required this.otherUserId});
}
