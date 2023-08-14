import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:nclientv3/constants/constants.dart';
import 'package:nclientv3/utils/utils.dart';
import 'package:nhentai/nhentai.dart' as nh;
import 'package:share_plus/share_plus.dart';

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

  /// If the user wants to temporarily disable their white/blacklisted tags
  bool disableWhiteAndBlacklists = false;

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

  Future<void> export() async {
    Directory? appDir = await getAppDir();
    if (appDir == null) return;

    final file = File("${appDir.path}/$saveFileName");
    if (!file.existsSync()) return;

    final zipFile = File("${appDir.path}/user_data.zip");
    if (zipFile.existsSync()) zipFile.deleteSync();
    zipFiles([file], zipFile.path);

    // try {
    await Share.shareXFiles(
      [XFile(zipFile.path)],
      text: "My NClientV3 save data",
    );
    // } catch (e) {
    // todo do something?
    // }

    // if running into errors, https://github.com/miguelpruivo/flutter_file_picker/wiki/Setup#android
    // find out where the user wants to export to
    /* final String? exportPath = await FilePicker.platform.getDirectoryPath();

    // if no folder was chosen
    if (exportPath == null) return;

    File exportFile = await File(
      "$exportPath/zs_tracker_data_${DateTime.now().toString().replaceAll(' ', '_')}.sav",
    ).create(recursive: true);
    */
    // // if the file is empty, don't append , at the start of the json!
    // await exportFile.writeAsString(
    //   "Hello World",
    //   mode: FileMode.write,
    // );
  }

  Future<void> import() async {
    // All available permissions for permission handler:
    // https://github.com/Baseflow/flutter-permission-handler/blob/master/permission_handler/example/android/app/src/main/AndroidManifest.xml
    // Either the permission was already granted before or the user just granted it.
    // only manage_external_storage can be used to write to custom directory, and unless it is a core
    // functionality of my app, Play Store will reject it, which we want to avoid, so we'll save to documents folder instead
    // if (!(await Permission.storage.request().isGranted)) {
    //   return;
    // }
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result == null) return;

    if (result.files.length != 1) {
      //   displayError("Invalid amount of files chosen");
      return;
    }

    PlatformFile file = result.files[0];

    if (file.path == null) return;

    Directory? appDir = await getAppDir();
    if (appDir == null) return;

    final existingFile = File("${appDir.path}/$saveFileName");
    if (existingFile.existsSync()) existingFile.delete();

    unzipFile(file.path!, existingFile.parent.path);
  }

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
        "disableWhiteAndBlacklists": disableWhiteAndBlacklists
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

    if (userDataJson['disableWhiteAndBlacklists'] != null) {
      disableWhiteAndBlacklists = userDataJson['disableWhiteAndBlacklists'] == true ? true : false;
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
