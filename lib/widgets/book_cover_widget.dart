import 'package:flutter/material.dart';
import 'package:focused_menu/modals.dart';
import 'package:nclientv3/models/user_preferences.dart';
import 'package:nclientv3/theme/theme.dart';
import 'package:nclientv3/widgets/widgets.dart';
import 'package:nhentai/nhentai.dart' as nh;
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';

class BookCoverWidget extends StatefulWidget {
  final nh.Book _book;
  final nh.API _api;

  /// if this is the last book on the page, and it can stretch
  /// the full width of the page, then we can apply special
  /// styling
  final bool _lastBookFullWidth;
  final Future<void> Function()? _reloadData;
  final UserPreferencesModel _userPreferences;

  const BookCoverWidget({
    super.key,
    required nh.Book book,
    required nh.API api,
    required UserPreferencesModel userPreferences,
    bool lastBookFullWidth = false,
    Future<void> Function()? reloadData,
  })  : _book = book,
        _api = api,
        _userPreferences = userPreferences,
        _lastBookFullWidth = lastBookFullWidth,
        _reloadData = reloadData;

  @override
  State<BookCoverWidget> createState() => _BookCoverWidgetState();
}

class _BookCoverWidgetState extends State<BookCoverWidget> {
  final pageIndexNotifier = ValueNotifier(0);

  Future<void> openDoujin(BuildContext context) async {
    await Navigator.pushNamed(context, "/read", arguments: {"bookId": widget._book.id, "api": widget._api});
    if (!widget._userPreferences.slowInternetMode) {
      if (widget._reloadData != null) await widget._reloadData!();
    }
  }

  WoltModalSheetPage bookDetailsPopup(BuildContext modalSheetContext) {
    return WoltModalSheetPage.withSingleChild(
      backgroundColor: Palette.backgroundColor,
      //   backButton: WoltModalSheetBackButton(onBackPressed: () {
      //     pageIndexNotifier.value = pageIndexNotifier.value - 1;
      //   }),
      closeButton: MaterialButton(
        onPressed: () {
          Navigator.of(modalSheetContext).pop();
          pageIndexNotifier.value = 0;
        },
        child: const Icon(Icons.close),
      ),
      child: BookInfoWidget(
        // handleDownloadBook: widget._handleDownloadBook,
        api: widget._api,
        book: widget._book,
        userPreferences: widget._userPreferences,
        // downloadingBook: widget._downloadingBook,
        totalPages: widget._book.pages.length,
        // textColor: Colors.black,
        // totalPagesDownloaded: widget._totalPagesDownloaded,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            // double expandedWidth = constraints.maxWidth;
            return MenuHolder(
              onTap: () async {
                await openDoujin(context);
              },
              menuItems: [
                FocusedMenuItem(
                  title: const Text("Open"),
                  backgroundColor: Colors.black54,
                  trailingIcon: const Icon(Icons.open_in_browser),
                  onPressed: () async {
                    await openDoujin(context);
                  },
                ),
                FocusedMenuItem(
                  title: const Text("About"),
                  backgroundColor: Colors.black54,
                  trailingIcon: const Icon(Icons.question_mark_sharp),
                  onPressed: () {
                    setState(() {
                      //   _showBookDetailsPopup = true;
                      WoltModalSheet.show<void>(
                        pageIndexNotifier: pageIndexNotifier,
                        context: context,
                        pageListBuilder: (modalSheetContext) {
                          return [
                            bookDetailsPopup(modalSheetContext),
                          ];
                        },
                        modalTypeBuilder: (context) {
                          final size = MediaQuery.of(context).size.width;
                          if (size < 768) {
                            return WoltModalType.bottomSheet;
                          } else {
                            return WoltModalType.dialog;
                          }
                        },
                        onModalDismissedWithBarrierTap: () {
                          debugPrint('Closed modal sheet with barrier tap');
                          pageIndexNotifier.value = 0;
                        },
                        maxDialogWidth: 560,
                        minDialogWidth: 400,
                        minPageHeight: 0.4,
                        maxPageHeight: 0.9,
                      );
                    });
                  },
                ),
                // FocusedMenuItem(
                //   title: const Text("Hide"),
                //   backgroundColor: Colors.black54,
                //   trailingIcon: const Icon(Icons.hide_image),
                //   onPressed: () => Navigator.pushNamed(context, "/profile"),
                // ),
                // FocusedMenuItem(
                //   title: const Text("Download"),
                //   backgroundColor: Colors.black54,
                //   trailingIcon: const Icon(Icons.download),
                //   onPressed: () => Navigator.pushNamed(context, "/settings"),
                // ),
              ],
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
                                FadeInImage(
                                  placeholder: const AssetImage('assets/images/cover_loader.jpg'), // Placeholder image
                                  image: Image.network(
                                    widget._book.thumbnail.getUrl(api: widget._api).toString(),
                                  ).image,
                                ),
                                Positioned(
                                  bottom: 0,
                                  child: Container(
                                    color: Colors.black.withOpacity(0.5),
                                    width: paddingWidth,
                                    child: Padding(
                                      padding: widget._lastBookFullWidth
                                          ? const EdgeInsets.fromLTRB(5, 5, 5, 35)
                                          : const EdgeInsets.all(5),
                                      child: Text(
                                        widget._book.title.english ?? widget._book.title.japanese ?? "No title?",
                                        softWrap: true,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: widget._lastBookFullWidth ? 20 : 14,
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
