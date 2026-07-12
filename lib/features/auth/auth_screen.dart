import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:swapstash/core/services/auth_service.dart';

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
    if (!_formKey.currentState!.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      _isLoading = true;
    });

    try {
      final displayName =
          _displayNameController.text.trim();
      final email = _emailController.text.trim();
      final password = _passwordController.text;

      if (_isLogin) {
        await _authService.login(
          email: email,
          password: password,
        );
      } else {
        await _authService.register(
          email: email,
          password: password,
          displayName: displayName,
        );
      }
    } on FirebaseAuthException catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _firebaseErrorMessage(error.code),
          ),
        ),
      );
    } on ArgumentError catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error.message?.toString() ??
                'Podatki niso veljavni.',
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Prišlo je do nepričakovane napake: $error',
          ),
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

  String _firebaseErrorMessage(String code) {
    switch (code) {
      case 'invalid-email':
        return 'E-poštni naslov ni veljaven.';
      case 'email-already-in-use':
        return 'Račun s tem e-poštnim naslovom že obstaja.';
      case 'weak-password':
        return 'Geslo je prešibko.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'E-poštni naslov ali geslo ni pravilno.';
      case 'too-many-requests':
        return 'Preveč poskusov. Poskusi ponovno pozneje.';
      case 'network-request-failed':
        return 'Preveri internetno povezavo.';
      default:
        return 'Prijava ali registracija ni uspela.';
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
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 440,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const CircleAvatar(
                      radius: 42,
                      child: Icon(
                        Icons.swap_horiz,
                        size: 46,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'SwapStash',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _isLogin
                          ? 'Prijavi se v svoj račun'
                          : 'Ustvari nov zbirateljski račun',
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
                        textCapitalization:
                            TextCapitalization.words,
                        autocorrect: false,
                        decoration: const InputDecoration(
                          labelText: 'Prikazno ime',
                          hintText: 'Na primer Uroš',
                          prefixIcon:
                              Icon(Icons.person_outline),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (_isLogin) {
                            return null;
                          }

                          final displayName =
                              value?.trim() ?? '';

                          if (displayName.isEmpty) {
                            return 'Vpiši prikazno ime.';
                          }

                          if (displayName.length < 2) {
                            return 'Ime mora imeti najmanj 2 znaka.';
                          }

                          if (displayName.length > 40) {
                            return 'Ime ima lahko največ 40 znakov.';
                          }

                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                    ],

                    TextFormField(
                      controller: _emailController,
                      keyboardType:
                          TextInputType.emailAddress,
                      textInputAction:
                          TextInputAction.next,
                      autocorrect: false,
                      enableSuggestions: false,
                      autofillHints: const [
                        AutofillHints.email,
                      ],
                      decoration: const InputDecoration(
                        labelText: 'E-poštni naslov',
                        prefixIcon:
                            Icon(Icons.email_outlined),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        final email =
                            value?.trim() ?? '';

                        if (email.isEmpty) {
                          return 'Vpiši e-poštni naslov.';
                        }

                        if (!email.contains('@') ||
                            !email.contains('.')) {
                          return 'Vpiši veljaven e-poštni naslov.';
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
                      autofillHints: const [
                        AutofillHints.password,
                      ],
                      decoration: InputDecoration(
                        labelText: 'Geslo',
                        prefixIcon:
                            const Icon(Icons.lock_outline),
                        border:
                            const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          tooltip: _hidePassword
                              ? 'Prikaži geslo'
                              : 'Skrij geslo',
                          onPressed: () {
                            setState(() {
                              _hidePassword =
                                  !_hidePassword;
                            });
                          },
                          icon: Icon(
                            _hidePassword
                                ? Icons.visibility_outlined
                                : Icons
                                    .visibility_off_outlined,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty) {
                          return 'Vpiši geslo.';
                        }

                        if (value.length < 6) {
                          return 'Geslo mora imeti najmanj 6 znakov.';
                        }

                        return null;
                      },
                      onFieldSubmitted: (_) {
                        if (_isLogin && !_isLoading) {
                          _submit();
                        }
                      },
                    ),

                    if (!_isLogin) ...[
                      const SizedBox(height: 16),
                      TextFormField(
                        controller:
                            _confirmPasswordController,
                        obscureText: _hidePassword,
                        textInputAction:
                            TextInputAction.done,
                        decoration:
                            const InputDecoration(
                          labelText: 'Ponovi geslo',
                          prefixIcon:
                              Icon(Icons.lock_reset),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (_isLogin) {
                            return null;
                          }

                          if (value == null ||
                              value.isEmpty) {
                            return 'Ponovno vpiši geslo.';
                          }

                          if (value !=
                              _passwordController.text) {
                            return 'Gesli se ne ujemata.';
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
                        onPressed:
                            _isLoading ? null : _submit,
                        child: Padding(
                          padding:
                              const EdgeInsets.symmetric(
                            vertical: 12,
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child:
                                      CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  _isLogin
                                      ? 'Prijava'
                                      : 'Ustvari račun',
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    TextButton(
                      onPressed:
                          _isLoading ? null : _switchMode,
                      child: Text(
                        _isLogin
                            ? 'Še nimaš računa? Registriraj se'
                            : 'Že imaš račun? Prijavi se',
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