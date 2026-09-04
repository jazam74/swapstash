# Observability (P23)

## Purpose

Firebase Crashlytics captures fatal Flutter/platform crashes and a small set of
high-value **non-fatal** trade signals before the P22 production cutover.

This is **client** observability only. Backend anomalies continue to use
structured Firebase Functions logs.

## What is recorded

- Fatal Flutter framework errors (`FlutterError.onError`)
- Fatal unhandled async/platform errors (`PlatformDispatcher.instance.onError`)
- Firebase Auth UID as Crashlytics user id (no email / displayName)
- Non-fatal trade Firebase failures with codes:
  - `permission-denied`
  - `internal` / `aborted` / `data-loss` / `unknown`
- Explicit `reservation_overcommit` signal via
  `CrashReporter.logReservationOvercommit` (hook for **P22A2C**)

Exception payloads are **sanitized** before Crashlytics: only runtime type +
optional Firebase `code` are kept. Original exception messages are stripped so
emails, free text, delivery notes, etc. are not uploaded.

## What is NOT recorded

- Email, displayName, phone, address, delivery details
- Chat message text, report free text, item notes
- Full Firestore documents / request payloads
- Raw `exception.toString()` / `FirebaseException.message`
- `tradeId` (omitted on purpose for privacy; use operation + error_code +
  collection_id / item_count when needed)
- Expected UX trade failures (inventory unavailable, wrong turn, etc.)
- Firebase Analytics events (deferred to **P24**)

## Collection policy

| Build | Crashlytics collection |
|-------|------------------------|
| `debug` | **disabled** (default) |
| `profile` / `release` | **enabled** |
| any + `--dart-define=CRASHLYTICS_FORCE_ENABLE=true` | **enabled** |

Normal `flutter build apk --debug` does **not** enable collection and does
**not** trigger a smoke crash.

## One-time Crashlytics smoke test

Do **not** ship a visible “Crash app” button.

Smoke crash runs **only** when both defines are present (or at least
`CRASHLYTICS_SMOKE=true` for the crash; force-enable is required to upload from
debug):

```bash
flutter build apk --debug \
  --dart-define=CRASHLYTICS_FORCE_ENABLE=true \
  --dart-define=CRASHLYTICS_SMOKE=true
```

1. Install and launch once. The app calls `FirebaseCrashlytics.instance.crash()`
   only when `CRASHLYTICS_SMOKE=true`.
2. Confirm the crash appears in the Firebase Console → Crashlytics for
   `swapstash-49199` (may take a few minutes).
3. Discard that APK; never distribute smoke builds.

Release/profile builds without `CRASHLYTICS_SMOKE` never call the artificial
crash.

## Architecture

- Facade: `lib/core/observability/crash_reporter.dart`
- Installed from `lib/main.dart` **after** `Firebase.initializeApp`
- Auth UID synced via `FirebaseAuth.authStateChanges` (login, restore, logout →
  cleared to empty string)
- Trade mutations wrap through `TradeService._withTradeObservability`

## Backend vs client

| Layer | System | Example |
|-------|--------|---------|
| Cloud Functions | Structured `logger.error` | `reservation_aggregate_underflow` |
| Flutter app | Crashlytics | `permission-denied`, `reservation_overcommit` |

Do not pipe Functions logs into Flutter Crashlytics.

## Reservation overcommit telemetry status

`reservation_overcommit` telemetry hook is prepared but **automatic detection
is NOT implemented in P23.**

`P22A2C` = strong consistency / active detection follow-up.

Until P22A2C wires detection to `CrashReporter.logReservationOvercommit`,
Crashlytics will **not** measure real overcommit events (the hook exists only).

When detection lands, call:

```dart
CrashReporter.instance.logReservationOvercommit(
  operation: 'accept_trade',
  collectionId: collectionId,
  itemCount: count,
  status: 'accepted',
);
```

## Signals to watch after Closed Testing

1. Fatal crash-free users / sessions
2. Non-fatal `trade_*` + `permission-denied`
3. `reservation_overcommit` (expect none until P22A2C detection exists; after
   P22A2C, any spike needs investigation before wider rollout)
4. Functions logs for `reservation_aggregate_underflow`

## Privacy disclosure

**PRIVACY DISCLOSURE REVIEW: REQUIRED BEFORE PUBLIC RELEASE**

Before shipping a public Crashlytics-enabled build, confirm the public Privacy
Policy clearly covers crash/error diagnostics / Firebase Crashlytics. This is
not a blocker for committing P23 code; it is a release-gate follow-up (website
copy is out of scope for this Flutter branch).

## Production rollout

1. Merge P23 after review
2. Complete privacy disclosure review for public release
3. Ship Closed Testing / internal track release build (collection enabled)
4. Run one smoke crash in a **non-store** forced build, then delete it
5. Monitor Crashlytics for 24–48h before P22 production cutover
6. P22 cutover is **not** started by P23

## Analytics

`firebase_analytics` is **not** added in P23.

`ANALYTICS STATUS: ABSENT — DEFERRED TO P24`

Website GA4 on `swapstash.net` is a separate system.

## Firebase dependency alignment (P23)

Direct `pubspec.yaml` constraints (unchanged except adding Crashlytics):

- `firebase_core: ^4.11.0`
- `firebase_auth: ^6.5.4`
- `cloud_firestore: ^6.6.0`
- `firebase_storage: ^13.4.3`
- `firebase_messaging: ^16.4.3`
- `firebase_crashlytics: ^5.3.0` (**new**)

Resolved lock alignment (legitimate for Crashlytics + Android compile):

- `firebase_core` 4.14.0
- `firebase_auth` 6.6.1
- `cloud_firestore` 6.7.1
- `firebase_storage` 13.4.5
- `firebase_messaging` 16.4.3
- `firebase_crashlytics` 5.3.0
