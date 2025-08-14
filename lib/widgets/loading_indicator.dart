import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: CupertinoActivityIndicator(
          radius: 15,
          color: Color.fromRGBO(255, 255, 255, 1.0),
        ),
      ),
    );
  }
}

class LoadingIndicatorBlack extends StatelessWidget {
  const LoadingIndicatorBlack({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: CupertinoActivityIndicator(
          radius: 15,
          color: Color.fromRGBO(2, 40, 60, 1),
        ),
      ),
    );
  }
}

class LoadingIndicatorGreen extends StatelessWidget {
  const LoadingIndicatorGreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: CupertinoActivityIndicator(
          radius: 20,
          color: Colors.green,
        ),
      ),
    );
  }
}
