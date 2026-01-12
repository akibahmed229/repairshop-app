// domain/usecases/connect_chat_socket.dart
import 'package:fpdart/fpdart.dart';
import 'package:repair_shop/core/error/failure.dart';
import 'package:repair_shop/core/usecase/usecase.dart';
import 'package:repair_shop/features/chat/domain/repository/chat_repository.dart';

class DisconnectChatSocket implements Usecase<Unit, NoParams> {
  final ChatRepository repository;
  DisconnectChatSocket(this.repository);

  @override
  Future<Either<Failure, Unit>> call(NoParams params) async {
    return await repository.disconnectSocket();
  }
}
