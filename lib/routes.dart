import 'package:flutter/material.dart';
import 'package:nclientv3/views/views.dart';

Map<String, Widget Function(BuildContext)> routes = {
  "/": (context) => const BrowseView(),
  '/downloads': (context) => const DownloadsView(),
  "/not-a-robot": (context) => const NotARobotView(),
  "/read": (context) => const ReadBookView(),
  "/search": (context) => const SearchView(),
  '/settings': (context) => const SettingsView(),
  '/settings/donate': (context) => const SettingsDonateView(),
  '/settings/storage': (context) => const SettingsStorageView(),
};
