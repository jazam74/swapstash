import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppLanguagePreference { system, sl, en, de, hr }

class LanguageSettings {
  final AppLanguagePreference preference;
  final bool setupCompleted;

  const LanguageSettings({
    required this.preference,
    required this.setupCompleted,
  });
}

class LanguageService {
  LanguageService._();

  static final LanguageService instance = LanguageService._();

  static const String _preferenceKey = 'app_language_preference';
  static const String _setupCompletedKey = 'language_setup_completed';

  static const Set<String> supportedLanguageCodes = {'sl', 'en', 'de', 'hr'};

  final ValueNotifier<AppLanguagePreference> preferenceNotifier =
      ValueNotifier<AppLanguagePreference>(AppLanguagePreference.system);

  AppLanguagePreference get currentPreference {
    return preferenceNotifier.value;
  }

  Future<LanguageSettings> loadSettings() async {
    final preferences = await SharedPreferences.getInstance();
    final storedPreference = preferences.getString(_preferenceKey);

    var preference = AppLanguagePreference.system;

    for (final candidate in AppLanguagePreference.values) {
      if (candidate.name == storedPreference) {
        preference = candidate;
        break;
      }
    }

    if (preferenceNotifier.value != preference) {
      preferenceNotifier.value = preference;
    }

    return LanguageSettings(
      preference: preference,
      setupCompleted: preferences.getBool(_setupCompletedKey) ?? false,
    );
  }

  Future<void> saveSettings({
    required AppLanguagePreference preference,
    required bool setupCompleted,
  }) async {
    final preferences = await SharedPreferences.getInstance();

    await preferences.setString(_preferenceKey, preference.name);
    await preferences.setBool(_setupCompletedKey, setupCompleted);
  }

  Future<void> updatePreference(
    AppLanguagePreference preference, {
    bool setupCompleted = true,
  }) async {
    await saveSettings(preference: preference, setupCompleted: setupCompleted);

    if (preferenceNotifier.value != preference) {
      preferenceNotifier.value = preference;
    }
  }

  Locale resolveLocale({
    required AppLanguagePreference preference,
    required List<Locale> deviceLocales,
  }) {
    final manualLanguageCode = switch (preference) {
      AppLanguagePreference.system => null,
      AppLanguagePreference.sl => 'sl',
      AppLanguagePreference.en => 'en',
      AppLanguagePreference.de => 'de',
      AppLanguagePreference.hr => 'hr',
    };

    if (manualLanguageCode != null) {
      return Locale(manualLanguageCode);
    }

    for (final locale in deviceLocales) {
      final languageCode = locale.languageCode.toLowerCase();

      if (supportedLanguageCodes.contains(languageCode)) {
        return Locale(languageCode);
      }
    }

    // Angleščina je rezervni jezik za vse nepodprte jezike naprave.
    return const Locale('en');
  }
}
