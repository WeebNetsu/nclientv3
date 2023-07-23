import 'package:flutter/material.dart';
import 'package:nclientv3/models/models.dart';
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
  final _userPreferences = UserPreferencesModel();
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _userPreferences.loadDataFromFile().then((value) => {
          setState(() {
            _loading = false;
          })
        });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            const PageTitleDisplay(title: "Settings"),
            /*  GestureDetector(
              onTap: () {
                setState(() {
                  _userPreferences.hideNsfw = !_userPreferences.hideNsfw;
                  _userPreferences.saveToFileData();
                });
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Hide NSFW Content"),
                      Text(
                        "This will hide NSFW doujins on the browse page",
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[400],
                        ),
                      ),
                    ],
                  ),
                  Checkbox(
                    value: _userPreferences.hideNsfw,
                    onChanged: (value) {},
                  ),
                ],
              ),
            ), */
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
