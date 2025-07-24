import 'dart:async';
import 'dart:developer';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:new_version_plus/new_version_plus.dart';
import 'package:no_screenshot/no_screenshot.dart';
import 'package:samparka/Screens/PrivacyPolicyScreen.dart';
import 'package:samparka/Screens/home.dart'; //InfluencersPage()
import 'package:samparka/Screens/login.dart'; //LoginPage()
import 'package:samparka/Screens/error_page.dart'; //ErrorPage()
import 'package:samparka/Service/api_service.dart';
import 'Screens/ForceUpdatePage.dart';
import 'Service/PushNotificationService.dart'; //TaskListScreen()

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure bindings are initialized
  //await Firebase.initializeApp();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  setupFCMListeners();
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: Colors.transparent, // or any color you want
    statusBarIconBrightness: Brightness.dark, // use Brightness.dark for black icons
    statusBarBrightness: Brightness.light, // for iOS (optional)
  ));
  NoScreenshot.instance.screenshotOff();
  //screenshotOn()
  //runApp(MyApp());
  //runApp(VersionCheck()); //MyApp called inside VersionCheck

  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: ForceUpdatePage(nextPage: MyApp()),
  ));
}


class MyApp extends StatelessWidget {
  MyApp({super.key});
  final ApiService apiService = ApiService(); // Initializing ApiService here
  final FirebaseMessaging messaging = FirebaseMessaging.instance;

  StreamSubscription<ConnectivityResult>? _subscription;
  final bool _isOffline = false;


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
    if(apiService.devVersion){
      NoScreenshot.instance.screenshotOff();
    }
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
    await Future.delayed(const Duration(milliseconds: 2000));
  }


  Future<void> requestNotificationPermission() async {
    NotificationSettings settings = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      log("Notifications permission granted.");
    } else {
      log("Notifications permission denied.");
    }
  }
}

class VersionCheck extends StatefulWidget {
  const VersionCheck({super.key});

  @override
  VersionCheckState createState() => VersionCheckState();
}

class VersionCheckState extends State<VersionCheck> {
  bool _isReady = false;

  @override
  void initState() {
    super.initState();
    log('check vr called');
    _checkVersion();
    log('call ended vr');
  }

  void _checkVersion() async {
    final newVersion = NewVersionPlus(
      androidId: "com.samparkamysuru.samparka", // ✅ replace with your real Android package ID
      iOSId: "000000000", // ✅ replace with your real iOS App Store ID
    );

    final status = await newVersion.getVersionStatus();

    if (status != null) {
      log("Local version: ${status.localVersion}");
      log("Store version: ${status.storeVersion}");
      log("App store link: ${status.appStoreLink}");
      log("Can update: ${status.canUpdate}");
    } else {
      log("Version status is null.");
    }

    if (status != null && status.canUpdate) {
      newVersion.showUpdateDialog(
        context: context,
        versionStatus: status,
        dialogTitle: "Update Required",
        dialogText:
        "A new version (${status.storeVersion}) is available. Please update the app to continue.",
        updateButtonText: "Update Now",
        dismissButtonText: "Later",
        allowDismissal: false, // ❗ Force the user to update
      );
    } else {
      setState(() => _isReady = true); // Proceed to app
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isReady) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: Colors.white,
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

    return MyApp(); // ✅ launch your app when version check is done
  }
}


Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  log('🔔 Background message: ${message.messageId}');
}
