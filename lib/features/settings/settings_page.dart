import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:swapstash/core/services/language_service.dart';
import 'package:swapstash/core/services/report_service.dart';
import 'package:swapstash/features/admin/admin_reports_page.dart';
import 'package:swapstash/features/settings/blocked_users_page.dart';
import 'package:swapstash/features/about/about_app_page.dart';
import 'package:swapstash/features/legal/legal_document_page.dart';
import 'package:swapstash/features/onboarding/onboarding_page.dart';
import 'package:swapstash/l10n/generated/app_localizations.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final LanguageService _languageService = LanguageService.instance;

  late AppLanguagePreference _selectedPreference;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _selectedPreference = _languageService.currentPreference;
  }

  Future<void> _selectLanguage(AppLanguagePreference preference) async {
    if (_isSaving || preference == _selectedPreference) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      await _languageService.updatePreference(preference);

      if (!mounted) {
        return;
      }

      setState(() {
        _selectedPreference = preference;
      });

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.languageChanged),
          ),
        );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.settings),
        actions: [
          if (_isSaving)
            const Padding(
              padding: EdgeInsets.only(right: 16),
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          const maxContentWidth = 1100.0;

          final horizontalPadding = constraints.maxWidth >= 900
              ? 24.0
              : 16.0;
          final availableWidth =
              constraints.maxWidth - (horizontalPadding * 2);
          final contentWidth = availableWidth > maxContentWidth
              ? maxContentWidth
              : availableWidth;

          return ListView(
            padding: EdgeInsets.fromLTRB(
              horizontalPadding,
              20,
              horizontalPadding,
              32,
            ),
            children: [
              Align(
                alignment: Alignment.topCenter,
                child: SizedBox(
                  width: contentWidth,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
          Text(
            localizations.language,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            localizations.languageSettingsDescription,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 18),
          _LanguageSettingsOption(
            title: localizations.automaticLanguage,
            subtitle: localizations.automaticLanguageDescription,
            preference: AppLanguagePreference.system,
            selectedPreference: _selectedPreference,
            enabled: !_isSaving,
            onSelected: _selectLanguage,
            icon: Icons.phone_android_rounded,
          ),
          const SizedBox(height: 10),
          _LanguageSettingsOption(
            title: 'Slovenščina',
            subtitle: 'Slovenian',
            preference: AppLanguagePreference.sl,
            selectedPreference: _selectedPreference,
            enabled: !_isSaving,
            onSelected: _selectLanguage,
            icon: Icons.translate_rounded,
          ),
          const SizedBox(height: 10),
          _LanguageSettingsOption(
            title: 'English',
            subtitle: 'English',
            preference: AppLanguagePreference.en,
            selectedPreference: _selectedPreference,
            enabled: !_isSaving,
            onSelected: _selectLanguage,
            icon: Icons.translate_rounded,
          ),
          const SizedBox(height: 10),
          _LanguageSettingsOption(
            title: 'Deutsch',
            subtitle: 'German',
            preference: AppLanguagePreference.de,
            selectedPreference: _selectedPreference,
            enabled: !_isSaving,
            onSelected: _selectLanguage,
            icon: Icons.translate_rounded,
          ),
          const SizedBox(height: 10),
          _LanguageSettingsOption(
            title: 'Hrvatski',
            subtitle: 'Croatian',
            preference: AppLanguagePreference.hr,
            selectedPreference: _selectedPreference,
            enabled: !_isSaving,
            onSelected: _selectLanguage,
            icon: Icons.translate_rounded,
          ),
          const SizedBox(height: 24),
          Text(
            localizations.safetySettingsTitle,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          Card(
            child: ListTile(
              leading: const Icon(Icons.person_off_outlined),
              title: Text(localizations.safetyBlockedUsers),
              subtitle: Text(localizations.safetyBlockedUsersDescription),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const BlockedUsersPage()),
                );
              },
            ),
          ),
          if (FirebaseAuth.instance.currentUser?.uid == ReportService.adminUid)
            Card(
              child: ListTile(
                leading: const Icon(Icons.admin_panel_settings_outlined),
                title: Text(localizations.safetyAdminReports),
                subtitle: Text(localizations.safetyAdminReportsDescription),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const AdminReportsPage()),
                  );
                },
              ),
            ),
          const SizedBox(height: 24),
          Text(
            localizations.settingsAboutAndLegalTitle,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          Card(
            child: ListTile(
              leading: const Icon(Icons.info_outline),
              title: Text(localizations.aboutAppTitle),
              subtitle: Text(localizations.settingsAboutAppSubtitle),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const AboutAppPage(),
                  ),
                );
              },
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.description_outlined),
              title: Text(localizations.legalTermsTitle),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const LegalDocumentPage(
                      type: LegalDocumentType.terms,
                    ),
                  ),
                );
              },
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.privacy_tip_outlined),
              title: Text(localizations.legalPrivacyTitle),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const LegalDocumentPage(
                      type: LegalDocumentType.privacy,
                    ),
                  ),
                );
              },
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.slideshow_outlined),
              title: Text(localizations.betaOnboardingShowAgain),
              subtitle: Text(
                localizations.betaOnboardingShowAgainDescription,
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (pageContext) => OnboardingPage(
                      isReplay: true,
                      onComplete: () async {
                        if (pageContext.mounted) {
                          Navigator.of(pageContext).pop();
                        }
                      },
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 18),
          Text(
            localizations.englishFallbackDescription,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _LanguageSettingsOption extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final AppLanguagePreference preference;
  final AppLanguagePreference selectedPreference;
  final bool enabled;
  final ValueChanged<AppLanguagePreference> onSelected;

  const _LanguageSettingsOption({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.preference,
    required this.selectedPreference,
    required this.enabled,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isSelected = preference == selectedPreference;

    return Material(
      color: isSelected
          ? colorScheme.primaryContainer
          : colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(
          color: isSelected ? colorScheme.primary : colorScheme.outlineVariant,
          width: isSelected ? 2 : 1,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: enabled ? () => onSelected(preference) : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(
                icon,
                color: isSelected
                    ? colorScheme.onPrimaryContainer
                    : colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? colorScheme.onPrimaryContainer
                            : colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isSelected
                            ? colorScheme.onPrimaryContainer
                            : colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Icon(
                isSelected ? Icons.check_circle_rounded : Icons.circle_outlined,
                color: isSelected ? colorScheme.primary : colorScheme.outline,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
