import 'dart:async';
import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:xchange_app/notification_state.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  StreamSubscription? _firebaseSubscription;
  final _notificationController = StreamController<void>.broadcast();
  bool _isDisposed = false;

  factory NotificationService() => _instance;
  NotificationService._internal();

  Stream<void> get onNotification => _notificationController.stream;

  Future<void> initialize() async {
    await Firebase.initializeApp();
    await _analytics.setAnalyticsCollectionEnabled(true);
    await _setupFirebaseMessaging();
  }

  Future<void> _setupFirebaseMessaging() async {
    try {
      final messaging = FirebaseMessaging.instance;

      // Request permission for notifications
      NotificationSettings settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      // Configure foreground notifications
      await messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      // Listen to foreground messages
      _firebaseSubscription =
          FirebaseMessaging.onMessage.listen((message) async {
        if (!_isDisposed) {
          // Save notification
          await _saveNotification(message);

          // Show notification in system tray
          await _showNotification(
            title: message.notification?.title ?? 'New Message',
            body: message.notification?.body ?? '',
            data: message.data,
          );
        }
      });

      // Handle background messages
      FirebaseMessaging.onBackgroundMessage(_handleBackgroundMessage);

      await _analytics.logEvent(name: 'notification_service_initialized');
    } catch (e) {
      print('Firebase setup error: $e');
    }
  }

  Future<void> _showNotification({
    required String title,
    required String body,
    required Map<String, dynamic> data,
  }) async {
    // Android notification channel
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      importance: Importance.max,
      enableVibration: true,
    );

    // Show the notification
    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          channel.id,
          channel.name,
          icon: '@mipmap/ic_launcher',
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
  }

  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    if (!_isDisposed) {
      await _saveNotification(message);
    }
  }

  @pragma('vm:entry-point')
  static Future<void> _handleBackgroundMessage(RemoteMessage message) async {
    await Firebase.initializeApp();
    await _saveNotification(message);
  }

  static Future<void> _saveNotification(RemoteMessage message) async {
    final notification = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'title': message.notification?.title,
      'body': message.notification?.body,
      'timestamp': DateTime.now().toString(),
      'data': message.data,
      'status': 'unread'
    };

    await NotificationState.saveNotification(notification);
  }

  Future<void> checkNotifications() async {
    final notifications = await NotificationState.getNotifications();
    _notificationController.add(null);
  }

  void dispose() {
    _isDisposed = true;
    _firebaseSubscription?.cancel();
    _notificationController.close();
  }
}
