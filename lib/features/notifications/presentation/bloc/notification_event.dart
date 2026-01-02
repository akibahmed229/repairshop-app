part of 'notification_bloc.dart';

@immutable
sealed class NotificationEvent {
  const NotificationEvent();
}

final class FetchNotificationsEvent extends NotificationEvent {
  const FetchNotificationsEvent();
}

final class MarkNotificationAsReadEvent extends NotificationEvent {
  final String notificationId;

  const MarkNotificationAsReadEvent({required this.notificationId});
}

final class NotificationSyncEvent extends NotificationEvent {
  const NotificationSyncEvent();
}

final class DeleteAllNotificationEvent extends NotificationEvent {
  const DeleteAllNotificationEvent();
}
