import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:repair_shop/core/usecase/usecase.dart';
import 'package:repair_shop/features/notifications/domain/entities/notification_entities.dart';
import 'package:repair_shop/features/notifications/domain/usecases/get_all_notifications.dart';
import 'package:repair_shop/features/notifications/domain/usecases/mark_notification_as_read.dart';

part 'notification_event.dart';
part 'notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final GetAllNotifications _getAllNotifications;
  final MarkNotificationAsRead _markNotificationAsRead;

  NotificationBloc({
    required GetAllNotifications getAllNotifications,
    required MarkNotificationAsRead markNotificationAsRead,
  }) : _getAllNotifications = getAllNotifications,
       _markNotificationAsRead = markNotificationAsRead,
       super(NotificationInitial()) {
    on<NotificationEvent>((event, emit) => emit(NotificationLoading()));
    on<FetchNotificationsEvent>(_onNotificationInboxLoaded);
    on<MarkNotificationAsReadEvent>(_onNotificationMarkedASRead);
  }

  void _onNotificationInboxLoaded(
    FetchNotificationsEvent event,
    Emitter<NotificationState> emit,
  ) async {
    final res = await _getAllNotifications(NoParams());

    res.fold(
      (failure) => emit(NotificationFailure(message: failure.message)),
      (notifications) => emit(NotificationInboxLoaded(notifications)),
    );
  }

  void _onNotificationMarkedASRead(
    MarkNotificationAsReadEvent event,
    Emitter<NotificationState> emit,
  ) async {
    final res = await _markNotificationAsRead(
      MarkNotificationParam(notificationId: event.notificationId),
    );

    res.fold(
      (failure) => emit(NotificationFailure(message: failure.message)),
      (notification) => emit(NotificationMarkedASRead(notification)),
    );
  }
}
