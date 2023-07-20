/// Will remove special characters from a string and replace them with "_"
String makeFilenameSafe(String input) {
  return input.replaceAll(RegExp(r'[^a-zA-Z0-9\.]'), '_');
}
