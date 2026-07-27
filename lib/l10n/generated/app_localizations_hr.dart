// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Croatian (`hr`).
class AppLocalizationsHr extends AppLocalizations {
  AppLocalizationsHr([String locale = 'hr']) : super(locale);

  @override
  String get appName => 'SwapStash';

  @override
  String get home => 'Početna';

  @override
  String get collections => 'Kolekcije';

  @override
  String get trades => 'Zamjene';

  @override
  String get messages => 'Poruke';

  @override
  String get profile => 'Profil';

  @override
  String get welcomeUser => 'Dobro došao, Uroš!';

  @override
  String get welcomeDescription =>
      'Upravljaj svojim kolekcijama i pronađi najbolje zamjene.';

  @override
  String get newMatches => 'Nova podudaranja';

  @override
  String get activeCollections => 'Aktivne kolekcije';

  @override
  String get addCollection => 'Dodaj kolekciju';

  @override
  String get sameCountry => 'Ista država';

  @override
  String get international => 'Međunarodno';

  @override
  String get reviewTrade => 'Pregledaj zamjenu';

  @override
  String get noMessages => 'Nema poruka';

  @override
  String get noMessagesDescription =>
      'Razgovori o zamjenama prikazat će se ovdje.';

  @override
  String get language => 'Jezik';

  @override
  String get internationalTrades => 'Međunarodne zamjene';

  @override
  String get allowed => 'Dopuštene';

  @override
  String get successfulTrades => 'Uspješne zamjene';

  @override
  String get chooseLanguage => 'Odaberi jezik';

  @override
  String get chooseLanguageDescription =>
      'Odaberi jezik koji želiš koristiti u aplikaciji SwapStash. Kasnije ga možeš promijeniti u postavkama.';

  @override
  String get automaticLanguage => 'Automatski – jezik uređaja';

  @override
  String get automaticLanguageDescription =>
      'Automatski koristi podržani jezik uređaja.';

  @override
  String get englishFallbackDescription =>
      'Ako jezik uređaja nije podržan, koristit će se engleski.';

  @override
  String get continueButton => 'Nastavi';

  @override
  String get saving => 'Spremanje…';

  @override
  String get settings => 'Postavke';

  @override
  String get applicationSettings => 'Postavke aplikacije';

  @override
  String get languageSettingsDescription =>
      'Odaberi jezik aplikacije. Promjena se primjenjuje odmah i sprema za buduća pokretanja.';

  @override
  String get languageChanged => 'Jezik je promijenjen.';

  @override
  String get profileLoadError => 'Profil nije moguće učitati:';

  @override
  String get profileMissing => 'Profil ne postoji.';

  @override
  String get unnamedUser => 'Neimenovani korisnik';

  @override
  String get unknownUser => 'Nepoznati korisnik';

  @override
  String get rating => 'Ocjena';

  @override
  String get completedTrades => 'Dovršene zamjene';

  @override
  String get profileVisibility => 'Vidljivost profila';

  @override
  String get publicProfile => 'Javan';

  @override
  String get privateProfile => 'Privatan';

  @override
  String get notAllowed => 'Nisu dopuštene';

  @override
  String get editProfile => 'Uredi profil';

  @override
  String get editProfileSubtitle => 'Ime, grad, opis i privatnost';

  @override
  String get signOut => 'Odjava';

  @override
  String get dashboardCatalogTooltip => 'Katalog kolekcija';

  @override
  String get dashboardFavoritesTooltip => 'Moji favoriti';

  @override
  String get dashboardLoadError => 'Nadzorna ploča nije se mogla učitati';

  @override
  String get dashboardMyCollections => 'Moje kolekcije';

  @override
  String get dashboardShowAll => 'Prikaži sve';

  @override
  String get dashboardOverview => 'Pregled';

  @override
  String get dashboardYourCollections => 'Tvoje kolekcije';

  @override
  String get dashboardWelcomeTitle => 'Dobro došao!';

  @override
  String get dashboardWelcomeSubtitle =>
      'Pregled tvojih kolekcija i aktivnosti.';

  @override
  String get dashboardTodayTasks => 'Danas te čeka';

  @override
  String get dashboardAllDone => 'Sve je riješeno';

  @override
  String get dashboardNoOpenTasks => 'Trenutačno nemaš otvorenih zadataka.';

  @override
  String get dashboardNoCollectionsTitle => 'Još nemaš nijednu kolekciju';

  @override
  String get dashboardNoCollectionsDescription =>
      'Otvori karticu Kolekcije i dodaj svoju prvu kolekciju.';

  @override
  String get dashboardCollected => 'Prikupljeno';

  @override
  String get dashboardDuplicates => 'Duplikati';

  @override
  String get dashboardMissing => 'Nedostaje';

  @override
  String get dashboardCollectionOpenError => 'Kolekciju nije moguće otvoriti.';

  @override
  String get dashboardCollectionNotFound => 'Kolekciju nije moguće pronaći.';

  @override
  String dashboardCollectionOpenErrorDetails(String error) {
    return 'Kolekciju nije moguće otvoriti: $error';
  }

