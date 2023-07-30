import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:nclientv3/models/models.dart';
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

  late nh.API _api;
  late StreamSubscription<bool> keyboardSubscription;
  bool? _connectedToInternet;

  bool _apiDownError = false;

  /// similar to loadingBooks, but does not store a function
  bool _loading = false;
  late Future<void> _loadingBooks;
  List<nh.Book> _bookList = [];

  Future<void> setNotRobot({bool? clearData = false}) async {
    await Navigator.pushNamed(context, "/not-a-robot", arguments: {"clearData": clearData});
  }

  Future<void> fetchBooks() async {
    if (_connectedToInternet == false) return;

    await _userData.loadDataFromFile();

    final cookies = _userData.cookies;
    final userAgent = _userData.userAgent;

    if (cookies == null || cookies.isEmpty || userAgent == null || userAgent.isEmpty) {
      await setNotRobot();
      return fetchBooks();
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
      _loading = true;
    });

    await _userPreferences.loadDataFromFile();

    try {
      nh.Search searchedBooks;

      String searchQuery = "";

      if (_userPreferences.language != "*") {
        final languageQuery = nh.Tag.named(
          type: nh.TagType.language,
          name: _userPreferences.language,
        ).query;

        searchQuery += "$languageQuery";
      }

      if (_userPreferences.blacklistedTags.isNotEmpty) {
        for (final tag in _userPreferences.blacklistedTags) {
          final query = nh.Tag.named(
            type: nh.TagType.tag,
            name: tag,
          ).query;

          searchQuery += searchQuery.isEmpty ? '-$query' : ' -$query';
        }
      }

      if (_userPreferences.blacklistedArtists.isNotEmpty) {
        for (final tag in _userPreferences.blacklistedArtists) {
          final query = nh.Tag.named(
            type: nh.TagType.artist,
            name: tag,
          ).query;

          searchQuery += searchQuery.isEmpty ? '-$query' : ' -$query';
        }
      }

      if (_userPreferences.blacklistedGroups.isNotEmpty) {
        for (final tag in _userPreferences.blacklistedGroups) {
          final query = nh.Tag.named(
            type: nh.TagType.group,
            name: tag,
          ).query;

          searchQuery += searchQuery.isEmpty ? '-$query' : ' -$query';
        }
      }

      if (_userPreferences.whitelistedTags.isNotEmpty) {
        for (final tag in _userPreferences.whitelistedTags) {
          final query = nh.Tag.named(
            type: nh.TagType.tag,
            name: tag,
          ).query;

          searchQuery += searchQuery.isEmpty ? '$query' : ' $query';
        }
      }

      if (_userPreferences.whitelistedArtists.isNotEmpty) {
        for (final tag in _userPreferences.whitelistedArtists) {
          final query = nh.Tag.named(
            type: nh.TagType.artist,
            name: tag,
          ).query;

          searchQuery += searchQuery.isEmpty ? '$query' : ' $query';
        }
      }

      if (_userPreferences.whitelistedGroups.isNotEmpty) {
        for (final tag in _userPreferences.whitelistedGroups) {
          final query = nh.Tag.named(
            type: nh.TagType.group,
            name: tag,
          ).query;

          searchQuery += searchQuery.isEmpty ? '$query' : ' $query';
        }
      }

      if (searchQuery.isEmpty) searchQuery = "*";

      // get 1 page of the most recent books
      searchedBooks = await _api.searchSinglePage(
        searchQuery,
        sort: _userPreferences.sort,
      );

      try {
        setState(() {
          _bookList = searchedBooks.books;
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

      await setNotRobot(clearData: true);
      return fetchBooks();
    } catch (e) {
      debugPrint("Error on fetching books: $e");
      await setNotRobot(clearData: true);
      return fetchBooks();
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();

    InternetConnectivity().hasInternetConnection.then((hasInternet) {
      setState(() {
        _connectedToInternet = hasInternet;
        _loadingBooks = fetchBooks();
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
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            debugPrint("Error occurred: ${snapshot.error}");
            // Handle any error that occurred during the future execution
            return const MessagePageWidget(
              text: "Could not fetch the books, I am broken!",
              showDownloadsButton: true,
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
                                  reloadData: fetchBooks,
                                  userPreferences: _userPreferences,
                                ),
                                if (index + 1 < _bookList.length)
                                  BookCoverWidget(
                                    book: _bookList[index + 1],
                                    api: _api,
                                    reloadData: fetchBooks,
                                    userPreferences: _userPreferences,
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
                api: _api,
                reloadData: fetchBooks,
              ),
            ],
          );
        },
      ),
    );
  }
}
