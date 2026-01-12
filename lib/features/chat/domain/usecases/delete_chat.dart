import 'package:fpdart/fpdart.dart';
import 'package:repair_shop/core/error/failure.dart';
import 'package:repair_shop/core/usecase/usecase.dart';
import 'package:repair_shop/features/chat/domain/repository/chat_repository.dart';

class DeleteChat implements Usecase<String, DeleteChatParams> {
  final ChatRepository chatRepository;
  const DeleteChat({required this.chatRepository});

  @override
  Future<Either<Failure, String>> call(DeleteChatParams params) async {
    return await chatRepository.deleteChat(params.id);
  }
}

class DeleteChatParams {
  final String id;
  const DeleteChatParams({required this.id});
}
