import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

/// Allowed diagnostic context keys for Crashlytics custom keys.
///
/// Do not add PII fields (email, displayName, message text, addresses, etc.).
const Set<String> kCrashlyticsAllowedContextKeys = {
  'operation',
  'error_code',
  'status',
  'collection_id',
  'item_count',
  'screen',
  'fatal',
  'side',
  'flag',
};

/// Backend used by [CrashReporter] — real Crashlytics or a test double.
abstract class CrashReporterBackend {
  Future<void> setCollectionEnabled(bool enabled);

  Future<void> setUserIdentifier(String? identifier);

  Future<void> setCustomKey(String key, Object value);

  Future<void> log(String message);

  Future<void> recordError(
    Object exception,
    StackTrace? stack, {
    String? reason,
    bool fatal = false,
  });

  Future<void> recordFlutterFatalError(FlutterErrorDetails details);
}

class FirebaseCrashReporterBackend implements CrashReporterBackend {
  FirebaseCrashReporterBackend([FirebaseCrashlytics? crashlytics])
    : _crashlyticsOverride = crashlytics;

  final FirebaseCrashlytics? _crashlyticsOverride;

  FirebaseCrashlytics get _crashlytics =>
      _crashlyticsOverride ?? FirebaseCrashlytics.instance;

  @override
  Future<void> setCollectionEnabled(bool enabled) {
    return _crashlytics.setCrashlyticsCollectionEnabled(enabled);
  }

  @override
  Future<void> setUserIdentifier(String? identifier) {
    return _crashlytics.setUserIdentifier(identifier ?? '');
  }

  @override
  Future<void> setCustomKey(String key, Object value) {
    return _crashlytics.setCustomKey(key, value);
  }

  @override
  Future<void> log(String message) {
    return _crashlytics.log(message);
  }

  @override
  Future<void> recordError(
    Object exception,
    StackTrace? stack, {
    String? reason,
    bool fatal = false,
  }) {
    return _crashlytics.recordError(
      exception,
      stack,
      reason: reason,
      fatal: fatal,
    );
  }

  @override
  Future<void> recordFlutterFatalError(FlutterErrorDetails details) {
    return _crashlytics.recordFlutterFatalError(details);
  }
}

/// In-memory backend for unit tests.
class RecordingCrashReporterBackend implements CrashReporterBackend {
  bool? collectionEnabled;
  String? userIdentifier;
  final List<String> logs = <String>[];
  final List<Map<String, Object?>> errors = <Map<String, Object?>>[];
  final Map<String, Object> customKeys = <String, Object>{};

  @override
  Future<void> setCollectionEnabled(bool enabled) async {
    collectionEnabled = enabled;
  }

  @override
  Future<void> setUserIdentifier(String? identifier) async {
    userIdentifier = identifier;
  }

  @override
  Future<void> setCustomKey(String key, Object value) async {
    customKeys[key] = value;
  }

  @override
  Future<void> log(String message) async {
    logs.add(message);
  }

  @override
  Future<void> recordError(
    Object exception,
    StackTrace? stack, {
    String? reason,
    bool fatal = false,
  }) async {
    errors.add(<String, Object?>{
      'exception': exception,
      'exception_text': exception.toString(),
      'reason': reason,
      'fatal': fatal,
    });
  }

  @override
  Future<void> recordFlutterFatalError(FlutterErrorDetails details) async {
    errors.add(<String, Object?>{
      'exception': details.exception,
      'exception_text': details.exceptionAsString(),
      'reason': 'flutter_fatal',
      'fatal': true,
    });
  }
}

/// Safe diagnostic wrapper sent to Crashlytics instead of raw exceptions.
///
/// Keeps type + optional Firebase code; strips original messages that may
/// contain PII / free text.
class SanitizedCrashException implements Exception {
  SanitizedCrashException({
    required this.originalType,
    this.errorCode,
  });

  final String originalType;
  final String? errorCode;

  @override
  String toString() {
    if (errorCode == null || errorCode!.isEmpty) {
      return 'SanitizedCrashException($originalType)';
    }
    return 'SanitizedCrashException($originalType, code=$errorCode)';
  }
}

/// Central Crashlytics facade. Prefer this over calling Firebase Crashlytics
/// directly from feature/business code.
class CrashReporter {
  CrashReporter._({CrashReporterBackend? backend})
    : _backend = backend ?? FirebaseCrashReporterBackend();

  static CrashReporter instance = CrashReporter._();

  /// Replace the singleton (tests). Call [resetForTest] in tearDown.
  @visibleForTesting
  static void debugOverride({CrashReporterBackend? backend}) {
    instance = CrashReporter._(backend: backend);
  }

  @visibleForTesting
  static void resetForTest() {
    instance = CrashReporter._(backend: RecordingCrashReporterBackend());
  }

  final CrashReporterBackend _backend;
  StreamSubscription<User?>? _authSubscription;
  bool _handlersInstalled = false;

  /// Force collection even in debug when building with:
  /// `--dart-define=CRASHLYTICS_FORCE_ENABLE=true`
  static const bool forceEnableCollection = bool.fromEnvironment(
    'CRASHLYTICS_FORCE_ENABLE',
    defaultValue: false,
  );

  /// Smoke-only crash trigger when building with:
  /// `--dart-define=CRASHLYTICS_SMOKE=true` (debug recommended).
  static const bool smokeHookEnabled = bool.fromEnvironment(
    'CRASHLYTICS_SMOKE',
    defaultValue: false,
  );

