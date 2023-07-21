import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:nclientv3/utils/utils.dart';
import 'package:nhentai/nhentai.dart' as nh;

class UserPreferencesModel {
  static const saveFileName = "user_preferences.json";

  /// User agent provided by the webview
  nh.SearchSort? sort;

  Future<bool> saveToFileData() async {
    Directory? appDir = await getAppDir();

    if (appDir == null) return false;

    try {
      final encodedData = jsonEncode({
        "sort": sort.toString(),
      });

      final newFile = await File("${appDir.path}/$saveFileName").create();

      await newFile.writeAsString(
        encodedData,
        mode: FileMode.write,
      );

      return true;
    } catch (err) {
      debugPrint(err.toString());
    }

    return false;
  }

  /// Load cookie data. If `filePath` is provided, read sleep data from the provided path file,
  ///
  /// else read the data from our cookies.json in our app directory
  Future<bool> loadDataFromFile() async {
    final Directory? appDir = await getAppDir();

    if (appDir == null) return false;

    final File saveFile = File("${appDir.path}/$saveFileName");

    if (!saveFile.existsSync()) return false;

    final saveData = await saveFile.readAsString();
    final userDataJson = jsonDecode(saveData);

    // not decoding it will leave quotes in the string
    final String sortData = jsonDecode(userDataJson['sort'].toString());

    if (sortData == nh.SearchSort.recent.toString()) {
      sort = nh.SearchSort.recent;
    } else if (sortData == nh.SearchSort.popular.toString()) {
      sort = nh.SearchSort.popular;
    } else if (sortData == nh.SearchSort.popularToday.toString()) {
      sort = nh.SearchSort.popularToday;
    } else if (sortData == nh.SearchSort.popularMonth.toString()) {
      sort = nh.SearchSort.popularMonth;
    } else {
      sort = nh.SearchSort.popularWeek;
    }

    return true;
  }
}
