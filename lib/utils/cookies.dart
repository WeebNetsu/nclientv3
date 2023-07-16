import 'dart:convert';
import 'dart:io';

import 'package:nclientv3/models/models.dart';

import 'app.dart';

Future<bool> saveCookieData(List<Cookie> cookies) async {
  Directory? appDir = await getAppDir();

  if (appDir == null) return false;

  try {
    final newFile = await File("${appDir.path}/cookies.json").create();

    // if overwriting
    String store = "";
    for (var cookie in cookies) {
      final data = {"name": cookie.name, "value": cookie.value};

      store += "${jsonEncode(data)},";
    }

    // remove last character from string, aka ","
    if (store.isNotEmpty) {
      store = store.substring(0, store.length - 1);
    }

    // if the file is empty, don't append , at the start of the json!
    await newFile.writeAsString(
      store,
      mode: FileMode.write,
    );
    return true;
  } catch (err) {
    print(err);
  }

  return false;
}

/// Load cookie data. If `filePath` is provided, read sleep data from the provided path file,
///
/// else read the data from our cookies.json in our app directory
Future<List<StoredCookieModel>?> loadCookieData({
  String? filePath,
  bool sort = true,
}) async {
  final Directory? appDir = await getAppDir();

  if (appDir == null) return null;

  final File saveFile = File(filePath ?? "${appDir.path}/cookies.json");

  if (!saveFile.existsSync()) return null;

  final saveData = await saveFile.readAsString();

  final sleepJson = jsonDecode("[$saveData]");
  final List<StoredCookieModel> cookies = [];
  for (var sleep in sleepJson) {
    cookies.add(
      StoredCookieModel.fromJSON(sleep),
    );
  }

  return cookies;
}
