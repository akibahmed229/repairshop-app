import 'package:fpdart/fpdart.dart';
import 'package:repair_shop/core/common/entities/user_entities.dart';
import 'package:repair_shop/core/error/failure.dart';
import 'package:repair_shop/core/usecase/usecase.dart';
import 'package:repair_shop/features/users/domain/repository/user_repository.dart';

class SignOutCurrentUser
    implements Usecase<UserEntities, SignOutCurrentUserParams> {
  final UserRepository userRepository;

  const SignOutCurrentUser({required this.userRepository});

  @override
  Future<Either<Failure, UserEntities>> call(
    SignOutCurrentUserParams params,
  ) async {
    return await userRepository.signOutUser(id: params.id);
  }
}

class SignOutCurrentUserParams {
  String id;

  SignOutCurrentUserParams({required this.id});
}
