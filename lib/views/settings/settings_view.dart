import 'package:flutter/material.dart';
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
            const SizedBox(height: 50),
            Row(children: [
              IconButton(onPressed: () {}, icon: const Icon(Icons.arrow_back)),
              const Expanded(
                child: Align(
                  alignment: Alignment(-0.1, 0),
                  child: Text(
                    "Settings",
                    style: TextStyle(fontSize: 30),
                  ),
                ),
              ),
            ]),
            const SizedBox(height: 20),
            ArrowRowButton(
              text: "Storage",
              onPressed: () {},
            ),
            ArrowRowButton(
              text: "Ads",
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}
