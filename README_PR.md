# PR-005.0 – Shared UI Components

## Dodano
- `AppCard`
- `AppSection`
- `AppInfoRow`
- `AppEmptyState`
- `AppLoadingCard`
- `AppConfirmDialog`

## Preverjanje zasnove
- `TradeSummaryCard` je posodobljen tako, da uporablja `AppCard`.
- Videz in poslovna logika povzetka menjave ostaneta enaka.

## Test
- [ ] `dart format lib/shared lib/features/trades/widgets/trade_summary_card.dart`
- [ ] `flutter analyze`
- [ ] Povzetek menjave se še vedno pravilno izriše
- [ ] Oddaš/Prejmeš ostaneta pravilna
- [ ] Datum in oznaka drugega uporabnika ostaneta vidna
- [ ] Kartica nima dvojnega roba ali dvojnega notranjega odmika

## Commit
`refactor(ui): add shared application components`
