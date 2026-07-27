import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:swapstash/core/localization/firebase_auth_error.dart';
import 'package:swapstash/core/services/auth_service.dart';
import 'package:swapstash/core/utils/email_utils.dart';
import 'package:swapstash/l10n/generated/app_localizations.dart';

class ForgotPasswordPage extends StatefulWidget {
  final String initialEmail;

  const ForgotPasswordPage({super.key, this.initialEmail = ''});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();

  late final TextEditingController _emailController;

  bool _isSending = false;
  bool _wasSent = false;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.initialEmail.trim());
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendResetEmail() async {
    final localizations = AppLocalizations.of(context)!;

    if (!_formKey.currentState!.validate() || _isSending) {
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      _isSending = true;
    });

    try {
      final email = normalizeEmailAddress(_emailController.text);

      _emailController.value = TextEditingValue(
        text: email,
        selection: TextSelection.collapsed(offset: email.length),
      );

      await _authService.sendPasswordResetEmail(
        email: email,
        languageCode: Localizations.localeOf(context).languageCode,
      );

      TextInput.finishAutofillContext(shouldSave: false);

      if (!mounted) {
        return;
      }

      setState(() {
        _wasSent = true;
      });
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
          content: Text(localizations.passwordResetError(error.toString())),
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

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(localizations.forgotPasswordTitle)),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: _wasSent
                  ? Column(
                      children: [
                        const Icon(Icons.mark_email_read_outlined, size: 72),
                        const SizedBox(height: 20),
                        Text(
                          localizations.passwordResetEmailSentTitle,
                          style: Theme.of(context).textTheme.headlineSmall,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          localizations.passwordResetEmailSentDescription,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        FilledButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text(localizations.backToSignIn),
                        ),
                      ],
                    )
                  : Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          const Icon(Icons.lock_reset_outlined, size: 72),
                          const SizedBox(height: 20),
                          Text(
                            localizations.forgotPasswordTitle,
                            style: Theme.of(context).textTheme.headlineSmall,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            localizations.forgotPasswordDescription,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.done,
                            textCapitalization: TextCapitalization.none,
                            autocorrect: false,
                            enableSuggestions: false,
                            autofillHints: const [
                              AutofillHints.username,
                              AutofillHints.email,
                            ],
                            inputFormatters: [emailInputFormatter],
                            decoration: InputDecoration(
                              labelText: localizations.authEmailLabel,
                              prefixIcon: const Icon(Icons.email_outlined),
                              border: const OutlineInputBorder(),
                            ),
                            validator: (value) {
                              final email = normalizeEmailAddress(value ?? '');

                              if (email.isEmpty) {
                                return localizations.authEmailRequired;
                              }

                              if (!isValidEmailAddress(email)) {
                                return localizations.authEmailInvalid;
                              }

                              return null;
                            },
                            onFieldSubmitted: (_) => _sendResetEmail(),
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton.icon(
                              onPressed: _isSending ? null : _sendResetEmail,
                              icon: _isSending
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(Icons.send_outlined),
                              label: Text(
                                _isSending
                                    ? localizations.sendingEmail
                                    : localizations.sendPasswordResetEmail,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
