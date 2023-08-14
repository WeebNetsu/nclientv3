import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:nclientv3/models/models.dart';
import 'package:nclientv3/utils/utils.dart';
import 'package:nclientv3/widgets/widgets.dart';
import 'package:nhentai/before_request_add_cookies.dart';
import 'package:nhentai/nhentai.dart' as nh;
import 'package:observe_internet_connectivity/observe_internet_connectivity.dart';

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
  final _userPreferences = UserPreferencesModel();
  final ScrollController _scrollController = ScrollController();

  late nh.API _api;
  late StreamSubscription<bool> keyboardSubscription;
  bool? _connectedToInternet;

  bool _apiDownError = false;

  /// similar to loadingBooks, but does not store a function
  bool _loading = false;
  bool _loadingNextPage = false;
  late Future<void> _loadingBooks;
  final List<nh.Book> _bookList = [];
  int _currentPage = 1;

  Future<void> _setNotRobot({bool? clearData = false}) async {
    await Navigator.pushNamed(context, "/not-a-robot", arguments: {"clearData": clearData});
  }

  Future<void> _fetchBooks({bool nextPage = false}) async {
    if (_connectedToInternet == false) return;

    await _userData.loadDataFromFile();

    final cookies = _userData.cookies;
    final userAgent = _userData.userAgent;

    if (cookies == null || cookies.isEmpty || userAgent == null || userAgent.isEmpty) {
      await _setNotRobot();
      return _fetchBooks();
    }

    final api = nh.API(
      // 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) FxQuantum/114.0 AppleWebKit/537.36 (KHTML, like Gecko) Chrome/118.0.0.0 Mobile Safari/537.36',
      userAgent: userAgent,
      beforeRequest: beforeRequestAddCookiesStatic(
        cookies,
      ),
    );

    setState(() {
      _api = api;
      if (nextPage) {
        _loadingNextPage = true;
        if (nextPage) _currentPage += 1;
      } else {
        _loading = true;
      }
    });

    await _userPreferences.loadDataFromFile();

    try {
      nh.Search searchedBooks;

      String searchQuery = generateSearchQueryString("", _userPreferences, searchTag: null);

      if (searchQuery.isEmpty) searchQuery = "*";

      // get 1 page of the most recent books
      searchedBooks = await _api.searchSinglePage(
        searchQuery,
        sort: _userPreferences.sort,
        page: _currentPage,
      );

      try {
        setState(() {
          _bookList.addAll(searchedBooks.books);
        });
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

      await _setNotRobot(clearData: true);
      return _fetchBooks();
    } catch (e) {
      debugPrint("Error on fetching books: $e");
      await _setNotRobot(clearData: true);
      return _fetchBooks();
    } finally {
      setState(() {
        _loading = false;
        _loadingNextPage = false;
      });
    }
  }

  Future<void> _searchNextPage() async {
    await _fetchBooks(nextPage: true);
  }

  void _scrollListener() {
    if (_userPreferences.slowInternetMode) return;

    if (_scrollController.position.atEdge) {
      if (_scrollController.position.pixels == 0) {
        // Reached the top of the scroll view
      } else {
        // Reached the bottom of the scroll view
        setState(() {
          _searchNextPage();
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();

    InternetConnectivity().hasInternetConnection.then((hasInternet) {
      setState(() {
        _connectedToInternet = hasInternet;
        _loadingBooks = _fetchBooks();
      });
    });

    var keyboardVisibilityController = KeyboardVisibilityController();

    // Subscribe
    keyboardSubscription = keyboardVisibilityController.onChange.listen((bool visible) {
      if (!visible) {
        // SystemChannels.textInput.invokeMethod('TextInput.hide');
        _focusNode.unfocus();
      }
    });

    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_connectedToInternet == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_connectedToInternet == false) {
      return const MessagePageWidget(
        text: "Damn! I can't seem to connect to the internet!",
        showDownloadsButton: true,
      );
    }

    if (_apiDownError) {
      return const MessagePageWidget(
        text: "Something went wrong, the API seems to be down",
        showDownloadsButton: true,
      );
    }

    return Scaffold(
      body: FutureBuilder<void>(
        future: _loadingBooks,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Display a loader while the future is executing
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            debugPrint("Error occurred: ${snapshot.error}");
            // Handle any error that occurred during the future execution
            return const MessagePageWidget(
              text: "Could not fetch the books, I am broken!",
              showDownloadsButton: true,
            );
          }

          if (_loading && !_loadingNextPage) {
            return const Center(child: CircularProgressIndicator());
          }

          return Stack(
            children: [
              SingleChildScrollView(
                controller: _scrollController,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      ListView.builder(
                        shrinkWrap: true, // Allow the ListView to take only the space it needs
                        physics: const NeverScrollableScrollPhysics(), // Disable scrolling for the ListView
                        itemCount: _bookList.length,
                        itemBuilder: (BuildContext context, int index) {
                          if (index % 2 == 0) {
                            // Create a new row after every 2nd item
                            return Row(
                              children: [
                                BookCoverWidget(
                                  book: _bookList[index],
                                  api: _api,
                                  lastBookFullWidth: index == _bookList.length - 1,
                                  reloadData: _fetchBooks,
                                  userPreferences: _userPreferences,
                                ),
                                if (index + 1 < _bookList.length)
                                  BookCoverWidget(
                                    book: _bookList[index + 1],
                                    api: _api,
                                    reloadData: _fetchBooks,
                                    userPreferences: _userPreferences,
                                  ),
                              ],
                            );
                          }

                          // Skip rendering for odd-indexed items
                          return Row(children: [Container()]);
                        },
                      ),
                      NextPageLoaderWidget(
                        userPreferences: _userPreferences,
                        loadingNextPage: _loadingNextPage,
                        fetchData: _searchNextPage,
                      ),
                    ],
                  ),
                ),
              ),
              BottomSearchBarWidget(
                focusNode: _focusNode,
                api: _api,
                reloadData: _fetchBooks,
              ),
            ],
          );
        },
      ),
    );
  }
}
