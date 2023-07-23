import 'package:flutter/material.dart';

class ArrowRowButton extends StatelessWidget {
  final String text;
  final void Function() onPressed;

  const ArrowRowButton({
    super.key,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        MaterialButton(
          onPressed: onPressed,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    text,
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
                IconButton(
                  onPressed: onPressed,
                  icon: const Icon(Icons.arrow_forward),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}
