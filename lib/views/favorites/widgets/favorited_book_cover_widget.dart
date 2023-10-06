import 'package:flutter/material.dart';
import 'package:nclientv3/constants/constants.dart';
import 'package:nclientv3/models/models.dart';

class DownloadedBookCoverWidget extends StatelessWidget {
  final SavedBookModel _book;

  final bool _lastBookFullWidth;
  final void Function() _reloadPage;

  const DownloadedBookCoverWidget({
    super.key,
    required SavedBookModel book,
    required void Function() reloadPage,
    bool lastBookFullWidth = false,
  })  : _book = book,
        _reloadPage = reloadPage,
        _lastBookFullWidth = lastBookFullWidth;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: GestureDetector(
          onTap: () async {
            await Navigator.pushNamed(context, "/downloads/read", arguments: {"bookId": _book.id});
            _reloadPage();
          },
          child: Stack(
            children: [
              LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  final paddingWidth = constraints.maxWidth;
                  final coverImage = _book.coverImage;

                  return Padding(
                    padding: const EdgeInsets.all(0),
                    child: Stack(
                      children: [
                        coverImage != null && coverImage.existsSync()
                            ? Image.file(coverImage)
                            : Image.asset(AssetConstants.coverImageLoaderPath),
                        Positioned(
                          bottom: 0,
                          child: Container(
                            color: Colors.black.withOpacity(0.5),
                            width: paddingWidth,
                            child: Padding(
                              padding:
                                  _lastBookFullWidth ? const EdgeInsets.fromLTRB(5, 5, 5, 35) : const EdgeInsets.all(5),
                              child: Text(
                                _book.title ?? _book.id.toString(),
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
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
