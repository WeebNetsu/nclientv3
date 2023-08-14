import 'package:flutter/material.dart';
import 'package:nclientv3/models/models.dart';
import 'package:nclientv3/widgets/widgets.dart';
import 'package:nhentai/nhentai.dart' as nh;

class WhiteAndBlacklistsWidget extends StatefulWidget {
  final UserPreferencesModel _userPreferences;
  final Future<void> Function()? _reloadData;

  const WhiteAndBlacklistsWidget({
    super.key,
    required UserPreferencesModel userPreferences,
    Future<void> Function()? reloadData,
  })  : _userPreferences = userPreferences,
        _reloadData = reloadData;

  @override
  State<WhiteAndBlacklistsWidget> createState() => _WhiteAndBlacklistsWidget();
}

class _WhiteAndBlacklistsWidget extends State<WhiteAndBlacklistsWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Blacklists
        const Text(
          "Blacklists",
          style: TextStyle(fontSize: 20),
        ),
        Text(
          "Tags added here will not be seen in your search results or home page. "
          "Double tap to remove, hold to move to whitelist.",
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
            children: widget._userPreferences.blacklistedTags
                .map(
                  (e) => TagButtonWidget(
                    tag: nh.Tag.named(type: nh.TagType.tag, name: e),
                    userPreferences: widget._userPreferences,
                    reloadData: widget._reloadData,
                  ),
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
            children: widget._userPreferences.blacklistedArtists
                .map(
                  (e) => TagButtonWidget(
                    tag: nh.Tag.named(type: nh.TagType.artist, name: e),
                    userPreferences: widget._userPreferences,
                    reloadData: widget._reloadData,
                  ),
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
            children: widget._userPreferences.blacklistedGroups
                .map(
                  (e) => TagButtonWidget(
                    tag: nh.Tag.named(type: nh.TagType.group, name: e),
                    userPreferences: widget._userPreferences,
                    reloadData: widget._reloadData,
                  ),
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
          "Tags added here will always be seen in your search results or home page. "
          "Double tap to remove, hold to move to blacklist.",
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
            children: widget._userPreferences.whitelistedTags
                .map(
                  (e) => TagButtonWidget(
                    tag: nh.Tag.named(type: nh.TagType.tag, name: e),
                    userPreferences: widget._userPreferences,
                    reloadData: widget._reloadData,
                  ),
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
            children: widget._userPreferences.whitelistedArtists
                .map(
                  (e) => TagButtonWidget(
                    tag: nh.Tag.named(type: nh.TagType.artist, name: e),
                    userPreferences: widget._userPreferences,
                    reloadData: widget._reloadData,
                  ),
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
            children: widget._userPreferences.whitelistedGroups
                .map(
                  (e) => TagButtonWidget(
                    tag: nh.Tag.named(type: nh.TagType.group, name: e),
                    userPreferences: widget._userPreferences,
                    reloadData: widget._reloadData,
                  ),
                )
                .toList(),
          ),
        ),
        const SizedBox(height: 10),
        Divider(color: Colors.grey[500]),
      ],
    );
  }
}
