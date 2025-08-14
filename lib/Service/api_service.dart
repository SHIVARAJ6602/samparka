import 'dart:convert';
import 'dart:io';
import 'dart:developer';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:samparka/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image/image.dart' as img;

class ApiService {
  late String baseUrl0 = "https://samparka.org/api";
  late String baseUrl1 = "https://samparka.org/api";
  late String baseUrl2 = "https://t6q7lj15-8000.inc1.devtunnels.ms/api";
  late String baseUrl3 = "https://llama-curious-adequately.ngrok-free.app/api";
  late String baseUrl = 'https://samparka.org/api';
  late String token = '';
  late int lvl = 0;
  late var profileImage = '';
  late String UserId = '';
  late String phone = '';
  late String first_name = '';
  late String user_name = '';
  late String last_name = '';
  late String designation = '';
  late String city = '';
  late String district = '';
  late String state = '';
  late bool isAuthenticated = false;
  late bool shouldUpdate = false;
  late bool privacyPolicyAgreed = false;
  late bool devVersion = true;
  late Dio dio;
  late CookieJar cookieJar;
  late FirebaseMessaging messaging;
  late FlutterLocalNotificationsPlugin localNotifications;
  late bool _isInitialized = false;
  late String txt = '...';
  late FlutterSecureStorage secureStorage;

  Future<void> _initialize() async {
    dio = Dio();
    cookieJar = CookieJar();
    dio.interceptors.add(CookieManager(cookieJar));
    messaging = FirebaseMessaging.instance;
    localNotifications = FlutterLocalNotificationsPlugin();
    setupNotifications();
    requestNotificationPermission();
    //showNotification('Test','this is a test notification');
    secureStorage = const FlutterSecureStorage();
    await loadData();

    try {
      final response = await dio.get(baseUrl.toString().substring(0, baseUrl.length-4));
      if (response.statusCode == 200) {
        log('Ping successful!', name: 'PingCheck', level: 200);
      } else {
        log('Failed to ping. Status Code: ${response.statusCode}', name: 'PingCheck', level: 900);
      }
    } catch (e) {
      log('Ping failed. Error: $e');
    }
    _isInitialized = true;
  }

  /// ***************FCM*************************

  /*
  Future<void> _requestPermissions() async {
    if (Platform.isIOS || Platform.isMacOS) {
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
          MacOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
    } else if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
      flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();

      final bool? grantedNotificationPermission =
      await androidImplementation?.requestNotificationsPermission();
      setState(() {
        _notificationsEnabled = grantedNotificationPermission ?? false;
      });
    }
  }
  */

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

  bool setupNotifications() {
    try{
      var androidSettings = AndroidInitializationSettings('@drawable/ic_launcher');
      var initializationSettings = InitializationSettings(android: androidSettings);

      localNotifications.initialize(initializationSettings);
      return true;
    }
    catch (e) {
      return false;
    }
  }

  void showNotification(String? title, String? body) async {
    var androidDetails = AndroidNotificationDetails(
        "channelId", "channelName",
        importance: Importance.high, priority: Priority.high);
    var notificationDetails = NotificationDetails(android: androidDetails);

    await localNotifications.show(0, title, body, notificationDetails);
  }

