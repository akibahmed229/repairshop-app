import 'dart:convert';

import 'package:repair_shop/core/common/models/user_model.dart';
import 'package:repair_shop/core/error/server_execptions.dart';
import 'package:repair_shop/core/secrets/app_secrets.dart';
import 'package:sqflite/sqflite.dart';

abstract interface class UserLocalDataSource {
  Future<void> cacheUser(UserModel user);

  Future<List<UserModel?>> getAllCachedUsers();

  Future<UserModel?> getUserById(String id);

  Future<UserModel?> getFirstCachedUser();

  Future<void> logoutUser(String id);

  Future<void> logoutALlUser();
}

class UserLocalDataSourceImp implements UserLocalDataSource {
  final Database database;

  const UserLocalDataSourceImp({required this.database});

  @override
  Future<void> cacheUser(UserModel user) async {
    try {
      await database.insert(AppSecrets.userTable, {
        "id": user.id,
        "name": user.name,
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
  Future<List<UserModel>> getAllCachedUsers() async {
    try {
      final List<Map<String, dynamic>> maps = await database.query(
        AppSecrets.userTable,
      );
      return maps
          .map(
            (data) => UserModel(
              id: data['id'],
              name: data["name"],
              email: data["email"],
              roles: (jsonDecode(data['roles']) as List<dynamic>)
                  .map((role) => role.toString())
                  .toList(),
              active: data["active"] == 1,
              token: data['token'], // Ensure token is mapped back for switching
            ),
          )
          .toList();
    } catch (e) {
      throw ServerExecptions('Failed to get cached users: $e');
    }
  }

  @override
  Future<UserModel?> getUserById(String id) async {
    try {
      final List<Map<String, dynamic>> map = await database.query(
        AppSecrets.userTable,
        where: "id = ?",
        whereArgs: [id],
      );

      if (map.isEmpty) {
        return null;
      }

      final data = map.first;

      return UserModel(
        id: data['id'],
        name: data["name"],
        email: data["email"],
        token: data['token'],
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
  Future<UserModel?> getFirstCachedUser() async {
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
        token: data['token'],
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
  Future<void> logoutUser(String id) async {
    try {
      await database.delete(
        AppSecrets.userTable,
        where: "id = ?",
        whereArgs: [id],
      );
    } catch (e) {
      throw ServerExecptions('Failed to logout user: $e');
    }
  }

  @override
  Future<void> logoutALlUser() async {
    try {
      await database.delete(AppSecrets.userTable);
      await database.delete(AppSecrets.techNotesTable);
      await database.delete(AppSecrets.techNoteUsersTable);
      await database.delete(AppSecrets.notificationsTable);
    } catch (e) {
      throw ServerExecptions('Failed to logout all user: $e');
    }
  }
}
