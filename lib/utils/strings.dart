import 'package:intl/intl.dart';

/// Will remove special characters from a string and replace them with "_"
String makeFilenameSafe(String input) {
  return input.replaceAll(RegExp(r'[^a-zA-Z0-9\.]'), '_');
}

/// Converts dates to d MMMM y
String formatDateToString(DateTime dateTime) {
  final DateFormat formatter = DateFormat('d MMMM y');
  final String formattedDate = formatter.format(dateTime);
  return formattedDate;
}
