import 'dart:io';

import 'package:fk_user_agent/fk_user_agent.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nclientv3/utils/utils.dart';
import 'package:nhentai/before_request_add_cookies.dart';
import 'package:nhentai/nhentai.dart';

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
  String _platformVersion = 'Unknown';

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) async {
      await FkUserAgent.init();
      initPlatformState();
    });
  }

  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      platformVersion = FkUserAgent.userAgent!;
      print(platformVersion);
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  void setNotRobot() {
    Navigator.pushNamed(context, "/not-a-robot");
  }

  void getData() async {
    final t = await loadCookieData();

    if (t == null || t.isEmpty) {
      return setNotRobot();
    }

    for (var c in t) {
      debugPrint(c.value);
    }

    debugPrint(_platformVersion);

    final api = API(
      userAgent: _platformVersion,
      // Add before request handler
      beforeRequest: beforeRequestAddCookiesStatic(
        t.map((e) => Cookie(e.name, e.value)).toList(),
      ),
    );

    try {
      /// Throws if book is not found, or parse failed, see docs.
      final Book book = await api.getBook(177013);

      // Short book summary
      debugPrint('Book: $book\n'
          // 'Artists: ${book.tags.artists.join(', ')}\n'
          // 'Languages: ${book.tags.languages.join(', ')}\n'
          // 'Cover: ${book.cover.getUrl(api: api)}\n'
          // 'First page: ${book.pages.first.getUrl(api: api)}\n'
          // 'First page thumbnail: ${book.pages.first.thumbnail.getUrl(api: api)}\n',
          );
    } on ApiClientException catch (e) {
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
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                MaterialButton(
                  onPressed: getData,
                  child: Text('Get data'),
                ),
                MaterialButton(
                  onPressed: setNotRobot,
                  child: Text('Fetch Tokens'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
