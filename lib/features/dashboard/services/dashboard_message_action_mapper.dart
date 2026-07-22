import 'package:flutter/material.dart';
import 'package:swapstash/core/models/conversation.dart';
import 'package:swapstash/core/theme/app_colors.dart';
import 'package:swapstash/features/dashboard/models/dashboard_action.dart';

abstract final class DashboardMessageActionMapper {
  static List<DashboardAction> build({
    required List<Conversation> conversations,
    required String currentUserId,
    int limit = 50,
  }) {
    final actions = <DashboardAction>[];

    for (final conversation in conversations) {
      final unreadCount = conversation.unreadCountFor(currentUserId);

      if (unreadCount <= 0) {
        continue;
      }

      final otherUserName = conversation.otherUserName(currentUserId).trim();
      final collectionName = conversation.collectionName.trim();
      final lastMessage = conversation.lastMessage.trim();

      final details = <String>[
        if (otherUserName.isNotEmpty) otherUserName,
        if (collectionName.isNotEmpty) collectionName,
      ];

      final subtitle = details.isNotEmpty
          ? details.join(' • ')
          : lastMessage.isNotEmpty
          ? lastMessage
          : 'Odpri pogovor in preberi nova sporočila.';

      actions.add(
        DashboardAction(
          icon: Icons.mark_chat_unread_outlined,
          color: AppColors.primary,
          title: unreadCount == 1
              ? '1 neprebrano sporočilo'
              : '$unreadCount neprebranih sporočil',
          subtitle: subtitle,
          conversationId: conversation.id,
          priority: 1,
          sortAt: (conversation.lastMessageAt ?? conversation.createdAt)
              .toDate(),
        ),
      );
    }

    actions.sort((first, second) {
      final firstDate = first.sortAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final secondDate =
          second.sortAt ?? DateTime.fromMillisecondsSinceEpoch(0);

      return secondDate.compareTo(firstDate);
    });

    return actions.take(limit).toList(growable: false);
  }
}
