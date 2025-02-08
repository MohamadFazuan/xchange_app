import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'package:xchange_app/login_state.dart';
import 'package:xchange_app/match_exchange.dart';
import 'package:xchange_app/notification_state.dart';
import 'package:xchange_app/qr_code_content.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  StreamSubscription? _firebaseSubscription;
  bool _isDisposed = false;
  String? username;
  List<Map<String, dynamic>> notifications = [];

  @override
  void initState() {
    super.initState();
    _loadSavedNotifications();
    _setupFirebaseMessaging();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _firebaseSubscription?.cancel();
    super.dispose();
  }

  Future<void> _setupFirebaseMessaging() async {
    try {
      FirebaseMessaging messaging = FirebaseMessaging.instance;

      _firebaseSubscription = FirebaseMessaging.onMessage.listen((message) {
        if (!_isDisposed && mounted) {
          _handleNewNotification(message);
          _loadSavedNotifications(); // Reload after new notification
        }
      });
    } catch (e) {
      print('Firebase setup error: $e');
    }
  }

  Future<void> _handleNewNotification(RemoteMessage message) async {
    final notification = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'title': message.notification?.title,
      'body': message.notification?.body,
      'timestamp': DateTime.now().toString(),
      'data': message.data,
      'status': 'unread'
    };

    await NotificationState.saveNotification(notification);
    _loadSavedNotifications();
  }

  Future<void> _loadSavedNotifications() async {
    if (!mounted) return;

    try {
      final savedNotifications = await NotificationState.getNotifications();
      setState(() {
        notifications = savedNotifications;
      });
    } catch (e) {
      print('Error loading notifications: $e');
    }
  }

  Future<void> _handleNotificationAction(
      String notificationId, String action) async {
    if (action == 'accept') {
      final notification = notifications
          .firstWhere((n) => n['id'] == notificationId, orElse: () => {});
      if (notification.isNotEmpty) {
        showModalBottomSheet(
          context: context,
          showDragHandle: true,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          builder: (context) {
            return QRCodeContent(
              dataQr: notification['data']?['dataQr'] ?? 'No QR Code Data',
            );
          },
        );

        await NotificationState.removeNotification(notificationId);
        _loadSavedNotifications();
      }
    } else if (action == 'reject') {
      await NotificationState.removeNotification(notificationId);
      _loadSavedNotifications();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: notifications.isEmpty
          ? const Center(child: Text('No notifications'))
          : ListView.builder(
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return Card(
                  margin: const EdgeInsets.all(8.0),
                  child: ListTile(
                    title: Text(notification['title'] ?? ''),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(notification['body'] ?? ''),
                        Text(
                          notification['timestamp'] ?? '',
                          style:
                              const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.check, color: Colors.green),
                          onPressed: () => _handleNotificationAction(
                              notification['id'], 'accept'),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.red),
                          onPressed: () => _handleNotificationAction(
                              notification['id'], 'reject'),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
