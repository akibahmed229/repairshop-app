import 'package:repair_shop/core/error/server_execptions.dart';
import 'package:repair_shop/core/secrets/app_secrets.dart';
import 'package:repair_shop/features/notifications/data/models/notification_model.dart';
import 'package:sqflite/sqflite.dart';

abstract interface class NotificationLocalDataSource {
  Future<void> cacheNotifications(List<NotificationModel> notifications);

  Future<List<NotificationModel>?> getCachedNotifications();

  Future<List<NotificationModel>> getUnSyncedNotifications();

  Future<void> markAllNotificationsAsSynced();

  Future<NotificationModel> updateNotification({
    required String id,
    required bool isRead,
  });

  Future<void> clearNotifications();
}

class NotificationLocalDataSourceImpl implements NotificationLocalDataSource {
  final Database database;
  const NotificationLocalDataSourceImpl({required this.database});

  @override
  Future<void> cacheNotifications(List<NotificationModel> notifications) async {
    try {
      final batch = database.batch();

      for (var notification in notifications) {
        batch.insert(
          AppSecrets.notificationsTable,
          notification.copyWith(isSynced: true).toJson(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }

      await batch.commit(noResult: true);
    } catch (e) {
      throw ServerExecptions('Failed to cache notifications: $e');
    }
  }

  @override
  Future<List<NotificationModel>?> getCachedNotifications() async {
    try {
      final maps = await database.query(AppSecrets.notificationsTable);

      if (maps.isEmpty) return null;

      return maps
          .map((notification) => NotificationModel.fromJson(notification))
          .toList();
    } catch (e) {
      throw ServerExecptions('Failed to get cache notifications: $e');
    }
  }

  @override
  Future<List<NotificationModel>> getUnSyncedNotifications() async {
    try {
      final result = await database.query(
        AppSecrets.notificationsTable,
        where: "isSynced = ?",
        whereArgs: [0],
      );

      if (result.isNotEmpty) {
        List<NotificationModel> notifications = [];
        for (var notification in result) {
          notifications.add(NotificationModel.fromJson(notification));
        }
        return notifications;
      }

      return [];
    } catch (e) {
      throw ServerExecptions('Failed to get unsyncedcache notifications: $e');
    }
  }

  @override
  Future<void> markAllNotificationsAsSynced() async {
    try {
      await database.update(
        AppSecrets.notificationsTable,
        {"isSynced": 1},
        where: "isSynced = ?",
        whereArgs: [0],
      );
    } catch (e) {
      throw ServerExecptions('Failed to mark notifications as synced: $e');
    }
  }

  @override
  Future<NotificationModel> updateNotification({
    required String id,
    required bool isRead,
  }) async {
    try {
      await database.update(
        AppSecrets.notificationsTable,
        {"isRead": isRead ? 1 : 0, "isSynced": 0},
        where: "id = ?",
        whereArgs: [id],
      );
      final notification = await database.query(
        AppSecrets.notificationsTable,
        where: "id = ?",
        whereArgs: [id],
      );

      if (notification.isNotEmpty) {
        return NotificationModel.fromJson(notification.first);
      } else {
        throw ServerExecptions(
          "Failed to get Notification: Query after insert failed",
        );
      }
    } catch (e) {
      throw ServerExecptions('Failed to update cached notifications: $e');
    }
  }

  @override
  Future<void> clearNotifications() async {
    try {
      await database.delete(AppSecrets.notificationsTable);
    } catch (e) {
      throw ServerExecptions('Failed to clear cached notifications: $e');
    }
  }
}
