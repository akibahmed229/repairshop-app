import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:repair_shop/core/usecase/usecase.dart';
import 'package:repair_shop/features/notifications/domain/entities/notification_entities.dart';
import 'package:repair_shop/features/notifications/domain/usecases/delete_all_notifications.dart';
import 'package:repair_shop/features/notifications/domain/usecases/get_all_notifications.dart';
import 'package:repair_shop/features/notifications/domain/usecases/mark_notification_as_read.dart';
import 'package:repair_shop/features/notifications/domain/usecases/sync_all_notifications.dart';

part 'notification_event.dart';
part 'notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final GetAllNotifications _getAllNotifications;
  final MarkNotificationAsRead _markNotificationAsRead;
  final SyncAllNotifications _syncAllNotifications;
  final DeleteAllNotifications _deleteAllNotifications;

  // Guard Variable to prevent double invoke on first render
  bool _isFetching = false;

  NotificationBloc({
    required GetAllNotifications getAllNotifications,
    required MarkNotificationAsRead markNotificationAsRead,
    required SyncAllNotifications syncAllNotifications,
    required DeleteAllNotifications deleteAllNotifications,
  }) : _getAllNotifications = getAllNotifications,
       _markNotificationAsRead = markNotificationAsRead,
       _syncAllNotifications = syncAllNotifications,
       _deleteAllNotifications = deleteAllNotifications,
       super(NotificationInitial()) {
    on<NotificationEvent>((event, emit) => emit(NotificationLoading()));
    on<FetchNotificationsEvent>(_onFetchNotificationsEvent);
    on<MarkNotificationAsReadEvent>(_onMarkNotificationAsReadEvent);
    on<NotificationSyncEvent>(_onNotificationSyncEvent);
    on<DeleteAllNotificationEvent>(_onDeleteAllNotificationEvent);
  }

  void _onFetchNotificationsEvent(
    FetchNotificationsEvent event,
    Emitter<NotificationState> emit,
  ) async {
    // APPLY GUARD: If already fetching, ignore this duplicate trigger
    if (_isFetching) return;

    _isFetching = true; // Lock

    try {
      final res = await _getAllNotifications(NoParams());

      res.fold(
        (failure) => emit(NotificationFailure(message: failure.message)),
        (notifications) => emit(NotificationInboxLoaded(notifications)),
      );
    } finally {
      // UNLOCK: Always release the guard, even if error occurs
      _isFetching = false;
    }
  }

  void _onMarkNotificationAsReadEvent(
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

  void _onNotificationSyncEvent(
    NotificationSyncEvent event,
    Emitter<NotificationState> emit,
  ) async {
    final res = await _syncAllNotifications(NoParams());

    res.fold((failure) => emit(NotificationFailure(message: failure.message)), (
      isSynced,
    ) {
      add(FetchNotificationsEvent());
      emit(NotificationSyncSucess(isSynced));
    });
  }

  void _onDeleteAllNotificationEvent(
    DeleteAllNotificationEvent event,
    Emitter<NotificationState> emit,
  ) async {
    final res = await _deleteAllNotifications(NoParams());

    res.fold(
      (failure) => emit(NotificationFailure(message: failure.message)),
      (message) => emit(AllNotificationDeleted(message)),
    );
  }
}
