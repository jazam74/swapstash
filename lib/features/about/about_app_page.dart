import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:swapstash/features/legal/legal_document_page.dart';
import 'package:swapstash/l10n/generated/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutAppPage extends StatelessWidget {
  static const String supportEmail = 'uros2004@gmail.com';

  const AboutAppPage({super.key});

  Future<void> _sendFeedback(BuildContext context) async {
    final localizations = AppLocalizations.of(context)!;
    final uri = Uri(
      scheme: 'mailto',
      path: supportEmail,
      queryParameters: {
        'subject': localizations.aboutFeedbackEmailSubject,
      },
    );

    final launched = await launchUrl(uri);

    if (!launched && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(localizations.aboutFeedbackOpenError),
        ),
      );
    }
  }

  void _openDocument(
    BuildContext context,
    LegalDocumentType type,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => LegalDocumentPage(type: type),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.aboutAppTitle),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          const maxContentWidth = 900.0;

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
          const SizedBox(height: 12),
          const CircleAvatar(
            radius: 48,
            child: Icon(
              Icons.swap_horiz_rounded,
              size: 52,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            localizations.appName,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            localizations.aboutAppDescription,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          FutureBuilder<PackageInfo>(
            future: PackageInfo.fromPlatform(),
            builder: (context, snapshot) {
              final packageInfo = snapshot.data;

              return Card(
                child: ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: Text(localizations.aboutVersion),
                  subtitle: Text(
                    packageInfo == null
                        ? localizations.aboutVersionLoading
                        : '${packageInfo.version} '
                              '(${packageInfo.buildNumber})',
                  ),
                ),
              );
            },
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.business_outlined),
              title: Text(localizations.aboutOperator),
              subtitle: const Text('SwapStash'),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.email_outlined),
              title: Text(localizations.aboutContact),
              subtitle: const Text(supportEmail),
              trailing: const Icon(Icons.open_in_new),
              onTap: () => _sendFeedback(context),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            localizations.aboutLegalSection,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.description_outlined),
                  title: Text(localizations.legalTermsTitle),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _openDocument(
                    context,
                    LegalDocumentType.terms,
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.privacy_tip_outlined),
                  title: Text(localizations.legalPrivacyTitle),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _openDocument(
                    context,
                    LegalDocumentType.privacy,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: () => _sendFeedback(context),
            icon: const Icon(Icons.feedback_outlined),
            label: Text(localizations.aboutSendFeedback),
          ),
          const SizedBox(height: 24),
          Text(
            localizations.aboutBetaFooter,
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
