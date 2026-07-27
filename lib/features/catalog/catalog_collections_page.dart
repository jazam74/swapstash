import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:swapstash/core/models/catalog_collection.dart';
import 'package:swapstash/core/models/user_collection.dart';
import 'package:swapstash/core/services/catalog_service.dart';
import 'package:swapstash/core/services/firestore_service.dart';
import 'package:swapstash/features/catalog/import/catalog_import_page.dart';
import 'package:swapstash/l10n/generated/app_localizations.dart';

class CatalogCollectionsPage extends StatefulWidget {
  const CatalogCollectionsPage({super.key});

  @override
  State<CatalogCollectionsPage> createState() => _CatalogCollectionsPageState();
}

class _CatalogCollectionsPageState extends State<CatalogCollectionsPage> {
  final CatalogService _catalogService = CatalogService();
  final FirestoreService _firestoreService = FirestoreService();

  final Set<String> _savingCollectionIds = {};

  Future<void> _addCollection(CatalogCollection collection) async {
    if (_savingCollectionIds.contains(collection.id)) {
      return;
    }

    setState(() {
      _savingCollectionIds.add(collection.id);
    });

    try {
      await _firestoreService.addCollectionToUser(
        UserCollection(
          catalogCollectionId: collection.id,
          createdAt: Timestamp.now(),
        ),
      );

      if (!mounted) {
        return;
      }

      final localizations = AppLocalizations.of(context)!;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(localizations.catalogCollectionAdded(collection.name)),
        ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      final localizations = AppLocalizations.of(context)!;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            localizations.catalogCollectionAddError(error.toString()),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _savingCollectionIds.remove(collection.id);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.catalogCollectionsTitle),
        actions: [
          IconButton(
            tooltip: localizations.catalogImportFileTooltip,
            icon: const Icon(Icons.upload_file_outlined),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const CatalogImportPage()),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<List<CatalogCollection>>(
        stream: _catalogService.watchActiveCollections(),
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
                  localizations.catalogLoadErrorDetails(
                    snapshot.error.toString(),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final collections = snapshot.data ?? [];

          if (collections.isEmpty) {
            return Center(child: Text(localizations.catalogNoCollectionsFound));
          }

          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: collections.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final collection = collections[index];
              final isSaving = _savingCollectionIds.contains(collection.id);

              final publisherInitial = collection.publisher.trim().isEmpty
                  ? '?'
                  : collection.publisher.trim().characters.first.toUpperCase();

              return ListTile(
                leading: CircleAvatar(child: Text(publisherInitial)),
                title: Text(collection.name),
                subtitle: Text(
                  '${collection.publisher} • '
                  '${collection.year} • '
                  '${localizations.catalogItemsCount(collection.totalItems)}',
                ),
                trailing: isSaving
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.add_circle_outline),
                onTap: isSaving ? null : () => _addCollection(collection),
              );
            },
          );
        },
      ),
    );
  }
}
