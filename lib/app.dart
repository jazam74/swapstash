import 'package:flutter/material.dart';
import 'package:swapstash/core/navigation/app_navigator.dart';
import 'package:swapstash/core/services/notification_service.dart';
import 'package:swapstash/core/theme/app_theme.dart';
import 'package:swapstash/features/auth/auth_gate.dart';
import 'package:swapstash/l10n/generated/app_localizations.dart';

class SwapStashApp extends StatefulWidget {
  const SwapStashApp({super.key});

  @override
  State<SwapStashApp> createState() => _SwapStashAppState();
}

class _SwapStashAppState extends State<SwapStashApp> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      NotificationService.instance.onAppReady();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: appNavigatorKey,
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
