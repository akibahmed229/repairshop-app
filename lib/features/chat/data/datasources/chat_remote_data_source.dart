import 'dart:convert';
import 'dart:io';

import 'package:repair_shop/core/common/models/user_model.dart';
import 'package:repair_shop/core/error/server_execptions.dart';
import 'package:repair_shop/core/secrets/app_secrets.dart';
import 'package:repair_shop/features/chat/data/models/chat_conversation_model.dart';
import 'package:repair_shop/features/chat/data/models/message_model.dart';
import 'package:http/http.dart' as http;

abstract interface class ChatRemoteDataSource {
  Future<List<UserModel>> searchUsers(String query, String token);

  Future<MessageModel> sendMessage({
    required String receiverId,
    required String content,
    required String myUserId,
    String? token,
  });

  Future<List<MessageModel>> getChatHistory(
    String otherUserId,
    String myUserId,
    String token,
  );

  Future<List<ChatConversationModel>> getAllConversations(String token);

  Future<String> deleteChat(String id, String token);
}

class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  @override
  Future<List<UserModel>> searchUsers(String query, String token) async {
    try {
      final response = await http.get(
        Uri.parse('${AppSecrets.backendUri}/api/chat/search?query=$query'),
        headers: {'Content-Type': 'application/json', 'x-auth-token': token},
      );

      final List<dynamic> decodedBody = jsonDecode(response.body);

      if (response.statusCode != 200) {
        throw jsonDecode(response.body)["message"] ??
            'Unknown error occurred on the server.';
      }

      return decodedBody.map((user) => UserModel.formJson(user)).toList();
    } on SocketException {
      // Catches actual network errors if connectionChecker missed them
      throw ServerExecptions("No Internet Connection");
    } catch (e) {
      throw ServerExecptions("Failed to search users: ${e.toString()}");
    }
  }

  @override
  Future<MessageModel> sendMessage({
    required String receiverId,
    required String content,
    required String myUserId,
    String? token,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${AppSecrets.backendUri}/api/chat/send'),
        headers: {'Content-Type': 'application/json', 'x-auth-token': token!},
        body: jsonEncode({"receiverId": receiverId, "content": content}),
      );

      if (response.statusCode != 201) {
        throw jsonDecode(response.body)["message"] ??
            'Unknown error occurred on the server.';
      }

      return MessageModel.fromJson(jsonDecode(response.body), myUserId);
    } catch (e) {
      throw ServerExecptions("Failed to send message: ${e.toString()}");
    }
  }

  @override
  Future<List<MessageModel>> getChatHistory(
    String otherUserId,
    String myUserId,
    String token,
  ) async {
    try {
      final response = await http.get(
        Uri.parse('${AppSecrets.backendUri}/api/chat/history/$otherUserId'),
        headers: {'Content-Type': 'application/json', 'x-auth-token': token},
      );

      if (response.statusCode != 200) {
        throw jsonDecode(response.body)["message"] ??
            'Unknown error occurred on the server.';
      }

      final List<dynamic> decodedBody = jsonDecode(response.body);

      return decodedBody
          .map((message) => MessageModel.fromJson(message, myUserId))
          .toList();
    } catch (e) {
      throw ServerExecptions("Failed to get chat history: ${e.toString()}");
    }
  }

  @override
  Future<List<ChatConversationModel>> getAllConversations(String token) async {
    try {
      final response = await http.get(
        Uri.parse('${AppSecrets.backendUri}/api/chat/conversations'),
        headers: {'Content-Type': 'application/json', 'x-auth-token': token},
      );

      if (response.statusCode != 200) {
        throw jsonDecode(response.body)["message"] ??
            'Unknown error occurred on the server.';
      }

      final List<dynamic> decodedBody = jsonDecode(response.body);

      return decodedBody
          .map((chat) => ChatConversationModel.fromJson(chat))
          .toList();
    } catch (e) {
      throw ServerExecptions("Failed to get chat history: ${e.toString()}");
    }
  }

  @override
  Future<String> deleteChat(String id, String token) async {
    try {
      final response = await http.delete(
        Uri.parse('${AppSecrets.backendUri}/api/chat/$id'),
        headers: {'Content-Type': 'application/json', 'x-auth-token': token},
      );

      if (response.statusCode != 200) {
        throw jsonDecode(response.body)["message"] ??
            'Unknown error occurred on the server.';
      }

      return jsonDecode(response.body)['message'];
    } catch (e) {
      throw ServerExecptions("Failed to delete chat history: ${e.toString()}");
    }
  }
}
