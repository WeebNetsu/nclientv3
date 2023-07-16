import 'package:fk_user_agent/fk_user_agent.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nclientv3/models/cook.dart';
import 'package:nclientv3/utils/utils.dart';
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
  String _platformVersion = 'Unknown';

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      await FkUserAgent.init();
      initPlatformState();
    });
  }

  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      platformVersion = FkUserAgent.userAgent!;
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

    // for (var c in t) {
    //   debugPrint(c.value);
    // }

// Dalvik/2.1.0 (Linux; U; Android 13; sdk_gphone_x86_64 Build/TE1A.220922.025)
    debugPrint('xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx');
    debugPrint(cooks.toString());
    debugPrint(_platformVersion);

    final api = nh.API(
      //   userAgent:
      //   'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) FxQuantum/114.0 AppleWebKit/537.36 (KHTML, like Gecko) Chrome/118.0.0.0 Mobile Safari/537.36',
      userAgent:
          "Mozilla/5.0 (Linux; Android 13; sdk_gphone_x86_64 Build/TE1A.220922.025; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/103.0.5060.71 Mobile Safari/537.36",
      // Add before request handler
      //   beforeRequest: beforeRequestAddCookiesStatic(
      //     t.map((e) => Cookie(e.name, e.value)).toList(),
      //   ),
      beforeRequest: beforeRequestAddCookiesStatic(
        cooks,
      ),
      //   beforeRequest: beforeRequestAddCookiesStatic(
      //     [
      //       Cookie('csrftoken', '9pL4YhMh30nXpIFKPQwGfcgwe1QsNQ3G1tIRn2CxfUGJhhzq677nImcgaPST8d5b'),
      //       Cookie('cf_clearance', '_83URPfYpPYFOgc9WPuPQlvUAZ01CVZsOs4LKK0WHiA-1689488049-0-160'),
      //     ],
      //   ),
    );

    try {
      /// Throws if book is not found, or parse failed, see docs.
      final nh.Book book = await api.getBook(177013);

      // Short book summary
      debugPrint('Book: $book\n'
          // 'Artists: ${book.tags.artists.join(', ')}\n'
          // 'Languages: ${book.tags.languages.join(', ')}\n'
          // 'Cover: ${book.cover.getUrl(api: api)}\n'
          // 'First page: ${book.pages.first.getUrl(api: api)}\n'
          // 'First page thumbnail: ${book.pages.first.thumbnail.getUrl(api: api)}\n',
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
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                MaterialButton(
                  onPressed: getData,
                  child: const Text('Get data'),
                ),
                MaterialButton(
                  onPressed: setNotRobot,
                  child: const Text('Fetch Tokens'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
