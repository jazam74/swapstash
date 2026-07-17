import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessage {
  final String id;
  final String senderId;
  final String text;
  final Timestamp createdAt;
  final List<String> readBy;

  const ChatMessage({
    required this.id,
    required this.senderId,
    required this.text,
    required this.createdAt,
    required this.readBy,
  });

  factory ChatMessage.fromMap(String id, Map<String, dynamic> map) {
    return ChatMessage(
      id: id,
      senderId: map['senderId']?.toString() ?? '',
      text: map['text']?.toString() ?? '',
      createdAt: map['createdAt'] as Timestamp? ?? Timestamp.now(),
      readBy: List<String>.from(map['readBy'] ?? const <String>[]),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'text': text,
      'createdAt': createdAt,
      'readBy': readBy,
    };
  }

  bool isMine(String currentUserId) {
    return senderId == currentUserId;
  }

  bool isReadBy(String userId) {
    return readBy.contains(userId);
  }
}
