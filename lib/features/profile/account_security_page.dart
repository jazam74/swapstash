import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:swapstash/core/localization/firebase_auth_error.dart';
import 'package:swapstash/core/services/auth_service.dart';
import 'package:swapstash/features/profile/change_password_page.dart';
import 'package:swapstash/features/profile/delete_account_page.dart';
import 'package:swapstash/l10n/generated/app_localizations.dart';

class AccountSecurityPage extends StatefulWidget {
  const AccountSecurityPage({super.key});

  @override
  State<AccountSecurityPage> createState() => _AccountSecurityPageState();
}

class _AccountSecurityPageState extends State<AccountSecurityPage> {
  final AuthService _authService = AuthService();

  bool _isSendingVerification = false;
  bool _isCheckingVerification = false;

  Future<void> _sendVerification() async {
    final localizations = AppLocalizations.of(context)!;

    if (_isSendingVerification) {
      return;
    }

    setState(() {
      _isSendingVerification = true;
    });

    try {
      await _authService.sendEmailVerification(
        languageCode: Localizations.localeOf(context).languageCode,
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(localizations.verificationEmailSent)),
      );
    } on FirebaseAuthException catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(localizedFirebaseAuthError(error, localizations)),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSendingVerification = false;
        });
      }
    }
  }

  Future<void> _checkVerification() async {
    final localizations = AppLocalizations.of(context)!;

    if (_isCheckingVerification) {
      return;
    }

    setState(() {
      _isCheckingVerification = true;
    });

    try {
      final verified = await _authService.reloadEmailVerificationStatus();

      if (!mounted) {
        return;
      }

      setState(() {});

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            verified
                ? localizations.emailVerificationConfirmed
                : localizations.emailStillNotVerified,
          ),
        ),
      );
    } on FirebaseAuthException catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(localizedFirebaseAuthError(error, localizations)),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isCheckingVerification = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final user = FirebaseAuth.instance.currentUser;
    final isVerified = user?.emailVerified ?? false;

    return Scaffold(
      appBar: AppBar(title: Text(localizations.accountSecurityTitle)),
      body: LayoutBuilder(
        builder: (context, constraints) {
          const maxContentWidth = 900.0;

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
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Icon(
                    isVerified
                        ? Icons.verified_outlined
                        : Icons.mark_email_unread_outlined,
                    size: 48,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    user?.email ?? localizations.unknownUser,
                    style: Theme.of(context).textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    isVerified
                        ? localizations.emailVerified
                        : localizations.emailNotVerified,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isVerified
                          ? Colors.green
                          : Theme.of(context).colorScheme.error,
                    ),
                  ),
                  if (!isVerified) ...[
                    const SizedBox(height: 14),
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        OutlinedButton.icon(
                          onPressed: _isSendingVerification
                              ? null
                              : _sendVerification,
                          icon: _isSendingVerification
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.send_outlined),
                          label: Text(localizations.resendVerificationEmail),
                        ),
                        OutlinedButton.icon(
                          onPressed: _isCheckingVerification
                              ? null
                              : _checkVerification,
                          icon: _isCheckingVerification
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.refresh),
                          label: Text(localizations.checkVerificationStatus),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.password_outlined),
              title: Text(localizations.changePasswordTitle),
              subtitle: Text(localizations.changePasswordSubtitle),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ChangePasswordPage()),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: Icon(
                Icons.delete_forever_outlined,
                color: Theme.of(context).colorScheme.error,
              ),
              title: Text(
                localizations.deleteAccountTitle,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
              subtitle: Text(localizations.deleteAccountSubtitle),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const DeleteAccountPage()),
                );
              },
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
