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
  final buttonsDisabled = true;
  final FocusNode _focusNode = FocusNode();
  late StreamSubscription<bool> keyboardSubscription;

  @override
  void initState() {
    super.initState();

    var keyboardVisibilityController = KeyboardVisibilityController();

    // Subscribe
    keyboardSubscription = keyboardVisibilityController.onChange.listen((bool visible) {
      print('Keyboard visibility update. Is visible: $visible');
      if (!visible) {
        // SystemChannels.textInput.invokeMethod('TextInput.hide');
        _focusNode.unfocus();
      }
    });
  }

  void setNotRobot() {
    Navigator.pushNamed(context, "/not-a-robot");
  }

  void getData() async {
    await _userData.loadDataFromFile();

    final cookies = _userData.cookies;
    final userAgent = _userData.userAgent;

    if (cookies == null || cookies.isEmpty || userAgent == null || userAgent.isEmpty) {
      return setNotRobot();
    }

    final api = nh.API(
      //   'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) FxQuantum/114.0 AppleWebKit/537.36 (KHTML, like Gecko) Chrome/118.0.0.0 Mobile Safari/537.36',
      userAgent: userAgent,
      beforeRequest: beforeRequestAddCookiesStatic(
        cookies,
      ),
    );

    try {
      /// Throws if book is not found, or parse failed, see docs.
      final nh.Book book = await api.getBook(177013);

      // Short book summary
      debugPrint(
        'Book: $book\n'
        'Artists: ${book.tags.artists.join(', ')}\n'
        'Languages: ${book.tags.languages.join(', ')}\n'
        'Cover: ${book.cover.getUrl(api: api)}\n'
        'First page: ${book.pages.first.getUrl(api: api)}\n'
        'First page thumbnail: ${book.pages.first.thumbnail.getUrl(api: api)}\n',
      );
    } on nh.ApiClientException catch (e) {
      debugPrint('originalException ${e.originalException}');
      debugPrint('message ${e.message}');
      debugPrint('reasonPhrase ${e.response?.reasonPhrase}');
      debugPrint('headers ${e.response?.headers}');
      debugPrint('statusCode ${e.response?.statusCode}');
      debugPrint('method ${e.request?.method}');
      debugPrint('headers ${e.request?.headers}');
      debugPrint('url ${e.request?.url}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //   appBar: appBar,
      // In Flutter, SingleChildScrollView is a widget that allows its child to be scrolled
      // in a single axis (either horizontally or vertically). It's often used to enable scrolling
      // for a widget that would otherwise overflow the screen.
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      MaterialButton(
                        onPressed: buttonsDisabled ? null : getData,
                        child: const Text('Get data'),
                      ),
                      MaterialButton(
                        onPressed: buttonsDisabled ? null : setNotRobot,
                        child: const Text('Fetch Tokens'),
                      ),
                    ],
                  ),
                  const Row(
                    children: [
                      BookCoverWidget(),
                      BookCoverWidget(),
                    ],
                  ),
                  const Row(
                    children: [
                      BookCoverWidget(),
                      BookCoverWidget(),
                    ],
                  ),
                  const Row(
                    children: [
                      BookCoverWidget(),
                      BookCoverWidget(),
                    ],
                  ),
                  const Row(
                    children: [
                      BookCoverWidget(),
                      BookCoverWidget(),
                    ],
                  ),
                  const Row(
                    children: [
                      BookCoverWidget(),
                      BookCoverWidget(),
                    ],
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
          BottomSearchBarWidget(focusNode: _focusNode),
        ],
      ),
    );
  }
}
