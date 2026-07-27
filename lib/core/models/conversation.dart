import 'package:cloud_firestore/cloud_firestore.dart';

class Conversation {
  final String id;
  final List<String> participantIds;
  final Map<String, String> participantNames;
  final Map<String, String> participantPhotoUrls;

  final String collectionId;
  final String collectionName;

  final String lastMessage;
  final Timestamp? lastMessageAt;
  final String lastSenderId;

  final Map<String, int> unreadCounts;
  final Timestamp createdAt;

  const Conversation({
    required this.id,
    required this.participantIds,
    required this.participantNames,
    required this.participantPhotoUrls,
    required this.collectionId,
    required this.collectionName,
    required this.lastMessage,
    required this.lastMessageAt,
    required this.lastSenderId,
    required this.unreadCounts,
    required this.createdAt,
  });

  factory Conversation.fromMap(String id, Map<String, dynamic> map) {
    final rawNames = Map<String, dynamic>.from(map['participantNames'] ?? {});

    final rawPhotos = Map<String, dynamic>.from(
      map['participantPhotoUrls'] ?? {},
    );

    final rawUnread = Map<String, dynamic>.from(map['unreadCounts'] ?? {});

    return Conversation(
      id: id,
      participantIds: List<String>.from(
        map['participantIds'] ?? const <String>[],
      ),
      participantNames: rawNames.map(
        (key, value) => MapEntry(key, value?.toString() ?? ''),
      ),
      participantPhotoUrls: rawPhotos.map(
        (key, value) => MapEntry(key, value?.toString() ?? ''),
      ),
      collectionId: map['collectionId']?.toString() ?? '',
      collectionName: map['collectionName']?.toString() ?? '',
      lastMessage: map['lastMessage']?.toString() ?? '',
      lastMessageAt: map['lastMessageAt'] as Timestamp?,
      lastSenderId: map['lastSenderId']?.toString() ?? '',
      unreadCounts: rawUnread.map(
        (key, value) => MapEntry(key, (value as num?)?.toInt() ?? 0),
      ),
      createdAt: map['createdAt'] as Timestamp? ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'participantIds': participantIds,
      'participantNames': participantNames,
      'participantPhotoUrls': participantPhotoUrls,
      'collectionId': collectionId,
      'collectionName': collectionName,
      'lastMessage': lastMessage,
      'lastMessageAt': lastMessageAt,
      'lastSenderId': lastSenderId,
      'unreadCounts': unreadCounts,
      'createdAt': createdAt,
    };
  }

  String otherUserId(String currentUserId) {
    for (final participantId in participantIds) {
      if (participantId != currentUserId) {
        return participantId;
      }
    }

    return '';
  }

  String otherUserName(String currentUserId) {
    final userId = otherUserId(currentUserId);

    if (userId.isEmpty) {
      return '';
    }

    return participantNames[userId]?.trim() ?? '';
  }

  String otherUserPhotoUrl(String currentUserId) {
    final userId = otherUserId(currentUserId);

    if (userId.isEmpty) {
      return '';
    }

    return participantPhotoUrls[userId]?.trim() ?? '';
  }

  int unreadCountFor(String userId) {
    return unreadCounts[userId] ?? 0;
  }
}
