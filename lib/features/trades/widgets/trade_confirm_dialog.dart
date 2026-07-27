import 'package:flutter/material.dart';
import 'package:swapstash/l10n/generated/app_localizations.dart';

abstract final class TradeConfirmDialog {
  static Future<bool> confirmHandover(BuildContext context) async {
    final localizations = AppLocalizations.of(context)!;

    return await showDialog<bool>(
          context: context,
          builder: (dialogContext) {
            return AlertDialog(
              icon: const Icon(Icons.how_to_reg_outlined),
              title: Text(localizations.tradeConfirmHandoverTitle),
              content: Text(localizations.tradeConfirmHandoverDescription),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: Text(localizations.cancel),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(dialogContext).pop(true),
                  child: Text(localizations.tradeConfirmHandoverButton),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  static Future<bool> confirmReceipt(BuildContext context) async {
    final localizations = AppLocalizations.of(context)!;

    return await showDialog<bool>(
          context: context,
          builder: (dialogContext) {
            return AlertDialog(
              icon: const Icon(Icons.inventory_2_outlined),
              title: Text(localizations.tradeConfirmReceiptTitle),
              content: Text(localizations.tradeConfirmReceiptDescription),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: Text(localizations.cancel),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(dialogContext).pop(true),
                  child: Text(localizations.tradeConfirmReceiptButton),
                ),
              ],
            );
          },
        ) ??
        false;
  }
}
