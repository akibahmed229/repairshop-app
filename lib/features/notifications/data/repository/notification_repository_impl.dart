import 'package:fpdart/fpdart.dart';
import 'package:repair_shop/core/error/failure.dart';
import 'package:repair_shop/core/error/server_execptions.dart';
import 'package:repair_shop/core/network/connection_checker.dart';
import 'package:repair_shop/core/utils/sp_service.dart';
import 'package:repair_shop/features/notifications/data/datasources/notification_remote_data_source.dart';
import 'package:repair_shop/features/notifications/domain/entities/notification_entities.dart';
import 'package:repair_shop/features/notifications/domain/repository/notification_repository.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationRemoteDataSource notificationRemoteDataSource;
  final ConnectionChecker connectionChecker;
  final SpService spService;

  const NotificationRepositoryImpl({
    required this.notificationRemoteDataSource,
    required this.connectionChecker,
    required this.spService,
  });

  @override
  Future<Either<Failure, List<NotificationEntities>>> getNotifications() async {
    try {
      if (await connectionChecker.isConnected) {
        final token = await spService.getToken();

        final notification = await notificationRemoteDataSource
            .getNotifications(token: token!);

        if (notification.isEmpty) {
          return left(Failure(message: "No notification exist"));
        }

        return right(notification);
      } else {
        return left(Failure(message: "No Internel connection"));
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
        return left(Failure(message: "No Internel connection"));
      }
    } on ServerExecptions catch (e) {
      return left(Failure(message: e.message));
    }
  }
}
