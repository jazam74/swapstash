# PR-008.3 – Zavihek Vse menjave

## Namen
Ob običajnem odprtju strani **Menjave** uporabnik najprej vidi vse svoje
menjave skupaj in mu ni treba vedeti, ali je bila posamezna menjava prejeta,
poslana ali zaključena.

## Novo vedenje
Zavihki so po novem:

1. **Vse**
2. **Prejete**
3. **Poslane**
4. **Zaključene**

Zavihek **Vse** je privzet in združuje:
- prejete menjave
- poslane menjave
- zaključene menjave
- zavrnjene in preklicane menjave

Vsaka menjava je prikazana samo enkrat. Razvrščene so po zadnji spremembi,
najnovejše najprej.

## Neposredno odpiranje iz Dashboarda
Opravila še naprej odpirajo namenski zavihek:
- prejeta menjava → **Prejete**
- poslana menjava → **Poslane**
- zaključena menjava → **Zaključene**

Povezana menjava ostane premaknjena na vrh in poudarjena.

## Spremenjene datoteke
- `lib/features/trades/trades_page.dart`
- `lib/features/dashboard/services/dashboard_trade_action_mapper.dart`

## Firestore
Struktura podatkov se ne spremeni.

## Preverjanje
```powershell
dart format lib\features\trades\trades_page.dart lib\features\dashboard\services\dashboard_trade_action_mapper.dart
flutter analyze
```

Ročni test:
1. Spodaj klikni **Menjave**.
2. Privzeto mora biti izbran zavihek **Vse**.
3. Na seznamu morajo biti skupaj prejete, poslane in zaključene menjave.
4. Najnovejša oziroma nazadnje spremenjena menjava mora biti prva.
5. Klik na opravilo na Dashboardu mora še vedno odpreti pravi namenski zavihek
   in poudariti pravo menjavo.

## Commit
`feat(trades): add all trades overview tab`
