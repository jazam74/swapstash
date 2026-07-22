import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:swapstash/core/models/chat_message.dart';
import 'package:swapstash/core/models/conversation.dart';
import 'package:swapstash/core/models/user_profile.dart';
import 'package:swapstash/core/services/firestore_service.dart';

class ChatService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreService _firestoreService = FirestoreService();

  User get _currentUser {
    final user = _auth.currentUser;

    if (user == null) {
      throw StateError('Uporabnik ni prijavljen.');
    }

    return user;
  }

  String get _currentUserId => _currentUser.uid;

  String get currentUserId => _currentUserId;

  CollectionReference<Map<String, dynamic>> get _conversationsReference {
    return _db.collection('conversations');
  }

  String createConversationId({
    required String collectionId,
    required String firstUserId,
    required String secondUserId,
  }) {
    final normalizedCollectionId = collectionId.trim();
    final userIds = [firstUserId.trim(), secondUserId.trim()]..sort();

    if (normalizedCollectionId.isEmpty) {
      throw ArgumentError('ID zbirke ne sme biti prazen.');
    }

    if (userIds.any((id) => id.isEmpty)) {
      throw ArgumentError('ID uporabnika ne sme biti prazen.');
    }

    if (userIds[0] == userIds[1]) {
      throw ArgumentError('Pogovora ni mogoče ustvariti s samim seboj.');
    }

    return '${normalizedCollectionId}_${userIds[0]}_${userIds[1]}';
  }

  String _resolveCurrentUserName({
    required User firebaseUser,
    required UserProfile? profile,
  }) {
    final profileName = profile?.displayName.trim() ?? '';

    if (profileName.isNotEmpty) {
      return profileName;
    }

    final authName = firebaseUser.displayName?.trim() ?? '';

    if (authName.isNotEmpty) {
      return authName;
    }

    final email = firebaseUser.email?.trim() ?? '';

    if (email.isNotEmpty && email.contains('@')) {
      return email.split('@').first;
    }

    return 'Uporabnik';
  }

  Future<Conversation> getOrCreateConversation({
    required String collectionId,
    required String collectionName,
    required String otherUserId,
    required String otherUserName,
    required String otherUserPhotoUrl,
  }) async {
    final firebaseUser = _currentUser;
    final currentUserId = firebaseUser.uid;
    final candidateUserId = otherUserId.trim();

    if (candidateUserId.isEmpty) {
      throw ArgumentError('ID drugega uporabnika ne sme biti prazen.');
    }

    final normalizedOtherUserName = otherUserName.trim().isEmpty
        ? 'Uporabnik'
        : otherUserName.trim();

    final normalizedOtherUserPhotoUrl = otherUserPhotoUrl.trim();

    final UserProfile? currentProfile = await _firestoreService.getUserProfile(
      currentUserId,
    );

    final currentUserName = _resolveCurrentUserName(
      firebaseUser: firebaseUser,
      profile: currentProfile,
    );

    final currentUserPhotoUrl = currentProfile?.photoUrl.trim() ?? '';

    final conversationId = createConversationId(
      collectionId: collectionId,
      firstUserId: currentUserId,
      secondUserId: candidateUserId,
    );

    final reference = _conversationsReference.doc(conversationId);

    final existingDocument = await reference.get();
    final existingData = existingDocument.data();

    if (existingDocument.exists && existingData != null) {
      await reference.set({
        'participantNames': {
          currentUserId: currentUserName,
          candidateUserId: normalizedOtherUserName,
        },
        'participantPhotoUrls': {
          currentUserId: currentUserPhotoUrl,
          candidateUserId: normalizedOtherUserPhotoUrl,
        },
        'collectionName': collectionName.trim(),
      }, SetOptions(merge: true));

      final refreshedDocument = await reference.get();
      final refreshedData = refreshedDocument.data();

      if (refreshedData == null) {
        throw StateError('Podatkov pogovora ni bilo mogoče prebrati.');
      }

      return Conversation.fromMap(refreshedDocument.id, refreshedData);
    }

    final now = Timestamp.now();

    final conversation = Conversation(
      id: conversationId,
      participantIds: [currentUserId, candidateUserId],
      participantNames: {
        currentUserId: currentUserName,
        candidateUserId: normalizedOtherUserName,
      },
      participantPhotoUrls: {
        currentUserId: currentUserPhotoUrl,
        candidateUserId: normalizedOtherUserPhotoUrl,
      },
      collectionId: collectionId.trim(),
      collectionName: collectionName.trim(),
      lastMessage: '',
      lastMessageAt: null,
      lastSenderId: '',
      unreadCounts: {currentUserId: 0, candidateUserId: 0},
      createdAt: now,
    );

    await reference.set(conversation.toMap());

    return conversation;
  }

  Stream<List<Conversation>> watchConversations() {
    final currentUserId = _currentUserId;

    return _conversationsReference
        .where('participantIds', arrayContains: currentUserId)
        .orderBy('lastMessageAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (document) =>
                    Conversation.fromMap(document.id, document.data()),
              )
              .toList(),
        );
  }

  Stream<int> watchTotalUnreadCount() {
    final currentUserId = _auth.currentUser?.uid;

    if (currentUserId == null) {
      return Stream<int>.value(0);
    }

    return watchConversations().map((conversations) {
      var totalUnreadCount = 0;

      for (final conversation in conversations) {
        totalUnreadCount += conversation.unreadCountFor(currentUserId);
      }

      return totalUnreadCount;
    }).distinct();
  }

  Stream<List<ChatMessage>> watchMessages({required String conversationId}) {
    final id = conversationId.trim();

    if (id.isEmpty) {
      return Stream<List<ChatMessage>>.value(const []);
    }

    return _conversationsReference
        .doc(id)
        .collection('messages')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (document) => ChatMessage.fromMap(document.id, document.data()),
              )
              .toList(),
        );
  }

  Future<void> sendMessage({
    required String conversationId,
    required String text,
  }) async {
    final currentUserId = _currentUserId;
    final normalizedText = text.trim();
    final normalizedConversationId = conversationId.trim();

    if (normalizedConversationId.isEmpty) {
      throw ArgumentError('ID pogovora ne sme biti prazen.');
    }

    if (normalizedText.isEmpty) {
      throw ArgumentError('Sporočilo ne sme biti prazno.');
    }

    final conversationReference = _conversationsReference.doc(
      normalizedConversationId,
    );

    final conversationDocument = await conversationReference.get();
    final conversationData = conversationDocument.data();

    if (!conversationDocument.exists || conversationData == null) {
      throw StateError('Pogovor ne obstaja.');
    }

    final conversation = Conversation.fromMap(
      conversationDocument.id,
      conversationData,
    );

    if (!conversation.participantIds.contains(currentUserId)) {
      throw StateError('Nimaš dostopa do tega pogovora.');
    }

    final otherUserId = conversation.otherUserId(currentUserId);

    if (otherUserId.isEmpty) {
      throw StateError('Sogovornik ni bil najden.');
    }

    final messageReference = conversationReference.collection('messages').doc();
    final now = Timestamp.now();

    final message = ChatMessage(
      id: messageReference.id,
      senderId: currentUserId,
      text: normalizedText,
      createdAt: now,
      readBy: [currentUserId],
    );

    final batch = _db.batch();

    batch.set(messageReference, message.toMap());

    batch.update(conversationReference, {
      'lastMessage': normalizedText,
      'lastMessageAt': now,
      'lastSenderId': currentUserId,
      'unreadCounts.$currentUserId': 0,
      'unreadCounts.$otherUserId': FieldValue.increment(1),
    });

    await batch.commit();
  }

  Future<void> markConversationRead({required String conversationId}) async {
    final currentUserId = _currentUserId;
    final normalizedConversationId = conversationId.trim();

    if (normalizedConversationId.isEmpty) {
      return;
    }

    final conversationReference = _conversationsReference.doc(
      normalizedConversationId,
    );

    await conversationReference.update({'unreadCounts.$currentUserId': 0});

    final messagesSnapshot = await conversationReference
        .collection('messages')
        .get();

    if (messagesSnapshot.docs.isEmpty) {
      return;
    }

    final batch = _db.batch();

    for (final document in messagesSnapshot.docs) {
      final readBy = List<String>.from(
        document.data()['readBy'] ?? const <String>[],
      );

      if (!readBy.contains(currentUserId)) {
        batch.update(document.reference, {
          'readBy': FieldValue.arrayUnion([currentUserId]),
        });
      }
    }

    await batch.commit();
  }

  Future<Conversation?> getConversation({
    required String conversationId,
  }) async {
    final id = conversationId.trim();

    if (id.isEmpty) {
      return null;
    }

    final document = await _conversationsReference.doc(id).get();

    final data = document.data();

    if (!document.exists || data == null) {
      return null;
    }

    return Conversation.fromMap(document.id, data);
  }
}
