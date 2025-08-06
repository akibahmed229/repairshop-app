import 'package:repair_shop/core/common/entities/user_entities.dart';
import 'package:repair_shop/core/error/failure.dart';
import 'package:repair_shop/core/error/server_execptions.dart';
import 'package:repair_shop/core/utils/sp_service.dart';
import 'package:repair_shop/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:repair_shop/features/auth/domain/repository/auth_repository.dart';
import 'package:fpdart/fpdart.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource authRemoteDataSource;
  final SpService spService;
  const AuthRepositoryImpl({
    required this.authRemoteDataSource,
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
    } on ServerExecptions catch (e) {
      return left(Failure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, UserEntities>> logInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      final user = await authRemoteDataSource.logInWithEmailPassword(
        email: email,
        password: password,
      );

      if (user.token!.isNotEmpty) {
        spService.setToken(user.token!);
      }

      return right(user);
    } on ServerExecptions catch (e) {
      return left(Failure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, UserEntities>> currentUserData() async {
    try {
      final token = await spService.getToken();
      final userData = await authRemoteDataSource.currentUserData(token);

      if (userData == null) {
        return left(Failure(message: "User is not logged in"));
      }

      return right(userData);
    } on ServerExecptions catch (e) {
      return left(Failure(message: e.message));
    }
  }
}
