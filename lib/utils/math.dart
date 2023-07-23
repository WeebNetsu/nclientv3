/// Returns the size of bytes in KB, MB or GB
String formatByteSize(int bytes) {
  const int KB = 1024;
  const int MB = KB * 1024;
  const int GB = MB * 1024;

  if (bytes >= GB) {
    double size = bytes / GB;
    return '${size.toStringAsFixed(2)} GB';
  } else if (bytes >= MB) {
    double size = bytes / MB;
    return '${size.toStringAsFixed(2)} MB';
  } else {
    double size = bytes / KB;
    return '${size.toStringAsFixed(2)} KB';
  }
}
