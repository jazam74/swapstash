import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:swapstash/core/models/conversation.dart';
import 'package:swapstash/core/services/chat_service.dart';
import 'package:swapstash/features/messages/chat_page.dart';

class MessagesPage extends StatefulWidget {
  final String? initialConversationId;

  const MessagesPage({super.key, this.initialConversationId});

  @override
  State<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  final ChatService _chatService = ChatService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  String _searchQuery = '';
  String? _handledInitialConversationId;
  bool _openingInitialConversation = false;

  String? get _currentUserId => _auth.currentUser?.uid;

  @override
  void didUpdateWidget(covariant MessagesPage oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.initialConversationId != widget.initialConversationId) {
      _handledInitialConversationId = null;
      _openingInitialConversation = false;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  Future<void> _openConversation(Conversation conversation) async {
    _searchFocusNode.unfocus();

    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => ChatPage(conversation: conversation),
      ),
    );
  }

  void _scheduleInitialConversationOpen(List<Conversation> conversations) {
    final conversationId = widget.initialConversationId?.trim() ?? '';

    if (conversationId.isEmpty ||
        _openingInitialConversation ||
        _handledInitialConversationId == conversationId) {
      return;
    }

    Conversation? targetConversation;

    for (final conversation in conversations) {
      if (conversation.id == conversationId) {
        targetConversation = conversation;
        break;
      }
    }

    // The requested conversation may arrive in a later stream snapshot.
    if (targetConversation == null) {
      return;
    }

    _openingInitialConversation = true;
    _handledInitialConversationId = conversationId;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) {
        return;
      }

      try {
        await _openConversation(targetConversation!);
      } finally {
        if (mounted) {
          setState(() {
            _openingInitialConversation = false;
          });
        }
      }
    });
  }

  void _updateSearchQuery(String value) {
    setState(() {
      _searchQuery = value.trim().toLowerCase();
    });
  }

  void _clearSearch() {
    _searchController.clear();
    _updateSearchQuery('');
    _searchFocusNode.unfocus();
  }

  Future<void> _refreshConversations() async {
    setState(() {});
    await Future<void>.delayed(const Duration(milliseconds: 350));
  }

  List<Conversation> _filterConversations(
    List<Conversation> conversations,
    String currentUserId,
  ) {
    if (_searchQuery.isEmpty) {
      return conversations;
    }

    return conversations
        .where((conversation) {
          final otherUserName = conversation
              .otherUserName(currentUserId)
              .trim()
              .toLowerCase();
          final collectionName = conversation.collectionName
              .trim()
              .toLowerCase();
          final lastMessage = conversation.lastMessage.trim().toLowerCase();

          return otherUserName.contains(_searchQuery) ||
              collectionName.contains(_searchQuery) ||
              lastMessage.contains(_searchQuery);
        })
        .toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = _currentUserId;

    return Scaffold(
      appBar: AppBar(title: const Text('Sporočila'), centerTitle: false),
      body: currentUserId == null
          ? const _NotSignedInView()
          : StreamBuilder<List<Conversation>>(
              stream: _chatService.watchConversations(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting &&
                    !snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return _MessagesErrorView(
                    error: snapshot.error,
                    onRetry: _refreshConversations,
                  );
                }

                final conversations = snapshot.data ?? const <Conversation>[];

                _scheduleInitialConversationOpen(conversations);

                final filteredConversations = _filterConversations(
                  conversations,
                  currentUserId,
                );

                return Column(
                  children: [
                    _SearchField(
                      controller: _searchController,
                      focusNode: _searchFocusNode,
                      onChanged: _updateSearchQuery,
                      onClear: _clearSearch,
                    ),
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: _refreshConversations,
                        child: _buildConversationContent(
                          conversations: conversations,
                          filteredConversations: filteredConversations,
                          currentUserId: currentUserId,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }

  Widget _buildConversationContent({
    required List<Conversation> conversations,
    required List<Conversation> filteredConversations,
    required String currentUserId,
  }) {
    if (conversations.isEmpty) {
      return const _EmptyMessagesView();
    }

    if (filteredConversations.isEmpty) {
      return _NoSearchResultsView(query: _searchController.text.trim());
    }

    return ListView.separated(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 24),
      itemCount: filteredConversations.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final conversation = filteredConversations[index];

        return TweenAnimationBuilder<double>(
          key: ValueKey<String>(conversation.id),
          duration: Duration(milliseconds: 180 + (index > 6 ? 6 : index) * 40),
          tween: Tween<double>(begin: 0, end: 1),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(0, 10 * (1 - value)),
                child: child,
              ),
            );
          },
          child: _ConversationCard(
            conversation: conversation,
            currentUserId: currentUserId,
            onTap: () => _openConversation(conversation),
          ),
        );
      },
    );
  }
}

