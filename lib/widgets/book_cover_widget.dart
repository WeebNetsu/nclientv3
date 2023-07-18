import 'package:flutter/material.dart';
import 'package:nhentai/nhentai.dart' as nh;

class BookCoverWidget extends StatelessWidget {
  final nh.Book _book;
  final nh.API _api;

  /// if this is the last book on the page, and it can stretch
  /// the full width of the page, then we can apply special
  /// styling
  final bool _lastBookFullWidth;

  const BookCoverWidget({
    super.key,
    required nh.Book book,
    required nh.API api,
    bool lastBookFullWidth = false,
  })  : _book = book,
        _api = api,
        _lastBookFullWidth = lastBookFullWidth;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            // double expandedWidth = constraints.maxWidth;
            return GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, "/read");
              },
              child: Stack(
                children: [
                  LayoutBuilder(
                    builder: (BuildContext context, BoxConstraints constraints) {
                      double paddingWidth = constraints.maxWidth;
                      return Padding(
                        padding: const EdgeInsets.all(0),
                        child: LayoutBuilder(
                          builder: (BuildContext context, BoxConstraints constraints) {
                            //   double stackWidth = constraints.maxWidth;
                            return Stack(
                              children: [
                                Image.network(
                                  _book.thumbnail.getUrl(api: _api).toString(),
                                ),
                                // : Image.asset(
                                //     AssetConstants.coverImagePath,
                                //   ),
                                Positioned(
                                  bottom: 0,
                                  child: Container(
                                    color: Colors.black.withOpacity(0.5),
                                    width: paddingWidth,
                                    child: Padding(
                                      padding: _lastBookFullWidth
                                          ? const EdgeInsets.fromLTRB(5, 5, 5, 35)
                                          : const EdgeInsets.all(5),
                                      child: Text(
                                        _book.title.english ?? _book.title.japanese ?? "No title?",
                                        softWrap: true,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: _lastBookFullWidth ? 20 : 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      );
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
