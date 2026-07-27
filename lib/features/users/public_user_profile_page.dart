import 'package:flutter/material.dart';
import 'package:swapstash/core/models/user_profile.dart';
import 'package:swapstash/core/services/chat_service.dart';
import 'package:swapstash/core/services/firestore_service.dart';
import 'package:swapstash/core/services/block_service.dart';
import 'package:swapstash/features/safety/user_safety_menu.dart';
import 'package:swapstash/features/messages/chat_page.dart';
import 'package:swapstash/features/users/widgets/completed_trades_value.dart';
import 'package:swapstash/features/users/widgets/user_rating_list.dart';
import 'package:swapstash/features/users/widgets/user_rating_summary.dart';
import 'package:swapstash/l10n/generated/app_localizations.dart';

class PublicUserProfilePage extends StatefulWidget {
  final String userId;
  final UserProfile? initialProfile;

  const PublicUserProfilePage({
    super.key,
    required this.userId,
    this.initialProfile,
  });

  @override
  State<PublicUserProfilePage> createState() => _PublicUserProfilePageState();
}

class _PublicUserProfilePageState extends State<PublicUserProfilePage> {
  final FirestoreService _firestoreService = FirestoreService();
  final ChatService _chatService = ChatService();

  bool _openingChat = false;

  Future<void> _openChat(UserProfile profile) async {
    if (_openingChat) {
      return;
    }

    final localizations = AppLocalizations.of(context)!;

    setState(() {
      _openingChat = true;
    });

    try {
      final conversation = await _chatService.getOrCreateConversation(
        collectionId: 'direct_messages',
        collectionName: '',
        otherUserId: profile.uid,
        otherUserName: profile.displayName,
        otherUserPhotoUrl: profile.photoUrl,
      );

      if (!mounted) {
        return;
      }

      await Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => ChatPage(conversation: conversation)),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(localizations.collectorChatOpenError(error.toString())),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _openingChat = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.collectorProfileTitle),
        actions: [UserSafetyMenuButton(otherUserId: widget.userId)],
      ),
      body: StreamBuilder<UserProfile?>(
        stream: _firestoreService.watchUserProfile(widget.userId),
        initialData: widget.initialProfile,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return _ProfileErrorView(error: snapshot.error);
          }

          final profile = snapshot.data;

          if (profile == null) {
            return Center(child: Text(localizations.collectorProfileMissing));
          }

          return StreamBuilder<BlockRelationship>(
            stream: BlockService().watchRelationship(otherUserId: profile.uid),
            initialData: const BlockRelationship.none(),
            builder: (context, relationshipSnapshot) {
              final relationship =
                  relationshipSnapshot.data ?? const BlockRelationship.none();

              return _PublicProfileContent(
                profile: profile,
                openingChat: _openingChat,
                relationship: relationship,
                onOpenChat: () => _openChat(profile),
              );
            },
          );
        },
      ),
    );
  }
}

class _PublicProfileContent extends StatelessWidget {
  final UserProfile profile;
  final bool openingChat;
  final BlockRelationship relationship;
  final VoidCallback onOpenChat;

  const _PublicProfileContent({
    required this.profile,
    required this.openingChat,
    required this.relationship,
    required this.onOpenChat,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final displayName = profile.displayName.trim().isEmpty
        ? localizations.unnamedUser
        : profile.displayName.trim();

    final locationParts = <String>[
      if (profile.city.trim().isNotEmpty) profile.city.trim(),
      if (profile.country.trim().isNotEmpty) profile.country.trim(),
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _ProfileHeader(
          profile: profile,
          displayName: displayName,
          location: profile.isPublic ? locationParts.join(', ') : '',
        ),
        const SizedBox(height: 16),
        _ProfileStatsCard(profile: profile),
        const SizedBox(height: 16),
        if (profile.isPublic) ...[
          if (profile.bio.trim().isNotEmpty)
            _ProfileBioCard(bio: profile.bio.trim()),
          if (profile.bio.trim().isNotEmpty) const SizedBox(height: 16),
          UserRatingList(userId: profile.uid),
        ] else
          const _PrivateProfileNotice(),
        const SizedBox(height: 20),
        if (relationship.isBlocked) ...[
          Card(
            child: ListTile(
              leading: const Icon(Icons.block_outlined),
              title: Text(
                relationship.iBlockedThem
                    ? localizations.safetyProfileBlockedByYou
                    : localizations.safetyProfileBlockedByOther,
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
        FilledButton.icon(
          onPressed: openingChat || relationship.isBlocked ? null : onOpenChat,
          icon: openingChat
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.chat_bubble_outline_rounded),
          label: Text(
            openingChat
                ? localizations.collectorOpeningChat
                : localizations.collectorSendMessage,
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final UserProfile profile;
  final String displayName;
  final String location;

  const _ProfileHeader({
    required this.profile,
    required this.displayName,
    required this.location,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final initial = displayName.isEmpty
        ? '?'
        : displayName.substring(0, 1).toUpperCase();

    return Column(
      children: [
        CircleAvatar(
          radius: 48,
          backgroundImage: profile.photoUrl.trim().isEmpty
              ? null
              : NetworkImage(profile.photoUrl),
          child: profile.photoUrl.trim().isEmpty
              ? Text(initial, style: Theme.of(context).textTheme.headlineMedium)
              : null,
        ),
        const SizedBox(height: 14),
        Text(
          displayName,
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        if (location.isNotEmpty) ...[
          const SizedBox(height: 6),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.location_on_outlined, size: 18),
              const SizedBox(width: 4),
              Flexible(child: Text(location)),
            ],
          ),
        ],
        const SizedBox(height: 8),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          runSpacing: 8,
          children: [
            Chip(
              avatar: Icon(
                profile.isPublic ? Icons.public : Icons.lock_outline,
                size: 18,
              ),
              label: Text(
                profile.isPublic
                    ? localizations.publicProfile
                    : localizations.privateProfile,
              ),
            ),
            Chip(
              avatar: const Icon(Icons.language, size: 18),
              label: Text(
                profile.allowInternationalTrades
                    ? localizations.collectorInternationalTrades
                    : localizations.collectorLocalTrades,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ProfileStatsCard extends StatelessWidget {
  final UserProfile profile;

  const _ProfileStatsCard({required this.profile});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(child: UserRatingSummary(userId: profile.uid)),
            const SizedBox(height: 54, child: VerticalDivider()),
            Expanded(
              child: _ProfileStat(
                icon: Icons.handshake_outlined,
                value: CompletedTradesValue(
                  userId: profile.uid,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
                label: localizations.completedTrades,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileStat extends StatelessWidget {
  final IconData icon;
  final Widget value;
  final String label;

  const _ProfileStat({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon),
        const SizedBox(height: 6),
        value,
        const SizedBox(height: 2),
        Text(
          label,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

class _ProfileBioCard extends StatelessWidget {
  final String bio;

  const _ProfileBioCard({required this.bio});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              localizations.collectorAbout,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            Text(bio),
          ],
        ),
      ),
    );
  }
}

class _PrivateProfileNotice extends StatelessWidget {
  const _PrivateProfileNotice();

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Icon(Icons.lock_outline_rounded, size: 42),
            const SizedBox(height: 12),
            Text(
              localizations.collectorPrivateTitle,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(
              localizations.collectorPrivateDescription,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileErrorView extends StatelessWidget {
  final Object? error;

  const _ProfileErrorView({required this.error});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          localizations.collectorProfileLoadError(error.toString()),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
