// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Slovenian (`sl`).
class AppLocalizationsSl extends AppLocalizations {
  AppLocalizationsSl([String locale = 'sl']) : super(locale);

  @override
  String get appName => 'SwapStash';

  @override
  String get home => 'Domov';

  @override
  String get collections => 'Zbirke';

  @override
  String get trades => 'Menjave';

  @override
  String get messages => 'Sporočila';

  @override
  String get profile => 'Profil';

  @override
  String get welcomeUser => 'Dobrodošel, Uroš!';

  @override
  String get welcomeDescription =>
      'Uredi svoje zbirke in poišči najboljše menjave.';

  @override
  String get newMatches => 'Nova ujemanja';

  @override
  String get activeCollections => 'Aktivne zbirke';

  @override
  String get addCollection => 'Dodaj zbirko';

  @override
  String get sameCountry => 'Ista država';

  @override
  String get international => 'Mednarodno';

  @override
  String get reviewTrade => 'Preglej menjavo';

  @override
  String get noMessages => 'Ni sporočil';

  @override
  String get noMessagesDescription =>
      'Pogovori o menjavah bodo prikazani tukaj.';

  @override
  String get language => 'Jezik';

  @override
  String get internationalTrades => 'Mednarodne menjave';

  @override
  String get allowed => 'Dovoljene';

  @override
  String get successfulTrades => 'Uspešne menjave';
}
