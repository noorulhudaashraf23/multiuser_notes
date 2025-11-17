import 'dart:developer';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  static const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'default_notification_channel_id', // id
    'High Importance Notifications',
    importance: Importance.max,
  );

  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  /// Initialize Firebase Messaging and Notification Settings
  static Future<void> initialize() async {
    // Set up the notification channel for Android
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);

    // Get FCM token
    FirebaseMessaging fcm = FirebaseMessaging.instance;
    await fcm.requestPermission();
    await fcm.getToken().then((token) => _storeToken(token));
    fcm.onTokenRefresh.listen((token) => _storeToken(token));

    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle when app is opened from a notification
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      log('Message clicked!: ${message.messageId}');
    });

    // Request notification permissions
    var status = await Permission.notification.status;
    if (status.isDenied) {
      await Permission.notification.request();
    }
  }

  static Future<void> _storeToken(token) async {
    // Store FCM token in shared preferences for later use
    SharedPreferences prefs = await SharedPreferences.getInstance();
    log("FCM Token: $token");
    prefs.setString('fcm', token ?? "");
  }

  /// Background message handler
  @pragma('vm:entry-point')
  static Future<void> _firebaseMessagingBackgroundHandler(
    RemoteMessage message,
  ) async {
    log('Background Message: ${message.messageId}');
  }

  /// Foreground message handler
  static Future<void> _handleForegroundMessage(RemoteMessage message) async {
    String? notificationType = message.data['type']; // Extract type from data
    log("Foreground Message Type: $notificationType");
  }
}
