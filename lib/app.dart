import 'package:flutter/material.dart';
import 'package:swapstash/core/theme/app_theme.dart';
import 'package:swapstash/l10n/generated/app_localizations.dart';
import 'package:swapstash/features/auth/auth_gate.dart';

class SwapStashApp extends StatelessWidget {
  const SwapStashApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateTitle: (context) {
        return AppLocalizations.of(context)!.appName;
      },
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const AuthGate(),
    );
  }
}