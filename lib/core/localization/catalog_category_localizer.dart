import 'package:swapstash/l10n/generated/app_localizations.dart';

String localizedCatalogCategory(
  AppLocalizations localizations,
  String category,
) {
  final original = category.trim();

  if (original.isEmpty) {
    return original;
  }

  final normalized = original
      .toLowerCase()
      .replaceAll(RegExp(r'[_-]+'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();

  switch (normalized) {
    case 'sports cards':
    case 'sport cards':
    case 'sports card':
    case 'sports_cards':
    case 'športne kartice':
    case 'sportne kartice':
    case 'sportkarten':
    case 'sportske kartice':
      return localizations.catalogCategorySportsCards;
    default:
      return original;
  }
}
