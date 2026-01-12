import 'package:fpdart/fpdart.dart';
import 'package:repair_shop/core/error/failure.dart';
import 'package:repair_shop/core/usecase/usecase.dart';
import 'package:repair_shop/features/chat/domain/repository/chat_repository.dart';

// 1. Change the return type to Unit
class ConnectChatSocket implements Usecase<Unit, NoParams> {
  final ChatRepository chatRepository;
  ConnectChatSocket(this.chatRepository);

  @override
  Future<Either<Failure, Unit>> call(NoParams params) async {
    return await chatRepository.connectSocket();
  }
}
