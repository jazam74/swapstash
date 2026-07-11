import 'package:flutter/material.dart';
import 'package:swapstash/core/models/collection.dart';
import 'package:swapstash/core/services/collection_service.dart';

class EditCollectionDialog extends StatefulWidget {
  final Collection collection;

  const EditCollectionDialog({
    super.key,
    required this.collection,
  });

  @override
  State<EditCollectionDialog> createState() =>
      _EditCollectionDialogState();
}

class _EditCollectionDialogState
    extends State<EditCollectionDialog> {
  final CollectionService _collectionService =
      CollectionService();

  late final TextEditingController _nameController;
  late final TextEditingController _publisherController;
  late final TextEditingController _totalItemsController;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(
      text: widget.collection.name,
    );

    _publisherController = TextEditingController(
      text: widget.collection.publisher,
    );

    _totalItemsController = TextEditingController(
      text: widget.collection.totalItems.toString(),
    );
  }

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
    final totalItems = int.tryParse(
      _totalItemsController.text.trim(),
    );

    if (name.isEmpty ||
        publisher.isEmpty ||
        totalItems == null ||
        totalItems <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Izpolni vsa polja pravilno.'),
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      await _collectionService.updateCollection(
        collectionId: widget.collection.id,
        name: name,
        publisher: publisher,
        totalItems: totalItems,
      );

      if (!mounted) return;

      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Zbirke ni bilo mogoče posodobiti: $error',
          ),
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
      title: const Text('Uredi zbirko'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Ime zbirke',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _publisherController,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Založnik',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _totalItemsController,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) {
                if (!_isSaving) {
                  _save();
                }
              },
              decoration: const InputDecoration(
                labelText: 'Število predmetov',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving
              ? null
              : () => Navigator.of(context).pop(false),
          child: const Text('Prekliči'),
        ),
        FilledButton(
          onPressed: _isSaving ? null : _save,
          child: _isSaving
              ? const SizedBox(
                  width: 18,
                  height: 18,
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