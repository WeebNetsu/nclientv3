import 'package:flutter/material.dart';
import 'package:nclientv3/constants/constants.dart';
import 'package:nclientv3/models/models.dart';
import 'package:nclientv3/utils/utils.dart';
import 'package:nclientv3/views/settings_filters/widgets/white_and_blacklists_widget.dart';
import 'package:nclientv3/widgets/widgets.dart';

class SettingsFiltersView extends StatefulWidget {
  const SettingsFiltersView({super.key});

  // this is so we can easily call the route
  // to this component from other files
  static route() => MaterialPageRoute(
        builder: (context) => const SettingsFiltersView(),
      );

  @override
  State<SettingsFiltersView> createState() => _SettingsFiltersViewState();
}

class _SettingsFiltersViewState extends State<SettingsFiltersView> {
  final _userPreferences = UserPreferencesModel();

  bool _loading = true;

  Future<void> reloadData() async {
    setState(() {});
  }

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
              const PageTitleDisplay(title: "Filters"),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Language"),
                  DropdownButton<String>(
                    value: _userPreferences.language,
                    onChanged: (String? newValue) {
                      setState(() {
                        if (newValue != null) {
                          _userPreferences.language = newValue;
                          _userPreferences.saveToFileData();
                        }
                      });
                    },
                    items: NHentaiConstants.languages.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(capitalizeFirstLetter(value == "*" ? "All" : value)),
                      );
                    }).toList(),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Disable Tag Filters"),
                  Checkbox(
                    value: _userPreferences.disableWhiteAndBlacklists,
                    onChanged: (bool? value) async {
                      if (value != null) _userPreferences.disableWhiteAndBlacklists = value;
                      await _userPreferences.saveToFileData();
                      await _userPreferences.loadDataFromFile();
                      //   to update widgets
                      setState(() {});
                    },
                  )
                ],
              ),
              const SizedBox(height: 10),
              Divider(color: Colors.grey[500]),
              if (!_userPreferences.disableWhiteAndBlacklists)
                WhiteAndBlacklistsWidget(
                  userPreferences: _userPreferences,
                  reloadData: reloadData,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
