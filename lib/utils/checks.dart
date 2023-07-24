import 'package:mime/mime.dart';

bool isImage(String path) {
  final mimeType = lookupMimeType(path);

  return mimeType?.startsWith('image/') ?? false;
}