  void setupFirebaseListeners() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      log("New notification received: ${message.notification?.title}");
      showNotification(message.notification?.title, message.notification?.body);
    });
  }
  /// ******************FCM - END*************************

  Future<bool> checkVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    log("App Version: ${packageInfo.version}");
    log("Build Number: ${packageInfo.buildNumber}");
    return true;
  }

  Future<bool> saveDataShareOnly() async {
    try {
      //log('Token: $token');
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString("token", token ?? '');
      await prefs.setString('baseUrl', baseUrl ?? '');
      await prefs.setString('phone_number', phone ?? 'Error');
      await prefs.setBool("isAuthenticated", isAuthenticated ?? false);
      await prefs.setBool("privacyPolicyAgreed", privacyPolicyAgreed ?? false);
      await prefs.setString("userName", first_name ?? '');
      await prefs.setInt("level", lvl ?? 1);
      await prefs.setString("city", city ?? '');
      await prefs.setString("district", district ?? '');
      await prefs.setString("state", state ?? '');
      await prefs.setString("profile_image", profileImage ?? '');
      log("Data Saved Successfully");
      return true;
    } catch (e) {
      log("Error saving data: $e");
      return false;
    }
  }

  Future<void> loadDataSharedOnly() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    baseUrl = prefs.getString('baseUrl') ?? baseUrl;
    token = prefs.getString("token") ?? '';
    phone = prefs.getString("phone_number") ?? '';
    first_name = prefs.getString("userName") ?? '';
    lvl = prefs.getInt("level")??1;
    isAuthenticated = prefs.getBool("isAuthenticated") ?? isAuthenticated;
    privacyPolicyAgreed = prefs.getBool("privacyPolicyAgreed") ?? privacyPolicyAgreed;
    profileImage = prefs.getString("profile_image") ?? profileImage;
    city = prefs.getString('city') ?? city;
    district = prefs.getString('district') ?? district;
    state = prefs.getString('state') ?? state;
    log("DataLoaded");
  }

  Future<bool> saveData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      // Save sensitive data securely
      await secureStorage.write(key: "token", value: token ?? '');
      await secureStorage.write(key: "phone_number", value: phone ?? 'Error');

      // Save non-sensitive data
      await prefs.setString('baseUrl', baseUrl ?? '');
      await prefs.setBool("isAuthenticated", isAuthenticated ?? false);
      await prefs.setBool("privacyPolicyAgreed", privacyPolicyAgreed ?? false);
      await prefs.setString("userName", user_name ?? '');
      await prefs.setString("firstName", first_name ?? '');
      await prefs.setString("lastName", last_name ?? '');
      await prefs.setInt("level", lvl ?? 1);
      await prefs.setString("city", city ?? '');
      await prefs.setString("district", district ?? '');
      await prefs.setString("state", state ?? '');
      await prefs.setString("profile_image", profileImage ?? '');

      log("Data Saved Successfully");
      return true;
    } catch (e) {
      log("Error saving data: $e");
      return false;
    }
  }

  Future<void> loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Load sensitive data securely
    token = await secureStorage.read(key: "token") ?? '';
    phone = await secureStorage.read(key: "phone_number") ?? 'Error';

    // Load non-sensitive data
    baseUrl = prefs.getString('baseUrl') ?? baseUrl;
    user_name = prefs.getString("userName") ?? '';
    first_name = prefs.getString("firstName") ?? '';
    last_name = prefs.getString("lastName") ?? '';
    lvl = prefs.getInt("level") ?? 1;
    isAuthenticated = prefs.getBool("isAuthenticated") ?? false;
    privacyPolicyAgreed = prefs.getBool("privacyPolicyAgreed") ?? false;
    profileImage = prefs.getString("profile_image") ?? profileImage;
    city = prefs.getString('city') ?? city;
    district = prefs.getString('district') ?? district;
    state = prefs.getString('state') ?? state;

    log("Data Loaded");
  }



  Future<Uint8List> resizeImage(Uint8List imageBytes) async {
    // Decode the image (supports JPEG, PNG, etc.)
    img.Image? image = img.decodeImage(imageBytes);

    if (image == null) {
      throw Exception("Unable to decode the image");
    }

    // Get the current width and height of the image
    int width = image.width;
    int height = image.height;

    // Determine the resizing factor based on the larger dimension
    double factor = 600.0 / (width > height ? width : height);

    // Calculate the new dimensions to maintain the aspect ratio
    int newWidth = (width * factor).round();
    int newHeight = (height * factor).round();

    // Resize the image proportionally
    img.Image resizedImage = img.copyResize(image, width: newWidth, height: newHeight);

    // Encode the resized image to JPEG format
    Uint8List resizedImageBytes = Uint8List.fromList(img.encodeJpg(resizedImage));

    return resizedImageBytes;
  }

  Future<bool> registerUser(List<dynamic> data) async {
    try {

      // Check if token is null or empty before making the request
      if (token.isEmpty) {
        log('Error: Authorization token is missing');
        return false;
      }
      File orgImage = await data[8];
      List<int> resizedImageBytes = await imageResize(orgImage, true, 600);
      // Convert the byte array into a MultipartFile (temporary file)
      String tempFilePath = '${Directory.systemTemp.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';
      File tempFile = File(tempFilePath)..writeAsBytesSync(resizedImageBytes);

      // Create a MultipartFile from the resized temporary file
      MultipartFile resizedImage = await MultipartFile.fromFile(tempFile.path, filename: tempFile.uri.pathSegments.last);

      FormData formData = FormData.fromMap({
        "action": "register",
        "phone_number": data[0],
        "first_name": data[1],
        "last_name": data[2],
        "email": data[3],
        "designation": data[4],
        "password": data[5],
        "group": data[6],
        "supervisor": UserId,
        //"supervisor": 'AD00000001',
        "shreni_id": data[7],
        "profile_image": resizedImage,
        "city": data[9],
        "district": data[10],
        "state": data[11],
        "user_type": data[13],
      });

      dio.options.headers['Authorization'] = 'Token $token';

      // Send registration request to the server
      final response = await dio.post(
        '$baseUrl/callHandler/',
        data: formData,
      );

      // Handle server response status
      if (response.statusCode == 200 || response.statusCode == 201) {
        log("User registered successfully");
        return true;
      } else {
        // Capture error message from the server response, if available
        var errorData = response.data;
        String errorMessage = errorData['message'] ?? 'Unknown error';
        log('Registration failed: $errorMessage');
        throw Exception('Registration failed: $errorMessage');
      }
    } catch (e) {
      // Handle unexpected errors such as network issues or invalid responses
      log('Error during registration: $e');
      return false;
    }
  }

  Future<bool> updateUser(List<dynamic> userData, String userId) async {
    try {
      if (token.isEmpty) {
        log('Error: Authorization token is missing');
        return false;
      }

      Map<String, dynamic> updatePayload = {};

      void addIfValid(String key, dynamic value) {
        if (value != null) {
          if (value is String && value.trim().isEmpty) return;
          updatePayload[key] = value;
        }
      }

      // Optional image
      if (userData[8] != null && userData[8] is File) {
        File orgImage = userData[8];
        List<int> resizedImageBytes = await imageResize(orgImage, true, 600);
        String tempFilePath = '${Directory.systemTemp.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';
        File tempFile = File(tempFilePath)..writeAsBytesSync(resizedImageBytes);
        MultipartFile resizedImage = await MultipartFile.fromFile(tempFile.path, filename: tempFile.uri.pathSegments.last);
        updatePayload['profile_image'] = resizedImage;
      }

      addIfValid("phone_number", userData[0]);
      addIfValid("first_name", userData[1]);
      addIfValid("last_name", userData[2]);
      addIfValid("email", userData[3]);
      addIfValid("designation", userData[4]);
      addIfValid("description", userData[5]);
      addIfValid("address", userData[6]);
      addIfValid("city", userData[9]);
      addIfValid("district", userData[10]);
      addIfValid("state", userData[11]);
      addIfValid("shreni_id", userData[7]);

      updatePayload["KR_id"] = userId;
      updatePayload["action"] = "UpdateKaryakartha";

      FormData formData = FormData.fromMap(updatePayload);
      dio.options.headers['Authorization'] = 'Token $token';

      final response = await dio.post('$baseUrl/callHandler/', data: formData);

      if (response.statusCode == 200 || response.statusCode == 204) {
        //log("User updated successfully");
        return true;
      } else {
        //log('Update failed: ${response.statusCode}, ${response.data}');
        return false;
      }
    } catch (e) {
      log('Error during update: $e');
      return false;
    }
  }

  ApiService._privateConstructor();

  // The single instance of ApiService
  //static final ApiService _instance = ApiService._privateConstructor();
  static final ApiService _instance = ApiService._privateConstructor();

  factory ApiService() {
    if (!_instance._isInitialized) {
      _instance._initialize();
    }
    return _instance;
  }

  Future<List<dynamic>> homePage() async{
    try {
      // Check if token is null or empty before making the request
      if (token.isEmpty) {
        log('Error: Authorization token is missing');
        throw Exception('Failed: No Auth Token');
      }
      dio.options.headers['Authorization'] = 'Token $token';
      // Send registration request to the server
      final response = await dio.post(
        '$baseUrl/callHandler/',
        data: {
          "action":"homePage",
        },
      );
      // Handle server response status
      if (response.statusCode == 200) {
        if (response.data is List<dynamic>) {
          return response.data;
        } else if (response.data is String) {
          final parsedData = List<dynamic>.from(response.data);
          return parsedData;
        } else {
          throw Exception('Expected a List, but got ${response.data.runtimeType}');
        }
      } else {
        throw Exception('Failed to load tasks. Status code: ${response.statusCode}');
      }
    } catch (e) {
      // Handle unexpected errors such as network issues or invalid responses
      log('Error: $e');
      throw Exception('Failed to load tasks: $e');
    }
  }

  Future<bool> getUser(BuildContext context) async  {
    dio.options.headers['Authorization'] = 'Token $token';

    try {
      final response = await dio.get('$baseUrl/callHandler/');

      if (response.statusCode == 200) {
        var userData = response.data['data'];
        UserId = userData['id'] ?? '';
        phone = userData['phone_number'] ?? 'Error';
        first_name = userData['first_name'] ?? '';
        last_name = userData['last_name'] ?? '';
        lvl = userData['level'] ?? 1;
        city = userData['city'] ?? '';
        district = userData['district'] ?? '';
        profileImage = userData['profile_image'] ?? '';
        state = userData['state'] ?? '';
        designation = userData['designation'] ?? 'None';

        await saveData();
        await loadData();

        return true;
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        log('401 Error: Unauthorized');
        this.isAuthenticated = false;
        this.token = '';
        await saveData();
        await loadData();
        showDialogMsg(context, 'You Have been logged Out', 'Please Sign in again!');
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => MyApp()),
                (route) => false, // removes all previous routes
          );
        });
        return false;
      } else {
        log('Dio error: ${e.response?.statusCode} - ${e.message}');
        // You could also show a dialog/snackbar depending on the use case
      }
    } catch (e) {
      log('Unexpected error: $e');
    }

    return false;
  }

  Future<dynamic> getHashtags() async  {
    dio.options.headers['Authorization'] = 'Token $token';

    try {
      final response = await dio.post(
        '$baseUrl/callHandler/',
        data: {
          "action":"getHashtags",
        },
      );

      if (response.statusCode == 200) {
        // Assuming the response data contains a list of user data.
        return response.data;
      }

    } catch (e) {
      log('Error: $e');
      throw Exception('Failed to load user data: $e');
    }
    return false;
  }

  Future<List<dynamic>> getInfluencer(int sCount,int eCount,String krId) async{
    try {
      // Check if token is null or empty before making the request
      if (token.isEmpty) {
        log('Error: Authorization token is missing');
        throw Exception('Failed: No Auth Token');
      }
      dio.options.headers['Authorization'] = 'Token $token';
      // Send registration request to the server
      final response = await dio.post(
        '$baseUrl/callHandler/',
        data: {
          'action':"getInfluencers",
          'orderby':'date_approved',
          'KR_id': krId,
          'sCount':sCount,
          'eCount':eCount,
        },
      );
      // Handle server response status
      if (response.statusCode == 200) {
        if (response.data is List<dynamic>) {
          return response.data;
        } else if (response.data is String) {
          final parsedData = List<dynamic>.from(response.data);
          return parsedData;
        } else {
          throw Exception('Expected a List, but got ${response.data.runtimeType}');
        }
      } else {
        throw Exception('Failed to load tasks. Status code: ${response.statusCode}');
      }
    } catch (e) {
      // Handle unexpected errors such as network issues or invalid responses
      log('Error: $e');
      throw Exception('Failed to load tasks: $e');
    }
  }

  Future<int> getInfluencerCount(String krId) async {
    try {
      // Check if token is null or empty before making the request
      if (token.isEmpty) {
        log('Error: Authorization token is missing');
        throw Exception('Failed: No Auth Token');
      }

      dio.options.headers['Authorization'] = 'Token $token';

      // Send request to get the count of influencers
      final response = await dio.post(
        '$baseUrl/callHandler/',
        data: {
          'action': "getInfluencerCount", // <-- updated action
          'KR_id': krId,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map<String, dynamic> && data.containsKey('count')) {
          return data['count'] as int;
        } else {
          throw Exception('Invalid response format: ${response.data}');
        }
      } else {
        throw Exception('Failed to get count. Status code: ${response.statusCode}');
      }
    } catch (e) {
      log('Error: $e');
      throw Exception('Failed to get influencer count: $e');
    }
  }


  Future<List<dynamic>> get_unapproved_profiles() async {
    dio.options.headers['Authorization'] = 'Token $token';

    try {
      final response = await dio.post('$baseUrl/callHandler/',data: {'action':'get_unapproved_profiles'});
      //log(response.data);

      if (response.statusCode == 200) {
        //log('my supervisor ${response.data}');

        if (response.statusCode == 200) {
          if (response.data is List<dynamic>) {
            return response.data;
          } else if (response.data is String) {
            final parsedData = List<dynamic>.from(response.data);
            return parsedData;
          } else {
            throw Exception('Expected a List, but got ${response.data.runtimeType}');
          }
        } else {
          throw Exception('Failed to load Unapproved Influencer. Status code: ${response.statusCode}');
        }
      } else {
        throw Exception('Failed to load supervisor. Status code: ${response.statusCode}');
      }


    } catch (e) {
      log('Error: $e');
      throw Exception('Failed to load supervisor: $e');
    }
  }

  Future<List<dynamic>> myTeam(int sCount,int eCount) async{
    try {
      // Check if token is null or empty before making the request
      if (token.isEmpty) {
        log('Error: Authorization token is missing');
        throw Exception('Failed: No Auth Token');
      }
      dio.options.headers['Authorization'] = 'Token $token';
      // Send registration request to the server
      final response = await dio.post(
        '$baseUrl/callHandler/',
        data: {
          "action":"myTeam",
        },
      );
      // Handle server response status
      if (response.statusCode == 200) {
        if (response.data is List<dynamic>) {
          return response.data;
        } else if (response.data is String) {
          final parsedData = List<dynamic>.from(response.data);
          return parsedData;
        } else {
          throw Exception('Expected a List, but got ${response.data.runtimeType}');
        }
      } else {
        throw Exception('Failed to load tasks. Status code: ${response.statusCode}');
      }
    } catch (e) {
      // Handle unexpected errors such as network issues or invalid responses
      log('Error: $e');
      throw Exception('Failed to load tasks: $e');
    }
  }

  Future<List<dynamic>> myMJMembers(int sCount,int eCount) async{
    try {
      // Check if token is null or empty before making the request
      if (token.isEmpty) {
        log('Error: Authorization token is missing');
        throw Exception('Failed: No Auth Token');
      }
      dio.options.headers['Authorization'] = 'Token $token';
      // Send registration request to the server
      final response = await dio.post(
        '$baseUrl/callHandler/',
        data: {
          "action":"myMJMembers",
        },
      );
      // Handle server response status
      if (response.statusCode == 200) {
        if (response.data is List<dynamic>) {
          return response.data;
        } else if (response.data is String) {
          final parsedData = List<dynamic>.from(response.data);
          return parsedData;
        } else {
          throw Exception('Expected a List, but got ${response.data.runtimeType}');
        }
      } else {
        throw Exception('Failed to load tasks. Status code: ${response.statusCode}');
      }
    } catch (e) {
      // Handle unexpected errors such as network issues or invalid responses
      log('Error: $e');
      throw Exception('Failed to load tasks: $e');
    }
  }

  Future<List<dynamic>> getGatanayak(String KR_id) async{
    try {
      // Check if token is null or empty before making the request
      if (token.isEmpty) {
        log('Error: Authorization token is missing');
        throw Exception('Failed: No Auth Token');
      }
      dio.options.headers['Authorization'] = 'Token $token';
      // Send registration request to the server
      final response = await dio.post(
        '$baseUrl/callHandler/',
        data: {
          "action":"getGatanayak",
          "KR_id":KR_id,
        },
      );
      // Handle server response status
      if (response.statusCode == 200) {
        if (response.data is List<dynamic>) {
          return response.data;
        } else if (response.data is String) {
          final parsedData = List<dynamic>.from(response.data);
          return parsedData;
        } else {
          throw Exception('Expected a List, but got ${response.data.runtimeType}');
        }
      } else {
        throw Exception('Failed to load tasks. Status code: ${response.statusCode}');
      }
    } catch (e) {
      // Handle unexpected errors such as network issues or invalid responses
      log('Error: $e');
      throw Exception('Failed to load tasks: $e');
    }
  }

  Future<List<dynamic>> getShreniPramukhs(String krId) async{
    try {
      // Check if token is null or empty before making the request
      if (token.isEmpty) {
        log('Error: Authorization token is missing');
        throw Exception('Failed: No Auth Token');
      }
      dio.options.headers['Authorization'] = 'Token $token';
      // Send registration request to the server
      final response = await dio.post(
        '$baseUrl/callHandler/',
        data: {
          "action":"getShreniPramukhs",
          "krId": krId,
        },
      );
      // Handle server response status
      if (response.statusCode == 200) {
        if (response.data is List<dynamic>) {
          return response.data;
        } else if (response.data is String) {
          final parsedData = List<dynamic>.from(response.data);
          return parsedData;
        } else {
          throw Exception('Expected a List, but got ${response.data.runtimeType}');
        }
      } else {
        throw Exception('Failed to load tasks. Status code: ${response.statusCode}');
      }
    } catch (e) {
      // Handle unexpected errors such as network issues or invalid responses
      log('Error: $e');
      throw Exception('Failed to load tasks: $e');
    }
  }

  Future<bool> createGanyaVyakthi(BuildContext context, List<dynamic> UserData) async {
    try {
      if (token.isEmpty) {
        log('Error: Authorization token is missing');
        showDialogMsg(context, 'Authorization Error', 'Token is missing. Please login again.');
        return false;
      }

      File orgImage = await UserData[14];
      List<int> resizedImageBytes = await imageResize(orgImage, true, 600);
      String tempFilePath = '${Directory.systemTemp.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';
      File tempFile = File(tempFilePath)..writeAsBytesSync(resizedImageBytes);

      MultipartFile resizedImage = await MultipartFile.fromFile(
        tempFile.path,
        filename: tempFile.uri.pathSegments.last,
      );

      FormData formData = FormData.fromMap({
        "action": "CreateGanyaVyakti",
        "fname": UserData[1],
        "lname": UserData[2],
        "phone_number": UserData[0],
        "assigned_karyakarta_id": UserData[15],
        "designation": UserData[4],
        "description": UserData[5],
        "hashtags": UserData[6],
        "organization": UserData[7],
        "email": UserData[3],
        "impact_on_society": UserData[8],
        "interaction_level": UserData[9],
        "address": UserData[10],
        "city": UserData[11],
        "district": UserData[12],
        "state": UserData[13],
        "address_2": UserData[10],
        "city_2": UserData[11],
        "district_2": UserData[12],
        "state_2": UserData[13],
        "profile_image": resizedImage,
        "shreni": UserData[16],
        "soochi": UserData[17],
        "isTest": UserData[18],
      });

      dio.options.headers['Authorization'] = 'Token $token';

      final response = await dio.post(
        '$baseUrl/callHandler/',
        data: formData,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final message = response.data['message'] ?? 'Profile created successfully.';
        showDialogMsg(context, 'Registration Successful', message);
        return true;
      } else {
        final errorMessage = response.data['message'] ?? 'Registration failed. Please try again.';
        showDialogMsg(context, 'Registration Failed', errorMessage);
        return false;
      }
    } catch (e) {
      if (e is DioException) {
        final response = e.response;
        final errorMessage = response?.data['message'] ??
            'Make sure all fields are filled! \n code ${response?.statusCode ?? 'unknown'}';

        showDialogMsg(context, 'Registration Failed', errorMessage);
        log('DioException: $errorMessage');
        return false;
      } else {
        showDialogMsg(context, 'Unexpected Error', 'An error occurred: $e');
        log('Unexpected error during registration: $e');
        return false;
      }
    }
  }

  Future<bool> updateGanyaVyakthi(List<dynamic> UserData, String gvId) async {
    try {
      if (token.isEmpty) {
        log('Error: Authorization token is missing');
        return false;
      }

      Map<String, dynamic> updatePayload = {};

      // Optional fields — only include them if they're not null or empty
      void addIfValid(String key, dynamic value) {
        if (value != null) {
          if (value is String && value.trim().isEmpty) return;
          updatePayload[key] = value;
        }
      }

      // Optional image resizing
      if (UserData[14] != null) {
        File orgImage = await UserData[14];
        List<int> resizedImageBytes = await imageResize(orgImage, true, 600);
        String tempFilePath = '${Directory.systemTemp.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';
        File tempFile = File(tempFilePath)..writeAsBytesSync(resizedImageBytes);
        MultipartFile resizedImage = await MultipartFile.fromFile(tempFile.path, filename: tempFile.uri.pathSegments.last);
        updatePayload['profile_image'] = resizedImage;
      }

      // Add only the changed/filled fields
      addIfValid("fname", UserData[1]);
      addIfValid("lname", UserData[2]);
      addIfValid("phone_number", UserData[0]);
      addIfValid("assigned_karyakarta_id", UserData[15]);
      addIfValid("designation", UserData[4]);
      addIfValid("description", UserData[5]);
      addIfValid("hashtags", UserData[6]);
      addIfValid("organization", UserData[7]);
      addIfValid("email", UserData[3]);
      addIfValid("impact_on_society", UserData[8]);
      addIfValid("interaction_level", UserData[9]);
      addIfValid("address", UserData[10]);
      addIfValid("city", UserData[11]);
      addIfValid("district", UserData[12]);
      addIfValid("state", UserData[13]);
      addIfValid("GVid", gvId);
      addIfValid("shreni", UserData[16]);
      addIfValid("soochi", UserData[17]);

      updatePayload["action"] = "UpdateGanyaVyakti";

      FormData formData = FormData.fromMap(updatePayload);

      dio.options.headers['Authorization'] = 'Token $token';

      final response = await dio.post(
        '$baseUrl/callHandler/',
        data: formData,
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      } else {
        log('Update failed: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      log('Error during update: $e');
      return false;
    }
  }

  Future<bool> deleteGanyaVyakthi(String id) async {
    try {
      dio.options.headers['Authorization'] = 'Token $token';

      final response = await dio.post(
        '$baseUrl/callHandler/',
        data: {
          "action": "deleteGanyaVyakthi",
          "gvid": id,
        },
        options: Options(
          headers: {"Content-Type": "application/json"},
        ),
      );


      if (response.statusCode == 200) {
        return true;
      } else {
        log("Deletion failed: ${response.data}");
        return false;
      }
    } catch (e) {
      log("Error deleting profile: $e");
      return false;
    }
  }

  Future<List<dynamic>> fetchTasks() async {
    dio.options.headers['Authorization'] = 'Token $token';

    try {
      return [];
      final response = await dio.get('$baseUrl/tasks/');
      if (response.statusCode == 200) {
        log(response.data);
        if (response.data is List<dynamic>) {
          return response.data;
        } else if (response.data is String) {
          final parsedData = List<dynamic>.from(response.data);
          return parsedData;
        } else {
          throw Exception('Expected a List, but got ${response.data.runtimeType}');
        }
      } else {
        throw Exception('Failed to load tasks. Status code: ${response.statusCode}');
      }
    } catch (e) {
      log('Error: $e');
      throw Exception('Failed to load tasks: $e');
    }
  }

  Future<List<dynamic>> getGroups() async {
    dio.options.headers['Authorization'] = 'Token $token';

    try {
      final response = await dio.post('$baseUrl/callHandler/', data: {'action': 'get_groups'});

      if (response.statusCode == 200) {
        if (response.data is List<dynamic>) {
          return response.data;
        }
        else if (response.data is String) {
          try {
            final parsedData = List<dynamic>.from(jsonDecode(response.data));
            return parsedData;
          } catch (e) {
            throw Exception('Failed to parse JSON: $e');
          }
        }
        else if (response.data is Map<String, dynamic>) {
          if (response.data.containsKey('groups') && response.data['groups'] is List<dynamic>) {
            return response.data['groups'];
          } else {
            throw Exception('Expected "groups" field to be a List but got ${response.data['groups']?.runtimeType}');
          }
        }
        else {
          throw Exception('Expected a List or String, but got ${response.data.runtimeType}');
        }
      } else {
        throw Exception('Failed to load Groups. Status code: ${response.statusCode}');
      }
    } catch (e) {
      log('Error: $e');
      throw Exception('Failed to load Groups: $e');
    }
  }

  Future<bool> addTask(String title) async {
    dio.options.headers['Authorization'] = 'Token $token';

    final response = await dio.post(
      '$baseUrl/tasks/',
      data: json.encode({'title': title, 'completed': false}),
    );
    if (response.statusCode != 201) {
      throw Exception('Failed to add task');
    }
    return true;
  }

  Future<int> getOTP(String phone, String mail) async {
    try {

      // Making the POST request to get OTP
      final response = await dio.post(
        "$baseUrl/loginHandler/",
        data: {'action': 'get_otp', 'mail': mail, 'phone': phone},
      );

      // Check if the response status code indicates success (e.g., 200 or 201)
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.data != null && response.data.isNotEmpty) {
          return 200; // Successfully sent OTP
        } else {
          log('Received empty response body');
          throw Exception('Empty response body');
        }
      } else {
        // If the status code is not 200 or 201, throw an error with the message from the response
        var errorData = response.data;
        log('Error Data: $errorData'); // Log the error data for debugging
        throw Exception('Failed to get OTP: ${errorData['message'] ?? 'Unknown error'}');
      }
    } catch (e) {
      log('Error getting OTP: $e'); // Catching errors from API request or response parsing

      // If the error has a response, return its status code. Otherwise, return 400.
      if (e is DioException && e.response != null) {
        return e.response!.statusCode ?? 400; // Return the status code from the error response, or 400 as fallback
      } else {
        return 400; // Return 400 for generic failure
      }
    }
  }

  Future<Response> login(BuildContext context, String phone, String otp) async {
    Response? response;
    try {
      // Make the POST request
      response = await dio.post(
        '$baseUrl/loginHandler/',
        data: {
          'action': 'login',
          'phone': phone,
          'otp': otp,
        },
      );

      // Check for success status code
      if (response.statusCode == 200 || response.statusCode == 201) {
        var responseData = response.data;

        // Ensure responseData is a Map and contains the expected keys
        if (responseData is Map<String, dynamic>) {
          token = responseData['token'];
          first_name = responseData['userName'];
          lvl = responseData['level'] ?? 1;
          //profile_image = responseData["profile_image"]??'';

          if (responseData['token'] != null) {
            await getUser(context);
            //log('Login successful. Token: $token UserName: $first_name');
            isAuthenticated = true;
            privacyPolicyAgreed = true;
            await saveData(); // Save the data as needed
            await loadData();

            // Show success dialog
            //showDialogMsg(context, 'Samparka', 'Login successful!', infoColor: Colors.green, alertColor: Colors.greenAccent);
          } else {
            // Show failure dialog
            showDialogMsg(context, 'Samparka', 'Failed to Login!');
            throw Exception('Login failed: Token not received');
          }
        } else {
          // Show failure dialog
          showDialogMsg(context, 'Samparka', 'Failed to Login!');
          throw Exception('Unexpected response format');
        }
      }

      return response;

    } catch (e) {
      if (e is DioException) {
        // Handle specific Dio exceptions
        if (e.response?.statusCode == 401) {
          showDialogMsg(context, 'Samparka', 'Invalid OTP');
          return Response(
            requestOptions: RequestOptions(path: ''), // Dummy RequestOptions
            statusCode: 401,
            data: {'message': 'Invalid OTP or authentication issue'},
          );
        } else {
          // Handle other Dio errors
          showDialogMsg(context, 'Samparka', 'Dio error: ${e.message}');
          return Response(
            requestOptions: RequestOptions(path: ''), // Dummy RequestOptions
            statusCode: 400,
            data: {'message': e.message}, // Pass the Dio error message
          );
        }
      } else {
        // Handle non-Dio errors
        showDialogMsg(context, 'Samparka', 'Unexpected error occurred: $e');
        return Response(
          requestOptions: RequestOptions(path: ''), // Dummy RequestOptions
          statusCode: 400,
          data: {'message': 'Unexpected error occurred: $e'},
        );
      }
    }
  }

  Future<bool> sendEmail(String eMail) async{
    dio.options.headers['Authorization'] = 'Token $token';
    try {
      var email = eMail;
      final response = await dio.post(
        '$baseUrl/loginHandler/',
        data: {
          'action': 'send_mail',  // Specify the action as 'login'
          'email': email,
        },
      );
      txt = response.data['message'] as String;

    } catch (e) {
      log('Error: $e');
    }
    return true;
  }

  Future<bool> logout() async {
    try{
      final response = await dio.post(
        '$baseUrl/loginHandler/',
        data: {
          'action': 'logout',
        },
      );
    } catch (e) {
      log('Error during logout: $e');
      return false;
    } finally {
      // this should be inside try after response.
      isAuthenticated = false;
      token = '';
      first_name = '';
      privacyPolicyAgreed = false;
      saveData();
      SystemNavigator.pop();
      /************/
      //await Future.delayed(const Duration(milliseconds: 1000));
    }
    return true;

  }

  Future<void> userAuth(BuildContext context) async {
    dio.options.headers['Authorization'] = 'Token $token';

    try {
      final response = await dio.get('$baseUrl/callHandler/');

      if (response.statusCode == 200) {
        showDialogMsg(context, 'Success', '$first_name $last_name is authenticated!');
      } else {
        showDialogMsg(context, 'Failed', '$first_name $last_name is not authenticated!');
        throw Exception('Failed to check user auth. Status code: ${response.statusCode}');
      }

    } catch (e) {
      log('Error: $e');
    }
  }

  Future<void> Subordinates() async {
    dio.options.headers['Authorization'] = 'Token $token';

    try {
      final response = await dio.post('$baseUrl/callHandler/',data: {'action':'Subordinates'});
      //log(response.data);

      if (response.statusCode == 200) {
        //log(response.data);
      } else {
        throw Exception('Failed to check user auth. Status code: ${response.statusCode}');
      }

    } catch (e) {
      log('Error: $e');
    }
  }

  Future<List<dynamic>> mySupervisor() async {
    dio.options.headers['Authorization'] = 'Token $token';

    try {
      final response = await dio.post('$baseUrl/callHandler/',data: {'action':'mySupervisor'});
      //log(response.data);

      if (response.statusCode == 200) {
        //log('my supervisor ${response.data}');

        if (response.data is List<dynamic>) {
          return response.data;
        } else if (response.data is Map<String, dynamic>) {
          return [response.data];
        } else {
          throw Exception('Unexpected data type: ${response.data.runtimeType}');
        }
      } else {
        throw Exception('Failed to load supervisor. Status code: ${response.statusCode}');
      }


    } catch (e) {
      log('Error: $e');
      throw Exception('Failed to load supervisor: $e');
    }
  }

  Future<List<dynamic>> myLead() async {
    dio.options.headers['Authorization'] = 'Token $token';

    try {
      final response = await dio.post('$baseUrl/callHandler/',data: {'action':'myLead'});
      //log(response.data);

      if (response.statusCode == 200) {
        //log('my Lead ${response.data}');

        if (response.data is List<dynamic>) {
          return response.data;
        } else if (response.data is Map<String, dynamic>) {
          return [response.data];
        } else {
          throw Exception('Unexpected data type: ${response.data.runtimeType}');
        }
      } else {
        throw Exception('Failed to load lead. Status code: ${response.statusCode}');
      }


    } catch (e) {
      log('Error: $e');
      throw Exception('Failed to load supervisor: $e');
    }
  }

  Future<List<dynamic>> getGanyavyakthi(String GV_id) async {
    dio.options.headers['Authorization'] = 'Token $token';

    try {
      final response = await dio.post('$baseUrl/callHandler/',data: {'action':'getGanyavyakthi','GV_id':GV_id});
      //log(response.data);

      if (response.statusCode == 200) {
        //log('GV ${response.data[0]}');

        if (response.data is List<dynamic>) {
          return response.data;
        } else if (response.data is Map<String, dynamic>) {
          return [response.data];
        } else {
          throw Exception('Unexpected data type: ${response.data.runtimeType}');
        }
      } else {
        throw Exception('Failed to load lead. Status code: ${response.statusCode}');
      }


    } catch (e) {
      log('Error: $e');
      throw Exception('Failed to load supervisor: $e');
    }
  }

  Future<List<dynamic>> getKaryakartha(String KR_id) async {
    dio.options.headers['Authorization'] = 'Token $token';

    try {
      final response = await dio.post('$baseUrl/callHandler/',data: {'action':'getKaryakartha','KR_id':KR_id});
      //log(response.data);

      if (response.statusCode == 200) {
        //log('RV ${response.data[0]}');

        if (response.data is List<dynamic>) {
          return response.data;
        } else if (response.data is Map<String, dynamic>) {
          return [response.data];
        } else {
          throw Exception('Unexpected data type: ${response.data.runtimeType}');
        }
      } else {
        throw Exception('Failed to load lead. Status code: ${response.statusCode}');
      }


    } catch (e) {
      log('Error: $e');
      throw Exception('Failed to load supervisor: $e');
    }
  }

  Future<List<dynamic>> approveGanyavyakthi(String GV_id,String KR_id) async {
    dio.options.headers['Authorization'] = 'Token $token';

    try {
      final response = await dio.post('$baseUrl/callHandler/',
          data: {'action':'ApproveGanyaVyakti','GV_id':GV_id,'KR_id':KR_id}
      );
      //log(response.data);

      if (response.statusCode == 200) {
        //log('my supervisor ${response.data}');

        if (response.data is List<dynamic>) {
          return response.data;
        } else if (response.data is Map<String, dynamic>) {
          return [response.data];
        } else {
          throw Exception('Unexpected data type: ${response.data.runtimeType}');
        }
      } else {
        throw Exception('Failed to load supervisor. Status code: ${response.statusCode}');
      }


    } catch (e) {
      log('Error: $e');
      throw Exception('Failed to load supervisor: $e');
    }
  }

  Future<void> RecurSubordinates() async {
    dio.options.headers['Authorization'] = 'Token $token';

    try {
      final response = await dio.post('$baseUrl/callHandler/',data: {'action':'RecursiveSubordinates'});

      if (response.statusCode == 200) {
        log("Recuring subordinates fetched");
        //log(response.data);
      } else {
        throw Exception('Failed to check user auth. Status code: ${response.statusCode}');
      }

    } catch (e) {
      log('Error: $e');
    }
  }

  Future<bool> createTask(String gv_id, String title) async {
    dio.options.headers['Authorization'] = 'Token $token';

    try {
      final response = await dio.post(
        '$baseUrl/callHandler/',
        data: {'action': 'create_task','GV_id': gv_id,'task_name': title,},
      );

      // Check if the response is successful (status code 200)
      if (response.statusCode == 201) {
        return true;
      } else {
        // Log and throw exception if status code is not 200
        log('Failed to create task: ${response.statusCode}');
        return false;
        throw Exception('Failed to create task. Status code: ${response.statusCode}');
      }
    } catch (e) {
      // log the error and rethrow it
      log('Error: $e');
      throw Exception('Failed to create task: $e');
    }

    // Return false if for any reason the task could not be created
    return false;
  }

  Future<bool> deleteTask(String taskId) async {
    dio.options.headers['Authorization'] = 'Token $token';

    try {
      final response = await dio.post(
        '$baseUrl/callHandler/',
        data: {'action': 'delete_task','task_id': taskId},
      );

      // Check if the response is successful (status code 200)
      if (response.statusCode == 200) {
        return true;
      } else {
        // Log and throw exception if status code is not 200
        log('Failed to delete task: ${response.statusCode}');
        return false;
        throw Exception('Failed to create task. Status code: ${response.statusCode}');
      }
    } catch (e) {
      // log the error and rethrow it
      log('Error: $e');
      throw Exception('Failed to create task: $e');
    }

    // Return false if for any reason the task could not be created
    return false;
  }

  Future<bool> createInteraction(Map<String, dynamic> data) async {
    dio.options.headers['Authorization'] = 'Token $token';

    try {
      final response = await dio.post(
        '$baseUrl/callHandler/',
        data: {
          'action': 'addInteraction',
          'created_by': this.UserId,
          'title': data["title"],
          'meeting_place': data["locationType"],
          'meeting_datetime': data["meetingDate"],
          'discussion_points': data["discussionPoints"],
          'action_points': data["actionPoints"], // action points as description
          'materials_distributed': data["materialsDistributed"],
          'ganya_vyakti': data["ganyavyaktiId"],
        },
      );

      return response.statusCode == 201;
    } catch (e) {
      log('Error: $e');
      return false;
    }
  }


  Future<bool> createMeeting(List<dynamic> data) async {
    dio.options.headers['Authorization'] = 'Token $token';

    try {
      final response = await dio.post(
        '$baseUrl/callHandler/',
        data: {
          'action': 'addMeeting',
          'type': data[0],
          'title': data[1],
          'description': data[2],
          'venue':data[3],
          'participants': data[5],
          'organizers': data[5],
          'ganyavyakti': data[6],
          'status': data[7],
          'meeting_datetime': data[4],
        },
      );

      // Check if the response is successful (status code 200)
      if (response.statusCode == 201) {
        return true;
      } else {
        // Log and throw exception if status code is not 200
        log('Failed to create task: ${response.statusCode}');
        return false;
        throw Exception('Failed to create task. Status code: ${response.statusCode}');
      }
    } catch (e) {
      // log the error and rethrow it
      log('Error: $e');
      throw Exception('Failed to create task: $e');
    }

    // Return false if for any reason the task could not be created
    return false;
  }

  Future<List<dynamic>> getTasks(String GV_id) async {
    dio.options.headers['Authorization'] = 'Token $token';

    try {
      final response = await dio.post('$baseUrl/callHandler/',data: {'action':'get_task','GV_id':GV_id});
      //log(response.data);

      if (response.statusCode == 200) {
        //log('TS ${response.data}');

        if (response.data is List<dynamic>) {
          return response.data;
        } else if (response.data is Map<String, dynamic>) {
          return [response.data];
        } else {
          throw Exception('Unexpected data type: ${response.data.runtimeType}');
        }
      } else {
        throw Exception('Failed to load lead. Status code: ${response.statusCode}');
      }


    } catch (e) {
      log('Error: $e');
      throw Exception('Failed to load supervisor: $e');
    }
  }

  Future<bool> addUsers(File file) async {
    dio.options.headers['Authorization'] = 'Token $token';

    // Step 2: Prepare the file for sending with Dio
    FormData formData = FormData.fromMap({
      'action': 'add_Karyakartha_Excel',  // Action name for the API
      'file': await MultipartFile.fromFile(file.path, filename: file.uri.pathSegments.last),
    });

    try {
      // Step 3: Send the file to the server via a POST request
      final response = await dio.post(
        '$baseUrl/callHandler/',  // Replace with your actual API endpoint
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      if (response.statusCode == 200) {
        log("File uploaded successfully!");
        return true;  // Return true on success
      } else {
        log("Failed to upload file. Status code: ${response.statusCode}");
        return false;  // Return false on failure
      }
    } catch (e) {
      log("Error occurred: $e");
      return false;  // Return false if there's an exception
    }
  }

  Future<bool> addGVORG(File file) async {
    dio.options.headers['Authorization'] = 'Token $token';

    // Step 2: Prepare the file for sending with Dio
    FormData formData = FormData.fromMap({
      'action': 'add_GanyaVyakti_Excel',  // Action name for the API
      'file': await MultipartFile.fromFile(file.path, filename: file.uri.pathSegments.last),
    });

    try {
      // Step 3: Send the file to the server via a POST request
      final response = await dio.post(
        '$baseUrl/callHandler/',  // Replace with your actual API endpoint
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      if (response.statusCode == 200) {
        log("File uploaded successfully!");
        return true;  // Return true on success
      } else {
        log("Failed to upload file. Status code: ${response.statusCode}");
        return false;  // Return false on failure
      }
    } catch (e) {
      log("Error occurred: $e");
      return false;  // Return false if there's an exception
    }
  }

  Future<File?> addGV(File file) async {
    dio.options.headers['Authorization'] = 'Token $token';

    try {
      FormData formData = FormData.fromMap({
        'action': 'add_GanyaVyakti_Excel',
        'file': await MultipartFile.fromFile(file.path, filename: file.uri.pathSegments.last),
      });

      final response = await dio.post(
        '$baseUrl/callHandler/',
        data: formData,
        options: Options(responseType: ResponseType.bytes), // Expect bytes if Excel returned
      );

      // If the response is an Excel file (failures present)
      if (response.statusCode == 200 &&
          response.headers.map['content-type']?.contains(
            'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
          ) == true) {
        // Get external directory
        String fileName = 'failed_ganyavyakthi_uploads.xlsx';
        var exPath = await _getExternalDirectory();
        await Directory(exPath).create(recursive: true);
        String filePath = '$exPath/$fileName';

        int count = 1;
        while (await File(filePath).exists()) {
          filePath = '$exPath/failed_ganyavyakthi_uploads_$count.xlsx';
          count++;
        }

        final File failedFile = File(filePath);
        await failedFile.writeAsBytes(response.data);

        return failedFile;
      }

      // If upload is successful and no file is returned
      log("File uploaded successfully with no failures.");
      return null;

    } catch (e) {
      log("Error during addGV: $e");
      return null;
    }
  }

  Future<File?> addKR(File file) async {
    dio.options.headers['Authorization'] = 'Token $token';

    try {
      FormData formData = FormData.fromMap({
        'action': 'add_Karyakartha_Excel',
        'file': await MultipartFile.fromFile(file.path, filename: file.uri.pathSegments.last),
      });

      final response = await dio.post(
        '$baseUrl/callHandler/',
        data: formData,
        options: Options(responseType: ResponseType.bytes), // Expect bytes if Excel returned
      );

      // If the response is an Excel file (failures present)
      if (response.statusCode == 200 &&
          response.headers.map['content-type']?.contains(
            'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
          ) == true) {
        // Get external directory
        String fileName = 'failed_Karyakartha_uploads.xlsx';
        var exPath = await _getExternalDirectory();
        await Directory(exPath).create(recursive: true);
        String filePath = '$exPath/$fileName';

        int count = 1;
        while (await File(filePath).exists()) {
          filePath = '$exPath/failed_Karyakartha_uploads_$count.xlsx';
          count++;
        }

        final File failedFile = File(filePath);
        await failedFile.writeAsBytes(response.data);
        return failedFile;
      }

      // If upload is successful and no file is returned
      //log("File uploaded successfully with no failures.");
      return null;

    } catch (e) {
      log("Error during addKR: $e");
      return null;
    }
  }

  Future<List<dynamic>> getInteractionByID(String IR_id) async {
    dio.options.headers['Authorization'] = 'Token $token';

    try {
      //log(IR_id);
      final response = await dio.post('$baseUrl/callHandler/',data: {'action':'get_interaction_by_id','id':IR_id});
      //log(response.data);

      if (response.statusCode == 200) {
        //log('TS ${response.data}');

        if (response.data is List<dynamic>) {
          return [response.data];
        } else if (response.data is Map<String, dynamic>) {
          return [response.data];
        } else {
          throw Exception('Unexpected data type: ${response.data.runtimeType}');
        }
      } else {
        throw Exception('Failed to load lead. Status code: ${response.statusCode}');
      }
    } catch (e) {
      log('Error: $e');
      throw Exception('Failed to load interaction: $e');
    }
  }

  Future<List<dynamic>> getEventByID(String meetingID,String meetingTypeID) async {
    dio.options.headers['Authorization'] = 'Token $token';

    try {
      //log(meetingTypeID);
      final response = await dio.post('$baseUrl/callHandler/',data: {'action':'getEventById','id':meetingID ,'EventType':meetingTypeID});
      //log(response.data);

      if (response.statusCode == 200) {
        //log('TS ${response.data}');

        if (response.data is List<dynamic>) {
          return [response.data];
        } else if (response.data is Map<String, dynamic>) {
          return [response.data];
        } else {
          throw Exception('Unexpected data type: ${response.data.runtimeType}');
        }
      } else {
        throw Exception('Failed to load lead. Status code: ${response.statusCode}');
      }


    } catch (e) {
      log('Error: $e');
      throw Exception('Failed to load supervisor: $e');
    }
  }

  Future<List<dynamic>> getEventByStatus() async {
    dio.options.headers['Authorization'] = 'Token $token';

    try {
      final response = await dio.post('$baseUrl/callHandler/',data: {'action':'getEventByStatus'});

      if (response.statusCode == 200) {
        //log('TS ${response.data}');

        if (response.data is List<dynamic>) {
          return [response.data];
        } else if (response.data is Map<String, dynamic>) {
          return [response.data];
        } else {
          throw Exception('Unexpected data type: ${response.data.runtimeType}');
        }
      } else {
        throw Exception('Failed to load lead. Status code: ${response.statusCode}');
      }


    } catch (e) {
      log('Error: $e');
      throw Exception('Failed to load supervisor: $e');
    }
  }

  Future<List<dynamic>> getInteraction(String GV_id) async {
    dio.options.headers['Authorization'] = 'Token $token';

    try {
      //log(GV_id);
      final response = await dio.post('$baseUrl/callHandler/',data: {'action':'get_interaction','GV_id':GV_id});
      //log(response.data);

      if (response.statusCode == 200) {
        //log('TS ${response.data}');

        if (response.data is List<dynamic>) {
          return response.data;
        } else if (response.data is Map<String, dynamic>) {
          return [response.data];
        } else {
          throw Exception('Unexpected data type: ${response.data.runtimeType}');
        }
      } else {
        throw Exception('Failed to load lead. Status code: ${response.statusCode}');
      }


    } catch (e) {
      log('Error: $e');
      throw Exception('Failed to load supervisor: $e');
    }
  }

  Future<List<dynamic>> getReportPage(String id,String fromDate, String toDate) async {
    dio.options.headers['Authorization'] = 'Token $token';

    try {
      final response = await dio.post('$baseUrl/callHandler/',data: {'action':'reportPage', 'user_id': id, 'fromDate':fromDate,'toDate':toDate});

      if (response.statusCode == 200) {
        if (response.data is List<dynamic>) {
          return response.data;
        } else if (response.data is Map<String, dynamic>) {
          return [response.data];
        } else {
          throw Exception('Unexpected data type: ${response.data.runtimeType}');
        }
      } else if (response.statusCode == 500){
        log('error');
        throw Exception('Failed to load lead. Status code: ${response.statusCode}');
      } else {
        throw Exception('Failed to load lead. Status code: ${response.statusCode}');
      }


    } catch (e) {
      log('Error: $e');
      throw Exception('Failed to load supervisor: $e');
    }
  }

  Future<List<dynamic>> getReportMeet(String meetType,String fromDate, String toDate) async {
    dio.options.headers['Authorization'] = 'Token $token';

    try {
      final response = await dio.post('$baseUrl/callHandler/',data: {'action':'reportMeetings','type':meetType,'fromDate':fromDate,'toDate':toDate});

      if (response.statusCode == 200) {
        if (response.data is List<dynamic>) {
          return response.data;
        } else if (response.data is Map<String, dynamic>) {
          return [response.data];
        } else {
          throw Exception('Unexpected data type: ${response.data.runtimeType}');
        }
      } else if (response.statusCode == 500){
        log('error');
        throw Exception('Failed to load lead. Status code: ${response.statusCode}');
      } else {
        throw Exception('Failed to load lead. Status code: ${response.statusCode}');
      }


    } catch (e) {
      log('Error: $e');
      throw Exception('Failed to load supervisor: $e');
    }
  }

  Future<List<dynamic>> getEvents(String meetingTypeID) async {
    dio.options.headers['Authorization'] = 'Token $token';

    try {
      //log('meeting ID: $meetingTypeID');
      final response = await dio.post('$baseUrl/callHandler/',data: {'action':'getEvents','EventType':meetingTypeID,'KR_id':UserId});

      if (response.statusCode == 200) {
        //log('TS ${response.data}');

        if (response.data is List<dynamic>) {
          return response.data;
        } else if (response.data is Map<String, dynamic>) {
          return [response.data];
        } else {
          throw Exception('Unexpected data type: ${response.data.runtimeType}');
        }
      } else {
        throw Exception('Failed to load lead. Status code: ${response.statusCode}');
      }


    } catch (e) {
      log('Error: $e');
      throw Exception('Failed to load supervisor: $e');
    }
  }

  Future<List<dynamic>> getEventsById(String eventID, String meetingTypeID) async {
    dio.options.headers['Authorization'] = 'Token $token';
    try {
      final response = await dio.post('$baseUrl/callHandler/', data: {
        'action': 'getEventsById',
        'EventType': meetingTypeID,
        'id': eventID
      });

      if (response.statusCode == 200) {
        if (response.data is List<dynamic>) {
          return response.data;
        } else if (response.data is Map<String, dynamic>) {
          return [response.data];
        } else {
          throw Exception('Unexpected data type: ${response.data.runtimeType}');
        }
      } else {
        throw Exception('Failed to load Meeting details: Status code ${response.statusCode}');
      }
    } catch (e) {
      log('Error: $e');
      throw Exception('Failed to load Meeting details: $e');
    }
  }


  Future<List<dynamic>> getEventImages(String id,String meetingTypeID) async {
    dio.options.headers['Authorization'] = 'Token $token';

    try {
      //log('meeting ID: $meetingTypeID');
      final response = await dio.post('$baseUrl/callHandler/',data: {'action':'getEventImage','EventType':meetingTypeID,'id':id});
      //log('meeting images');
      //log(response.data);

      if (response.statusCode == 200) {
        //log('TS ${response.data}');

        if (response.data is List<dynamic>) {
          //log('images : ${response.data[0]['images'].length}');
          return response.data;
        } else if (response.data is Map<String, dynamic>) {
          return [response.data];
        } else {
          throw Exception('Unexpected data type: ${response.data.runtimeType}');
        }
      } else {
        throw Exception('Failed to load lead. Status code: ${response.statusCode}');
      }


    } catch (e) {
      log('Error: $e');
      throw Exception('Failed to load supervisor: $e');
    }
  }

  Future genReport(String fromDate, String toDate) async {
    try {
      // Request storage permission once
      //await _requestPermission();

      // Get external directory path based on platform
      var exPath = await _getExternalDirectory();

      // Create the directory if it does not exist
      await Directory(exPath).create(recursive: true);

      // Set authorization header for the request
      dio.options.headers['Authorization'] = 'Token $token';

      // Make the API request to generate the report
      final response = await dio.post(
        '$baseUrl/callHandler/',
        data: {'action': 'gen_report', 'fromDate': fromDate, 'toDate': toDate},
        options: Options(
          responseType: ResponseType.bytes,  // Ensure we get binary data (PDF)
        ),
      );

      if (response.statusCode == 200) {
        // Check that the response data is of expected type (binary)
        if (response.data is List<int>) {
          // Define the file path to save the PDF
          var filePath = '$exPath/Samparka_Report.pdf';

          // Check if the file already exists, and if so, increment the filename
          int count = 1;
          while (await File(filePath).exists()) {
            filePath = '$exPath/Samparka_Report_$count.pdf';
            count++;
          }

          final file = File(filePath);

          // Write PDF data to the file
          //await file.writeAsBytes(response.data);

          // log file path for confirmation
          //log('PDF saved to: $filePath');
          return response.data;
        } else {
          throw Exception('Unexpected data format. Expected binary data for PDF.');
        }
      } else {
        throw Exception('Failed to download report. Status code: ${response.statusCode}');
      }
    } catch (e) {
      log('Error: $e');
      throw Exception('Failed to download report: $e');
    }
  }

  // Helper function to request storage permission
  Future<void> _requestPermission() async {
    // Check the current status of storage permission
    var status = await Permission.storage.status;

    // If storage permission is not granted, request for it
    if (!status.isGranted) {
      // On Android 11+, check if the app has `MANAGE_EXTERNAL_STORAGE` permission
      if (await Permission.manageExternalStorage.isGranted) {
        // Already have storage permission on Android 11+
        return;
      } else {
        // Request storage permission for Android 10 and below
        if (await Permission.storage.request().isGranted) {
          // Permission granted, continue
          return;
        } else {
          // If permission denied, prompt user to open settings
          openAppSettings();
        }
      }
    }
    // Else, handle cases where storage permission is granted
  }

  // Helper function to get external directory based on platform
  Future<String> _getExternalDirectory() async {
    if (Platform.isAndroid) {
      return '/storage/emulated/0/Download/samparka'; // Android-specific path
    } else {
      // For iOS or other platforms, use application documents directory
      final directory = await getApplicationDocumentsDirectory();
      return directory.path;
    }
  }

  Future searchGV(String str) async {
    dio.options.headers['Authorization'] = 'Token $token';

    try {
      final response = await dio.post('$baseUrl/callHandler/', data: {'action': 'search_inf', 'search': str});

      if (response.statusCode == 200) {
        if (response.data is List<dynamic>) {
          return response.data;
        } else if (response.data is Map<String, dynamic>) {
          return [response.data];
        } else {
          throw Exception('Unexpected data type: ${response.data.runtimeType}');
        }
      } else if (response.statusCode == 204 || response.statusCode == 404) {
        // Return false for both 204 and 404 status codes
        return false;
      } else {
        throw Exception('Failed to Search inf. Status code: ${response.statusCode}');
      }
    } catch (e) {
      log('Error: $e');
      return false;
      throw Exception('Failed to search inf: $e');
    }
  }

  Future searchKR(String str) async {
    dio.options.headers['Authorization'] = 'Token $token';

    try {
      final response = await dio.post('$baseUrl/callHandler/', data: {'action': 'search_Karyakartha', 'search': str});

      if (response.statusCode == 200) {
        if (response.data is List<dynamic>) {
          return response.data;
        } else if (response.data is Map<String, dynamic>) {
          return [response.data];
        } else {
          throw Exception('Unexpected data type: ${response.data.runtimeType}');
        }
      } else if (response.statusCode == 204 || response.statusCode == 404) {
        // Return false for both 204 and 404 status codes
        return false;
      } else {
        throw Exception('Failed to Search inf. Status code: ${response.statusCode}');
      }
    } catch (e) {
      log('Error: $e');
      return false;
      throw Exception('Failed to search inf: $e');
    }
  }

  Future<Map<String, dynamic>> migrateInfluencers(List<String> influencerIds, String targetUserId) async {
    dio.options.headers['Authorization'] = 'Token $token';

    try {
      final response = await dio.post(
        '$baseUrl/callHandler/',
        data: {
          'action': 'MigrateInfluencer',
          'influencerIds': influencerIds,
          'targetUserId': targetUserId,
        },
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        log('Failed to migrate. Status code: ${response.statusCode}');
        throw Exception('Migration failed with status ${response.statusCode}');
      }
    } catch (e) {
      log('Migration exception: $e');
      throw Exception('Migration exception: $e');
    }
  }

  Future<Map<String, dynamic>> migrateKaryakartha(List<String> influencerIds, String targetUserId) async {
    dio.options.headers['Authorization'] = 'Token $token';

    try {
      final response = await dio.post(
        '$baseUrl/callHandler/',
        data: {
          'action': 'MigrateInfluencer',
          'influencerIds': influencerIds,
          'targetUserId': targetUserId,
        },
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        log('Failed to migrate. Status code: ${response.statusCode}');
        throw Exception('Migration failed with status ${response.statusCode}');
      }
    } catch (e) {
      log('Migration exception: $e');
      throw Exception('Migration exception: $e');
    }
  }


  Future<bool> markTaskComplete(taskId) async {
    dio.options.headers['Authorization'] = 'Token $token';

    try {
      final response = await dio.post(
        '$baseUrl/callHandler/',
        data: {'action': 'set_task_status','task_id': taskId},
      );

      // Check if the response is successful (status code 200)
      if (response.statusCode == 200) {
        return true;
      } else {
        // Log and throw exception if status code is not 200
        log('Failed to create task: ${response.statusCode}');
        return false;
        throw Exception('Failed to create task. Status code: ${response.statusCode}');
      }
    } catch (e) {
      // log the error and rethrow it
      log('Error: $e');
      throw Exception('Failed to create task: $e');
    }
  }

  Future<Uint8List> resizeReportImage(Uint8List imageBytes) async {
    // Decode the image (supports JPEG, PNG, etc.)
    img.Image? image = img.decodeImage(imageBytes);

    if (image == null) {
      throw Exception("Unable to decode the image");
    }

    // Get the current width and height of the image
    int width = image.width;
    int height = image.height;

    // Determine the resizing factor based on the larger dimension
    double factor = 600.0 / (width > height ? width : height);

    // Calculate the new dimensions to maintain the aspect ratio
    int newWidth = (width * factor).round();
    int newHeight = (height * factor).round();

    // Resize the image proportionally
    img.Image resizedImage = img.copyResize(image, width: newWidth, height: newHeight);

    // Encode the resized image to JPEG format
    Uint8List resizedImageBytes = Uint8List.fromList(img.encodeJpg(resizedImage));

    return resizedImageBytes;
  }

  Future<bool> submitReportORG(String id,String typeID, List<File> images, String reportData) async {
    Dio dio = Dio();
    dio.options.headers['Authorization'] = 'Token $token';

    try {
      List<Uint8List> binaryImages = [];

      // Loop through each image, resize it, and convert it to binary
      for (File image in images) {
        List<int> imageBytes = await image.readAsBytes();

        // Resize the image in memory
        Uint8List resizedImageBytes = await resizeReportImage(Uint8List.fromList(imageBytes));

        // Add the resized image binary data to the list
        binaryImages.add(resizedImageBytes);
      }

      // Convert the binary images to base64 for sending in the request
      List<String> base64Images = binaryImages.map((imageBytes) => base64Encode(imageBytes)).toList();

      //log('Sub func $id $base64Images $reportData');
      // Make the POST request
      final response = await dio.post('$baseUrl/callHandler/',
        data: {
          'action': 'submitReport',
          'id': id,
          'type': typeID,
          'report': reportData,
          'images': base64Images, // Send the base64-encoded images in the request
        },
      );

      // Check if the response is successful (status code 200)
      if (response.statusCode == 200) {
        return true;
      } else {
        // Log and throw exception if status code is not 200
        log('Failed to submit report: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      // log the error and rethrow it
      log('Error: $e');
      throw Exception('Failed to submit report: $e');
    }
  }

  Future<List<int>> imageResize(File orgImage, bool profile, int maxDim) async {
    // Decode the image (supports JPEG, PNG, etc.)
    img.Image? image = img.decodeImage(await orgImage.readAsBytes());

    if (image == null) {
      throw Exception("Unable to decode the image. Please check the image format.");
    }

    // Get the current width and height of the image
    int orgWidth = image.width;
    int orgHeight = image.height;

    int newWidth, newHeight;

    if (profile) {
      // Determine the resizing factor based on the larger dimension
      double factor = 600.0 / (orgWidth > orgHeight ? orgWidth : orgHeight);

      // Calculate the new dimensions to maintain the aspect ratio
      newWidth = (orgWidth * factor).round();
      newHeight = (orgHeight * factor).round();
    } else {
      // Calculate the new dimensions to maintain the aspect ratio
      double factor = maxDim / (orgWidth > orgHeight ? orgWidth : orgHeight);

      // Calculate the new dimensions to maintain the aspect ratio
      newWidth = (orgWidth * factor).round();
      newHeight = (orgHeight * factor).round();
    }

    // Ensure that we don't enlarge the image if it's already smaller than the target size
    if (newWidth > orgWidth || newHeight > orgHeight) {
      newWidth = orgWidth;
      newHeight = orgHeight;
    }

    // Resize the image proportionally
    img.Image resizedImage = img.copyResize(image, width: newWidth, height: newHeight);

    // Return the resized image as a byte array (JPEG)
    return img.encodeJpg(resizedImage);
  }

  Future<bool> submitReport(String id, String typeID, List<File> images, String reportData) async {
    Dio dio = Dio();
    dio.options.headers['Authorization'] = 'Token $token';

    try {
      List<MultipartFile> imageFiles = [];

      // Loop through each image, resize it, and convert it to binary
      for (File image in images) {
        // Resize the image and get it as a byte array
        List<int> resizedImageBytes = await imageResize(image, false, 2000);

        // Convert the byte array into a MultipartFile (temporary file)
        String tempFilePath = '${Directory.systemTemp.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';
        File tempFile = File(tempFilePath)..writeAsBytesSync(resizedImageBytes);

        // Add the file to the list of image files
        imageFiles.add(await MultipartFile.fromFile(tempFile.path, filename: tempFile.uri.pathSegments.last));
      }

      //log('Sub func $id $imageFiles $reportData');

      // Make the POST request with FormData
      FormData formData = FormData.fromMap({
        'action': 'submitReport',
        'id': id,
        'type': typeID,
        'report': reportData,
        'images': imageFiles,
      });

      final response = await dio.post('$baseUrl/callHandler/', data: formData);

      // Check if the response is successful (status code 200)
      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        // Log and throw exception if status code is not 200
        log('Failed to submit report: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      // log the error and rethrow it
      log('Error: $e');
      throw Exception('Failed to submit report: $e');
    }
  }

  Future<void> showDialogMsg(BuildContext context, String alert, String info, { Color? alertColor = Colors.black, Color? infoColor = Colors.grey }) async {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent user from closing it manually
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            alert,
            style: TextStyle(
              color: alertColor, // Use provided or default alertColor
            ),
          ),
          content: Text(
            info,
            style: TextStyle(
              fontSize: 18,
              color: infoColor, // Use provided or default infoColor
            ),
          ),
        );
      },
    );

    // Dismiss the dialog after 4 seconds
    Future.delayed(Duration(seconds: 4), () {
      Navigator.of(context).pop();
    });
  }

  Future<bool> sendFeedBack(List<dynamic> data) async {
    dio.options.headers['Authorization'] = 'Token $token';

    try {
      //log("Data at Feedback: $data");
      final String email = data[0];
      final String description = data[1];
      final List<File> images = List<File>.from(data[2]);

      List<MultipartFile> multipartImages = [];

      for (File image in images) {
        // Resize each image
        List<int> resizedImageBytes = await imageResize(image, true, 600);

        // Write to a temp file
        String tempFilePath = '${Directory.systemTemp.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';
        File tempFile = File(tempFilePath)..writeAsBytesSync(resizedImageBytes);

        // Add to Multipart list
        MultipartFile multipartFile = await MultipartFile.fromFile(
          tempFile.path,
          filename: tempFile.uri.pathSegments.last,
        );

        multipartImages.add(multipartFile);
      }

      FormData formData = FormData.fromMap({
        'action': 'submitFeedBack',
        'email': email,
        'description': description,
        'images': multipartImages,
      });

      final response = await dio.post(
        '$baseUrl/FeedbackHandler/',
        data: formData,
      );

      return true;
    } catch (e) {
      log('Error: $e');
      return false;
    }
  }



}
