import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:swapstash/core/localization/firebase_auth_error.dart';
import 'package:swapstash/core/services/auth_service.dart';
import 'package:swapstash/l10n/generated/app_localizations.dart';

class EmailVerificationPage extends StatefulWidget {
  final VoidCallback onContinue;
  final VoidCallback onVerified;

  const EmailVerificationPage({
    super.key,
    required this.onContinue,
    required this.onVerified,
  });

  @override
  State<EmailVerificationPage> createState() => _EmailVerificationPageState();
}

class _EmailVerificationPageState extends State<EmailVerificationPage>
    with WidgetsBindingObserver {
  final AuthService _authService = AuthService();

  bool _isChecking = false;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(_checkStatus(showUnverifiedMessage: false));
    }
  }

  Future<void> _sendAgain() async {
    final localizations = AppLocalizations.of(context)!;

    if (_isSending) {
      return;
    }

    setState(() {
      _isSending = true;
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
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            localizations.verificationEmailSendError(error.toString()),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
    }
  }

  Future<void> _checkStatus({bool showUnverifiedMessage = true}) async {
    final localizations = AppLocalizations.of(context)!;

    if (_isChecking) {
      return;
    }

    setState(() {
      _isChecking = true;
    });

    try {
      final isVerified = await _authService.reloadEmailVerificationStatus();

      if (!mounted) {
        return;
      }

      if (isVerified) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(localizations.emailVerificationConfirmed)),
        );
        widget.onVerified();
      } else if (showUnverifiedMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(localizations.emailStillNotVerified)),
        );
      }
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
          _isChecking = false;
        });
      }
    }
  }

  Future<void> _signOut() async {
    await _authService.signOut();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final email = FirebaseAuth.instance.currentUser?.email ?? '';

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                children: [
                  const Icon(Icons.mark_email_unread_outlined, size: 80),
                  const SizedBox(height: 20),
                  Text(
                    localizations.verifyEmailTitle,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    localizations.verifyEmailDescription(email),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _isChecking ? null : () => _checkStatus(),
                      icon: _isChecking
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.verified_outlined),
                      label: Text(
                        _isChecking
                            ? localizations.checkingVerification
                            : localizations.checkVerificationStatus,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _isSending ? null : _sendAgain,
                      icon: _isSending
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.refresh_outlined),
                      label: Text(
                        _isSending
                            ? localizations.sendingEmail
                            : localizations.resendVerificationEmail,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: widget.onContinue,
                    child: Text(localizations.continueWithoutVerification),
                  ),
                  TextButton(
                    onPressed: _signOut,
                    child: Text(localizations.signOut),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
