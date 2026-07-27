import 'dart:convert';
import 'dart:typed_data';

import 'package:csv/csv.dart';
import 'package:excel/excel.dart';
import 'package:swapstash/core/models/catalog_item.dart';
import 'package:swapstash/l10n/generated/app_localizations.dart';

class CatalogImportRow {
  final int sourceRowNumber;
  final String number;
  final String name;
  final String imageUrl;
  final String rarity;
  final Map<String, String> attributes;
  final List<String> errors;

  const CatalogImportRow({
    required this.sourceRowNumber,
    required this.number,
    required this.name,
    required this.imageUrl,
    required this.rarity,
    required this.attributes,
    required this.errors,
  });

  bool get isValid => errors.isEmpty;

  CatalogItem toCatalogItem(String collectionId) {
    return CatalogItem(
      id: '',
      collectionId: collectionId,
      number: number,
      name: name,
      imageUrl: imageUrl,
      rarity: rarity,
      attributes: attributes,
    );
  }
}

class CatalogImportResult {
  final String fileName;
  final String? sheetName;
  final List<String> sourceHeaders;
  final List<CatalogImportRow> rows;
  final List<String> fileErrors;

  const CatalogImportResult({
    required this.fileName,
    required this.sheetName,
    required this.sourceHeaders,
    required this.rows,
    required this.fileErrors,
  });

  List<CatalogImportRow> get validRows =>
      rows.where((row) => row.isValid).toList(growable: false);

  List<CatalogImportRow> get invalidRows =>
      rows.where((row) => !row.isValid).toList(growable: false);

  bool get canImport => fileErrors.isEmpty && validRows.isNotEmpty;
}

class CatalogImportParser {
  CatalogImportResult parse({
    required String fileName,
    required Uint8List bytes,
    required AppLocalizations localizations,
  }) {
    final extension = _extensionOf(fileName);

    switch (extension) {
      case 'csv':
        return _parseCsv(
          fileName: fileName,
          bytes: bytes,
          localizations: localizations,
        );
      case 'xlsx':
        return _parseXlsx(
          fileName: fileName,
          bytes: bytes,
          localizations: localizations,
        );
      default:
        return CatalogImportResult(
          fileName: fileName,
          sheetName: null,
          sourceHeaders: const [],
          rows: const [],
          fileErrors: [localizations.catalogImportSupportedFilesOnly],
        );
    }
  }

  CatalogImportResult _parseCsv({
    required String fileName,
    required Uint8List bytes,
    required AppLocalizations localizations,
  }) {
    try {
      final text = utf8.decode(bytes, allowMalformed: true);
      final decodedRows = csv.decode(text);

      return _parseRows(
        fileName: fileName,
        sheetName: null,
        rawRows: decodedRows,
        localizations: localizations,
      );
    } catch (error) {
      return CatalogImportResult(
        fileName: fileName,
        sheetName: null,
        sourceHeaders: const [],
        rows: const [],
        fileErrors: [localizations.catalogImportCsvReadError(error.toString())],
      );
    }
  }

  CatalogImportResult _parseXlsx({
    required String fileName,
    required Uint8List bytes,
    required AppLocalizations localizations,
  }) {
    try {
      final workbook = Excel.decodeBytes(bytes);
      final nonEmptySheetNames = workbook.tables.entries
          .where((entry) => entry.value.rows.any(_rowHasValue))
          .map((entry) => entry.key)
          .toList(growable: false);

      if (nonEmptySheetNames.isEmpty) {
        return CatalogImportResult(
          fileName: fileName,
          sheetName: null,
          sourceHeaders: const [],
          rows: const [],
          fileErrors: [localizations.catalogImportExcelNoData],
        );
      }

      final sheetName = nonEmptySheetNames.first;
      final sheet = workbook.tables[sheetName]!;

      final rows = sheet.rows
          .map(
            (row) => row
                .map((cell) => _excelCellToString(cell?.value))
                .toList(growable: false),
          )
          .toList(growable: false);

      return _parseRows(
        fileName: fileName,
        sheetName: sheetName,
        rawRows: rows,
        localizations: localizations,
      );
    } catch (error) {
      return CatalogImportResult(
        fileName: fileName,
        sheetName: null,
        sourceHeaders: const [],
        rows: const [],
        fileErrors: [
          localizations.catalogImportXlsxReadError(error.toString()),
        ],
      );
    }
  }

