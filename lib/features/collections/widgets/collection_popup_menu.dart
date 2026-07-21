import 'package:flutter/material.dart';

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
    return PopupMenuButton<CollectionMenuAction>(
      tooltip: 'Možnosti zbirke',
      onSelected: onSelected,
      itemBuilder: (context) {
        return [
          if (allowEdit)
            const PopupMenuItem(
              value: CollectionMenuAction.edit,
              child: Row(
                children: [
                  Icon(Icons.edit_outlined),
                  SizedBox(width: 8),
                  Text('Uredi'),
                ],
              ),
            ),
          const PopupMenuItem(
            value: CollectionMenuAction.remove,
            child: Row(
              children: [
                Icon(Icons.delete_outline),
                SizedBox(width: 8),
                Text('Odstrani'),
              ],
            ),
          ),
        ];
      },
    );
  }
}
