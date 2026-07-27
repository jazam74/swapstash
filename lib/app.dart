import 'dart:async';

import 'package:flutter/material.dart';
import 'package:swapstash/core/navigation/app_navigator.dart';
import 'package:swapstash/core/services/language_service.dart';
import 'package:swapstash/core/services/beta_setup_service.dart';
import 'package:swapstash/core/services/notification_service.dart';
import 'package:swapstash/core/theme/app_theme.dart';
import 'package:swapstash/features/auth/auth_gate.dart';
import 'package:swapstash/features/language/language_selection_page.dart';
import 'package:swapstash/features/onboarding/onboarding_page.dart';
import 'package:swapstash/features/legal/legal_acceptance_page.dart';
import 'package:swapstash/l10n/generated/app_localizations.dart';

class SwapStashApp extends StatefulWidget {
  const SwapStashApp({super.key});

  @override
  State<SwapStashApp> createState() => _SwapStashAppState();
}

class _SwapStashAppState extends State<SwapStashApp>
    with WidgetsBindingObserver {
  final LanguageService _languageService = LanguageService.instance;
  final BetaSetupService _betaSetupService = BetaSetupService();

  AppLanguagePreference _languagePreference = AppLanguagePreference.system;
  Locale _locale = const Locale('en');
  bool _isLoadingLanguage = true;
  bool _languageSetupCompleted = false;
  bool _isLoadingBetaSetup = true;
  bool _onboardingCompleted = false;
  bool _legalDocumentsAccepted = false;

  List<Locale> get _deviceLocales {
    return WidgetsBinding.instance.platformDispatcher.locales;
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);
    _languageService.preferenceNotifier.addListener(
      _handleLanguagePreferenceChanged,
    );

    _loadLanguageSettings();
    _loadBetaSetupSettings();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      NotificationService.instance.onAppReady();
    });
  }

  @override
  void dispose() {
    _languageService.preferenceNotifier.removeListener(
      _handleLanguagePreferenceChanged,
    );
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _loadLanguageSettings() async {
    final settings = await _languageService.loadSettings();
    final resolvedLocale = _languageService.resolveLocale(
      preference: settings.preference,
      deviceLocales: _deviceLocales,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _languagePreference = settings.preference;
      _locale = resolvedLocale;
      _languageSetupCompleted = settings.setupCompleted;
      _isLoadingLanguage = false;
    });

    unawaited(
      NotificationService.instance.updateLanguageCode(
        resolvedLocale.languageCode,
      ),
    );
  }

  Future<void> _loadBetaSetupSettings() async {
    final settings = await _betaSetupService.loadSettings();

    if (!mounted) {
      return;
    }

    setState(() {
      _onboardingCompleted = settings.onboardingCompleted;
      _legalDocumentsAccepted = settings.legalDocumentsAccepted;
      _isLoadingBetaSetup = false;
    });
  }

  Future<void> _completeOnboarding() async {
    await _betaSetupService.completeOnboarding();

    if (!mounted) {
      return;
    }

    setState(() {
      _onboardingCompleted = true;
    });
  }

  Future<void> _acceptLegalDocuments() async {
    await _betaSetupService.acceptCurrentLegalDocuments();

    if (!mounted) {
      return;
    }

    setState(() {
      _legalDocumentsAccepted = true;
    });
  }

  void _handleLanguagePreferenceChanged() {
    if (!mounted) {
      return;
    }

    final preference = _languageService.currentPreference;
    final resolvedLocale = _languageService.resolveLocale(
      preference: preference,
      deviceLocales: _deviceLocales,
    );

    setState(() {
      _languagePreference = preference;
      _locale = resolvedLocale;
    });

    unawaited(
      NotificationService.instance.updateLanguageCode(
        resolvedLocale.languageCode,
      ),
    );
  }

  void _previewLanguage(AppLanguagePreference preference) {
    final resolvedLocale = _languageService.resolveLocale(
      preference: preference,
      deviceLocales: _deviceLocales,
    );

    setState(() {
      _languagePreference = preference;
      _locale = resolvedLocale;
    });

    unawaited(
      NotificationService.instance.updateLanguageCode(
        resolvedLocale.languageCode,
      ),
    );
  }

  Future<void> _completeLanguageSetup(AppLanguagePreference preference) async {
    await _languageService.updatePreference(preference, setupCompleted: true);

    if (!mounted) {
      return;
    }

    setState(() {
      _languageSetupCompleted = true;
    });
  }

  @override
  void didChangeLocales(List<Locale>? locales) {
    super.didChangeLocales(locales);

    if (_isLoadingLanguage ||
        _languagePreference != AppLanguagePreference.system) {
      return;
    }

    final resolvedLocale = _languageService.resolveLocale(
      preference: AppLanguagePreference.system,
      deviceLocales: locales ?? _deviceLocales,
    );

    if (resolvedLocale == _locale) {
      return;
    }

    setState(() {
      _locale = resolvedLocale;
    });

    unawaited(
      NotificationService.instance.updateLanguageCode(
        resolvedLocale.languageCode,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: appNavigatorKey,
      onGenerateTitle: (context) {
        return AppLocalizations.of(context)?.appName ?? 'SwapStash';
      },
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      locale: _locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      localeListResolutionCallback: (deviceLocales, supportedLocales) {
        return _languageService.resolveLocale(
          preference: AppLanguagePreference.system,
          deviceLocales: deviceLocales ?? const <Locale>[],
        );
      },
      home: _isLoadingLanguage || _isLoadingBetaSetup
          ? const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            )
          : !_languageSetupCompleted
          ? LanguageSelectionPage(
              selectedPreference: _languagePreference,
              onPreferenceChanged: _previewLanguage,
              onContinue: _completeLanguageSetup,
            )
          : !_onboardingCompleted
          ? OnboardingPage(
              onComplete: _completeOnboarding,
            )
          : !_legalDocumentsAccepted
          ? LegalAcceptancePage(
              onAccepted: _acceptLegalDocuments,
            )
          : const AuthGate(),
    );
  }
}
