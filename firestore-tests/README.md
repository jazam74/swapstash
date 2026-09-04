# SwapStash Firestore rules tests

Security-rules tests for `../firestore.rules`, running against the Firestore
emulator. Added in batch **P22A1** together with the `/trades` and
`/conversations` lockdown.

## Requirements

- Node.js 22+
- A JDK (the Firestore emulator is a Java process)

## Running

```bash
cd firestore-tests
npm install
npm test
```

`npm test` starts the emulator, loads the real `firestore.rules` from the
repository root, runs every `*.test.js` file and shuts the emulator down again.
No Firebase login and no cloud project are needed — nothing is deployed.

Tests run with `--test-concurrency=1` on purpose. Every file calls
`clearFirestore()` in `beforeEach`, and the emulator has a single shared
database, so parallel files would wipe each other's fixtures.

## Files

| File | Covers |
|------|--------|
| `helpers.js` | Test environment, fixtures mirroring the documents the Flutter client writes |
| `trades-access.test.js` | Who may read `/trades`, and which queries are still allowed |
| `trades-state-machine.test.js` | Every allowed and forbidden trade status transition |
| `conversations.test.js` | Conversation IDOR, plus the reworked `getOrCreateConversation` write shape |
| `regressions.test.js` | Ratings, chat messages, unread counters and delivery details, which all depend on trades and conversations |

## Note on fixtures

`tradeFixture` and `conversationFixture` in `helpers.js` mirror the documents
that `TradeService.createTrade` and `ChatService.getOrCreateConversation`
actually write. When those services change their document shape, update the
fixtures too, otherwise the tests stop describing reality.
