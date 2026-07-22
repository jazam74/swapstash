import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:swapstash/core/models/chat_message.dart';
import 'package:swapstash/core/models/conversation.dart';
import 'package:swapstash/core/services/chat_service.dart';
import 'package:swapstash/features/messages/widgets/message_bubble.dart';
import 'package:swapstash/features/messages/widgets/message_input.dart';

class ChatPage extends StatefulWidget {
  final Conversation conversation;

  const ChatPage({super.key, required this.conversation});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final ChatService _chatService = ChatService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _currentUserId {
    final user = _auth.currentUser;

    if (user == null) {
      throw StateError('Uporabnik ni prijavljen.');
    }

    return user.uid;
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _markAsRead();
    });
  }

  Future<void> _markAsRead() async {
    try {
      await _chatService.markConversationRead(
        conversationId: widget.conversation.id,
      );
    } catch (_) {
      // Branje pogovora ne sme zapreti zaslona,
      // če označevanje sporočil kot prebranih ne uspe.
    }
  }

  Future<void> _sendMessage(String text) async {
    try {
      await _chatService.sendMessage(
        conversationId: widget.conversation.id,
        text: text,
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sporočila ni bilo mogoče poslati:\n$error')),
      );

      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = _currentUserId;
    final otherUserName = widget.conversation.otherUserName(currentUserId);
    final isDirectConversation =
        widget.conversation.collectionId.trim() == 'direct_messages';

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            _ConversationAvatar(
              conversation: widget.conversation,
              currentUserId: currentUserId,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    otherUserName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (!isDirectConversation &&
                      widget.conversation.collectionName.trim().isNotEmpty)
                    Text(
                      widget.conversation.collectionName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<ChatMessage>>(
              stream: _chatService.watchMessages(
                conversationId: widget.conversation.id,
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting &&
                    !snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return _ChatErrorView(error: snapshot.error);
                }

                final messages = snapshot.data ?? <ChatMessage>[];

                if (messages.isEmpty) {
                  return _EmptyChatView(
                    otherUserName: otherUserName,
                    collectionName: isDirectConversation
                        ? ''
                        : widget.conversation.collectionName,
                  );
                }

                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _markAsRead();
                });

                return ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    return MessageBubble(
                      message: messages[index],
                      currentUserId: currentUserId,
                    );
                  },
                );
              },
            ),
          ),
          const Divider(height: 1),
          MessageInput(onSend: _sendMessage),
        ],
      ),
    );
  }
}

class _ConversationAvatar extends StatelessWidget {
  final Conversation conversation;
  final String currentUserId;

  const _ConversationAvatar({
    required this.conversation,
    required this.currentUserId,
  });

  @override
  Widget build(BuildContext context) {
    final name = conversation.otherUserName(currentUserId).trim();

    final photoUrl = conversation.otherUserPhotoUrl(currentUserId).trim();

    final initial = name.isEmpty ? '?' : name.substring(0, 1).toUpperCase();

    return CircleAvatar(
      backgroundImage: photoUrl.isEmpty ? null : NetworkImage(photoUrl),
      child: photoUrl.isEmpty ? Text(initial) : null,
    );
  }
}

class _EmptyChatView extends StatelessWidget {
  final String otherUserName;
  final String collectionName;

  const _EmptyChatView({
    required this.otherUserName,
    required this.collectionName,
  });

  @override
  Widget build(BuildContext context) {
    final normalizedName = otherUserName.trim().isEmpty
        ? 'uporabnikom'
        : otherUserName.trim();

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.chat_bubble_outline, size: 64),
            const SizedBox(height: 16),
            Text(
              'Začni pogovor z $normalizedName',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            if (collectionName.trim().isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Pogovor se nanaša na zbirko $collectionName.',
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 12),
            const Text(
              'Napiši prvo sporočilo in se dogovorita za menjavo.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatErrorView extends StatelessWidget {
  final Object? error;

  const _ChatErrorView({required this.error});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 56),
            const SizedBox(height: 16),
            const Text(
              'Sporočil ni bilo mogoče naložiti.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              '$error',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
