import 'package:fpdart/fpdart.dart';
import 'package:repair_shop/core/common/entities/user_entities.dart';
import 'package:repair_shop/core/error/failure.dart';

abstract interface class UserRepository {
  Future<Either<Failure, List<UserEntities>>> getAllUsers();

  Future<Either<Failure, UserEntities>> createNewUser({
    required String name,
    required String email,
    required String password,
    required List<String> roles,
  });

  Future<Either<Failure, UserEntities>> updateUser({
    required String id,
    required String name,
    required String email,
    required String password,
    required List<String> roles,
  });

  Future<Either<Failure, String>> deleteUser({required String id});
}
