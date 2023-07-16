import 'dart:io';

import 'package:path_provider/path_provider.dart';

Future<Directory?> getAppDir() async {
  var dirs = await getExternalStorageDirectories();
  if (dirs == null || dirs.isEmpty) return null;

  return dirs[0];
}
