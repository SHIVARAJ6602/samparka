import 'dart:developer';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

void handleMessageData(Map<String, dynamic> data, BuildContext context) {
  final screen = data['screen'];
  final id = data['id'];

  if (screen == 'event_detail' && id != null) {
    Navigator.pushNamed(
      context,
      '/event_detail',
      arguments: {'id': id}, // or just `id` depending on your route setup
    );
  } else if (screen == 'Baitak' && id != null) {
    Navigator.pushNamed(
      context,
      '/Baitak',
      arguments: {'id': id}, // or just `id` depending on your route setup
    );
  } else if (screen == 'program' && id != null) {
    Navigator.pushNamed(
      context,
      '/program',
      arguments: {'id': id}, // or just `id` depending on your route setup
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
    log('📬 Foreground: ${message.notification?.title}');

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
    log('📲 Notification clicked: ${message.data}');
    //handleMessageData(message.data, context);
  });

  FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
    if (message != null) {
      log('🚀 App launched from notification: ${message.data}');
      //handleMessageData(message.data, context);
    }
  });
}
