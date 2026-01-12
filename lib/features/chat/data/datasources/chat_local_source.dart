import 'package:repair_shop/core/error/server_execptions.dart';
import 'package:repair_shop/core/secrets/app_secrets.dart';
import 'package:sqflite/sqflite.dart';

abstract interface class ChatLocalSource {
  Future<String> getUserIdByToken(String token);
}

class ChatLocalSourceImpl implements ChatLocalSource {
  final Database database;
  const ChatLocalSourceImpl({required this.database});

  @override
  Future<String> getUserIdByToken(String token) async {
    try {
      final List<Map<String, dynamic>> map = await database.query(
        AppSecrets.userTable,
        where: "token = ?",
        whereArgs: [token],
      );

      final data = map.first;

      return data['id'];
    } catch (e) {
      throw ServerExecptions('Failed to get cached user data: $e');
    }
  }
}
