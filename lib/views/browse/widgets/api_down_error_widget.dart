import 'package:flutter/material.dart';

class ApiDownErrorWidget extends StatelessWidget {
  const ApiDownErrorWidget({
    super.key,
  });

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
            const Text("Something went wrong, the API seems to be down"),
          ],
        ),
      ),
    );
  }
}
