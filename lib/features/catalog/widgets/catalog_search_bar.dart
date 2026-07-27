import 'package:flutter/material.dart';
import 'package:swapstash/l10n/generated/app_localizations.dart';

class CatalogSearchBar extends StatelessWidget {
  final ValueChanged<String> onChanged;

  const CatalogSearchBar({super.key, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
      child: TextField(
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.search),
          hintText: localizations.catalogSearchHint,
          border: const OutlineInputBorder(),
        ),
        onChanged: onChanged,
      ),
    );
  }
}
