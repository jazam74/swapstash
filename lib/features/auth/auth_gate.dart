import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:swapstash/core/services/auth_service.dart';
import 'package:swapstash/features/auth/auth_screen.dart';
import 'package:swapstash/features/auth/email_verification_page.dart';
import 'package:swapstash/features/home/home_shell.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  final AuthService _authService = AuthService();

  String? _continuedUnverifiedUserId;

  void _continueWithoutVerification(String userId) {
    setState(() {
      _continuedUnverifiedUserId = userId;
    });
  }

  void _handleVerified() {
    setState(() {
      _continuedUnverifiedUserId = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: _authService.userChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final streamUser = snapshot.data;
        final currentUser = FirebaseAuth.instance.currentUser;
        final user = currentUser?.uid == streamUser?.uid
            ? currentUser
            : streamUser;

        if (user == null) {
          return const AuthScreen();
        }

        if (user.emailVerified || _continuedUnverifiedUserId == user.uid) {
          return const HomeShell();
        }

        return EmailVerificationPage(
          onContinue: () => _continueWithoutVerification(user.uid),
          onVerified: _handleVerified,
        );
      },
    );
  }
}
