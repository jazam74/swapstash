import 'package:shared_preferences/shared_preferences.dart';

class BetaSetupSettings {
  final bool onboardingCompleted;
  final bool legalDocumentsAccepted;

  const BetaSetupSettings({
    required this.onboardingCompleted,
    required this.legalDocumentsAccepted,
  });
}

class BetaSetupService {
  static const String currentLegalVersion = '2026-07-24-v1';

  static const String _onboardingCompletedKey =
      'swapstash_beta_onboarding_completed';
  static const String _legalVersionKey =
      'swapstash_accepted_legal_version';
  static const String _legalAcceptedAtKey =
      'swapstash_legal_accepted_at';

  Future<BetaSetupSettings> loadSettings() async {
    final preferences = await SharedPreferences.getInstance();

    return BetaSetupSettings(
      onboardingCompleted:
          preferences.getBool(_onboardingCompletedKey) ?? false,
      legalDocumentsAccepted:
          preferences.getString(_legalVersionKey) == currentLegalVersion,
    );
  }

  Future<void> completeOnboarding() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(_onboardingCompletedKey, true);
  }

  Future<void> acceptCurrentLegalDocuments() async {
    final preferences = await SharedPreferences.getInstance();

    await Future.wait([
      preferences.setString(
        _legalVersionKey,
        currentLegalVersion,
      ),
      preferences.setString(
        _legalAcceptedAtKey,
        DateTime.now().toUtc().toIso8601String(),
      ),
    ]);
  }
}
