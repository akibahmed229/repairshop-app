import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:repair_shop/features/notifications/presentation/bloc/notification_bloc.dart';
import 'package:repair_shop/features/notifications/domain/entities/notification_entities.dart';
import 'package:repair_shop/core/theme/app_pallate.dart';

class NotificationInboxPage extends StatefulWidget {
  const NotificationInboxPage({super.key});

  @override
  State<NotificationInboxPage> createState() => _NotificationInboxPageState();
}

class _NotificationInboxPageState extends State<NotificationInboxPage> {
  List<NotificationEntities> notifications = [];

  @override
  void initState() {
    super.initState();
    // Fetch notifications when the page first loads
    context.read<NotificationBloc>().add(FetchNotificationsEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Notifications")),
      body: BlocConsumer<NotificationBloc, NotificationState>(
        listener: (context, state) {
          if (state is NotificationFailure) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          // 1. Show Loading Indicator
          if (state is NotificationLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // 2. Show List Data
          if (state is NotificationInboxLoaded) {
            notifications = state.notifications;
          }

          if (state is NotificationMarkedASRead) {
            context.read<NotificationBloc>().add(FetchNotificationsEvent());
          }

          if (notifications.isEmpty) {
            return const Center(child: Text("No notifications yet."));
          }

          return ListView.separated(
            itemCount: notifications.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final notification = notifications[index];
              return _NotificationTile(notification: notification);
            },
          );
        },
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final NotificationEntities notification;

  const _NotificationTile({required this.notification});

  @override
  Widget build(BuildContext context) {
    final isRead = notification.isRead;

    return ListTile(
      tileColor: isRead
          ? Colors.transparent
          : Colors.blue.withValues(alpha: 0.1),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: CircleAvatar(
        backgroundColor: isRead ? Colors.grey : AppPallete.gradient1,
        child: Icon(
          notification.type == 'task_assigned' ? Icons.assignment : Icons.info,
          color: Colors.white,
        ),
      ),
      title: Text(
        notification.title,
        style: TextStyle(
          fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Text(notification.body, maxLines: 2, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 4),
          Text(
            DateFormat('MMM d, h:mm a').format(notification.createdAt!),
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
      trailing: !isRead
          ? const Icon(Icons.circle, size: 10, color: Colors.blue)
          : null,
      onTap: () {
        if (!isRead) {
          context.read<NotificationBloc>().add(
            MarkNotificationAsReadEvent(notificationId: notification.id),
          );
        }
      },
    );
  }
}
