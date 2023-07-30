import 'package:flutter/material.dart';
import 'package:nclientv3/models/models.dart';
import 'package:nclientv3/widgets/widgets.dart';

class SettingsNetworkView extends StatefulWidget {
  const SettingsNetworkView({super.key});

  // this is so we can easily call the route
  // to this component from other files
  static route() => MaterialPageRoute(
        builder: (context) => const SettingsNetworkView(),
      );

  @override
  State<SettingsNetworkView> createState() => _SettingsNetworkViewState();
}

class _SettingsNetworkViewState extends State<SettingsNetworkView> {
  final _userPreferences = UserPreferencesModel();

  bool _loading = true;

  @override
  void initState() {
    super.initState();

    _userPreferences.loadDataFromFile().then(
          (value) => {
            setState(() {
              _loading = false;
            })
          },
        );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              const PageTitleDisplay(title: "Network"),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Slow Internet Mode"),
                  Checkbox(
                    value: _userPreferences.slowInternetMode,
                    onChanged: (bool? value) async {
                      if (value != null) _userPreferences.slowInternetMode = value;
                      await _userPreferences.saveToFileData();
                      await _userPreferences.loadDataFromFile();
                      //   to update widgets
                      setState(() {});
                    },
                  )
                ],
              ),
              Text(
                "This will make the app reload data less often, but you "
                "might need to manually reload it.",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[300],
                ),
              ),
              const SizedBox(height: 10),
              Divider(color: Colors.grey[500]),
            ],
          ),
        ),
      ),
    );
  }
}
