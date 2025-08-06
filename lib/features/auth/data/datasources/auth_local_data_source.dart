import 'package:repair_shop/core/error/server_execptions.dart';
import 'package:repair_shop/features/auth/data/models/user_model.dart';
import 'package:sqflite/sqflite.dart';

abstract interface class AuthLocalDataSource {
  Future<void> cacheUser(UserModel user);
  Future<UserModel?> getCachedUser();
  Future<void> clearUser();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final Database database;
  const AuthLocalDataSourceImpl({required this.database});

  @override
  Future<void> cacheUser(UserModel user) {
    try {
      throw UnimplementedError();
    } catch (e) {
      throw ServerExecptions('Failed to cache user data: $e');
    }
  }

  @override
  Future<UserModel?> getCachedUser() {
    try {
      throw UnimplementedError();
    } catch (e) {
      throw ServerExecptions('Failed to get cached user data: $e');
    }
  }

  @override
  Future<void> clearUser() {
    try {
      throw UnimplementedError();
    } catch (e) {
      throw ServerExecptions('Failed to clear user data: $e');
    }
  }
}
