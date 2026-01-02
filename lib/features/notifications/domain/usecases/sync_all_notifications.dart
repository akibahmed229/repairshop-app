import 'package:fpdart/fpdart.dart';
import 'package:repair_shop/core/error/failure.dart';
import 'package:repair_shop/core/usecase/usecase.dart';
import 'package:repair_shop/features/notifications/domain/repository/notification_repository.dart';

class SyncAllNotifications implements Usecase<bool, NoParams> {
  final NotificationRepository notificationRepository;

  const SyncAllNotifications({required this.notificationRepository});

  @override
  Future<Either<Failure, bool>> call(NoParams params) async {
    return await notificationRepository.syncAllNotifications();
  }
}