class _SearchField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const _SearchField({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: ValueListenableBuilder<TextEditingValue>(
        valueListenable: controller,
        builder: (context, value, child) {
          return TextField(
            controller: controller,
            focusNode: focusNode,
            onChanged: onChanged,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: 'Išči po uporabniku, zbirki ali sporočilu',
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: value.text.isEmpty
                  ? null
                  : IconButton(
                      tooltip: 'Počisti iskanje',
                      onPressed: onClear,
                      icon: const Icon(Icons.close_rounded),
                    ),
              filled: true,
              fillColor: colorScheme.surfaceContainerHighest.withValues(
                alpha: 0.55,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide(color: colorScheme.primary, width: 1.4),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 14),
            ),
          );
        },
      ),
    );
  }
}

class _ConversationCard extends StatelessWidget {
  final Conversation conversation;
  final String currentUserId;
  final VoidCallback onTap;

  const _ConversationCard({
    required this.conversation,
    required this.currentUserId,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final otherUserName = conversation.otherUserName(currentUserId).trim();
    final displayName = otherUserName.isEmpty
        ? 'Neznan uporabnik'
        : otherUserName;
    final otherUserPhotoUrl = conversation
        .otherUserPhotoUrl(currentUserId)
        .trim();
    final unreadCount = conversation.unreadCountFor(currentUserId);
    final isUnread = unreadCount > 0;
    final isCurrentUserLastSender = conversation.lastSenderId == currentUserId;
    final lastMessage = conversation.lastMessage.trim();
    final collectionName = conversation.collectionId.trim() == 'direct_messages'
        ? ''
        : conversation.collectionName.trim();

    final messagePreview = lastMessage.isEmpty
        ? 'Pogovor še nima sporočil.'
        : isCurrentUserLastSender
        ? 'Ti: $lastMessage'
        : lastMessage;

    return Material(
      color: isUnread
          ? colorScheme.primaryContainer.withValues(alpha: 0.24)
          : colorScheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _ConversationAvatar(
                name: displayName,
                photoUrl: otherUserPhotoUrl,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            displayName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: isUnread
                                  ? FontWeight.w800
                                  : FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _formatConversationTime(conversation),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: isUnread
                                ? colorScheme.primary
                                : colorScheme.onSurfaceVariant,
                            fontWeight: isUnread
                                ? FontWeight.w700
                                : FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    if (collectionName.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      _CollectionLabel(name: collectionName),
                    ],
                    const SizedBox(height: 7),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            messagePreview,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: isUnread
                                  ? colorScheme.onSurface
                                  : colorScheme.onSurfaceVariant,
                              fontWeight: isUnread
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                            ),
                          ),
                        ),
                        if (isUnread) ...[
                          const SizedBox(width: 10),
                          _UnreadBadge(count: unreadCount),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CollectionLabel extends StatelessWidget {
  final String name;

  const _CollectionLabel({required this.name});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      constraints: const BoxConstraints(maxWidth: 220),
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: colorScheme.secondaryContainer.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.labelSmall?.copyWith(
          color: colorScheme.onSecondaryContainer,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _ConversationAvatar extends StatelessWidget {
  final String name;
  final String photoUrl;

  const _ConversationAvatar({required this.name, required this.photoUrl});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final normalizedName = name.trim();
    final initial = normalizedName.isEmpty
        ? '?'
        : normalizedName.substring(0, 1).toUpperCase();

    return CircleAvatar(
      radius: 29,
      backgroundColor: colorScheme.primaryContainer,
      foregroundImage: photoUrl.isEmpty ? null : NetworkImage(photoUrl),
      child: Text(
        initial,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          color: colorScheme.onPrimaryContainer,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _UnreadBadge extends StatelessWidget {
  final int count;

  const _UnreadBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final label = count > 99 ? '99+' : count.toString();

    return Container(
      constraints: const BoxConstraints(minWidth: 22, minHeight: 22),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: colorScheme.primary,
        borderRadius: BorderRadius.circular(999),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: colorScheme.onPrimary,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _EmptyMessagesView extends StatelessWidget {
  const _EmptyMessagesView();

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(32),
      children: [
        const SizedBox(height: 96),
        _StateIcon(icon: Icons.forum_outlined),
        const SizedBox(height: 22),
        Text(
          'Še nimaš pogovorov',
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 10),
        Text(
          'Pogovor lahko začneš pri uporabniku, s katerim želiš opraviti menjavo.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _NoSearchResultsView extends StatelessWidget {
  final String query;

  const _NoSearchResultsView({required this.query});

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(32),
      children: [
        const SizedBox(height: 96),
        const _StateIcon(icon: Icons.search_off_rounded),
        const SizedBox(height: 22),
        Text(
          'Ni zadetkov',
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 10),
        Text(
          query.isEmpty
              ? 'Poskusi z drugim iskalnim izrazom.'
              : 'Za »$query« ni bilo najdenih pogovorov.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _MessagesErrorView extends StatelessWidget {
  final Object? error;
  final Future<void> Function() onRetry;

  const _MessagesErrorView({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const _StateIcon(icon: Icons.error_outline_rounded),
            const SizedBox(height: 22),
            Text(
              'Pogovorov ni bilo mogoče naložiti',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              '$error',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Poskusi znova'),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotSignedInView extends StatelessWidget {
  const _NotSignedInView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const _StateIcon(icon: Icons.lock_outline_rounded),
            const SizedBox(height: 20),
            Text(
              'Za ogled sporočil se moraš prijaviti.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class _StateIcon extends StatelessWidget {
  final IconData icon;

  const _StateIcon({required this.icon});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: 88,
      height: 88,
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withValues(alpha: 0.65),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Icon(icon, size: 42, color: colorScheme.onPrimaryContainer),
    );
  }
}

String _formatConversationTime(Conversation conversation) {
  final timestamp = conversation.lastMessageAt ?? conversation.createdAt;
  final dateTime = timestamp.toDate().toLocal();
  final now = DateTime.now();
  final difference = now.difference(dateTime);

  if (!difference.isNegative && difference.inMinutes < 1) {
    return 'Zdaj';
  }

  if (!difference.isNegative && difference.inMinutes < 60) {
    return '${difference.inMinutes} min';
  }

  if (!difference.isNegative && difference.inHours < 6) {
    return '${difference.inHours} h';
  }

  final today = DateTime(now.year, now.month, now.day);
  final messageDay = DateTime(dateTime.year, dateTime.month, dateTime.day);
  final dayDifference = today.difference(messageDay).inDays;

  if (dayDifference == 0) {
    return '${_twoDigits(dateTime.hour)}:${_twoDigits(dateTime.minute)}';
  }

  if (dayDifference == 1) {
    return 'Včeraj';
  }

  if (dayDifference > 1 && dayDifference < 7) {
    return _weekdayName(dateTime.weekday);
  }

  if (dateTime.year == now.year) {
    return '${dateTime.day}. ${dateTime.month}.';
  }

  return '${dateTime.day}. ${dateTime.month}. ${dateTime.year}';
}

String _twoDigits(int value) => value.toString().padLeft(2, '0');

String _weekdayName(int weekday) {
  switch (weekday) {
    case DateTime.monday:
      return 'Pon';
    case DateTime.tuesday:
      return 'Tor';
    case DateTime.wednesday:
      return 'Sre';
    case DateTime.thursday:
      return 'Čet';
    case DateTime.friday:
      return 'Pet';
    case DateTime.saturday:
      return 'Sob';
    case DateTime.sunday:
      return 'Ned';
    default:
      return '';
  }
}
