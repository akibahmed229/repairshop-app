part of 'notification_bloc.dart';

@immutable
sealed class NotificationState {
  const NotificationState();
}

final class NotificationInitial extends NotificationState {
  const NotificationInitial();
}

final class NotificationLoading extends NotificationState {
  const NotificationLoading();
}

final class NotificationFailure extends NotificationState {
  final String message;

  const NotificationFailure({required this.message});
}

final class NotificationInboxLoaded extends NotificationState {
  final List<NotificationEntities> notifications;

  const NotificationInboxLoaded(this.notifications);
}

final class NotificationMarkedASRead extends NotificationState {
  final NotificationEntities notification;

  const NotificationMarkedASRead(this.notification);
}
