import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:swapstash/core/models/catalog_collection.dart';
import 'package:swapstash/core/services/catalog_item_service.dart';
import 'package:swapstash/core/services/catalog_service.dart';
import 'package:swapstash/features/catalog/import/catalog_import_parser.dart';
import 'package:swapstash/l10n/generated/app_localizations.dart';

class CatalogImportPage extends StatefulWidget {
  const CatalogImportPage({super.key});

  @override
  State<CatalogImportPage> createState() => _CatalogImportPageState();
}

class _CatalogImportPageState extends State<CatalogImportPage> {
  static const int _maximumFileSize = 20 * 1024 * 1024;

  final CatalogService _catalogService = CatalogService();
  final CatalogItemService _catalogItemService = CatalogItemService();
  final CatalogImportParser _parser = CatalogImportParser();

  String? _selectedCollectionId;
  CatalogImportResult? _importResult;
  CatalogItemImportMode _importMode = CatalogItemImportMode.skipExisting;
  bool _isPickingFile = false;
  bool _isImporting = false;
  bool _isCreatingCollection = false;

  Future<void> _pickFile() async {
    final localizations = AppLocalizations.of(context)!;

    if (_isPickingFile || _isImporting) {
      return;
    }

    setState(() {
      _isPickingFile = true;
    });

    try {
      final acceptedTypes = XTypeGroup(
        label: localizations.catalogImportCsvAndExcel,
        extensions: const ['csv', 'xlsx'],
      );

      final file = await openFile(acceptedTypeGroups: [acceptedTypes]);

      if (file == null) {
        return;
      }

      final fileSize = await file.length();

      if (fileSize > _maximumFileSize) {
        throw FormatException(localizations.catalogImportFileTooLarge);
      }

      final bytes = await file.readAsBytes();

      final parsed = _parser.parse(
        fileName: file.name,
        bytes: bytes,
        localizations: localizations,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _importResult = parsed;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            localizations.catalogImportFileOpenError(error.toString()),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isPickingFile = false;
        });
      }
    }
  }

  Future<void> _createCollection() async {
    final localizations = AppLocalizations.of(context)!;

    if (_isCreatingCollection || _isImporting) {
      return;
    }

    final suggestedName = _suggestedCollectionName();
    final suggestedId = _slugify(suggestedName);
    final suggestedPublisher = suggestedName.toLowerCase().contains('panini')
        ? 'Panini'
        : '';
    final suggestedCategory = suggestedName.toLowerCase().contains('world cup')
        ? 'Športne kartice'
        : '';
    final suggestedYear = _suggestedYear().toString();
    final suggestedTotalItems = (_importResult?.validRows.length ?? 0)
        .toString();

    final input = await showDialog<_NewCatalogCollectionInput>(
      context: context,
      builder: (dialogContext) {
        final formKey = GlobalKey<FormState>();
        final nameController = TextEditingController(text: suggestedName);
        final idController = TextEditingController(text: suggestedId);
        final publisherController = TextEditingController(
          text: suggestedPublisher,
        );
        final categoryController = TextEditingController(
          text: suggestedCategory,
        );
        final yearController = TextEditingController(text: suggestedYear);
        final totalItemsController = TextEditingController(
          text: suggestedTotalItems,
        );

        var idWasEdited = false;

        nameController.addListener(() {
          if (!idWasEdited) {
            idController.text = _slugify(nameController.text);
          }
        });

        idController.addListener(() {
          if (idController.text != _slugify(nameController.text)) {
            idWasEdited = true;
          }
        });

        return AlertDialog(
          title: Text(localizations.catalogCreateNewCollection),
          content: SizedBox(
            width: 520,
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: nameController,
                      autofocus: true,
                      decoration: InputDecoration(
                        labelText: localizations.catalogCollectionName,
                        prefixIcon: const Icon(
                          Icons.collections_bookmark_outlined,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return localizations.catalogEnterCollectionName;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: idController,
                      decoration: InputDecoration(
                        labelText: localizations.catalogCollectionId,
                        prefixIcon: const Icon(Icons.key_outlined),
                        helperText: localizations.catalogCollectionIdHelp,
                      ),
                      validator: (value) {
                        final id = value?.trim() ?? '';

                        if (id.isEmpty) {
                          return localizations.catalogEnterCollectionId;
                        }

                        if (!RegExp(
                          r'^[a-z0-9]+(?:-[a-z0-9]+)*$',
                        ).hasMatch(id)) {
                          return localizations.catalogCollectionIdInvalid;
                        }

                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: publisherController,
                      decoration: InputDecoration(
                        labelText: localizations.catalogPublisher,
                        prefixIcon: const Icon(Icons.business_outlined),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: categoryController,
                      decoration: InputDecoration(
                        labelText: localizations.catalogCategory,
                        prefixIcon: const Icon(Icons.category_outlined),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: yearController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: localizations.catalogYear,
                            ),
                            validator: (value) {
                              final year = int.tryParse(value?.trim() ?? '');

                              if (year == null || year < 0 || year > 9999) {
                                return localizations.catalogInvalidYear;
                              }

                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: totalItemsController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: localizations.catalogItemCount,
                            ),
                            validator: (value) {
                              final total = int.tryParse(value?.trim() ?? '');

                              if (total == null || total < 0) {
                                return localizations.catalogInvalidNumber;
                              }

                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(localizations.catalogCancel),
            ),
            FilledButton.icon(
              onPressed: () {
                if (formKey.currentState?.validate() != true) {
                  return;
                }

                Navigator.of(dialogContext).pop(
                  _NewCatalogCollectionInput(
                    id: idController.text.trim(),
                    name: nameController.text.trim(),
                    publisher: publisherController.text.trim(),
                    category: categoryController.text.trim(),
                    year: int.parse(yearController.text.trim()),
                    totalItems: int.parse(totalItemsController.text.trim()),
                  ),
                );
              },
              icon: const Icon(Icons.add),
              label: Text(localizations.catalogCreate),
            ),
          ],
        );
      },
    );

    if (input == null || !mounted) {
      return;
    }

    setState(() {
      _isCreatingCollection = true;
    });

    try {
      final reference = FirebaseFirestore.instance
          .collection('catalogCollections')
          .doc(input.id);

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final existing = await transaction.get(reference);

        if (existing.exists) {
          throw StateError(localizations.catalogCollectionIdExists(input.id));
        }

        transaction.set(reference, {
          'name': input.name,
          'publisher': input.publisher,
          'category': input.category,
          'year': input.year,
          'totalItems': input.totalItems,
          'coverImageUrl': '',
          'isActive': true,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      });

      if (!mounted) {
        return;
      }

      setState(() {
        _selectedCollectionId = input.id;
      });

      _showMessage(localizations.catalogCollectionCreatedForImport(input.name));
    } on FirebaseException catch (error) {
      if (!mounted) {
        return;
      }

      final message = error.code == 'permission-denied'
          ? localizations.catalogCollectionCreatePermissionDenied
          : localizations.catalogCollectionCreateError(
              error.message ?? error.code,
            );

      _showMessage(message);
    } catch (error) {
      if (!mounted) {
        return;
      }

      _showMessage(
        localizations.catalogCollectionCreateError(error.toString()),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isCreatingCollection = false;
        });
      }
    }
  }

  String _suggestedCollectionName() {
    final fileName = _importResult?.fileName ?? '';
    final normalized = fileName.toLowerCase();

    if (normalized.contains('panini') &&
        normalized.contains('world_cup_2026') &&
        normalized.contains('base_630')) {
      return 'Panini FIFA World Cup 2026 Adrenalyn XL – Base Collection';
    }

    final withoutExtension = fileName.replaceFirst(
      RegExp(r'\.(csv|xlsx)$', caseSensitive: false),
      '',
    );

    final readable = withoutExtension
        .replaceAll('_', ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    return readable.isEmpty
        ? AppLocalizations.of(context)!.catalogNewCollection
        : readable;
  }

  int _suggestedYear() {
    final source =
        '${_importResult?.fileName ?? ''} ${_suggestedCollectionName()}';
    final match = RegExp(r'\b(19|20)\d{2}\b').firstMatch(source);

    return int.tryParse(match?.group(0) ?? '') ?? DateTime.now().year;
  }

  String _slugify(String value) {
    const replacements = {
      'č': 'c',
      'ć': 'c',
      'š': 's',
      'ž': 'z',
      'đ': 'd',
      'Č': 'c',
      'Ć': 'c',
      'Š': 's',
      'Ž': 'z',
      'Đ': 'd',
    };

    var normalized = value;

    for (final entry in replacements.entries) {
      normalized = normalized.replaceAll(entry.key, entry.value);
    }

    return normalized
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '');
  }

  Future<void> _startImport(List<CatalogCollection> collections) async {
    final localizations = AppLocalizations.of(context)!;
    final collectionId = _selectedCollectionId;
    final result = _importResult;

    if (collectionId == null || collectionId.isEmpty) {
      _showMessage(localizations.catalogSelectTargetCollectionFirst);
      return;
    }

    if (result == null || !result.canImport) {
      _showMessage(localizations.catalogSelectValidFileFirst);
      return;
    }

    final selectedCollection = collections.where(
      (collection) => collection.id == collectionId,
    );

    if (selectedCollection.isEmpty) {
      _showMessage(localizations.catalogSelectedCollectionMissing);
      return;
    }

    final collection = selectedCollection.first;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(localizations.catalogConfirmImport),
          content: Text(
            '${localizations.catalogImportConfirmRows(result.validRows.length, collection.name)}\n\n'
            '${_importMode == CatalogItemImportMode.skipExisting ? localizations.catalogImportExistingSkipped : localizations.catalogImportExistingUpdated}',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(localizations.catalogCancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(localizations.catalogImportAction),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) {
      return;
    }

    setState(() {
      _isImporting = true;
    });

    try {
      final items = result.validRows
          .map((row) => row.toCatalogItem(collectionId))
          .toList(growable: false);

      final summary = await _catalogItemService.importItems(
        collectionId: collectionId,
        items: items,
        mode: _importMode,
      );

      if (!mounted) {
        return;
      }

      await showDialog<void>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: Text(localizations.catalogImportCompleted),
            content: Text(
              '${localizations.catalogImportCreated(summary.created)}\n'
              '${localizations.catalogImportUpdated(summary.updated)}\n'
              '${localizations.catalogImportSkipped(summary.skipped)}',
            ),
            actions: [
              FilledButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: Text(localizations.catalogOk),
              ),
            ],
          );
        },
      );
    } on FirebaseException catch (error) {
      if (!mounted) {
        return;
      }

      final message = error.code == 'permission-denied'
          ? localizations.catalogImportPermissionDenied
          : localizations.catalogImportFailed(error.message ?? error.code);

      _showMessage(message);
    } catch (error) {
      if (!mounted) {
        return;
      }

      _showMessage(localizations.catalogImportFailed(error.toString()));
    } finally {
      if (mounted) {
        setState(() {
          _isImporting = false;
        });
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(localizations.catalogImportTitle)),
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
                  localizations.catalogCollectionsLoadErrorDetails(
                    snapshot.error.toString(),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final collections = snapshot.data ?? const <CatalogCollection>[];
          final selectedCollectionStillExists =
              _selectedCollectionId == null ||
              collections.any(
                (collection) => collection.id == _selectedCollectionId,
              );

          if (!selectedCollectionStillExists) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                setState(() {
                  _selectedCollectionId = null;
                });
              }
            });
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                localizations.catalogImportDescription,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                localizations.catalogImportColumnHelp,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                key: ValueKey(
                  '${collections.length}-${_selectedCollectionId ?? ''}',
                ),
                initialValue: selectedCollectionStillExists
                    ? _selectedCollectionId
                    : null,
                isExpanded: true,
                decoration: InputDecoration(
                  labelText: localizations.catalogTargetCollection,
                  prefixIcon: const Icon(Icons.collections_bookmark_outlined),
                  border: const OutlineInputBorder(),
                ),
                items: collections
                    .map(
                      (collection) => DropdownMenuItem<String>(
                        value: collection.id,
                        child: Text(
                          '${collection.name} (${collection.totalItems})',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    )
                    .toList(growable: false),
                onChanged: _isImporting
                    ? null
                    : (value) {
                        setState(() {
                          _selectedCollectionId = value;
                        });
                      },
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _isImporting || _isCreatingCollection
                      ? null
                      : _createCollection,
                  icon: _isCreatingCollection
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.add_circle_outline),
                  label: Text(
                    _isCreatingCollection
                        ? localizations.catalogCreatingCollection
                        : localizations.catalogCreateNewCollection,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SegmentedButton<CatalogItemImportMode>(
                segments: [
                  ButtonSegment(
                    value: CatalogItemImportMode.skipExisting,
                    icon: const Icon(Icons.skip_next_outlined),
                    label: Text(localizations.catalogSkip),
                  ),
                  ButtonSegment(
                    value: CatalogItemImportMode.updateExisting,
                    icon: const Icon(Icons.update_outlined),
                    label: Text(localizations.catalogUpdate),
                  ),
                ],
                selected: {_importMode},
                onSelectionChanged: _isImporting
                    ? null
                    : (selection) {
                        setState(() {
                          _importMode = selection.first;
                        });
                      },
              ),
              const SizedBox(height: 8),
              Text(
                _importMode == CatalogItemImportMode.skipExisting
                    ? localizations.catalogImportSkipHelp
                    : localizations.catalogImportUpdateHelp,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: _isPickingFile || _isImporting ? null : _pickFile,
                icon: _isPickingFile
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.upload_file_outlined),
                label: Text(
                  _isPickingFile
                      ? localizations.catalogOpeningFile
                      : localizations.catalogChooseCsvOrXlsx,
                ),
              ),
              if (_importResult case final result?) ...[
                const SizedBox(height: 20),
                _ImportSummaryCard(result: result),
                if (result.fileErrors.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _ErrorCard(
                    title: localizations.catalogFileErrors,
                    errors: result.fileErrors,
                  ),
                ],
                if (result.rows.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Text(
                        localizations.catalogPreview,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const Spacer(),
                      Text(
                        localizations.catalogFirstRows(
                          result.rows.length > 12 ? 12 : result.rows.length,
                        ),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ...result.rows
                      .take(12)
                      .map((row) => _ImportRowCard(row: row)),
                ],
                const SizedBox(height: 18),
                FilledButton.icon(
                  onPressed:
                      result.canImport &&
                          !_isImporting &&
                          collections.isNotEmpty
                      ? () => _startImport(collections)
                      : null,
                  icon: _isImporting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.cloud_upload_outlined),
                  label: Text(
                    _isImporting
                        ? localizations.catalogImporting
                        : localizations.catalogImportItems(
                            result.validRows.length,
                          ),
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _NewCatalogCollectionInput {
  final String id;
  final String name;
  final String publisher;
  final String category;
  final int year;
  final int totalItems;

  const _NewCatalogCollectionInput({
    required this.id,
    required this.name,
    required this.publisher,
    required this.category,
    required this.year,
    required this.totalItems,
  });
}

class _ImportSummaryCard extends StatelessWidget {
  final CatalogImportResult result;

  const _ImportSummaryCard({required this.result});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              result.fileName,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            if (result.sheetName != null) ...[
              const SizedBox(height: 4),
              Text(localizations.catalogSheetName(result.sheetName!)),
            ],
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Chip(
                  avatar: const Icon(Icons.check_circle_outline, size: 18),
                  label: Text(
                    localizations.catalogValidRows(result.validRows.length),
                  ),
                ),
                Chip(
                  avatar: const Icon(Icons.error_outline, size: 18),
                  label: Text(
                    localizations.catalogInvalidRows(result.invalidRows.length),
                  ),
                ),
                Chip(
                  avatar: const Icon(Icons.view_column_outlined, size: 18),
                  label: Text(
                    localizations.catalogColumnCount(
                      result.sourceHeaders.length,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  final String title;
  final List<String> errors;

  const _ErrorCard({required this.title, required this.errors});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      color: colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: colorScheme.onErrorContainer,
              ),
            ),
            const SizedBox(height: 8),
            ...errors.map(
              (error) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  '• $error',
                  style: TextStyle(color: colorScheme.onErrorContainer),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ImportRowCard extends StatelessWidget {
  final CatalogImportRow row;

  const _ImportRowCard({required this.row});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      color: row.isValid ? null : colorScheme.errorContainer,
      child: ListTile(
        leading: CircleAvatar(child: Text(row.sourceRowNumber.toString())),
        title: Text(
          '${row.number.isEmpty ? '—' : row.number} • '
          '${row.name.isEmpty ? localizations.catalogUnnamedItem : row.name}',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (row.rarity.isNotEmpty)
              Text(localizations.catalogRarityValue(row.rarity)),
            if (row.attributes.isNotEmpty)
              Text(
                row.attributes.entries
                    .map((entry) => '${entry.key}: ${entry.value}')
                    .join(' • '),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            if (row.errors.isNotEmpty)
              Text(
                row.errors.join(' '),
                style: TextStyle(
                  color: colorScheme.onErrorContainer,
                  fontWeight: FontWeight.w600,
                ),
              ),
          ],
        ),
        trailing: Icon(
          row.isValid ? Icons.check_circle : Icons.error,
          color: row.isValid ? Colors.green : colorScheme.error,
        ),
      ),
    );
  }
}
