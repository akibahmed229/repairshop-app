import 'package:fpdart/fpdart.dart';
import 'package:repair_shop/core/common/entities/user_entities.dart';
import 'package:repair_shop/core/error/failure.dart';
import 'package:repair_shop/core/error/other_execptions.dart';
import 'package:repair_shop/core/error/server_execptions.dart';
import 'package:repair_shop/core/network/connection_checker.dart';
import 'package:repair_shop/features/users/data/datasources/user_local_data_source.dart';
import 'package:repair_shop/features/users/data/datasources/user_remote_data_source.dart';
import 'package:repair_shop/features/users/domain/repository/user_repository.dart';

class UserRepositoryImpl implements UserRepository {
  final UserRemoteDataSource userRemoteDataSource;
  final UserLocalDataSource userLocalDataSource;
  final ConnectionChecker connectionChecker;

  const UserRepositoryImpl({
    required this.userRemoteDataSource,
    required this.userLocalDataSource,
    required this.connectionChecker,
  });

  @override
  Future<Either<Failure, List<UserEntities>>> getAllUsers() async {
    try {
      if (await connectionChecker.isConnected) {
        final users = await userRemoteDataSource.getAllUsers();

        if (users.isEmpty) {
          return left(Failure(message: "No note users exist"));
        }

        return right(users);
      } else {
        return left(Failure(message: "No Internet Connection!!!"));
      }
    } on ServerExecptions catch (e) {
      return left(Failure(message: e.message));
    } on OtherExecptions catch (e) {
      return left(Failure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, UserEntities>> createNewUser({
    required String name,
    required String email,
    required String password,
    required List<String> roles,
  }) async {
    try {
      if (await connectionChecker.isConnected) {
        final user = await userRemoteDataSource.createNewUser(
          name: name,
          email: email,
          password: password,
          roles: roles,
        );

        return right(user);
      } else {
        return left(Failure(message: "No Internet Connection!!!"));
      }
    } on ServerExecptions catch (e) {
      return left(Failure(message: e.message));
    } on OtherExecptions catch (e) {
      return left(Failure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, UserEntities>> updateUser({
    required String id,
    required String name,
    required String email,
    required String password,
    required List<String> roles,
  }) async {
    try {
      if (await connectionChecker.isConnected) {
        final user = await userRemoteDataSource.updateUser(
          id: id,
          name: name,
          email: email,
          password: password,
          roles: roles,
        );

        return right(user);
      } else {
        return left(Failure(message: "No Internet Connection!!!"));
      }
    } on ServerExecptions catch (e) {
      return left(Failure(message: e.message));
    } on OtherExecptions catch (e) {
      return left(Failure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, String>> deleteUser({required String id}) async {
    try {
      if (await connectionChecker.isConnected) {
        final user = await userRemoteDataSource.deleteUser(id: id);

        return right(user);
      } else {
        return left(Failure(message: "No Internet Connection!!!"));
      }
    } on ServerExecptions catch (e) {
      return left(Failure(message: e.message));
    } on OtherExecptions catch (e) {
      return left(Failure(message: e.message));
    }
  }
}
