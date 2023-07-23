import 'package:flutter/material.dart';

class PageTitleDisplay extends StatelessWidget {
  const PageTitleDisplay({
    super.key,
    required this.title,
  });

  final String title;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 50),
        Row(children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back),
          ),
          Expanded(
            child: Align(
              alignment: const Alignment(-0.1, 0),
              child: Text(
                title,
                style: const TextStyle(fontSize: 30),
              ),
            ),
          ),
        ]),
        const SizedBox(height: 20),
      ],
    );
  }
}
