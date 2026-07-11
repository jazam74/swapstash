import 'package:flutter/material.dart';
import 'package:swapstash/core/services/collection_service.dart';

class AddCollectionDialog extends StatefulWidget {
  const AddCollectionDialog({super.key});

  @override
  State<AddCollectionDialog> createState() =>
      _AddCollectionDialogState();
}

class _AddCollectionDialogState extends State<AddCollectionDialog> {
  final _nameController = TextEditingController();
  final _publisherController = TextEditingController();
  final _totalItemsController = TextEditingController();
  final CollectionService _collectionService = CollectionService();

  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _publisherController.dispose();
    _totalItemsController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    final publisher = _publisherController.text.trim();
    final totalItems =
        int.tryParse(_totalItemsController.text.trim());

    if (name.isEmpty ||
        publisher.isEmpty ||
        totalItems == null ||
        totalItems <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Izpolni vsa polja.'),
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      await _collectionService.addCollection(
        name: name,
        publisher: publisher,
        totalItems: totalItems,
      );

      if (!mounted) return;

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Napaka: $e'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Dodaj zbirko'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Ime zbirke',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _publisherController,
              decoration: const InputDecoration(
                labelText: 'Založnik',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _totalItemsController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Število predmetov',
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed:
              _isSaving ? null : () => Navigator.pop(context),
          child: const Text('Prekliči'),
        ),
        FilledButton(
          onPressed: _isSaving ? null : _save,
          child: _isSaving
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                )
              : const Text('Shrani'),
        ),
      ],
    );
  }
}