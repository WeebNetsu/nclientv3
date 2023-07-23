import 'package:flutter/material.dart';
import 'package:nclientv3/constants/constants.dart';

class MessagePageWidget extends StatelessWidget {
  final String _text;
  final StatusEmojis _statusEmoji;
  final bool _showDownloadsButton;

  const MessagePageWidget({
    super.key,
    String text = "An unknown error has just ocurred, sorry friend!",
    StatusEmojis statusEmoji = StatusEmojis.cry,
    bool showDownloadsButton = false,
  })  : _text = text,
        _statusEmoji = statusEmoji,
        _showDownloadsButton = showDownloadsButton;

  String getEmojiAsset() {
    switch (_statusEmoji) {
      case StatusEmojis.happy:
        return AssetConstants.happyEmojiImagePath;
      case StatusEmojis.cry:
        return AssetConstants.cryEmojiImagePath;
      case StatusEmojis.thinking:
        return AssetConstants.thinkingEmojiImagePath;
      case StatusEmojis.party:
        return AssetConstants.partyEmojiImagePath;
      case StatusEmojis.surprised:
        return AssetConstants.surprisedEmojiImagePath;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              getEmojiAsset(),
              width: 100,
            ),
            const SizedBox(height: 20),
            Text(_text),
            const Divider(),
            if (!_showDownloadsButton)
              Container()
            else
              MaterialButton(
                onPressed: () => Navigator.pushNamed(context, "/downloads"),
                child: const Text("Open Downloads"),
              ),
          ],
        ),
      ),
    );
  }
}
