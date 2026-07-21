# PR-006.0 – CollectionCard

## Dodano
- `CollectionCardData`
- `CollectionCard`
- `CollectionProgress`
- `CollectionStatsRow`
- `CollectionPopupMenu`

## Pomembno
Ta PR še ne spreminja obstoječih strani.

Nova komponenta:
- ne pozna Firestore modelov,
- ne kliče servisov,
- podpira navadni in kompaktni prikaz,
- podpira klik in meni,
- prikazuje napredek, viške in manjkajoče kartice.

## Test
- [ ] `dart format lib/features/collections/models lib/features/collections/widgets`
- [ ] `flutter analyze`

## Commit
`feat(collections): add reusable collection card`
