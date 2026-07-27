import 'package:flutter/material.dart';
import 'package:swapstash/core/services/language_service.dart';
import 'package:swapstash/l10n/generated/app_localizations.dart';

class LanguageSelectionPage extends StatefulWidget {
  final AppLanguagePreference selectedPreference;
  final ValueChanged<AppLanguagePreference> onPreferenceChanged;
  final Future<void> Function(AppLanguagePreference preference) onContinue;

  const LanguageSelectionPage({
    super.key,
    required this.selectedPreference,
    required this.onPreferenceChanged,
    required this.onContinue,
  });

  @override
  State<LanguageSelectionPage> createState() => _LanguageSelectionPageState();
}

class _LanguageSelectionPageState extends State<LanguageSelectionPage> {
  bool _isSaving = false;

  Future<void> _continue() async {
    if (_isSaving) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      await widget.onContinue(widget.selectedPreference);
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
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
              children: [
                Align(
                  alignment: Alignment.center,
                  child: Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.language_rounded,
                      size: 38,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  localizations.chooseLanguage,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  localizations.chooseLanguageDescription,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 28),
                _LanguageOption(
                  title: localizations.automaticLanguage,
                  subtitle: localizations.automaticLanguageDescription,
                  preference: AppLanguagePreference.system,
                  selectedPreference: widget.selectedPreference,
                  onSelected: widget.onPreferenceChanged,
                  icon: Icons.phone_android_rounded,
                ),
                const SizedBox(height: 10),
                _LanguageOption(
                  title: 'Slovenščina',
                  subtitle: 'Slovenian',
                  preference: AppLanguagePreference.sl,
                  selectedPreference: widget.selectedPreference,
                  onSelected: widget.onPreferenceChanged,
                  icon: Icons.translate_rounded,
                ),
                const SizedBox(height: 10),
                _LanguageOption(
                  title: 'English',
                  subtitle: 'English',
                  preference: AppLanguagePreference.en,
                  selectedPreference: widget.selectedPreference,
                  onSelected: widget.onPreferenceChanged,
                  icon: Icons.translate_rounded,
                ),
                const SizedBox(height: 10),
                _LanguageOption(
                  title: 'Deutsch',
                  subtitle: 'German',
                  preference: AppLanguagePreference.de,
                  selectedPreference: widget.selectedPreference,
                  onSelected: widget.onPreferenceChanged,
                  icon: Icons.translate_rounded,
                ),
                const SizedBox(height: 10),
                _LanguageOption(
                  title: 'Hrvatski',
                  subtitle: 'Croatian',
                  preference: AppLanguagePreference.hr,
                  selectedPreference: widget.selectedPreference,
                  onSelected: widget.onPreferenceChanged,
                  icon: Icons.translate_rounded,
                ),
                const SizedBox(height: 18),
                Text(
                  localizations.englishFallbackDescription,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _isSaving ? null : _continue,
                    icon: _isSaving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.arrow_forward_rounded),
                    label: Text(
                      _isSaving
                          ? localizations.saving
                          : localizations.continueButton,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LanguageOption extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final AppLanguagePreference preference;
  final AppLanguagePreference selectedPreference;
  final ValueChanged<AppLanguagePreference> onSelected;

  const _LanguageOption({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.preference,
    required this.selectedPreference,
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
        onTap: () => onSelected(preference),
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
