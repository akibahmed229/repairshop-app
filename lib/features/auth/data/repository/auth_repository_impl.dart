import 'package:repair_shop/core/common/entities/user_entities.dart';
import 'package:repair_shop/core/error/failure.dart';
import 'package:repair_shop/core/error/other_execptions.dart';
import 'package:repair_shop/core/error/server_execptions.dart';
import 'package:repair_shop/core/network/connection_checker.dart';
import 'package:repair_shop/core/utils/sp_service.dart';
import 'package:repair_shop/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:repair_shop/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:repair_shop/features/auth/domain/repository/auth_repository.dart';
import 'package:fpdart/fpdart.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource authRemoteDataSource;
  final AuthLocalDataSource authLocalDataSource;
  final ConnectionChecker connectionChecker;
  final SpService spService;

  const AuthRepositoryImpl({
    required this.authRemoteDataSource,
    required this.authLocalDataSource,
    required this.connectionChecker,
    required this.spService,
  });

  @override
  Future<Either<Failure, UserEntities>> signUpWithEmailPassword({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final user = await authRemoteDataSource.signUpWithEmailPassword(
        name: name,
        email: email,
        password: password,
      );
      return right(user);
    } on OtherExecptions catch (e) {
      // signup is strictly online, so show clean error
      return left(Failure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, UserEntities>> logInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      if (await connectionChecker.isConnected) {
        final user = await authRemoteDataSource.logInWithEmailPassword(
          email: email,
          password: password,
        );

        if (user.token?.isNotEmpty ?? false) {
          spService.setToken(user.token!);
          await authLocalDataSource.cacheUser(user);
        }
        return right(user);
      }
      // If not connected
      return _getCachedUserData(() => authLocalDataSource.getCachedUser());
    } on ServerExecptions catch (_) {
      return _getCachedUserData(() => authLocalDataSource.getCachedUser());
    } on OtherExecptions catch (e) {
      return left(Failure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, UserEntities>> currentUserData() async {
    try {
      if (await connectionChecker.isConnected) {
        final token = await spService.getToken();
        final userData = await authRemoteDataSource.currentUserData(token);

        if (userData == null) {
          return left(Failure(message: "User is not logged in"));
        }

        return right(userData);
      }
      // If not connected or no data returned
      return _getCachedUserData(() => authLocalDataSource.getCachedUser());
    } on ServerExecptions catch (_) {
      return _getCachedUserData(() => authLocalDataSource.getCachedUser());
    } on OtherExecptions catch (e) {
      return left(Failure(message: e.message));
    }
  }

  // ----------------- Helper Methods -----------------

  Future<Either<Failure, UserEntities>> _getCachedUserData(
    Future<UserEntities?> Function() fn,
  ) async {
    final cachedUser = await fn();
    if (cachedUser == null) {
      return left(Failure(message: "User not found"));
    }
    return right(cachedUser);
  }
}
