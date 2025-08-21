import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/app_notification.dart';

class AppNotificationService {
  static const _storageKey = 'app_notifications';

  // Load all notifications
  static Future<List<AppNotification>> getNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final rawList = prefs.getStringList(_storageKey) ?? [];
    return rawList.map((e) => AppNotification.fromJson(jsonDecode(e))).toList();
  }

  // Save notifications list
  static Future<void> _saveAll(List<AppNotification> notifs) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setStringList(_storageKey, notifs.map((n) => jsonEncode(n.toJson())).toList());
  }

  // Add a new notification
  static Future<void> addNotification(AppNotification notif) async {
    final notifications = await getNotifications();
    notifications.insert(0, notif); // newest on top
    await _saveAll(notifications);
  }

  // Mark all notifications as read
  static Future<void> setAllRead() async {
    final notifications = await getNotifications();
    for(final n in notifications) { n.read = true; }
    await _saveAll(notifications);
  }

  // Mark specific notification as read
  static Future<void> setRead(String id) async {
    final notifications = await getNotifications();
    for(final n in notifications) {
      if(n.id == id) n.read = true;
    }
    await _saveAll(notifications);
  }

  // Get unread count
  static Future<int> getUnreadCount() async {
    final notifications = await getNotifications();
    return notifications.where((n) => !n.read).length;
  }
}
