import 'package:flutter/material.dart';
import 'package:write_it_lao/config/routes.dart';
import 'package:write_it_lao/config/theme.dart';

class WriteItLaoApp extends StatelessWidget {
  const WriteItLaoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Write Lao',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: router,
    );
  }
}
