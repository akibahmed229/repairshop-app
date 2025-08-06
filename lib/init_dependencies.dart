import 'package:get_it/get_it.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:path/path.dart';
import 'package:repair_shop/core/common/cubits/app_wide_user/app_wide_user_cubit.dart';
import 'package:repair_shop/core/network/connection_checker.dart';
import 'package:repair_shop/core/secrets/app_secrets.dart';
import 'package:repair_shop/core/utils/sp_service.dart';
import 'package:repair_shop/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:repair_shop/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:repair_shop/features/auth/data/repository/auth_repository_impl.dart';
import 'package:repair_shop/features/auth/domain/repository/auth_repository.dart';
import 'package:repair_shop/features/auth/domain/usecases/current_user.dart';
import 'package:repair_shop/features/auth/domain/usecases/user_log_in.dart';
import 'package:repair_shop/features/auth/domain/usecases/user_sign_up.dart';
import 'package:repair_shop/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:sqflite/sqflite.dart';

final serviceLocator = GetIt.instance;

Future<void> initDependencies() async {
  // shared data like token
  serviceLocator.registerLazySingleton(() => SpService());

  // app wide user info
  serviceLocator.registerLazySingleton(() => AppWideUserCubit());

  // internet connection
  serviceLocator
    ..registerFactory(() => InternetConnection())
    ..registerFactory<ConnectionChecker>(
      () => ConnectionCheckerImpl(serviceLocator()),
    );

  // Local database initiate
  final db = await openDatabase(
    join(await getDatabasesPath(), AppSecrets.sqfliteDbName),
    onCreate: (db, version) {
      return db.execute(
        'CREATE TABLE users(id TEXT PRIMARY KEY, name TEXT, email TEXT, roles TEXT, active INTEGER, token TEXT)',
      );
    },
    version: 1,
  );
  serviceLocator.registerLazySingleton(() => db);

  _initAuth();
}

void _initAuth() {
  serviceLocator
    ..registerFactory<AuthRemoteDataSource>(() => AuthRemoteDataSourceImpl())
    ..registerFactory<AuthLocalDataSource>(
      () => AuthLocalDataSourceImpl(database: serviceLocator()),
    )
    ..registerFactory<AuthRepository>(
      () => AuthRepositoryImpl(
        authRemoteDataSource: serviceLocator(),
        authLocalDataSource: serviceLocator(),
        connectionChecker: serviceLocator(),
        spService: serviceLocator(),
      ),
    )
    ..registerFactory(() => UserSignUp(authRepository: serviceLocator()))
    ..registerFactory(() => UserLogIn(authRepository: serviceLocator()))
    ..registerFactory(() => CurrentUser(authRepository: serviceLocator()))
    ..registerLazySingleton(
      () => AuthBloc(
        userSignUp: serviceLocator(),
        userLogIn: serviceLocator(),
        currentUser: serviceLocator(),
        appWideUserCubit: serviceLocator(),
      ),
    );
}
