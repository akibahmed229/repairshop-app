import 'package:fpdart/fpdart.dart';
import 'package:repair_shop/core/common/entities/user_entities.dart';
import 'package:repair_shop/core/error/failure.dart';
import 'package:repair_shop/core/usecase/usecase.dart';
import 'package:repair_shop/features/users/domain/repository/user_repository.dart';

class UpdateUser implements Usecase<UserEntities, UpdateUserParams> {
  final UserRepository userRepository;

  const UpdateUser({required this.userRepository});

  @override
  Future<Either<Failure, UserEntities>> call(UpdateUserParams params) async {
    return await userRepository.updateUser(
      id: params.id,
      name: params.name,
      email: params.email,
      password: params.password,
      roles: params.roles,
    );
  }
}

class UpdateUserParams {
  String id;
  String name;
  String email;
  String password;
  List<String> roles;

  UpdateUserParams({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.roles,
  });
}
