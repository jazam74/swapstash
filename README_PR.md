# PR-008.2 – Neprebrana sporočila na Dashboardu

## Namen
Kartica **Danes te čaka** poleg opravil menjav prikazuje tudi pogovore
z neprebranimi sporočili.

## Novo vedenje
- vsak pogovor z neprebranimi sporočili ustvari svoje opravilo
- opravilo pokaže število neprebranih sporočil
- pod naslovom sta prikazana sogovornik in zbirka
- klik odpre točno povezani pogovor
- ob odprtju se pogovor označi kot prebran
- opravilo nato samodejno izgine z Dashboarda

## Prednost opravil
1. odgovor na ponudbo ali protiponudbo
2. neprebrana sporočila
3. potrditev prejema
4. potrditev predaje

Na Dashboardu je še vedno prikazanih največ pet opravil.

## Firestore
Struktura podatkov se ne spremeni. Uporabljajo se obstoječi:
- `Conversation.unreadCounts`
- `ChatService.watchConversations()`
- `ChatService.markConversationRead()`

## Spremenjene datoteke
- `lib/core/services/chat_service.dart`
- `lib/features/messages/messages_page.dart`
- `lib/features/dashboard/models/dashboard_action.dart`
- `lib/features/dashboard/services/dashboard_trade_action_mapper.dart`
- `lib/features/dashboard/services/dashboard_message_action_mapper.dart`
- `lib/features/dashboard/services/dashboard_service.dart`
- `lib/features/dashboard/dashboard_page.dart`

## Preverjanje
```powershell
dart format lib\core\services\chat_service.dart lib\features\messages\messages_page.dart lib\features\dashboard
flutter analyze
```

Ročni test:
1. Z drugim računom pošlji eno ali več sporočil.
2. Na prejemnikovem Dashboardu mora biti prikazano opravilo.
3. Naslov mora pokazati število neprebranih sporočil.
4. Klik mora odpreti pravi pogovor.
5. Po odprtju in vrnitvi na Dashboard mora opravilo izginiti.
6. Opravila menjav morajo še vedno odpirati pravo menjavo.

## Commit
`feat(dashboard): show unread message tasks`
