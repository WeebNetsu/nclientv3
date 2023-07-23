import 'dart:convert';
import 'dart:io';

import 'package:nclientv3/utils/utils.dart';

class SavedBookModel {
  static const saveFileName = ".book";

  /// User agent provided by the webview
  String? title;
  File? coverImage;
  final int id;

  SavedBookModel(this.id);

  Future<bool> saveBookData() async {
    Directory? appDir = await getAppDir();

    if (appDir == null) return false;

    if (title == null) return false;

    final saveDir = Directory('${appDir.path}/$id');

    if (!saveDir.existsSync()) await saveDir.create(recursive: true);

    final encodedData = jsonEncode({
      "title": escapeString(title!),
    });

    final newFile = await File("${saveDir.path}/$saveFileName").create();

    await newFile.writeAsString(
      encodedData,
      mode: FileMode.write,
    );

    return true;
  }

  /// Load data from file, if failed, it will return false
  Future<bool> loadBookData() async {
    final Directory? appDir = await getAppDir();

    if (appDir == null) return false;

    final Directory saveFileDir = Directory("${appDir.path}/$id");
    final File saveFile = File("${saveFileDir.path}/$saveFileName");

    coverImage = File("${saveFileDir.path}/1.jpg");

    if (!saveFile.existsSync()) return true;

    final saveData = await saveFile.readAsString();
    final userDataJson = jsonDecode(saveData);

    // not decoding it will leave quotes in the string
    final String bookTitle = userDataJson['title'].toString();

    title = bookTitle;

    return true;
  }

  /// Permanently delete a book from storage
  Future<void> deleteBook({void Function()? afterDelete}) async {
    final Directory? appDir = await getAppDir();

    if (appDir == null) return;

    final Directory saveFileDir = Directory("${appDir.path}/$id");

    if (!saveFileDir.existsSync()) return;

    await saveFileDir.delete(recursive: true);

    if (afterDelete != null) afterDelete();
  }
}
