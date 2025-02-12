import 'dart:convert';
import 'dart:io';
import 'package:image/image.dart' as img;
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image/image.dart' as img; // Make sure to import the 'image' package
import 'dart:typed_data';

class ApiService {
  late String baseUrl0 = "https://samparka.org/api";
  late String baseUrl1 = "https://samparka.org/api";
  late String baseUrl2 = "https://t6q7lj15-8000.inc1.devtunnels.ms/api";
  late String baseUrl3 = "https://llama-curious-adequately.ngrok-free.app/api";
  late String baseUrl = '';
  late String token='8dd529c0df4ca79b2b85e786088af9daa614cccf';
  late int lvl = 0;
  late var profile_image = '';
  late String UserId = 'KR00000001';
  late String first_name = '';
  late String last_name = '';
  late String designation = '';
  late String city = '';
  late String district = '';
  late String state = '';
  late bool isAuthenticated = false;
  late Dio dio;
  late CookieJar cookieJar;
  late bool _isInitialized = false;
  late String txt = '...';

  Future<void> _initialize() async {
    dio = Dio();
    cookieJar = CookieJar();
    dio.interceptors.add(CookieManager(cookieJar));
    await loadData();

    try {
      final response = await dio.get(baseUrl.toString().substring(0, baseUrl.length-4));
      if (response.statusCode == 200) {
        print('Ping successful! Status Code: 200');
      } else {
        print('Failed to ping. Status Code: ${response.statusCode}');
      }
    } catch (e) {
      print('Ping failed. Error: $e');
    }
    _isInitialized = true;
  }

  Future<void> saveData() async {
    print('Token: $token');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('baseUrl', baseUrl??'');
    await prefs.setString("token", token??'');
    await prefs.setBool("isAuthenticated", isAuthenticated??false);
    await prefs.setString("userName", first_name??'');
    await prefs.setInt("level", lvl??1);
    await prefs.setString("city", city??'');
    await prefs.setString("district", district??'');
    await prefs.setString("state", state??'');
    await prefs.setString("profile_image", profile_image??'');

    print("DataSaved");
  }

  Future<void> loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    baseUrl = prefs.getString('baseUrl') ?? baseUrl1;
    token = prefs.getString("token") ?? '';
    first_name = prefs.getString("userName") ?? '';
    lvl = prefs.getInt("level")??1;
    isAuthenticated = prefs.getBool("isAuthenticated") ?? isAuthenticated;
    profile_image = prefs.getString("profile_image") ?? profile_image;
    city = prefs.getString('city') ?? city;
    district = prefs.getString('district') ?? district;
    state = prefs.getString('state') ?? state;
    print("DataLoaded - isAuthenticated: $isAuthenticated id $UserId token: $token");
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
      print(data);
      // Check if token is null or empty before making the request
      if (token.isEmpty) {
        print('Error: Authorization token is missing');
        return false;
      }

      List<int> imageBytes = await data[8].readAsBytes();

      // Resize the image in memory
      Uint8List resizedImageBytes = await resizeImage(Uint8List.fromList(imageBytes));

      print("Resized Image Size: ${resizedImageBytes.lengthInBytes} bytes");

      print("ProfileImage ${data[8]} ${data[8].path.split('/').last}");

