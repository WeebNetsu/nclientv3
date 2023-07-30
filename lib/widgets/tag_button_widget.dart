import 'package:flutter/material.dart';
import 'package:nclientv3/models/models.dart';
import 'package:nhentai/nhentai.dart' as nh;

class TagButtonWidget extends StatefulWidget {
  final nh.API? _api;
  final nh.Tag _tag;
  final UserPreferencesModel _userPreferences;

  const TagButtonWidget({
    super.key,
    nh.API? api,
    required nh.Tag tag,
    required UserPreferencesModel userPreferences,
  })  : _api = api,
        _tag = tag,
        _userPreferences = userPreferences;

  @override
  State<TagButtonWidget> createState() => _TagButtonWidget();
}

class _TagButtonWidget extends State<TagButtonWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  /// This will blacklist a tag, if the tag is already blacklisted, it will remove it from the list
  Future<void> whiteOrBlacklistTag(String tagName, {bool artist = false, bool tag = false, bool group = false}) async {
    // only one is allowed to be changed at a time, this is for safety
    if (artist && tag || artist && group || group && tag) {
      throw Exception("Only one of artist, tag, or group can be changed at a time");
    }

    // at least 1 tag is required
    if (!artist && !tag && !group) {
      throw Exception("At least 1 tag is required");
    }

    if (artist) {
      final blacklistIndex = widget._userPreferences.blacklistedArtists.indexOf(tagName);
      final whitelistIndex = widget._userPreferences.whitelistedArtists.indexOf(tagName);

      if (blacklistIndex > -1) {
        // remove from blacklist if it is there
        widget._userPreferences.blacklistedArtists.removeAt(blacklistIndex);
      } else if (whitelistIndex > -1) {
        // remove from whitelist if it is there and add it to the blacklist
        widget._userPreferences.whitelistedArtists.removeAt(whitelistIndex);
        widget._userPreferences.blacklistedArtists.add(tagName);
      } else {
        // add it to the whitelist
        widget._userPreferences.whitelistedArtists.add(tagName);
      }
    } else if (tag) {
      final blacklistIndex = widget._userPreferences.blacklistedTags.indexOf(tagName);
      final whitelistIndex = widget._userPreferences.whitelistedTags.indexOf(tagName);

      if (blacklistIndex > -1) {
        // remove from blacklist if it is there
        widget._userPreferences.blacklistedTags.removeAt(blacklistIndex);
      } else if (whitelistIndex > -1) {
        // remove from whitelist if it is there and add it to the blacklist
        widget._userPreferences.whitelistedTags.removeAt(whitelistIndex);
        widget._userPreferences.blacklistedTags.add(tagName);
      } else {
        // add it to the whitelist
        widget._userPreferences.whitelistedTags.add(tagName);
      }
    } else if (group) {
      final blacklistIndex = widget._userPreferences.blacklistedGroups.indexOf(tagName);
      final whitelistIndex = widget._userPreferences.whitelistedGroups.indexOf(tagName);

      if (blacklistIndex > -1) {
        // remove from blacklist if it is there
        widget._userPreferences.blacklistedGroups.removeAt(blacklistIndex);
      } else if (whitelistIndex > -1) {
        // remove from whitelist if it is there and add it to the blacklist
        widget._userPreferences.whitelistedGroups.removeAt(whitelistIndex);
        widget._userPreferences.blacklistedGroups.add(tagName);
      } else {
        // add it to the whitelist
        widget._userPreferences.whitelistedGroups.add(tagName);
      }
    }

    await widget._userPreferences.saveToFileData();
    await widget._userPreferences.loadDataFromFile();
  }

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onLongPress: () async {
        await whiteOrBlacklistTag(
          widget._tag.name,
          artist: widget._tag.type == nh.TagType.artist,
          tag: widget._tag.type == nh.TagType.tag,
          group: widget._tag.type == nh.TagType.group,
        );
      },
      onPressed: () async {
        await Navigator.pushNamed(context, "/search", arguments: {
          "tag": widget._tag,
          "api": widget._api,
        });
      },
      style: ButtonStyle(
        foregroundColor: MaterialStateProperty.resolveWith<Color>(
          (Set<MaterialState> states) {
            if (states.contains(MaterialState.disabled)) {
              return Colors.grey; // Set the disabled text color
            }

            final pref = widget._userPreferences;

            if (pref.blacklistedTags.contains(widget._tag.name) ||
                pref.blacklistedArtists.contains(widget._tag.name) ||
                pref.blacklistedGroups.contains(widget._tag.name)) {
              return Colors.red;
            }

            if (pref.whitelistedTags.contains(widget._tag.name) ||
                pref.whitelistedArtists.contains(widget._tag.name) ||
                pref.whitelistedGroups.contains(widget._tag.name)) {
              return Colors.green;
            }

            return Colors.blue; // Use the default text color
          },
        ),
      ),
      child: Text(widget._tag.name),
    );
  }
}
