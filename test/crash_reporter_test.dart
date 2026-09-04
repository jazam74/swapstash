import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:swapstash/core/observability/crash_reporter.dart';

void main() {
  tearDown(() {
    CrashReporter.resetForTest();
  });

  group('CrashReporter.sanitizeContext', () {
    test('keeps only allowlisted keys', () {
      final sanitized = CrashReporter.sanitizeContext(<String, Object?>{
        'operation': 'accept_trade',
        'error_code': 'permission-denied',
        'collection_id': 'col_1',
        'item_count': 3,
        'email': 'user@example.com',
        'displayName': 'Ada',
        'message': 'secret chat text',
        'tradeId': 'trade_abc',
      });

      expect(
        sanitized.keys,
        unorderedEquals(<String>[
          'operation',
          'error_code',
          'collection_id',
          'item_count',
        ]),
      );
      expect(sanitized.containsKey('email'), isFalse);
      expect(sanitized.containsKey('tradeId'), isFalse);
      expect(sanitized['item_count'], 3);
    });

    test('redacts emails inside string values', () {
      final sanitized = CrashReporter.sanitizeContext(<String, Object?>{
        'operation': 'contact user@example.com please',
      });

      expect(sanitized['operation'], contains('[redacted-email]'));
      expect(sanitized['operation'], isNot(contains('user@example.com')));
    });
  });

  group('CrashReporter.sanitizeException', () {
    test('strips PII and free text from exception payload', () async {
      final backend = RecordingCrashReporterBackend();
      CrashReporter.debugOverride(backend: backend);

      await CrashReporter.instance.recordNonFatal(
        Exception(
          'Failed for user@example.com with Secret delivery note',
        ),
        StackTrace.current,
        reason: 'unit_test',
        context: <String, Object?>{
          'operation': 'mark_shipped',
          'error_code': 'permission-denied',
        },
      );

      expect(backend.errors, hasLength(1));
      final text = backend.errors.single['exception_text']!.toString();
      expect(text, isNot(contains('user@example.com')));
      expect(text, isNot(contains('Secret delivery note')));
      expect(text, contains('SanitizedCrashException'));
      expect(text, contains('Exception'));
    });

    test('keeps Firebase error code without message body', () async {
      final backend = RecordingCrashReporterBackend();
      CrashReporter.debugOverride(backend: backend);

      await CrashReporter.instance.observeTradeFailure(
        operation: 'accept_trade',
        error: FirebaseException(
          plugin: 'cloud_firestore',
          code: 'permission-denied',
          message:
              'Missing permissions for user@example.com Secret delivery note',
        ),
        stack: StackTrace.current,
      );

      expect(backend.errors, hasLength(1));
      final text = backend.errors.single['exception_text']!.toString();
      expect(text, contains('permission-denied'));
      expect(text, isNot(contains('user@example.com')));
      expect(text, isNot(contains('Secret delivery note')));
      expect(backend.customKeys['error_code'], 'permission-denied');
    });
  });

  group('CrashReporter trade failure mapping', () {
    test('records permission-denied non-fatals', () async {
      final backend = RecordingCrashReporterBackend();
      CrashReporter.debugOverride(backend: backend);

      await CrashReporter.instance.observeTradeFailure(
        operation: 'accept_trade',
        error: FirebaseException(
          plugin: 'cloud_firestore',
          code: 'permission-denied',
          message: 'Missing or insufficient permissions.',
        ),
        stack: StackTrace.current,
      );

      expect(backend.errors, hasLength(1));
      expect(backend.errors.single['reason'], 'trade_accept_trade');
      expect(backend.errors.single['fatal'], isFalse);
      expect(backend.customKeys['error_code'], 'permission-denied');
      expect(backend.customKeys['operation'], 'accept_trade');
    });

    test('ignores expected not-found Firebase codes', () async {
      final backend = RecordingCrashReporterBackend();
      CrashReporter.debugOverride(backend: backend);

      await CrashReporter.instance.observeTradeFailure(
        operation: 'accept_trade',
        error: FirebaseException(
          plugin: 'cloud_firestore',
          code: 'not-found',
        ),
      );

      expect(backend.errors, isEmpty);
    });

    test('ignores plain Exception UX failures', () async {
      final backend = RecordingCrashReporterBackend();
      CrashReporter.debugOverride(backend: backend);

      await CrashReporter.instance.observeTradeFailure(
        operation: 'mark_shipped',
        error: Exception('Predmeta 12 nimaš več v zadostni količini.'),
      );

      expect(backend.errors, isEmpty);
    });
  });

  group('CrashReporter reservation overcommit', () {
    test('records structured non-fatal without tradeId', () async {
      final backend = RecordingCrashReporterBackend();
      CrashReporter.debugOverride(backend: backend);

      await CrashReporter.instance.logReservationOvercommit(
        operation: 'accept_trade',
        collectionId: 'col_x',
        itemCount: 2,
        status: 'accepted',
      );

      expect(backend.errors, hasLength(1));
      expect(backend.errors.single['reason'], 'reservation_overcommit');
      expect(backend.customKeys['collection_id'], 'col_x');
      expect(backend.customKeys.containsKey('trade_id'), isFalse);
    });
  });

  group('collection policy', () {
    test('force enable dart-define is false by default', () {
      expect(CrashReporter.forceEnableCollection, isFalse);
      expect(CrashReporter.smokeHookEnabled, isFalse);
    });

    test('debug policy disables collection unless forced', () {
      expect(kDebugMode, isTrue);
      expect(CrashReporter.instance.isCollectionEnabledByPolicy, isFalse);
    });

    test('user id clears to empty string', () async {
      final backend = RecordingCrashReporterBackend();
      CrashReporter.debugOverride(backend: backend);

      await CrashReporter.instance.setUserId('uid_abc');
      expect(backend.userIdentifier, 'uid_abc');
      await CrashReporter.instance.clearUserId();
      expect(backend.userIdentifier, '');
      await CrashReporter.instance.setUserId(null);
      expect(backend.userIdentifier, '');
    });
  });
}
