import 'package:flutter/material.dart';

class ErrorPageWidget extends StatelessWidget {
  final String _text;

  const ErrorPageWidget({super.key, String text = "An unknown error has just ocurred, sorry friend!"}) : _text = text;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              "assets/images/uoooh.png",
              width: 100,
            ),
            const SizedBox(height: 20),
            Text(_text),
          ],
        ),
      ),
    );
  }
}
