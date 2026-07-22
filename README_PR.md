# PR-008.1 – Odpri povezano menjavo

## Namen
Klik na opravilo na Dashboardu ne odpre več vedno zavihka **Prejete**.

## Novo vedenje
- opravilo za prejeto menjavo odpre **Prejete**
- opravilo za poslano menjavo odpre **Poslane**
- zaključena menjava lahko odpre **Zaključene**
- povezana menjava se premakne na vrh seznama
- povezana menjava je poudarjena z okvirjem in oznako **Menjava iz opravila**

## Tehnična izvedba
`DashboardAction` zdaj hrani:
- `tradeId`
- `tradeTabIndex`

`TradesPage` zdaj sprejema:
- `initialTabIndex`
- `highlightedTradeId`

Logika same menjave in Firestore struktura se ne spreminjata.

## Test
```powershell
dart format lib\features\dashboard lib\features\trades\trades_page.dart
flutter analyze
```

Ročno preveri:
1. Na računu pošiljatelja klikni **Potrdi predajo kartic**.
2. Odpreti se mora zavihek **Poslane**.
3. Prava menjava mora biti prva in označena.
4. Na računu prejemnika klikni **Odgovori na ponudbo**.
5. Odpreti se mora zavihek **Prejete** z označeno pravo menjavo.

## Commit
`feat(dashboard): open linked trade from task`
