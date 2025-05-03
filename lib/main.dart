import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:no_screenshot/no_screenshot.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:samparka/Screens/PrivacyPolicyScreen.dart';
import 'package:samparka/Screens/home.dart'; //InfluencersPage()
import 'package:samparka/Screens/login.dart'; //LoginPage()
import 'package:samparka/Screens/error_page.dart'; //ErrorPage()
import 'package:samparka/Screens/add_influencer.dart'; //AddInfluencerPage()
import 'package:samparka/Service/api_service.dart';
import 'Screens/API_TEST.dart';
import 'Screens/temp.dart';
import 'Service/PushNotificationService.dart'; //TaskListScreen()

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure bindings are initialized
  //await Firebase.initializeApp();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  setupFCMListeners();
  NoScreenshot.instance.screenshotOff();
  //screenshotOn()
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});
  final ApiService apiService = ApiService(); // Initializing ApiService here
  final FirebaseMessaging messaging = FirebaseMessaging.instance;

  StreamSubscription<ConnectivityResult>? _subscription;
  bool _isOffline = false;


  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _wait(apiService), // Initialize ApiService and load authentication state
      builder: (context, snapshot) {
        // Handle different states of the Future
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildWaitingState();
        }

        if (snapshot.hasError) {
          // If there's an error, show an error page
          return _buildErrorState();
        }

        // Once initialization is complete, return the actual MaterialApp
        return _buildApp(apiService,context);
      },
    );
  }

  Future<bool> checkVersion() {
    return apiService.checkVersion();
  }

  // Helper function to build the waiting state screen
  Widget _buildWaitingState() {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Samparka',
      home: Scaffold(
        backgroundColor: Colors.white, // Set the background color to white
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/logo/logo.png',
                height: 150,
              ),
              const CupertinoActivityIndicator(
                color: Colors.green,
                radius: 20, // Customize the radius of the activity indicator
              )
            ],
          )
        ),
      ),
    );
  }


  // Helper function to build the error screen
  Widget _buildErrorState() {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Samparka',
      home: ErrorPage(),
    );
  }

  // Helper function to build the actual app depending on authentication
  Widget _buildApp(ApiService apiService,BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Samparka',
      //home: InfluencersPage(),
      //home: apiService.isAuthenticated ? const InfluencersPage() : const LoginPage(),
      home: apiService.privacyPolicyAgreed
          ? (apiService.isAuthenticated
          ? const InfluencersPage()
          : const LoginPage())
          : PrivacyPolicyScreen(
            onAccept: () {
              apiService.privacyPolicyAgreed = true;
            },
            onDecline: () {
                  SystemNavigator.pop();
                  },
          ),
    );
  }

  Future<void> _wait(ApiService apiService) async {
    //await requestNotificationPermission();
    await Future.delayed(const Duration(milliseconds: 0));
  }


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
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('🔔 Background message: ${message.messageId}');
}
