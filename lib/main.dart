import 'package:flutter/material.dart';
import 'package:samparka/Screens/l1home.dart'; //InfluencersPage()
import 'package:samparka/Screens/login.dart'; //LoginPage()
import 'package:samparka/Screens/error_page.dart'; //ErrorPage()
import 'package:samparka/Screens/add_influencer.dart'; //AddInfluencerPage()
import 'package:samparka/Service/api_service.dart';
import 'Screens/API_TEST.dart'; //TaskListScreen()

void main() {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure bindings are initialized
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});
  final apiService = ApiService();

  @override
  Widget build(BuildContext context) {
    // FutureBuilder only for initialization, not MaterialApp rebuilding
    return FutureBuilder<void>(
      future: _wait(), // Initialize ApiService and load authentication state
      //future: null,
      builder: (context, snapshot) {
        // Handle different states of the Future
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Samparka',
            home: Center(child: CircularProgressIndicator()), // Waiting for initialization
          );
        }

        if (snapshot.hasError) {
          // If there's an error, show an error page or retry option
          return const MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Samparka',
            home: ErrorPage(),
          );
        }

        // Once initialization is complete, return the actual MaterialApp
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Samparka',
          // Depending on whether the user is authenticated or not, show the correct page
          home: apiService.isAuthenticated ? const InfluencersPage() : const LoginPage(),
        );
      },
    );
  }

  Future<void> _wait() async {
    await Future.delayed(const Duration(milliseconds: 10));
  }
}


/*class MyApp extends StatelessWidget {
  const MyApp({super.key});
  //final ApiService apiService = ApiService();

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Samparka',
      //home: InfluencersPage(),
      //home: AddInfluencerPage(),
      home: LoginPage()
    );
  }
}*/
