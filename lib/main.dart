import 'package:flutter/material.dart';
import 'package:nclientv3/features/browse/view/browse_view.dart';
import 'package:nclientv3/theme/theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Twitter Clone',
      theme: AppTheme.theme,
      home: const BrowseView(),
    );
  }
}
