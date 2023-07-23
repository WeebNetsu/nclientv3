import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

/// Get the directory that your app has access to as file storage
Future<Directory?> getAppDir() async {
  var dirs = await getExternalStorageDirectories();
  if (dirs == null || dirs.isEmpty) return null;

  return dirs[0];
}

/// Get the size of your cache directory (may not be 100% same as in app info page)
Future<int> getCacheSize() async {
  Directory tempDir = await getTemporaryDirectory();
  int tempDirSize = getDirectorySize(tempDir);
  return tempDirSize;
}

/// Get the size of a directory
int getDirectorySize(FileSystemEntity file) {
  if (file is File) {
    return file.lengthSync();
  } else if (file is Directory) {
    int sum = 0;
    List<FileSystemEntity> children = file.listSync();
    for (FileSystemEntity child in children) {
      sum += getDirectorySize(child);
    }
    return sum;
  }
  return 0;
}

Future<void> openUrl(String url) async {
  final uri = Uri.parse(url);
  if (await canLaunchUrl(uri)) await launchUrl(uri);
}
