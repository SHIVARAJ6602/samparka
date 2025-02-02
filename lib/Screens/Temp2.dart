import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class MultiImagePickerScreen extends StatefulWidget {
  @override
  _MultiImagePickerScreenState createState() => _MultiImagePickerScreenState();
}

class _MultiImagePickerScreenState extends State<MultiImagePickerScreen> {
  bool isLoading = false; // Track loading state

  // Simulated register function
  Future<void> registerInfluencer() async {
    // Simulate a network request or some time-consuming operation
    await Future.delayed(Duration(seconds: 3));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Register Influencer")),
      body: Stack(
        children: [
          // Your main content goes here
          Center(
            child: ElevatedButton(
              onPressed: () async {
                setState(() {
                  isLoading = true; // Show loading indicator
                });

                await registerInfluencer();

                setState(() {
                  isLoading = false; // Hide loading indicator
                });
              },
              child: Text("Register Influencer"),
            ),
          ),
          // Show the circular progress indicator if isLoading is true
          if (isLoading)
            Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
