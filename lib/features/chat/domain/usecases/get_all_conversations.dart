import 'package:fpdart/fpdart.dart';
import 'package:repair_shop/core/error/failure.dart';
import 'package:repair_shop/core/usecase/usecase.dart';
import 'package:repair_shop/features/chat/domain/entities/chat_conversation_entity.dart';
import 'package:repair_shop/features/chat/domain/repository/chat_repository.dart';

class GetAllConversations
    implements Usecase<List<ChatConversationEntity>, NoParams> {
  final ChatRepository chatRepository;
  const GetAllConversations({required this.chatRepository});

  @override
  Future<Either<Failure, List<ChatConversationEntity>>> call(
    NoParams params,
  ) async {
    return await chatRepository.getAllConversations();
  }
}
