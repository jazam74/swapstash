# PR-004.2 – Trade Items Card

## Dodano
- `TradeItemsCard`
- `TradeItemTile`
- prostor za prihodnje slike kartic
- prikaz količine samo, kadar je večja od 1

## Spremenjeno
- `trades_page.dart`
- odstranjena stara zasebna komponenta `_TradeItemsSection`

## Test
- [ ] `dart format lib/features/trades`
- [ ] `flutter analyze`
- [ ] Prejeta menjava: Oddaš/Prejmeš sta pravilno obrnjena
- [ ] Poslana menjava: Oddaš/Prejmeš sta pravilno obrnjena
- [ ] Količina 1 se ne prikazuje kot ×1
- [ ] Količina nad 1 se prikaže kot ×N
- [ ] Prazna stran se izriše brez napake

## Commit
`feat(trades): add trade items cards`