  bool get isCollectionEnabledByPolicy {
    if (forceEnableCollection) {
      return true;
    }
    return !kDebugMode;
  }

  /// Call once after [Firebase.initializeApp].
  Future<void> install({FirebaseAuth? auth}) async {
    await _backend.setCollectionEnabled(isCollectionEnabledByPolicy);

    if (!_handlersInstalled) {
      FlutterError.onError = (FlutterErrorDetails details) {
        // Keep Flutter's normal presentation/debug dump.
        FlutterError.presentError(details);
        unawaited(
          _backend.recordFlutterFatalError(
            FlutterErrorDetails(
              exception: sanitizeException(details.exception),
              stack: details.stack,
              library: details.library,
              context: details.context,
              informationCollector: null,
              silent: details.silent,
            ),
          ),
        );
      };

      PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
        unawaited(
          _backend.recordError(
            sanitizeException(error),
            stack,
            reason: 'platform_dispatcher',
            fatal: true,
          ),
        );
        // true = error was handled for engine purposes; we still reported it.
        return true;
      };

      _handlersInstalled = true;
    }

    await _authSubscription?.cancel();
    _authSubscription = (auth ?? FirebaseAuth.instance).authStateChanges()
        .listen((User? user) {
          unawaited(setUserId(user?.uid));
        });
  }

  Future<void> setUserId(String? uid) {
    // UID only. Never email / displayName / phone.
    return _backend.setUserIdentifier(uid ?? '');
  }

  Future<void> clearUserId() {
    return _backend.setUserIdentifier('');
  }

  Future<void> log(String message) {
    return _backend.log(_sanitizeLogMessage(message));
  }

  /// Records a non-fatal issue with sanitized exception + context only.
  Future<void> recordNonFatal(
    Object error,
    StackTrace? stack, {
    String? reason,
    Map<String, Object?> context = const <String, Object?>{},
  }) async {
    final sanitized = sanitizeContext(context);
    for (final entry in sanitized.entries) {
      await _backend.setCustomKey(entry.key, entry.value);
    }

    await _backend.recordError(
      sanitizeException(error),
      stack,
      reason: reason == null ? null : _sanitizeLogMessage(reason),
      fatal: false,
    );
  }

  /// P22A2C hook: call when client-side reservation overcommit is detected.
  ///
  /// Automatic detection is NOT implemented in P23.
  Future<void> logReservationOvercommit({
    required String operation,
    String? collectionId,
    int? itemCount,
    String? status,
  }) {
    return recordNonFatal(
      StateError('reservation_overcommit'),
      StackTrace.current,
      reason: 'reservation_overcommit',
      context: <String, Object?>{
        'operation': operation,
        'error_code': 'reservation_overcommit',
        'collection_id': ?collectionId,
        'item_count': ?itemCount,
        'status': ?status,
      },
    );
  }

  /// Report selected Firebase trade failures (non-fatal).
  ///
  /// Expected UX [Exception]/[ArgumentError] from TradeService are ignored.
  /// Use [logReservationOvercommit] for the P22A2C overcommit signal.
  Future<void> observeTradeFailure({
    required String operation,
    required Object error,
    StackTrace? stack,
  }) async {
    if (error is! FirebaseException) {
      return;
    }
    if (!_shouldReportFirebaseCode(error.code)) {
      return;
    }
    await recordNonFatal(
      error,
      stack,
      reason: 'trade_$operation',
      context: <String, Object?>{
        'operation': operation,
        'error_code': error.code,
      },
    );
  }

  /// Debug / smoke-only. Compiles to no-op unless CRASHLYTICS_SMOKE=true.
  void triggerSmokeCrashIfEnabled() {
    if (!smokeHookEnabled) {
      return;
    }
    // Intentionally fatal for Crashlytics verification builds only.
    FirebaseCrashlytics.instance.crash();
  }

  /// Replaces raw exceptions (and their messages) with a safe diagnostic object.
  @visibleForTesting
  static SanitizedCrashException sanitizeException(Object error) {
    String? code;
    if (error is FirebaseException) {
      code = error.code;
    } else if (error is SanitizedCrashException) {
      return error;
    }
    return SanitizedCrashException(
      originalType: error.runtimeType.toString(),
      errorCode: code,
    );
  }

  @visibleForTesting
  static Map<String, Object> sanitizeContext(Map<String, Object?> raw) {
    final out = <String, Object>{};
    for (final entry in raw.entries) {
      final key = entry.key.trim().toLowerCase();
      if (!kCrashlyticsAllowedContextKeys.contains(key)) {
        continue;
      }
      final value = entry.value;
      if (value == null) {
        continue;
      }
      if (value is bool || value is num) {
        out[key] = value;
        continue;
      }
      final text = _sanitizeLogMessage(value.toString());
      if (text.isEmpty) {
        continue;
      }
      out[key] = text;
    }
    return out;
  }

  static bool _shouldReportFirebaseCode(String code) {
    switch (code) {
      case 'permission-denied':
      case 'internal':
      case 'data-loss':
      case 'unknown':
      case 'aborted':
        return true;
      default:
        return false;
    }
  }

  static String _sanitizeLogMessage(String message) {
    var text = message;
    // Strip emails if accidentally included.
    text = text.replaceAll(
      RegExp(r'[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}', caseSensitive: false),
      '[redacted-email]',
    );
    if (text.length > 180) {
      text = '${text.substring(0, 180)}…';
    }
    return text;
  }
}
