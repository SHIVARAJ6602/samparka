import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationHandler {
  late FirebaseMessaging messaging;
  late FlutterLocalNotificationsPlugin localNotifications;
  late bool _isInitialized = false;

  // Initialize the notification handler
  Future<void> _initialize() async {
    messaging = FirebaseMessaging.instance;
    localNotifications = FlutterLocalNotificationsPlugin();
    await setupNotifications();
    await requestNotificationPermission();
    showNotification('Test', 'This is a test notification');
    setupFirebaseListeners();
    _isInitialized = true;
  }

  /***************FCM*******************/
  Future<void> requestNotificationPermission() async {
    NotificationSettings settings = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print("Notifications permission granted.");
    } else {
      print("Notifications permission denied.");
    }
  }

  bool setupNotifications() {
    try {
      var androidSettings = AndroidInitializationSettings('@drawable/ic_launcher');
      var initializationSettings = InitializationSettings(android: androidSettings);

      // Correctly passing the onSelectNotification callback
      localNotifications.initialize(initializationSettings);
      return true;
    } catch (e) {
      print("Error initializing local notifications: $e");
      return false;
    }
  }

  void showNotification(String? title, String? body) async {
    var androidDetails = AndroidNotificationDetails(
      "channelId",
      "channelName",
      importance: Importance.high,
      priority: Priority.high,
    );
    var notificationDetails = NotificationDetails(android: androidDetails);

    await localNotifications.show(0, title, body, notificationDetails);
  }

  void setupFirebaseListeners() {
    // Foreground notification handling
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("New notification received: ${message.notification?.title}");
      showNotification(message.notification?.title, message.notification?.body);
    });

    // Background/terminated notification handling
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("Notification clicked: ${message.notification?.title}");
      // Handle the logic when the user taps the notification (e.g., navigating to a specific screen)
    });

    // Handle when the app is in the background or terminated and the notification is tapped
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  static Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    print("Handling a background message: ${message.notification?.title}");
    // Perform background operations like navigating or showing the notification
  }

  // When the notification is selected/tapped
  Future<void> onSelectNotification(String? payload) async {
    // Handle logic when the user taps on the notification (e.g., navigating to a different screen)
    print("Notification tapped: $payload");
  }
}
