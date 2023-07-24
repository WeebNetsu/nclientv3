import 'dart:io';

import 'package:flutter/material.dart';
import 'package:nclientv3/models/saved_book.dart';
import 'package:nclientv3/utils/utils.dart';
import 'package:nclientv3/widgets/widgets.dart';

class DownloadsReadBookView extends StatefulWidget {
  const DownloadsReadBookView({super.key});

  // this is so we can easily call the route
  // to this component from other files
  static route() => MaterialPageRoute(
        builder: (context) => const DownloadsReadBookView(),
      );

  @override
  State<DownloadsReadBookView> createState() => _DownloadsReadBookViewState();
}

class _DownloadsReadBookViewState extends State<DownloadsReadBookView> {
  Map<String, dynamic>? arguments;
  bool _loading = true;
  String? _errorMessage;
  int? _bookId;
  SavedBookModel? _book;
  final List<File> _images = [];

  Future<void> fetchBook() async {
    try {
      if (_bookId == null) {
        _errorMessage = "Did not get book ID... Coding bug, gomen!";
        return;
      }

      final appDir = await getAppDir();

      if (appDir == null) {
        _errorMessage = "Oh no! I couldn't find the book...";
        return;
      }

      final bookDir = Directory("${appDir.path}/$_bookId");
      for (final item in bookDir.listSync()) {
        if (item is File) {
          if (item.path.endsWith(".jpg")) {
            _images.add(item);
          }
        }
      }

      String getImageName(String path) {
        return path.split("/").last.split(".").first;
      }

      _images.sort(
        ((a, b) => (int.tryParse(getImageName(a.path)) ?? 0).compareTo(int.tryParse(getImageName(b.path)) ?? 0)),
      );

      _book = SavedBookModel(_bookId!);
      await _book!.loadBookData();
    } catch (error) {
      setState(() {
        _errorMessage = "Oh no! something went wrong...";
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      arguments = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;

      final int? bookId = arguments?['bookId'];

      _bookId = bookId;
      fetchBook();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_errorMessage != null) return const MessagePageWidget();

    if (_bookId == null || _loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_book == null) return const MessagePageWidget();

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: ListView(
          children: [
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _book!.title ?? "OwO! No title?!",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: GestureDetector(
                      onTap: () {
                        copyTextToClipboard(context, _book!.id.toString());
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Code: ",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "${_book!.id}",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 5, 0, 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Pages: ${_images.length}"),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () async {
                            await _book!.deleteBook(afterDelete: () => Navigator.pop(context));
                          },
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),

            // the actual doujin content
            ListView.builder(
              shrinkWrap: true, // Allow the ListView to take only the space it needs
              physics: const NeverScrollableScrollPhysics(), // Disable scrolling for the ListView
              itemCount: _images.length,
              itemBuilder: (BuildContext context, int index) {
                final page = _images[index];

                return BookPageWidget(page: page);
              },
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
