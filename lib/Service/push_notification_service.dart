import 'dart:developer';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:samparka/Screens/view_meeting.dart';
import '../utils/global_navigator_key.dart';
import 'api_service.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();
//final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> handleMessageData(Map<String, dynamic> data) async {

  final screen = data['screen'];
  final id = data['id'];
  final typeId = data['meetingTypeId'] ?? '';
  Map<String, dynamic> eventData;

  Future<Map<String, dynamic>> fetchEventData() async {
    try {
      final apiService = ApiService();
      final result = await apiService.getEventByID(id, typeId);
      if (result.isNotEmpty) {
        return eventData = result[0];
      }
    } catch (e) {
      log("Error loading event: $e");
    }
    return {}; // Return empty map if error occurs or result is empty
  }

  if (screen == 'ViewEvent' && id != null) {
    eventData = await fetchEventData();
    navigatorKey.currentState?.push(
      MaterialPageRoute(
        builder: (_) => ViewEventPage(id, eventData,typeId),
      ),
    );
  }

}


Future<void> setupFCMListeners() async {
  const AndroidInitializationSettings initializationSettingsAndroid =
  AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  // Handle foreground messages
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    log('Foreground: ${message.notification?.title}');

    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;

    if (notification != null && android != null) {
      flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'channel_id', // must match with AndroidManifest
            'App Notifications',
            importance: Importance.max,
            priority: Priority.high,
            showWhen: true,
          ),
        ),
      );
    }
  });

  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    log('Notification clicked: ${message.data}');
    handleMessageData(message.data);
  });

  // App launched via notification (terminated state)
  FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
    if (message != null) {
      log('App launched from notification: ${message.data}');
      handleMessageData(message.data);
    }
  });
}
