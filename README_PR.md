# PR-009.1 – Javni profil zbiratelja

## Namen

Uporabnik lahko odpre profil drugega zbiratelja iz:

- strani **Zbiratelji**
- glave uporabnika na strani **Primerjava menjave**

## Javni profil prikazuje

- fotografijo in prikazno ime
- kraj in državo pri javnem profilu
- povprečno oceno in število ocen
- število zaključenih menjav
- dovoljenje za mednarodne menjave
- opis uporabnika
- zadnje komentarje po zaključenih menjavah
- gumb **Pošlji sporočilo**

## Zaseben profil

Pri `isPublic == false` ostanejo vidni:

- ime in fotografija
- povprečna ocena
- število zaključenih menjav
- možnost pošiljanja sporočila

Skriti so:

- lokacija
- opis
- komentarji ocen

## Pogovor

Gumb **Pošlji sporočilo** ustvari oziroma odpre splošni neposredni pogovor:

```text
collectionId: direct_messages
collectionName: Splošni pogovor
```

To uporablja obstoječi model pogovorov in ne zahteva spremembe Firestore
strukture.

## Spremenjene datoteke

- `lib/features/users/users_page.dart`
- `lib/features/users/public_user_profile_page.dart`
- `lib/features/users/widgets/user_rating_summary.dart`
- `lib/features/users/widgets/user_rating_list.dart`
- `lib/features/trades/trade_detail_page.dart`
- `lib/core/services/trade_rating_service.dart`

## Firestore

Obstoječa pravila iz PR-009.0A že dovoljujejo prijavljenim uporabnikom branje
ocen. Nova struktura ni potrebna.

## Preverjanje

```powershell
dart format lib\features\users lib\features\trades\trade_detail_page.dart lib\core\services\trade_rating_service.dart
flutter analyze
```

## Ročni test

1. Odpri **Zbiratelji** in poišči uporabnika.
2. Klik na rezultat mora odpreti njegov javni profil.
3. Preveri povprečno oceno, zaključene menjave in komentarje.
4. Klikni **Pošlji sporočilo** in preveri, da se odpre pravi pogovor.
5. Odpri **Poišči menjavo → Primerjava menjave**.
6. Klik na ime oziroma fotografijo zbiratelja mora odpreti isti javni profil.
7. Pri zasebnem profilu morajo biti lokacija, opis in komentarji skriti.

## Commit

```text
feat(users): add public collector profiles
```
