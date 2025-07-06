import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TempPage2 extends StatelessWidget {
  const TempPage2({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        elevation: 0,
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
