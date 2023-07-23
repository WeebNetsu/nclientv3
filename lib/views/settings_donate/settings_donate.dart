import 'package:flutter/material.dart';
import 'package:nclientv3/utils/utils.dart';
import 'package:nclientv3/widgets/widgets.dart';

class SettingsDonateView extends StatefulWidget {
  const SettingsDonateView({super.key});

  // this is so we can easily call the route
  // to this component from other files
  static route() => MaterialPageRoute(
        builder: (context) => const SettingsDonateView(),
      );

  @override
  State<SettingsDonateView> createState() => _SettingsDonateViewState();
}

class _SettingsDonateViewState extends State<SettingsDonateView> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            const PageTitleDisplay(title: "Donate"),
            const Text("I am developing this app out of passion, I even made it "),
            GestureDetector(
              child: const Text(
                "Open Source",
                style: TextStyle(fontSize: 20, decoration: TextDecoration.underline),
              ),
              onTap: () async {
                await openUrl('https://github.com/WeebNetsu/nclientv3');
              },
            ),
            const SizedBox(height: 10),
            const Text(
              " But, this takes a lot of time and resources to accomplish. This is why"
              " I am asking for your support.",
            ),
            const SizedBox(height: 10),
            const Text(
              "Any donations would be greatly appreciated! And help further develop this app!",
            ),
            const SizedBox(height: 20),
            FullWidthButton(
              text: "PayPal",
              onPressed: () async {
                await openUrl('https://www.paypal.com/donate/?hosted_button_id=P9V2M4Q6WYHR8');
              },
            ),
            FullWidthButton(
              text: "LiberaPay",
              onPressed: () async {
                await openUrl('https://liberapay.com/stevesteacher/');
              },
            ),
            FullWidthButton(
              text: "Kofi",
              onPressed: () async {
                await openUrl('https://ko-fi.com/stevesteacher');
              },
            ),
            FullWidthButton(
              text: "Patreon",
              onPressed: () async {
                await openUrl('https://www.patreon.com/Stevesteacher');
              },
            ),
          ],
        ),
      ),
    );
  }
}
