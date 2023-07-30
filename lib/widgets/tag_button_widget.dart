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
  Future<void> whiteOrBlacklistTag(String tagName) async {
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

    await widget._userPreferences.saveToFileData();
    await widget._userPreferences.loadDataFromFile();
  }

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onLongPress: () async {
        await whiteOrBlacklistTag(widget._tag.name);
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

            if (widget._userPreferences.blacklistedTags.contains(widget._tag.name)) {
              return Colors.red;
            }

            if (widget._userPreferences.whitelistedTags.contains(widget._tag.name)) {
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
