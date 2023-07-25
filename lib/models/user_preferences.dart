import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:nclientv3/utils/utils.dart';
import 'package:nhentai/nhentai.dart' as nh;

/// All book languages, name and ID
///
/// Their IDs are what have been returned when asking the API
enum BookLanguage {
  all, // 0
  english, // 12227
}

/// This will give each language its unique ID
extension BookLanguageExtension on BookLanguage {
  String get name {
    switch (this) {
      case BookLanguage.english:
        return 'english';
      default:
        return 'all';
    }
  }

  int get id {
    switch (this) {
      case BookLanguage.english:
        return 12227;
      default:
        return 0;
    }
  }

  /// Get a language by its ID, if not found, it will return `BookLanguage.all`
  BookLanguage getLanguageById(int id) {
    for (final lang in BookLanguage.values) {
      if (lang.id == id) return lang;
    }

    return BookLanguage.all;
  }
}

class UserPreferencesModel {
  static const saveFileName = "user_preferences.json";

  /// User agent provided by the webview
  // bool hideNsfw = false;
  nh.SearchSort sort = nh.SearchSort.popularWeek;
  BookLanguage language = BookLanguage.all;

  Future<bool> saveToFileData() async {
    Directory? appDir = await getAppDir();

    if (appDir == null) return false;

    try {
      final encodedData = jsonEncode({
        "sort": sort.toString(),
        "language": language.id,
        // "hideNsfw": hideNsfw,
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

  /// Load data from file, if failed, it will return false
  Future<bool> loadDataFromFile() async {
    final Directory? appDir = await getAppDir();

    if (appDir == null) return false;

    final File saveFile = File("${appDir.path}/$saveFileName");

    if (!saveFile.existsSync()) {
      sort = nh.SearchSort.popularWeek;
      await saveToFileData();
      return true;
    }

    final saveData = await saveFile.readAsString();
    final userDataJson = jsonDecode(saveData);

    // not decoding it will leave quotes in the string
    final String sortData = userDataJson['sort'].toString();

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

    final int? languageData = userDataJson['language'];

    for (final lang in BookLanguage.values) {
      if (lang.id == languageData) {
        language = lang;
        break;
      }
    }

    // not decoding it will leave quotes in the string
    // final bool? hideNsfwData = userDataJson['hideNsfw'];
    // hideNsfw = hideNsfwData == true ? true : false;

    return true;
  }
}
