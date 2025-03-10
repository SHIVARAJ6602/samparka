import 'package:flutter/material.dart';
import 'package:samparka/Screens/home.dart'; //InfluencersPage()
import 'package:samparka/Screens/login.dart'; //LoginPage()
import 'package:samparka/Screens/error_page.dart'; //ErrorPage()
import 'package:samparka/Screens/add_influencer.dart'; //AddInfluencerPage()
import 'package:samparka/Service/api_service.dart';
import 'Screens/API_TEST.dart';
import 'Screens/temp.dart'; //TaskListScreen()

void main() {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure bindings are initialized
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});
  final ApiService apiService = ApiService(); // Initializing ApiService here

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
        return _buildApp(apiService);
      },
    );
  }

  // Helper function to build the waiting state screen
  Widget _buildWaitingState() {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Samparka',
      home: Center(child: CircularProgressIndicator(color: Colors.green, backgroundColor: Colors.white,)),
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
  Widget _buildApp(ApiService apiService) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Samparka',
      home: InfluencersPage(),
      //home: apiService.isAuthenticated ? const InfluencersPage() : const LoginPage(),
    );
  }

  Future<void> _wait(ApiService apiService) async {
    await Future.delayed(const Duration(milliseconds: 50));
  }
}
