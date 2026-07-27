import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:swapstash/core/models/user_profile.dart';
import 'package:swapstash/core/utils/email_utils.dart';
import 'package:swapstash/core/services/firestore_service.dart';
import 'package:swapstash/core/services/notification_service.dart';

class AccountDeletionBlockedByActiveTradesException implements Exception {
  const AccountDeletionBlockedByActiveTradesException();
}

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirestoreService _firestore = FirestoreService();

  User? get currentUser => _auth.currentUser;

  Stream<User?> authStateChanges() {
    return _auth.authStateChanges();
  }

  Stream<User?> userChanges() {
    return _auth.userChanges();
  }

  Future<void> signOut() async {
    await NotificationService.instance.removeCurrentDeviceToken();
    await _auth.signOut();
  }

  Future<void> register({
    required String email,
    required String password,
    required String displayName,
    required String languageCode,
  }) async {
    final trimmedEmail = normalizeEmailAddress(email);
    final trimmedDisplayName = displayName.trim();

    if (trimmedDisplayName.isEmpty) {
      throw ArgumentError('Prikazno ime ne sme biti prazno.');
    }

    await _auth.setLanguageCode(languageCode);

    final credential = await _auth.createUserWithEmailAndPassword(
      email: trimmedEmail,
      password: password,
    );

    final user = credential.user;

    if (user == null) {
      throw Exception('Uporabniškega računa ni bilo mogoče ustvariti.');
    }

    await user.updateDisplayName(trimmedDisplayName);

    final profile = UserProfile(
      uid: user.uid,
      email: trimmedEmail,
      displayName: trimmedDisplayName,
      country: 'SI',
      language: languageCode,
      allowInternationalTrades: false,
      rating: 0,
      completedTrades: 0,
      createdAt: Timestamp.now(),
    );

    await _firestore.createUserProfile(profile);

    try {
      await user.sendEmailVerification();
    } on FirebaseAuthException {
      // Račun je že uspešno ustvarjen. Uporabnik lahko potrditveno
      // sporočilo ponovno pošlje na zaslonu za potrditev e-pošte.
    }
  }

  Future<void> login({required String email, required String password}) async {
    await _auth.signInWithEmailAndPassword(
      email: normalizeEmailAddress(email),
      password: password,
    );
  }

  Future<void> sendPasswordResetEmail({
    required String email,
    required String languageCode,
  }) async {
    await _auth.setLanguageCode(languageCode);
    await _auth.sendPasswordResetEmail(email: normalizeEmailAddress(email));
  }

  Future<void> sendEmailVerification({required String languageCode}) async {
    final user = _requireUser();

    if (user.emailVerified) {
      return;
    }

    await _auth.setLanguageCode(languageCode);
    await user.sendEmailVerification();
  }

  Future<bool> reloadEmailVerificationStatus() async {
    final user = _requireUser();

    await user.reload();

    return _auth.currentUser?.emailVerified ?? false;
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final user = _requireUser();

    await _reauthenticate(user: user, password: currentPassword);

    await user.updatePassword(newPassword);
  }

  Future<void> deleteAccount({required String password}) async {
    final user = _requireUser();
    final uid = user.uid;

    await _reauthenticate(user: user, password: password);

    if (await _hasActiveTrades(uid)) {
      throw const AccountDeletionBlockedByActiveTradesException();
    }

    await NotificationService.instance.removeCurrentDeviceToken();
    await _deleteUserOwnedFirestoreData(uid);
    await user.delete();
  }

  User _requireUser() {
    final user = _auth.currentUser;

    if (user == null) {
      throw StateError('Uporabnik ni prijavljen.');
    }

    return user;
  }

  Future<void> _reauthenticate({
    required User user,
    required String password,
  }) async {
    final email = normalizeEmailAddress(user.email ?? '');

    if (email.isEmpty) {
      throw StateError('Uporabnik nima e-poštnega naslova.');
    }

    final credential = EmailAuthProvider.credential(
      email: email,
      password: password,
    );

    await user.reauthenticateWithCredential(credential);
  }

  Future<bool> _hasActiveTrades(String userId) async {
    final snapshots = await Future.wait([
      _db.collection('trades').where('senderId', isEqualTo: userId).get(),
      _db.collection('trades').where('receiverId', isEqualTo: userId).get(),
    ]);

    const activeStatuses = {'pending', 'countered', 'accepted'};

    return snapshots
        .expand((snapshot) => snapshot.docs)
        .any(
          (document) =>
              activeStatuses.contains(document.data()['status']?.toString()),
        );
  }

  Future<void> _deleteUserOwnedFirestoreData(String userId) async {
    final userReference = _db.collection('users').doc(userId);
    final collectionSnapshot = await userReference
        .collection('collections')
        .get();

    for (final collectionDocument in collectionSnapshot.docs) {
      await _deleteQueryInBatches(
        collectionDocument.reference.collection('items'),
      );

      await _db
          .collection('collectionMembers')
          .doc(collectionDocument.id)
          .collection('users')
          .doc(userId)
          .delete();

      await collectionDocument.reference.delete();
    }

    await _deleteQueryInBatches(userReference.collection('favorites'));

    // Zgodovina sporočil, menjav in oddanih ocen ostane zaradi integritete
    // zapisov drugih udeležencev. Ker se profil izbriše, se uporabnik v teh
    // zapisih prikaže kot neznan oziroma izbrisan uporabnik.
    await userReference.delete();
  }

  Future<void> _deleteQueryInBatches(Query<Map<String, dynamic>> query) async {
    while (true) {
      final snapshot = await query.limit(200).get();

      if (snapshot.docs.isEmpty) {
        return;
      }

      final batch = _db.batch();

      for (final document in snapshot.docs) {
        batch.delete(document.reference);
      }

      await batch.commit();
    }
  }
}
