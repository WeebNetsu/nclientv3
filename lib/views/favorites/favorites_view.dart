import 'dart:async';

import 'package:flutter/material.dart';
import 'package:nclientv3/constants/constants.dart';
import 'package:nclientv3/models/models.dart';
import 'package:nclientv3/widgets/widgets.dart';
import 'package:nhentai/nhentai.dart' as nh;

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
  final _userPreferences = UserPreferencesModel();
//   final ScrollController _scrollController = ScrollController();

  Map<String, dynamic>? arguments;
  String? _errorMessage;
  nh.API? _api;
  int _currentPage = 1;

  /// if searching for a specific tag
  final List<nh.Book> _searchedBooks = [];

  /// Similar to _loadingBooks, but does not store a function
  bool _loading = false;
//   bool _loadingNextPage = false;

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
      setState(() {
        _errorMessage = "Oh no, the API said '${error.message}'!";
      });
    } on nh.ApiClientException catch (e) {
      if (e.response?.reasonPhrase == "Too Many Requests") {
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

  Future<void> _searchBooks({int? selectedBookId, nh.API? api, bool nextPage = false}) async {
    setState(() {
      _errorMessage = null;
    });

    if (api == null && _api == null) {
      _errorMessage = "Did not get api... Coding bug, gomen!";
      return;
    }

    try {
      setState(() {
        if (nextPage) {
          //   _loadingNextPage = true;
          _currentPage += 1;
        } else {
          _currentPage = 1;
          _loading = true;
        }
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
        //   if (!nextPage) _searchedBooks.clear();
        _loading = false;
        //   _loadingNextPage = false;
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

//   void _scrollListener() {
//     if (_userPreferences.slowInternetMode) return;

//     if (_scrollController.position.atEdge) {
//       if (_scrollController.position.pixels == 0) {
//         // Reached the top of the scroll view
//       } else {
//         // Reached the bottom of the scroll view
//         setState(() {
//           _searchNextPage();
//         });
//       }
//     }
//   }

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