  CatalogImportResult _parseRows({
    required String fileName,
    required String? sheetName,
    required List<List<dynamic>> rawRows,
    required AppLocalizations localizations,
  }) {
    final headerRowIndex = rawRows.indexWhere(_rowHasValue);

    if (headerRowIndex < 0) {
      return CatalogImportResult(
        fileName: fileName,
        sheetName: sheetName,
        sourceHeaders: const [],
        rows: const [],
        fileErrors: [localizations.catalogImportFileNoData],
      );
    }

    final sourceHeaders = rawRows[headerRowIndex]
        .map((value) => _cleanCell(value))
        .toList(growable: false);

    final canonicalHeaders = <int, String>{};

    for (var index = 0; index < sourceHeaders.length; index++) {
      final header = sourceHeaders[index];
      if (header.isEmpty) {
        continue;
      }

      canonicalHeaders[index] = _canonicalHeader(header);
    }

    final availableCanonicalHeaders = canonicalHeaders.values.toSet();
    final fileErrors = <String>[];

    if (!availableCanonicalHeaders.contains('number')) {
      fileErrors.add(localizations.catalogImportMissingNumberColumn);
    }

    if (!availableCanonicalHeaders.contains('name')) {
      fileErrors.add(localizations.catalogImportMissingNameColumn);
    }

    final parsedRows = <CatalogImportRow>[];
    final seenNumbers = <String>{};

    for (
      var rowIndex = headerRowIndex + 1;
      rowIndex < rawRows.length;
      rowIndex++
    ) {
      final rawRow = rawRows[rowIndex];

      if (!_rowHasValue(rawRow)) {
        continue;
      }

      final values = <String, String>{};
      final attributes = <String, String>{};

      for (final headerEntry in canonicalHeaders.entries) {
        final columnIndex = headerEntry.key;
        final canonicalHeader = headerEntry.value;
        final value = columnIndex < rawRow.length
            ? _cleanCell(rawRow[columnIndex])
            : '';

        if (canonicalHeader.startsWith('attr:')) {
          final attributeKey = canonicalHeader.substring(5).trim();
          if (attributeKey.isNotEmpty && value.isNotEmpty) {
            attributes[attributeKey] = value;
          }
        } else {
          values[canonicalHeader] = value;
        }
      }

      final number = values['number']?.trim() ?? '';
      final name = values['name']?.trim() ?? '';
      final imageUrl = values['imageUrl']?.trim() ?? '';
      final rarity = values['rarity']?.trim() ?? '';
      final errors = <String>[];

      if (number.isEmpty) {
        errors.add(localizations.catalogImportMissingNumber);
      }

      if (name.isEmpty) {
        errors.add(localizations.catalogImportMissingName);
      }

      final normalizedNumber = number.toLowerCase();

      if (normalizedNumber.isNotEmpty && !seenNumbers.add(normalizedNumber)) {
        errors.add(localizations.catalogImportDuplicateNumber);
      }

      parsedRows.add(
        CatalogImportRow(
          sourceRowNumber: rowIndex + 1,
          number: number,
          name: name,
          imageUrl: imageUrl,
          rarity: rarity,
          attributes: Map.unmodifiable(attributes),
          errors: List.unmodifiable(errors),
        ),
      );
    }

    if (parsedRows.isEmpty && fileErrors.isEmpty) {
      fileErrors.add(localizations.catalogImportNoItemsBelowHeader);
    }

    return CatalogImportResult(
      fileName: fileName,
      sheetName: sheetName,
      sourceHeaders: List.unmodifiable(sourceHeaders),
      rows: List.unmodifiable(parsedRows),
      fileErrors: List.unmodifiable(fileErrors),
    );
  }

  String _canonicalHeader(String sourceHeader) {
    final normalized = _normalizeHeader(sourceHeader);

    const numberAliases = {
      'number',
      'no',
      'num',
      'stevilka',
      'st',
      'cardnumber',
      'itemnumber',
      'cataloguenumber',
      'catalognumber',
    };

    const nameAliases = {'name', 'ime', 'naziv', 'title', 'naslov'};

    const imageAliases = {
      'imageurl',
      'image',
      'slika',
      'slikaurl',
      'photo',
      'photourl',
    };

    const rarityAliases = {'rarity', 'redkost'};

    if (numberAliases.contains(normalized)) {
      return 'number';
    }

    if (nameAliases.contains(normalized)) {
      return 'name';
    }

    if (imageAliases.contains(normalized)) {
      return 'imageUrl';
    }

    if (rarityAliases.contains(normalized)) {
      return 'rarity';
    }

    var attributeKey = sourceHeader.trim();

    if (_normalizeHeader(attributeKey).startsWith('attr')) {
      attributeKey = attributeKey.replaceFirst(
        RegExp(r'^attr[\s_\-:]*', caseSensitive: false),
        '',
      );
    }

    attributeKey = _attributeKey(attributeKey);

    return 'attr:$attributeKey';
  }

  String _attributeKey(String value) {
    final normalized = _removeDiacritics(value)
        .trim()
        .replaceAll(RegExp(r'([a-z0-9])([A-Z])'), r'$1_$2')
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'^_+|_+$'), '');

    return normalized;
  }

  String _normalizeHeader(String value) {
    return _removeDiacritics(value)
        .replaceAll('\ufeff', '')
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '');
  }

  String _removeDiacritics(String value) {
    const replacements = {
      'č': 'c',
      'ć': 'c',
      'š': 's',
      'ž': 'z',
      'đ': 'd',
      'Č': 'C',
      'Ć': 'C',
      'Š': 'S',
      'Ž': 'Z',
      'Đ': 'D',
    };

    var result = value;

    for (final entry in replacements.entries) {
      result = result.replaceAll(entry.key, entry.value);
    }

    return result;
  }

  bool _rowHasValue(List<dynamic> row) {
    return row.any((value) => _cleanCell(value).isNotEmpty);
  }

  String _cleanCell(dynamic value) {
    return value?.toString().replaceAll('\ufeff', '').trim() ?? '';
  }

  String _extensionOf(String fileName) {
    final parts = fileName.toLowerCase().split('.');
    return parts.length < 2 ? '' : parts.last;
  }

  String _excelCellToString(CellValue? value) {
    if (value == null) {
      return '';
    }

    if (value is TextCellValue) {
      return value.toString().trim();
    }

    if (value is FormulaCellValue) {
      return value.formula.trim();
    }

    if (value is IntCellValue) {
      return value.value.toString();
    }

    if (value is DoubleCellValue) {
      final number = value.value;
      if (number == number.truncateToDouble()) {
        return number.toInt().toString();
      }
      return number.toString();
    }

    if (value is BoolCellValue) {
      return value.value.toString();
    }

    if (value is DateCellValue) {
      return _dateOnly(value.asDateTimeLocal());
    }

    if (value is DateTimeCellValue) {
      return value.asDateTimeLocal().toIso8601String();
    }

    if (value is TimeCellValue) {
      return value.asDuration().toString();
    }

    return value.toString();
  }

  String _dateOnly(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }
}
