import 'package:fpdart/fpdart.dart';
import 'package:repair_shop/core/error/failure.dart';
import 'package:repair_shop/features/notifications/domain/entities/notification_entities.dart';

abstract interface class NotificationRepository {
  Future<Either<Failure, List<NotificationEntities>>> getNotifications();

  Future<Either<Failure, NotificationEntities>> markAsRead({
    required String notificationId,
  });

  Future<Either<Failure, String>> deleteAllNotifications();

  Future<Either<Failure, bool>> syncAllNotifications();
}
