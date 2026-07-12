import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:swapstash/core/models/user_profile.dart';
import 'package:swapstash/core/services/firestore_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreService _firestore = FirestoreService();

  User? get currentUser => _auth.currentUser;

  Stream<User?> authStateChanges() {
    return _auth.authStateChanges();
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<void> register({
    required String email,
    required String password,
    required String displayName,
  }) async {
    final trimmedEmail = email.trim();
    final trimmedDisplayName = displayName.trim();

    if (trimmedDisplayName.isEmpty) {
      throw ArgumentError(
        'Prikazno ime ne sme biti prazno.',
      );
    }

    final credential =
        await _auth.createUserWithEmailAndPassword(
      email: trimmedEmail,
      password: password,
    );

    final user = credential.user;

    if (user == null) {
      throw Exception(
        'Uporabniškega računa ni bilo mogoče ustvariti.',
      );
    }

    await user.updateDisplayName(
      trimmedDisplayName,
    );

    final profile = UserProfile(
      uid: user.uid,
      email: trimmedEmail,
      displayName: trimmedDisplayName,
      country: 'SI',
      language: 'sl',
      allowInternationalTrades: false,
      rating: 0,
      completedTrades: 0,
      createdAt: Timestamp.now(),
    );

    await _firestore.createUserProfile(profile);
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }
}