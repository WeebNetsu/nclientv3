import 'dart:io';

import 'package:flutter/material.dart';

class DownloadBookPageWidget extends StatefulWidget {
  final File _page;

  const DownloadBookPageWidget({
    super.key,
    required File page,
  }) : _page = page;

  @override
  State<DownloadBookPageWidget> createState() => _DownloadBookPageWidgetState();
}

class _DownloadBookPageWidgetState extends State<DownloadBookPageWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget._page.existsSync()) {
      return const Text("Oh no! Could not get this image!");
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Image.file(
        widget._page,
      ),
    );
  }
}
