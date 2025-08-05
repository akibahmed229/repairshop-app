import 'package:get_it/get_it.dart';
import 'package:repair_shop/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:repair_shop/features/auth/data/repository/auth_repository_impl.dart';
import 'package:repair_shop/features/auth/domain/repository/auth_repository.dart';
import 'package:repair_shop/features/auth/domain/usecases/user_sign_up.dart';
import 'package:repair_shop/features/auth/presentation/bloc/auth_bloc.dart';

final serviceLocator = GetIt.instance;

Future<void> initDependencies() async {
  _initAuth();
}

void _initAuth() {
  serviceLocator
    ..registerFactory<AuthRemoteDataSource>(() => AuthRemoteDataSourceImpl())
    ..registerFactory<AuthRepository>(
      () => AuthRepositoryImpl(authRemoteDataSource: serviceLocator()),
    )
    ..registerFactory(() => UserSignUp(authRepository: serviceLocator()))
    ..registerFactory(() => AuthBloc(userSignUp: serviceLocator()));
}
