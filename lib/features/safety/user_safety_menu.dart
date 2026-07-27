import 'package:flutter/material.dart';
import 'package:swapstash/core/models/safety_report.dart';
import 'package:swapstash/core/services/block_service.dart';
import 'package:swapstash/features/safety/report_dialog.dart';
import 'package:swapstash/l10n/generated/app_localizations.dart';

enum _UserSafetyAction { block, unblock, report }

class UserSafetyMenuButton extends StatelessWidget {
  final String otherUserId;

  const UserSafetyMenuButton({super.key, required this.otherUserId});

  Future<void> _handleAction(
    BuildContext context,
    _UserSafetyAction action,
    BlockRelationship relationship,
  ) async {
    final localizations = AppLocalizations.of(context)!;
    final blockService = BlockService();

    switch (action) {
      case _UserSafetyAction.block:
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: Text(localizations.safetyBlockUserTitle),
            content: Text(localizations.safetyBlockUserConfirmation),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: Text(localizations.cancel),
              ),
              FilledButton(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                child: Text(localizations.safetyBlockUser),
              ),
            ],
          ),
        );

        if (confirmed != true) {
          return;
        }

        await blockService.blockUser(userId: otherUserId);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(localizations.safetyUserBlocked)),
          );
        }

        return;

      case _UserSafetyAction.unblock:
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

        await blockService.unblockUser(userId: otherUserId);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(localizations.safetyUserUnblocked)),
          );
        }

        return;

      case _UserSafetyAction.report:
        await showSafetyReportDialog(
          context: context,
          reportedUserId: otherUserId,
          targetType: SafetyReportType.user,
          targetId: otherUserId,
        );

        return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return StreamBuilder<BlockRelationship>(
      stream: BlockService().watchRelationship(otherUserId: otherUserId),
      initialData: const BlockRelationship.none(),
      builder: (context, snapshot) {
        final relationship = snapshot.data ?? const BlockRelationship.none();

        return PopupMenuButton<_UserSafetyAction>(
          tooltip: localizations.safetyMenu,
          onSelected: (action) async {
            try {
              await _handleAction(context, action, relationship);
            } catch (error) {
              if (!context.mounted) {
                return;
              }

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${localizations.safetyActionError}: $error'),
                ),
              );
            }
          },
          itemBuilder: (context) => [
            if (relationship.iBlockedThem)
              PopupMenuItem(
                value: _UserSafetyAction.unblock,
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.person_add_alt_1_outlined),
                  title: Text(localizations.safetyUnblockUser),
                ),
              )
            else if (!relationship.theyBlockedMe)
              PopupMenuItem(
                value: _UserSafetyAction.block,
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.block_outlined),
                  title: Text(localizations.safetyBlockUser),
                ),
              ),
            PopupMenuItem(
              value: _UserSafetyAction.report,
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.flag_outlined),
                title: Text(localizations.safetyReportUser),
              ),
            ),
          ],
        );
      },
    );
  }
}
