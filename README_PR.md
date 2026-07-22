# PR-009.0A – Popravek Firestore pravil za ocene

## Vzrok napake

Aplikacija je poskušala prebrati:

```text
users/{reviewedUserId}/ratings/{ratingId}
```

v trenutnih Firestore pravilih pa podzbirka `ratings` ni bila dovoljena.
Zato je `StreamBuilder` prejel `permission-denied` in skril gumb za oceno.

Prvotna izvedba je poskušala tudi neposredno posodobiti profil drugega
uporabnika, kar je pravilno blokiralo obstoječe pravilo, da profil spreminja
samo njegov lastnik.

## Popravek

- dodana varna pravila za branje in ustvarjanje ocen
- ocena je dovoljena samo pri zaključeni menjavi
- ocenjevalec mora biti udeleženec menjave
- ocenjen mora biti drugi udeleženec
- ocena mora imeti 1–5 zvezdic
- komentar je omejen na 300 znakov
- dokument ima deterministični ID in ga ni mogoče posodobiti ali izbrisati
- aplikacija ne posodablja več profila drugega uporabnika
- povprečje se izračuna iz nespremenljivih dokumentov ocen
- lastnik profila ne more ročno spreminjati `rating`, `ratingCount` ali
  `completedTrades`

## Namestitev

Datoteko `firestore.rules` prekopiraj v koren projekta in pravila objavi.

S Firebase CLI:

```powershell
firebase deploy --only firestore:rules
```

Ali v Firebase Console odpri:

```text
Firestore Database → Rules
```

prilepi vsebino datoteke in pritisni **Publish**.

## Preverjanje kode

```powershell
dart format lib\core\models\trade_rating_summary.dart lib\core\services\trade_rating_service.dart lib\features\profile\profile_page.dart lib\features\trades\widgets\trade_rating_section.dart
flutter analyze
```

## Ročni test

1. Najprej objavi nova Firestore pravila.
2. Ponovno zaženi oziroma osveži aplikacijo.
3. Odpri **Menjave → Arhiv → Zaključene**.
4. Prikazati se mora gumb **Oceni uporabnika**.
5. Oddaj oceno.
6. Gumb se mora zamenjati s prikazom oddane ocene.
7. Na profilu ocenjenega uporabnika se mora prikazati novo povprečje.
8. Ponovna oddaja istega uporabnika za isto menjavo ne sme biti mogoča.

## Commit

```text
fix(ratings): add secure firestore rules
```
