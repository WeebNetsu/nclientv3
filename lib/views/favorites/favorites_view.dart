import 'dart:io';

import 'package:flutter/material.dart';
import 'package:nclientv3/models/saved_book.dart';
import 'package:nclientv3/utils/app.dart';
import 'package:nclientv3/widgets/widgets.dart';

import 'widgets/favorited_book_cover_widget.dart';

class FavoritesView extends StatefulWidget {
  const FavoritesView({super.key});

  // this is so we can easily call the route
  // to this component from other files
  static route() => MaterialPageRoute(
        builder: (context) => const FavoritesView(),
      );

  @override
  State<FavoritesView> createState() => _FavoritesViewState();
}

class _FavoritesViewState extends State<FavoritesView> {
  List<SavedBookModel> _bookList = [];
  bool _loading = true;

  void reloadData() {
    setState(() {
      _loading = true;
      _bookList = [];
    });

    getDownloadedBooks().then((value) {
      setState(() {
        _loading = false;
      });
    }).catchError((e) {
      debugPrint(e);
    });
  }

  @override
  void initState() {
    super.initState();

    reloadData();
  }

  Future<void> getDownloadedBooks() async {
    final appDir = await getAppDir();
    if (appDir == null) return;

    for (var fileEntity in appDir.listSync()) {
      if (fileEntity is Directory) {
        final code = int.tryParse(fileEntity.path.split("/").last);
        if (code == null) continue;

        final book = SavedBookModel(code);
        await book.loadBookData();

        _bookList.add(book);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              PageTitleDisplay(title: "Favorites"),
              Center(child: CircularProgressIndicator()),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const PageTitleDisplay(title: "Downloads"),
              ListView.builder(
                shrinkWrap: true, // Allow the ListView to take only the space it needs
                physics: const NeverScrollableScrollPhysics(), // Disable scrolling for the ListView
                itemCount: _bookList.length,
                itemBuilder: (BuildContext context, int index) {
                  if (index % 2 == 0) {
                    // Create a new row after every 2nd item
                    return Row(
                      children: [
                        DownloadedBookCoverWidget(
                          book: _bookList[index],
                          lastBookFullWidth: index == _bookList.length - 1,
                          reloadPage: reloadData,
                        ),
                        if (index + 1 < _bookList.length)
                          DownloadedBookCoverWidget(
                            book: _bookList[index + 1],
                            reloadPage: reloadData,
                          ),
                      ],
                    );
                  } else {
                    // Skip rendering for odd-indexed items
                    return Row(children: [Container()]);
                  }
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
