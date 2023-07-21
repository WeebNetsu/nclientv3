import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:nclientv3/constants/constants.dart';
import 'package:nclientv3/models/models.dart';
import 'package:nclientv3/widgets/widgets.dart';
import 'package:nhentai/nhentai.dart' as nh;

class SearchView extends StatefulWidget {
  const SearchView({super.key});

  // this is so we can easily call the route
  // to this component from other files
  static route() => MaterialPageRoute(
        builder: (context) => const SearchView(),
      );

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  final FocusNode _focusNode = FocusNode();
  final _userPreferences = UserPreferencesModel();

  Map<String, dynamic>? arguments;
  String? _errorMessage;
  nh.API? _api;
  List<nh.Book> _searchedBooks = [];
  String? _lastSearchPrompt;

  /// Similar to _loadingBooks, but does not store a function
  bool _loading = false;

  late StreamSubscription<bool> keyboardSubscription;
  late Future<void> _loadingBooks = searchBooks('*');

  Future<void> searchBooks(String text, {nh.API? api}) async {
    setState(() {
      _errorMessage = null;
      _lastSearchPrompt = text;
    });

    if (api == null && _api == null) {
      _errorMessage = "Did not get books or api... Coding bug, gomen!";
      return;
    }

    try {
      setState(() {
        _loading = true;
      });

      final code = int.tryParse(text);

      if (code != null) {
        Navigator.pushNamed(context, "/read", arguments: {"bookId": code, "api": _api});
      }

      await _userPreferences.loadDataFromFile();

      final nh.Search searchRes = await (api ?? _api)!.searchSinglePage(
        text,
        sort: _userPreferences.sort ?? nh.SearchSort.popular,
      );

      setState(() {
        _searchedBooks = searchRes.books;
      });
    } on nh.ApiException {
      setState(() {
        _errorMessage = "Seems like a word is blacklisted by the API...";
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
      });
    }
  }

  Future<void> _reloadDataOnSpot() async {
    await searchBooks(_lastSearchPrompt ?? '', api: _api);
  }

  @override
  void initState() {
    super.initState();

    var keyboardVisibilityController = KeyboardVisibilityController();
    _loadingBooks = searchBooks("*", api: null);

    // Subscribe
    keyboardSubscription = keyboardVisibilityController.onChange.listen((bool visible) {
      if (!visible) {
        _focusNode.unfocus();
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      arguments = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;

      final String searchText = arguments?['searchText'];
      final nh.API? api = arguments?['api'];

      _api = api;
      _loadingBooks = searchBooks(searchText, api: api);
    });
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
            BottomSearchBarWidget(
              focusNode: _focusNode,
              handleSearch: searchBooks,
            ),
          ],
        ),
      );
    }

    return Scaffold(
      body: FutureBuilder<void>(
        future: _loadingBooks,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Display a loader while the future is executing
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            debugPrint("Error occurred: ${snapshot.error}");
            // Handle any error that occurred during the future execution
            return const MessagePageWidget(text: "Could not fetch the books, I am broken!");
          }

          if (_searchedBooks.isEmpty) {
            return Scaffold(
              body: Stack(
                children: [
                  const MessagePageWidget(
                    text: "It's all empty here! No books were found.",
                    statusEmoji: StatusEmojis.thinking,
                  ),
                  BottomSearchBarWidget(
                    focusNode: _focusNode,
                    handleSearch: searchBooks,
                  ),
                ],
              ),
            );
          }

          if (_loading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return Stack(
            children: [
              SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
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
                                ),
                                if (index + 1 < _searchedBooks.length)
                                  BookCoverWidget(
                                    book: _searchedBooks[index + 1],
                                    api: _api!,
                                  ),
                              ],
                            );
                          } else {
                            // Skip rendering for odd-indexed items
                            return Row(
                              children: [Container()],
                            );
                          }
                        },
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
              BottomSearchBarWidget(
                focusNode: _focusNode,
                handleSearch: searchBooks,
                reloadData: _reloadDataOnSpot,
              ),
            ],
          );
        },
      ),
    );
  }
}
