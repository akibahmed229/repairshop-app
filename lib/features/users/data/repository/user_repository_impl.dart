import 'package:fpdart/fpdart.dart';
import 'package:repair_shop/core/common/entities/user_entities.dart';
import 'package:repair_shop/core/error/failure.dart';
import 'package:repair_shop/core/error/other_execptions.dart';
import 'package:repair_shop/core/error/server_execptions.dart';
import 'package:repair_shop/core/network/connection_checker.dart';
import 'package:repair_shop/core/utils/sp_service.dart';
import 'package:repair_shop/features/users/data/datasources/user_local_data_source.dart';
import 'package:repair_shop/features/users/data/datasources/user_remote_data_source.dart';
import 'package:repair_shop/features/users/domain/repository/user_repository.dart';

class UserRepositoryImpl implements UserRepository {
  final UserRemoteDataSource userRemoteDataSource;
  final UserLocalDataSource userLocalDataSource;
  final ConnectionChecker connectionChecker;
  final SpService spService;

  const UserRepositoryImpl({
    required this.userRemoteDataSource,
    required this.userLocalDataSource,
    required this.connectionChecker,
    required this.spService,
  });

  @override
  Future<Either<Failure, List<UserEntities>>> getAllUsers() async {
    try {
      if (await connectionChecker.isConnected) {
        final token = await spService.getToken();

        final users = await userRemoteDataSource.getAllUsers(token: token);

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
        final token = await spService.getToken();

        final user = await userRemoteDataSource.createNewUser(
          name: name,
          email: email,
          password: password,
          roles: roles,
          token: token,
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
        final token = await spService.getToken();

        final user = await userRemoteDataSource.updateUser(
          id: id,
          name: name,
          email: email,
          password: password,
          roles: roles,
          token: token,
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
        final token = await spService.getToken();

        final user = await userRemoteDataSource.deleteUser(
          id: id,
          token: token,
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
  Future<Either<Failure, List<UserEntities>>> getAllCachedUsers() async {
    try {
      final userList = await userLocalDataSource.getAllCachedUsers();

      if (userList.isEmpty) {
        return left(Failure(message: "No User Found"));
      }

      return right(userList.cast<UserEntities>());
    } on ServerExecptions catch (e) {
      return left(Failure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, UserEntities>> switchAccount({
    required String id,
  }) async {
    try {
      if (await connectionChecker.isConnected) {
        final user = await userLocalDataSource.getUserById(id);

        if (user == null) {
          return left(Failure(message: "Failed to switch user"));
        }

        await spService.setToken(user.token!);

        return right(user);
      } else {
        return left(Failure(message: "No Internet Connection!!!"));
      }
    } on ServerExecptions catch (e) {
      return left(Failure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, UserEntities>> signOutUser({
    required String id,
  }) async {
    try {
      if (await connectionChecker.isConnected) {
        await userLocalDataSource.logoutUser(id);

        final getUser = await userLocalDataSource.getFirstCachedUser();

        if (getUser == null) {
          await spService.setToken('');
          return left(Failure(message: "No User Exist! Please login."));
        }
        await spService.setToken(getUser.token!);

        return right(getUser);
      } else {
        return left(Failure(message: "No Internet Connection!!!"));
      }
    } on ServerExecptions catch (e) {
      return left(Failure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, bool>> signOutAllUser() async {
    try {
      if (await connectionChecker.isConnected) {
        await userLocalDataSource.logoutALlUser();

        await spService.setToken('');

        return right(true);
      } else {
        return left(Failure(message: "No Internet Connection!!!"));
      }
    } on ServerExecptions catch (e) {
      return left(Failure(message: e.message));
    }
  }
}
