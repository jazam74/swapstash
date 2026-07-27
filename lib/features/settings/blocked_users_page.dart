import 'package:flutter/material.dart';
import 'package:swapstash/core/models/blocked_user.dart';
import 'package:swapstash/core/models/user_profile.dart';
import 'package:swapstash/core/services/block_service.dart';
import 'package:swapstash/core/services/firestore_service.dart';
import 'package:swapstash/l10n/generated/app_localizations.dart';

class BlockedUsersPage extends StatelessWidget {
  const BlockedUsersPage({super.key});

  Future<void> _unblock(BuildContext context, String userId) async {
    final localizations = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(localizations.safetyUnblockUserTitle),
        content: Text(localizations.safetyUnblockUserConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(localizations.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(localizations.safetyUnblockUser),
          ),
        ],
      ),
    );

    if (confirmed != true) {
      return;
    }

    await BlockService().unblockUser(userId: userId);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(localizations.safetyUserUnblocked)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(localizations.safetyBlockedUsers)),
      body: StreamBuilder<List<BlockedUser>>(
        stream: BlockService().watchBlockedUsers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  '${localizations.safetyBlockedUsersLoadError}\n'
                  '${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final blockedUsers = snapshot.data ?? const <BlockedUser>[];

          if (blockedUsers.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.person_off_outlined, size: 64),
                    const SizedBox(height: 16),
                    Text(
                      localizations.safetyNoBlockedUsers,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: blockedUsers.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              return _BlockedUserCard(
                blockedUser: blockedUsers[index],
                onUnblock: () => _unblock(context, blockedUsers[index].userId),
              );
            },
          );
        },
      ),
    );
  }
}

class _BlockedUserCard extends StatelessWidget {
  final BlockedUser blockedUser;
  final VoidCallback onUnblock;

  const _BlockedUserCard({required this.blockedUser, required this.onUnblock});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return FutureBuilder<UserProfile?>(
      future: FirestoreService().getUserProfile(blockedUser.userId),
      builder: (context, snapshot) {
        final profile = snapshot.data;
        final name = profile?.displayName.trim();

        return Card(
          margin: EdgeInsets.zero,
          child: ListTile(
            leading: CircleAvatar(
              backgroundImage: profile?.photoUrl.trim().isNotEmpty == true
                  ? NetworkImage(profile!.photoUrl)
                  : null,
              child: profile?.photoUrl.trim().isNotEmpty == true
                  ? null
                  : const Icon(Icons.person_off_outlined),
            ),
            title: Text(
              name == null || name.isEmpty ? localizations.unknownUser : name,
            ),
            subtitle: Text(
              profile?.email.trim().isNotEmpty == true
                  ? profile!.email
                  : blockedUser.userId,
            ),
            trailing: TextButton(
              onPressed: onUnblock,
              child: Text(localizations.safetyUnblockUser),
            ),
          ),
        );
      },
    );
  }
}
