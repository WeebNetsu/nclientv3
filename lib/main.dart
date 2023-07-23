import 'package:flutter/material.dart';
import 'package:nclientv3/routes.dart';
import 'package:nclientv3/theme/theme.dart';

void main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NClientV3',
      theme: AppTheme.theme,
      routes: routes,
    );
  }
}
