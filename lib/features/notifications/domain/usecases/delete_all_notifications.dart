import 'package:fpdart/fpdart.dart';
import 'package:repair_shop/core/error/failure.dart';
import 'package:repair_shop/core/usecase/usecase.dart';
import 'package:repair_shop/features/notifications/domain/repository/notification_repository.dart';

class DeleteAllNotifications implements Usecase<String, NoParams> {
  final NotificationRepository notificationRepository;

  const DeleteAllNotifications({required this.notificationRepository});

  @override
  Future<Either<Failure, String>> call(NoParams params) async {
    return await notificationRepository.deleteAllNotifications();
  }
}
