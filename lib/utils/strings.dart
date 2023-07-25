import 'package:intl/intl.dart';

/// Will remove special characters from a string and replace them with "_"
String makeFilenameSafe(String input) {
  return input.replaceAll(RegExp(r'[^a-zA-Z0-9\.]'), '_');
}

/// Remove \, ' and " from string
String escapeString(String input) {
  input = input.replaceAll('\\', ''); // Escape backslashes
  input = input.replaceAll("'", ""); // Escape single quotes
  input = input.replaceAll('"', ''); // Escape double quotes
  return input;
}

/// Converts dates to d MMMM y
String formatDateToString(DateTime dateTime) {
  final DateFormat formatter = DateFormat('d MMMM y');
  final String formattedDate = formatter.format(dateTime);
  return formattedDate;
}

String capitalizeFirstLetter(String input) {
  if (input.isEmpty) {
    return input;
  }
  return input[0].toUpperCase() + input.substring(1);
}
