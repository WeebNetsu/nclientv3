import 'package:flutter/material.dart';
import 'package:nclientv3/views/browse/view/browse_view.dart';
import 'package:nclientv3/views/not_a_robot_check/not_a_robot_check.dart';

Map<String, Widget Function(BuildContext)> routes = {
  "/": (context) => const BrowseView(),
  "/not-a-robot": (context) => const NotARobotView(),
};
