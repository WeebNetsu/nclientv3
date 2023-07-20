import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
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
  Map<String, dynamic>? arguments;
  String? _errorMessage;

  nh.API? _api;
  late StreamSubscription<bool> keyboardSubscription;

  late Future<void> _loadingBooks = searchBooks('*');
  List<nh.Book> _searchedBooks = [];

  Future<void> searchBooks(String text, {nh.API? api}) async {
    if (api == null && _api == null) {
      _errorMessage = "Did not get books or api... Coding bug, gomen!";
      return;
    }

    final Stream<nh.Search> searchedBooks = (api ?? _api)!.search(text, count: 1);

    try {
      await for (nh.Search search in searchedBooks) {
        setState(() {
          _searchedBooks = search.books;
        });

        break;
      }
    } catch (error) {
      // Handle any errors that occur during the stream
      debugPrint('Error: $error');
    }
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

    return Scaffold(
      //   appBar: appBar,
      // In Flutter, SingleChildScrollView is a widget that allows its child to be scrolled
      // in a single axis (either horizontally or vertically). It's often used to enable scrolling
      // for a widget that would otherwise overflow the screen.
      body: FutureBuilder<void>(
        future: _loadingBooks,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Display a loader while the future is executing
            print("Reached 103");
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            debugPrint("Error occurred: ${snapshot.error}");
            // Handle any error that occurred during the future execution
            return const ErrorPageWidget(text: "Could not fetch the books, I am broken!");
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
                              children: [
                                Container(),
                              ],
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
              ),
            ],
          );
        },
      ),
    );
  }
}
