import 'package:flutter/material.dart';
import 'package:write_lao/config/routes.dart';
import 'package:write_lao/config/theme.dart';
import 'package:write_lao/l10n/app_localizations.dart';

class WriteLaoApp extends StatelessWidget {
  const WriteLaoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Write Lao',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: router,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
    );
  }
}
