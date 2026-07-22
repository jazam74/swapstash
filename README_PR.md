# PR-008.4 – Aktivne menjave in Arhiv

## Namen

Zavihka **Prejete** in **Poslane** zdaj prikazujeta samo menjave, pri katerih
postopek še poteka. Zaključena zgodovina je zbrana v zavihku **Arhiv**.

## Glavni zavihki

1. **Vse**
2. **Prejete**
3. **Poslane**
4. **Arhiv**

## Prejete in Poslane

Prikazujejo samo aktivne statuse:

- `pending`
- `countered`
- `accepted`

Iz teh dveh zavihkov so odstranjene:

- zaključene
- zavrnjene
- preklicane

## Arhiv

Vsebuje:

- `completed`
- `rejected`
- `cancelled`

Na vrhu Arhiva so manjši filtri:

- **Vse**
- **Zaključene**
- **Zavrnjene**
- **Preklicane**

Privzeto je izbran filter **Vse**. Menjave so razvrščene po zadnji spremembi,
najnovejše najprej.

## Neposredno odpiranje

Neposredno odpiranje menjave z Dashboarda ostane nespremenjeno. Četrti zavihek
ima še vedno indeks `3`, zato obstoječa navigacija ostane združljiva.

## Firestore

Struktura podatkov se ne spremeni.

## Preverjanje

```powershell
dart format lib\features\trades\trades_page.dart
flutter analyze
```

Ročni test:

1. Preklicana in zavrnjena menjava ne smeta biti več v **Prejete** ali **Poslane**.
2. Obe morata biti vidni v **Arhiv → Vse**.
3. Filter **Zavrnjene** mora prikazati samo zavrnjene.
4. Filter **Preklicane** mora prikazati samo preklicane.
5. Filter **Zaključene** mora prikazati samo uspešno zaključene.
6. Zavihek **Vse** mora še vedno prikazovati celotno zgodovino.

## Commit

`feat(trades): separate active trades from archive`
