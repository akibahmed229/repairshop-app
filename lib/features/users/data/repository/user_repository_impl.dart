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
}
