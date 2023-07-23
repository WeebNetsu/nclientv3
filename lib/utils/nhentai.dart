import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:nclientv3/utils/utils.dart';
import 'package:nhentai/nhentai.dart' as nh;
import 'package:path_provider/path_provider.dart';

Future<File?> downloadImage(
  nh.API api,
  nh.Image page,
  String bookName, {
  int retries = 0,
  int maxRetries = 5,
}) async {
  final directory = await getTemporaryDirectory();
  final dirName = '${directory.path}/${makeFilenameSafe(bookName)}';
  final fileName = '$dirName/${makeFilenameSafe(page.filename)}';
  final file = File(fileName);

  if (file.existsSync()) return file;

  final url = page.getUrl(api: api).toString();

  final response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    final bytes = response.bodyBytes;
    final newFile = File(fileName);
    //   create file and folders if it does not exist
    file.createSync(recursive: true);
    await newFile.writeAsBytes(bytes);
    return newFile;
  }

  if (retries < maxRetries) {
    return downloadImage(
      api,
      page,
      bookName,
      retries: retries + 1,
      maxRetries: maxRetries,
    );
  }

  return null;
}

/// Download book from nhentai, if return true, then it was a success
Future<bool> downloadBook(
  nh.API api,
  int bookId, {
  /// pass a function that counts the amount of pages downloaded
  void Function(int totalPageCount)? afterSinglePageDownload,
}) async {
  final book = await api.getBook(bookId);
  bool failedDownload = false;

  List<File> images = [];
  for (final page in book.pages) {
    final res = await downloadImage(api, page, book.title.toString(), maxRetries: 7);

    if (res == null) {
      failedDownload = true;
      break;
    }

    if (afterSinglePageDownload != null) {
      afterSinglePageDownload(book.pages.length);
    }

    images.add(res);
  }

  if (failedDownload) return !failedDownload;

  final directory = await getAppDir();
  //   todo display error
  if (directory == null) return false;

  final dirName = '${directory.path}/${book.id}';
  final saveDir = Directory(dirName);

  if (!saveDir.existsSync()) await saveDir.create(recursive: true);

  for (var image in images) {
    await image.copy("${saveDir.path}/${image.path.split("/").last}");
  }

  return !failedDownload;
}

/* example of how we can accomplish threaded downloads 
we need to make sure downloadImage can also handle threads for thread safety
Future<bool> downloadBook(
  nh.API api,
  int bookId, {
  void Function(int totalPageCount)? afterSinglePageDownload,
}) async {
  final book = await api.getBook(bookId);
  bool failedDownload = false;

  List<Future> downloadFutures = [];

  for (final page in book.pages) {
    Future downloadFuture = downloadImage(api, page, book.title.toString(), maxRetries: 5);
    downloadFutures.add(downloadFuture);

    if (downloadFutures.length >= 3) {
      await Future.wait(downloadFutures);

      for (var future in downloadFutures) {
        if (future != null && await future == null) {
          failedDownload = true;
          break;
        }
      }

      downloadFutures.clear();
    }
  }

  if (failedDownload) return !failedDownload;

  if (downloadFutures.isNotEmpty) {
    await Future.wait(downloadFutures);

    for (var future in downloadFutures) {
      if (future != null && await future == null) {
        failedDownload = true;
        break;
      }
    }
  }

  return !failedDownload;
}
 */