import 'package:flutter/material.dart';
import 'package:nclientv3/widgets/widgets.dart';
import 'package:nhentai/nhentai.dart' as nh;

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
    if (_errorMessage != null) {
      return const ErrorPageWidget();
    }

    if (_bookId == null || _api == null) {
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
            return const ErrorPageWidget(text: "Could not fetch the books, I am broken!");
          }

          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              children: [
                SizedBox(height: 20),
                Expanded(
                  child: ListView.builder(
                    shrinkWrap: true, // Allow the ListView to take only the space it needs
                    // physics: const NeverScrollableScrollPhysics(), // Disable scrolling for the ListView
                    itemCount: _book!.pages.length,
                    itemBuilder: (BuildContext context, int index) {
                      final page = _book!.pages[index];

                      // Create a new row after every 2nd item
                      return Container(
                        child: BookPageWidget(
                          api: _api!,
                          page: page,
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }
}
