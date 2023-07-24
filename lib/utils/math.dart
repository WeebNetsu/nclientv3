/// Returns the size of bytes in KB, MB or GB
String formatByteSize(int bytes) {
  const int kb = 1024;
  const int mb = kb * 1024;
  const int gb = mb * 1024;

  if (bytes >= gb) {
    double size = bytes / gb;
    return '${size.toStringAsFixed(2)} GB';
  } else if (bytes >= mb) {
    double size = bytes / mb;
    return '${size.toStringAsFixed(2)} MB';
  } else {
    double size = bytes / kb;
    return '${size.toStringAsFixed(2)} KB';
  }
}
