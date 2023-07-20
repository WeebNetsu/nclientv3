import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:nhentai/nhentai.dart' as nh;
import 'package:path_provider/path_provider.dart';

class BookPageWidget extends StatefulWidget {
  final nh.Image _page;
  final nh.API _api;

  const BookPageWidget({
    super.key,
    required nh.Image page,
    required nh.API api,
  })  : _page = page,
        _api = api;

  @override
  State<BookPageWidget> createState() => _BookPageWidgetState();
}

class _BookPageWidgetState extends State<BookPageWidget> {
  late Future<void> _loadingPage;
  File? _image;

  Future<File> downloadImage({int retries = 0}) async {
    final directory = await getTemporaryDirectory(); // Change this to your desired directory
    final file = File('${directory.path}/${widget._page.filename}'); // Change the file name and extension as needed

    if (file.existsSync()) {
      return file;
    }

    final url = widget._page.getUrl(api: widget._api).toString();

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final bytes = response.bodyBytes;
      final newFile =
          File('${directory.path}/${widget._page.filename}'); // Change the file name and extension as needed
      await newFile.writeAsBytes(bytes);
      return newFile;
    } else {
      if (retries < 3) {
        return downloadImage(retries: retries + 1);
      }

      throw Exception('Failed to download image');
    }
  }

  Future<void> fetchData() async {
    final img = await downloadImage();

    setState(() {
      _image = img;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadingPage = fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _loadingPage,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Display a loader while waiting for the async operation to complete
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasError) {
          // Handle any errors that occurred during the async operation
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        } else {
          if (_image == null) {
            return const Text("Oh no! Could not get this image!");
          }

          // Display the widget once the async operation is completed
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 7),
            child: Image.file(
              _image!,
            ),
          );
        }
      },
    );
  }
}
