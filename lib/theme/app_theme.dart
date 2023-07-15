import 'package:flutter/material.dart';
import 'package:nclientv3/theme/palette.dart';

class AppTheme {
  static ThemeData theme = ThemeData.dark().copyWith(
    scaffoldBackgroundColor: Palette.backgroundColor,
    appBarTheme: const AppBarTheme(
      backgroundColor: Palette.backgroundColor,
      elevation: 0,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Palette.blueColor,
    ),
  );
}
