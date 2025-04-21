import 'dart:convert';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:dio/dio.dart';
import 'package:cookie_jar/cookie_jar.dart';

import 'api_service.dart';

Future<void> initFCM() async {
  print('in init FCM()');
  final apiService = ApiService();
  final FirebaseMessaging messaging = FirebaseMessaging.instance;

  final dio = Dio();
  final cookieJar = CookieJar();

  dio.interceptors.add(CookieManager(cookieJar));

  // Optional: Set base URL if consistent across app
  dio.options.baseUrl = apiService.baseUrl;

  // Set headers
  dio.options.headers.addAll({
    'Authorization': 'Token ${apiService.token}',
    'Content-Type': 'application/json',
  });

  try {
    final String? fcmToken = await messaging.getToken();

    if (fcmToken != null) {
      final response = await dio.post(
        '${apiService.baseUrl}/callHandler/',
        data: {'action': 'save_fcm_token','token': fcmToken},
        options: Options(
          responseType: ResponseType.bytes,  // Ensure we get binary data (PDF)
        ),
      );

      print('✅ FCM token sent: ${response.statusCode}');
    } else {
      print('⚠️ FCM token is null');
    }
  } catch (e, stackTrace) {
    print('❌ Failed to send FCM token: $e');
    print(stackTrace);
  }
}
