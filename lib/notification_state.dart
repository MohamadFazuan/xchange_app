import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class NotificationState {
  static const String _notificationsKey = 'MESSAGES';

  static Future<void> saveNotification(Map<String, dynamic> notification) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> notifications = prefs.getStringList(_notificationsKey) ?? [];
    notifications.add(jsonEncode(notification));
    await prefs.setStringList(_notificationsKey, notifications);
  }

  // Get all notifications
  static Future<List<Map<String, dynamic>>> getNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> notifications = prefs.getStringList(_notificationsKey) ?? [];
    return notifications.map((n) => jsonDecode(n) as Map<String, dynamic>).toList();
  }

  // Remove specific notification
  static Future<void> removeNotification(String notificationId) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> notifications = prefs.getStringList(_notificationsKey) ?? [];
    notifications.removeWhere((n) => 
      jsonDecode(n)['id'] == notificationId
    );
    await prefs.setStringList(_notificationsKey, notifications);
  }

  // Clear all notifications
  static Future<void> clearNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_notificationsKey);
  }
}