import 'package:flutter/material.dart';

class TempPage2 extends StatelessWidget {
  const TempPage2({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Page Under Development'),
      ),
      body: Center(
        child: Column(
          children: [
            Text(
              'This page is under development.',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          ],
        )
      ),
    );
  }
}
