import 'package:flutter/material.dart';
import 'package:lazy_load_scrollview/lazy_load_scrollview.dart';
import 'package:nclientv3/models/models.dart';
import 'package:nclientv3/utils/utils.dart';
import 'package:nclientv3/widgets/widgets.dart';
import 'package:nhentai/nhentai.dart' as nh;
import 'package:random_string/random_string.dart';

class ReadBookView extends StatefulWidget {
  const ReadBookView({super.key});

  // this is so we can easily call the route
  // to this component from other files
  static route() => MaterialPageRoute(
        builder: (context) => const ReadBookView(),
      );

  @override
  State<ReadBookView> createState() => _ReadBookViewState();
}

class _ReadBookViewState extends State<ReadBookView> {
  Map<String, dynamic>? arguments;
  late Future<void> _loadingBook = fetchBook();
  String? _errorMessage;
  int? _bookId;
  nh.API? _api;
  nh.Book? _book;
  int _visiblePages = 5;
  bool _downloadingBook = false;
  final _userPreferences = UserPreferencesModel();

  /// if downloading the book, show total pages downloaded
  int? _totalPages;

  /// works directly with _totalDownloadPercent
  int _totalPagesDownloaded = 0;

  Future<void> fetchBook() async {
    if (_bookId == null || _api == null) {
      _errorMessage = "Did not get book ID or api... Coding bug, gomen!";
      return;
    }

    try {
      final book = await _api!.getBook(_bookId!);
      await _userPreferences.loadDataFromFile();

      setState(() {
        _book = book;
      });
    } on nh.ApiException catch (error) {
      if (error.message == "does not exist") {
        setState(() {
          _errorMessage = "Sorry friend, but $_bookId does not exist...";
        });
      } else {
        setState(() {
          _errorMessage = "Oh no, the API said '${error.message}'!";
        });
      }
    } catch (error) {
      setState(() {
        _errorMessage = "Oh no! something went wrong...";
      });
    }
  }

  Future<void> handleDownloadBook(int bookId) async {
    setState(() {
      _downloadingBook = true;
    });

    await downloadBook(
      _api!,
      bookId,
      afterSinglePageDownload: (totalPageCount) {
        setState(() {
          _totalPagesDownloaded++;
          _totalPages ??= totalPageCount;
        });
      },
    );
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      arguments = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;

      final int bookId = arguments?['bookId'];
      final nh.API api = arguments?['api'];

      _bookId = bookId;
      _api = api;
      _loadingBook = fetchBook();
    });
  }

  @override
  Widget build(BuildContext context) {
    // final scrollController = ScrollController();

    if (_errorMessage != null) {
      return MessagePageWidget(text: _errorMessage!);
    }

    if (_bookId == null || _api == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return Scaffold(
      body: FutureBuilder<void>(
        future: _loadingBook,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Display a loader while the future is executing
            return const SizedBox(
              height: 300,
              child: Center(
                child: CircularProgressIndicator(),
              ),
            );
          } else if (snapshot.hasError) {
            debugPrint("Error occurred: ${snapshot.error}");
            // Handle any error that occurred during the future execution
            return const MessagePageWidget(text: "Could not fetch the books, I am broken!");
          }

          final book = _book!;
          //   final bookTags = book.tags.map((e) => e.name).toList().join(', ');

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: LazyLoadScrollView(
              onEndOfPage: () {
                setState(() {
                  _visiblePages += 5;
                });
              },
              child: ListView(
                children: [
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          book.title.english ?? book.title.japanese ?? "OwO! No title?!",
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          child: GestureDetector(
                            onTap: () {
                              copyTextToClipboard(context, book.id.toString());
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
                                  "${book.id}",
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
                              Text("Pages: ${book.pages.length}"),
                              Text("Favorites: ${book.favorites}"),
                            ],
                          ),
                        ),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              const Text("Languages:"),
                              Row(
                                children: book.tags.languages
                                    .map(
                                      (e) => TextButton(
                                        child: Text(e.name),
                                        onPressed: () async {
                                          await Navigator.pushNamed(context, "/search", arguments: {
                                            "tag": e,
                                            "api": _api,
                                          });
                                        },
                                      ),
                                    )
                                    .toList(),
                              ),
                            ],
                          ),
                        ),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              const Text("Artists: "),
                              Row(
                                children: book.tags.artists.isEmpty
                                    ? [const Text("N/A")]
                                    : book.tags.artists
                                        .map(
                                          (e) => TagButtonWidget(
                                            tag: e,
                                            userPreferences: _userPreferences,
                                            api: _api,
                                          ),
                                        )
                                        .toList(),
                              ),
                            ],
                          ),
                        ),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              const Text("Tags:"),
                              Row(
                                children: book.tags.tags
                                    .map(
                                      (e) => TagButtonWidget(
                                        tag: e,
                                        userPreferences: _userPreferences,
                                        api: _api,
                                      ),
                                    )
                                    .toList(),
                              ),
                            ],
                          ),
                        ),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              const Text("Groups:"),
                              Row(
                                children: book.tags.groups
                                    .map(
                                      (e) => TagButtonWidget(
                                        tag: e,
                                        userPreferences: _userPreferences,
                                        api: _api,
                                      ),
                                    )
                                    .toList(),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Uploaded On: ${formatDateToString(book.uploaded)}"),
                            IconButton(
                              icon: const Icon(Icons.download),
                              onPressed: _downloadingBook || _totalPagesDownloaded == _totalPages
                                  ? null
                                  : () => handleDownloadBook(book.id),
                            )
                          ],
                        ),
                        if (_downloadingBook && _totalPagesDownloaded < 1) const LinearProgressIndicator(),
                        if (_totalPages != null)
                          Column(
                            children: [
                              Text(
                                _totalPagesDownloaded == _totalPages!
                                    ? "Download Done!"
                                    : "Downloading book, do not leave this page until it is done!",
                              ),
                              LinearProgressIndicator(
                                value: _totalPagesDownloaded / _totalPages!,
                                color: _totalPagesDownloaded == _totalPages! ? Colors.green : Colors.blue,
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),

                  // the actual doujin content
                  ListView.builder(
                    shrinkWrap: true, // Allow the ListView to take only the space it needs
                    physics: const NeverScrollableScrollPhysics(), // Disable scrolling for the ListView
                    itemCount: book.pages.length > _visiblePages ? _visiblePages : book.pages.length,
                    itemBuilder: (BuildContext context, int index) {
                      final page = book.pages[index];

                      return BookPageWidget(
                        api: _api!,
                        page: page,
                        bookName: book.title.english ?? randomAlphaNumeric(15),
                      );
                    },
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
