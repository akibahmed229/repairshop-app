import 'package:fpdart/fpdart.dart';
import 'package:repair_shop/core/common/entities/user_entities.dart';
import 'package:repair_shop/core/error/failure.dart';
import 'package:repair_shop/core/usecase/usecase.dart';
import 'package:repair_shop/features/chat/domain/repository/chat_repository.dart';

class SearchUsers implements Usecase<List<UserEntities>, SearchUsersParams> {
  final ChatRepository chatRepository;
  const SearchUsers({required this.chatRepository});

  @override
  Future<Either<Failure, List<UserEntities>>> call(
    SearchUsersParams params,
  ) async {
    return await chatRepository.searchUsers(params.query);
  }
}

class SearchUsersParams {
  final String query;
  const SearchUsersParams({required this.query});
}
