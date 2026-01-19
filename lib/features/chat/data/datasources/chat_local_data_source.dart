import 'package:repair_shop/core/error/server_execptions.dart';
import 'package:repair_shop/core/secrets/app_secrets.dart';
import 'package:repair_shop/features/chat/data/models/chat_conversation_model.dart';
import 'package:repair_shop/features/chat/data/models/message_model.dart';
import 'package:sqflite/sqflite.dart';

abstract interface class ChatLocalDataSource {
  Future<String> getUserIdByToken(String token);

  Future<void> cacheMessages(List<MessageModel> messages);

  Future<void> cacheConversations(List<ChatConversationModel> conversations);

  Future<List<MessageModel>?> getCachedMessages(
    String myUserId,
    String otherUserId,
  );

  Future<List<ChatConversationModel>?> getCachedConversations();

  Future<void> clearCachedMessages();

  Future<void> clearCachedConversations();
}

class ChatLocalDataSourceImpl implements ChatLocalDataSource {
  final Database database;
  const ChatLocalDataSourceImpl({required this.database});

  @override
  Future<String> getUserIdByToken(String token) async {
    try {
      // Note: Ensure your table name and column names match exactly
      final List<Map<String, dynamic>> map = await database.query(
        AppSecrets.userTable, // Usually "users"
        where: "token = ?",
        // If you don't store the token in the users table,
        // you might need to query by email or ID.
        whereArgs: [token],
      );

      if (map.isNotEmpty) {
        return map.first['id'];
      }

      throw 'User not found in local database';
    } catch (e) {
      throw ServerExecptions('Failed to get cached user data: $e');
    }
  }

  @override
  Future<void> cacheMessages(List<MessageModel> messages) async {
    try {
      final batch = database.batch();

      for (var message in messages) {
        batch.insert(
          AppSecrets.messagesTable,
          message.toJson(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }

      await batch.commit(noResult: true);
    } catch (e) {
      throw ServerExecptions('Failed to cache messages: $e');
    }
  }

  @override
  Future<void> cacheConversations(
    List<ChatConversationModel> conversations,
  ) async {
    try {
      final batch = database.batch();

      for (var conv in conversations) {
        batch.insert(
          AppSecrets.conversationTable,
          conv.toJson(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }

      await batch.commit(noResult: true);
    } catch (e) {
      throw ServerExecptions('Failed to cache conversations: $e');
    }
  }

  @override
  Future<List<MessageModel>?> getCachedMessages(
    String myUserId,
    String otherUserId,
  ) async {
    try {
      final maps = await database.query(
        AppSecrets.messagesTable,
        where:
            "senderId = ? AND receiverId = ? OR senderId = ? AND receiverId = ?",
        whereArgs: [myUserId, otherUserId, otherUserId, myUserId],
      );

      if (maps.isEmpty) return null;

      return maps.map((msg) => MessageModel.fromJson(msg, myUserId)).toList();
    } catch (e) {
      throw ServerExecptions('Failed to get cache messages: $e');
    }
  }

  @override
  Future<List<ChatConversationModel>?> getCachedConversations() async {
    try {
      final maps = await database.query(AppSecrets.conversationTable);

      if (maps.isEmpty) return null;

      return maps.map((conv) => ChatConversationModel.fromJson(conv)).toList();
    } catch (e) {
      throw ServerExecptions('Failed to get cache conversations: $e');
    }
  }

  @override
  Future<void> clearCachedMessages() async {
    try {
      await database.delete(AppSecrets.messagesTable);
    } catch (e) {
      throw ServerExecptions('Failed to clear cached messages: $e');
    }
  }

  @override
  Future<void> clearCachedConversations() async {
    try {
      await database.delete(AppSecrets.conversationTable);
    } catch (e) {
      throw ServerExecptions('Failed to clear cached conversations: $e');
    }
  }
}
