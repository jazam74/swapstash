import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:swapstash/core/models/chat_message.dart';

class MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final String currentUserId;

  const MessageBubble({
    super.key,
    required this.message,
    required this.currentUserId,
  });

  @override
  Widget build(BuildContext context) {
    final isMine = message.isMine(currentUserId);
    final colorScheme = Theme.of(context).colorScheme;

    final bubbleColor = isMine
        ? colorScheme.primaryContainer
        : colorScheme.surfaceContainerHighest;

    final textColor = isMine
        ? colorScheme.onPrimaryContainer
        : colorScheme.onSurfaceVariant;

    final time = DateFormat('HH:mm').format(message.createdAt.toDate());

    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.78,
        ),
        margin: EdgeInsets.only(
          left: isMine ? 56 : 8,
          right: isMine ? 8 : 56,
          top: 4,
          bottom: 4,
        ),
        padding: const EdgeInsets.fromLTRB(14, 10, 10, 6),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(isMine ? 18 : 4),
            bottomRight: Radius.circular(isMine ? 4 : 18),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                message.text,
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: textColor),
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  time,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: textColor.withValues(alpha: 0.7),
                  ),
                ),
                if (isMine) ...[
                  const SizedBox(width: 4),
                  Icon(
                    message.readBy.length > 1 ? Icons.done_all : Icons.done,
                    size: 15,
                    color: textColor.withValues(alpha: 0.7),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
