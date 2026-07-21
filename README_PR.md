# PR-007.0 – Collection Statistics Foundation

## Dodano
- `CollectionStatistics`
- `CollectionStatisticsService`

## Kaj izračuna
- zbrane različne kartice
- viške nad prvim izvodom
- manjkajoče kartice
- odstotek dokončanosti
- skupno fizično količino kartic

## Pomembno
Ta PR ne spreminja Firestore strukture in še ne spreminja uporabniškega vmesnika.

## Test
```powershell
dart format lib\core\models\collection_statistics.dart lib\core\services\collection_statistics_service.dart
flutter analyze
```

## Commit
`feat(collections): add collection statistics foundation`
