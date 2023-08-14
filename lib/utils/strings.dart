import 'package:intl/intl.dart';
import 'package:nclientv3/models/models.dart';
import 'package:nhentai/nhentai.dart' as nh;

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

/// Generate a tag url, `/tag/value/`
String generateTagUrl(String name) => '/tag/$name/';

String generateSearchQueryString(String originalQuery, UserPreferencesModel userPreferences, {nh.Tag? searchTag}) {
  String newQuery = originalQuery;

  if (userPreferences.language != "*") {
    final languageQuery = nh.Tag.named(
      type: nh.TagType.language,
      name: userPreferences.language,
    ).query;

    newQuery += newQuery.isEmpty ? "$languageQuery" : " $languageQuery";
  }

  if (searchTag != null) {
    newQuery += newQuery.isEmpty ? '${searchTag.query}' : ' ${searchTag.query}';
  }

  if (userPreferences.disableWhiteAndBlacklists) return newQuery;

  if (userPreferences.blacklistedTags.isNotEmpty) {
    for (final tag in userPreferences.blacklistedTags) {
      if (searchTag?.name == tag) continue;

      final query = nh.Tag.named(
        type: nh.TagType.tag,
        name: tag,
      ).query;

      newQuery += newQuery.isEmpty ? '-$query' : ' -$query';
    }
  }

  if (userPreferences.blacklistedArtists.isNotEmpty) {
    for (final tag in userPreferences.blacklistedArtists) {
      if (searchTag?.name == tag) continue;

      final query = nh.Tag.named(
        type: nh.TagType.artist,
        name: tag,
      ).query;

      newQuery += newQuery.isEmpty ? '-$query' : ' -$query';
    }
  }

  if (userPreferences.blacklistedCharacters.isNotEmpty) {
    for (final tag in userPreferences.blacklistedCharacters) {
      if (searchTag?.name == tag) continue;

      final query = nh.Tag.named(
        type: nh.TagType.character,
        name: tag,
      ).query;

      newQuery += newQuery.isEmpty ? '-$query' : ' -$query';
    }
  }

  if (userPreferences.blacklistedGroups.isNotEmpty) {
    for (final tag in userPreferences.blacklistedGroups) {
      if (searchTag?.name == tag) continue;

      final query = nh.Tag.named(
        type: nh.TagType.group,
        name: tag,
      ).query;

      newQuery += newQuery.isEmpty ? '-$query' : ' -$query';
    }
  }

  if (userPreferences.whitelistedTags.isNotEmpty) {
    for (final tag in userPreferences.whitelistedTags) {
      if (searchTag?.name == tag) continue;

      final query = nh.Tag.named(
        type: nh.TagType.tag,
        name: tag,
      ).query;

      newQuery += newQuery.isEmpty ? '$query' : ' $query';
    }
  }

  if (userPreferences.whitelistedArtists.isNotEmpty) {
    for (final tag in userPreferences.whitelistedArtists) {
      if (searchTag?.name == tag) continue;

      final query = nh.Tag.named(
        type: nh.TagType.artist,
        name: tag,
      ).query;

      newQuery += newQuery.isEmpty ? '$query' : ' $query';
    }
  }

  if (userPreferences.whitelistedCharacters.isNotEmpty) {
    for (final tag in userPreferences.whitelistedCharacters) {
      if (searchTag?.name == tag) continue;

      final query = nh.Tag.named(
        type: nh.TagType.character,
        name: tag,
      ).query;

      newQuery += newQuery.isEmpty ? '$query' : ' $query';
    }
  }

  if (userPreferences.whitelistedGroups.isNotEmpty) {
    for (final tag in userPreferences.whitelistedGroups) {
      if (searchTag?.name == tag) continue;

      final query = nh.Tag.named(
        type: nh.TagType.group,
        name: tag,
      ).query;

      newQuery += newQuery.isEmpty ? '$query' : ' $query';
    }
  }

  return newQuery;
}
