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

  @override
  String get chooseLanguage => 'Izberi jezik';

  @override
  String get chooseLanguageDescription =>
      'Izberi jezik, ki ga želiš uporabljati v aplikaciji SwapStash. Pozneje ga lahko spremeniš v nastavitvah.';

  @override
  String get automaticLanguage => 'Samodejno – jezik naprave';

  @override
  String get automaticLanguageDescription =>
      'Samodejno uporabi podprti jezik telefona.';

  @override
  String get englishFallbackDescription =>
      'Če jezik naprave ni podprt, bo uporabljena angleščina.';

  @override
  String get continueButton => 'Nadaljuj';

  @override
  String get saving => 'Shranjujem…';

  @override
  String get settings => 'Nastavitve';

  @override
  String get applicationSettings => 'Nastavitve aplikacije';

  @override
  String get languageSettingsDescription =>
      'Izberi jezik aplikacije. Sprememba se uporabi takoj in shrani za naslednje zagone.';

  @override
  String get languageChanged => 'Jezik je bil spremenjen.';

  @override
  String get profileLoadError => 'Profila ni bilo mogoče naložiti:';

  @override
  String get profileMissing => 'Profil ne obstaja.';

  @override
  String get unnamedUser => 'Neimenovan uporabnik';

  @override
  String get unknownUser => 'Neznan uporabnik';

  @override
  String get rating => 'Ocena';

  @override
  String get completedTrades => 'Zaključene menjave';

  @override
  String get profileVisibility => 'Vidnost profila';

  @override
  String get publicProfile => 'Javen';

  @override
  String get privateProfile => 'Zaseben';

  @override
  String get notAllowed => 'Niso dovoljene';

  @override
  String get editProfile => 'Uredi profil';

  @override
  String get editProfileSubtitle => 'Ime, mesto, opis in zasebnost';

  @override
  String get signOut => 'Odjava';

  @override
  String get dashboardCatalogTooltip => 'Katalog zbirk';

  @override
  String get dashboardFavoritesTooltip => 'Moji favoriti';

  @override
  String get dashboardLoadError => 'Dashboarda ni bilo mogoče naložiti';

  @override
  String get dashboardMyCollections => 'Moje zbirke';

  @override
  String get dashboardShowAll => 'Prikaži vse';

  @override
  String get dashboardOverview => 'Pregled';

  @override
  String get dashboardYourCollections => 'Tvoje zbirke';

  @override
  String get dashboardWelcomeTitle => 'Dobrodošel!';

  @override
  String get dashboardWelcomeSubtitle => 'Pregled tvojih zbirk in aktivnosti.';

  @override
  String get dashboardTodayTasks => 'Danes te čaka';

  @override
  String get dashboardAllDone => 'Vse je urejeno';

  @override
  String get dashboardNoOpenTasks => 'Trenutno nimaš odprtih opravil.';

  @override
  String get dashboardNoCollectionsTitle => 'Še nimaš nobene zbirke';

  @override
  String get dashboardNoCollectionsDescription =>
      'Odpri zavihek Zbirke in dodaj svojo prvo zbirko.';

  @override
  String get dashboardCollected => 'Zbranih';

  @override
  String get dashboardDuplicates => 'Viški';

  @override
  String get dashboardMissing => 'Manjka';

  @override
  String get dashboardCollectionOpenError => 'Zbirke ni bilo mogoče odpreti.';

  @override
  String get dashboardCollectionNotFound => 'Zbirke ni bilo mogoče najti.';

  @override
  String dashboardCollectionOpenErrorDetails(String error) {
    return 'Zbirke ni bilo mogoče odpreti: $error';
  }

  @override
  String dashboardUnreadMessages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count neprebranih sporočil',
      two: '2 neprebrani sporočili',
      one: '1 neprebrano sporočilo',
    );
    return '$_temp0';
  }

  @override
  String get dashboardOpenConversation =>
      'Odpri pogovor in preberi nova sporočila.';

  @override
  String get dashboardRespondToCounterOffer => 'Odgovori na protiponudbo';

  @override
  String get dashboardRespondToOffer => 'Odgovori na ponudbo';

  @override
  String get dashboardConfirmHandover => 'Potrdi predajo kartic';

  @override
  String get dashboardConfirmReceipt => 'Potrdi prejem kartic';

  @override
  String get dashboardOpenTrade => 'Odpri menjavo';

  @override
  String get dashboardOpenTradeAndContinue =>
      'Odpri menjavo in nadaljuj postopek.';

  @override
  String dashboardTradeWithUser(String userId) {
    return 'Menjava z uporabnikom $userId';
  }

  @override
  String get catalogAddToFavorites => 'Dodaj med priljubljene';

  @override
  String get catalogAddedToFavorites => 'Predmet je dodan med priljubljene.';

  @override
  String catalogAdditionalFilterCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dodatnih filtrov',
      few: '$count dodatni filtri',
      two: '$count dodatna filtra',
      one: '$count dodatni filter',
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
  String get catalogAll => 'Vse';

  @override
  String get catalogAllRarities => 'Vse redkosti';

  @override
  String get catalogApply => 'Uporabi';

  @override
  String get catalogAttributeBrand => 'Znamka';

  @override
  String get catalogAttributeCharacter => 'Lik';

  @override
  String get catalogAttributeCountry => 'Država';

  @override
  String get catalogAttributeDenomination => 'Nominala';

  @override
  String get catalogAttributeFranchise => 'Franšiza';

  @override
  String get catalogAttributeManufacturer => 'Proizvajalec';

  @override
  String get catalogAttributeMaterial => 'Material';

  @override
  String get catalogAttributeSeries => 'Serija';

  @override
  String get catalogAttributeSet => 'Set';

  @override
  String get catalogAttributeTeam => 'Ekipa';

  @override
  String get catalogAttributeTheme => 'Tema';

  @override
  String get catalogAttributeType => 'Tip';

  @override
  String get catalogAttributeYear => 'Leto';

  @override
  String get catalogCancel => 'Prekliči';

  @override
  String get catalogCategory => 'Kategorija';

  @override
  String get catalogChooseCsvOrXlsx => 'Izberi CSV ali XLSX';

  @override
  String get catalogClear => 'Počisti';

  @override
  String get catalogClose => 'Zapri';

  @override
  String catalogCollectionAddError(String error) {
    return 'Zbirke ni bilo mogoče dodati: $error';
  }

  @override
  String catalogCollectionAdded(String name) {
    return 'Zbirka »$name« je bila dodana med tvoje zbirke.';
  }

  @override
  String get catalogCollectionComplete =>
      'Zbirka je popolna. Ni manjkajočih predmetov.';

  @override
  String catalogCollectionCreateError(String error) {
    return 'Zbirke ni bilo mogoče ustvariti: $error';
  }

  @override
  String get catalogCollectionCreatePermissionDenied =>
      'Firestore je ustvarjanje zbirke zavrnil. Prijavljeni uporabnik potrebuje administratorsko dovoljenje.';

  @override
  String catalogCollectionCreatedForImport(String name) {
    return 'Zbirka »$name« je ustvarjena in izbrana za uvoz.';
  }

  @override
  String get catalogCollectionId => 'ID zbirke';

  @override
  String catalogCollectionIdExists(String id) {
    return 'Zbirka z ID-jem »$id« že obstaja.';
  }

  @override
  String get catalogCollectionIdHelp =>
      'Male črke, številke in vezaji. Pozneje ga ne spreminjaj.';

  @override
  String get catalogCollectionIdInvalid =>
      'Uporabi samo male črke, številke in vezaje.';

  @override
  String get catalogCollectionName => 'Ime zbirke';

  @override
  String get catalogCollectionProgress => '📊 Napredek zbirke';

  @override
  String catalogCollectionsLoadErrorDetails(String error) {
    return 'Zbirk ni bilo mogoče naložiti:\n$error';
  }

  @override
  String get catalogCollectionsTitle => 'Katalog zbirk';

  @override
  String catalogColumnCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count stolpcev',
      few: '$count stolpci',
      two: '$count stolpca',
      one: '$count stolpec',
    );
    return '$_temp0';
  }

  @override
  String get catalogConfirmImport => 'Potrdi uvoz';

  @override
  String get catalogCreate => 'Ustvari';

  @override
  String get catalogCreateNewCollection => 'Ustvari novo zbirko';

  @override
  String get catalogCreatingCollection => 'Ustvarjam zbirko ...';

  @override
  String get catalogDecreaseQuantity => 'Zmanjšaj količino';

  @override
  String get catalogDisableQuickEntry => 'Izključi hitri vnos';

  @override
  String get catalogDuplicates => 'Viški';

  @override
  String get catalogEnableQuickEntry => 'Vključi hitri vnos';

  @override
  String get catalogEnterCollectionId => 'Vpiši ID zbirke.';

  @override
  String get catalogEnterCollectionName => 'Vpiši ime zbirke.';

  @override
  String catalogFavoriteChangeError(String error) {
    return 'Priljubljenega stanja ni bilo mogoče spremeniti: $error';
  }

  @override
  String get catalogFileErrors => 'Napake v datoteki';

  @override
  String get catalogFilterByRarity => 'Filtriraj po redkosti';

  @override
  String get catalogFindTrades => 'Najdi menjave';

  @override
  String catalogFirstRows(int count) {
    return 'Prvih $count';
  }

  @override
  String get catalogImageNotAdded => 'Slika še ni dodana';

  @override
  String get catalogImportAction => 'Uvozi';

  @override
  String get catalogImportColumnHelp =>
      'Obvezna stolpca sta number/številka in name/ime. Stolpci rarity/redkost in imageUrl/slika so neobvezni. Ostali stolpci se samodejno uvozijo kot dodatne lastnosti.';

  @override
  String get catalogImportCompleted => 'Uvoz je končan';

  @override
  String catalogImportConfirmRows(int count, String collectionName) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count veljavnih vrstic',
      few: '$count veljavne vrstice',
      two: '$count veljavni vrstici',
      one: '$count veljavna vrstica',
    );
    return 'V zbirki »$collectionName« bo obdelanih $_temp0.';
  }

  @override
  String catalogImportCreated(int count) {
    return 'Dodano: $count';
  }

  @override
  String get catalogImportCsvAndExcel => 'CSV in Excel';

  @override
  String catalogImportCsvReadError(String error) {
    return 'Datoteke CSV ni bilo mogoče prebrati: $error';
  }

  @override
  String get catalogImportDescription =>
      'Uvozi predmete iz CSV ali XLSX datoteke.';

  @override
  String get catalogImportDuplicateNumber =>
      'Podvojena številka v isti datoteki.';

  @override
  String get catalogImportExcelNoData => 'Excelova datoteka nima podatkov.';

  @override
  String get catalogImportExistingSkipped =>
      'Obstoječi predmeti bodo preskočeni.';

  @override
  String get catalogImportExistingUpdated =>
      'Obstoječi predmeti z isto številko bodo posodobljeni.';

  @override
  String catalogImportFailed(String error) {
    return 'Uvoz ni uspel: $error';
  }

  @override
  String get catalogImportFileNoData => 'Datoteka nima podatkov.';

  @override
  String catalogImportFileOpenError(String error) {
    return 'Datoteke ni bilo mogoče odpreti: $error';
  }

  @override
  String get catalogImportFileTooLarge =>
      'Datoteka je večja od dovoljenih 20 MB.';

  @override
  String get catalogImportFileTooltip => 'Uvozi CSV ali XLSX';

  @override
  String catalogImportItems(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count predmetov',
      few: '$count predmete',
      two: '$count predmeta',
      one: '$count predmet',
    );
    return 'Uvozi $_temp0';
  }

  @override
  String get catalogImportMissingName => 'Manjka ime.';

  @override
  String get catalogImportMissingNameColumn =>
      'Manjka obvezni stolpec »name« oziroma »ime«.';

  @override
  String get catalogImportMissingNumber => 'Manjka številka.';

  @override
  String get catalogImportMissingNumberColumn =>
      'Manjka obvezni stolpec »number« oziroma »številka«.';

  @override
  String get catalogImportNoItemsBelowHeader =>
      'Pod naslovno vrstico ni nobenega predmeta.';

  @override
  String get catalogImportPermissionDenied =>
      'Firestore je uvoz zavrnil. Za uvoz v centralni katalog mora biti prijavljeni uporabnik administrator.';

  @override
  String get catalogImportSkipHelp =>
      'Predmeti z že obstoječo številko se ne spremenijo.';

  @override
  String catalogImportSkipped(int count) {
    return 'Preskočeno: $count';
  }

  @override
  String get catalogImportSupportedFilesOnly =>
      'Podprti sta samo datoteki CSV in XLSX.';

  @override
  String get catalogImportTitle => 'Uvoz kataloga';

  @override
  String get catalogImportUpdateHelp =>
      'Predmeti z že obstoječo številko se posodobijo.';

  @override
  String catalogImportUpdated(int count) {
    return 'Posodobljeno: $count';
  }

  @override
  String catalogImportXlsxReadError(String error) {
    return 'Datoteke XLSX ni bilo mogoče prebrati: $error';
  }

  @override
  String get catalogImporting => 'Uvažam ...';

  @override
  String get catalogIncreaseQuantity => 'Povečaj količino';

  @override
  String get catalogInvalidNumber => 'Neveljavno število.';

  @override
  String catalogInvalidRows(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count neveljavnih',
      few: '$count neveljavne',
      two: '$count neveljavni',
      one: '$count neveljavna',
    );
    return '$_temp0';
  }

  @override
  String get catalogInvalidYear => 'Neveljavno leto.';

  @override
  String catalogInventoryLoadErrorDetails(String error) {
    return 'Inventarja ni bilo mogoče naložiti:\n$error';
  }

  @override
  String get catalogItemCount => 'Število predmetov';

  @override
  String catalogItemDefaultName(String number) {
    return 'Predmet $number';
  }

  @override
  String get catalogItemMarkedMissing => 'Predmet je označen kot manjkajoč.';

  @override
  String get catalogItemMissing => 'Predmet manjka';

  @override
  String get catalogItemOwned => 'Predmet imaš';

  @override
  String catalogItemStatusLoadErrorDetails(String error) {
    return 'Statusa predmeta ni bilo mogoče naložiti:\n$error';
  }

  @override
  String catalogItemsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count predmetov',
      few: '$count predmeti',
      two: '$count predmeta',
      one: '$count predmet',
    );
    return '$_temp0';
  }

  @override
  String catalogItemsLoadErrorDetails(String error) {
    return 'Predmetov ni bilo mogoče naložiti:\n$error';
  }

  @override
  String catalogLoadErrorDetails(String error) {
    return 'Kataloga ni bilo mogoče naložiti:\n$error';
  }

  @override
  String get catalogMissing => 'Manjka';

  @override
  String get catalogMissingPlural => 'Manjkajo';

  @override
  String get catalogNewCollection => 'Nova zbirka';

  @override
  String get catalogNoCollectionsFound => 'Ni najdenih zbirk.';

  @override
  String get catalogNoDuplicates => 'Nimaš še nobenih viškov.';

  @override
  String get catalogNoFilterResults =>
      'Za izbrane filtre ni ustreznih predmetov.';

  @override
  String get catalogNoItems => 'V tej zbirki še ni predmetov.';

  @override
  String get catalogNoOwnedItems => 'Nimaš še nobenega predmeta.';

  @override
  String get catalogNoSearchResults =>
      'Za iskani izraz in izbrane filtre ni rezultatov.';

  @override
  String get catalogNotOwned => 'Nimam';

  @override
  String get catalogOk => 'V redu';

  @override
  String get catalogOpeningFile => 'Odpiram datoteko ...';

  @override
  String get catalogOther => 'Drugo';

  @override
  String get catalogOwned => 'Imam';

  @override
  String catalogOwnedSurplusCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Imaš $count viškov.',
      few: 'Imaš $count viške.',
      two: 'Imaš $count viška.',
      one: 'Imaš $count višek.',
      zero: 'Nimaš viškov.',
    );
    return '$_temp0';
  }

  @override
  String catalogPiecesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count kosov',
      few: '$count kosi',
      two: '$count kosa',
      one: '$count kos',
    );
    return '$_temp0';
  }

  @override
  String get catalogPreview => 'Predogled';

  @override
  String get catalogPublisher => 'Založnik';

  @override
  String get catalogQuantity => 'Količina';

  @override
  String catalogQuantitySaveError(String error) {
    return 'Količine ni bilo mogoče shraniti: $error';
  }

  @override
  String catalogQuantityUpdated(int quantity) {
    return 'Količina je posodobljena na $quantity.';
  }

  @override
  String get catalogRarity => 'Redkost';

  @override
  String get catalogRarityAll => 'Redkost: vse';

  @override
  String get catalogRarityCommon => 'Pogosta';

  @override
  String get catalogRarityLimitedEdition => 'Omejena izdaja';

  @override
  String get catalogRarityRare => 'Redka';

  @override
  String catalogRaritySelected(String value) {
    return 'Redkost: $value';
  }

  @override
  String get catalogRarityUltraRare => 'Zelo redka';

  @override
  String catalogRarityValue(String value) {
    return 'Redkost: $value';
  }

  @override
  String get catalogRemoveFromFavorites => 'Odstrani iz priljubljenih';

  @override
  String get catalogRemovedFromFavorites =>
      'Predmet je odstranjen iz priljubljenih.';

  @override
  String catalogResultsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count zadetkov',
      few: '$count zadetki',
      two: '$count zadetka',
      one: '$count zadetek',
    );
    return '$_temp0';
  }

  @override
  String get catalogSearchHint => 'Išči številko ali ime ...';

  @override
  String get catalogSelectTargetCollectionFirst =>
      'Najprej izberi ciljno zbirko.';

  @override
  String get catalogSelectValidFileFirst => 'Najprej izberi veljavno datoteko.';

  @override
  String get catalogSelectedCollectionMissing =>
      'Izbrana zbirka ne obstaja več.';

  @override
  String catalogSheetName(String name) {
    return 'List: $name';
  }

  @override
  String get catalogSkip => 'Preskoči';

  @override
  String get catalogSortItems => 'Razvrsti predmete';

  @override
  String get catalogSortNameAscending => 'Ime: A–Ž';

  @override
  String get catalogSortNameDescending => 'Ime: Ž–A';

  @override
  String get catalogSortNumberAscending => 'Številka: naraščajoče';

  @override
  String get catalogSortNumberDescending => 'Številka: padajoče';

  @override
  String get catalogSortRarityAscending => 'Redkost: A–Ž';

  @override
  String get catalogSortRarityDescending => 'Redkost: Ž–A';

  @override
  String catalogSurplusCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '+$count viškov',
      few: '+$count viški',
      two: '+$count viška',
      one: '+$count višek',
    );
    return '$_temp0';
  }

  @override
  String get catalogTargetCollection => 'Ciljna zbirka';

  @override
  String get catalogTotalPieces => 'Skupaj kosov';

  @override
  String get catalogUnnamedItem => 'Brez imena';

  @override
  String get catalogUpdate => 'Posodobi';

  @override
  String catalogValidRows(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count veljavnih',
      few: '$count veljavne',
      two: '$count veljavni',
      one: '$count veljavna',
    );
    return '$_temp0';
  }

  @override
  String get catalogYear => 'Leto';

  @override
  String get cancel => 'Prekliči';

  @override
  String get clearSearch => 'Počisti iskanje';

  @override
  String get noResults => 'Ni zadetkov';

  @override
  String get now => 'Zdaj';

  @override
  String get sending => 'Pošiljam...';

  @override
  String get tryAgain => 'Poskusi znova';

  @override
  String get yesterday => 'Včeraj';

  @override
  String get weekdayMondayShort => 'Pon';

  @override
  String get weekdayTuesdayShort => 'Tor';

  @override
  String get weekdayWednesdayShort => 'Sre';

  @override
  String get weekdayThursdayShort => 'Čet';

  @override
  String get weekdayFridayShort => 'Pet';

  @override
  String get weekdaySaturdayShort => 'Sob';

  @override
  String get weekdaySundayShort => 'Ned';

  @override
  String messageSendError(String error) {
    return 'Sporočila ni bilo mogoče poslati:\n$error';
  }

  @override
  String get messagesSearchHint => 'Išči po uporabniku, zbirki ali sporočilu';

  @override
  String get messagesConversationEmptyPreview => 'Pogovor še nima sporočil.';

  @override
  String messagesYouPreview(String message) {
    return 'Ti: $message';
  }

  @override
  String get messagesEmptyTitle => 'Še nimaš pogovorov';

  @override
  String get messagesEmptyDescription =>
      'Pogovor lahko začneš pri uporabniku, s katerim želiš opraviti menjavo.';

  @override
  String get messagesTryAnotherSearch => 'Poskusi z drugim iskalnim izrazom.';

  @override
  String messagesNoConversationsForQuery(String query) {
    return 'Za »$query« ni bilo najdenih pogovorov.';
  }

  @override
  String get messagesLoadError => 'Pogovorov ni bilo mogoče naložiti';

  @override
  String get messagesSignInRequired => 'Za ogled sporočil se moraš prijaviti.';

  @override
  String get messagesGenericUser => 'uporabnikom';

  @override
  String messagesStartConversationWith(String name) {
    return 'Začni pogovor z $name';
  }

  @override
  String messagesConversationAboutCollection(String collectionName) {
    return 'Pogovor se nanaša na zbirko $collectionName.';
  }

  @override
  String get messagesWriteFirstMessage =>
      'Napiši prvo sporočilo in se dogovorita za menjavo.';

  @override
  String get messagesChatLoadError => 'Sporočil ni bilo mogoče naložiti.';

  @override
  String get messagesWriteMessageHint => 'Napiši sporočilo...';

  @override
  String get messagesSendMessage => 'Pošlji sporočilo';

  @override
  String get tradeAccept => 'Sprejmi';

  @override
  String get tradeArchiveEmpty => 'Arhiv je prazen.';

  @override
  String tradeAutomaticProposalDescription(
    int offeredCount,
    int requestedCount,
  ) {
    return 'SwapStash predlaga uravnoteženo menjavo $offeredCount za $requestedCount.';
  }

  @override
  String get tradeAutomaticProposalTitle => 'Samodejni predlog menjave';

  @override
  String get tradeBackToResults => 'Nazaj na rezultate';

  @override
  String get tradeCanOffer => 'Lahko ponudiš';

  @override
  String get tradeCanReceive => 'Lahko dobiš';

  @override
  String get tradeCancelOffer => 'Prekliči ponudbo';

  @override
  String get tradeCardFromCollection => 'Kartica iz zbirke';

  @override
  String tradeCardsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count kartic',
      few: '$count kartice',
      two: '$count kartici',
      one: '$count kartica',
    );
    return '$_temp0';
  }

  @override
  String tradeCardsLoadError(String error) {
    return 'Kartic ni bilo mogoče naložiti:\n$error';
  }

  @override
  String get tradeCollectionMissing => 'Menjava nima določene zbirke.';

  @override
  String get tradeCommentHint =>
      'Npr. hiter dogovor in odlično ohranjene kartice.';

  @override
  String get tradeComparisonTitle => 'Primerjava menjave';

  @override
  String tradeCompletedSteps(int completed, int total) {
    return '$completed od $total korakov';
  }

  @override
  String get tradeConfirmHandoverButton => 'Da, potrjujem predajo';

  @override
  String get tradeConfirmHandoverDescription =>
      'Potrdi šele, ko si kartice dejansko predal drugi strani. Po potrditvi bodo kartice odstranjene iz tvojega inventarja. Tega koraka ni mogoče razveljaviti.';

  @override
  String get tradeConfirmHandoverTitle => 'Potrdi predajo kartic';

  @override
  String get tradeConfirmReceiptButton => 'Da, potrjujem prejem';

  @override
  String get tradeConfirmReceiptDescription =>
      'Potrdi šele, ko si dogovorjene kartice dejansko prejel. Po potrditvi bodo dodane v tvoj inventar. Tega koraka ni mogoče razveljaviti.';

  @override
  String get tradeConfirmReceiptTitle => 'Potrdi prejem kartic';

  @override
  String tradeConversationOpenError(String error) {
    return 'Pogovora ni bilo mogoče odpreti:\n$error';
  }

  @override
  String get tradeCounterOfferDescription =>
      'Spremeni ponudbo. Razmerje ni omejeno, zato lahko na primer predlog 3 za 3 spremeniš v 5 za 3.';

  @override
  String get tradeCounterOfferItemsUnavailable =>
      'Izbrane kartice niso več razpoložljive za protiponudbo.';

  @override
  String get tradeCounterOfferNeedsBothSides =>
      'Protiponudba mora vsebovati vsaj en predmet na obeh straneh.';

  @override
  String tradeCounterOfferSendError(String error) {
    return 'Protiponudbe ni bilo mogoče poslati: $error';
  }

  @override
  String get tradeCounterOfferTitle => 'Protiponudba';

  @override
  String get tradeDirectionCounterOffer => 'PROTIPONUDBA';

  @override
  String get tradeDirectionReceivedOffer => 'PREJETA PONUDBA';

  @override
  String get tradeDirectionSentOffer => 'POSLANA PONUDBA';

  @override
  String get tradeFilterCancelled => 'Preklicane';

  @override
  String get tradeFilterCompleted => 'Zaključene';

  @override
  String get tradeFilterRejected => 'Zavrnjene';

  @override
  String get tradeFindTrades => 'Najdi menjave';

  @override
  String get tradeFromTask => 'Menjava iz opravila';

  @override
  String get tradeHandoverConfirmed => 'Predaja potrjena ✓';

  @override
  String get tradeHandoverConfirmedSuccess =>
      'Predaja kartic je potrjena in inventar je posodobljen.';

  @override
  String get tradeIAmOffering => 'Ponujam';

  @override
  String get tradeIWant => 'Želim';

  @override
  String get tradeItemSelectionNextStep =>
      'Izbira predmetov pride v naslednjem koraku.';

  @override
  String get tradeItemsNextStep =>
      'Seznam predmetov pride v naslednjem koraku.';

  @override
  String get tradeLoadError => 'Menjav ni bilo mogoče naložiti.';

  @override
  String tradeLoadErrorDetails(String error) {
    return 'Menjav ni bilo mogoče naložiti:\n$error';
  }

  @override
  String get tradeNewTrade => 'Nova menjava';

  @override
  String get tradeNoAvailableItems => 'Ni razpoložljivih predmetov.';

  @override
  String get tradeNoCancelledTrades => 'Ni preklicanih menjav.';

  @override
  String get tradeNoCards => 'Ni kartic.';

  @override
  String get tradeNoCompletedTrades => 'Ni zaključenih menjav.';

  @override
  String get tradeNoIncomingTrades => 'Ni prejetih menjav.';

  @override
  String get tradeNoMatchesFound => 'Trenutno ni najdenih možnih menjav.';

  @override
  String get tradeNoMatchesHint =>
      'Preveri, ali imaš označene viške in ali drugi uporabniki uporabljajo isto zbirko.';

  @override
  String get tradeNoOutgoingTrades => 'Ni poslanih menjav.';

  @override
  String get tradeNoRejectedTrades => 'Ni zavrnjenih menjav.';

  @override
  String get tradeNoTradesYet => 'Še nimaš nobene menjave.';

  @override
  String get tradeNoUsersMatch => 'Ni uporabnikov, ki ustrezajo iskanju.';

  @override
  String get tradeOfferAcceptedSuccess => 'Menjava je bila sprejeta.';

  @override
  String get tradeOfferCancelledSuccess => 'Ponudba je bila preklicana.';

  @override
  String get tradeOfferRejectedSuccess => 'Ponudba je bila zavrnjena.';

  @override
  String get tradeOpeningConversation => 'Odpiram pogovor...';

  @override
  String get tradeOptionalComment => 'Komentar (neobvezno)';

  @override
  String tradePossibleTradesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count možnih menjav',
      few: '$count možne menjave',
      two: '$count možni menjavi',
      one: '$count možna menjava',
    );
    return '$_temp0';
  }

  @override
  String get tradeProgressAgreed => 'Menjava dogovorjena';

  @override
  String get tradeProgressIHandedOver => 'Predal sem kartice';

  @override
  String get tradeProgressIReceived => 'Prejel sem kartice';

  @override
  String get tradeProgressOtherHandedOver => 'Druga stran je predala kartice';

  @override
  String get tradeProgressOtherReceived => 'Druga stran je prejela kartice';

  @override
  String get tradeProgressTitle => 'Potek menjave';

  @override
  String tradeProposalSendError(String error) {
    return 'Predloga menjave ni bilo mogoče poslati:\n$error';
  }

  @override
  String get tradeProposalSentSuccessfully =>
      'Predlog menjave je bil uspešno poslan.';

  @override
  String get tradeRateUser => 'Oceni uporabnika';

  @override
  String get tradeRatingQuestion => 'Kako si zadovoljen z opravljeno menjavo?';

  @override
  String tradeRatingSubmitError(String error) {
    return 'Ocene ni bilo mogoče oddati: $error';
  }

  @override
  String get tradeRatingSubmitted => 'Ocena je oddana.';

  @override
  String get tradeRatingSubmittedSuccessfully =>
      'Ocena je bila uspešno oddana.';

  @override
  String get tradeRatingUnavailable =>
      'Ocenjevanje trenutno ni na voljo. Preveri, ali so nova Firestore pravila objavljena.';

  @override
  String get tradeReceiptConfirmed => 'Prejem potrjen ✓';

  @override
  String get tradeReceiptConfirmedSuccess =>
      'Prejem kartic je potrjen in inventar je posodobljen.';

  @override
  String get tradeRecipient => 'Prejemnik';

  @override
  String get tradeReject => 'Zavrni';

  @override
  String get tradeRemoveRecipient => 'Odstrani prejemnika';

  @override
  String get tradeSearchUserHint => 'Išči uporabnika po imenu...';

  @override
  String get tradeSendCounterOffer => 'Pošlji protiponudbo';

  @override
  String tradeSendMessageToUser(String name) {
    return 'Pošlji sporočilo uporabniku $name';
  }

  @override
  String get tradeSendProposal => 'Pošlji predlog';

  @override
  String get tradeSendingProposal => 'Pošiljam predlog...';

  @override
  String tradeStarsOutOfFive(int value) {
    return '$value od 5';
  }

  @override
  String get tradeSubmitRating => 'Oddaj oceno';

  @override
  String get tradeSubmittingRating => 'Oddajam oceno...';

  @override
  String get tradeSuggestAutomatically => 'Samodejno predlagaj menjavo';

  @override
  String get tradeSummaryTitle => 'Povzetek menjave';

  @override
  String get tradeTabAll => 'Vse';

  @override
  String get tradeTabArchive => 'Arhiv';

  @override
  String get tradeTabReceived => 'Prejete';

  @override
  String get tradeTabSent => 'Poslane';

  @override
  String get tradeTheirDuplicates => 'Njegovi viški';

  @override
  String get tradeTheirDuplicatesYouNeed =>
      'Njegovi viški, ki jih ti še nimaš.';

  @override
  String tradeUserCanOffer(String name) {
    return '$name lahko ponudi';
  }

  @override
  String tradeUserHasNoDuplicatesYouNeed(String name) {
    return '$name trenutno nima viškov, ki bi jih potreboval.';
  }

  @override
  String tradeUserNeedsNoneOfYourDuplicates(String name) {
    return '$name trenutno ne potrebuje nobenega tvojega viška.';
  }

  @override
  String tradeUserOffers(String name) {
    return '$name ponudi:';
  }

  @override
  String tradeUserSearchError(String error) {
    return 'Uporabnikov ni bilo mogoče poiskati:\n$error';
  }

  @override
  String get tradeWantedItemsNextStep =>
      'Seznam želenih predmetov pride v naslednjem koraku.';

  @override
  String get tradeWith => 'Menjava z';

  @override
  String get tradeYouCanOffer => 'Ti lahko ponudiš';

  @override
  String get tradeYouGive => 'Oddaš';

  @override
  String get tradeYouOfferColon => 'Ti ponudiš:';

  @override
  String tradeYouOfferCount(int count) {
    return '$count ponudiš';
  }

  @override
  String get tradeYouReceive => 'Prejmeš';

  @override
  String tradeYouReceiveCount(int count) {
    return '$count dobiš';
  }

  @override
  String get tradeYourDuplicatesTheyNeed =>
      'Tvoji viški, ki jih ta uporabnik še nima.';

  @override
  String get tradeAllowsInternationalTrades => 'Dovoljuje mednarodne menjave';

  @override
  String tradeActionExecutionError(String error) {
    return 'Dejanja ni bilo mogoče izvesti: $error';
  }

  @override
  String get tradeActionCompletedTitle => 'Menjava je zaključena';

  @override
  String get tradeActionCompletedDescription =>
      'Obe strani sta potrdili predajo in prejem kartic. Inventarja sta posodobljena.';

  @override
  String get tradeActionRejectedTitle => 'Ponudba je bila zavrnjena';

  @override
  String get tradeActionCancelledTitle => 'Ponudba je bila preklicana';

  @override
  String get tradeActionNoActionRequired =>
      'Pri tej ponudbi ni več potrebna nobena akcija.';

  @override
  String get tradeActionYourTurnTitle => 'Na potezi si ti';

  @override
  String get tradeActionReviewOfferDescription =>
      'Preglej kartice in ponudbo sprejmi, zavrni ali pošlji protiponudbo.';

  @override
  String get tradeActionOtherTurnTitle => 'Na potezi je druga stran';

  @override
  String get tradeActionWaitingResponseDescription =>
      'Trenutno ni potrebna nobena akcija. Čaka se odgovor drugega uporabnika.';

  @override
  String get tradeActionNoActionTitle => 'Trenutno ni potrebna nobena akcija';

  @override
  String get tradeActionStatusNoResponseDescription =>
      'Stanje menjave ne zahteva tvojega odziva.';

  @override
  String get tradeActionNextStepTitle => 'Naslednji korak';

  @override
  String get tradeActionConfirmHandoverDescription =>
      'Ko svoje kartice dejansko predaš drugi strani, potrdi predajo. Nato bodo odštete iz tvojega inventarja.';

  @override
  String get tradeActionConfirmReceiptDescription =>
      'Ko dogovorjene kartice dejansko prejmeš, potrdi prejem. Nato bodo dodane v tvoj inventar.';

  @override
  String get tradeActionWaitingOtherHandoverDescription =>
      'Ti si predajo že potrdil. Čaka se, da druga stran preda svoje kartice.';

  @override
  String get tradeActionWaitingOtherConfirmationTitle =>
      'Čaka se potrditev druge strani';

  @override
  String get tradeActionWaitingOtherReceiptDescription =>
      'Ti si prejem že potrdil. Menjava se zaključi, ko tudi druga stran potrdi prejem.';

  @override
  String get tradeActionWaitingNextConfirmationDescription =>
      'Čaka se naslednja potrditev druge strani.';

  @override
  String get tradeStatusCompletedTitle => 'Menjava zaključena';

  @override
  String get tradeStatusCompletedSubtitle =>
      'Oba uporabnika sta potrdila pošiljanje in prejem.';

  @override
  String get tradeStatusCompletedBadge => 'Zaključena';

  @override
  String get tradeStatusRejectedTitle => 'Ponudba zavrnjena';

  @override
  String get tradeStatusRejectedSubtitle =>
      'Ta predlog menjave ni bil sprejet.';

  @override
  String get tradeStatusRejectedBadge => 'Zavrnjena';

  @override
  String get tradeStatusCancelledTitle => 'Ponudba preklicana';

  @override
  String get tradeStatusCancelledSubtitle =>
      'Pošiljatelj je predlog menjave preklical.';

  @override
  String get tradeStatusCancelledBadge => 'Preklicana';

  @override
  String get tradeStatusCounterOfferReceivedTitle => 'Prejel si protiponudbo';

  @override
  String get tradeStatusAwaitingYourResponseTitle =>
      'Ponudba čaka na tvoj odgovor';

  @override
  String get tradeStatusReviewOfferSubtitle =>
      'Preglej kartice in izberi Sprejmi, Zavrni ali Protiponudba.';

  @override
  String get tradeStatusWaitingForYouBadge => 'Čaka nate';

  @override
  String get tradeStatusCounterOfferSentTitle => 'Protiponudba poslana';

  @override
  String get tradeStatusOfferSentTitle => 'Ponudba poslana';

  @override
  String get tradeStatusWaitingOtherUserSubtitle =>
      'Čaka se odgovor drugega uporabnika.';

  @override
  String get tradeStatusWaitingResponseBadge => 'Čaka odgovor';

  @override
  String get tradeStatusReceivedTitle => 'Paket si prejel';

  @override
  String get tradeStatusReceivedSubtitle =>
      'Prejete kartice so dodane v inventar. Čaka se še potrditev druge strani.';

  @override
  String get tradeStatusReceivedBadge => 'Prejel';

  @override
  String get tradeStatusBothOnWayTitle => 'Pošiljki sta na poti';

  @override
  String get tradeStatusPackageOnWayTitle => 'Paket je na poti k tebi';

  @override
  String get tradeStatusBothOnWaySubtitle =>
      'Obe pošiljki sta oddani. Ko paket prejmeš, potrdi prejem.';

  @override
  String get tradeStatusOtherSentSubtitle =>
      'Druga stran je paket oddala. Tvoje kartice so še rezervirane.';

  @override
  String get tradeStatusOnWayBadge => 'Na poti';

  @override
  String get tradeStatusSentTitle => 'Paket si poslal';

  @override
  String get tradeStatusSentSubtitle =>
      'Oddane kartice so odstranjene iz inventarja. Čaka se druga stran.';

  @override
  String get tradeStatusSentBadge => 'Poslal';

  @override
  String get tradeStatusOtherReceivedTitle => 'Druga stran je paket prejela';

  @override
  String get tradeStatusConfirmWhenReceivedSubtitle =>
      'Ko prejmeš svojo pošiljko, potrdi prejem.';

  @override
  String get tradeStatusWaitingReceiptBadge => 'Čaka prejem';

  @override
  String get tradeStatusAgreedTitle => 'Menjava dogovorjena';

  @override
  String get tradeStatusAgreedSubtitle =>
      'Kartice na obeh straneh so rezervirane. Inventar se spremeni šele ob potrditvi pošiljanja ali prejema.';

  @override
  String get tradeStatusAgreedBadge => 'Dogovorjena';

  @override
  String get authLoginSubtitle => 'Prijavi se v svoj račun';

  @override
  String get authRegisterSubtitle => 'Ustvari nov zbirateljski račun';

  @override
  String get authDisplayNameLabel => 'Prikazno ime';

  @override
  String get authDisplayNameHint => 'Na primer Uroš';

  @override
  String get authDisplayNameRequired => 'Vpiši prikazno ime.';

  @override
  String get authDisplayNameMinLength => 'Ime mora imeti najmanj 2 znaka.';

  @override
  String get authDisplayNameMaxLength => 'Ime ima lahko največ 40 znakov.';

  @override
  String get authEmailLabel => 'E-poštni naslov';

  @override
  String get authEmailRequired => 'Vpiši e-poštni naslov.';

  @override
  String get authEmailInvalid => 'Vpiši veljaven e-poštni naslov.';

  @override
  String get authPasswordLabel => 'Geslo';

  @override
  String get authShowPassword => 'Prikaži geslo';

  @override
  String get authHidePassword => 'Skrij geslo';

  @override
  String get authPasswordRequired => 'Vpiši geslo.';

  @override
  String get authPasswordMinLength => 'Geslo mora imeti najmanj 6 znakov.';

  @override
  String get authConfirmPasswordLabel => 'Ponovi geslo';

  @override
  String get authConfirmPasswordRequired => 'Ponovno vpiši geslo.';

  @override
  String get authPasswordsDoNotMatch => 'Gesli se ne ujemata.';

  @override
  String get authLoginButton => 'Prijava';

  @override
  String get authCreateAccountButton => 'Ustvari račun';

  @override
  String get authNoAccountRegister => 'Še nimaš računa? Registriraj se';

  @override
  String get authHaveAccountLogin => 'Že imaš račun? Prijavi se';

  @override
  String get authInvalidData => 'Podatki niso veljavni.';

  @override
  String authUnexpectedError(String error) {
    return 'Prišlo je do nepričakovane napake: $error';
  }

  @override
  String get authFirebaseInvalidEmail => 'E-poštni naslov ni veljaven.';

  @override
  String get authFirebaseEmailAlreadyInUse =>
      'Račun s tem e-poštnim naslovom že obstaja.';

  @override
  String get authFirebaseWeakPassword => 'Geslo je prešibko.';

  @override
  String get authFirebaseInvalidCredentials =>
      'E-poštni naslov ali geslo ni pravilno.';

  @override
  String get authFirebaseTooManyRequests =>
      'Preveč poskusov. Poskusi ponovno pozneje.';

  @override
  String get authFirebaseNetworkError => 'Preveri internetno povezavo.';

  @override
  String get authFirebaseGenericError => 'Prijava ali registracija ni uspela.';

  @override
  String get favoritesTitle => 'Moji favoriti';

  @override
  String get favoritesSearchHint => 'Išči med favoriti';

  @override
  String get favoritesClearSearch => 'Počisti';

  @override
  String get favoritesRemoved => 'Odstranjeno iz favoritov.';

  @override
  String favoritesNamedItemRemoved(String name) {
    return 'Predmet »$name« je odstranjen iz favoritov.';
  }

  @override
  String favoritesRemoveError(String error) {
    return 'Napaka pri odstranjevanju: $error';
  }

  @override
  String get favoritesUnnamedItem => 'Brez imena';

  @override
  String get favoritesRemoveTooltip => 'Odstrani iz favoritov';

  @override
  String get favoritesEmptyTitle => 'Še nimaš favoritov';

  @override
  String get favoritesEmptyDescription =>
      'Na podrobnostih kartice pritisni srček in kartica se bo pojavila tukaj.';

  @override
  String get favoritesNoResults => 'Ni zadetkov.';

  @override
  String favoritesNoResultsForQuery(String query) {
    return 'Za »$query« ni bilo najdenih favoritov.';
  }

  @override
  String get favoritesLoadError => 'Favoritov ni bilo mogoče naložiti.';

  @override
  String get myCollectionsTitle => 'Moje zbirke';

  @override
  String get myCollectionsAddFromCatalog => 'Dodaj zbirko iz kataloga';

  @override
  String get myCollectionsAddButton => 'Dodaj zbirko';

  @override
  String get myCollectionsRemoveTitle => 'Odstrani zbirko';

  @override
  String myCollectionsRemoveQuestion(String name) {
    return 'Ali želiš zbirko »$name« odstraniti iz svojih zbirk?';
  }

  @override
  String get myCollectionsRemoveButton => 'Odstrani';

  @override
  String myCollectionsRemoved(String name) {
    return 'Zbirka »$name« je bila odstranjena.';
  }

  @override
  String myCollectionsRemoveError(String error) {
    return 'Zbirke ni bilo mogoče odstraniti: $error';
  }

  @override
  String myCollectionsLoadError(String error) {
    return 'Tvojih zbirk ni bilo mogoče naložiti:\n$error';
  }

  @override
  String get myCollectionsCatalogLoadError => 'Zbirke ni bilo mogoče naložiti.';

  @override
  String get myCollectionsCatalogMissing => 'Kataloška zbirka ne obstaja.';

  @override
  String get myCollectionsStatisticsLoadError =>
      'Statistike zbirke ni bilo mogoče naložiti.';

  @override
  String get myCollectionsStatisticsUnavailable =>
      'Statistika zbirke ni na voljo.';

  @override
  String get myCollectionsEmptyTitle => 'Še nimaš dodanih zbirk.';

  @override
  String get myCollectionsEmptyDescription =>
      'Izberi zbirko iz centralnega kataloga.';

  @override
  String get myCollectionsOpenCatalog => 'Odpri katalog';

  @override
  String get myCollectionsUnnamedCollection => 'Neimenovana zbirka';

  @override
  String get myCollectionsMenuTooltip => 'Možnosti zbirke';

  @override
  String get myCollectionsEditMenu => 'Uredi';

  @override
  String get myCollectionsRemoveMenu => 'Odstrani';

  @override
  String myCollectionsProgressCount(int owned, int total) {
    return 'Zbrano: $owned / $total';
  }

  @override
  String myCollectionsDuplicateCount(int count) {
    return 'Viški: $count';
  }

  @override
  String myCollectionsMissingCount(int count) {
    return 'Manjka: $count';
  }

  @override
  String get collectors => 'Zbiratelji';

  @override
  String get editProfileDisplayName => 'Prikazno ime';

  @override
  String get editProfileCity => 'Mesto';

  @override
  String get editProfileBio => 'Opis';

  @override
  String get editProfilePublicTitle => 'Javni profil';

  @override
  String get editProfilePublicSubtitle => 'Drugi uporabniki te lahko najdejo.';

  @override
  String get editProfileInternationalTitle => 'Dovolim mednarodne menjave';

  @override
  String get editProfileInternationalSubtitle =>
      'Ponudbe lahko prejmeš tudi iz drugih držav.';

  @override
  String get editProfileSave => 'Shrani';

  @override
  String get editProfileSaving => 'Shranjujem…';

  @override
  String get editProfileSaved => 'Profil je bil uspešno shranjen.';

  @override
  String editProfileSaveError(String error) {
    return 'Profila ni bilo mogoče shraniti: $error';
  }

  @override
  String editProfileLoadError(String error) {
    return 'Profila ni bilo mogoče naložiti:\n$error';
  }

  @override
  String get editProfileMissing => 'Profil ne obstaja.';

  @override
  String get editProfileDisplayNameRequired => 'Vpiši prikazno ime.';

  @override
  String get collectorsSearchLabel => 'Išči zbiratelja';

  @override
  String get collectorsSearchHint => 'Vpiši prikazno ime';

  @override
  String collectorsSearchError(String error) {
    return 'Uporabnikov ni bilo mogoče poiskati:\n$error';
  }

  @override
  String get collectorsNoResults => 'Ni najdenih zbirateljev.';

  @override
  String get collectorsSearchDescription =>
      'Poišči druge zbiratelje po prikaznem imenu.';

  @override
  String get collectorsInternationalAllowed => 'Mednarodne menjave dovoljene';

  @override
  String get collectorsLocalOnly => 'Samo lokalne menjave';

  @override
  String get collectorProfileTitle => 'Profil zbiratelja';

  @override
  String get collectorProfileMissing => 'Profil uporabnika ne obstaja.';

  @override
  String collectorChatOpenError(String error) {
    return 'Pogovora ni bilo mogoče odpreti:\n$error';
  }

  @override
  String get collectorOpeningChat => 'Odpiram pogovor…';

  @override
  String get collectorSendMessage => 'Pošlji sporočilo';

  @override
  String get collectorInternationalTrades => 'Mednarodne menjave';

  @override
  String get collectorLocalTrades => 'Lokalne menjave';

  @override
  String get collectorAbout => 'O zbiratelju';

  @override
  String get collectorPrivateTitle => 'Ta profil je zaseben';

  @override
  String get collectorPrivateDescription =>
      'Lokacija, opis in komentarji ocen niso javno prikazani.';

  @override
  String collectorProfileLoadError(String error) {
    return 'Profila ni bilo mogoče naložiti:\n$error';
  }

  @override
  String get ratingUnavailable => 'Ocena ni na voljo';

  @override
  String get ratingLoading => 'Nalagam ocene';

  @override
  String get ratingNone => 'Brez ocen';

  @override
  String ratingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ocen',
      few: '$count ocene',
      two: '$count oceni',
      one: '$count ocena',
    );
    return '$_temp0';
  }

  @override
  String get ratingCommentsLoadError =>
      'Komentarjev ocen ni bilo mogoče naložiti.';

  @override
  String get ratingNoPublicComments =>
      'Ta zbiratelj še nima javnih komentarjev.';

  @override
  String get ratingRecentComments => 'Zadnji komentarji';

  @override
  String get catalogCategorySportsCards => 'Športne kartice';

  @override
  String get collectorsNavigation => 'Zbiratelji';

  @override
  String get tradeManualStepRecipient => 'Prejemnik';

  @override
  String get tradeManualStepItems => 'Kartice';

  @override
  String get tradeManualStepSummary => 'Povzetek';

  @override
  String get tradeManualChooseRecipientDescription =>
      'Poišči zbiratelja, ki mu želiš poslati ponudbo za menjavo.';

  @override
  String get tradeManualChangeRecipient => 'Zamenjaj';

  @override
  String get tradeManualLoadingOptions =>
      'Preverjam skupne zbirke in razpoložljive kartice…';

  @override
  String tradeManualOptionsError(String error) {
    return 'Kartic za menjavo ni bilo mogoče naložiti: $error';
  }

  @override
  String get tradeManualNoCommonCollections => 'Nimata skupne zbirke';

  @override
  String get tradeManualNoCommonCollectionsDescription =>
      'Za ročno menjavo morata imeti oba dodano vsaj eno isto zbirko.';

  @override
  String get tradeManualNoAvailableItems => 'Trenutno ni razpoložljivih kartic';

  @override
  String get tradeManualNeedsBothDirections =>
      'Za ponudbo mora imeti vsak uporabnik vsaj en razpoložljiv višek.';

  @override
  String get tradeManualChooseCollection => 'Zbirka';

  @override
  String get tradeManualSelectionsRemainAcrossCollections =>
      'V eni ponudbi lahko izbereš kartice samo iz ene zbirke. Ob menjavi zbirke se izbor počisti.';

  @override
  String get tradeManualNoOfferedItemsInCollection =>
      'V tej zbirki nimaš razpoložljivih viškov.';

  @override
  String get tradeManualNoRequestedItemsInCollection =>
      'Drugi uporabnik v tej zbirki nima razpoložljivih viškov.';

  @override
  String tradeManualSelectedItems(int count) {
    return 'Izbranih: $count';
  }

  @override
  String tradeManualAvailableQuantity(int count) {
    return 'Na voljo za menjavo: $count';
  }

  @override
  String get tradeManualChooseAtLeastOneEach =>
      'Izberi najmanj eno kartico na vsaki strani menjave.';

  @override
  String get tradeManualReviewOffer => 'Preglej ponudbo';

  @override
  String get tradeManualSummaryRecipient => 'Prejemnik';

  @override
  String get tradeManualSummaryOffering => 'Ponujam';

  @override
  String get tradeManualSummaryRequesting => 'Želim';

  @override
  String get tradeManualSendOffer => 'Pošlji ponudbo';

  @override
  String get tradeManualSendingOffer => 'Pošiljam ponudbo…';

  @override
  String get tradeManualOfferCreated => 'Ponudba za menjavo je bila poslana.';

  @override
  String tradeManualOfferError(String error) {
    return 'Ponudbe ni bilo mogoče poslati: $error';
  }

  @override
  String tradeManualYourInventoryUnavailable(String itemNumber) {
    return 'Kartica #$itemNumber ni več na voljo med tvojimi viški.';
  }

  @override
  String tradeManualTheirInventoryUnavailable(String itemNumber) {
    return 'Kartica #$itemNumber ni več na voljo pri drugem uporabniku.';
  }

  @override
  String tradeManualCatalogItemUnavailable(String itemNumber) {
    return 'Kartice #$itemNumber ni mogoče povezati s katalogom.';
  }

  @override
  String get tradeManualInvalidOffer =>
      'Ponudba ni veljavna. Preveri izbrane kartice in količine.';

  @override
  String get tradeManualBack => 'Nazaj';

  @override
  String get forgotPassword => 'Pozabljeno geslo?';

  @override
  String get forgotPasswordTitle => 'Ponastavitev gesla';

  @override
  String get forgotPasswordDescription =>
      'Vpiši e-poštni naslov svojega računa. Poslali ti bomo povezavo za nastavitev novega gesla.';

  @override
  String get sendPasswordResetEmail => 'Pošlji povezavo';

  @override
  String get sendingEmail => 'Pošiljam…';

  @override
  String get passwordResetEmailSentTitle => 'Preveri svojo e-pošto';

  @override
  String get passwordResetEmailSentDescription =>
      'Če račun s tem e-poštnim naslovom obstaja, boš prejel povezavo za ponastavitev gesla.';

  @override
  String get backToSignIn => 'Nazaj na prijavo';

  @override
  String passwordResetError(String error) {
    return 'Povezave za ponastavitev gesla ni bilo mogoče poslati: $error';
  }

  @override
  String get verifyEmailTitle => 'Potrdi e-poštni naslov';

  @override
  String verifyEmailDescription(String email) {
    return 'Na naslov $email smo poslali potrditveno sporočilo. Odpri povezavo v sporočilu in nato preveri stanje.';
  }

  @override
  String get checkVerificationStatus => 'Preveri stanje';

  @override
  String get checkingVerification => 'Preverjam…';

  @override
  String get resendVerificationEmail => 'Ponovno pošlji sporočilo';

  @override
  String get verificationEmailSent => 'Potrditveno sporočilo je bilo poslano.';

  @override
  String verificationEmailSendError(String error) {
    return 'Potrditvenega sporočila ni bilo mogoče poslati: $error';
  }

  @override
  String get emailVerificationConfirmed => 'E-poštni naslov je potrjen.';

  @override
  String get emailStillNotVerified => 'E-poštni naslov še ni potrjen.';

  @override
  String get continueWithoutVerification => 'Za zdaj nadaljuj brez potrditve';

  @override
  String get emailVerified => 'E-pošta je potrjena';

  @override
  String get emailNotVerified => 'E-pošta ni potrjena';

  @override
  String get emailVerificationReminder => 'E-poštni naslov še ni potrjen';

  @override
  String get accountSecurityTitle => 'Račun in varnost';

  @override
  String get accountSecuritySubtitle => 'E-pošta, geslo in izbris računa';

  @override
  String get changePasswordTitle => 'Spremeni geslo';

  @override
  String get changePasswordSubtitle => 'Nastavi novo geslo za prijavo';

  @override
  String get changePasswordDescription =>
      'Za varnost najprej vpiši trenutno geslo in nato izberi novo.';

  @override
  String get currentPassword => 'Trenutno geslo';

  @override
  String get currentPasswordRequired => 'Vpiši trenutno geslo.';

  @override
  String get newPassword => 'Novo geslo';

  @override
  String get newPasswordRequired => 'Vpiši novo geslo.';

  @override
  String get newPasswordMustDiffer =>
      'Novo geslo mora biti drugačno od trenutnega.';

  @override
  String get confirmNewPassword => 'Ponovi novo geslo';

  @override
  String get confirmNewPasswordRequired => 'Ponovno vpiši novo geslo.';

  @override
  String get changePasswordButton => 'Spremeni geslo';

  @override
  String get changingPassword => 'Spreminjam…';

  @override
  String get passwordChanged => 'Geslo je bilo uspešno spremenjeno.';

  @override
  String passwordChangeError(String error) {
    return 'Gesla ni bilo mogoče spremeniti: $error';
  }

  @override
  String get deleteAccountTitle => 'Izbriši račun';

  @override
  String get deleteAccountSubtitle =>
      'Trajno odstrani profil, zbirke in favorite';

  @override
  String get deleteAccountWarningTitle => 'Tega dejanja ni mogoče razveljaviti';

  @override
  String get deleteAccountWarning =>
      'Izbrisani bodo tvoj profil, inventar, zbirke, favoriti in prijavni račun.';

  @override
  String get deleteAccountHistoryNotice =>
      'Zaradi zgodovine drugih udeležencev ostanejo zaključene menjave, sporočila in oddane ocene shranjeni brez tvojega javnega profila.';

  @override
  String get deleteAccountConfirmationWord => 'IZBRIŠI';

  @override
  String deleteAccountConfirmationLabel(String word) {
    return 'Za potrditev vpiši $word';
  }

  @override
  String deleteAccountConfirmationInvalid(String word) {
    return 'Vpiši $word.';
  }

  @override
  String get deleteAccountButton => 'Trajno izbriši račun';

  @override
  String get deletingAccount => 'Brišem račun…';

  @override
  String get deleteAccountConfirmationTitle => 'Res želiš izbrisati račun?';

  @override
  String get deleteAccountConfirmationMessage =>
      'Račun in tvoji osebni podatki v profilu bodo trajno odstranjeni.';

  @override
  String accountDeleteError(String error) {
    return 'Računa ni bilo mogoče izbrisati: $error';
  }

  @override
  String get signOutConfirmationTitle => 'Odjava';

  @override
  String get signOutConfirmationMessage => 'Se želiš odjaviti iz tega računa?';

  @override
  String get authFirebaseRequiresRecentLogin =>
      'Zaradi varnosti se moraš ponovno prijaviti.';

  @override
  String get authFirebaseUserDisabled => 'Ta uporabniški račun je onemogočen.';

  @override
  String get authFirebaseOperationNotAllowed =>
      'Ta način prijave trenutno ni omogočen.';

  @override
  String get accountDeleteActiveTrades =>
      'Računa ni mogoče izbrisati, dokler imaš aktivne ali nedokončane menjave.';

  @override
  String get tradeManualShowAllSurpluses => 'Prikaži vse viške';

  @override
  String get tradeManualSuggestedSurplusesDescription =>
      'Najprej so prikazani samo viški, ki drugemu uporabniku dopolnijo zbirko.';

  @override
  String get tradeManualAllSurplusesDescription =>
      'Prikazani so vsi razpoložljivi viški obeh uporabnikov.';

  @override
  String get tradeManualNoSuggestedOfferedItemsInCollection =>
      'Nimaš viškov, ki bi temu uporabniku dopolnili zbirko.';

  @override
  String get tradeManualNoSuggestedRequestedItemsInCollection =>
      'Ta uporabnik nima viškov, ki bi dopolnili tvojo zbirko.';

  @override
  String get tradeRatingTitle => 'Ocena menjave';

  @override
  String get tradeRatingYourRating => 'Tvoja ocena';

  @override
  String get tradeRatingEdit => 'Uredi oceno';

  @override
  String get tradeRatingCommentHint => 'Kratek komentar (neobvezno)';

  @override
  String get tradeRatingSaveChanges => 'Shrani spremembe';

  @override
  String get tradeRatingUpdating => 'Shranjujem spremembe...';

  @override
  String get tradeRatingUpdatedSuccessfully =>
      'Ocena je bila uspešno posodobljena.';

  @override
  String get tradeRatingSelectStars => 'Izberi od 1 do 5 zvezdic.';

  @override
  String get ratingReviewsTitle => 'Prejete ocene';

  @override
  String get ratingNoReviews => 'Ta zbiratelj še nima ocen.';

  @override
  String get safetySettingsTitle => 'Varnost in zasebnost';

  @override
  String get safetyMenu => 'Varnostne možnosti';

  @override
  String get safetyBlockUser => 'Blokiraj uporabnika';

  @override
  String get safetyBlockUserTitle => 'Blokiranje uporabnika';

  @override
  String get safetyBlockUserConfirmation =>
      'Uporabnik ti ne bo mogel pošiljati sporočil ali novih ponudb za menjavo. Tudi ti mu ne boš mogel pisati ali poslati nove ponudbe.';

  @override
  String get safetyUserBlocked => 'Uporabnik je blokiran.';

  @override
  String get safetyUnblockUser => 'Odblokiraj';

  @override
  String get safetyUnblockUserTitle => 'Odblokiranje uporabnika';

  @override
  String get safetyUnblockUserConfirmation =>
      'Ali želiš temu uporabniku znova dovoliti sporočila in nove ponudbe?';

  @override
  String get safetyUserUnblocked => 'Uporabnik je odblokiran.';

  @override
  String get safetyReportUser => 'Prijavi uporabnika';

  @override
  String get safetyReportTrade => 'Prijavi menjavo';

  @override
  String get safetyReportMessage => 'Prijavi sporočilo';

  @override
  String get safetyReportTitle => 'Pošlji prijavo';

  @override
  String get safetyReportDescription =>
      'Izberi razlog in po želji dodaj podrobnosti. Prijavo bo lahko pregledal samo skrbnik.';

  @override
  String get safetyReportReason => 'Razlog';

  @override
  String get safetyReportReasonSpam => 'Neželena vsebina ali spam';

  @override
  String get safetyReportReasonHarassment => 'Nadlegovanje ali žaljenje';

  @override
  String get safetyReportReasonFraud => 'Sum prevare';

  @override
  String get safetyReportReasonInappropriate => 'Neprimerna vsebina';

  @override
  String get safetyReportReasonOther => 'Drugo';

  @override
  String get safetyReportDetails => 'Podrobnosti (neobvezno)';

  @override
  String get safetyReportDetailsHint => 'Na kratko opiši, kaj se je zgodilo.';

  @override
  String get safetyReportSubmit => 'Pošlji prijavo';

  @override
  String get safetyReportSubmitting => 'Pošiljam...';

  @override
  String get safetyReportSubmitted => 'Prijava je bila poslana.';

  @override
  String get safetyReportError => 'Prijave ni bilo mogoče poslati';

  @override
  String get safetyActionError => 'Dejanja ni bilo mogoče izvesti';

  @override
  String get safetyBlockedUsers => 'Blokirani uporabniki';

  @override
  String get safetyBlockedUsersDescription =>
      'Preglej in odblokiraj uporabnike.';

  @override
  String get safetyBlockedUsersLoadError =>
      'Blokiranih uporabnikov ni bilo mogoče naložiti.';

  @override
  String get safetyNoBlockedUsers => 'Nimaš blokiranih uporabnikov.';

  @override
  String get safetyConversationBlockedByYou =>
      'Tega uporabnika si blokiral. Pogovor ostane viden, novih sporočil pa ni mogoče poslati.';

  @override
  String get safetyConversationBlockedByOther =>
      'Pošiljanje novih sporočil v tem pogovoru ni na voljo.';

  @override
  String get safetyProfileBlockedByYou => 'Tega uporabnika si blokiral.';

  @override
  String get safetyProfileBlockedByOther =>
      'Komunikacija s tem uporabnikom ni na voljo.';

  @override
  String get safetyAdminReports => 'Pregled prijav';

  @override
  String get safetyAdminReportsDescription =>
      'Administrativni pregled prijavljenih uporabnikov in vsebine.';

  @override
  String get safetyReportsLoadError => 'Prijav ni bilo mogoče naložiti.';

  @override
  String get safetyNoReports => 'Ni prijav za izbrani filter.';

  @override
  String get safetyReportTypeUser => 'Uporabnik';

  @override
  String get safetyReportTypeMessage => 'Sporočilo';

  @override
  String get safetyReportTypeTrade => 'Menjava';

  @override
  String get safetyReportStatusOpen => 'Odprto';

  @override
  String get safetyReportStatusReviewing => 'V pregledu';

  @override
  String get safetyReportStatusResolved => 'Rešeno';

  @override
  String get safetyReportStatusDismissed => 'Zavrnjeno';

  @override
  String get safetyReportStatusUpdated => 'Stanje prijave je posodobljeno.';

  @override
  String get safetyReporterId => 'Prijavitelj';

  @override
  String get safetyReportedUserId => 'Prijavljeni uporabnik';

  @override
  String get safetyTargetId => 'Prijavljena vsebina';

  @override
  String get safetyConversationId => 'Pogovor';

  @override
  String get tradeDeliverySectionTitle => 'Predaja in pošiljanje';

  @override
  String get tradeDeliverySectionDescription =>
      'Izberi način predaje ter partnerju posreduj potrebne zasebne podatke.';

  @override
  String get tradeDeliveryYourDetails => 'Tvoji podatki';

  @override
  String get tradeDeliveryPartnerDetails => 'Partnerjevi podatki';

  @override
  String get tradeDeliveryYourDetailsMissing =>
      'Še nisi dodal podatkov za predajo ali pošiljanje.';

  @override
  String get tradeDeliveryPartnerDetailsMissing =>
      'Partner še ni dodal podatkov za predajo ali pošiljanje.';

  @override
  String get tradeDeliveryAdd => 'Dodaj';

  @override
  String get tradeDeliveryEdit => 'Uredi';

  @override
  String get tradeDeliveryFormTitle => 'Podatki za predajo';

  @override
  String get tradeDeliveryChooseMethod => 'Način predaje';

  @override
  String get tradeDeliveryByMail => 'Po pošti';

  @override
  String get tradeDeliveryInPerson => 'Osebna predaja';

  @override
  String get tradeDeliveryFullName => 'Ime in priimek';

  @override
  String get tradeDeliveryAddressLine1 => 'Naslov';

  @override
  String get tradeDeliveryAddressLine2 => 'Dodatna vrstica naslova (neobvezno)';

  @override
  String get tradeDeliveryPostalCode => 'Poštna številka';

  @override
  String get tradeDeliveryCity => 'Kraj';

  @override
  String get tradeDeliveryCountry => 'Država';

  @override
  String get tradeDeliveryPhone => 'Telefonska številka (neobvezno)';

  @override
  String get tradeDeliveryMeetingDetails => 'Podrobnosti osebne predaje';

  @override
  String get tradeDeliveryMeetingDetailsHint =>
      'Predlagaj kraj, čas ali način dogovora.';

  @override
  String get tradeDeliveryCarrier => 'Dostavna služba (neobvezno)';

  @override
  String get tradeDeliveryCarrierHint =>
      'Na primer Pošta Slovenije, GLS ali DPD';

  @override
  String get tradeDeliveryTrackingNumber => 'Sledilna številka (neobvezno)';

  @override
  String get tradeDeliveryNotes => 'Opomba (neobvezno)';

  @override
  String get tradeDeliveryNotesHint => 'Dodaj pomembna navodila za partnerja.';

  @override
  String get tradeDeliveryPrivateTitle => 'Zasebni podatki';

  @override
  String get tradeDeliveryPrivateDescription =>
      'Ti podatki niso javni. Vidi jih samo drugi udeleženec sprejete menjave.';

  @override
  String get tradeDeliveryPrivateShortDescription =>
      'Podatki so vidni samo udeležencema te sprejete ali zaključene menjave.';

  @override
  String get tradeDeliveryRequiredField => 'To polje je obvezno.';

  @override
  String get tradeDeliverySave => 'Shrani podatke';

  @override
  String get tradeDeliverySaving => 'Shranjujem...';

  @override
  String get tradeDeliverySaved => 'Podatki za predajo so shranjeni.';

  @override
  String tradeDeliverySaveError(String error) {
    return 'Podatkov ni bilo mogoče shraniti: $error';
  }

  @override
  String get tradeDeliveryLoadError =>
      'Podatkov za predajo ni bilo mogoče naložiti.';

  @override
  String get tradeDeliveryAddress => 'Naslov za pošiljanje';

  @override
  String get tradeDeliveryTrackingMissing => 'Sledilna številka še ni dodana.';

  @override
  String get tradeDeliveryCopyAddress => 'Kopiraj naslov';

  @override
  String get tradeDeliveryCopyPhone => 'Kopiraj telefonsko številko';

  @override
  String get tradeDeliveryCopyTracking => 'Kopiraj sledilno številko';

  @override
  String get tradeDeliveryCopied => 'Podatek je kopiran.';

  @override
  String get continueLabel => 'Nadaljuj';

  @override
  String get done => 'Končano';

  @override
  String get betaOnboardingTitle => 'Predstavitev aplikacije';

  @override
  String get betaOnboardingSkip => 'Preskoči';

  @override
  String get betaOnboardingStart => 'Začni uporabljati';

  @override
  String get betaOnboardingCollectionsTitle => 'Zbirke na enem mestu';

  @override
  String get betaOnboardingCollectionsDescription =>
      'Označi, katere kartice imaš, katere ti manjkajo in koliko viškov imaš. Pregled zbirke se sproti posodablja.';

  @override
  String get betaOnboardingTradesTitle => 'Poišči smiselne menjave';

  @override
  String get betaOnboardingTradesDescription =>
      'SwapStash primerja viške in manjkajoče kartice ter predlaga uporabnike, s katerimi je možna obojestransko koristna menjava.';

  @override
  String get betaOnboardingCompleteTradeTitle => 'Dogovor, predaja in ocena';

  @override
  String get betaOnboardingCompleteTradeDescription =>
      'Pošlji ponudbo, se pogovori, varno deli podatke za predajo ali pošiljanje in po zaključku oceni partnerja.';

  @override
  String get betaOnboardingSafetyTitle => 'Varnost in nadzor';

  @override
  String get betaOnboardingSafetyDescription =>
      'Blokiraj uporabnika, prijavi neprimerno vsebino in sam odločaš, kateri podatki so javni ter kateri so vidni samo partnerju v menjavi.';

  @override
  String get betaOnboardingShowAgain => 'Ponovno pokaži predstavitev';

  @override
  String get betaOnboardingShowAgainDescription =>
      'Še enkrat preglej glavne funkcije aplikacije.';

  @override
  String get legalAcceptanceTitle => 'Pogoji in zasebnost';

  @override
  String get legalAcceptanceHeading => 'Pred nadaljevanjem';

  @override
  String get legalAcceptanceDescription =>
      'Preberi osnovna pravila uporabe in informacije o obdelavi osebnih podatkov.';

  @override
  String get legalAgeConfirmation =>
      'Potrjujem, da sem star najmanj 13 let. Če sem v Sloveniji mlajši od 15 let, imam dovoljenje starša ali skrbnika.';

  @override
  String get legalDocumentsConfirmation =>
      'Prebral sem in sprejemam Pogoje uporabe ter Politiko zasebnosti.';

  @override
  String get legalAcceptAndContinue => 'Sprejmi in nadaljuj';

  @override
  String get legalAcceptanceSaving => 'Shranjujem sprejem...';

  @override
  String get legalBetaNoticeTitle => 'Zaprta beta različica';

  @override
  String get legalBetaNoticeDescription =>
      'Aplikacija je še v preizkušanju. Funkcije se lahko spremenijo, občasno pa so možne napake ali prekinitve.';

  @override
  String get legalTermsTitle => 'Pogoji uporabe';

  @override
  String get legalPrivacyTitle => 'Politika zasebnosti';

  @override
  String get legalEffectiveDate => 'Velja od: 24. julija 2026';

  @override
  String get legalContactFooter =>
      'Upravljavec: SwapStash · Kontakt: uros2004@gmail.com';

  @override
  String get legalTermsIntro =>
      'Ti pogoji urejajo uporabo aplikacije SwapStash. Z uporabo aplikacije potrjuješ, da se z njimi strinjaš.';

  @override
  String get legalTermsEligibilityTitle => '1. Starost in uporabniški račun';

  @override
  String get legalTermsEligibilityBody =>
      'Aplikacijo lahko uporablja oseba, stara najmanj 13 let. Kadar veljavna zakonodaja za samostojno privolitev zahteva višjo starost, mora mladoletni uporabnik pridobiti dovoljenje starša ali skrbnika. V Sloveniji uporabnik, mlajši od 15 let, potrebuje takšno dovoljenje. Uporabnik mora navesti resnične podatke, varovati prijavne podatke in je odgovoren za dejavnost svojega računa.';

  @override
  String get legalTermsServiceTitle => '2. Namen storitve in beta različica';

  @override
  String get legalTermsServiceBody =>
      'SwapStash omogoča vodenje zbirk, iskanje možnih menjav, pošiljanje ponudb, sporočanje, dogovor o predaji in ocenjevanje zaključenih menjav. SwapStash ni prodajalec, kupec, posrednik, dostavna služba ali stranka dogovora med uporabniki. V beta obdobju se lahko funkcije spremenijo ali začasno niso dosegljive.';

  @override
  String get legalTermsConductTitle => '3. Dovoljena uporaba';

  @override
  String get legalTermsConductBody =>
      'Prepovedani so nadlegovanje, grožnje, sovražni govor, spam, zavajanje, prevare, lažno predstavljanje, objava nezakonite vsebine, posegi v delovanje aplikacije in uporaba avtomatiziranih sredstev brez dovoljenja. Uporabnik ne sme objaviti podatkov druge osebe brez ustrezne pravne podlage.';

  @override
  String get legalTermsTradesTitle => '4. Menjave in dostava';

  @override
  String get legalTermsTradesBody =>
      'Uporabniki sami preverijo stanje, pristnost in vrednost predmetov ter se dogovorijo o načinu predaje, stroških in sledenju pošiljke. SwapStash ne jamči, da bo druga stranka izpolnila dogovor, in ne zagotavlja povračila izgubljenih, poškodovanih ali drugače spornih pošiljk. Pred osebno predajo izberi varen javni kraj; mladoletni uporabniki naj vključijo starša ali skrbnika.';

  @override
  String get legalTermsContentTitle => '5. Sporočila in uporabniška vsebina';

  @override
  String get legalTermsContentBody =>
      'Uporabnik ostane odgovoren za vsebino, ki jo vnese ali pošlje. SwapStash lahko zaradi varnosti, prijave, preprečevanja zlorab ali izpolnjevanja zakonskih obveznosti dostop omeji, vsebino odstrani oziroma jo posreduje pristojnim organom, kadar je to potrebno in zakonito.';

  @override
  String get legalTermsSuspensionTitle => '6. Blokiranje in ukrepi';

  @override
  String get legalTermsSuspensionBody =>
      'Uporabniki lahko druge uporabnike blokirajo ali prijavijo. SwapStash lahko omeji ali ukine račun, kadar obstaja utemeljen sum kršitve teh pogojev, zlorabe, varnostnega tveganja ali nezakonitega ravnanja. Kadar je mogoče, bo uporabnik o razlogu obveščen.';

  @override
  String get legalTermsLiabilityTitle => '7. Razpoložljivost in odgovornost';

  @override
  String get legalTermsLiabilityBody =>
      'Storitev je zagotovljena po načelu »takšna, kot je«. SwapStash si prizadeva za varno in zanesljivo delovanje, vendar ne zagotavlja neprekinjene razpoložljivosti, popolne točnosti podatkov ali uspeha posamezne menjave. Omejitve odgovornosti veljajo samo v obsegu, ki ga dovoljuje veljavna zakonodaja, in ne izključujejo pravic, ki jih ni mogoče pogodbeno omejiti.';

  @override
  String get legalTermsChangesTitle => '8. Spremembe, pravo in kontakt';

  @override
  String get legalTermsChangesBody =>
      'Pogoji se lahko posodobijo zaradi novih funkcij, varnostnih zahtev ali zakonodaje. Ob pomembni spremembi bo aplikacija zahtevala ponoven sprejem. Za pogoje velja pravo Republike Slovenije, ob upoštevanju obveznih pravic uporabnika po pravu njegove države. Vprašanja pošlji na uros2004@gmail.com.';

  @override
  String get legalPrivacyIntro =>
      'Ta politika pojasnjuje, katere osebne podatke SwapStash obdeluje, zakaj jih uporablja in katere pravice ima uporabnik.';

  @override
  String get legalPrivacyControllerTitle => '1. Upravljavec in kontakt';

  @override
  String get legalPrivacyControllerBody =>
      'Upravljavec osebnih podatkov je SwapStash. Za vprašanja, zahteve ali ugovor glede zasebnosti piši na uros2004@gmail.com.';

  @override
  String get legalPrivacyDataTitle => '2. Podatki, ki jih obdelujemo';

  @override
  String get legalPrivacyDataBody =>
      'Obdelujemo podatke računa in prijave, e-poštni naslov, prikazno ime, državo, mesto, jezik, fotografijo profila in opis; podatke o zbirkah, karticah in viških; ponudbe, statuse menjav, ocene, sporočila in prijave; podatke za predajo ali pošiljanje, ki jih uporabnik prostovoljno vnese; žetone za potisna obvestila ter osnovne tehnične in varnostne podatke, potrebne za delovanje storitve.';

  @override
  String get legalPrivacyPurposeTitle => '3. Nameni in pravne podlage';

  @override
  String get legalPrivacyPurposeBody =>
      'Podatke uporabljamo za ustvarjanje in upravljanje računa, izvajanje funkcij zbirke in menjav, komunikacijo, dostavo obvestil, preprečevanje zlorab, reševanje prijav, varnost, podporo in izpolnjevanje pravnih obveznosti. Pravne podlage so izvajanje dogovora z uporabnikom, privolitev, zakoniti interes za varnost in izboljšanje storitve ter zakonske obveznosti.';

  @override
  String get legalPrivacyVisibilityTitle =>
      '4. Vidnost in posredovanje drugim uporabnikom';

  @override
  String get legalPrivacyVisibilityBody =>
      'Javni profil lahko prikazuje izbrano ime, fotografijo, lokacijo, opis, ocene in statistiko menjav. Sporočila so vidna udeležencema pogovora. Naslov, telefonska številka, podatki osebne predaje in sledenja so vidni samo udeležencema sprejete ali zaključene menjave. Prijave so vidne prijavitelju v dovoljenem obsegu in skrbniku.';

  @override
  String get legalPrivacyRetentionTitle => '5. Hramba in izbris';

  @override
  String get legalPrivacyRetentionBody =>
      'Podatke hranimo toliko časa, kolikor je potrebno za uporabo računa, varnost, reševanje sporov in zakonske obveznosti. Uporabnik lahko zahteva izbris računa. Nekatere zapise lahko omejeno obdobje ohranimo, kadar je to nujno zaradi preprečevanja zlorab, uveljavljanja pravnih zahtev ali zakonske obveznosti. Lokalni sprejem pogojev je shranjen v napravi.';

  @override
  String get legalPrivacyProcessorsTitle => '6. Ponudniki storitev in prenosi';

  @override
  String get legalPrivacyProcessorsBody =>
      'Za gostovanje, prijavo, podatkovno zbirko, shranjevanje fotografij in potisna obvestila uporabljamo Firebase oziroma Google Cloud ter druge tehnične ponudnike. Ti podatke obdelujejo po naših navodilih in svojih pogodbenih obveznostih. Kadar se podatki obdelujejo zunaj Evropskega gospodarskega prostora, se uporabljajo ustrezni zaščitni mehanizmi, kot so sklepi o ustreznosti ali standardne pogodbene klavzule.';

  @override
  String get legalPrivacyRightsTitle => '7. Pravice uporabnika';

  @override
  String get legalPrivacyRightsBody =>
      'Glede na okoliščine lahko zahtevaš dostop, popravek, izbris, omejitev obdelave, prenosljivost podatkov ali ugovarjaš obdelavi. Privolitev lahko prekličeš za naprej. Zahtevo pošlji na uros2004@gmail.com. Prav tako lahko vložiš pritožbo pri Informacijskem pooblaščencu Republike Slovenije oziroma pristojnem nadzornem organu.';

  @override
  String get legalPrivacyChildrenTitle => '8. Otroci in mladostniki';

  @override
  String get legalPrivacyChildrenBody =>
      'SwapStash ni namenjen otrokom, mlajšim od 13 let. Uporabnik, star 13 ali 14 let v Sloveniji, mora imeti dovoljenje starša ali skrbnika. Starši oziroma skrbniki lahko zahtevajo pregled ali izbris podatkov mladoletnega uporabnika. Zaradi varnosti naj mladoletni uporabniki ne objavljajo domačega naslova javno in naj osebne predaje opravijo v spremstvu odrasle osebe.';

  @override
  String get legalPrivacySecurityTitle => '9. Varnost in spremembe politike';

  @override
  String get legalPrivacySecurityBody =>
      'Uporabljamo tehnične in organizacijske ukrepe, kot so preverjanje dostopa, zasebne podzbirke, omejitve pravil podatkovne zbirke, blokiranje, prijave in varna prijava. Noben sistem ni popolnoma varen. Ob pomembni spremembi te politike bo aplikacija prikazala obvestilo in po potrebi zahtevala ponoven sprejem.';

  @override
  String get aboutAppTitle => 'O aplikaciji';

  @override
  String get aboutAppDescription =>
      'SwapStash pomaga zbirateljem voditi zbirke, poiskati primerne partnerje in varneje zaključiti menjave.';

  @override
  String get aboutVersion => 'Različica aplikacije';

  @override
  String get aboutVersionLoading => 'Nalagam različico...';

  @override
  String get aboutOperator => 'Upravljavec';

  @override
  String get aboutContact => 'Kontakt in podpora';

  @override
  String get aboutLegalSection => 'Pravne informacije';

  @override
  String get aboutSendFeedback => 'Pošlji povratne informacije';

  @override
  String get aboutFeedbackEmailSubject =>
      'SwapStash beta – povratne informacije';

  @override
  String get aboutFeedbackOpenError =>
      'E-poštne aplikacije ni bilo mogoče odpreti.';

  @override
  String get aboutBetaFooter =>
      'Zaprta beta različica · podatki in funkcije se lahko pred javno izdajo spremenijo.';

  @override
  String get settingsAboutAndLegalTitle => 'O aplikaciji in pravne informacije';

  @override
  String get settingsAboutAppSubtitle =>
      'Različica, kontakt, povratne informacije in dokumenti';
}
