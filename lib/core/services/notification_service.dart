import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:repair_shop/core/theme/app_pallate.dart';
import 'package:repair_shop/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:repair_shop/main.dart';

class NotificationService {
  static final FirebaseMessaging _firebaseMessaging =
      FirebaseMessaging.instance;

  // Request Permissions & Get Token
  static Future<void> initNotifications(AuthBloc authBloc) async {
    // Request Permission
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      // Get Token
      final fcmToken = await _firebaseMessaging.getToken();

      if (fcmToken != null) {
        // Sync with Backend via Bloc
        // Make sure this is called ONLY if the user is logged in
        authBloc.add(AuthFcmSyncToken(fcmToken: fcmToken));
      }
    }
  }

  // Handle Foreground Messages
  static void setupForegroundListeners() async {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        // USE THE GLOBAL KEY HERE
        rootScaffoldMessengerKey.currentState?.showSnackBar(
          SnackBar(
            backgroundColor: AppPallete.backgroundColor,
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message.notification!.title ?? 'New Notification',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(message.notification!.body ?? ''),
              ],
            ),
            action: SnackBarAction(
              label: "VIEW",
              textColor: AppPallete.whiteColor,
              onPressed: () {
                // Handle navigation based on message.data['noteId']
                // Navigator.pushNamed(context, '/tech-note', arguments: message.data['noteId']);
              },
            ),
          ),
        );
      }
    });
  }
}
