# PR-009.1B – Popravek `flutter analyze`

## Vzrok

`dashboard_page.dart` še vedno odpira:

```dart
MessagesPage(initialConversationId: conversationId)
```

PR-009.1A pa je datoteko `messages_page.dart` izdelal iz starejše različice,
ki konstruktorja `initialConversationId` ni več vsebovala. S tem se je izgubila
tudi funkcija, ki iz opravila na domači strani odpre točno določen pogovor.

## Popravek

- vrnjen je neobvezni parameter `initialConversationId`
- po prvem prejetem seznamu pogovorov se samodejno odpre zahtevani pogovor
- pogovor se odpre samo enkrat in se po vrnitvi ne odpira ponovno
- če pogovor prispe v poznejšem Firestore posnetku, ga stran še vedno počaka
- vse štiri uporabe zastarelega `withOpacity` so zamenjane z `withValues`

Popravek ohrani spremembo iz PR-009.1A, zato se pri neposrednih pogovorih
oznaka `Splošni pogovor` še vedno ne prikazuje.

## Datoteka

- `lib/features/messages/messages_page.dart`

## Preverjanje

```powershell
dart format lib\features\messages\messages_page.dart
flutter analyze
```

Pričakovani rezultat:

```text
No issues found!
```

## Ročni test

1. Odpri neposredni pogovor iz javnega profila.
2. Preveri, da oznaka `Splošni pogovor` ni prikazana.
3. Ustvari neprebrano sporočilo z drugim računom.
4. Na domači strani klikni opravilo za neprebrani pogovor.
5. Odpreti se mora točno ta pogovor.
6. Po vrnitvi na seznam se pogovor ne sme samodejno odpreti še enkrat.

## Commit

```text
fix(messages): restore conversation deep link
```
