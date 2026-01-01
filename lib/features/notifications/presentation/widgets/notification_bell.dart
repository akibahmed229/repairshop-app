import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:repair_shop/features/notifications/presentation/bloc/notification_bloc.dart';
import 'package:repair_shop/features/notifications/presentation/pages/notification_inbox_page.dart';

class NotificationBell extends StatefulWidget {
  const NotificationBell({super.key});

  @override
  State<NotificationBell> createState() => _NotificationBellState();
}

class _NotificationBellState extends State<NotificationBell> {
  @override
  void initState() {
    super.initState();
    // Ensure we fetch notifications when this icon first appears
    context.read<NotificationBloc>().add(FetchNotificationsEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotificationBloc, NotificationState>(
      builder: (context, state) {
        int unreadCount = 0;

        if (state is NotificationInboxLoaded) {
          unreadCount = state.notifications.where((n) => !n.isRead).length;
        }

        return IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const NotificationInboxPage(),
              ),
            );
          },
          icon: Badge(
            label: Text(unreadCount.toString()),
            isLabelVisible: unreadCount > 0,
            backgroundColor: Colors.redAccent,
            child: const Icon(Icons.notifications_outlined),
          ),
        );
      },
    );
  }
}
