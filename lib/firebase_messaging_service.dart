import 'dart:developer';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:multiuser_notes/local_notifications_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FirebaseMessagingService {
  // Private constructor for singleton pattern
  FirebaseMessagingService._internal();

  // Singleton instance
  static final FirebaseMessagingService _instance =
      FirebaseMessagingService._internal();

  // Factory constructor to provide singleton instance
  factory FirebaseMessagingService.instance() => _instance;

  // Reference to local notifications service for displaying notifications
  LocalNotificationsService? _localNotificationsService;

  /// Initialize Firebase Messaging and sets up all message listeners
  Future<void> init({
    required LocalNotificationsService localNotificationsService,
  }) async {
    // Init local notifications service
    _localNotificationsService = localNotificationsService;

    // Handle FCM token
    _handlePushNotificationsToken();

    // Request user permission for notifications
    _requestPermission();

    // Register handler for background messages (app terminated)
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Listen for messages when the app is in foreground
    FirebaseMessaging.onMessage.listen(_onForegroundMessage);

    // Listen for notification taps when the app is in background but not terminated
    FirebaseMessaging.onMessageOpenedApp.listen(_onMessageOpenedApp);

    // Check for initial message that opened the app from terminated state
    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      _onMessageOpenedApp(initialMessage);
    }
  }

  /// Retrieves and manages the FCM token for push notifications
  Future<void> _handlePushNotificationsToken() async {
    final prefs = await SharedPreferences.getInstance();
    final apnsToken = await FirebaseMessaging.instance.getAPNSToken();
    log('APNS token: $apnsToken');
    // Get the FCM token for the device
    final token = await FirebaseMessaging.instance.getToken();
    log('Push notifications token: $token');
    prefs.setString('fcm', token.toString());

    // Listen for token refresh events
    FirebaseMessaging.instance.onTokenRefresh
        .listen((fcmToken) {
          log('FCM token refreshed: $fcmToken');
        })
        .onError((error) {
          // Handle errors during token refresh
          log('Error refreshing FCM token: $error');
        });
  }

  /// Requests notification permission from the user
  Future<void> _requestPermission() async {
    final settings = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false, // Set to true if you want provisional authorization
    );

    log('Notification permission status: ${settings.authorizationStatus}');
    log('Alert: ${settings.alert}');
    log('Badge: ${settings.badge}');
    log('Sound: ${settings.sound}');
  }

  /// Handles messages received while the app is in the foreground
  void _onForegroundMessage(RemoteMessage message) {
    log('Foreground message received: ${message.data}');
    log('Notification title: ${message.notification?.title}');
    log('Notification body: ${message.notification?.body}');
    log('Data: ${message.data}');

    if (message.notification != null) {
      log('iOS notification received in foreground');
      // For iOS, you might need to manually show the notification
      _localNotificationsService?.showNotification(
        message.notification?.title,
        message.notification?.body,
        message.data.toString(),
      );
    }
  }

  /// Handles notification taps when app is opened from the background or terminated state
  void _onMessageOpenedApp(RemoteMessage message) {
    log('Notification caused the app to open: ${message.data.toString()}');
  }
}

/// Background message handler (must be top-level function or static)
/// Handles messages when the app is fully terminated
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  log('Background message received: ${message.data.toString()}');
}
