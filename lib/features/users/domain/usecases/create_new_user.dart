import 'package:fpdart/fpdart.dart';
import 'package:repair_shop/core/common/entities/user_entities.dart';
import 'package:repair_shop/core/error/failure.dart';
import 'package:repair_shop/core/usecase/usecase.dart';
import 'package:repair_shop/features/users/domain/repository/user_repository.dart';

class CreateNewUser implements Usecase<UserEntities, CreateNewUserParams> {
  final UserRepository userRepository;

  const CreateNewUser({required this.userRepository});

  @override
  Future<Either<Failure, UserEntities>> call(CreateNewUserParams params) async {
    return await userRepository.createNewUser(
      name: params.name,
      email: params.email,
      password: params.password,
      roles: params.roles,
    );
  }
}

class CreateNewUserParams {
  String name;
  String email;
  String password;
  List<String> roles;

  CreateNewUserParams({
    required this.name,
    required this.email,
    required this.password,
    required this.roles,
  });
}
