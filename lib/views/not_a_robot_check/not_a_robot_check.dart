import 'package:flutter/material.dart';
import 'package:nclientv3/constants/constants.dart';
import 'package:nclientv3/utils/utils.dart';
import 'package:webview_cookie_manager/webview_cookie_manager.dart';
import 'package:webview_flutter/webview_flutter.dart';

class NotARobotView extends StatefulWidget {
  const NotARobotView({super.key});

  // this is so we can easily call the route
  // to this component from other files
  static route() => MaterialPageRoute(
        builder: (context) => const NotARobotView(),
      );

  @override
  State<NotARobotView> createState() => _NotARobotViewState();
}

class _NotARobotViewState extends State<NotARobotView> {
  @override
  void initState() {
    super.initState();
  }

  String _extractCookieValue(String cookies, String cookieName) {
    final List<String> cookiePairs = cookies.split(';');
    for (String cookiePair in cookiePairs) {
      final List<String> pair = cookiePair.split('=');
      final String name = pair[0].trim();
      final String value = pair.length > 1 ? pair[1].trim() : '';
      if (name == cookieName) {
        return value;
      }
    }
    return '';
  }

  final controller = WebViewController()
    ..setJavaScriptMode(JavaScriptMode.unrestricted)
    ..setBackgroundColor(const Color(0x00000000))
    ..setNavigationDelegate(
      NavigationDelegate(
        // onProgress: (int progress) {
        // Update loading bar.
        // },
        // onPageStarted: (String url) {},
        onUrlChange: (change) async {
          if (change.url == NHentaiConstants.url) {
            final realCookieManager = WebviewCookieManager();
            final gotCookies = await realCookieManager.getCookies(NHentaiConstants.url);
            // debugPrint(gotCookies.toString());
            // for (var item in gotCookies) {
            //   debugPrint(item.toString());
            // }

            saveCookieData(gotCookies);
          }

          //   final WebViewCookieManager cookieManager = WebViewCookieManager();
          //   await cookieManager.platform.clearCookies();
        },
        // onPageFinished: (String url) async {},
        // onWebResourceError: (WebResourceError error) {},
        // onNavigationRequest: (NavigationRequest request) {
        //   if (request.url.startsWith('https://www.youtube.com/')) {
        //     return NavigationDecision.prevent;
        //   }
        //   return NavigationDecision.navigate;
        // },
      ),
    )
    ..loadRequest(Uri.parse(NHentaiConstants.url));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WebViewWidget(controller: controller),
    );
  }
}
