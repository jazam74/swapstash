import 'package:flutter/material.dart';

abstract final class TradeConfirmDialog {
  static Future<bool> confirmHandover(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (dialogContext) {
            return AlertDialog(
              icon: const Icon(Icons.how_to_reg_outlined),
              title: const Text('Potrdi predajo kartic'),
              content: const Text(
                'Potrdi šele, ko si kartice dejansko predal drugi strani. '
                'Po potrditvi bodo kartice odstranjene iz tvojega inventarja. '
                'Tega koraka ni mogoče razveljaviti.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: const Text('Prekliči'),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(dialogContext).pop(true),
                  child: const Text('Da, potrjujem predajo'),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  static Future<bool> confirmReceipt(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (dialogContext) {
            return AlertDialog(
              icon: const Icon(Icons.inventory_2_outlined),
              title: const Text('Potrdi prejem kartic'),
              content: const Text(
                'Potrdi šele, ko si dogovorjene kartice dejansko prejel. '
                'Po potrditvi bodo dodane v tvoj inventar. '
                'Tega koraka ni mogoče razveljaviti.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: const Text('Prekliči'),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(dialogContext).pop(true),
                  child: const Text('Da, potrjujem prejem'),
                ),
              ],
            );
          },
        ) ??
        false;
  }
}
