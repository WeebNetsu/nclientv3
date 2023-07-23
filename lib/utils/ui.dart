import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Copies text and save it to clipboard, then displays a snackbar afterwards
void copyTextToClipboard(BuildContext context, String text) {
  Clipboard.setData(ClipboardData(text: text));

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Copied!')),
  );
}

void showMessage(
  BuildContext context,
  String text, {
  int duration = 3,
  bool error = false,
}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(text),
      duration: Duration(seconds: duration),
      backgroundColor: error ? Colors.red : Colors.blue,
    ),
  );
}
