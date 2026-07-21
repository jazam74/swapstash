# PR-007.2 – Dashboard V2

## Namen
Dashboard preklopi s starega `CollectionService` in modela `Collection`
na V2 podatke:

- `UserCollectionService`
- `CatalogService`
- `CollectionStatisticsService`
- `CollectionStatistics`
- skupni `CollectionCard`

## Kaj se spremeni
- Dashboard prikazuje enake podatke kot stran **Moje zbirke**
- `19 / 0` se zamenja s pravim razmerjem, npr. `19 / 728`
- pravilno se izračunajo zbrane kartice, viški in manjkajoče
- najboljša in zadnje zbirke uporabljajo skupni `CollectionCard`
- klik na zbirko ali statistiko **Zbirke** odpre `MyCollectionsV2Page`
- odstranjen je začasni gumb **Moje zbirke V2** iz AppBara

## Firestore
Struktura podatkov se ne spremeni.

## Test
```powershell
dart format lib\features\dashboard
flutter analyze
```

Ročno preveri:
- Dashboard pokaže `19 / 728` in ne več `19 / 0`
- Pregled pokaže enake številke kot stran Moje zbirke
- klik na najboljšo zbirko odpre Moje zbirke
- klik na kartico pod Tvoje zbirke odpre Moje zbirke
- klik na statistiko Zbirke odpre Moje zbirke
- sprememba količine kartice sproti osveži oba zaslona

## Commit
`refactor(dashboard): migrate dashboard to v2 collection data`
