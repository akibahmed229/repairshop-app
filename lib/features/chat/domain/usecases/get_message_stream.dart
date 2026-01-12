import 'package:fpdart/fpdart.dart';
import 'package:repair_shop/core/error/failure.dart';
import 'package:repair_shop/core/usecase/usecase.dart';
import 'package:repair_shop/features/chat/domain/entities/message_entity.dart';
import 'package:repair_shop/features/chat/domain/repository/chat_repository.dart';

class GetMessageStream implements Usecase<Stream<MessageEntity>, NoParams> {
  final ChatRepository repository;
  GetMessageStream(this.repository);

  @override
  Future<Either<Failure, Stream<MessageEntity>>> call(NoParams params) async {
    return await repository.messageStream;
  }
}
