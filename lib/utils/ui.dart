import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Copies text and save it to clipboard, then displays a snackbar afterwards
void copyTextToClipboard(BuildContext context, String text) {
  Clipboard.setData(ClipboardData(text: text));

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Copied!')),
  );
}