  @override
  String dashboardUnreadMessages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count nepročitanih poruka',
      one: '1 nepročitana poruka',
    );
    return '$_temp0';
  }

  @override
  String get dashboardOpenConversation =>
      'Otvori razgovor i pročitaj nove poruke.';

  @override
  String get dashboardRespondToCounterOffer => 'Odgovori na protuponudu';

  @override
  String get dashboardRespondToOffer => 'Odgovori na ponudu';

  @override
  String get dashboardConfirmHandover => 'Potvrdi predaju kartica';

  @override
  String get dashboardConfirmReceipt => 'Potvrdi primitak kartica';

  @override
  String get dashboardOpenTrade => 'Otvori zamjenu';

  @override
  String get dashboardOpenTradeAndContinue =>
      'Otvori zamjenu i nastavi postupak.';

  @override
  String dashboardTradeWithUser(String userId) {
    return 'Zamjena s korisnikom $userId';
  }

  @override
  String get catalogAddToFavorites => 'Dodaj u favorite';

  @override
  String get catalogAddedToFavorites => 'Predmet je dodan u favorite.';

  @override
  String catalogAdditionalFilterCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dodatnih filtara',
      few: '$count dodatna filtra',
      one: '$count dodatni filtar',
    );
    return '$_temp0';
  }

  @override
  String get catalogAdditionalFilters => 'Dodatni filtri';

  @override
  String catalogAdditionalFiltersCount(int count) {
    return 'Dodatni filtri ($count)';
  }

  @override
  String get catalogAll => 'Sve';

  @override
  String get catalogAllRarities => 'Sve rijetkosti';

  @override
  String get catalogApply => 'Primijeni';

  @override
  String get catalogAttributeBrand => 'Marka';

  @override
  String get catalogAttributeCharacter => 'Lik';

  @override
  String get catalogAttributeCountry => 'Država';

  @override
  String get catalogAttributeDenomination => 'Nominala';

  @override
  String get catalogAttributeFranchise => 'Franšiza';

  @override
  String get catalogAttributeManufacturer => 'Proizvođač';

  @override
  String get catalogAttributeMaterial => 'Materijal';

  @override
  String get catalogAttributeSeries => 'Serija';

  @override
  String get catalogAttributeSet => 'Set';

  @override
  String get catalogAttributeTeam => 'Ekipa';

  @override
  String get catalogAttributeTheme => 'Tema';

  @override
  String get catalogAttributeType => 'Vrsta';

  @override
  String get catalogAttributeYear => 'Godina';

  @override
  String get catalogCancel => 'Odustani';

  @override
  String get catalogCategory => 'Kategorija';

  @override
  String get catalogChooseCsvOrXlsx => 'Odaberi CSV ili XLSX';

  @override
  String get catalogClear => 'Očisti';

  @override
  String get catalogClose => 'Zatvori';

  @override
  String catalogCollectionAddError(String error) {
    return 'Kolekciju nije moguće dodati: $error';
  }

  @override
  String catalogCollectionAdded(String name) {
    return 'Kolekcija „$name” dodana je u tvoje kolekcije.';
  }

  @override
  String get catalogCollectionComplete =>
      'Kolekcija je potpuna. Ne nedostaje nijedan predmet.';

  @override
  String catalogCollectionCreateError(String error) {
    return 'Kolekciju nije moguće stvoriti: $error';
  }

  @override
  String get catalogCollectionCreatePermissionDenied =>
      'Firestore je odbio stvaranje kolekcije. Prijavljeni korisnik treba administratorsku dozvolu.';

  @override
  String catalogCollectionCreatedForImport(String name) {
    return 'Kolekcija „$name” stvorena je i odabrana za uvoz.';
  }

  @override
  String get catalogCollectionId => 'ID kolekcije';

  @override
  String catalogCollectionIdExists(String id) {
    return 'Kolekcija s ID-jem „$id” već postoji.';
  }

  @override
  String get catalogCollectionIdHelp =>
      'Mala slova, brojevi i crtice. Nemoj ga kasnije mijenjati.';

  @override
  String get catalogCollectionIdInvalid =>
      'Upotrijebi samo mala slova, brojeve i crtice.';

  @override
  String get catalogCollectionName => 'Naziv kolekcije';

  @override
  String get catalogCollectionProgress => '📊 Napredak kolekcije';

  @override
  String catalogCollectionsLoadErrorDetails(String error) {
    return 'Kolekcije nije moguće učitati:\n$error';
  }

  @override
  String get catalogCollectionsTitle => 'Katalog kolekcija';

  @override
  String catalogColumnCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count stupaca',
      few: '$count stupca',
      one: '$count stupac',
    );
    return '$_temp0';
  }

  @override
  String get catalogConfirmImport => 'Potvrdi uvoz';

  @override
  String get catalogCreate => 'Stvori';

  @override
  String get catalogCreateNewCollection => 'Stvori novu kolekciju';

  @override
  String get catalogCreatingCollection => 'Stvaranje kolekcije ...';

  @override
  String get catalogDecreaseQuantity => 'Smanji količinu';

  @override
  String get catalogDisableQuickEntry => 'Isključi brzi unos';

  @override
  String get catalogDuplicates => 'Duplikati';

  @override
  String get catalogEnableQuickEntry => 'Uključi brzi unos';

  @override
  String get catalogEnterCollectionId => 'Unesi ID kolekcije.';

  @override
  String get catalogEnterCollectionName => 'Unesi naziv kolekcije.';

  @override
  String catalogFavoriteChangeError(String error) {
    return 'Status favorita nije moguće promijeniti: $error';
  }

  @override
  String get catalogFileErrors => 'Pogreške u datoteci';

  @override
  String get catalogFilterByRarity => 'Filtriraj prema rijetkosti';

  @override
  String get catalogFindTrades => 'Pronađi zamjene';

  @override
  String catalogFirstRows(int count) {
    return 'Prvih $count';
  }

  @override
  String get catalogImageNotAdded => 'Slika još nije dodana';

  @override
  String get catalogImportAction => 'Uvezi';

  @override
  String get catalogImportColumnHelp =>
      'Obavezni stupci su number/broj i name/naziv. Stupci rarity/rijetkost i imageUrl/slika nisu obavezni. Ostali stupci automatski se uvoze kao dodatna svojstva.';

  @override
  String get catalogImportCompleted => 'Uvoz je završen';

  @override
  String catalogImportConfirmRows(int count, String collectionName) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count valjanih redaka',
      few: '$count valjana retka',
      one: '$count valjani redak',
    );
    return 'U kolekciji „$collectionName” obradit će se $_temp0.';
  }

  @override
  String catalogImportCreated(int count) {
    return 'Dodano: $count';
  }

  @override
  String get catalogImportCsvAndExcel => 'CSV i Excel';

  @override
  String catalogImportCsvReadError(String error) {
    return 'CSV datoteku nije moguće pročitati: $error';
  }

  @override
  String get catalogImportDescription =>
      'Uvezi predmete iz CSV ili XLSX datoteke.';

  @override
  String get catalogImportDuplicateNumber => 'Duplikat broja u istoj datoteci.';

  @override
  String get catalogImportExcelNoData => 'Excel datoteka nema podataka.';

  @override
  String get catalogImportExistingSkipped =>
      'Postojeći predmeti bit će preskočeni.';

  @override
  String get catalogImportExistingUpdated =>
      'Postojeći predmeti s istim brojem bit će ažurirani.';

  @override
  String catalogImportFailed(String error) {
    return 'Uvoz nije uspio: $error';
  }

  @override
  String get catalogImportFileNoData => 'Datoteka nema podataka.';

  @override
  String catalogImportFileOpenError(String error) {
    return 'Datoteku nije moguće otvoriti: $error';
  }

  @override
  String get catalogImportFileTooLarge =>
      'Datoteka je veća od dopuštenih 20 MB.';

  @override
  String get catalogImportFileTooltip => 'Uvezi CSV ili XLSX';

  @override
  String catalogImportItems(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count predmeta',
      few: '$count predmeta',
      one: '$count predmet',
    );
    return 'Uvezi $_temp0';
  }

  @override
  String get catalogImportMissingName => 'Nedostaje naziv.';

  @override
  String get catalogImportMissingNameColumn =>
      'Nedostaje obavezni stupac „name” odnosno „naziv”.';

  @override
  String get catalogImportMissingNumber => 'Nedostaje broj.';

  @override
  String get catalogImportMissingNumberColumn =>
      'Nedostaje obavezni stupac „number” odnosno „broj”.';

  @override
  String get catalogImportNoItemsBelowHeader =>
      'Ispod retka zaglavlja nema predmeta.';

  @override
  String get catalogImportPermissionDenied =>
      'Firestore je odbio uvoz. Za uvoz u središnji katalog prijavljeni korisnik mora biti administrator.';

  @override
  String get catalogImportSkipHelp =>
      'Predmeti s već postojećim brojem neće se promijeniti.';

  @override
  String catalogImportSkipped(int count) {
    return 'Preskočeno: $count';
  }

  @override
  String get catalogImportSupportedFilesOnly =>
      'Podržane su samo CSV i XLSX datoteke.';

  @override
  String get catalogImportTitle => 'Uvoz kataloga';

  @override
  String get catalogImportUpdateHelp =>
      'Predmeti s već postojećim brojem bit će ažurirani.';

  @override
  String catalogImportUpdated(int count) {
    return 'Ažurirano: $count';
  }

  @override
  String catalogImportXlsxReadError(String error) {
    return 'XLSX datoteku nije moguće pročitati: $error';
  }

  @override
  String get catalogImporting => 'Uvoz ...';

  @override
  String get catalogIncreaseQuantity => 'Povećaj količinu';

  @override
  String get catalogInvalidNumber => 'Neispravan broj.';

  @override
  String catalogInvalidRows(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count nevaljanih',
      few: '$count nevaljana',
      one: '$count nevaljan',
    );
    return '$_temp0';
  }

  @override
  String get catalogInvalidYear => 'Neispravna godina.';

  @override
  String catalogInventoryLoadErrorDetails(String error) {
    return 'Inventar nije moguće učitati:\n$error';
  }

  @override
  String get catalogItemCount => 'Broj predmeta';

  @override
  String catalogItemDefaultName(String number) {
    return 'Predmet $number';
  }

  @override
  String get catalogItemMarkedMissing => 'Predmet je označen kao nedostajući.';

  @override
  String get catalogItemMissing => 'Predmet nedostaje';

  @override
  String get catalogItemOwned => 'Imaš predmet';

  @override
  String catalogItemStatusLoadErrorDetails(String error) {
    return 'Status predmeta nije moguće učitati:\n$error';
  }

  @override
  String catalogItemsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count predmeta',
      few: '$count predmeta',
      one: '$count predmet',
    );
    return '$_temp0';
  }

  @override
  String catalogItemsLoadErrorDetails(String error) {
    return 'Predmete nije moguće učitati:\n$error';
  }

  @override
  String catalogLoadErrorDetails(String error) {
    return 'Katalog nije moguće učitati:\n$error';
  }

  @override
  String get catalogMissing => 'Nedostaje';

  @override
  String get catalogMissingPlural => 'Nedostaju';

  @override
  String get catalogNewCollection => 'Nova kolekcija';

  @override
  String get catalogNoCollectionsFound => 'Nema pronađenih kolekcija.';

  @override
  String get catalogNoDuplicates => 'Još nemaš duplikata.';

  @override
  String get catalogNoFilterResults =>
      'Nema predmeta koji odgovaraju odabranim filtrima.';

  @override
  String get catalogNoItems => 'U ovoj kolekciji još nema predmeta.';

  @override
  String get catalogNoOwnedItems => 'Još nemaš nijedan predmet.';

  @override
  String get catalogNoSearchResults =>
      'Nema rezultata za pojam pretraživanja i odabrane filtre.';

  @override
  String get catalogNotOwned => 'Nemam';

  @override
  String get catalogOk => 'U redu';

  @override
  String get catalogOpeningFile => 'Otvaranje datoteke ...';

  @override
  String get catalogOther => 'Ostalo';

  @override
  String get catalogOwned => 'Imam';

  @override
  String catalogOwnedSurplusCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Imaš $count duplikata.',
      few: 'Imaš $count duplikata.',
      one: 'Imaš $count duplikat.',
      zero: 'Nemaš duplikata.',
    );
    return '$_temp0';
  }

  @override
  String catalogPiecesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count komada',
      few: '$count komada',
      one: '$count komad',
    );
    return '$_temp0';
  }

  @override
  String get catalogPreview => 'Pregled';

  @override
  String get catalogPublisher => 'Izdavač';

  @override
  String get catalogQuantity => 'Količina';

  @override
  String catalogQuantitySaveError(String error) {
    return 'Količinu nije moguće spremiti: $error';
  }

  @override
  String catalogQuantityUpdated(int quantity) {
    return 'Količina je ažurirana na $quantity.';
  }

  @override
  String get catalogRarity => 'Rijetkost';

  @override
  String get catalogRarityAll => 'Rijetkost: sve';

  @override
  String get catalogRarityCommon => 'Uobičajena';

  @override
  String get catalogRarityLimitedEdition => 'Ograničeno izdanje';

  @override
  String get catalogRarityRare => 'Rijetka';

  @override
  String catalogRaritySelected(String value) {
    return 'Rijetkost: $value';
  }

  @override
  String get catalogRarityUltraRare => 'Vrlo rijetka';

  @override
  String catalogRarityValue(String value) {
    return 'Rijetkost: $value';
  }

  @override
  String get catalogRemoveFromFavorites => 'Ukloni iz favorita';

  @override
  String get catalogRemovedFromFavorites => 'Predmet je uklonjen iz favorita.';

  @override
  String catalogResultsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count rezultata',
      few: '$count rezultata',
      one: '$count rezultat',
    );
    return '$_temp0';
  }

  @override
  String get catalogSearchHint => 'Pretraži broj ili naziv ...';

  @override
  String get catalogSelectTargetCollectionFirst =>
      'Najprije odaberi ciljnu kolekciju.';

  @override
  String get catalogSelectValidFileFirst =>
      'Najprije odaberi valjanu datoteku.';

  @override
  String get catalogSelectedCollectionMissing =>
      'Odabrana kolekcija više ne postoji.';

  @override
  String catalogSheetName(String name) {
    return 'List: $name';
  }

  @override
  String get catalogSkip => 'Preskoči';

  @override
  String get catalogSortItems => 'Razvrstaj predmete';

  @override
  String get catalogSortNameAscending => 'Naziv: A–Ž';

  @override
  String get catalogSortNameDescending => 'Naziv: Ž–A';

  @override
  String get catalogSortNumberAscending => 'Broj: uzlazno';

  @override
  String get catalogSortNumberDescending => 'Broj: silazno';

  @override
  String get catalogSortRarityAscending => 'Rijetkost: A–Ž';

  @override
  String get catalogSortRarityDescending => 'Rijetkost: Ž–A';

  @override
  String catalogSurplusCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '+$count duplikata',
      few: '+$count duplikata',
      one: '+$count duplikat',
    );
    return '$_temp0';
  }

  @override
  String get catalogTargetCollection => 'Ciljna kolekcija';

  @override
  String get catalogTotalPieces => 'Ukupno komada';

  @override
  String get catalogUnnamedItem => 'Bez naziva';

  @override
  String get catalogUpdate => 'Ažuriraj';

  @override
  String catalogValidRows(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count valjanih',
      few: '$count valjana',
      one: '$count valjan',
    );
    return '$_temp0';
  }

  @override
  String get catalogYear => 'Godina';

  @override
  String get cancel => 'Odustani';

  @override
  String get clearSearch => 'Očisti pretraživanje';

  @override
  String get noResults => 'Nema rezultata';

  @override
  String get now => 'Sada';

  @override
  String get sending => 'Slanje...';

  @override
  String get tryAgain => 'Pokušaj ponovno';

  @override
  String get yesterday => 'Jučer';

  @override
  String get weekdayMondayShort => 'Pon';

  @override
  String get weekdayTuesdayShort => 'Uto';

  @override
  String get weekdayWednesdayShort => 'Sri';

  @override
  String get weekdayThursdayShort => 'Čet';

  @override
  String get weekdayFridayShort => 'Pet';

  @override
  String get weekdaySaturdayShort => 'Sub';

  @override
  String get weekdaySundayShort => 'Ned';

  @override
  String messageSendError(String error) {
    return 'Poruku nije moguće poslati:\n$error';
  }

  @override
  String get messagesSearchHint =>
      'Pretraži po korisniku, kolekciji ili poruci';

  @override
  String get messagesConversationEmptyPreview =>
      'Ovaj razgovor još nema poruka.';

  @override
  String messagesYouPreview(String message) {
    return 'Ti: $message';
  }

  @override
  String get messagesEmptyTitle => 'Još nemaš razgovora';

  @override
  String get messagesEmptyDescription =>
      'Razgovor možeš započeti s korisnikom s kojim želiš obaviti zamjenu.';

  @override
  String get messagesTryAnotherSearch =>
      'Pokušaj s drugim pojmom za pretraživanje.';

  @override
  String messagesNoConversationsForQuery(String query) {
    return 'Za „$query” nisu pronađeni razgovori.';
  }

  @override
  String get messagesLoadError => 'Razgovore nije moguće učitati';

  @override
  String get messagesSignInRequired => 'Za pregled poruka moraš se prijaviti.';

  @override
  String get messagesGenericUser => 'korisnikom';

  @override
  String messagesStartConversationWith(String name) {
    return 'Započni razgovor s $name';
  }

  @override
  String messagesConversationAboutCollection(String collectionName) {
    return 'Razgovor se odnosi na kolekciju $collectionName.';
  }

  @override
  String get messagesWriteFirstMessage =>
      'Napiši prvu poruku i dogovorite zamjenu.';

  @override
  String get messagesChatLoadError => 'Poruke nije moguće učitati.';

  @override
  String get messagesWriteMessageHint => 'Napiši poruku...';

  @override
  String get messagesSendMessage => 'Pošalji poruku';

  @override
  String get tradeAccept => 'Prihvati';

  @override
  String get tradeArchiveEmpty => 'Arhiva je prazna.';

  @override
  String tradeAutomaticProposalDescription(
    int offeredCount,
    int requestedCount,
  ) {
    return 'SwapStash predlaže uravnoteženu zamjenu $offeredCount za $requestedCount.';
  }

  @override
  String get tradeAutomaticProposalTitle => 'Automatski prijedlog zamjene';

  @override
  String get tradeBackToResults => 'Natrag na rezultate';

  @override
  String get tradeCanOffer => 'Možeš ponuditi';

  @override
  String get tradeCanReceive => 'Možeš dobiti';

  @override
  String get tradeCancelOffer => 'Otkaži ponudu';

  @override
  String get tradeCardFromCollection => 'Kartica iz kolekcije';

  @override
  String tradeCardsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count kartica',
      few: '$count kartice',
      one: '$count kartica',
    );
    return '$_temp0';
  }

  @override
  String tradeCardsLoadError(String error) {
    return 'Kartice nije moguće učitati:\n$error';
  }

  @override
  String get tradeCollectionMissing => 'Zamjena nema određenu kolekciju.';

  @override
  String get tradeCommentHint => 'Npr. brz dogovor i odlično očuvane kartice.';

  @override
  String get tradeComparisonTitle => 'Usporedba zamjene';

  @override
  String tradeCompletedSteps(int completed, int total) {
    return '$completed od $total koraka';
  }

  @override
  String get tradeConfirmHandoverButton => 'Da, potvrđujem predaju';

  @override
  String get tradeConfirmHandoverDescription =>
      'Potvrdi tek kada si kartice stvarno predao drugoj strani. Nakon potvrde kartice će biti uklonjene iz tvog inventara. Ovaj korak nije moguće poništiti.';

  @override
  String get tradeConfirmHandoverTitle => 'Potvrdi predaju kartica';

  @override
  String get tradeConfirmReceiptButton => 'Da, potvrđujem primitak';

  @override
  String get tradeConfirmReceiptDescription =>
      'Potvrdi tek kada si dogovorene kartice stvarno primio. Nakon potvrde bit će dodane u tvoj inventar. Ovaj korak nije moguće poništiti.';

  @override
  String get tradeConfirmReceiptTitle => 'Potvrdi primitak kartica';

  @override
  String tradeConversationOpenError(String error) {
    return 'Razgovor nije moguće otvoriti:\n$error';
  }

  @override
  String get tradeCounterOfferDescription =>
      'Promijeni ponudu. Omjer nije ograničen pa, primjerice, prijedlog 3 za 3 možeš promijeniti u 5 za 3.';

  @override
  String get tradeCounterOfferItemsUnavailable =>
      'Odabrane kartice više nisu dostupne za protuponudu.';

  @override
  String get tradeCounterOfferNeedsBothSides =>
      'Protuponuda mora sadržavati barem jedan predmet na obje strane.';

  @override
  String tradeCounterOfferSendError(String error) {
    return 'Protuponudu nije moguće poslati: $error';
  }

  @override
  String get tradeCounterOfferTitle => 'Protuponuda';

  @override
  String get tradeDirectionCounterOffer => 'PROTUPONUDA';

  @override
  String get tradeDirectionReceivedOffer => 'PRIMLJENA PONUDA';

  @override
  String get tradeDirectionSentOffer => 'POSLANA PONUDA';

  @override
  String get tradeFilterCancelled => 'Otkazane';

  @override
  String get tradeFilterCompleted => 'Dovršene';

  @override
  String get tradeFilterRejected => 'Odbijene';

  @override
  String get tradeFindTrades => 'Pronađi zamjene';

  @override
  String get tradeFromTask => 'Zamjena iz zadatka';

  @override
  String get tradeHandoverConfirmed => 'Predaja potvrđena ✓';

  @override
  String get tradeHandoverConfirmedSuccess =>
      'Predaja kartica je potvrđena i inventar je ažuriran.';

  @override
  String get tradeIAmOffering => 'Nudim';

  @override
  String get tradeIWant => 'Želim';

  @override
  String get tradeItemSelectionNextStep =>
      'Odabir predmeta dolazi u sljedećem koraku.';

  @override
  String get tradeItemsNextStep => 'Popis predmeta dolazi u sljedećem koraku.';

  @override
  String get tradeLoadError => 'Zamjene nije moguće učitati.';

  @override
  String tradeLoadErrorDetails(String error) {
    return 'Zamjene nije moguće učitati:\n$error';
  }

  @override
  String get tradeNewTrade => 'Nova zamjena';

  @override
  String get tradeNoAvailableItems => 'Nema dostupnih predmeta.';

  @override
  String get tradeNoCancelledTrades => 'Nema otkazanih zamjena.';

  @override
  String get tradeNoCards => 'Nema kartica.';

  @override
  String get tradeNoCompletedTrades => 'Nema dovršenih zamjena.';

  @override
  String get tradeNoIncomingTrades => 'Nema primljenih zamjena.';

  @override
  String get tradeNoMatchesFound => 'Trenutačno nisu pronađene moguće zamjene.';

  @override
  String get tradeNoMatchesHint =>
      'Provjeri jesi li označio duplikate i koriste li drugi korisnici istu kolekciju.';

  @override
  String get tradeNoOutgoingTrades => 'Nema poslanih zamjena.';

  @override
  String get tradeNoRejectedTrades => 'Nema odbijenih zamjena.';

  @override
  String get tradeNoTradesYet => 'Još nemaš nijednu zamjenu.';

  @override
  String get tradeNoUsersMatch =>
      'Nema korisnika koji odgovaraju pretraživanju.';

  @override
  String get tradeOfferAcceptedSuccess => 'Zamjena je prihvaćena.';

  @override
  String get tradeOfferCancelledSuccess => 'Ponuda je otkazana.';

  @override
  String get tradeOfferRejectedSuccess => 'Ponuda je odbijena.';

  @override
  String get tradeOpeningConversation => 'Otvaranje razgovora...';

  @override
  String get tradeOptionalComment => 'Komentar (neobavezno)';

  @override
  String tradePossibleTradesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count mogućih zamjena',
      few: '$count moguće zamjene',
      one: '$count moguća zamjena',
    );
    return '$_temp0';
  }

  @override
  String get tradeProgressAgreed => 'Zamjena dogovorena';

  @override
  String get tradeProgressIHandedOver => 'Predao sam kartice';

  @override
  String get tradeProgressIReceived => 'Primio sam kartice';

  @override
  String get tradeProgressOtherHandedOver => 'Druga strana je predala kartice';

  @override
  String get tradeProgressOtherReceived => 'Druga strana je primila kartice';

  @override
  String get tradeProgressTitle => 'Tijek zamjene';

  @override
  String tradeProposalSendError(String error) {
    return 'Prijedlog zamjene nije moguće poslati:\n$error';
  }

  @override
  String get tradeProposalSentSuccessfully =>
      'Prijedlog zamjene uspješno je poslan.';

  @override
  String get tradeRateUser => 'Ocijeni korisnika';

  @override
  String get tradeRatingQuestion => 'Koliko si zadovoljan obavljenom zamjenom?';

  @override
  String tradeRatingSubmitError(String error) {
    return 'Ocjenu nije moguće poslati: $error';
  }

  @override
  String get tradeRatingSubmitted => 'Ocjena je poslana.';

  @override
  String get tradeRatingSubmittedSuccessfully => 'Ocjena je uspješno poslana.';

  @override
  String get tradeRatingUnavailable =>
      'Ocjenjivanje trenutačno nije dostupno. Provjeri jesu li nova Firestore pravila objavljena.';

  @override
  String get tradeReceiptConfirmed => 'Primitak potvrđen ✓';

  @override
  String get tradeReceiptConfirmedSuccess =>
      'Primitak kartica je potvrđen i inventar je ažuriran.';

  @override
  String get tradeRecipient => 'Primatelj';

  @override
  String get tradeReject => 'Odbij';

  @override
  String get tradeRemoveRecipient => 'Ukloni primatelja';

  @override
  String get tradeSearchUserHint => 'Pretraži korisnika po imenu...';

  @override
  String get tradeSendCounterOffer => 'Pošalji protuponudu';

  @override
  String tradeSendMessageToUser(String name) {
    return 'Pošalji poruku korisniku $name';
  }

  @override
  String get tradeSendProposal => 'Pošalji prijedlog';

  @override
  String get tradeSendingProposal => 'Slanje prijedloga...';

  @override
  String tradeStarsOutOfFive(int value) {
    return '$value od 5';
  }

  @override
  String get tradeSubmitRating => 'Pošalji ocjenu';

  @override
  String get tradeSubmittingRating => 'Slanje ocjene...';

  @override
  String get tradeSuggestAutomatically => 'Automatski predloži zamjenu';

  @override
  String get tradeSummaryTitle => 'Sažetak zamjene';

  @override
  String get tradeTabAll => 'Sve';

  @override
  String get tradeTabArchive => 'Arhiva';

  @override
  String get tradeTabReceived => 'Primljene';

  @override
  String get tradeTabSent => 'Poslane';

  @override
  String get tradeTheirDuplicates => 'Njegovi duplikati';

  @override
  String get tradeTheirDuplicatesYouNeed =>
      'Njegovi duplikati koje ti još nemaš.';

  @override
  String tradeUserCanOffer(String name) {
    return '$name može ponuditi';
  }

  @override
  String tradeUserHasNoDuplicatesYouNeed(String name) {
    return '$name trenutačno nema duplikate koji su ti potrebni.';
  }

  @override
  String tradeUserNeedsNoneOfYourDuplicates(String name) {
    return '$name trenutačno ne treba nijedan tvoj duplikat.';
  }

  @override
  String tradeUserOffers(String name) {
    return '$name nudi:';
  }

  @override
  String tradeUserSearchError(String error) {
    return 'Korisnike nije moguće pretražiti:\n$error';
  }

  @override
  String get tradeWantedItemsNextStep =>
      'Popis željenih predmeta dolazi u sljedećem koraku.';

  @override
  String get tradeWith => 'Zamjena s';

  @override
  String get tradeYouCanOffer => 'Ti možeš ponuditi';

  @override
  String get tradeYouGive => 'Daješ';

  @override
  String get tradeYouOfferColon => 'Ti nudiš:';

  @override
  String tradeYouOfferCount(int count) {
    return '$count nudiš';
  }

  @override
  String get tradeYouReceive => 'Primaš';

  @override
  String tradeYouReceiveCount(int count) {
    return '$count dobivaš';
  }

  @override
  String get tradeYourDuplicatesTheyNeed =>
      'Tvoji duplikati koje ovaj korisnik još nema.';

  @override
  String get tradeAllowsInternationalTrades => 'Dopušta međunarodne zamjene';

  @override
  String tradeActionExecutionError(String error) {
    return 'Radnju nije moguće izvršiti: $error';
  }

  @override
  String get tradeActionCompletedTitle => 'Zamjena je dovršena';

  @override
  String get tradeActionCompletedDescription =>
      'Obje strane potvrdile su predaju i primitak kartica. Inventari su ažurirani.';

  @override
  String get tradeActionRejectedTitle => 'Ponuda je odbijena';

  @override
  String get tradeActionCancelledTitle => 'Ponuda je otkazana';

  @override
  String get tradeActionNoActionRequired =>
      'Za ovu ponudu više nije potrebna nikakva radnja.';

  @override
  String get tradeActionYourTurnTitle => 'Ti si na potezu';

  @override
  String get tradeActionReviewOfferDescription =>
      'Pregledaj kartice i prihvati ponudu, odbij je ili pošalji protuponudu.';

  @override
  String get tradeActionOtherTurnTitle => 'Druga strana je na potezu';

  @override
  String get tradeActionWaitingResponseDescription =>
      'Trenutačno nije potrebna nikakva radnja. Čeka se odgovor drugog korisnika.';

  @override
  String get tradeActionNoActionTitle =>
      'Trenutačno nije potrebna nikakva radnja';

  @override
  String get tradeActionStatusNoResponseDescription =>
      'Status zamjene ne zahtijeva tvoj odgovor.';

  @override
  String get tradeActionNextStepTitle => 'Sljedeći korak';

  @override
  String get tradeActionConfirmHandoverDescription =>
      'Kada svoje kartice stvarno predaš drugoj strani, potvrdi predaju. Zatim će biti oduzete iz tvog inventara.';

  @override
  String get tradeActionConfirmReceiptDescription =>
      'Kada dogovorene kartice stvarno primiš, potvrdi primitak. Zatim će biti dodane u tvoj inventar.';

  @override
  String get tradeActionWaitingOtherHandoverDescription =>
      'Već si potvrdio predaju. Čeka se da druga strana preda svoje kartice.';

  @override
  String get tradeActionWaitingOtherConfirmationTitle =>
      'Čeka se potvrda druge strane';

  @override
  String get tradeActionWaitingOtherReceiptDescription =>
      'Već si potvrdio primitak. Zamjena će se dovršiti kada i druga strana potvrdi primitak.';

  @override
  String get tradeActionWaitingNextConfirmationDescription =>
      'Čeka se sljedeća potvrda druge strane.';

  @override
  String get tradeStatusCompletedTitle => 'Zamjena dovršena';

  @override
  String get tradeStatusCompletedSubtitle =>
      'Oba korisnika potvrdila su predaju i primitak.';

  @override
  String get tradeStatusCompletedBadge => 'Dovršena';

  @override
  String get tradeStatusRejectedTitle => 'Ponuda odbijena';

  @override
  String get tradeStatusRejectedSubtitle =>
      'Ovaj prijedlog zamjene nije prihvaćen.';

  @override
  String get tradeStatusRejectedBadge => 'Odbijena';

  @override
  String get tradeStatusCancelledTitle => 'Ponuda otkazana';

  @override
  String get tradeStatusCancelledSubtitle =>
      'Pošiljatelj je otkazao prijedlog zamjene.';

  @override
  String get tradeStatusCancelledBadge => 'Otkazana';

  @override
  String get tradeStatusCounterOfferReceivedTitle => 'Primio si protuponudu';

  @override
  String get tradeStatusAwaitingYourResponseTitle => 'Ponuda čeka tvoj odgovor';

  @override
  String get tradeStatusReviewOfferSubtitle =>
      'Pregledaj kartice i odaberi Prihvati, Odbij ili Protuponuda.';

  @override
  String get tradeStatusWaitingForYouBadge => 'Čeka tebe';

  @override
  String get tradeStatusCounterOfferSentTitle => 'Protuponuda poslana';

  @override
  String get tradeStatusOfferSentTitle => 'Ponuda poslana';

  @override
  String get tradeStatusWaitingOtherUserSubtitle =>
      'Čeka se odgovor drugog korisnika.';

  @override
  String get tradeStatusWaitingResponseBadge => 'Čeka odgovor';

  @override
  String get tradeStatusReceivedTitle => 'Primio si paket';

  @override
  String get tradeStatusReceivedSubtitle =>
      'Primljene kartice dodane su u inventar. Čeka se još potvrda druge strane.';

  @override
  String get tradeStatusReceivedBadge => 'Primljeno';

  @override
  String get tradeStatusBothOnWayTitle => 'Oba paketa su na putu';

  @override
  String get tradeStatusPackageOnWayTitle => 'Paket je na putu prema tebi';

  @override
  String get tradeStatusBothOnWaySubtitle =>
      'Oba paketa su predana. Kada primiš paket, potvrdi primitak.';

  @override
  String get tradeStatusOtherSentSubtitle =>
      'Druga strana je predala paket. Tvoje kartice su još rezervirane.';

  @override
  String get tradeStatusOnWayBadge => 'Na putu';

  @override
  String get tradeStatusSentTitle => 'Poslao si paket';

  @override
  String get tradeStatusSentSubtitle =>
      'Predane kartice uklonjene su iz inventara. Čeka se druga strana.';

  @override
  String get tradeStatusSentBadge => 'Poslano';

  @override
  String get tradeStatusOtherReceivedTitle => 'Druga strana je primila paket';

  @override
  String get tradeStatusConfirmWhenReceivedSubtitle =>
      'Kada primiš svoju pošiljku, potvrdi primitak.';

  @override
  String get tradeStatusWaitingReceiptBadge => 'Čeka primitak';

  @override
  String get tradeStatusAgreedTitle => 'Zamjena dogovorena';

  @override
  String get tradeStatusAgreedSubtitle =>
      'Kartice na obje strane su rezervirane. Inventar se mijenja tek nakon potvrde predaje ili primitka.';

  @override
  String get tradeStatusAgreedBadge => 'Dogovorena';

  @override
  String get authLoginSubtitle => 'Prijavi se na svoj račun';

  @override
  String get authRegisterSubtitle => 'Izradi novi kolekcionarski račun';

  @override
  String get authDisplayNameLabel => 'Prikazano ime';

  @override
  String get authDisplayNameHint => 'Na primjer Marko';

  @override
  String get authDisplayNameRequired => 'Unesi prikazano ime.';

  @override
  String get authDisplayNameMinLength => 'Ime mora imati najmanje 2 znaka.';

  @override
  String get authDisplayNameMaxLength => 'Ime može imati najviše 40 znakova.';

  @override
  String get authEmailLabel => 'Adresa e-pošte';

  @override
  String get authEmailRequired => 'Unesi adresu e-pošte.';

  @override
  String get authEmailInvalid => 'Unesi valjanu adresu e-pošte.';

  @override
  String get authPasswordLabel => 'Lozinka';

  @override
  String get authShowPassword => 'Prikaži lozinku';

  @override
  String get authHidePassword => 'Sakrij lozinku';

  @override
  String get authPasswordRequired => 'Unesi lozinku.';

  @override
  String get authPasswordMinLength => 'Lozinka mora imati najmanje 6 znakova.';

  @override
  String get authConfirmPasswordLabel => 'Ponovi lozinku';

  @override
  String get authConfirmPasswordRequired => 'Ponovno unesi lozinku.';

  @override
  String get authPasswordsDoNotMatch => 'Lozinke se ne podudaraju.';

  @override
  String get authLoginButton => 'Prijava';

  @override
  String get authCreateAccountButton => 'Izradi račun';

  @override
  String get authNoAccountRegister => 'Još nemaš račun? Registriraj se';

  @override
  String get authHaveAccountLogin => 'Već imaš račun? Prijavi se';

  @override
  String get authInvalidData => 'Uneseni podaci nisu valjani.';

  @override
  String authUnexpectedError(String error) {
    return 'Dogodila se neočekivana pogreška: $error';
  }

  @override
  String get authFirebaseInvalidEmail => 'Adresa e-pošte nije valjana.';

  @override
  String get authFirebaseEmailAlreadyInUse =>
      'Račun s ovom adresom e-pošte već postoji.';

  @override
  String get authFirebaseWeakPassword => 'Lozinka je preslaba.';

  @override
  String get authFirebaseInvalidCredentials =>
      'Adresa e-pošte ili lozinka nisu ispravne.';

  @override
  String get authFirebaseTooManyRequests =>
      'Previše pokušaja. Pokušaj ponovno kasnije.';

  @override
  String get authFirebaseNetworkError => 'Provjeri internetsku vezu.';

  @override
  String get authFirebaseGenericError =>
      'Prijava ili registracija nije uspjela.';

  @override
  String get favoritesTitle => 'Moji favoriti';

  @override
  String get favoritesSearchHint => 'Pretraži favorite';

  @override
  String get favoritesClearSearch => 'Očisti';

  @override
  String get favoritesRemoved => 'Uklonjeno iz favorita.';

  @override
  String favoritesNamedItemRemoved(String name) {
    return '„$name“ je uklonjen iz favorita.';
  }

  @override
  String favoritesRemoveError(String error) {
    return 'Favorit nije moguće ukloniti: $error';
  }

  @override
  String get favoritesUnnamedItem => 'Predmet bez imena';

  @override
  String get favoritesRemoveTooltip => 'Ukloni iz favorita';

  @override
  String get favoritesEmptyTitle => 'Još nemaš favorita';

  @override
  String get favoritesEmptyDescription =>
      'Na stranici s pojedinostima predmeta pritisni srce i predmet će se pojaviti ovdje.';

  @override
  String get favoritesNoResults => 'Nema rezultata.';

  @override
  String favoritesNoResultsForQuery(String query) {
    return 'Za „$query“ nisu pronađeni favoriti.';
  }

  @override
  String get favoritesLoadError => 'Favorite nije moguće učitati.';

  @override
  String get myCollectionsTitle => 'Moje kolekcije';

  @override
  String get myCollectionsAddFromCatalog => 'Dodaj kolekciju iz kataloga';

  @override
  String get myCollectionsAddButton => 'Dodaj kolekciju';

  @override
  String get myCollectionsRemoveTitle => 'Ukloni kolekciju';

  @override
  String myCollectionsRemoveQuestion(String name) {
    return 'Želiš li ukloniti „$name“ iz svojih kolekcija?';
  }

  @override
  String get myCollectionsRemoveButton => 'Ukloni';

  @override
  String myCollectionsRemoved(String name) {
    return '„$name“ je uklonjena iz tvojih kolekcija.';
  }

  @override
  String myCollectionsRemoveError(String error) {
    return 'Kolekciju nije moguće ukloniti: $error';
  }

  @override
  String myCollectionsLoadError(String error) {
    return 'Tvoje kolekcije nije moguće učitati:\n$error';
  }

  @override
  String get myCollectionsCatalogLoadError => 'Kolekciju nije moguće učitati.';

  @override
  String get myCollectionsCatalogMissing => 'Kolekcija iz kataloga ne postoji.';

  @override
  String get myCollectionsStatisticsLoadError =>
      'Statistiku kolekcije nije moguće učitati.';

  @override
  String get myCollectionsStatisticsUnavailable =>
      'Statistika kolekcije nije dostupna.';

  @override
  String get myCollectionsEmptyTitle => 'Još nemaš dodanih kolekcija.';

  @override
  String get myCollectionsEmptyDescription =>
      'Odaberi kolekciju iz središnjeg kataloga.';

  @override
  String get myCollectionsOpenCatalog => 'Otvori katalog';

  @override
  String get myCollectionsUnnamedCollection => 'Kolekcija bez imena';

  @override
  String get myCollectionsMenuTooltip => 'Mogućnosti kolekcije';

  @override
  String get myCollectionsEditMenu => 'Uredi';

  @override
  String get myCollectionsRemoveMenu => 'Ukloni';

  @override
  String myCollectionsProgressCount(int owned, int total) {
    return 'Prikupljeno: $owned / $total';
  }

  @override
  String myCollectionsDuplicateCount(int count) {
    return 'Duplikati: $count';
  }

  @override
  String myCollectionsMissingCount(int count) {
    return 'Nedostaje: $count';
  }

  @override
  String get collectors => 'Kolekcionari';

  @override
  String get editProfileDisplayName => 'Ime za prikaz';

  @override
  String get editProfileCity => 'Grad';

  @override
  String get editProfileBio => 'Opis';

  @override
  String get editProfilePublicTitle => 'Javni profil';

  @override
  String get editProfilePublicSubtitle => 'Drugi korisnici mogu te pronaći.';

  @override
  String get editProfileInternationalTitle => 'Dopusti međunarodne zamjene';

  @override
  String get editProfileInternationalSubtitle =>
      'Možeš primati ponude iz drugih država.';

  @override
  String get editProfileSave => 'Spremi';

  @override
  String get editProfileSaving => 'Spremanje…';

  @override
  String get editProfileSaved => 'Profil je uspješno spremljen.';

  @override
  String editProfileSaveError(String error) {
    return 'Profil nije moguće spremiti: $error';
  }

  @override
  String editProfileLoadError(String error) {
    return 'Profil nije moguće učitati:\n$error';
  }

  @override
  String get editProfileMissing => 'Profil ne postoji.';

  @override
  String get editProfileDisplayNameRequired => 'Unesi ime za prikaz.';

  @override
  String get collectorsSearchLabel => 'Pretraži kolekcionare';

  @override
  String get collectorsSearchHint => 'Unesi ime za prikaz';

  @override
  String collectorsSearchError(String error) {
    return 'Korisnike nije moguće pretražiti:\n$error';
  }

  @override
  String get collectorsNoResults => 'Nisu pronađeni kolekcionari.';

  @override
  String get collectorsSearchDescription =>
      'Pronađi druge kolekcionare prema imenu za prikaz.';

  @override
  String get collectorsInternationalAllowed => 'Međunarodne zamjene dopuštene';

  @override
  String get collectorsLocalOnly => 'Samo lokalne zamjene';

  @override
  String get collectorProfileTitle => 'Profil kolekcionara';

  @override
  String get collectorProfileMissing => 'Korisnički profil ne postoji.';

  @override
  String collectorChatOpenError(String error) {
    return 'Razgovor nije moguće otvoriti:\n$error';
  }

  @override
  String get collectorOpeningChat => 'Otvaranje razgovora…';

  @override
  String get collectorSendMessage => 'Pošalji poruku';

  @override
  String get collectorInternationalTrades => 'Međunarodne zamjene';

  @override
  String get collectorLocalTrades => 'Lokalne zamjene';

  @override
  String get collectorAbout => 'O kolekcionaru';

  @override
  String get collectorPrivateTitle => 'Ovaj profil je privatan';

  @override
  String get collectorPrivateDescription =>
      'Lokacija, opis i komentari ocjena nisu javno prikazani.';

  @override
  String collectorProfileLoadError(String error) {
    return 'Profil nije moguće učitati:\n$error';
  }

  @override
  String get ratingUnavailable => 'Ocjena nije dostupna';

  @override
  String get ratingLoading => 'Učitavanje ocjena';

  @override
  String get ratingNone => 'Nema ocjena';

  @override
  String ratingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ocjena',
      few: '$count ocjene',
      one: '$count ocjena',
    );
    return '$_temp0';
  }

  @override
  String get ratingCommentsLoadError => 'Komentare ocjena nije moguće učitati.';

  @override
  String get ratingNoPublicComments =>
      'Ovaj kolekcionar još nema javnih komentara.';

  @override
  String get ratingRecentComments => 'Najnoviji komentari';

  @override
  String get catalogCategorySportsCards => 'Sportske kartice';

  @override
  String get collectorsNavigation => 'Korisnici';

  @override
  String get tradeManualStepRecipient => 'Primatelj';

  @override
  String get tradeManualStepItems => 'Kartice';

  @override
  String get tradeManualStepSummary => 'Sažetak';

  @override
  String get tradeManualChooseRecipientDescription =>
      'Pronađi kolekcionara kojem želiš poslati ponudu za zamjenu.';

  @override
  String get tradeManualChangeRecipient => 'Promijeni';

  @override
  String get tradeManualLoadingOptions =>
      'Provjeravam zajedničke kolekcije i dostupne kartice…';

  @override
  String tradeManualOptionsError(String error) {
    return 'Kartice za zamjenu nije moguće učitati: $error';
  }

  @override
  String get tradeManualNoCommonCollections => 'Nemate zajedničku kolekciju';

  @override
  String get tradeManualNoCommonCollectionsDescription =>
      'Za ručnu zamjenu oba korisnika moraju imati dodanu barem jednu istu kolekciju.';

  @override
  String get tradeManualNoAvailableItems => 'Trenutačno nema dostupnih kartica';

  @override
  String get tradeManualNeedsBothDirections =>
      'Za ponudu svaki korisnik mora imati barem jedan dostupan duplikat.';

  @override
  String get tradeManualChooseCollection => 'Kolekcija';

  @override
  String get tradeManualSelectionsRemainAcrossCollections =>
      'Jedna ponuda može sadržavati kartice samo iz jedne kolekcije. Promjena kolekcije briše odabir.';

  @override
  String get tradeManualNoOfferedItemsInCollection =>
      'U ovoj kolekciji nemaš dostupnih duplikata.';

  @override
  String get tradeManualNoRequestedItemsInCollection =>
      'Drugi korisnik u ovoj kolekciji nema dostupnih duplikata.';

  @override
  String tradeManualSelectedItems(int count) {
    return 'Odabrano: $count';
  }

  @override
  String tradeManualAvailableQuantity(int count) {
    return 'Dostupno za zamjenu: $count';
  }

  @override
  String get tradeManualChooseAtLeastOneEach =>
      'Odaberi barem jednu karticu na svakoj strani zamjene.';

  @override
  String get tradeManualReviewOffer => 'Pregledaj ponudu';

  @override
  String get tradeManualSummaryRecipient => 'Primatelj';

  @override
  String get tradeManualSummaryOffering => 'Nudim';

  @override
  String get tradeManualSummaryRequesting => 'Želim';

  @override
  String get tradeManualSendOffer => 'Pošalji ponudu';

  @override
  String get tradeManualSendingOffer => 'Slanje ponude…';

  @override
  String get tradeManualOfferCreated => 'Ponuda za zamjenu je poslana.';

  @override
  String tradeManualOfferError(String error) {
    return 'Ponudu nije moguće poslati: $error';
  }

  @override
  String tradeManualYourInventoryUnavailable(String itemNumber) {
    return 'Kartica #$itemNumber više nije dostupna među tvojim duplikatima.';
  }

  @override
  String tradeManualTheirInventoryUnavailable(String itemNumber) {
    return 'Kartica #$itemNumber više nije dostupna kod drugog korisnika.';
  }

  @override
  String tradeManualCatalogItemUnavailable(String itemNumber) {
    return 'Karticu #$itemNumber nije moguće povezati s katalogom.';
  }

  @override
  String get tradeManualInvalidOffer =>
      'Ponuda nije valjana. Provjeri odabrane kartice i količine.';

  @override
  String get tradeManualBack => 'Natrag';

  @override
  String get forgotPassword => 'Zaboravljena lozinka?';

  @override
  String get forgotPasswordTitle => 'Ponovno postavljanje lozinke';

  @override
  String get forgotPasswordDescription =>
      'Unesi adresu e-pošte svojeg računa. Poslat ćemo ti poveznicu za postavljanje nove lozinke.';

  @override
  String get sendPasswordResetEmail => 'Pošalji poveznicu';

  @override
  String get sendingEmail => 'Slanje…';

  @override
  String get passwordResetEmailSentTitle => 'Provjeri e-poštu';

  @override
  String get passwordResetEmailSentDescription =>
      'Ako račun s ovom adresom e-pošte postoji, primit ćeš poveznicu za ponovno postavljanje lozinke.';

  @override
  String get backToSignIn => 'Natrag na prijavu';

  @override
  String passwordResetError(String error) {
    return 'Poveznicu za ponovno postavljanje lozinke nije moguće poslati: $error';
  }

  @override
  String get verifyEmailTitle => 'Potvrdi adresu e-pošte';

  @override
  String verifyEmailDescription(String email) {
    return 'Poslali smo poruku za potvrdu na $email. Otvori poveznicu u poruci, a zatim provjeri status.';
  }

  @override
  String get checkVerificationStatus => 'Provjeri status';

  @override
  String get checkingVerification => 'Provjera…';

  @override
  String get resendVerificationEmail => 'Ponovno pošalji poruku';

  @override
  String get verificationEmailSent => 'Poruka za potvrdu je poslana.';

  @override
  String verificationEmailSendError(String error) {
    return 'Poruku za potvrdu nije moguće poslati: $error';
  }

  @override
  String get emailVerificationConfirmed => 'Adresa e-pošte je potvrđena.';

  @override
  String get emailStillNotVerified => 'Adresa e-pošte još nije potvrđena.';

  @override
  String get continueWithoutVerification => 'Za sada nastavi bez potvrde';

  @override
  String get emailVerified => 'E-pošta je potvrđena';

  @override
  String get emailNotVerified => 'E-pošta nije potvrđena';

  @override
  String get emailVerificationReminder => 'Adresa e-pošte još nije potvrđena';

  @override
  String get accountSecurityTitle => 'Račun i sigurnost';

  @override
  String get accountSecuritySubtitle => 'E-pošta, lozinka i brisanje računa';

  @override
  String get changePasswordTitle => 'Promijeni lozinku';

  @override
  String get changePasswordSubtitle => 'Postavi novu lozinku za prijavu';

  @override
  String get changePasswordDescription =>
      'Radi sigurnosti najprije unesi trenutačnu lozinku, a zatim odaberi novu.';

  @override
  String get currentPassword => 'Trenutačna lozinka';

  @override
  String get currentPasswordRequired => 'Unesi trenutačnu lozinku.';

  @override
  String get newPassword => 'Nova lozinka';

  @override
  String get newPasswordRequired => 'Unesi novu lozinku.';

  @override
  String get newPasswordMustDiffer =>
      'Nova lozinka mora se razlikovati od trenutačne.';

  @override
  String get confirmNewPassword => 'Ponovi novu lozinku';

  @override
  String get confirmNewPasswordRequired => 'Ponovno unesi novu lozinku.';

  @override
  String get changePasswordButton => 'Promijeni lozinku';

  @override
  String get changingPassword => 'Promjena…';

  @override
  String get passwordChanged => 'Lozinka je uspješno promijenjena.';

  @override
  String passwordChangeError(String error) {
    return 'Lozinku nije moguće promijeniti: $error';
  }

  @override
  String get deleteAccountTitle => 'Izbriši račun';

  @override
  String get deleteAccountSubtitle =>
      'Trajno ukloni profil, kolekcije i favorite';

  @override
  String get deleteAccountWarningTitle => 'Ova se radnja ne može poništiti';

  @override
  String get deleteAccountWarning =>
      'Izbrisat će se tvoj profil, inventar, kolekcije, favoriti i račun za prijavu.';

  @override
  String get deleteAccountHistoryNotice =>
      'Radi očuvanja povijesti drugih sudionika dovršene zamjene, poruke i poslane ocjene ostaju spremljene bez tvojeg javnog profila.';

  @override
  String get deleteAccountConfirmationWord => 'IZBRIŠI';

  @override
  String deleteAccountConfirmationLabel(String word) {
    return 'Za potvrdu upiši $word';
  }

  @override
  String deleteAccountConfirmationInvalid(String word) {
    return 'Upiši $word.';
  }

  @override
  String get deleteAccountButton => 'Trajno izbriši račun';

  @override
  String get deletingAccount => 'Brisanje računa…';

  @override
  String get deleteAccountConfirmationTitle => 'Izbrisati ovaj račun?';

  @override
  String get deleteAccountConfirmationMessage =>
      'Račun i tvoji osobni podaci profila bit će trajno uklonjeni.';

  @override
  String accountDeleteError(String error) {
    return 'Račun nije moguće izbrisati: $error';
  }

  @override
  String get signOutConfirmationTitle => 'Odjava';

  @override
  String get signOutConfirmationMessage =>
      'Želiš li se odjaviti s ovog računa?';

  @override
  String get authFirebaseRequiresRecentLogin =>
      'Radi sigurnosti ponovno se prijavi prije nastavka.';

  @override
  String get authFirebaseUserDisabled => 'Ovaj korisnički račun je onemogućen.';

  @override
  String get authFirebaseOperationNotAllowed =>
      'Ovaj način prijave trenutačno nije omogućen.';

  @override
  String get accountDeleteActiveTrades =>
      'Račun nije moguće izbrisati dok imaš aktivne ili nedovršene zamjene.';

  @override
  String get tradeManualShowAllSurpluses => 'Prikaži sve duplikate';

  @override
  String get tradeManualSuggestedSurplusesDescription =>
      'Najprije se prikazuju samo duplikati koji drugom korisniku dopunjuju kolekciju.';

  @override
  String get tradeManualAllSurplusesDescription =>
      'Prikazuju se svi dostupni duplikati oba korisnika.';

  @override
  String get tradeManualNoSuggestedOfferedItemsInCollection =>
      'Nemaš duplikate koji bi ovom korisniku dopunili kolekciju.';

  @override
  String get tradeManualNoSuggestedRequestedItemsInCollection =>
      'Ovaj korisnik nema duplikate koji bi dopunili tvoju kolekciju.';

  @override
  String get tradeRatingTitle => 'Ocjena zamjene';

  @override
  String get tradeRatingYourRating => 'Tvoja ocjena';

  @override
  String get tradeRatingEdit => 'Uredi ocjenu';

  @override
  String get tradeRatingCommentHint => 'Kratak komentar (neobavezno)';

  @override
  String get tradeRatingSaveChanges => 'Spremi promjene';

  @override
  String get tradeRatingUpdating => 'Spremanje promjena...';

  @override
  String get tradeRatingUpdatedSuccessfully => 'Ocjena je uspješno ažurirana.';

  @override
  String get tradeRatingSelectStars => 'Odaberi od 1 do 5 zvjezdica.';

  @override
  String get ratingReviewsTitle => 'Primljene ocjene';

  @override
  String get ratingNoReviews => 'Ovaj kolekcionar još nema ocjena.';

  @override
  String get safetySettingsTitle => 'Sigurnost i privatnost';

  @override
  String get safetyMenu => 'Sigurnosne mogućnosti';

  @override
  String get safetyBlockUser => 'Blokiraj korisnika';

  @override
  String get safetyBlockUserTitle => 'Blokiranje korisnika';

  @override
  String get safetyBlockUserConfirmation =>
      'Ovaj korisnik ti neće moći slati poruke ni nove ponude za zamjenu. Ni ti njemu nećeš moći slati poruke ili novu ponudu.';

  @override
  String get safetyUserBlocked => 'Korisnik je blokiran.';

  @override
  String get safetyUnblockUser => 'Odblokiraj';

  @override
  String get safetyUnblockUserTitle => 'Odblokiranje korisnika';

  @override
  String get safetyUnblockUserConfirmation =>
      'Ponovno dopustiti poruke i nove ponude za zamjenu s ovim korisnikom?';

  @override
  String get safetyUserUnblocked => 'Korisnik je odblokiran.';

  @override
  String get safetyReportUser => 'Prijavi korisnika';

  @override
  String get safetyReportTrade => 'Prijavi zamjenu';

  @override
  String get safetyReportMessage => 'Prijavi poruku';

  @override
  String get safetyReportTitle => 'Pošalji prijavu';

  @override
  String get safetyReportDescription =>
      'Odaberi razlog i po želji dodaj detalje. Prijavu može pregledati samo administrator.';

  @override
  String get safetyReportReason => 'Razlog';

  @override
  String get safetyReportReasonSpam => 'Spam ili neželjeni sadržaj';

  @override
  String get safetyReportReasonHarassment => 'Uznemiravanje ili vrijeđanje';

  @override
  String get safetyReportReasonFraud => 'Sumnja na prijevaru';

  @override
  String get safetyReportReasonInappropriate => 'Neprimjeren sadržaj';

  @override
  String get safetyReportReasonOther => 'Drugo';

  @override
  String get safetyReportDetails => 'Detalji (neobavezno)';

  @override
  String get safetyReportDetailsHint => 'Ukratko opiši što se dogodilo.';

  @override
  String get safetyReportSubmit => 'Pošalji prijavu';

  @override
  String get safetyReportSubmitting => 'Slanje...';

  @override
  String get safetyReportSubmitted => 'Prijava je poslana.';

  @override
  String get safetyReportError => 'Prijavu nije bilo moguće poslati';

  @override
  String get safetyActionError => 'Radnju nije bilo moguće izvršiti';

  @override
  String get safetyBlockedUsers => 'Blokirani korisnici';

  @override
  String get safetyBlockedUsersDescription =>
      'Pregledaj i odblokiraj korisnike.';

  @override
  String get safetyBlockedUsersLoadError =>
      'Blokirane korisnike nije bilo moguće učitati.';

  @override
  String get safetyNoBlockedUsers => 'Nemaš blokiranih korisnika.';

  @override
  String get safetyConversationBlockedByYou =>
      'Blokirao si ovog korisnika. Razgovor ostaje vidljiv, ali nove poruke nije moguće poslati.';

  @override
  String get safetyConversationBlockedByOther =>
      'Slanje novih poruka u ovom razgovoru nije dostupno.';

  @override
  String get safetyProfileBlockedByYou => 'Blokirao si ovog korisnika.';

  @override
  String get safetyProfileBlockedByOther =>
      'Komunikacija s ovim korisnikom nije dostupna.';

  @override
  String get safetyAdminReports => 'Pregled prijava';

  @override
  String get safetyAdminReportsDescription =>
      'Administrativni pregled prijavljenih korisnika i sadržaja.';

  @override
  String get safetyReportsLoadError => 'Prijave nije bilo moguće učitati.';

  @override
  String get safetyNoReports => 'Nema prijava za odabrani filtar.';

  @override
  String get safetyReportTypeUser => 'Korisnik';

  @override
  String get safetyReportTypeMessage => 'Poruka';

  @override
  String get safetyReportTypeTrade => 'Zamjena';

  @override
  String get safetyReportStatusOpen => 'Otvoreno';

  @override
  String get safetyReportStatusReviewing => 'U pregledu';

  @override
  String get safetyReportStatusResolved => 'Riješeno';

  @override
  String get safetyReportStatusDismissed => 'Odbačeno';

  @override
  String get safetyReportStatusUpdated => 'Status prijave je ažuriran.';

  @override
  String get safetyReporterId => 'Prijavitelj';

  @override
  String get safetyReportedUserId => 'Prijavljeni korisnik';

  @override
  String get safetyTargetId => 'Prijavljeni sadržaj';

  @override
  String get safetyConversationId => 'Razgovor';

  @override
  String get tradeDeliverySectionTitle => 'Primopredaja i slanje';

  @override
  String get tradeDeliverySectionDescription =>
      'Odaberi način primopredaje i podijeli potrebne privatne podatke s partnerom za zamjenu.';

  @override
  String get tradeDeliveryYourDetails => 'Tvoji podaci';

  @override
  String get tradeDeliveryPartnerDetails => 'Podaci partnera';

  @override
  String get tradeDeliveryYourDetailsMissing =>
      'Još nisi dodao podatke za primopredaju ili slanje.';

  @override
  String get tradeDeliveryPartnerDetailsMissing =>
      'Partner još nije dodao podatke za primopredaju ili slanje.';

  @override
  String get tradeDeliveryAdd => 'Dodaj';

  @override
  String get tradeDeliveryEdit => 'Uredi';

  @override
  String get tradeDeliveryFormTitle => 'Podaci za primopredaju';

  @override
  String get tradeDeliveryChooseMethod => 'Način primopredaje';

  @override
  String get tradeDeliveryByMail => 'Poštom';

  @override
  String get tradeDeliveryInPerson => 'Osobna primopredaja';

  @override
  String get tradeDeliveryFullName => 'Ime i prezime';

  @override
  String get tradeDeliveryAddressLine1 => 'Adresa';

  @override
  String get tradeDeliveryAddressLine2 => 'Dodatni redak adrese (neobavezno)';

  @override
  String get tradeDeliveryPostalCode => 'Poštanski broj';

  @override
  String get tradeDeliveryCity => 'Mjesto';

  @override
  String get tradeDeliveryCountry => 'Država';

  @override
  String get tradeDeliveryPhone => 'Broj telefona (neobavezno)';

  @override
  String get tradeDeliveryMeetingDetails => 'Detalji osobne primopredaje';

  @override
  String get tradeDeliveryMeetingDetailsHint =>
      'Predloži mjesto, vrijeme ili način dogovora.';

  @override
  String get tradeDeliveryCarrier => 'Dostavna služba (neobavezno)';

  @override
  String get tradeDeliveryCarrierHint => 'Na primjer pošta, GLS ili DPD';

  @override
  String get tradeDeliveryTrackingNumber => 'Broj za praćenje (neobavezno)';

  @override
  String get tradeDeliveryNotes => 'Napomena (neobavezno)';

  @override
  String get tradeDeliveryNotesHint => 'Dodaj važne upute za partnera.';

  @override
  String get tradeDeliveryPrivateTitle => 'Privatni podaci';

  @override
  String get tradeDeliveryPrivateDescription =>
      'Ovi podaci nisu javni. Može ih vidjeti samo drugi sudionik prihvaćene zamjene.';

  @override
  String get tradeDeliveryPrivateShortDescription =>
      'Podaci su vidljivi samo sudionicima ove prihvaćene ili završene zamjene.';

  @override
  String get tradeDeliveryRequiredField => 'Ovo je polje obavezno.';

  @override
  String get tradeDeliverySave => 'Spremi podatke';

  @override
  String get tradeDeliverySaving => 'Spremanje...';

  @override
  String get tradeDeliverySaved => 'Podaci za primopredaju su spremljeni.';

  @override
  String tradeDeliverySaveError(String error) {
    return 'Podatke nije bilo moguće spremiti: $error';
  }

  @override
  String get tradeDeliveryLoadError =>
      'Podatke za primopredaju nije bilo moguće učitati.';

  @override
  String get tradeDeliveryAddress => 'Adresa za slanje';

  @override
  String get tradeDeliveryTrackingMissing => 'Broj za praćenje još nije dodan.';

  @override
  String get tradeDeliveryCopyAddress => 'Kopiraj adresu';

  @override
  String get tradeDeliveryCopyPhone => 'Kopiraj broj telefona';

  @override
  String get tradeDeliveryCopyTracking => 'Kopiraj broj za praćenje';

  @override
  String get tradeDeliveryCopied => 'Podatak je kopiran.';

  @override
  String get continueLabel => 'Nastavi';

  @override
  String get done => 'Gotovo';

  @override
  String get betaOnboardingTitle => 'Predstavljanje aplikacije';

  @override
  String get betaOnboardingSkip => 'Preskoči';

  @override
  String get betaOnboardingStart => 'Započni';

  @override
  String get betaOnboardingCollectionsTitle => 'Zbirke na jednom mjestu';

  @override
  String get betaOnboardingCollectionsDescription =>
      'Označi koje kartice imaš, koje ti nedostaju i koliko duplikata imaš. Pregled zbirke ažurira se tijekom unosa.';

  @override
  String get betaOnboardingTradesTitle => 'Pronađi smislene zamjene';

  @override
  String get betaOnboardingTradesDescription =>
      'SwapStash uspoređuje duplikate i kartice koje nedostaju te predlaže kolekcionare s kojima je moguća obostrano korisna zamjena.';

  @override
  String get betaOnboardingCompleteTradeTitle =>
      'Dogovor, primopredaja i ocjena';

  @override
  String get betaOnboardingCompleteTradeDescription =>
      'Pošalji ponudu, razgovaraj, privatno podijeli podatke za primopredaju ili slanje i nakon završetka ocijeni partnera.';

  @override
  String get betaOnboardingSafetyTitle => 'Sigurnost i kontrola';

  @override
  String get betaOnboardingSafetyDescription =>
      'Blokiraj korisnika, prijavi neprimjeren sadržaj i odluči koji su podaci javni, a koji su vidljivi samo partneru u zamjeni.';

  @override
  String get betaOnboardingShowAgain => 'Ponovno prikaži predstavljanje';

  @override
  String get betaOnboardingShowAgainDescription =>
      'Ponovno pregledaj glavne funkcije aplikacije.';

  @override
  String get legalAcceptanceTitle => 'Uvjeti i privatnost';

  @override
  String get legalAcceptanceHeading => 'Prije nastavka';

  @override
  String get legalAcceptanceDescription =>
      'Pročitaj osnovna pravila korištenja i informacije o obradi osobnih podataka.';

  @override
  String get legalAgeConfirmation =>
      'Potvrđujem da imam najmanje 13 godina. Ako sam u Sloveniji mlađi od 15 godina, imam dopuštenje roditelja ili skrbnika.';

  @override
  String get legalDocumentsConfirmation =>
      'Pročitao sam i prihvaćam Uvjete korištenja i Politiku privatnosti.';

  @override
  String get legalAcceptAndContinue => 'Prihvati i nastavi';

  @override
  String get legalAcceptanceSaving => 'Spremanje prihvaćanja...';

  @override
  String get legalBetaNoticeTitle => 'Zatvorena beta verzija';

  @override
  String get legalBetaNoticeDescription =>
      'Aplikacija se još testira. Funkcije se mogu mijenjati, a povremeno su moguće pogreške ili prekidi.';

  @override
  String get legalTermsTitle => 'Uvjeti korištenja';

  @override
  String get legalPrivacyTitle => 'Politika privatnosti';

  @override
  String get legalEffectiveDate => 'Vrijedi od: 24. srpnja 2026.';

  @override
  String get legalContactFooter =>
      'Voditelj obrade: SwapStash · Kontakt: uros2004@gmail.com';

  @override
  String get legalTermsIntro =>
      'Ovi uvjeti uređuju korištenje aplikacije SwapStash. Korištenjem aplikacije prihvaćaš ih.';

  @override
  String get legalTermsEligibilityTitle => '1. Dob i korisnički račun';

  @override
  String get legalTermsEligibilityBody =>
      'Aplikaciju može koristiti osoba koja ima najmanje 13 godina. Kada primjenjivi zakon zahtijeva višu dob za samostalnu privolu, maloljetni korisnik mora dobiti dopuštenje roditelja ili skrbnika. U Sloveniji korisnik mlađi od 15 godina treba takvo dopuštenje. Korisnik mora navesti točne podatke, čuvati podatke za prijavu i odgovoran je za aktivnosti računa.';

  @override
  String get legalTermsServiceTitle => '2. Svrha usluge i beta verzija';

  @override
  String get legalTermsServiceBody =>
      'SwapStash omogućuje vođenje zbirki, pronalaženje mogućih zamjena, ponude, poruke, dogovor o primopredaji i ocjenjivanje završenih zamjena. SwapStash nije prodavatelj, kupac, posrednik, dostavna služba ni strana dogovora između korisnika. Tijekom beta razdoblja funkcije se mogu mijenjati ili privremeno biti nedostupne.';

  @override
  String get legalTermsConductTitle => '3. Dopušteno korištenje';

  @override
  String get legalTermsConductBody =>
      'Zabranjeni su uznemiravanje, prijetnje, govor mržnje, spam, obmana, prijevara, lažno predstavljanje, nezakonit sadržaj, ometanje aplikacije i neovlaštena automatizirana uporaba. Korisnik ne smije objaviti podatke druge osobe bez odgovarajuće pravne osnove.';

  @override
  String get legalTermsTradesTitle => '4. Zamjene i dostava';

  @override
  String get legalTermsTradesBody =>
      'Korisnici sami provjeravaju stanje, autentičnost i vrijednost predmeta te dogovaraju primopredaju, troškove i praćenje pošiljke. SwapStash ne jamči da će druga strana ispuniti dogovor i ne nadoknađuje izgubljene, oštećene ili sporne pošiljke. Za osobnu primopredaju odaberi sigurno javno mjesto; maloljetnici trebaju uključiti roditelja ili skrbnika.';

  @override
  String get legalTermsContentTitle => '5. Poruke i korisnički sadržaj';

  @override
  String get legalTermsContentBody =>
      'Korisnik ostaje odgovoran za sadržaj koji unese ili pošalje. Radi sigurnosti, prijava, sprječavanja zlouporabe ili zakonskih obveza SwapStash može ograničiti pristup, ukloniti sadržaj ili proslijediti podatke nadležnim tijelima kada je to potrebno i zakonito.';

  @override
  String get legalTermsSuspensionTitle => '6. Blokiranje i mjere';

  @override
  String get legalTermsSuspensionBody =>
      'Korisnici mogu blokirati ili prijaviti druge korisnike. SwapStash može ograničiti ili ukinuti račun kada postoji opravdana sumnja na kršenje uvjeta, zlouporabu, sigurnosni rizik ili nezakonito ponašanje. Kada je moguće, korisnik će biti obaviješten o razlogu.';

  @override
  String get legalTermsLiabilityTitle => '7. Dostupnost i odgovornost';

  @override
  String get legalTermsLiabilityBody =>
      'Usluga se pruža po načelu „kakva jest”. SwapStash nastoji osigurati siguran i pouzdan rad, ali ne jamči neprekidnu dostupnost, potpunu točnost ni uspjeh pojedine zamjene. Ograničenja odgovornosti vrijede samo u zakonom dopuštenom opsegu i ne isključuju prava koja se ne mogu ograničiti.';

  @override
  String get legalTermsChangesTitle => '8. Izmjene, pravo i kontakt';

  @override
  String get legalTermsChangesBody =>
      'Uvjeti se mogu ažurirati zbog novih funkcija, sigurnosnih zahtjeva ili zakona. Kod važnih promjena aplikacija će zatražiti ponovno prihvaćanje. Primjenjuje se pravo Republike Slovenije uz poštovanje obveznih prava korisnika prema pravu njegove države. Pitanja pošalji na uros2004@gmail.com.';

  @override
  String get legalPrivacyIntro =>
      'Ova politika objašnjava koje osobne podatke SwapStash obrađuje, zašto ih koristi i koja prava ima korisnik.';

  @override
  String get legalPrivacyControllerTitle => '1. Voditelj obrade i kontakt';

  @override
  String get legalPrivacyControllerBody =>
      'Voditelj obrade osobnih podataka je SwapStash. Pitanja, zahtjeve ili prigovore u vezi privatnosti pošalji na uros2004@gmail.com.';

  @override
  String get legalPrivacyDataTitle => '2. Podaci koje obrađujemo';

  @override
  String get legalPrivacyDataBody =>
      'Obrađujemo podatke računa i prijave, e-adresu, prikazno ime, državu, grad, jezik, fotografiju profila i opis; podatke o zbirkama, karticama i duplikatima; ponude, statuse zamjena, ocjene, poruke i prijave; dobrovoljno unesene podatke za primopredaju ili slanje; tokene za push obavijesti te osnovne tehničke i sigurnosne podatke.';

  @override
  String get legalPrivacyPurposeTitle => '3. Svrhe i pravne osnove';

  @override
  String get legalPrivacyPurposeBody =>
      'Podatke koristimo za izradu i upravljanje računom, funkcije zbirki i zamjena, komunikaciju, obavijesti, sprječavanje zlouporabe, obradu prijava, sigurnost, podršku i zakonske obveze. Pravne osnove uključuju izvršavanje dogovora s korisnikom, privolu, legitimne interese sigurnosti i poboljšanja usluge te zakonske obveze.';

  @override
  String get legalPrivacyVisibilityTitle =>
      '4. Vidljivost i dijeljenje s drugim korisnicima';

  @override
  String get legalPrivacyVisibilityBody =>
      'Javni profil može prikazivati odabrano ime, fotografiju, lokaciju, opis, ocjene i statistiku zamjena. Poruke su vidljive sudionicima razgovora. Adresa, telefon, podaci osobne primopredaje i praćenje pošiljke vidljivi su samo sudionicima prihvaćene ili završene zamjene. Prijave su u dopuštenom opsegu vidljive prijavitelju i administratoru.';

  @override
  String get legalPrivacyRetentionTitle => '5. Čuvanje i brisanje';

  @override
  String get legalPrivacyRetentionBody =>
      'Podatke čuvamo koliko je potrebno za korištenje računa, sigurnost, rješavanje sporova i zakonske obveze. Korisnik može zatražiti brisanje računa. Neki se zapisi mogu ograničeno čuvati radi sprječavanja zlouporabe, pravnih zahtjeva ili zakonske obveze. Lokalno prihvaćanje dokumenata sprema se na uređaju.';

  @override
  String get legalPrivacyProcessorsTitle => '6. Pružatelji usluga i prijenosi';

  @override
  String get legalPrivacyProcessorsBody =>
      'Za hosting, prijavu, bazu podataka, pohranu fotografija i push obavijesti koristimo Firebase odnosno Google Cloud i druge tehničke pružatelje. Podatke obrađuju prema uputama i ugovornim obvezama. Kod obrade izvan Europskog gospodarskog prostora koriste se odgovarajuće zaštitne mjere poput odluka o primjerenosti ili standardnih ugovornih klauzula.';

  @override
  String get legalPrivacyRightsTitle => '7. Prava korisnika';

  @override
  String get legalPrivacyRightsBody =>
      'Ovisno o okolnostima možeš zatražiti pristup, ispravak, brisanje, ograničenje, prenosivost ili uložiti prigovor. Privolu možeš povući za budućnost. Zahtjeve pošalji na uros2004@gmail.com. Možeš podnijeti pritužbu slovenskom Informacijskom pooblaščencu ili nadležnom nadzornom tijelu.';

  @override
  String get legalPrivacyChildrenTitle => '8. Djeca i mladi';

  @override
  String get legalPrivacyChildrenBody =>
      'SwapStash nije namijenjen djeci mlađoj od 13 godina. Korisnik u dobi od 13 ili 14 godina u Sloveniji mora imati dopuštenje roditelja ili skrbnika. Roditelji ili skrbnici mogu zatražiti pregled ili brisanje podataka maloljetnika. Maloljetnici ne bi trebali javno objavljivati kućnu adresu i osobne primopredaje trebaju obavljati uz odraslu osobu.';

  @override
  String get legalPrivacySecurityTitle => '9. Sigurnost i izmjene politike';

  @override
  String get legalPrivacySecurityBody =>
      'Koristimo tehničke i organizacijske mjere kao što su provjere pristupa, privatne podzbirke, sigurnosna pravila baze, blokiranje, prijave i sigurna prijava. Nijedan sustav nije potpuno siguran. Važne promjene bit će prikazane u aplikaciji i mogu zahtijevati ponovno prihvaćanje.';

  @override
  String get aboutAppTitle => 'O aplikaciji';

  @override
  String get aboutAppDescription =>
      'SwapStash pomaže kolekcionarima voditi zbirke, pronaći odgovarajuće partnere i sigurnije završiti zamjene.';

  @override
  String get aboutVersion => 'Verzija aplikacije';

  @override
  String get aboutVersionLoading => 'Učitavanje verzije...';

  @override
  String get aboutOperator => 'Voditelj obrade';

  @override
  String get aboutContact => 'Kontakt i podrška';

  @override
  String get aboutLegalSection => 'Pravne informacije';

  @override
  String get aboutSendFeedback => 'Pošalji povratne informacije';

  @override
  String get aboutFeedbackEmailSubject =>
      'SwapStash beta – povratne informacije';

  @override
  String get aboutFeedbackOpenError =>
      'Aplikaciju za e-poštu nije bilo moguće otvoriti.';

  @override
  String get aboutBetaFooter =>
      'Zatvorena beta verzija · podaci i funkcije mogu se promijeniti prije javne objave.';

  @override
  String get settingsAboutAndLegalTitle => 'O aplikaciji i pravne informacije';

  @override
  String get settingsAboutAppSubtitle =>
      'Verzija, kontakt, povratne informacije i dokumenti';
}
