import 'package:flutter/material.dart';
import 'package:lazy_load_scrollview/lazy_load_scrollview.dart';
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
  int _visiblePages = 3;

  Future<void> fetchBook() async {
    if (_bookId == null || _api == null) {
      _errorMessage = "Did not get book ID or api... Coding bug, gomen!";
      return;
    }

    try {
      final book = await _api!.getBook(_bookId!);

      setState(() {
        _book = book;
      });
    } catch (error) {
      setState(() {
        _errorMessage = "Oh no! something went wrong...";
      });
    }
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
      return const MessagePageWidget();
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
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            debugPrint("Error occurred: ${snapshot.error}");
            // Handle any error that occurred during the future execution
            return const MessagePageWidget(text: "Could not fetch the books, I am broken!");
          }

          final book = _book!;
          final bookTags = book.tags.map((e) => e.name).toList().join(', ');

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
                        Text("Tags: $bookTags"),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Uploaded On: ${formatDateToString(book.uploaded)}"),
                            IconButton(onPressed: () {}, icon: const Icon(Icons.download))
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
