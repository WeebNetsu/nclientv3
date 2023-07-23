import 'dart:io';

import 'package:flutter/material.dart';
import 'package:nclientv3/utils/utils.dart';
import 'package:nclientv3/widgets/widgets.dart';
import 'package:path_provider/path_provider.dart';

class SettingsStorageView extends StatefulWidget {
  const SettingsStorageView({super.key});

  // this is so we can easily call the route
  // to this component from other files
  static route() => MaterialPageRoute(
        builder: (context) => const SettingsStorageView(),
      );

  @override
  State<SettingsStorageView> createState() => _SettingsStorageViewState();
}

class _SettingsStorageViewState extends State<SettingsStorageView> {
  bool _cacheCleared = false;

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
            const PageTitleDisplay(title: "Storage"),
            FutureBuilder<int>(
              future: getCacheSize(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const FullWidthButton(
                    text: "Clear App Cache",
                    onPressed: null,
                  ); // Show a loading indicator while fetching the cache size
                } else if (snapshot.hasError) {
                  return const FullWidthButton(
                    text: "Clear App Cache (Error)",
                    onPressed: null,
                  ); // Show an error message if an error occurs
                } else {
                  final cacheSize = snapshot.data;
                  final formattedSize = formatByteSize(cacheSize ?? 0);
                  return FullWidthButton(
                    text: "Clear App Cache (${_cacheCleared ? '0 KB' : formattedSize})",
                    onPressed: () async {
                      var appDir = (await getTemporaryDirectory()).path;
                      await Directory(appDir).delete(recursive: true);

                      setState(() {
                        _cacheCleared = true;
                      });
                    },
                  );
                }
              },
            )
          ],
        ),
      ),
    );
  }
}
