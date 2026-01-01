import 'dart:convert';

import 'package:repair_shop/core/error/server_execptions.dart';
import 'package:repair_shop/core/secrets/app_secrets.dart';
import 'package:repair_shop/features/notifications/data/models/notification_model.dart';
import 'package:http/http.dart' as http;

abstract interface class NotificationRemoteDataSource {
  Future<List<NotificationModel>> getNotifications({required String token});

  Future<NotificationModel> markAsRead({
    required String token,
    required String notificationId,
  });
}

class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  @override
  Future<List<NotificationModel>> getNotifications({
    required String token,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('${AppSecrets.backendUri}/api/notificatons'),
        headers: {'Content-Type': 'application/json', 'x-auth-token': token},
      );

      if (response.statusCode != 200) {
        throw jsonDecode(response.body)["message"] ??
            'Unknown error occurred on the server.';
      }

      final List<dynamic> decodedBody = jsonDecode(response.body);

      return decodedBody
          .map((notification) => NotificationModel.fromJson(notification))
          .toList();
    } catch (e) {
      throw ServerExecptions("Failed to create note: ${e.toString()}");
    }
  }

  @override
  Future<NotificationModel> markAsRead({
    required String token,
    required String notificationId,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('${AppSecrets.backendUri}/api/notificatons'),
        headers: {'Content-Type': 'application/json', 'x-auth-token': token},
        body: jsonEncode({"id": notificationId}),
      );

      if (response.statusCode != 200) {
        throw jsonDecode(response.body)["message"] ??
            'Unknown error occurred on the server.';
      }

      return NotificationModel.fromJson(jsonDecode(response.body)["data"]);
    } catch (e) {
      throw ServerExecptions("Failed to create note: ${e.toString()}");
    }
  }
}
