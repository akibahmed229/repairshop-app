import 'package:fpdart/fpdart.dart';
import 'package:repair_shop/core/error/failure.dart';
import 'package:repair_shop/core/error/server_execptions.dart';
import 'package:repair_shop/core/network/connection_checker.dart';
import 'package:repair_shop/core/utils/sp_service.dart';
import 'package:repair_shop/features/notifications/data/datasources/notification_local_data_source.dart';
import 'package:repair_shop/features/notifications/data/datasources/notification_remote_data_source.dart';
import 'package:repair_shop/features/notifications/domain/entities/notification_entities.dart';
import 'package:repair_shop/features/notifications/domain/repository/notification_repository.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationRemoteDataSource notificationRemoteDataSource;
  final NotificationLocalDataSource notificationLocalDataSource;
  final ConnectionChecker connectionChecker;
  final SpService spService;

  const NotificationRepositoryImpl({
    required this.notificationRemoteDataSource,
    required this.notificationLocalDataSource,
    required this.connectionChecker,
    required this.spService,
  });

  @override
  Future<Either<Failure, List<NotificationEntities>>> getNotifications() async {
    try {
      if (await connectionChecker.isConnected) {
        final token = await spService.getToken();

        final notifications = await notificationRemoteDataSource
            .getNotifications(token: token!);

        if (notifications.isEmpty) {
          return left(Failure(message: "No notification exist"));
        }

        await notificationLocalDataSource.clearNotifications();
        await notificationLocalDataSource.cacheNotifications(notifications);

        return right(notifications);
      } else {
        final cachedNotifications = await notificationLocalDataSource
            .getCachedNotifications();

        if (cachedNotifications == null) {
          return left(Failure(message: "Notifications not found"));
        }

        return right(cachedNotifications);
      }
    } on ServerExecptions catch (e) {
      return left(Failure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, NotificationEntities>> markAsRead({
    required String notificationId,
  }) async {
    try {
      if (await connectionChecker.isConnected) {
        final token = await spService.getToken();

        final markNotificationAsRead = await notificationRemoteDataSource
            .markAsRead(token: token!, notificationId: notificationId);

        return right(markNotificationAsRead);
      } else {
        final notification = await notificationLocalDataSource
            .updateNotification(id: notificationId, isRead: true);

        return right(notification);
      }
    } on ServerExecptions catch (e) {
      return left(Failure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, String>> deleteAllNotifications() async {
    try {
      if (await connectionChecker.isConnected) {
        final token = await spService.getToken();

        final deltedNotifications = await notificationRemoteDataSource
            .deleteAllNotifications(token: token!);

        return right(deltedNotifications);
      } else {
        return left(Failure(message: "No Internet Connection"));
      }
    } on ServerExecptions catch (e) {
      return left(Failure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, bool>> syncAllNotifications() async {
    try {
      if (await connectionChecker.isConnected) {
        final unSyncedNotifications = await notificationLocalDataSource
            .getUnSyncedNotifications();

        if (unSyncedNotifications.isEmpty) {
          return right(true);
        }

        final token = await spService.getToken();

        final result = await notificationRemoteDataSource.syncAllNotifications(
          notifications: unSyncedNotifications,
          token: token!,
        );

        if (result) {
          await notificationLocalDataSource.markAllNotificationsAsSynced();
        }

        return right(result);
      } else {
        return left(Failure(message: "No Internet Connection!!!"));
      }
    } on ServerExecptions catch (e) {
      return left(Failure(message: e.message));
    }
  }
}
