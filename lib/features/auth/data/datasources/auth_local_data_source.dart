import 'dart:convert';

import 'package:repair_shop/core/error/server_execptions.dart';
import 'package:repair_shop/core/secrets/app_secrets.dart';
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
  Future<void> cacheUser(UserModel user) async {
    try {
      await database.insert(AppSecrets.userTable, {
        "id": user.id,
        "name": user.email,
        "email": user.email,
        "roles": jsonEncode(user.roles ?? []),
        "active": user.active ?? true ? 1 : 0,
        "token": user.token,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    } catch (e) {
      throw ServerExecptions('Failed to cache user data: $e');
    }
  }

  @override
  Future<UserModel?> getCachedUser() async {
    try {
      final List<Map<String, dynamic>> map = await database.query(
        AppSecrets.userTable,
      );

      if (map.isEmpty) {
        return null;
      }

      final data = map.first;

      return UserModel(
        id: data['id'],
        name: data["name"],
        email: data["email"],
        roles: (jsonDecode(data['roles']) as List<dynamic>)
            .map((role) => role.toString())
            .toList(),
        active: data["active"] == 1,
      );
    } catch (e) {
      throw ServerExecptions('Failed to get cached user data: $e');
    }
  }

  @override
  Future<void> clearUser() async {
    try {
      await database.delete(AppSecrets.userTable);
    } catch (e) {
      throw ServerExecptions('Failed to clear user data: $e');
    }
  }
}
