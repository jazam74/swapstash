# SwapStash security rules tests

Security-rules tests for `../firestore.rules` and `../storage.rules`, running
against the Firebase emulators. Firestore coverage was added in batch
**P22A1** with the `/trades` and `/conversations` lockdown; Storage coverage
was added in **P22A2A**.

## Requirements

- Node.js 22+
- A JDK (the Firestore emulator is a Java process)

## Running

```bash
cd firestore-tests
npm install
npm test
```

`npm test` starts the Firestore and Storage emulators, loads the real rules
files from the repository root, runs every `*.test.js` file and shuts the
emulators down again. No Firebase login and no cloud project are needed —
nothing is deployed.

The emulators are started from the repository root, not from this directory,
because the Firebase CLI refuses a `rules` path outside the project directory.
That is also why the rules files are never duplicated here. As a side effect
the emulator writes `firestore-debug.log` into the repository root; the root
`.gitignore` already covers `*.log`.

Tests run with `--test-concurrency=1` on purpose. Every file calls
`clearFirestore()` or `clearStorage()` in `beforeEach`, and the emulators have
a single shared instance, so parallel files would wipe each other's fixtures.

## Files

| File | Covers |
|------|--------|
| `helpers.js` | Test environment, fixtures mirroring the documents and objects the Flutter client writes |
| `trades-access.test.js` | Who may read `/trades`, and which queries are still allowed |
| `trades-state-machine.test.js` | Every allowed and forbidden trade status transition |
| `conversations.test.js` | Conversation IDOR, plus the reworked `getOrCreateConversation` write shape |
| `regressions.test.js` | Ratings, chat messages, unread counters and delivery details, which all depend on trades and conversations |
| `storage.test.js` | Ownership, MIME type, file size and path shape for user item images |

## Storage status

**FIREBASE STORAGE STATUS: NOT INITIALIZED — MANUALLY CONFIRMED**

As of the P22A2A review, Cloud Storage for Firebase is **not activated** in
project `swapstash-49199`. The Firebase Console shows the Storage onboarding
screen with a "Get started" button and has no bucket or Files/Rules tabs. The
rules and tests in this directory are therefore **preparation for a future
activation**, not a fix for a currently deployed Storage vulnerability. There
is no active production Storage exposure today.

Storage is intentionally left inactive for the first public release: the only
upload path (`ItemImageService`) is reachable only from the unused legacy
`ItemsPage`, while the production UI uses `CatalogItemsPage`. When Storage is
eventually activated, these rules must be deployed **together with** the
activation — never with the default open rules.

## Storage read access is owner-only

`storage.test.js` asserts that one collector **cannot** read another
collector's item image. That is correct today: `ItemImageService` is the only
Storage client, it is used by a single widget, and the download URL is never
stored in Firestore, so no cross-user read path exists. If the product later
shows user photos to other collectors, that test is the one to change
deliberately — together with `storage.rules`.

## Note on fixtures

`tradeFixture` and `conversationFixture` in `helpers.js` mirror the documents
that `TradeService.createTrade` and `ChatService.getOrCreateConversation`
actually write. When those services change their document shape, update the
fixtures too, otherwise the tests stop describing reality.
