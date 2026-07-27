import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:swapstash/core/localization/firebase_auth_error.dart';
import 'package:swapstash/core/services/auth_service.dart';
import 'package:swapstash/l10n/generated/app_localizations.dart';

class DeleteAccountPage extends StatefulWidget {
  const DeleteAccountPage({super.key});

  @override
  State<DeleteAccountPage> createState() => _DeleteAccountPageState();
}

class _DeleteAccountPageState extends State<DeleteAccountPage> {
  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();

  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmationController = TextEditingController();

  bool _hidePassword = true;
  bool _isDeleting = false;

  String _normalizeConfirmationText(String value) {
    return value
        .toUpperCase()
        .replaceAll(RegExp(r'[\s\u00A0\u200B\u200C\u200D\u2060\uFEFF]'), '')
        .replaceAll('Š', 'S')
        .replaceAll('Ž', 'Z')
        .replaceAll('Č', 'C')
        .replaceAll('Ć', 'C')
        .replaceAll('Đ', 'D')
        .replaceAll('Ö', 'O')
        .replaceAll('Ä', 'A')
        .replaceAll('Ü', 'U')
        .replaceAll('ß', 'SS')
        .replaceAll(RegExp(r'[\u0300-\u036F]'), '');
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmationController.dispose();
    super.dispose();
  }

  Future<void> _deleteAccount() async {
    final localizations = AppLocalizations.of(context)!;

    if (!_formKey.currentState!.validate() || _isDeleting) {
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(localizations.deleteAccountConfirmationTitle),
          content: Text(localizations.deleteAccountConfirmationMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(localizations.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
                foregroundColor: Theme.of(context).colorScheme.onError,
              ),
              child: Text(localizations.deleteAccountButton),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) {
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      _isDeleting = true;
    });

    try {
      await _authService.deleteAccount(password: _passwordController.text);
    } on AccountDeletionBlockedByActiveTradesException {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(localizations.accountDeleteActiveTrades)),
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
          content: Text(localizations.accountDeleteError(error.toString())),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isDeleting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final confirmationWord = localizations.deleteAccountConfirmationWord;

    return Scaffold(
      appBar: AppBar(title: Text(localizations.deleteAccountTitle)),
      body: Form(
        key: _formKey,
        child: LayoutBuilder(
          builder: (context, constraints) {
            const maxContentWidth = 900.0;

            final horizontalPadding =
                constraints.maxWidth >= 900 ? 24.0 : 16.0;
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
              color: Theme.of(context).colorScheme.errorContainer,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      size: 48,
                      color: Theme.of(context).colorScheme.onErrorContainer,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      localizations.deleteAccountWarningTitle,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onErrorContainer,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      localizations.deleteAccountWarning,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onErrorContainer,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              localizations.deleteAccountHistoryNotice,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _passwordController,
              obscureText: _hidePassword,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: localizations.currentPassword,
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
                  return localizations.currentPasswordRequired;
                }

                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _confirmationController,
              textCapitalization: TextCapitalization.characters,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                labelText: localizations.deleteAccountConfirmationLabel(
                  confirmationWord,
                ),
                prefixIcon: const Icon(Icons.delete_forever_outlined),
                border: const OutlineInputBorder(),
              ),
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: (value) {
                final enteredValue = _normalizeConfirmationText(value ?? '');
                final requiredValue = _normalizeConfirmationText(
                  confirmationWord,
                );

                if (enteredValue != requiredValue) {
                  return localizations.deleteAccountConfirmationInvalid(
                    confirmationWord,
                  );
                }

                return null;
              },
              onFieldSubmitted: (_) => _deleteAccount(),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _isDeleting ? null : _deleteAccount,
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
                foregroundColor: Theme.of(context).colorScheme.onError,
              ),
              icon: _isDeleting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.delete_forever_outlined),
              label: Text(
                _isDeleting
                    ? localizations.deletingAccount
                    : localizations.deleteAccountButton,
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
      ),
    );
  }
}
