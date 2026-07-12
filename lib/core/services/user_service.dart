import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:swapstash/core/models/app_user.dart';

class UserService {
  final FirebaseFirestore _db =
      FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>>
      get _users =>
          _db.collection('users');

  Future<void> saveUser(AppUser user) async {
    await _users.doc(user.uid).set(
          user.toMap(),
          SetOptions(merge: true),
        );
  }

  Future<AppUser?> getUser(String uid) async {
    final snapshot = await _users.doc(uid).get();

    if (!snapshot.exists) {
      return null;
    }

    return AppUser.fromMap(
      snapshot.id,
      snapshot.data()!,
    );
  }

  Stream<AppUser?> watchUser(String uid) {
    return _users.doc(uid).snapshots().map(
      (snapshot) {
        if (!snapshot.exists) {
          return null;
        }

        return AppUser.fromMap(
          snapshot.id,
          snapshot.data()!,
        );
      },
    );
  }

  Future<List<AppUser>> searchUsers(
    String query,
  ) async {
    final value = query.trim();

    if (value.isEmpty) {
      return [];
    }

    final snapshot = await _users
        .orderBy('displayName')
        .startAt([value])
        .endAt(['$value\uf8ff'])
        .limit(20)
        .get();

    return snapshot.docs
        .map(
          (doc) => AppUser.fromMap(
            doc.id,
            doc.data(),
          ),
        )
        .toList();
  }
}