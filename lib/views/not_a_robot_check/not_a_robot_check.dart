import 'package:flutter/material.dart';
import 'package:nclientv3/constants/constants.dart';
import 'package:nclientv3/models/models.dart';
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
  late WebViewController controller;

  void goHome() {
    Navigator.pop(context);
  }

  @override
  void initState() {
    super.initState();

    String? userAgent;

    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..runJavaScriptReturningResult('navigator.userAgent').then((currentUserAgent) {
        userAgent = currentUserAgent.toString();
      })
      ..setNavigationDelegate(
        NavigationDelegate(
          // onProgress: (int progress) {
          // Update loading bar.
          // },
          onPageStarted: (String url) async {
            // final WebViewCookieManager cookieManager = WebViewCookieManager();
            // await cookieManager.platform.clearCookies();
            // final currentUserAgent = await WebViewController().runJavaScriptReturningResult('navigator.userAgent');
            // _newUserData.userAgent = currentUserAgent.toString();
            // debugPrint(currentUserAgent.toString());
          },
          onUrlChange: (change) async {
            if (change.url == NHentaiConstants.url) {
              final realCookieManager = WebviewCookieManager();
              final gotCookies = await realCookieManager.getCookies(NHentaiConstants.url);
              final newUserData = UserDataModel();

              newUserData.userAgent = userAgent;

              newUserData.cookies = gotCookies;
              final success = await newUserData.saveToFileData();

              debugPrint(gotCookies.toString());

              if (!success || userAgent == null || userAgent == 'null' || gotCookies.toString() == '[]') {
                // todo show error
                debugPrint("Could not save user data");
                return;
              }

              return goHome();
            }
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WebViewWidget(controller: controller),
    );
  }
}
