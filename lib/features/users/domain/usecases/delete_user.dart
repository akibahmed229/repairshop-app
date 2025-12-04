import 'package:fpdart/fpdart.dart';
import 'package:repair_shop/core/error/failure.dart';
import 'package:repair_shop/core/usecase/usecase.dart';
import 'package:repair_shop/features/users/domain/repository/user_repository.dart';

class DeleteUser implements Usecase<String, DeleteUserParams> {
  final UserRepository userRepository;

  const DeleteUser({required this.userRepository});

  @override
  Future<Either<Failure, String>> call(DeleteUserParams params) async {
    return await userRepository.deleteUser(id: params.id);
  }
}

class DeleteUserParams {
  String id;

  DeleteUserParams({required this.id});
}
