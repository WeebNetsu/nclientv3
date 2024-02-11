import 'dart:async';

import 'package:flutter/material.dart';
import 'package:nclientv3/constants/constants.dart';
import 'package:nclientv3/models/models.dart';
import 'package:nclientv3/theme/theme.dart';
import 'package:nclientv3/widgets/widgets.dart';
import 'package:nhentai/nhentai.dart' as nh;
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';

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
  final pageIndexNotifier = ValueNotifier(0);
  final _userPreferences = UserPreferencesModel();
//   final ScrollController _scrollController = ScrollController();

  Map<String, dynamic>? arguments;
  String? _errorMessage;
  nh.API? _api;
//   int _currentPage = 1;

  /// if searching for a specific tag
  final List<nh.Book> _searchedBooks = [];

  /// list of books that were not found on fetch (most likely deleted by nhentai)
  final List<int> _notFoundBooks = [];

  /// Similar to _loadingBooks, but does not store a function
  bool _loading = false;
  // bool _loadingNextPage = false;

  late Future<void> _loadingBooks = _searchBooks();

  Future<void> _fetchBook(int bookId) async {
    if (_api == null) {
      _errorMessage = "Did not get the api... Coding bug, gomen!";
      return;
    }

    try {
      final book = await _api!.getBook(bookId);
      await _userPreferences.loadDataFromFile();

      setState(() {
        _searchedBooks.add(book);
      });
    } on nh.ApiException catch (error) {
      if (error.message == "does not exist") {
        setState(() {
          _notFoundBooks.add(bookId);
        });
      } else {
        setState(() {
          _errorMessage = "Oh no, the API said '${error.message}'!";
        });
      }
    } on nh.ApiClientException catch (error) {
      if (error.response?.reasonPhrase == "Too Many Requests") {
        // just retry the fetch
        await _fetchBook(bookId);
      } else {
        setState(() {
          _errorMessage = "Oh no! something went wrong...";
        });
      }
    } catch (error) {
      print(error);
      setState(() {
        _errorMessage = "Oh no! something went wrong...";
      });
    }
  }

  Future<void> _searchBooks({int? selectedBookId, nh.API? api}) async {
    setState(() {
      _errorMessage = null;
    });

    if (api == null && _api == null) {
      _errorMessage = "Did not get api... Coding bug, gomen!";
      return;
    }

    try {
      setState(() {
        // if (nextPage) {
        //   //   _loadingNextPage = true;
        //   _currentPage += 1;
        // } else {
        //   _currentPage = 1;
        _loading = true;
        // }
      });

      if (selectedBookId != null) {
        await Navigator.pushNamed(context, "/read", arguments: {"bookId": selectedBookId, "api": _api});
        // if user searched for a code, then after they have opened the book,
        // they will be redirected back to the page before they made the search,
        // so they don't see an empty search page
        (() => Navigator.pop(context))();
      }

      await _userPreferences.loadDataFromFile();
      await Future.wait(_userPreferences.favoriteBooks.map((book) => _fetchBook(book)));

      setState(() {
        if (_notFoundBooks.isNotEmpty) {
          WoltModalSheet.show<void>(
            pageIndexNotifier: pageIndexNotifier,
            context: context,
            pageListBuilder: (modalSheetContext) {
              return [
                removedBooksPopup(modalSheetContext),
              ];
            },
            modalTypeBuilder: (context) {
              final size = MediaQuery.of(context).size.width;
              if (size < 768) {
                return WoltModalType.bottomSheet;
              } else {
                return WoltModalType.dialog;
              }
            },
            // onModalDismissedWithBarrierTap: () {
            //   debugPrint('Closed modal sheet with barrier tap');
            //   pageIndexNotifier.value = 0;
            // },
            maxDialogWidth: 560,
            minDialogWidth: 400,
            minPageHeight: 0.1,
            maxPageHeight: 0.9,
          );
        }

        _loading = false;
      });
    } catch (error) {
      setState(() {
        _errorMessage = "Oh no! An unknown error occurred, what a tragedy...";
      });
      // Handle any errors that occur during the stream
      debugPrint('Error: $error');
    } finally {
      setState(() {
        _loading = false;
        // _loadingNextPage = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();

    _loadingBooks = _searchBooks(api: null);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        arguments = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
        final nh.API? api = arguments?['api'];

        _api = api;
        _loadingBooks = _searchBooks(api: api);
      } catch (e) {
        _errorMessage = "Could not get API... Coding bug, gomen!";
      }
    });

    // _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    // _scrollController.removeListener(_scrollListener);
    // _scrollController.dispose();
    super.dispose();
  }

  WoltModalSheetPage removedBooksPopup(BuildContext modalSheetContext) {
    return WoltModalSheetPage.withSingleChild(
      backgroundColor: Palette.backgroundColor,
      child: Column(
        children: [
          const Text("These following books could not be found."),
          const Text("They may have been removed by nHentai."),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: _notFoundBooks.map((book) {
              return Text("${book.toString()} ");
            }).toList(),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              MaterialButton(
                onPressed: () {
                  for (int book in _notFoundBooks) {
                    if (_userPreferences.favoriteBooks.contains(book)) {
                      final bookIndex = _userPreferences.favoriteBooks.indexOf(book);
                      _userPreferences.favoriteBooks.removeAt(bookIndex);
                    }
                  }

                  setState(() {
                    _userPreferences.saveToFileData();
                  });

                  Navigator.of(modalSheetContext).pop();
                  pageIndexNotifier.value = 0;
                },
                child: const Text("Remove From Favorites"),
              ),
              MaterialButton(
                onPressed: () {
                  Navigator.of(modalSheetContext).pop();
                  pageIndexNotifier.value = 0;
                },
                child: const Text("Close"),
              ),
            ],
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_api == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        body: Stack(
          children: [
            MessagePageWidget(text: _errorMessage!),
          ],
        ),
      );
    }

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: Column(
            children: [
              const PageTitleDisplay(
                title: "Favorites",
                removeBottomPadding: true,
              ),
              FutureBuilder<void>(
                future: _loadingBooks,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    // Display a loader while the future is executing
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    debugPrint("Error occurred: ${snapshot.error}");
                    // Handle any error that occurred during the future execution
                    return const MessagePageWidget(text: "Could not fetch the books, I am broken!");
                  }

                  if (_searchedBooks.isEmpty) {
                    return const Scaffold(
                      body: Stack(
                        children: [
                          MessagePageWidget(
                            text: "It's all empty here! No books were found.",
                            statusEmoji: StatusEmojis.thinking,
                          ),
                        ],
                      ),
                    );
                  }

                  if (_loading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  return Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Column(
                          children: [
                            ListView.builder(
                              shrinkWrap: true, // Allow the ListView to take only the space it needs
                              physics: const NeverScrollableScrollPhysics(), // Disable scrolling for the ListView
                              itemCount: _searchedBooks.length,
                              itemBuilder: (BuildContext context, int index) {
                                if (index % 2 == 0) {
                                  // Create a new row after every 2nd item
                                  return Row(
                                    children: [
                                      BookCoverWidget(
                                        book: _searchedBooks[index],
                                        api: _api!,
                                        lastBookFullWidth: index == _searchedBooks.length - 1,
                                        userPreferences: _userPreferences,
                                      ),
                                      if (index + 1 < _searchedBooks.length)
                                        BookCoverWidget(
                                          book: _searchedBooks[index + 1],
                                          api: _api!,
                                          userPreferences: _userPreferences,
                                        ),
                                    ],
                                  );
                                }
                                // Skip rendering for odd-indexed items
                                return Row(children: [Container()]);
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