      print(UserId);

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
        "supervisor": 'AD00000001',
        "shreni_id": data[7],
        "profile_image": MultipartFile.fromBytes(
          resizedImageBytes,
          filename: data[8].path.split('/').last, // Optional: set file name
        ),
        "city": data[9],
        "district": data[10],
        "state": data[11],
      });
      dio.options.headers['Authorization'] = 'Token $token';

      // Send registration request to the server
      final response = await dio.post(
        '$baseUrl/callHandler/',
        data: formData,
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
        print('Error: Authorization token is missing');
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
        print(response.data);
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
      print('Error: $e');
      throw Exception('Failed to load tasks: $e');
    }
  }

  Future<bool> getUser() async  {
    dio.options.headers['Authorization'] = 'Token $token';

    try {
      final response = await dio.get('$baseUrl/callHandler/');
      print(response.data);

      if (response.statusCode == 200) {
        // Assuming the response data contains a list of user data.
        var userData = response.data['data']; // Assuming 'data' holds the user info
        print(userData);
        UserId = userData['id']??'';
        first_name = userData['first_name']??'';
        last_name = userData['last_name'??''];
        lvl  = userData['level'??1];
        city = userData['city'??''];
        district = userData['district']??'';
        state = userData['state']??'';
        designation = userData['designation']??'None';
        await saveData();
        await loadData();

        return true;
      } else {
        throw Exception('Failed to check user auth. Status code: ${response.statusCode}');
      }

    } catch (e) {
      print('Error: $e');
      throw Exception('Failed to load user data: $e');
    }
  }

  Future<List<dynamic>> myInfluencer(int sCount,int eCount) async{
    try {
      // Check if token is null or empty before making the request
      if (token.isEmpty) {
        print('Error: Authorization token is missing');
        throw Exception('Failed: No Auth Token');
      }
      dio.options.headers['Authorization'] = 'Token $token';
      // Send registration request to the server
      final response = await dio.post(
        '$baseUrl/callHandler/',
        data: {
          "action":"myInfluencer",
          'orderby':'date_approved',
          'sCount':sCount,
          'eCount':eCount,
        },
      );
      // Handle server response status
      if (response.statusCode == 200) {
        print(response.data);
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
      print('Error: $e');
      throw Exception('Failed to load tasks: $e');
    }
  }

  Future<List<dynamic>> get_unapproved_profiles() async {
    dio.options.headers['Authorization'] = 'Token $token';

    try {
      final response = await dio.post('$baseUrl/callHandler/',data: {'action':'get_unapproved_profiles'});
      //print(response.data);

      if (response.statusCode == 200) {
        //print('my supervisor ${response.data}');

        if (response.statusCode == 200) {
          print(response.data);
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
      print('Error: $e');
      throw Exception('Failed to load supervisor: $e');
    }
  }

  Future<List<dynamic>> myTeam(int sCount,int eCount) async{
    try {
      // Check if token is null or empty before making the request
      if (token.isEmpty) {
        print('Error: Authorization token is missing');
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
        print(response.data);
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
      print('Error: $e');
      throw Exception('Failed to load tasks: $e');
    }
  }

  Future<bool> CreateGanyaVyakthi(List<dynamic> UserData) async {
    try {
      // Check if token is null or empty before making the request
      if (token.isEmpty) {
        print('Error: Authorization token is missing');
        return false;
      }

      List<int> imageBytes = await UserData[14].readAsBytes();

      // Resize the image in memory
      Uint8List resizedImageBytes = await resizeImage(Uint8List.fromList(imageBytes));

      print("Resized Image Size: ${resizedImageBytes.lengthInBytes} bytes");

      print("ProfileImage ${UserData[14]} ${UserData[14].path.split('/').last}");

      FormData formData = FormData.fromMap({
        "action":"CreateGanyaVyakti",
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
        "profile_image": MultipartFile.fromBytes(
          resizedImageBytes,
          filename: UserData[14].path.split('/').last, // Optional: set file name
        ),
      });

      dio.options.headers['Authorization'] = 'Token $token';
      // Send registration request to the server
      final response = await dio.post(
        '$baseUrl/callHandler/',
        data: formData,
      );
      // Handle server response status
      if (response.statusCode == 200 || response.statusCode == 201) {
        print("GanyaVyakthi registered successfully");
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


  Future<List<dynamic>> fetchTasks() async {
    dio.options.headers['Authorization'] = 'Token $token';

    try {
      final response = await dio.get('$baseUrl/tasks/');
      if (response.statusCode == 200) {
        print(response.data);
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

  Future<int> getOTP(String phone, String mail) async {
    try {
      print('$baseUrl - $phone'); // Debugging: Logs the URL and phone number.

      // Making the POST request to get OTP
      final response = await dio.post(
        "$baseUrl/loginHandler/",
        data: {'action': 'get_otp', 'mail': mail, 'phone': phone},
      );

      print('Response body: ${response.data}'); // Logs the server's response body.

      // Check if the response status code indicates success (e.g., 200 or 201)
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.data != null && response.data.isNotEmpty) {
          // Assuming the OTP is returned in the response as a key 'otp'
          print('OTP sent: ${response.data['otp']}');
          return 200; // Successfully sent OTP
        } else {
          print('Received empty response body');
          throw Exception('Empty response body');
        }
      } else {
        // If the status code is not 200 or 201, throw an error with the message from the response
        var errorData = response.data;
        print('Error Data: $errorData'); // Log the error data for debugging
        throw Exception('Failed to get OTP: ${errorData['message'] ?? 'Unknown error'}');
      }
    } catch (e) {
      print('Error getting OTP: $e'); // Catching errors from API request or response parsing

      // If the error has a response, return its status code. Otherwise, return 400.
      if (e is DioException && e.response != null) {
        return e.response!.statusCode ?? 400; // Return the status code from the error response, or 400 as fallback
      } else {
        return 400; // Return 400 for generic failure
      }
    }
  }

  Future<Response> login(String phone, String otp) async {
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
      print('data ${response.data}');

      // Check for success status code
      if (response.statusCode == 200 || response.statusCode == 201) {
        var responseData = response.data;

        // Ensure responseData is a Map and contains the expected keys
        if (responseData is Map<String, dynamic>) {
          token = responseData['token'];
          first_name = responseData['userName'];
          lvl = responseData['level']??1;
          //profile_image = responseData["profile_image"]??'';

          if (responseData['token'] != null) {
            print('Login successful. Token: $token UserName: $first_name');
            isAuthenticated = true;
            await saveData(); // Save the data as needed
            await loadData();
          } else {
            throw Exception('Login failed: Token not received');
          }
        } else {
          throw Exception('Unexpected response format');
        }
      }
      return response;

    } catch (e) {
      if (e is DioException) {
        // Check if the error is caused by a 401 Unauthorized error
        if (e.response?.statusCode == 401) {
          print('Login failed: Invalid OTP or authentication issue');
          return Response(
            requestOptions: RequestOptions(path: ''), // Dummy RequestOptions
            statusCode: 401,
            data: {'message': 'Invalid OTP or authentication issue'},
          );
        } else {
          // For other Dio errors, handle them here
          print('Dio error: ${e.message}');
          return Response(
            requestOptions: RequestOptions(path: ''), // Dummy RequestOptions
            statusCode: 400,
            data: {'message': e.message}, // Pass the Dio error message
          );
        }
      } else {
        // Catch any other types of errors
        print('Error during login: $e');
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
      first_name = '';
      saveData();
      /************/
      //await Future.delayed(const Duration(milliseconds: 1000));
    }
    print('object');
    return true;

  }

  Future<void> userAuth() async {
    dio.options.headers['Authorization'] = 'Token $token';

    try {
      final response = await dio.get('$baseUrl/callHandler/');
      print(response.data);

      if (response.statusCode == 200) {
        print(response.data);
      } else {
        throw Exception('Failed to check user auth. Status code: ${response.statusCode}');
      }

    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> Subordinates() async {
    dio.options.headers['Authorization'] = 'Token $token';

    try {
      final response = await dio.post('$baseUrl/callHandler/',data: {'action':'Subordinates'});
      //print(response.data);

      if (response.statusCode == 200) {
        //print(response.data);
      } else {
        throw Exception('Failed to check user auth. Status code: ${response.statusCode}');
      }

    } catch (e) {
      print('Error: $e');
    }
  }

  Future<List<dynamic>> mySupervisor() async {
    dio.options.headers['Authorization'] = 'Token $token';

    try {
      final response = await dio.post('$baseUrl/callHandler/',data: {'action':'mySupervisor'});
      //print(response.data);

      if (response.statusCode == 200) {
        //print('my supervisor ${response.data}');

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
      print('Error: $e');
      throw Exception('Failed to load supervisor: $e');
    }
  }

  Future<List<dynamic>> myLead() async {
    dio.options.headers['Authorization'] = 'Token $token';

    try {
      final response = await dio.post('$baseUrl/callHandler/',data: {'action':'myLead'});
      //print(response.data);

      if (response.statusCode == 200) {
        //print('my Lead ${response.data}');

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
      print('Error: $e');
      throw Exception('Failed to load supervisor: $e');
    }
  }

  Future<List<dynamic>> getGanyavyakthi(String GV_id) async {
    dio.options.headers['Authorization'] = 'Token $token';

    try {
      final response = await dio.post('$baseUrl/callHandler/',data: {'action':'getGanyavyakthi','GV_id':GV_id});
      //print(response.data);

      if (response.statusCode == 200) {
        print('GV ${response.data[0]}');

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
      print('Error: $e');
      throw Exception('Failed to load supervisor: $e');
    }
  }

  Future<List<dynamic>> approveGanyavyakthi(String GV_id,String KR_id) async {
    dio.options.headers['Authorization'] = 'Token $token';

    try {
      final response = await dio.post('$baseUrl/callHandler/',
          data: {'action':'ApproveGanyaVyakti','GV_id':GV_id,'KR_id':KR_id}
      );
      //print(response.data);

      if (response.statusCode == 200) {
        //print('my supervisor ${response.data}');

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
      print('Error: $e');
      throw Exception('Failed to load supervisor: $e');
    }
  }

  Future<void> RecurSubordinates() async {
    dio.options.headers['Authorization'] = 'Token $token';

    try {
      final response = await dio.post('$baseUrl/callHandler/',data: {'action':'RecursiveSubordinates'});
      print(response.data);

      if (response.statusCode == 200) {
        print(response.data);
      } else {
        throw Exception('Failed to check user auth. Status code: ${response.statusCode}');
      }

    } catch (e) {
      print('Error: $e');
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
        print('Failed to create task: ${response.statusCode}');
        return false;
        throw Exception('Failed to create task. Status code: ${response.statusCode}');
      }
    } catch (e) {
      // Print the error and rethrow it
      print('Error: $e');
      throw Exception('Failed to create task: $e');
    }

    // Return false if for any reason the task could not be created
    return false;
  }

  Future<bool> createInteraction(List<dynamic> data) async {
    dio.options.headers['Authorization'] = 'Token $token';

    try {
      final response = await dio.post(
        '$baseUrl/callHandler/',
        data: {
          'action': 'addInteraction',
          'created_by': this.UserId,
          'ganya_vyakti': data[8],
          'title': data[0],
          'description': data[4],
          'discussion_points': data[7],
          'materials_distributed': data[5],
          'status': data[3],
          'virtual_meeting_link': data[6],
          'meeting_place': data[1],
          'meeting_datetime': data[2],
        },
      );

      // Check if the response is successful (status code 200)
      if (response.statusCode == 201) {
        return true;
      } else {
        // Log and throw exception if status code is not 200
        print('Failed to create task: ${response.statusCode}');
        return false;
        throw Exception('Failed to create task. Status code: ${response.statusCode}');
      }
    } catch (e) {
      // Print the error and rethrow it
      print('Error: $e');
      throw Exception('Failed to create task: $e');
    }

    // Return false if for any reason the task could not be created
    return false;
  }
  Future<bool> createMeeting(List<dynamic> data) async {
    dio.options.headers['Authorization'] = 'Token $token';

    try {
      final response = await dio.post(
        '$baseUrl/callHandler/',
        data: {
          'action': 'addBaitek',
          'title': data[1],
          'description': data[2],
          'venue':data[3],
          'participants': data[5],
          'organizers': data[5],
          'status': data[7],
          'meeting_datetime': data[4],
        },
      );

      // Check if the response is successful (status code 200)
      if (response.statusCode == 201) {
        return true;
      } else {
        // Log and throw exception if status code is not 200
        print('Failed to create task: ${response.statusCode}');
        return false;
        throw Exception('Failed to create task. Status code: ${response.statusCode}');
      }
    } catch (e) {
      // Print the error and rethrow it
      print('Error: $e');
      throw Exception('Failed to create task: $e');
    }

    // Return false if for any reason the task could not be created
    return false;
  }

  Future<List<dynamic>> getTasks(String GV_id) async {
    dio.options.headers['Authorization'] = 'Token $token';

    try {
      final response = await dio.post('$baseUrl/callHandler/',data: {'action':'get_task','GV_id':GV_id});
      //print(response.data);

      if (response.statusCode == 200) {
        //print('TS ${response.data}');

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
      print('Error: $e');
      throw Exception('Failed to load supervisor: $e');
    }
  }

  Future<bool> addUsers() async {
    dio.options.headers['Authorization'] = 'Token $token';

    try {
      final response = await dio.post('$baseUrl/callHandler/',data: {'action':'add_users'});
      //print(response.data);

      if (response.statusCode == 200) {
        //print('TS ${response.data}');

        return true;
      } else {
        throw Exception('Failed to load lead. Status code: ${response.statusCode}');
      }


    } catch (e) {
      print('Error: $e');
      throw Exception('Failed to load supervisor: $e');
    }
  }

  Future<List<dynamic>> getInteractionByID(String IR_id) async {
    dio.options.headers['Authorization'] = 'Token $token';

    try {
      print(IR_id);
      final response = await dio.post('$baseUrl/callHandler/',data: {'action':'get_interaction_by_id','id':IR_id});
      //print(response.data);

      if (response.statusCode == 200) {
        //print('TS ${response.data}');

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
      print('Error: $e');
      throw Exception('Failed to load supervisor: $e');
    }
  }

  Future<List<dynamic>> getInteraction(String GV_id) async {
    dio.options.headers['Authorization'] = 'Token $token';

    try {
      print(GV_id);
      final response = await dio.post('$baseUrl/callHandler/',data: {'action':'get_interaction','GV_id':GV_id});
      //print(response.data);

      if (response.statusCode == 200) {
        //print('TS ${response.data}');

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
      print('Error: $e');
      throw Exception('Failed to load supervisor: $e');
    }
  }

  Future<bool> markTaskComplete(task_id) async {
    dio.options.headers['Authorization'] = 'Token $token';

    try {
      final response = await dio.post(
        '$baseUrl/callHandler/',
        data: {'action': 'set_task_status','task_id': task_id},
      );

      // Check if the response is successful (status code 200)
      if (response.statusCode == 200) {
        return true;
      } else {
        // Log and throw exception if status code is not 200
        print('Failed to create task: ${response.statusCode}');
        return false;
        throw Exception('Failed to create task. Status code: ${response.statusCode}');
      }
    } catch (e) {
      // Print the error and rethrow it
      print('Error: $e');
      throw Exception('Failed to create task: $e');
    }
  }

}
