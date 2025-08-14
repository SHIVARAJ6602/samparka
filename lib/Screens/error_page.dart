import 'package:flutter/material.dart';

class ErrorPage extends StatefulWidget {
  const ErrorPage({super.key});

  @override
  _ErrorPageState createState() => _ErrorPageState();
}

class _ErrorPageState extends State<ErrorPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Clean white background
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0), // Padding around the content
          child: Container(
            padding: const EdgeInsets.all(30.0), // Space around the text
            decoration: BoxDecoration(
              color: Colors.red.shade50, // Light red background for the error message
              borderRadius: BorderRadius.circular(12.0), // Rounded corners for the container
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  offset: Offset(0, 4),
                  blurRadius: 8.0,
                ),
              ],
            ),
            child: Text(
              'Sorry :( Something went Wrong!',
              style: TextStyle(
                fontSize: 18, // Slightly larger font size
                fontWeight: FontWeight.bold,
                color: Colors.red.shade800, // Darker red for the error text
              ),
            ),
          ),
        ),
      ),
    );
  }
}
