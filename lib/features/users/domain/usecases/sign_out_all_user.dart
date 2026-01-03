import 'package:fpdart/fpdart.dart';
import 'package:repair_shop/core/error/failure.dart';
import 'package:repair_shop/core/usecase/usecase.dart';
import 'package:repair_shop/features/users/domain/repository/user_repository.dart';

class SignOutAllUser implements Usecase<bool, NoParams> {
  final UserRepository userRepository;

  const SignOutAllUser({required this.userRepository});

  @override
  Future<Either<Failure, bool>> call(NoParams params) async {
    return await userRepository.signOutAllUser();
  }
}
