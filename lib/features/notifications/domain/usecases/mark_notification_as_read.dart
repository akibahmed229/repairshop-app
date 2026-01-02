import 'package:fpdart/fpdart.dart';
import 'package:repair_shop/core/error/failure.dart';
import 'package:repair_shop/core/usecase/usecase.dart';
import 'package:repair_shop/features/notifications/domain/entities/notification_entities.dart';
import 'package:repair_shop/features/notifications/domain/repository/notification_repository.dart';

class MarkNotificationAsRead
    implements Usecase<NotificationEntities, MarkNotificationParam> {
  final NotificationRepository notificationRepository;

  const MarkNotificationAsRead({required this.notificationRepository});

  @override
  Future<Either<Failure, NotificationEntities>> call(
    MarkNotificationParam params,
  ) async {
    return await notificationRepository.markAsRead(
      notificationId: params.notificationId,
    );
  }
}

class MarkNotificationParam {
  String notificationId;

  MarkNotificationParam({required this.notificationId});
}
