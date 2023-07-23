import 'package:flutter/material.dart';
import 'package:nclientv3/utils/utils.dart';
import 'package:nclientv3/widgets/widgets.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  // this is so we can easily call the route
  // to this component from other files
  static route() => MaterialPageRoute(
        builder: (context) => const SettingsView(),
      );

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
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
            const PageTitleDisplay(title: "Settings"),
            ArrowRowButton(
              text: "Storage",
              onPressed: () => Navigator.pushNamed(context, "/settings/storage"),
            ),
            ArrowRowButton(
              text: "Donate",
              onPressed: () => Navigator.pushNamed(context, "/settings/donate"),
            ),
            const Divider(color: Colors.grey),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () async {
                await openUrl('https://github.com/WeebNetsu');
              },
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Developed by '),
                  Text(
                    'WeebNetsu',
                    style: TextStyle(decoration: TextDecoration.underline),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
