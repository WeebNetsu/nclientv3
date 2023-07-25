import 'package:flutter/material.dart';
import 'package:nclientv3/utils/utils.dart';
import 'package:nclientv3/widgets/widgets.dart';

class SettingsBrowseAndSearchView extends StatefulWidget {
  const SettingsBrowseAndSearchView({super.key});

  // this is so we can easily call the route
  // to this component from other files
  static route() => MaterialPageRoute(
        builder: (context) => const SettingsBrowseAndSearchView(),
      );

  @override
  State<SettingsBrowseAndSearchView> createState() => _SettingsBrowseAndSearchViewState();
}

class _SettingsBrowseAndSearchViewState extends State<SettingsBrowseAndSearchView> {
  final List<String> _languageOptions = [
    "all",
    "english",
  ];
  String? _selectedOption;

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
            const PageTitleDisplay(title: "Browse and Search"),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Language"),
                DropdownButton<String>(
                  value: _selectedOption ?? _languageOptions.first,
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedOption = newValue ?? _languageOptions.first;
                    });
                  },
                  items: _languageOptions.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(capitalizeFirstLetter(value)),
                    );
                  }).toList(),
                ),
              ],
            ),
            Divider(color: Colors.grey[500]),
          ],
        ),
      ),
    );
  }
}
