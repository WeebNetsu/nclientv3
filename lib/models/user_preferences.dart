import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:nclientv3/constants/constants.dart';
import 'package:nclientv3/utils/utils.dart';
import 'package:nhentai/nhentai.dart' as nh;

class UserPreferencesModel {
  static const saveFileName = "user_preferences.json";

  /// User agent provided by the webview
  // bool hideNsfw = false;
  nh.SearchSort sort = nh.SearchSort.popularWeek;

  /// The doujin language of choice for the user
  String language = NHentaiConstants.languages.first;

  /// If the user has slow internet, they can enable this
  /// which will implement manual page reloads and some
  /// other features to improve app performance
  bool slowInternetMode = false;

  /// These are the tags the user does not want to see.
  List<String> blacklistedTags = [];
  List<String> blacklistedArtists = [];
  List<String> blacklistedGroups = [];
  List<String> blacklistedCharacters = [];

  /// These are the tags the user always wants to see.
  List<String> whitelistedTags = [];
  List<String> whitelistedArtists = [];
  List<String> whitelistedGroups = [];
  List<String> whitelistedCharacters = [];

  /// These are the books the user has hidden
//   List<String> blacklistedBooks = [];

  Future<bool> saveToFileData() async {
    Directory? appDir = await getAppDir();

    if (appDir == null) return false;

    try {
      final encodedData = jsonEncode({
        "sort": sort.toString(),
        "language": language,
        "slowInternetMode": slowInternetMode,
        "blacklistedTags": blacklistedTags,
        "blacklistedArtists": blacklistedArtists,
        "blacklistedGroups": blacklistedGroups,
        "blacklistedCharacters": blacklistedCharacters,
        "whitelistedTags": whitelistedTags,
        "whitelistedArtists": whitelistedArtists,
        "whitelistedGroups": whitelistedGroups,
        "whitelistedCharacters": whitelistedCharacters,
        // "blacklistedBooks": blacklistedBooks,
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

    if (userDataJson['language'] != null) {
      language = userDataJson['language'].toString();
    }

    if (userDataJson['slowInternetMode'] != null) {
      slowInternetMode = userDataJson['slowInternetMode'] == true ? true : false;
    }

    if (userDataJson['blacklistedTags'] != null) {
      blacklistedTags = List<String>.from(userDataJson['blacklistedTags']);
    }

    if (userDataJson['blacklistedArtists'] != null) {
      blacklistedArtists = List<String>.from(userDataJson['blacklistedArtists']);
    }

    if (userDataJson['blacklistedGroups'] != null) {
      blacklistedGroups = List<String>.from(userDataJson['blacklistedGroups']);
    }

    if (userDataJson['blacklistedCharacters'] != null) {
      blacklistedCharacters = List<String>.from(userDataJson['blacklistedCharacters']);
    }

    if (userDataJson['whitelistedTags'] != null) {
      whitelistedTags = List<String>.from(userDataJson['whitelistedTags']);
    }

    if (userDataJson['whitelistedArtists'] != null) {
      whitelistedArtists = List<String>.from(userDataJson['whitelistedArtists']);
    }

    if (userDataJson['whitelistedGroups'] != null) {
      whitelistedGroups = List<String>.from(userDataJson['whitelistedGroups']);
    }

    if (userDataJson['whitelistedCharacters'] != null) {
      whitelistedCharacters = List<String>.from(userDataJson['whitelistedCharacters']);
    }

    // if (userDataJson['blacklistedBooks'] != null) {
    //   blacklistedBooks = List<String>.from(userDataJson['blacklistedBooks']);
    // }

    // not decoding it will leave quotes in the string
    // final bool? hideNsfwData = userDataJson['hideNsfw'];
    // hideNsfw = hideNsfwData == true ? true : false;

    return true;
  }
}
