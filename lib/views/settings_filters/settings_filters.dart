import 'package:flutter/material.dart';
import 'package:nclientv3/constants/constants.dart';
import 'package:nclientv3/models/models.dart';
import 'package:nclientv3/utils/utils.dart';
import 'package:nclientv3/widgets/widgets.dart';
import 'package:nhentai/nhentai.dart' as nh;

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
  bool _x = false;

  Future<void> reloadData() async {
    setState(() {
      _x = true;
    });
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
              Text(
                "This will make all your search results and "
                "home page only show results in your preferred language.",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[300],
                ),
              ),
              const SizedBox(height: 10),
              Divider(color: Colors.grey[500]),

              // Blacklists
              const Text(
                "Blacklists",
                style: TextStyle(fontSize: 20),
              ),
              Text(
                "Tags added here will not be seen in your search results or home page."
                "Double tap to remove, hold to move to whitelist",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[300],
                ),
              ),

              const SizedBox(height: 10),

              // blacklisted tags
              Container(
                alignment: Alignment.topLeft,
                child: const Text("Blacklisted Tags"),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _userPreferences.blacklistedTags
                      .map(
                        (e) => TagButtonWidget(
                            tag: nh.Tag.named(type: nh.TagType.tag, name: e),
                            userPreferences: _userPreferences,
                            reloadData: reloadData),
                      )
                      .toList(),
                ),
              ),
              const SizedBox(height: 10),

              // blacklisted artists
              Container(
                alignment: Alignment.topLeft,
                child: const Text("Blacklisted Artists"),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _userPreferences.blacklistedArtists
                      .map(
                        (e) => TagButtonWidget(
                            tag: nh.Tag.named(type: nh.TagType.artist, name: e),
                            userPreferences: _userPreferences,
                            reloadData: reloadData),
                      )
                      .toList(),
                ),
              ),
              const SizedBox(height: 10),

              // blacklisted groups
              Container(
                alignment: Alignment.topLeft,
                child: const Text("Blacklisted Groups"),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _userPreferences.blacklistedGroups
                      .map(
                        (e) => TagButtonWidget(
                            tag: nh.Tag.named(type: nh.TagType.group, name: e),
                            userPreferences: _userPreferences,
                            reloadData: reloadData),
                      )
                      .toList(),
                ),
              ),
              const SizedBox(height: 10),
              Divider(color: Colors.grey[500]),

              // whitelists
              const Text(
                "Whitelists",
                style: TextStyle(fontSize: 20),
              ),
              Text(
                "Tags added here will always be seen in your search results or home page."
                "Double tap to remove, hold to move to blacklist",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[300],
                ),
              ),
              const SizedBox(height: 10),

              // whitelisted tags
              Container(
                alignment: Alignment.topLeft,
                child: const Text("Whitelisted Tags"),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _userPreferences.whitelistedTags
                      .map(
                        (e) => TagButtonWidget(
                            tag: nh.Tag.named(type: nh.TagType.tag, name: e),
                            userPreferences: _userPreferences,
                            reloadData: reloadData),
                      )
                      .toList(),
                ),
              ),
              const SizedBox(height: 10),

              // whitelisted artists
              Container(
                alignment: Alignment.topLeft,
                child: const Text("Whitelisted Artists"),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _userPreferences.whitelistedArtists
                      .map(
                        (e) => TagButtonWidget(
                            tag: nh.Tag.named(type: nh.TagType.artist, name: e),
                            userPreferences: _userPreferences,
                            reloadData: reloadData),
                      )
                      .toList(),
                ),
              ),
              const SizedBox(height: 10),

              // whitelisted groups
              Container(
                alignment: Alignment.topLeft,
                child: const Text("Whitelisted Groups"),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _userPreferences.whitelistedGroups
                      .map(
                        (e) => TagButtonWidget(
                            tag: nh.Tag.named(type: nh.TagType.group, name: e),
                            userPreferences: _userPreferences,
                            reloadData: reloadData),
                      )
                      .toList(),
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
