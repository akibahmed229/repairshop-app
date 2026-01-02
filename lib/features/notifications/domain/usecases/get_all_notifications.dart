import 'package:fpdart/fpdart.dart';
import 'package:repair_shop/core/error/failure.dart';
import 'package:repair_shop/core/usecase/usecase.dart';
import 'package:repair_shop/features/notifications/domain/entities/notification_entities.dart';
import 'package:repair_shop/features/notifications/domain/repository/notification_repository.dart';

class GetAllNotifications
    implements Usecase<List<NotificationEntities>, NoParams> {
  final NotificationRepository notificationRepository;

  const GetAllNotifications({required this.notificationRepository});

  @override
  Future<Either<Failure, List<NotificationEntities>>> call(
    NoParams params,
  ) async {
    return await notificationRepository.getNotifications();
  }
}
