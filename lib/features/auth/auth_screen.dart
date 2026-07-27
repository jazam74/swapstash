import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:swapstash/core/localization/firebase_auth_error.dart';
import 'package:swapstash/core/services/auth_service.dart';
import 'package:swapstash/core/utils/email_utils.dart';
import 'package:swapstash/features/auth/forgot_password_page.dart';
import 'package:swapstash/l10n/generated/app_localizations.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();

  final _displayNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final AuthService _authService = AuthService();

  bool _isLogin = true;
  bool _isLoading = false;
  bool _hidePassword = true;

  @override
  void dispose() {
    _displayNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final localizations = AppLocalizations.of(context)!;

    if (!_formKey.currentState!.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      _isLoading = true;
    });

    try {
      final displayName = _displayNameController.text.trim();
      final email = normalizeEmailAddress(_emailController.text);
      final password = _passwordController.text;

      if (_emailController.text != email) {
        _emailController.value = TextEditingValue(
          text: email,
          selection: TextSelection.collapsed(offset: email.length),
        );
      }

      if (_isLogin) {
        await _authService.login(email: email, password: password);
        TextInput.finishAutofillContext(shouldSave: true);
      } else {
        await _authService.register(
          email: email,
          password: password,
          displayName: displayName,
          languageCode: Localizations.localeOf(context).languageCode,
        );
        TextInput.finishAutofillContext(shouldSave: true);
      }
    } on FirebaseAuthException catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(localizedFirebaseAuthError(error, localizations)),
        ),
      );
    } on ArgumentError catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error.message?.toString() ?? localizations.authInvalidData,
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(localizations.authUnexpectedError(error.toString())),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _switchMode() {
    setState(() {
      _isLogin = !_isLogin;

      if (_isLogin) {
        _displayNameController.clear();
        _confirmPasswordController.clear();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const CircleAvatar(
                      radius: 42,
                      child: Icon(Icons.swap_horiz, size: 46),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      localizations.appName,
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _isLogin
                          ? localizations.authLoginSubtitle
                          : localizations.authRegisterSubtitle,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    if (!_isLogin) ...[
                      TextFormField(
                        controller: _displayNameController,
                        textInputAction: TextInputAction.next,
                        textCapitalization: TextCapitalization.words,
                        autocorrect: false,
                        decoration: InputDecoration(
                          labelText: localizations.authDisplayNameLabel,
                          hintText: localizations.authDisplayNameHint,
                          prefixIcon: const Icon(Icons.person_outline),
                          border: const OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (_isLogin) {
                            return null;
                          }

                          final displayName = value?.trim() ?? '';

                          if (displayName.isEmpty) {
                            return localizations.authDisplayNameRequired;
                          }

                          if (displayName.length < 2) {
                            return localizations.authDisplayNameMinLength;
                          }

                          if (displayName.length > 40) {
                            return localizations.authDisplayNameMaxLength;
                          }

                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                    ],
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
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
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _hidePassword,
                      textInputAction: _isLogin
                          ? TextInputAction.done
                          : TextInputAction.next,
                      autofillHints: _isLogin
                          ? const [AutofillHints.password]
                          : const [AutofillHints.newPassword],
                      decoration: InputDecoration(
                        labelText: localizations.authPasswordLabel,
                        prefixIcon: const Icon(Icons.lock_outline),
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          tooltip: _hidePassword
                              ? localizations.authShowPassword
                              : localizations.authHidePassword,
                          onPressed: () {
                            setState(() {
                              _hidePassword = !_hidePassword;
                            });
                          },
                          icon: Icon(
                            _hidePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return localizations.authPasswordRequired;
                        }

                        if (value.length < 6) {
                          return localizations.authPasswordMinLength;
                        }

                        return null;
                      },
                      onFieldSubmitted: (_) {
                        if (_isLogin && !_isLoading) {
                          _submit();
                        }
                      },
                    ),
                    if (_isLogin)
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: _isLoading
                              ? null
                              : () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => ForgotPasswordPage(
                                        initialEmail: _emailController.text
                                            .trim(),
                                      ),
                                    ),
                                  );
                                },
                          child: Text(localizations.forgotPassword),
                        ),
                      ),
                    if (!_isLogin) ...[
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: _hidePassword,
                        textInputAction: TextInputAction.done,
                        decoration: InputDecoration(
                          labelText: localizations.authConfirmPasswordLabel,
                          prefixIcon: const Icon(Icons.lock_reset),
                          border: const OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (_isLogin) {
                            return null;
                          }

                          if (value == null || value.isEmpty) {
                            return localizations.authConfirmPasswordRequired;
                          }

                          if (value != _passwordController.text) {
                            return localizations.authPasswordsDoNotMatch;
                          }

                          return null;
                        },
                        onFieldSubmitted: (_) {
                          if (!_isLoading) {
                            _submit();
                          }
                        },
                      ),
                    ],
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: _isLoading ? null : _submit,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  _isLogin
                                      ? localizations.authLoginButton
                                      : localizations.authCreateAccountButton,
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: _isLoading ? null : _switchMode,
                      child: Text(
                        _isLogin
                            ? localizations.authNoAccountRegister
                            : localizations.authHaveAccountLogin,
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
