import 'package:flutter/material.dart';
import 'package:nclientv3/models/user_preferences.dart';
import 'package:nclientv3/utils/utils.dart';
import 'package:nclientv3/widgets/widgets.dart';
import 'package:nhentai/nhentai.dart' as nh;

class BookInfoWidget extends StatefulWidget {
  final Future<void> Function(int bookId)? _handleDownloadBook;
  final nh.API? _api;
  final nh.Book _book;
  final UserPreferencesModel _userPreferences;
  final bool? _downloadingBook;
  final int? _totalPagesDownloaded;
  final int? _totalPages;
  final Color? _textColor;

  /// if downloading the book, show total pages downloaded

  const BookInfoWidget({
    super.key,
    required nh.API? api,
    required nh.Book book,
    required UserPreferencesModel userPreferences,
    Future<void> Function(int bookId)? handleDownloadBook,
    bool? downloadingBook = false,
    int? totalPagesDownloaded = 0,
    int? totalPages,
    Color? textColor = Colors.white,
  })  : _handleDownloadBook = handleDownloadBook,
        _api = api,
        _book = book,
        _userPreferences = userPreferences,
        _downloadingBook = downloadingBook,
        _totalPagesDownloaded = totalPagesDownloaded,
        _totalPages = totalPages,
        _textColor = textColor;

  @override
  State<BookInfoWidget> createState() => _BookInfoWidgetState();
}

class _BookInfoWidgetState extends State<BookInfoWidget> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget._book.title.english ?? widget._book.title.japanese ?? "OwO! No title?!",
            style: TextStyle(
              color: widget._textColor,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: GestureDetector(
              onTap: () {
                copyTextToClipboard(context, widget._book.id.toString());
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Code: ",
                    style: TextStyle(
                      color: widget._textColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "${widget._book.id}",
                    style: TextStyle(
                      color: widget._textColor,
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
                Text(
                  "Pages: ${widget._book.pages.length}",
                  style: TextStyle(color: widget._textColor),
                ),
                Text(
                  "Favorites: ${widget._book.favorites}",
                  style: TextStyle(color: widget._textColor),
                ),
                Material(
                  type: MaterialType.transparency,
                  child: IconButton(
                    onPressed: () {
                      // Add your onPressed logic here
                      if (widget._userPreferences.favoriteBooks.contains(widget._book.id)) {
                        final bookIndex = widget._userPreferences.favoriteBooks.indexOf(widget._book.id);
                        widget._userPreferences.favoriteBooks.removeAt(bookIndex);
                      } else {
                        widget._userPreferences.favoriteBooks.add(widget._book.id);
                      }

                      setState(() {
                        widget._userPreferences.saveToFileData();
                      });
                    },
                    icon: Icon(
                      widget._userPreferences.favoriteBooks.contains(widget._book.id)
                          ? Icons.star
                          : Icons.star_outline_outlined,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ),
              ],
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                Text(
                  "Languages:",
                  style: TextStyle(color: widget._textColor),
                ),
                Row(
                  children: widget._book.tags.languages
                      .map(
                        (e) => TextButton(
                          child: Text(e.name),
                          onPressed: () async {
                            await Navigator.pushNamed(context, "/search", arguments: {
                              "tag": e,
                              "api": widget._api,
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
                Text(style: TextStyle(color: widget._textColor), "Artists: "),
                Row(
                  children: widget._book.tags.artists.isEmpty
                      ? [Text(style: TextStyle(color: widget._textColor), "N/A")]
                      : widget._book.tags.artists
                          .map(
                            (e) => TagButtonWidget(
                              tag: e,
                              userPreferences: widget._userPreferences,
                              api: widget._api,
                              reloadData: () async {
                                setState(() {});
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
                Text(style: TextStyle(color: widget._textColor), "Tags:"),
                Row(
                  children: widget._book.tags.tags
                      .map(
                        (e) => TagButtonWidget(
                          tag: e,
                          userPreferences: widget._userPreferences,
                          api: widget._api,
                          reloadData: () async {
                            setState(() {});
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
                Text(style: TextStyle(color: widget._textColor), "Characters: "),
                Row(
                  children: widget._book.tags.characters.isEmpty
                      ? [Text(style: TextStyle(color: widget._textColor), "N/A")]
                      : widget._book.tags.characters
                          .map(
                            (e) => TagButtonWidget(
                              tag: e,
                              userPreferences: widget._userPreferences,
                              api: widget._api,
                              reloadData: () async {
                                setState(() {});
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
                Text(style: TextStyle(color: widget._textColor), "Groups:"),
                Row(
                  children: widget._book.tags.groups
                      .map(
                        (e) => TagButtonWidget(
                          tag: e,
                          userPreferences: widget._userPreferences,
                          api: widget._api,
                          reloadData: () async {
                            setState(() {});
                          },
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
              Text(
                  style: TextStyle(color: widget._textColor),
                  "Uploaded On: ${formatDateToString(widget._book.uploaded)}"),
              if (widget._handleDownloadBook != null && widget._downloadingBook != null)
                IconButton(
                  icon: const Icon(Icons.download),
                  onPressed: widget._downloadingBook! || widget._totalPagesDownloaded == widget._totalPages
                      ? null
                      : () => widget._handleDownloadBook!(widget._book.id),
                )
            ],
          ),
          if ((widget._downloadingBook ?? false) && (widget._totalPagesDownloaded ?? 0) < 1)
            const LinearProgressIndicator(),
          if (widget._totalPages != null && widget._totalPagesDownloaded != null && widget._handleDownloadBook != null)
            Column(
              children: [
                Text(
                  style: TextStyle(color: widget._textColor),
                  widget._totalPagesDownloaded == widget._totalPages!
                      ? "Download Done!"
                      : "Downloading book, do not leave this page until it is done!",
                ),
                LinearProgressIndicator(
                  value: widget._totalPagesDownloaded! / widget._totalPages!,
                  color: widget._totalPagesDownloaded == widget._totalPages! ? Colors.green : Colors.blue,
                ),
              ],
            ),
        ],
      ),
    );
  }
}
