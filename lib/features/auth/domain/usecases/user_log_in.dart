import 'package:fpdart/fpdart.dart';
import 'package:repair_shop/core/common/entities/user_entities.dart';
import 'package:repair_shop/core/error/failure.dart';
import 'package:repair_shop/core/usecase/usecase.dart';
import 'package:repair_shop/features/auth/domain/repository/auth_repository.dart';

class UserLogIn implements Usecase<UserEntities, UserLoginParams> {
  final AuthRepository authRepository;
  const UserLogIn({required this.authRepository});

  @override
  Future<Either<Failure, UserEntities>> call(UserLoginParams params) async {
    return await authRepository.logInWithEmailPassword(
      email: params.email,
      password: params.password,
    );
  }
}

class UserLoginParams {
  String email;
  String password;

  UserLoginParams({required this.email, required this.password});
}
