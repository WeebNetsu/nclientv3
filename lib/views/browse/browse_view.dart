import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:nclientv3/models/models.dart';
import 'package:nclientv3/widgets/widgets.dart';
import 'package:nhentai/before_request_add_cookies.dart';
import 'package:nhentai/nhentai.dart' as nh;

class BrowseView extends StatefulWidget {
  const BrowseView({super.key});

  // this is so we can easily call the route
  // to this component from other files
  static route() => MaterialPageRoute(
        builder: (context) => const BrowseView(),
      );

  @override
  State<BrowseView> createState() => _BrowseViewState();
}

class _BrowseViewState extends State<BrowseView> {
  final _userData = UserDataModel();
  final FocusNode _focusNode = FocusNode();

  late nh.API _api;
  late StreamSubscription<bool> keyboardSubscription;

  bool _apiDownError = false;
  late Future<void> _loadingBooks;
  List<nh.Book> _recentBooks = [];

  Future<void> setNotRobot({bool? clearData = false}) async {
    await Navigator.pushNamed(context, "/not-a-robot", arguments: {"clearData": clearData});
  }

  Future<void> fetchBooks() async {
    await _userData.loadDataFromFile();

    final cookies = _userData.cookies;
    final userAgent = _userData.userAgent;

    if (cookies == null || cookies.isEmpty || userAgent == null || userAgent.isEmpty) {
      await setNotRobot();
      return fetchBooks();
    }

    final api = nh.API(
      //   'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) FxQuantum/114.0 AppleWebKit/537.36 (KHTML, like Gecko) Chrome/118.0.0.0 Mobile Safari/537.36',
      userAgent: userAgent,
      beforeRequest: beforeRequestAddCookiesStatic(
        cookies,
      ),
    );

    setState(() {
      _api = api;
    });

    try {
      // get 1 page of the most recent books
      final Stream<nh.Search> recentBooks = _api.search("*", count: 1);

      try {
        await for (nh.Search search in recentBooks) {
          setState(() {
            _recentBooks = search.books;
          });

          break;
        }
      } on nh.ApiException {
        setState(() {
          _apiDownError = true;
        });
      } catch (error) {
        // Handle any errors that occur during the stream
        debugPrint('Error: $error');
      }
    } on nh.ApiClientException catch (e) {
      debugPrint('originalException ${e.originalException}');
      debugPrint('message ${e.message}');
      debugPrint('reasonPhrase ${e.response?.reasonPhrase}');
      debugPrint('headers ${e.response?.headers}');
      debugPrint('statusCode ${e.response?.statusCode}');
      debugPrint('method ${e.request?.method}');
      debugPrint('headers ${e.request?.headers}');
      debugPrint('url ${e.request?.url}');

      await setNotRobot(clearData: true);
      return fetchBooks();
    } catch (e) {
      await setNotRobot(clearData: true);
      return fetchBooks();
    }
  }

  @override
  void initState() {
    super.initState();

    _loadingBooks = fetchBooks();

    var keyboardVisibilityController = KeyboardVisibilityController();

    // Subscribe
    keyboardSubscription = keyboardVisibilityController.onChange.listen((bool visible) {
      //   print('Keyboard visibility update. Is visible: $visible');
      if (!visible) {
        // SystemChannels.textInput.invokeMethod('TextInput.hide');
        _focusNode.unfocus();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_apiDownError) {
      return const ErrorPageWidget(
        text: "Something went wrong, the API seems to be down",
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
                        itemCount: _recentBooks.length,
                        itemBuilder: (BuildContext context, int index) {
                          if (index % 2 == 0) {
                            // Create a new row after every 2nd item
                            return Row(
                              children: [
                                BookCoverWidget(
                                  book: _recentBooks[index],
                                  api: _api,
                                  lastBookFullWidth: index == _recentBooks.length - 1,
                                ),
                                if (index + 1 < _recentBooks.length)
                                  BookCoverWidget(
                                    book: _recentBooks[index + 1],
                                    api: _api,
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
              BottomSearchBarWidget(focusNode: _focusNode, api: _api),
            ],
          );
        },
      ),
    );
  }
}
