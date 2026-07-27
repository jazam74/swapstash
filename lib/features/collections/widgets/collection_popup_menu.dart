import 'package:flutter/material.dart';
import 'package:swapstash/l10n/generated/app_localizations.dart';

enum CollectionMenuAction { edit, remove }

class CollectionPopupMenu extends StatelessWidget {
  final ValueChanged<CollectionMenuAction> onSelected;
  final bool allowEdit;

  const CollectionPopupMenu({
    super.key,
    required this.onSelected,
    this.allowEdit = false,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return PopupMenuButton<CollectionMenuAction>(
      tooltip: localizations.myCollectionsMenuTooltip,
      onSelected: onSelected,
      itemBuilder: (context) {
        return [
          if (allowEdit)
            PopupMenuItem(
              value: CollectionMenuAction.edit,
              child: Row(
                children: [
                  const Icon(Icons.edit_outlined),
                  const SizedBox(width: 8),
                  Text(localizations.myCollectionsEditMenu),
                ],
              ),
            ),
          PopupMenuItem(
            value: CollectionMenuAction.remove,
            child: Row(
              children: [
                const Icon(Icons.delete_outline),
                const SizedBox(width: 8),
                Text(localizations.myCollectionsRemoveMenu),
              ],
            ),
          ),
        ];
      },
    );
  }
}
