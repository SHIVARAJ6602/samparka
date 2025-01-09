import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  late String baseUrl0 = "http://127.0.0.1:8000/api";
  late String baseUrl1 = "https://t6q7lj15-8000.inc1.devtunnels.ms/api";
  late String baseUrl2 = "https://llama-curious-adequately.ngrok-free.app/api";
  late String baseUrl;
  late String token;
  late String userName = '';
  late bool isAuthenticated = false;
  late Dio dio;
  late CookieJar cookieJar;
  late bool _isInitialized = false;
  late String txt = '...';

  Future<bool> registerUser(String phone, String fname, String lname, String email, String designation, String password, String group) async {
    try {
      // Check if token is null or empty before making the request
      if (token.isEmpty) {
        print('Error: Authorization token is missing');
        return false;
      }

      dio.options.headers['Authorization'] = 'Token $token';

      // Send registration request to the server
      final response = await dio.post(
        '$baseUrl/callHandler/',
        data: {
          "action": "register",
          "phone_number": phone,
          "first_name": fname,
          "last_name": lname,
          "email": email,
          "designation": designation,
          "password": password,
          "group": group,
        },
      );

      // Handle server response status
      if (response.statusCode == 200 || response.statusCode == 201) {
        print("User registered successfully");
        print("message: ${response.data['message']} user: ${response.data['user']}");
        return true;
      } else {
        // Capture error message from the server response, if available
        var errorData = response.data;
        String errorMessage = errorData['message'] ?? 'Unknown error';
        print('Registration failed: $errorMessage');
        throw Exception('Registration failed: $errorMessage');
      }
    } catch (e) {
      // Handle unexpected errors such as network issues or invalid responses
      print('Error during registration: $e');
      return false;
    }
  }


  // Private constructor
  ApiService._privateConstructor();

  // The single instance of ApiService
  static final ApiService _instance = ApiService._privateConstructor();

  factory ApiService() {
    if (!_instance._isInitialized) {
      _instance._initialize();
    }
    return _instance;
  }

  /*ApiService(){
    dio = Dio();
    var cookieJar = CookieJar();
    dio.interceptors.add(CookieManager(cookieJar));
    loadData();
  }*/

  // Initialize the Dio instance and add interceptors
  Future<void> _initialize() async {
    dio = Dio();
    cookieJar = CookieJar();
    dio.interceptors.add(CookieManager(cookieJar));
    await loadData();

    try {
      //print(baseUrl.toString().substring(0, 40));
      //final response = await dio.get('https://t6q7lj15-8000.inc1.devtunnels.ms');
      final response = await dio.get(baseUrl.toString().substring(0, baseUrl.length-4));
      //final response = await dio.get(baseUrl.toString().substring(0, 40));
      // Check the response status code
      if (response.statusCode == 200) {
        //print(response.headers);
        //print('Ping successful! Status Code: 200\nResponse: ${response.data.toString().substring(0, 100)}...');
        print('Ping successful! Status Code: 200');
      } else {
        print('Failed to ping. Status Code: ${response.statusCode}');
      }
    } catch (e) {
      print('Ping failed. Error: $e');
    }

    _isInitialized = true;
  }

  /*Future<void> initialize() async {
    loadData();
  }*/

  Future<void> saveData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('baseUrl', baseUrl);  // Use setString, since baseUrl is a single string
    await prefs.setString("token", token);
    await prefs.setBool("isAuthenticated", isAuthenticated);
    await prefs.setString("userName", userName);
    print("DataSaved");
  }

  Future<void> loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    baseUrl = prefs.getString('baseUrl') ?? baseUrl1;
    token = prefs.getString("token") ?? '';
    userName = prefs.getString("userName") ?? '';
    isAuthenticated = prefs.getBool("isAuthenticated") ?? false;
    print("DataLoaded - isAuthenticated: $isAuthenticated");
  }

  /*Future<List<dynamic>> fetchTasks() async {
    dio.options.headers['Authorization'] = 'Token $token';

    final response = await dio.get('$baseUrl/tasks/');
    if (response.statusCode == 200) {
      print(response.data);
      return response.data;
    } else {
      throw Exception('Failed to load tasks');
    }
  }*/

  Future<List<dynamic>> fetchTasks() async {
    //dio.options.headers['Authorization'] = 'Token $token';

    try {
      //final response = await dio.get('$baseUrl/tasks/');
      final response = await dio.get('$baseUrl/tasks/');
      if (response.statusCode == 200) {
        print(response.data);
        if (response.data is List<dynamic>) {
          return response.data;
        } else if (response.data is String) {
          final parsedData = List<dynamic>.from(response.data);
          return parsedData;  // Return the parsed data
        } else {
          throw Exception('Expected a List, but got ${response.data.runtimeType}');
        }
      } else {
        throw Exception('Failed to load tasks. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
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
            print(response.data['groups']);
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
      print('Error: $e');
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

  Future<bool> getOTP(String phone,String mail) async {
    try {
      print('$baseUrl - $phone');

      final response = await dio.post(
        "$baseUrl/loginHandler/",
        data: {'action': 'get_otp', 'mail': mail, 'phone': phone},
      );

      // Log the raw response body for debugging
      print('Response body: ${response.data}');

      // Check if the response status code indicates success (e.g., 200 or 201)
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.data.isNotEmpty) {
          // Directly use response.data (which should be a Map)
          print('OTP sent: ${response.data['otp']}'); // Assuming the OTP is returned in the response
          return true;
        } else {
          print('Received empty response body');
          throw Exception('Empty response body');
        }
      } else {
        // If the status code is not 200 or 201, throw an error with the message from the response
        var errorData = response.data; // Assuming the error response is also a Map
        throw Exception('Failed to get OTP: ${errorData['message'] ?? 'Unknown error'}');
      }
    } catch (e) {
      print('Error getting OTP: $e');
      return false;
    }
  }

  // Function to log in with phone and OTP
  Future<bool> login(String phone, String otp) async {
    try {
      final response = await dio.post(
        '$baseUrl/loginHandler/',
        data: {
          'action': 'login',  // Specify the action as 'login'
          'phone': phone,
          'otp': otp,
        },
      );

      // Check if the login was successful (status code 200 or 201)
      if (response.statusCode == 200 || response.statusCode == 201) {
        // Directly access response.data since it's already a Map
        var responseData = response.data;

        // Example: Assuming the server returns a token or user info upon successful login
        token = responseData['token'];  // Adjust based on your backend response structure
        userName = responseData['userName'];

        if (token != null) {
          print('Login successful. Token: $token UserName: ${responseData['userName']}');
          isAuthenticated = true;
          saveData();
          return true;
        } else {
          throw Exception('Login failed: Token not received');
        }
      } else {
        // Handle login failure (incorrect OTP, phone not registered, etc.)
        var errorData = response.data;
        throw Exception('Login failed: ${errorData['message'] ?? 'Unknown error'}');
      }
    } catch (e) {
      print('Error during login: $e');
      return false;
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
      print(response.data);
      txt = response.data['message'] as String;

    } catch (e) {
      print('Error: $e');
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
      print('Error during logout: $e');
      return false;
    } finally {
      // this should be inside try after response.
      isAuthenticated = false;
      token = '';
      userName = '';
      saveData();
      /************/
      await Future.delayed(const Duration(milliseconds: 2000));
    }
    print('object');
    return true;

  }

  // Adding the token to the request headers
  Future<Response> _getAuthenticatedResponse(String path, {Map<String, dynamic>? data}) async {
    if (token == '') {
      throw Exception("No authentication token found");
    }

    // Add token to the Authorization header
    dio.options.headers['Authorization'] = 'Bearer $token';

    // Make the API request
    try {
      final response = await dio.post(path, data: data);
      return response;
    } catch (e) {
      throw Exception('Failed to load data: $e');
    }
  }

  // Example method to make an authenticated request
  Future<void> userAuth() async {
    dio.options.headers['Authorization'] = 'Token $token';

    try {
      final response = await dio.get('$baseUrl/callHandler/');
      print(response.data);
    } catch (e) {
      print('Error: $e');
    }
  }

}
