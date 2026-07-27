import 'package:flutter/material.dart';
import 'package:swapstash/features/legal/legal_document_page.dart';
import 'package:swapstash/l10n/generated/app_localizations.dart';

class LegalAcceptancePage extends StatefulWidget {
  final Future<void> Function() onAccepted;

  const LegalAcceptancePage({
    super.key,
    required this.onAccepted,
  });

  @override
  State<LegalAcceptancePage> createState() =>
      _LegalAcceptancePageState();
}

class _LegalAcceptancePageState extends State<LegalAcceptancePage> {
  bool _ageConfirmed = false;
  bool _documentsAccepted = false;
  bool _saving = false;

  Future<void> _accept() async {
    if (_saving || !_ageConfirmed || !_documentsAccepted) {
      return;
    }

    setState(() {
      _saving = true;
    });

    try {
      await widget.onAccepted();
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  void _openDocument(LegalDocumentType type) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => LegalDocumentPage(type: type),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final canContinue = _ageConfirmed && _documentsAccepted;

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.legalAcceptanceTitle),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const SizedBox(height: 12),
            Icon(
              Icons.verified_user_outlined,
              size: 72,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 20),
            Text(
              localizations.legalAcceptanceHeading,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 10),
            Text(
              localizations.legalAcceptanceDescription,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            Card(
              child: Column(
                children: [
                  CheckboxListTile(
                    value: _ageConfirmed,
                    onChanged: _saving
                        ? null
                        : (value) {
                            setState(() {
                              _ageConfirmed = value ?? false;
                            });
                          },
                    controlAffinity: ListTileControlAffinity.leading,
                    title: Text(
                      localizations.legalAgeConfirmation,
                    ),
                  ),
                  const Divider(height: 1),
                  CheckboxListTile(
                    value: _documentsAccepted,
                    onChanged: _saving
                        ? null
                        : (value) {
                            setState(() {
                              _documentsAccepted = value ?? false;
                            });
                          },
                    controlAffinity: ListTileControlAffinity.leading,
                    title: Text(
                      localizations.legalDocumentsConfirmation,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _openDocument(
                      LegalDocumentType.terms,
                    ),
                    icon: const Icon(Icons.description_outlined),
                    label: Text(localizations.legalTermsTitle),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _openDocument(
                      LegalDocumentType.privacy,
                    ),
                    icon: const Icon(Icons.privacy_tip_outlined),
                    label: Text(localizations.legalPrivacyTitle),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Card(
              color: Theme.of(context).colorScheme.surfaceContainerLow,
              child: ListTile(
                leading: const Icon(Icons.info_outline),
                title: Text(localizations.legalBetaNoticeTitle),
                subtitle: Text(localizations.legalBetaNoticeDescription),
              ),
            ),
            const SizedBox(height: 22),
            FilledButton.icon(
              onPressed: canContinue && !_saving ? _accept : null,
              icon: _saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.check_circle_outline),
              label: Text(
                _saving
                    ? localizations.legalAcceptanceSaving
                    : localizations.legalAcceptAndContinue,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
