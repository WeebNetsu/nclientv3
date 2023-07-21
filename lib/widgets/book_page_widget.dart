import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:nclientv3/utils/utils.dart';
import 'package:nhentai/nhentai.dart' as nh;
import 'package:path_provider/path_provider.dart';

class BookPageWidget extends StatefulWidget {
  final nh.Image _page;
  final nh.API _api;
  final String _bookName;

  const BookPageWidget({
    super.key,
    required nh.Image page,
    required nh.API api,
    required String bookName,
  })  : _page = page,
        _api = api,
        _bookName = bookName;

  @override
  State<BookPageWidget> createState() => _BookPageWidgetState();
}

class _BookPageWidgetState extends State<BookPageWidget> {
  late Future<void> _loadingPage;
  File? _image;

  Future<File> downloadImage({int retries = 0}) async {
    final directory = await getTemporaryDirectory();
    final dirName = '${directory.path}/${makeFilenameSafe(widget._bookName)}';
    final fileName = '$dirName/${makeFilenameSafe(widget._page.filename)}';
    final file = File(fileName);

    if (file.existsSync()) return file;

    final url = widget._page.getUrl(api: widget._api).toString();

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final bytes = response.bodyBytes;
      final newFile = File(fileName);
      //   create file and folders if it does not exist
      file.createSync(recursive: true);
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
          return const SizedBox(
            height: 500,
            child: Center(
              child: CircularProgressIndicator(),
            ),
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
