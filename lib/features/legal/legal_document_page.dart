import 'package:flutter/material.dart';
import 'package:swapstash/l10n/generated/app_localizations.dart';

enum LegalDocumentType {
  terms,
  privacy,
}

class LegalDocumentPage extends StatelessWidget {
  final LegalDocumentType type;

  const LegalDocumentPage({
    super.key,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final isTerms = type == LegalDocumentType.terms;

    final sections = isTerms
        ? [
            _LegalSection(
              title: localizations.legalTermsEligibilityTitle,
              body: localizations.legalTermsEligibilityBody,
            ),
            _LegalSection(
              title: localizations.legalTermsServiceTitle,
              body: localizations.legalTermsServiceBody,
            ),
            _LegalSection(
              title: localizations.legalTermsConductTitle,
              body: localizations.legalTermsConductBody,
            ),
            _LegalSection(
              title: localizations.legalTermsTradesTitle,
              body: localizations.legalTermsTradesBody,
            ),
            _LegalSection(
              title: localizations.legalTermsContentTitle,
              body: localizations.legalTermsContentBody,
            ),
            _LegalSection(
              title: localizations.legalTermsSuspensionTitle,
              body: localizations.legalTermsSuspensionBody,
            ),
            _LegalSection(
              title: localizations.legalTermsLiabilityTitle,
              body: localizations.legalTermsLiabilityBody,
            ),
            _LegalSection(
              title: localizations.legalTermsChangesTitle,
              body: localizations.legalTermsChangesBody,
            ),
          ]
        : [
            _LegalSection(
              title: localizations.legalPrivacyControllerTitle,
              body: localizations.legalPrivacyControllerBody,
            ),
            _LegalSection(
              title: localizations.legalPrivacyDataTitle,
              body: localizations.legalPrivacyDataBody,
            ),
            _LegalSection(
              title: localizations.legalPrivacyPurposeTitle,
              body: localizations.legalPrivacyPurposeBody,
            ),
            _LegalSection(
              title: localizations.legalPrivacyVisibilityTitle,
              body: localizations.legalPrivacyVisibilityBody,
            ),
            _LegalSection(
              title: localizations.legalPrivacyRetentionTitle,
              body: localizations.legalPrivacyRetentionBody,
            ),
            _LegalSection(
              title: localizations.legalPrivacyProcessorsTitle,
              body: localizations.legalPrivacyProcessorsBody,
            ),
            _LegalSection(
              title: localizations.legalPrivacyRightsTitle,
              body: localizations.legalPrivacyRightsBody,
            ),
            _LegalSection(
              title: localizations.legalPrivacyChildrenTitle,
              body: localizations.legalPrivacyChildrenBody,
            ),
            _LegalSection(
              title: localizations.legalPrivacySecurityTitle,
              body: localizations.legalPrivacySecurityBody,
            ),
          ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isTerms
              ? localizations.legalTermsTitle
              : localizations.legalPrivacyTitle,
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          const maxContentWidth = 1100.0;

          final horizontalPadding = constraints.maxWidth >= 900 ? 24.0 : 20.0;
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
              40,
            ),
            children: [
              Align(
                alignment: Alignment.topCenter,
                child: SizedBox(
                  width: contentWidth,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(18),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isTerms
                                    ? localizations.legalTermsIntro
                                    : localizations.legalPrivacyIntro,
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                localizations.legalEffectiveDate,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      for (final section in sections)
                        _LegalSectionCard(section: section),
                      const SizedBox(height: 8),
                      Text(
                        localizations.legalContactFooter,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall,
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

class _LegalSectionCard extends StatelessWidget {
  final _LegalSection section;

  const _LegalSectionCard({
    required this.section,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              section.title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 8),
            SelectableText(
              section.body,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    height: 1.45,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LegalSection {
  final String title;
  final String body;

  const _LegalSection({
    required this.title,
    required this.body,
  });
}
