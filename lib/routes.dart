import 'package:flutter/material.dart';
import 'package:nclientv3/views/browse/browse_view.dart';
import 'package:nclientv3/views/not_a_robot_check/not_a_robot_check.dart';
import 'package:nclientv3/views/read_book/read_book_view.dart';
import 'package:nclientv3/views/search/search_view.dart';

Map<String, Widget Function(BuildContext)> routes = {
  "/": (context) => const BrowseView(),
  "/not-a-robot": (context) => const NotARobotView(),
  "/read": (context) => const ReadBookView(),
  "/search": (context) => const SearchView(),
};
