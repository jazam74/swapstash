// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appName => 'SwapStash';

  @override
  String get home => 'Startseite';

  @override
  String get collections => 'Sammlungen';

  @override
  String get trades => 'Tausch';

  @override
  String get messages => 'Nachrichten';

  @override
  String get profile => 'Profil';

  @override
  String get welcomeUser => 'Willkommen, Uroš!';

  @override
  String get welcomeDescription =>
      'Verwalte deine Sammlungen und finde die besten Tauschmöglichkeiten.';

  @override
  String get newMatches => 'Neue Treffer';

  @override
  String get activeCollections => 'Aktive Sammlungen';

  @override
  String get addCollection => 'Sammlung hinzufügen';

  @override
  String get sameCountry => 'Gleiches Land';

  @override
  String get international => 'International';

  @override
  String get reviewTrade => 'Tausch prüfen';

  @override
  String get noMessages => 'Keine Nachrichten';

  @override
  String get noMessagesDescription =>
      'Deine Unterhaltungen zu Tauschvorgängen werden hier angezeigt.';

  @override
  String get language => 'Sprache';

  @override
  String get internationalTrades => 'Internationale Tauschvorgänge';

  @override
  String get allowed => 'Erlaubt';

  @override
  String get successfulTrades => 'Erfolgreiche Tauschvorgänge';

  @override
  String get chooseLanguage => 'Sprache auswählen';

  @override
  String get chooseLanguageDescription =>
      'Wähle die Sprache aus, die du in SwapStash verwenden möchtest. Du kannst sie später in den Einstellungen ändern.';

  @override
  String get automaticLanguage => 'Automatisch – Gerätesprache';

  @override
  String get automaticLanguageDescription =>
      'Verwendet automatisch eine unterstützte Gerätesprache.';

  @override
  String get englishFallbackDescription =>
      'Wenn die Gerätesprache nicht unterstützt wird, wird Englisch verwendet.';

  @override
  String get continueButton => 'Weiter';

  @override
  String get saving => 'Wird gespeichert…';

  @override
  String get settings => 'Einstellungen';

  @override
  String get applicationSettings => 'App-Einstellungen';

  @override
  String get languageSettingsDescription =>
      'Wähle die Sprache der App. Die Änderung wird sofort übernommen und für zukünftige Starts gespeichert.';

  @override
  String get languageChanged => 'Die Sprache wurde geändert.';

  @override
  String get profileLoadError => 'Das Profil konnte nicht geladen werden:';

  @override
  String get profileMissing => 'Das Profil ist nicht vorhanden.';

  @override
  String get unnamedUser => 'Unbenannter Benutzer';

  @override
  String get unknownUser => 'Unbekannter Benutzer';

  @override
  String get rating => 'Bewertung';

  @override
  String get completedTrades => 'Abgeschlossene Tauschvorgänge';

  @override
  String get profileVisibility => 'Profilsichtbarkeit';

  @override
  String get publicProfile => 'Öffentlich';

  @override
  String get privateProfile => 'Privat';

  @override
  String get notAllowed => 'Nicht erlaubt';

  @override
  String get editProfile => 'Profil bearbeiten';

  @override
  String get editProfileSubtitle => 'Name, Ort, Beschreibung und Privatsphäre';

  @override
  String get signOut => 'Abmelden';

  @override
  String get dashboardCatalogTooltip => 'Sammlungskatalog';

  @override
  String get dashboardFavoritesTooltip => 'Meine Favoriten';

  @override
  String get dashboardLoadError => 'Das Dashboard konnte nicht geladen werden';

  @override
  String get dashboardMyCollections => 'Meine Sammlungen';

  @override
  String get dashboardShowAll => 'Alle anzeigen';

  @override
  String get dashboardOverview => 'Übersicht';

  @override
  String get dashboardYourCollections => 'Deine Sammlungen';

  @override
  String get dashboardWelcomeTitle => 'Willkommen!';

  @override
  String get dashboardWelcomeSubtitle =>
      'Übersicht über deine Sammlungen und Aktivitäten.';

  @override
  String get dashboardTodayTasks => 'Das steht heute an';

  @override
  String get dashboardAllDone => 'Alles ist erledigt';

  @override
  String get dashboardNoOpenTasks => 'Du hast derzeit keine offenen Aufgaben.';

  @override
  String get dashboardNoCollectionsTitle => 'Du hast noch keine Sammlung';

  @override
  String get dashboardNoCollectionsDescription =>
      'Öffne den Tab Sammlungen und füge deine erste Sammlung hinzu.';

  @override
  String get dashboardCollected => 'Gesammelt';

  @override
  String get dashboardDuplicates => 'Doppelte';

  @override
  String get dashboardMissing => 'Fehlend';

  @override
  String get dashboardCollectionOpenError =>
      'Die Sammlung konnte nicht geöffnet werden.';

  @override
  String get dashboardCollectionNotFound =>
      'Die Sammlung konnte nicht gefunden werden.';

  @override
  String dashboardCollectionOpenErrorDetails(String error) {
    return 'Die Sammlung konnte nicht geöffnet werden: $error';
  }

  @override
  String dashboardUnreadMessages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ungelesene Nachrichten',
      one: '1 ungelesene Nachricht',
    );
    return '$_temp0';
  }

  @override
  String get dashboardOpenConversation =>
      'Öffne die Unterhaltung und lies die neuen Nachrichten.';

  @override
  String get dashboardRespondToCounterOffer => 'Auf das Gegenangebot antworten';

  @override
  String get dashboardRespondToOffer => 'Auf das Angebot antworten';

  @override
  String get dashboardConfirmHandover => 'Kartenübergabe bestätigen';

  @override
  String get dashboardConfirmReceipt => 'Kartenerhalt bestätigen';

  @override
  String get dashboardOpenTrade => 'Tausch öffnen';

  @override
  String get dashboardOpenTradeAndContinue =>
      'Öffne den Tausch und setze den Vorgang fort.';

  @override
  String dashboardTradeWithUser(String userId) {
    return 'Tausch mit Benutzer $userId';
  }

  @override
  String get catalogAddToFavorites => 'Zu Favoriten hinzufügen';

  @override
  String get catalogAddedToFavorites =>
      'Der Artikel wurde zu den Favoriten hinzugefügt.';

  @override
  String catalogAdditionalFilterCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count zusätzliche Filter',
      one: '$count zusätzlicher Filter',
    );
    return '$_temp0';
  }

  @override
  String get catalogAdditionalFilters => 'Zusätzliche Filter';

  @override
  String catalogAdditionalFiltersCount(int count) {
    return 'Zusätzliche Filter ($count)';
  }

  @override
  String get catalogAll => 'Alle';

  @override
  String get catalogAllRarities => 'Alle Seltenheiten';

  @override
  String get catalogApply => 'Anwenden';

  @override
  String get catalogAttributeBrand => 'Marke';

  @override
  String get catalogAttributeCharacter => 'Figur';

  @override
  String get catalogAttributeCountry => 'Land';

  @override
  String get catalogAttributeDenomination => 'Nennwert';

  @override
  String get catalogAttributeFranchise => 'Franchise';

  @override
  String get catalogAttributeManufacturer => 'Hersteller';

  @override
  String get catalogAttributeMaterial => 'Material';

  @override
  String get catalogAttributeSeries => 'Serie';

  @override
  String get catalogAttributeSet => 'Set';

  @override
  String get catalogAttributeTeam => 'Team';

  @override
  String get catalogAttributeTheme => 'Thema';

  @override
  String get catalogAttributeType => 'Typ';

  @override
  String get catalogAttributeYear => 'Jahr';

  @override
  String get catalogCancel => 'Abbrechen';

  @override
  String get catalogCategory => 'Kategorie';

  @override
  String get catalogChooseCsvOrXlsx => 'CSV oder XLSX auswählen';

  @override
  String get catalogClear => 'Löschen';

  @override
  String get catalogClose => 'Schließen';

  @override
  String catalogCollectionAddError(String error) {
    return 'Die Sammlung konnte nicht hinzugefügt werden: $error';
  }

  @override
  String catalogCollectionAdded(String name) {
    return '„$name“ wurde zu deinen Sammlungen hinzugefügt.';
  }

  @override
  String get catalogCollectionComplete =>
      'Die Sammlung ist vollständig. Es fehlen keine Artikel.';

  @override
  String catalogCollectionCreateError(String error) {
    return 'Die Sammlung konnte nicht erstellt werden: $error';
  }

  @override
  String get catalogCollectionCreatePermissionDenied =>
      'Firestore hat das Erstellen der Sammlung abgelehnt. Der angemeldete Benutzer benötigt Administratorrechte.';

  @override
  String catalogCollectionCreatedForImport(String name) {
    return '„$name“ wurde erstellt und für den Import ausgewählt.';
  }

  @override
  String get catalogCollectionId => 'Sammlungs-ID';

  @override
  String catalogCollectionIdExists(String id) {
    return 'Eine Sammlung mit der ID „$id“ ist bereits vorhanden.';
  }

  @override
  String get catalogCollectionIdHelp =>
      'Kleinbuchstaben, Zahlen und Bindestriche. Später nicht mehr ändern.';

  @override
  String get catalogCollectionIdInvalid =>
      'Verwende nur Kleinbuchstaben, Zahlen und Bindestriche.';

  @override
  String get catalogCollectionName => 'Name der Sammlung';

  @override
  String get catalogCollectionProgress => '📊 Sammlungsfortschritt';

  @override
  String catalogCollectionsLoadErrorDetails(String error) {
    return 'Sammlungen konnten nicht geladen werden:\n$error';
  }

  @override
  String get catalogCollectionsTitle => 'Sammlungskatalog';

  @override
  String catalogColumnCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Spalten',
      one: '$count Spalte',
    );
    return '$_temp0';
  }

  @override
  String get catalogConfirmImport => 'Import bestätigen';

  @override
  String get catalogCreate => 'Erstellen';

  @override
  String get catalogCreateNewCollection => 'Neue Sammlung erstellen';

  @override
  String get catalogCreatingCollection => 'Sammlung wird erstellt ...';

  @override
  String get catalogDecreaseQuantity => 'Menge verringern';

  @override
  String get catalogDisableQuickEntry => 'Schnelleingabe deaktivieren';

  @override
  String get catalogDuplicates => 'Doppelte';

  @override
  String get catalogEnableQuickEntry => 'Schnelleingabe aktivieren';

  @override
  String get catalogEnterCollectionId => 'Gib die Sammlungs-ID ein.';

  @override
  String get catalogEnterCollectionName => 'Gib den Namen der Sammlung ein.';

  @override
  String catalogFavoriteChangeError(String error) {
    return 'Der Favoritenstatus konnte nicht geändert werden: $error';
  }

  @override
  String get catalogFileErrors => 'Dateifehler';

  @override
  String get catalogFilterByRarity => 'Nach Seltenheit filtern';

  @override
  String get catalogFindTrades => 'Tauschmöglichkeiten finden';

  @override
  String catalogFirstRows(int count) {
    return 'Erste $count';
  }

  @override
  String get catalogImageNotAdded => 'Noch kein Bild hinzugefügt';

  @override
  String get catalogImportAction => 'Importieren';

  @override
  String get catalogImportColumnHelp =>
      'Erforderlich sind die Spalten number und name. Die Spalten rarity und imageUrl sind optional. Alle weiteren Spalten werden automatisch als zusätzliche Eigenschaften importiert.';

  @override
  String get catalogImportCompleted => 'Import abgeschlossen';

  @override
  String catalogImportConfirmRows(int count, String collectionName) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count gültige Zeilen',
      one: '$count gültige Zeile',
    );
    return 'In „$collectionName“ werden $_temp0 verarbeitet.';
  }

  @override
  String catalogImportCreated(int count) {
    return 'Erstellt: $count';
  }

  @override
  String get catalogImportCsvAndExcel => 'CSV und Excel';

  @override
  String catalogImportCsvReadError(String error) {
    return 'Die CSV-Datei konnte nicht gelesen werden: $error';
  }

  @override
  String get catalogImportDescription =>
      'Artikel aus einer CSV- oder XLSX-Datei importieren.';

  @override
  String get catalogImportDuplicateNumber =>
      'Doppelte Nummer in derselben Datei.';

  @override
  String get catalogImportExcelNoData => 'Die Excel-Datei enthält keine Daten.';

  @override
  String get catalogImportExistingSkipped =>
      'Vorhandene Artikel werden übersprungen.';

  @override
  String get catalogImportExistingUpdated =>
      'Vorhandene Artikel mit derselben Nummer werden aktualisiert.';

  @override
  String catalogImportFailed(String error) {
    return 'Import fehlgeschlagen: $error';
  }

  @override
  String get catalogImportFileNoData => 'Die Datei enthält keine Daten.';

  @override
  String catalogImportFileOpenError(String error) {
    return 'Die Datei konnte nicht geöffnet werden: $error';
  }

  @override
  String get catalogImportFileTooLarge =>
      'Die Datei ist größer als die erlaubten 20 MB.';

  @override
  String get catalogImportFileTooltip => 'CSV oder XLSX importieren';

  @override
  String catalogImportItems(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Artikel importieren',
      one: '$count Artikel importieren',
    );
    return '$_temp0';
  }

  @override
  String get catalogImportMissingName => 'Der Name fehlt.';

  @override
  String get catalogImportMissingNameColumn =>
      'Die erforderliche Spalte „name“ fehlt.';

  @override
  String get catalogImportMissingNumber => 'Die Nummer fehlt.';

  @override
  String get catalogImportMissingNumberColumn =>
      'Die erforderliche Spalte „number“ fehlt.';

  @override
  String get catalogImportNoItemsBelowHeader =>
      'Unter der Kopfzeile befinden sich keine Artikel.';

  @override
  String get catalogImportPermissionDenied =>
      'Firestore hat den Import abgelehnt. Für den Import in den zentralen Katalog muss der angemeldete Benutzer Administrator sein.';

  @override
  String get catalogImportSkipHelp =>
      'Artikel mit einer bereits vorhandenen Nummer werden nicht geändert.';

  @override
  String catalogImportSkipped(int count) {
    return 'Übersprungen: $count';
  }

  @override
  String get catalogImportSupportedFilesOnly =>
      'Es werden nur CSV- und XLSX-Dateien unterstützt.';

  @override
  String get catalogImportTitle => 'Katalogimport';

  @override
  String get catalogImportUpdateHelp =>
      'Artikel mit einer bereits vorhandenen Nummer werden aktualisiert.';

  @override
  String catalogImportUpdated(int count) {
    return 'Aktualisiert: $count';
  }

  @override
  String catalogImportXlsxReadError(String error) {
    return 'Die XLSX-Datei konnte nicht gelesen werden: $error';
  }

  @override
  String get catalogImporting => 'Import wird ausgeführt ...';

  @override
  String get catalogIncreaseQuantity => 'Menge erhöhen';

  @override
  String get catalogInvalidNumber => 'Ungültige Zahl.';

  @override
  String catalogInvalidRows(int count) {
    return '$count ungültig';
  }

  @override
  String get catalogInvalidYear => 'Ungültiges Jahr.';

  @override
  String catalogInventoryLoadErrorDetails(String error) {
    return 'Inventar konnte nicht geladen werden:\n$error';
  }

  @override
  String get catalogItemCount => 'Anzahl der Artikel';

  @override
  String catalogItemDefaultName(String number) {
    return 'Artikel $number';
  }

  @override
  String get catalogItemMarkedMissing =>
      'Der Artikel wurde als fehlend markiert.';

  @override
  String get catalogItemMissing => 'Artikel fehlt';

  @override
  String get catalogItemOwned => 'Du besitzt diesen Artikel';

  @override
  String catalogItemStatusLoadErrorDetails(String error) {
    return 'Der Artikelstatus konnte nicht geladen werden:\n$error';
  }

  @override
  String catalogItemsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Artikel',
      one: '$count Artikel',
    );
    return '$_temp0';
  }

  @override
  String catalogItemsLoadErrorDetails(String error) {
    return 'Artikel konnten nicht geladen werden:\n$error';
  }

  @override
  String catalogLoadErrorDetails(String error) {
    return 'Der Katalog konnte nicht geladen werden:\n$error';
  }

  @override
  String get catalogMissing => 'Fehlend';

  @override
  String get catalogMissingPlural => 'Fehlend';

  @override
  String get catalogNewCollection => 'Neue Sammlung';

  @override
  String get catalogNoCollectionsFound => 'Keine Sammlungen gefunden.';

  @override
  String get catalogNoDuplicates => 'Du hast noch keine doppelten Artikel.';

  @override
  String get catalogNoFilterResults =>
      'Für die ausgewählten Filter wurden keine passenden Artikel gefunden.';

  @override
  String get catalogNoItems => 'Diese Sammlung enthält noch keine Artikel.';

  @override
  String get catalogNoOwnedItems => 'Du besitzt noch keine Artikel.';

  @override
  String get catalogNoSearchResults =>
      'Für den Suchbegriff und die ausgewählten Filter wurden keine Ergebnisse gefunden.';

  @override
  String get catalogNotOwned => 'Nicht vorhanden';

  @override
  String get catalogOk => 'OK';

  @override
  String get catalogOpeningFile => 'Datei wird geöffnet ...';

  @override
  String get catalogOther => 'Andere';

  @override
  String get catalogOwned => 'Vorhanden';

  @override
  String catalogOwnedSurplusCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Du hast $count doppelte Artikel.',
      one: 'Du hast $count doppelten Artikel.',
      zero: 'Du hast keine doppelten Artikel.',
    );
    return '$_temp0';
  }

  @override
  String catalogPiecesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Stück',
      one: '$count Stück',
    );
    return '$_temp0';
  }

  @override
  String get catalogPreview => 'Vorschau';

  @override
  String get catalogPublisher => 'Herausgeber';

  @override
  String get catalogQuantity => 'Menge';

  @override
  String catalogQuantitySaveError(String error) {
    return 'Die Menge konnte nicht gespeichert werden: $error';
  }

  @override
  String catalogQuantityUpdated(int quantity) {
    return 'Die Menge wurde auf $quantity aktualisiert.';
  }

  @override
  String get catalogRarity => 'Seltenheit';

  @override
  String get catalogRarityAll => 'Seltenheit: alle';

  @override
  String get catalogRarityCommon => 'Häufig';

  @override
  String get catalogRarityLimitedEdition => 'Limitierte Auflage';

  @override
  String get catalogRarityRare => 'Selten';

  @override
  String catalogRaritySelected(String value) {
    return 'Seltenheit: $value';
  }

  @override
  String get catalogRarityUltraRare => 'Ultraselten';

  @override
  String catalogRarityValue(String value) {
    return 'Seltenheit: $value';
  }

  @override
  String get catalogRemoveFromFavorites => 'Aus Favoriten entfernen';

  @override
  String get catalogRemovedFromFavorites =>
      'Der Artikel wurde aus den Favoriten entfernt.';

  @override
  String catalogResultsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Ergebnisse',
      one: '$count Ergebnis',
    );
    return '$_temp0';
  }

  @override
  String get catalogSearchHint => 'Nach Nummer oder Name suchen ...';

  @override
  String get catalogSelectTargetCollectionFirst =>
      'Wähle zuerst die Zielsammlung aus.';

  @override
  String get catalogSelectValidFileFirst =>
      'Wähle zuerst eine gültige Datei aus.';

  @override
  String get catalogSelectedCollectionMissing =>
      'Die ausgewählte Sammlung ist nicht mehr vorhanden.';

  @override
  String catalogSheetName(String name) {
    return 'Tabellenblatt: $name';
  }

  @override
  String get catalogSkip => 'Überspringen';

  @override
  String get catalogSortItems => 'Artikel sortieren';

  @override
  String get catalogSortNameAscending => 'Name: A–Z';

  @override
  String get catalogSortNameDescending => 'Name: Z–A';

  @override
  String get catalogSortNumberAscending => 'Nummer: aufsteigend';

  @override
  String get catalogSortNumberDescending => 'Nummer: absteigend';

  @override
  String get catalogSortRarityAscending => 'Seltenheit: A–Z';

  @override
  String get catalogSortRarityDescending => 'Seltenheit: Z–A';

  @override
  String catalogSurplusCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '+$count doppelt',
      one: '+$count doppelt',
    );
    return '$_temp0';
  }

  @override
  String get catalogTargetCollection => 'Zielsammlung';

  @override
  String get catalogTotalPieces => 'Stück insgesamt';

  @override
  String get catalogUnnamedItem => 'Unbenannter Artikel';

  @override
  String get catalogUpdate => 'Aktualisieren';

  @override
  String catalogValidRows(int count) {
    return '$count gültig';
  }

  @override
  String get catalogYear => 'Jahr';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get clearSearch => 'Suche löschen';

  @override
  String get noResults => 'Keine Ergebnisse';

  @override
  String get now => 'Jetzt';

  @override
  String get sending => 'Wird gesendet...';

  @override
  String get tryAgain => 'Erneut versuchen';

  @override
  String get yesterday => 'Gestern';

  @override
  String get weekdayMondayShort => 'Mo';

  @override
  String get weekdayTuesdayShort => 'Di';

  @override
  String get weekdayWednesdayShort => 'Mi';

  @override
  String get weekdayThursdayShort => 'Do';

  @override
  String get weekdayFridayShort => 'Fr';

  @override
  String get weekdaySaturdayShort => 'Sa';

  @override
  String get weekdaySundayShort => 'So';

  @override
  String messageSendError(String error) {
    return 'Die Nachricht konnte nicht gesendet werden:\n$error';
  }

  @override
  String get messagesSearchHint =>
      'Nach Benutzer, Sammlung oder Nachricht suchen';

  @override
  String get messagesConversationEmptyPreview =>
      'Diese Unterhaltung enthält noch keine Nachrichten.';

  @override
  String messagesYouPreview(String message) {
    return 'Du: $message';
  }

  @override
  String get messagesEmptyTitle => 'Du hast noch keine Unterhaltungen';

  @override
  String get messagesEmptyDescription =>
      'Du kannst eine Unterhaltung mit einem Benutzer beginnen, mit dem du tauschen möchtest.';

  @override
  String get messagesTryAnotherSearch => 'Versuche einen anderen Suchbegriff.';

  @override
  String messagesNoConversationsForQuery(String query) {
    return 'Für „$query“ wurden keine Unterhaltungen gefunden.';
  }

  @override
  String get messagesLoadError => 'Unterhaltungen konnten nicht geladen werden';

  @override
  String get messagesSignInRequired =>
      'Du musst dich anmelden, um Nachrichten anzusehen.';

  @override
  String get messagesGenericUser => 'diesem Benutzer';

  @override
  String messagesStartConversationWith(String name) {
    return 'Unterhaltung mit $name beginnen';
  }

  @override
  String messagesConversationAboutCollection(String collectionName) {
    return 'Diese Unterhaltung bezieht sich auf die Sammlung $collectionName.';
  }

  @override
  String get messagesWriteFirstMessage =>
      'Schreibe die erste Nachricht und vereinbart einen Tausch.';

  @override
  String get messagesChatLoadError =>
      'Nachrichten konnten nicht geladen werden.';

  @override
  String get messagesWriteMessageHint => 'Nachricht schreiben...';

  @override
  String get messagesSendMessage => 'Nachricht senden';

  @override
  String get tradeAccept => 'Annehmen';

  @override
  String get tradeArchiveEmpty => 'Das Archiv ist leer.';

  @override
  String tradeAutomaticProposalDescription(
    int offeredCount,
    int requestedCount,
  ) {
    return 'SwapStash schlägt einen ausgeglichenen Tausch von $offeredCount gegen $requestedCount vor.';
  }

  @override
  String get tradeAutomaticProposalTitle => 'Automatischer Tauschvorschlag';

  @override
  String get tradeBackToResults => 'Zurück zu den Ergebnissen';

  @override
  String get tradeCanOffer => 'Du kannst anbieten';

  @override
  String get tradeCanReceive => 'Du kannst erhalten';

  @override
  String get tradeCancelOffer => 'Angebot zurückziehen';

  @override
  String get tradeCardFromCollection => 'Karte aus der Sammlung';

  @override
  String tradeCardsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Karten',
      one: '$count Karte',
    );
    return '$_temp0';
  }

  @override
  String tradeCardsLoadError(String error) {
    return 'Karten konnten nicht geladen werden:\n$error';
  }

  @override
  String get tradeCollectionMissing =>
      'Dem Tausch ist keine Sammlung zugeordnet.';

  @override
  String get tradeCommentHint =>
      'Zum Beispiel: schnelle Einigung und Karten in ausgezeichnetem Zustand.';

  @override
  String get tradeComparisonTitle => 'Tauschvergleich';

  @override
  String tradeCompletedSteps(int completed, int total) {
    return '$completed von $total Schritten';
  }

  @override
  String get tradeConfirmHandoverButton => 'Ja, Übergabe bestätigen';

  @override
  String get tradeConfirmHandoverDescription =>
      'Bestätige erst, wenn du die Karten tatsächlich an die andere Partei übergeben hast. Nach der Bestätigung werden die Karten aus deinem Inventar entfernt. Dieser Schritt kann nicht rückgängig gemacht werden.';

  @override
  String get tradeConfirmHandoverTitle => 'Kartenübergabe bestätigen';

  @override
  String get tradeConfirmReceiptButton => 'Ja, Erhalt bestätigen';

  @override
  String get tradeConfirmReceiptDescription =>
      'Bestätige erst, wenn du die vereinbarten Karten tatsächlich erhalten hast. Nach der Bestätigung werden sie deinem Inventar hinzugefügt. Dieser Schritt kann nicht rückgängig gemacht werden.';

  @override
  String get tradeConfirmReceiptTitle => 'Kartenerhalt bestätigen';

  @override
  String tradeConversationOpenError(String error) {
    return 'Die Unterhaltung konnte nicht geöffnet werden:\n$error';
  }

  @override
  String get tradeCounterOfferDescription =>
      'Ändere das Angebot. Das Verhältnis ist nicht begrenzt; du kannst zum Beispiel einen Vorschlag 3 gegen 3 in 5 gegen 3 ändern.';

  @override
  String get tradeCounterOfferItemsUnavailable =>
      'Die ausgewählten Karten sind für das Gegenangebot nicht mehr verfügbar.';

  @override
  String get tradeCounterOfferNeedsBothSides =>
      'Ein Gegenangebot muss auf beiden Seiten mindestens einen Gegenstand enthalten.';

  @override
  String tradeCounterOfferSendError(String error) {
    return 'Das Gegenangebot konnte nicht gesendet werden: $error';
  }

  @override
  String get tradeCounterOfferTitle => 'Gegenangebot';

  @override
  String get tradeDirectionCounterOffer => 'GEGENANGEBOT';

  @override
  String get tradeDirectionReceivedOffer => 'ERHALTENES ANGEBOT';

  @override
  String get tradeDirectionSentOffer => 'GESENDETES ANGEBOT';

  @override
  String get tradeFilterCancelled => 'Zurückgezogen';

  @override
  String get tradeFilterCompleted => 'Abgeschlossen';

  @override
  String get tradeFilterRejected => 'Abgelehnt';

  @override
  String get tradeFindTrades => 'Tauschpartner finden';

  @override
  String get tradeFromTask => 'Tausch aus Aufgabe';

  @override
  String get tradeHandoverConfirmed => 'Übergabe bestätigt ✓';

  @override
  String get tradeHandoverConfirmedSuccess =>
      'Die Kartenübergabe wurde bestätigt und das Inventar aktualisiert.';

  @override
  String get tradeIAmOffering => 'Ich biete';

  @override
  String get tradeIWant => 'Ich möchte';

  @override
  String get tradeItemSelectionNextStep =>
      'Die Auswahl der Gegenstände erfolgt im nächsten Schritt.';

  @override
  String get tradeItemsNextStep =>
      'Die Gegenstandsliste folgt im nächsten Schritt.';

  @override
  String get tradeLoadError => 'Tauschvorgänge konnten nicht geladen werden.';

  @override
  String tradeLoadErrorDetails(String error) {
    return 'Tauschvorgänge konnten nicht geladen werden:\n$error';
  }

  @override
  String get tradeNewTrade => 'Neuer Tausch';

  @override
  String get tradeNoAvailableItems => 'Keine Gegenstände verfügbar.';

  @override
  String get tradeNoCancelledTrades =>
      'Es gibt keine zurückgezogenen Tauschvorgänge.';

  @override
  String get tradeNoCards => 'Keine Karten.';

  @override
  String get tradeNoCompletedTrades =>
      'Es gibt keine abgeschlossenen Tauschvorgänge.';

  @override
  String get tradeNoIncomingTrades =>
      'Es gibt keine erhaltenen Tauschvorgänge.';

  @override
  String get tradeNoMatchesFound =>
      'Derzeit wurden keine möglichen Tauschvorgänge gefunden.';

  @override
  String get tradeNoMatchesHint =>
      'Prüfe, ob du deine doppelten Karten markiert hast und ob andere Benutzer dieselbe Sammlung verwenden.';

  @override
  String get tradeNoOutgoingTrades =>
      'Es gibt keine gesendeten Tauschvorgänge.';

  @override
  String get tradeNoRejectedTrades =>
      'Es gibt keine abgelehnten Tauschvorgänge.';

  @override
  String get tradeNoTradesYet => 'Du hast noch keine Tauschvorgänge.';

  @override
  String get tradeNoUsersMatch => 'Keine Benutzer entsprechen der Suche.';

  @override
  String get tradeOfferAcceptedSuccess => 'Der Tausch wurde angenommen.';

  @override
  String get tradeOfferCancelledSuccess => 'Das Angebot wurde zurückgezogen.';

  @override
  String get tradeOfferRejectedSuccess => 'Das Angebot wurde abgelehnt.';

  @override
  String get tradeOpeningConversation => 'Unterhaltung wird geöffnet...';

  @override
  String get tradeOptionalComment => 'Kommentar (optional)';

  @override
  String tradePossibleTradesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count mögliche Tauschvorgänge',
      one: '$count möglicher Tausch',
    );
    return '$_temp0';
  }

  @override
  String get tradeProgressAgreed => 'Tausch vereinbart';

  @override
  String get tradeProgressIHandedOver => 'Ich habe die Karten übergeben';

  @override
  String get tradeProgressIReceived => 'Ich habe die Karten erhalten';

  @override
  String get tradeProgressOtherHandedOver =>
      'Die andere Partei hat die Karten übergeben';

  @override
  String get tradeProgressOtherReceived =>
      'Die andere Partei hat die Karten erhalten';

  @override
  String get tradeProgressTitle => 'Tauschverlauf';

  @override
  String tradeProposalSendError(String error) {
    return 'Der Tauschvorschlag konnte nicht gesendet werden:\n$error';
  }

  @override
  String get tradeProposalSentSuccessfully =>
      'Der Tauschvorschlag wurde erfolgreich gesendet.';

  @override
  String get tradeRateUser => 'Benutzer bewerten';

  @override
  String get tradeRatingQuestion =>
      'Wie zufrieden bist du mit dem abgeschlossenen Tausch?';

  @override
  String tradeRatingSubmitError(String error) {
    return 'Die Bewertung konnte nicht gesendet werden: $error';
  }

  @override
  String get tradeRatingSubmitted => 'Bewertung abgegeben.';

  @override
  String get tradeRatingSubmittedSuccessfully =>
      'Die Bewertung wurde erfolgreich abgegeben.';

  @override
  String get tradeRatingUnavailable =>
      'Die Bewertung ist derzeit nicht verfügbar. Prüfe, ob die neuen Firestore-Regeln veröffentlicht wurden.';

  @override
  String get tradeReceiptConfirmed => 'Erhalt bestätigt ✓';

  @override
  String get tradeReceiptConfirmedSuccess =>
      'Der Erhalt der Karten wurde bestätigt und das Inventar aktualisiert.';

  @override
  String get tradeRecipient => 'Empfänger';

  @override
  String get tradeReject => 'Ablehnen';

  @override
  String get tradeRemoveRecipient => 'Empfänger entfernen';

  @override
  String get tradeSearchUserHint => 'Benutzer nach Namen suchen...';

  @override
  String get tradeSendCounterOffer => 'Gegenangebot senden';

  @override
  String tradeSendMessageToUser(String name) {
    return 'Nachricht an $name senden';
  }

  @override
  String get tradeSendProposal => 'Vorschlag senden';

  @override
  String get tradeSendingProposal => 'Vorschlag wird gesendet...';

  @override
  String tradeStarsOutOfFive(int value) {
    return '$value von 5';
  }

  @override
  String get tradeSubmitRating => 'Bewertung senden';

  @override
  String get tradeSubmittingRating => 'Bewertung wird gesendet...';

  @override
  String get tradeSuggestAutomatically => 'Tausch automatisch vorschlagen';

  @override
  String get tradeSummaryTitle => 'Tauschübersicht';

  @override
  String get tradeTabAll => 'Alle';

  @override
  String get tradeTabArchive => 'Archiv';

  @override
  String get tradeTabReceived => 'Erhalten';

  @override
  String get tradeTabSent => 'Gesendet';

  @override
  String get tradeTheirDuplicates => 'Doppelte Karten der anderen Person';

  @override
  String get tradeTheirDuplicatesYouNeed =>
      'Doppelte Karten der anderen Person, die dir noch fehlen.';

  @override
  String tradeUserCanOffer(String name) {
    return '$name kann anbieten';
  }

  @override
  String tradeUserHasNoDuplicatesYouNeed(String name) {
    return '$name hat derzeit keine doppelten Karten, die du benötigst.';
  }

  @override
  String tradeUserNeedsNoneOfYourDuplicates(String name) {
    return '$name benötigt derzeit keine deiner doppelten Karten.';
  }

  @override
  String tradeUserOffers(String name) {
    return '$name bietet an:';
  }

  @override
  String tradeUserSearchError(String error) {
    return 'Benutzer konnten nicht gesucht werden:\n$error';
  }

  @override
  String get tradeWantedItemsNextStep =>
      'Die Liste der gewünschten Gegenstände folgt im nächsten Schritt.';

  @override
  String get tradeWith => 'Tausch mit';

  @override
  String get tradeYouCanOffer => 'Du kannst anbieten';

  @override
  String get tradeYouGive => 'Du gibst';

  @override
  String get tradeYouOfferColon => 'Du bietest an:';

  @override
  String tradeYouOfferCount(int count) {
    return '$count angeboten';
  }

  @override
  String get tradeYouReceive => 'Du erhältst';

  @override
  String tradeYouReceiveCount(int count) {
    return '$count erhalten';
  }

  @override
  String get tradeYourDuplicatesTheyNeed =>
      'Deine doppelten Karten, die dieser Benutzer noch nicht hat.';

  @override
  String get tradeAllowsInternationalTrades =>
      'Erlaubt internationale Tauschvorgänge';

  @override
  String tradeActionExecutionError(String error) {
    return 'Die Aktion konnte nicht ausgeführt werden: $error';
  }

  @override
  String get tradeActionCompletedTitle => 'Tausch abgeschlossen';

  @override
  String get tradeActionCompletedDescription =>
      'Beide Parteien haben Übergabe und Erhalt der Karten bestätigt. Die Inventare wurden aktualisiert.';

  @override
  String get tradeActionRejectedTitle => 'Das Angebot wurde abgelehnt';

  @override
  String get tradeActionCancelledTitle => 'Das Angebot wurde zurückgezogen';

  @override
  String get tradeActionNoActionRequired =>
      'Für dieses Angebot ist keine weitere Aktion erforderlich.';

  @override
  String get tradeActionYourTurnTitle => 'Du bist am Zug';

  @override
  String get tradeActionReviewOfferDescription =>
      'Prüfe die Karten und nimm das Angebot an, lehne es ab oder sende ein Gegenangebot.';

  @override
  String get tradeActionOtherTurnTitle => 'Die andere Partei ist am Zug';

  @override
  String get tradeActionWaitingResponseDescription =>
      'Derzeit ist keine Aktion erforderlich. Es wird auf die Antwort des anderen Benutzers gewartet.';

  @override
  String get tradeActionNoActionTitle =>
      'Derzeit ist keine Aktion erforderlich';

  @override
  String get tradeActionStatusNoResponseDescription =>
      'Der Tauschstatus erfordert keine Reaktion von dir.';

  @override
  String get tradeActionNextStepTitle => 'Nächster Schritt';

  @override
  String get tradeActionConfirmHandoverDescription =>
      'Nachdem du deine Karten tatsächlich an die andere Partei übergeben hast, bestätige die Übergabe. Danach werden sie aus deinem Inventar entfernt.';

  @override
  String get tradeActionConfirmReceiptDescription =>
      'Nachdem du die vereinbarten Karten tatsächlich erhalten hast, bestätige den Erhalt. Danach werden sie deinem Inventar hinzugefügt.';

  @override
  String get tradeActionWaitingOtherHandoverDescription =>
      'Du hast die Übergabe bereits bestätigt. Es wird darauf gewartet, dass die andere Partei ihre Karten übergibt.';

  @override
  String get tradeActionWaitingOtherConfirmationTitle =>
      'Bestätigung der anderen Partei ausstehend';

  @override
  String get tradeActionWaitingOtherReceiptDescription =>
      'Du hast den Erhalt bereits bestätigt. Der Tausch wird abgeschlossen, sobald auch die andere Partei den Erhalt bestätigt.';

  @override
  String get tradeActionWaitingNextConfirmationDescription =>
      'Es wird auf die nächste Bestätigung der anderen Partei gewartet.';

  @override
  String get tradeStatusCompletedTitle => 'Tausch abgeschlossen';

  @override
  String get tradeStatusCompletedSubtitle =>
      'Beide Benutzer haben Übergabe und Erhalt bestätigt.';

  @override
  String get tradeStatusCompletedBadge => 'Abgeschlossen';

  @override
  String get tradeStatusRejectedTitle => 'Angebot abgelehnt';

  @override
  String get tradeStatusRejectedSubtitle =>
      'Dieser Tauschvorschlag wurde nicht angenommen.';

  @override
  String get tradeStatusRejectedBadge => 'Abgelehnt';

  @override
  String get tradeStatusCancelledTitle => 'Angebot zurückgezogen';

  @override
  String get tradeStatusCancelledSubtitle =>
      'Der Absender hat den Tauschvorschlag zurückgezogen.';

  @override
  String get tradeStatusCancelledBadge => 'Zurückgezogen';

  @override
  String get tradeStatusCounterOfferReceivedTitle =>
      'Du hast ein Gegenangebot erhalten';

  @override
  String get tradeStatusAwaitingYourResponseTitle =>
      'Das Angebot wartet auf deine Antwort';

  @override
  String get tradeStatusReviewOfferSubtitle =>
      'Prüfe die Karten und wähle Annehmen, Ablehnen oder Gegenangebot.';

  @override
  String get tradeStatusWaitingForYouBadge => 'Wartet auf dich';

  @override
  String get tradeStatusCounterOfferSentTitle => 'Gegenangebot gesendet';

  @override
  String get tradeStatusOfferSentTitle => 'Angebot gesendet';

  @override
  String get tradeStatusWaitingOtherUserSubtitle =>
      'Es wird auf die Antwort des anderen Benutzers gewartet.';

  @override
  String get tradeStatusWaitingResponseBadge => 'Antwort ausstehend';

  @override
  String get tradeStatusReceivedTitle => 'Du hast das Paket erhalten';

  @override
  String get tradeStatusReceivedSubtitle =>
      'Die erhaltenen Karten wurden deinem Inventar hinzugefügt. Die Bestätigung der anderen Partei steht noch aus.';

  @override
  String get tradeStatusReceivedBadge => 'Erhalten';

  @override
  String get tradeStatusBothOnWayTitle => 'Beide Pakete sind unterwegs';

  @override
  String get tradeStatusPackageOnWayTitle => 'Ein Paket ist zu dir unterwegs';

  @override
  String get tradeStatusBothOnWaySubtitle =>
      'Beide Pakete wurden übergeben. Bestätige den Erhalt, sobald dein Paket angekommen ist.';

  @override
  String get tradeStatusOtherSentSubtitle =>
      'Die andere Partei hat das Paket übergeben. Deine Karten sind weiterhin reserviert.';

  @override
  String get tradeStatusOnWayBadge => 'Unterwegs';

  @override
  String get tradeStatusSentTitle => 'Du hast das Paket gesendet';

  @override
  String get tradeStatusSentSubtitle =>
      'Die übergebenen Karten wurden aus deinem Inventar entfernt. Es wird auf die andere Partei gewartet.';

  @override
  String get tradeStatusSentBadge => 'Gesendet';

  @override
  String get tradeStatusOtherReceivedTitle =>
      'Die andere Partei hat das Paket erhalten';

  @override
  String get tradeStatusConfirmWhenReceivedSubtitle =>
      'Bestätige den Erhalt, sobald dein Paket angekommen ist.';

  @override
  String get tradeStatusWaitingReceiptBadge => 'Erhalt ausstehend';

  @override
  String get tradeStatusAgreedTitle => 'Tausch vereinbart';

  @override
  String get tradeStatusAgreedSubtitle =>
      'Die Karten beider Seiten sind reserviert. Das Inventar ändert sich erst nach Bestätigung der Übergabe oder des Erhalts.';

  @override
  String get tradeStatusAgreedBadge => 'Vereinbart';

  @override
  String get authLoginSubtitle => 'Melde dich bei deinem Konto an';

  @override
  String get authRegisterSubtitle => 'Erstelle ein neues Sammlerkonto';

  @override
  String get authDisplayNameLabel => 'Anzeigename';

  @override
  String get authDisplayNameHint => 'Zum Beispiel Alex';

  @override
  String get authDisplayNameRequired => 'Gib einen Anzeigenamen ein.';

  @override
  String get authDisplayNameMinLength =>
      'Der Name muss mindestens 2 Zeichen lang sein.';

  @override
  String get authDisplayNameMaxLength =>
      'Der Name darf höchstens 40 Zeichen lang sein.';

  @override
  String get authEmailLabel => 'E-Mail-Adresse';

  @override
  String get authEmailRequired => 'Gib deine E-Mail-Adresse ein.';

  @override
  String get authEmailInvalid => 'Gib eine gültige E-Mail-Adresse ein.';

  @override
  String get authPasswordLabel => 'Passwort';

  @override
  String get authShowPassword => 'Passwort anzeigen';

  @override
  String get authHidePassword => 'Passwort ausblenden';

  @override
  String get authPasswordRequired => 'Gib dein Passwort ein.';

  @override
  String get authPasswordMinLength =>
      'Das Passwort muss mindestens 6 Zeichen lang sein.';

  @override
  String get authConfirmPasswordLabel => 'Passwort wiederholen';

  @override
  String get authConfirmPasswordRequired => 'Gib das Passwort erneut ein.';

  @override
  String get authPasswordsDoNotMatch => 'Die Passwörter stimmen nicht überein.';

  @override
  String get authLoginButton => 'Anmelden';

  @override
  String get authCreateAccountButton => 'Konto erstellen';

  @override
  String get authNoAccountRegister => 'Noch kein Konto? Registrieren';

  @override
  String get authHaveAccountLogin => 'Du hast bereits ein Konto? Anmelden';

  @override
  String get authInvalidData => 'Die eingegebenen Daten sind ungültig.';

  @override
  String authUnexpectedError(String error) {
    return 'Ein unerwarteter Fehler ist aufgetreten: $error';
  }

  @override
  String get authFirebaseInvalidEmail => 'Die E-Mail-Adresse ist ungültig.';

  @override
  String get authFirebaseEmailAlreadyInUse =>
      'Ein Konto mit dieser E-Mail-Adresse besteht bereits.';

  @override
  String get authFirebaseWeakPassword => 'Das Passwort ist zu schwach.';

  @override
  String get authFirebaseInvalidCredentials =>
      'Die E-Mail-Adresse oder das Passwort ist falsch.';

  @override
  String get authFirebaseTooManyRequests =>
      'Zu viele Versuche. Versuche es später erneut.';

  @override
  String get authFirebaseNetworkError => 'Überprüfe deine Internetverbindung.';

  @override
  String get authFirebaseGenericError =>
      'Anmeldung oder Registrierung fehlgeschlagen.';

  @override
  String get favoritesTitle => 'Meine Favoriten';

  @override
  String get favoritesSearchHint => 'Favoriten durchsuchen';

  @override
  String get favoritesClearSearch => 'Löschen';

  @override
  String get favoritesRemoved => 'Aus den Favoriten entfernt.';

  @override
  String favoritesNamedItemRemoved(String name) {
    return '„$name“ wurde aus den Favoriten entfernt.';
  }

  @override
  String favoritesRemoveError(String error) {
    return 'Der Favorit konnte nicht entfernt werden: $error';
  }

  @override
  String get favoritesUnnamedItem => 'Unbenanntes Element';

  @override
  String get favoritesRemoveTooltip => 'Aus Favoriten entfernen';

  @override
  String get favoritesEmptyTitle => 'Du hast noch keine Favoriten';

  @override
  String get favoritesEmptyDescription =>
      'Tippe auf der Detailseite eines Elements auf das Herz. Danach erscheint es hier.';

  @override
  String get favoritesNoResults => 'Keine Ergebnisse.';

  @override
  String favoritesNoResultsForQuery(String query) {
    return 'Für „$query“ wurden keine Favoriten gefunden.';
  }

  @override
  String get favoritesLoadError =>
      'Die Favoriten konnten nicht geladen werden.';

  @override
  String get myCollectionsTitle => 'Meine Sammlungen';

  @override
  String get myCollectionsAddFromCatalog =>
      'Sammlung aus dem Katalog hinzufügen';

  @override
  String get myCollectionsAddButton => 'Sammlung hinzufügen';

  @override
  String get myCollectionsRemoveTitle => 'Sammlung entfernen';

  @override
  String myCollectionsRemoveQuestion(String name) {
    return 'Möchtest du „$name“ aus deinen Sammlungen entfernen?';
  }

  @override
  String get myCollectionsRemoveButton => 'Entfernen';

  @override
  String myCollectionsRemoved(String name) {
    return '„$name“ wurde aus deinen Sammlungen entfernt.';
  }

  @override
  String myCollectionsRemoveError(String error) {
    return 'Die Sammlung konnte nicht entfernt werden: $error';
  }

  @override
  String myCollectionsLoadError(String error) {
    return 'Deine Sammlungen konnten nicht geladen werden:\n$error';
  }

  @override
  String get myCollectionsCatalogLoadError =>
      'Die Sammlung konnte nicht geladen werden.';

  @override
  String get myCollectionsCatalogMissing =>
      'Die Katalogsammlung ist nicht vorhanden.';

  @override
  String get myCollectionsStatisticsLoadError =>
      'Die Sammlungsstatistik konnte nicht geladen werden.';

  @override
  String get myCollectionsStatisticsUnavailable =>
      'Die Sammlungsstatistik ist nicht verfügbar.';

  @override
  String get myCollectionsEmptyTitle =>
      'Du hast noch keine Sammlungen hinzugefügt.';

  @override
  String get myCollectionsEmptyDescription =>
      'Wähle eine Sammlung aus dem zentralen Katalog.';

  @override
  String get myCollectionsOpenCatalog => 'Katalog öffnen';

  @override
  String get myCollectionsUnnamedCollection => 'Unbenannte Sammlung';

  @override
  String get myCollectionsMenuTooltip => 'Sammlungsoptionen';

  @override
  String get myCollectionsEditMenu => 'Bearbeiten';

  @override
  String get myCollectionsRemoveMenu => 'Entfernen';

  @override
  String myCollectionsProgressCount(int owned, int total) {
    return 'Gesammelt: $owned / $total';
  }

  @override
  String myCollectionsDuplicateCount(int count) {
    return 'Doppelte: $count';
  }

  @override
  String myCollectionsMissingCount(int count) {
    return 'Fehlend: $count';
  }

  @override
  String get collectors => 'Sammler';

  @override
  String get editProfileDisplayName => 'Anzeigename';

  @override
  String get editProfileCity => 'Ort';

  @override
  String get editProfileBio => 'Beschreibung';

  @override
  String get editProfilePublicTitle => 'Öffentliches Profil';

  @override
  String get editProfilePublicSubtitle => 'Andere Benutzer können dich finden.';

  @override
  String get editProfileInternationalTitle =>
      'Internationale Tauschvorgänge erlauben';

  @override
  String get editProfileInternationalSubtitle =>
      'Du kannst Angebote aus anderen Ländern erhalten.';

  @override
  String get editProfileSave => 'Speichern';

  @override
  String get editProfileSaving => 'Wird gespeichert…';

  @override
  String get editProfileSaved => 'Das Profil wurde erfolgreich gespeichert.';

  @override
  String editProfileSaveError(String error) {
    return 'Das Profil konnte nicht gespeichert werden: $error';
  }

  @override
  String editProfileLoadError(String error) {
    return 'Das Profil konnte nicht geladen werden:\n$error';
  }

  @override
  String get editProfileMissing => 'Das Profil ist nicht vorhanden.';

  @override
  String get editProfileDisplayNameRequired => 'Gib einen Anzeigenamen ein.';

  @override
  String get collectorsSearchLabel => 'Sammler suchen';

  @override
  String get collectorsSearchHint => 'Anzeigenamen eingeben';

  @override
  String collectorsSearchError(String error) {
    return 'Benutzer konnten nicht gesucht werden:\n$error';
  }

  @override
  String get collectorsNoResults => 'Keine Sammler gefunden.';

  @override
  String get collectorsSearchDescription =>
      'Finde andere Sammler anhand ihres Anzeigenamens.';

  @override
  String get collectorsInternationalAllowed =>
      'Internationale Tauschvorgänge erlaubt';

  @override
  String get collectorsLocalOnly => 'Nur lokale Tauschvorgänge';

  @override
  String get collectorProfileTitle => 'Sammlerprofil';

  @override
  String get collectorProfileMissing =>
      'Das Benutzerprofil ist nicht vorhanden.';

  @override
  String collectorChatOpenError(String error) {
    return 'Die Unterhaltung konnte nicht geöffnet werden:\n$error';
  }

  @override
  String get collectorOpeningChat => 'Unterhaltung wird geöffnet…';

  @override
  String get collectorSendMessage => 'Nachricht senden';

  @override
  String get collectorInternationalTrades => 'Internationale Tauschvorgänge';

  @override
  String get collectorLocalTrades => 'Lokale Tauschvorgänge';

  @override
  String get collectorAbout => 'Über den Sammler';

  @override
  String get collectorPrivateTitle => 'Dieses Profil ist privat';

  @override
  String get collectorPrivateDescription =>
      'Ort, Beschreibung und Bewertungskommentare werden nicht öffentlich angezeigt.';

  @override
  String collectorProfileLoadError(String error) {
    return 'Das Profil konnte nicht geladen werden:\n$error';
  }

  @override
  String get ratingUnavailable => 'Bewertung nicht verfügbar';

  @override
  String get ratingLoading => 'Bewertungen werden geladen';

  @override
  String get ratingNone => 'Keine Bewertungen';

  @override
  String ratingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Bewertungen',
      one: '1 Bewertung',
    );
    return '$_temp0';
  }

  @override
  String get ratingCommentsLoadError =>
      'Bewertungskommentare konnten nicht geladen werden.';

  @override
  String get ratingNoPublicComments =>
      'Dieser Sammler hat noch keine öffentlichen Kommentare.';

  @override
  String get ratingRecentComments => 'Neueste Kommentare';

  @override
  String get catalogCategorySportsCards => 'Sportkarten';

  @override
  String get collectorsNavigation => 'Sammler';

  @override
  String get tradeManualStepRecipient => 'Empfänger';

  @override
  String get tradeManualStepItems => 'Karten';

  @override
  String get tradeManualStepSummary => 'Übersicht';

  @override
  String get tradeManualChooseRecipientDescription =>
      'Suche den Sammler, dem du ein Tauschangebot senden möchtest.';

  @override
  String get tradeManualChangeRecipient => 'Ändern';

  @override
  String get tradeManualLoadingOptions =>
      'Gemeinsame Sammlungen und verfügbare Karten werden geprüft…';

  @override
  String tradeManualOptionsError(String error) {
    return 'Die Tauschkarten konnten nicht geladen werden: $error';
  }

  @override
  String get tradeManualNoCommonCollections => 'Keine gemeinsame Sammlung';

  @override
  String get tradeManualNoCommonCollectionsDescription =>
      'Für einen manuellen Tausch müssen beide Benutzer mindestens dieselbe Sammlung hinzugefügt haben.';

  @override
  String get tradeManualNoAvailableItems =>
      'Derzeit sind keine Karten verfügbar';

  @override
  String get tradeManualNeedsBothDirections =>
      'Für ein Angebot muss jeder Benutzer mindestens eine verfügbare doppelte Karte haben.';

  @override
  String get tradeManualChooseCollection => 'Sammlung';

  @override
  String get tradeManualSelectionsRemainAcrossCollections =>
      'Ein Angebot kann nur Karten aus einer Sammlung enthalten. Beim Wechseln der Sammlung wird die Auswahl gelöscht.';

  @override
  String get tradeManualNoOfferedItemsInCollection =>
      'Du hast in dieser Sammlung keine verfügbaren doppelten Karten.';

  @override
  String get tradeManualNoRequestedItemsInCollection =>
      'Der andere Benutzer hat in dieser Sammlung keine verfügbaren doppelten Karten.';

  @override
  String tradeManualSelectedItems(int count) {
    return 'Ausgewählt: $count';
  }

  @override
  String tradeManualAvailableQuantity(int count) {
    return 'Zum Tauschen verfügbar: $count';
  }

  @override
  String get tradeManualChooseAtLeastOneEach =>
      'Wähle auf jeder Seite des Tauschs mindestens eine Karte aus.';

  @override
  String get tradeManualReviewOffer => 'Angebot prüfen';

  @override
  String get tradeManualSummaryRecipient => 'Empfänger';

  @override
  String get tradeManualSummaryOffering => 'Ich biete';

  @override
  String get tradeManualSummaryRequesting => 'Ich möchte';

  @override
  String get tradeManualSendOffer => 'Angebot senden';

  @override
  String get tradeManualSendingOffer => 'Angebot wird gesendet…';

  @override
  String get tradeManualOfferCreated => 'Das Tauschangebot wurde gesendet.';

  @override
  String tradeManualOfferError(String error) {
    return 'Das Angebot konnte nicht gesendet werden: $error';
  }

  @override
  String tradeManualYourInventoryUnavailable(String itemNumber) {
    return 'Karte #$itemNumber ist unter deinen doppelten Karten nicht mehr verfügbar.';
  }

  @override
  String tradeManualTheirInventoryUnavailable(String itemNumber) {
    return 'Karte #$itemNumber ist beim anderen Benutzer nicht mehr verfügbar.';
  }

  @override
  String tradeManualCatalogItemUnavailable(String itemNumber) {
    return 'Karte #$itemNumber konnte nicht dem Katalog zugeordnet werden.';
  }

  @override
  String get tradeManualInvalidOffer =>
      'Das Angebot ist ungültig. Prüfe die ausgewählten Karten und Mengen.';

  @override
  String get tradeManualBack => 'Zurück';

  @override
  String get forgotPassword => 'Passwort vergessen?';

  @override
  String get forgotPasswordTitle => 'Passwort zurücksetzen';

  @override
  String get forgotPasswordDescription =>
      'Gib die E-Mail-Adresse deines Kontos ein. Wir senden dir einen Link zum Festlegen eines neuen Passworts.';

  @override
  String get sendPasswordResetEmail => 'Link senden';

  @override
  String get sendingEmail => 'Wird gesendet…';

  @override
  String get passwordResetEmailSentTitle => 'E-Mails prüfen';

  @override
  String get passwordResetEmailSentDescription =>
      'Wenn ein Konto mit dieser E-Mail-Adresse existiert, erhältst du einen Link zum Zurücksetzen des Passworts.';

  @override
  String get backToSignIn => 'Zurück zur Anmeldung';

  @override
  String passwordResetError(String error) {
    return 'Der Link zum Zurücksetzen des Passworts konnte nicht gesendet werden: $error';
  }

  @override
  String get verifyEmailTitle => 'E-Mail-Adresse bestätigen';

  @override
  String verifyEmailDescription(String email) {
    return 'Wir haben eine Bestätigungsnachricht an $email gesendet. Öffne den Link in der Nachricht und prüfe anschließend den Status.';
  }

  @override
  String get checkVerificationStatus => 'Status prüfen';

  @override
  String get checkingVerification => 'Wird geprüft…';

  @override
  String get resendVerificationEmail => 'Bestätigungs-E-Mail erneut senden';

  @override
  String get verificationEmailSent => 'Die Bestätigungs-E-Mail wurde gesendet.';

  @override
  String verificationEmailSendError(String error) {
    return 'Die Bestätigungs-E-Mail konnte nicht gesendet werden: $error';
  }

  @override
  String get emailVerificationConfirmed => 'Die E-Mail-Adresse ist bestätigt.';

  @override
  String get emailStillNotVerified =>
      'Die E-Mail-Adresse ist noch nicht bestätigt.';

  @override
  String get continueWithoutVerification =>
      'Vorerst ohne Bestätigung fortfahren';

  @override
  String get emailVerified => 'E-Mail bestätigt';

  @override
  String get emailNotVerified => 'E-Mail nicht bestätigt';

  @override
  String get emailVerificationReminder =>
      'Die E-Mail-Adresse ist noch nicht bestätigt';

  @override
  String get accountSecurityTitle => 'Konto und Sicherheit';

  @override
  String get accountSecuritySubtitle => 'E-Mail, Passwort und Kontolöschung';

  @override
  String get changePasswordTitle => 'Passwort ändern';

  @override
  String get changePasswordSubtitle => 'Neues Anmeldepasswort festlegen';

  @override
  String get changePasswordDescription =>
      'Gib aus Sicherheitsgründen zuerst dein aktuelles Passwort ein und wähle anschließend ein neues.';

  @override
  String get currentPassword => 'Aktuelles Passwort';

  @override
  String get currentPasswordRequired => 'Gib dein aktuelles Passwort ein.';

  @override
  String get newPassword => 'Neues Passwort';

  @override
  String get newPasswordRequired => 'Gib ein neues Passwort ein.';

  @override
  String get newPasswordMustDiffer =>
      'Das neue Passwort muss sich vom aktuellen unterscheiden.';

  @override
  String get confirmNewPassword => 'Neues Passwort wiederholen';

  @override
  String get confirmNewPasswordRequired => 'Gib das neue Passwort erneut ein.';

  @override
  String get changePasswordButton => 'Passwort ändern';

  @override
  String get changingPassword => 'Wird geändert…';

  @override
  String get passwordChanged => 'Das Passwort wurde erfolgreich geändert.';

  @override
  String passwordChangeError(String error) {
    return 'Das Passwort konnte nicht geändert werden: $error';
  }

  @override
  String get deleteAccountTitle => 'Konto löschen';

  @override
  String get deleteAccountSubtitle =>
      'Profil, Sammlungen und Favoriten dauerhaft entfernen';

  @override
  String get deleteAccountWarningTitle =>
      'Diese Aktion kann nicht rückgängig gemacht werden';

  @override
  String get deleteAccountWarning =>
      'Dein Profil, Inventar, deine Sammlungen, Favoriten und dein Anmeldekonto werden gelöscht.';

  @override
  String get deleteAccountHistoryNotice =>
      'Zum Erhalt der Historie anderer Teilnehmer bleiben abgeschlossene Tauschvorgänge, Nachrichten und abgegebene Bewertungen ohne dein öffentliches Profil gespeichert.';

  @override
  String get deleteAccountConfirmationWord => 'LÖSCHEN';

  @override
  String deleteAccountConfirmationLabel(String word) {
    return 'Gib zur Bestätigung $word ein';
  }

  @override
  String deleteAccountConfirmationInvalid(String word) {
    return 'Gib $word ein.';
  }

  @override
  String get deleteAccountButton => 'Konto dauerhaft löschen';

  @override
  String get deletingAccount => 'Konto wird gelöscht…';

  @override
  String get deleteAccountConfirmationTitle => 'Dieses Konto löschen?';

  @override
  String get deleteAccountConfirmationMessage =>
      'Das Konto und deine persönlichen Profildaten werden dauerhaft entfernt.';

  @override
  String accountDeleteError(String error) {
    return 'Das Konto konnte nicht gelöscht werden: $error';
  }

  @override
  String get signOutConfirmationTitle => 'Abmelden';

  @override
  String get signOutConfirmationMessage =>
      'Möchtest du dich von diesem Konto abmelden?';

  @override
  String get authFirebaseRequiresRecentLogin =>
      'Melde dich aus Sicherheitsgründen erneut an.';

  @override
  String get authFirebaseUserDisabled =>
      'Dieses Benutzerkonto wurde deaktiviert.';

  @override
  String get authFirebaseOperationNotAllowed =>
      'Diese Anmeldemethode ist derzeit deaktiviert.';

  @override
  String get accountDeleteActiveTrades =>
      'Das Konto kann nicht gelöscht werden, solange aktive oder nicht abgeschlossene Tauschvorgänge bestehen.';

  @override
  String get tradeManualShowAllSurpluses => 'Alle Duplikate anzeigen';

  @override
  String get tradeManualSuggestedSurplusesDescription =>
      'Zuerst werden nur Duplikate angezeigt, die die Sammlung der anderen Person ergänzen.';

  @override
  String get tradeManualAllSurplusesDescription =>
      'Alle verfügbaren Duplikate beider Benutzer werden angezeigt.';

  @override
  String get tradeManualNoSuggestedOfferedItemsInCollection =>
      'Du hast keine Duplikate, die die Sammlung dieser Person ergänzen würden.';

  @override
  String get tradeManualNoSuggestedRequestedItemsInCollection =>
      'Diese Person hat keine Duplikate, die deine Sammlung ergänzen würden.';

  @override
  String get tradeRatingTitle => 'Tauschbewertung';

  @override
  String get tradeRatingYourRating => 'Deine Bewertung';

  @override
  String get tradeRatingEdit => 'Bewertung bearbeiten';

  @override
  String get tradeRatingCommentHint => 'Kurzer Kommentar (optional)';

  @override
  String get tradeRatingSaveChanges => 'Änderungen speichern';

  @override
  String get tradeRatingUpdating => 'Änderungen werden gespeichert...';

  @override
  String get tradeRatingUpdatedSuccessfully =>
      'Die Bewertung wurde erfolgreich aktualisiert.';

  @override
  String get tradeRatingSelectStars => 'Wähle 1 bis 5 Sterne.';

  @override
  String get ratingReviewsTitle => 'Erhaltene Bewertungen';

  @override
  String get ratingNoReviews => 'Dieser Sammler hat noch keine Bewertungen.';

  @override
  String get safetySettingsTitle => 'Sicherheit und Datenschutz';

  @override
  String get safetyMenu => 'Sicherheitsoptionen';

  @override
  String get safetyBlockUser => 'Benutzer blockieren';

  @override
  String get safetyBlockUserTitle => 'Benutzer blockieren';

  @override
  String get safetyBlockUserConfirmation =>
      'Dieser Benutzer kann dir keine Nachrichten oder neuen Tauschangebote senden. Auch du kannst keine Nachrichten oder neuen Angebote senden.';

  @override
  String get safetyUserBlocked => 'Der Benutzer wurde blockiert.';

  @override
  String get safetyUnblockUser => 'Entsperren';

  @override
  String get safetyUnblockUserTitle => 'Benutzer entsperren';

  @override
  String get safetyUnblockUserConfirmation =>
      'Nachrichten und neue Tauschangebote mit diesem Benutzer wieder erlauben?';

  @override
  String get safetyUserUnblocked => 'Der Benutzer wurde entsperrt.';

  @override
  String get safetyReportUser => 'Benutzer melden';

  @override
  String get safetyReportTrade => 'Tausch melden';

  @override
  String get safetyReportMessage => 'Nachricht melden';

  @override
  String get safetyReportTitle => 'Meldung senden';

  @override
  String get safetyReportDescription =>
      'Wähle einen Grund und füge optional Details hinzu. Nur ein Administrator kann die Meldung prüfen.';

  @override
  String get safetyReportReason => 'Grund';

  @override
  String get safetyReportReasonSpam => 'Spam oder unerwünschte Inhalte';

  @override
  String get safetyReportReasonHarassment => 'Belästigung oder Beleidigung';

  @override
  String get safetyReportReasonFraud => 'Verdacht auf Betrug';

  @override
  String get safetyReportReasonInappropriate => 'Unangemessene Inhalte';

  @override
  String get safetyReportReasonOther => 'Sonstiges';

  @override
  String get safetyReportDetails => 'Details (optional)';

  @override
  String get safetyReportDetailsHint => 'Beschreibe kurz, was passiert ist.';

  @override
  String get safetyReportSubmit => 'Meldung senden';

  @override
  String get safetyReportSubmitting => 'Wird gesendet...';

  @override
  String get safetyReportSubmitted => 'Die Meldung wurde gesendet.';

  @override
  String get safetyReportError => 'Die Meldung konnte nicht gesendet werden';

  @override
  String get safetyActionError => 'Die Aktion konnte nicht ausgeführt werden';

  @override
  String get safetyBlockedUsers => 'Blockierte Benutzer';

  @override
  String get safetyBlockedUsersDescription =>
      'Blockierte Benutzer ansehen und entsperren.';

  @override
  String get safetyBlockedUsersLoadError =>
      'Blockierte Benutzer konnten nicht geladen werden.';

  @override
  String get safetyNoBlockedUsers => 'Du hast keine blockierten Benutzer.';

  @override
  String get safetyConversationBlockedByYou =>
      'Du hast diesen Benutzer blockiert. Der Chat bleibt sichtbar, neue Nachrichten können jedoch nicht gesendet werden.';

  @override
  String get safetyConversationBlockedByOther =>
      'Das Senden neuer Nachrichten ist in diesem Chat nicht verfügbar.';

  @override
  String get safetyProfileBlockedByYou => 'Du hast diesen Benutzer blockiert.';

  @override
  String get safetyProfileBlockedByOther =>
      'Die Kommunikation mit diesem Benutzer ist nicht verfügbar.';

  @override
  String get safetyAdminReports => 'Meldungen prüfen';

  @override
  String get safetyAdminReportsDescription =>
      'Administrative Prüfung gemeldeter Benutzer und Inhalte.';

  @override
  String get safetyReportsLoadError =>
      'Meldungen konnten nicht geladen werden.';

  @override
  String get safetyNoReports =>
      'Für den ausgewählten Filter gibt es keine Meldungen.';

  @override
  String get safetyReportTypeUser => 'Benutzer';

  @override
  String get safetyReportTypeMessage => 'Nachricht';

  @override
  String get safetyReportTypeTrade => 'Tausch';

  @override
  String get safetyReportStatusOpen => 'Offen';

  @override
  String get safetyReportStatusReviewing => 'In Prüfung';

  @override
  String get safetyReportStatusResolved => 'Gelöst';

  @override
  String get safetyReportStatusDismissed => 'Abgewiesen';

  @override
  String get safetyReportStatusUpdated =>
      'Der Status der Meldung wurde aktualisiert.';

  @override
  String get safetyReporterId => 'Meldender Benutzer';

  @override
  String get safetyReportedUserId => 'Gemeldeter Benutzer';

  @override
  String get safetyTargetId => 'Gemeldeter Inhalt';

  @override
  String get safetyConversationId => 'Unterhaltung';

  @override
  String get tradeDeliverySectionTitle => 'Übergabe und Versand';

  @override
  String get tradeDeliverySectionDescription =>
      'Wähle eine Übergabeart und teile die erforderlichen privaten Daten mit deinem Tauschpartner.';

  @override
  String get tradeDeliveryYourDetails => 'Deine Angaben';

  @override
  String get tradeDeliveryPartnerDetails => 'Angaben des Partners';

  @override
  String get tradeDeliveryYourDetailsMissing =>
      'Du hast noch keine Übergabe- oder Versanddaten hinzugefügt.';

  @override
  String get tradeDeliveryPartnerDetailsMissing =>
      'Dein Partner hat noch keine Übergabe- oder Versanddaten hinzugefügt.';

  @override
  String get tradeDeliveryAdd => 'Hinzufügen';

  @override
  String get tradeDeliveryEdit => 'Bearbeiten';

  @override
  String get tradeDeliveryFormTitle => 'Übergabedaten';

  @override
  String get tradeDeliveryChooseMethod => 'Übergabeart';

  @override
  String get tradeDeliveryByMail => 'Per Post';

  @override
  String get tradeDeliveryInPerson => 'Persönliche Übergabe';

  @override
  String get tradeDeliveryFullName => 'Vor- und Nachname';

  @override
  String get tradeDeliveryAddressLine1 => 'Adresse';

  @override
  String get tradeDeliveryAddressLine2 => 'Zusätzliche Adresszeile (optional)';

  @override
  String get tradeDeliveryPostalCode => 'Postleitzahl';

  @override
  String get tradeDeliveryCity => 'Ort';

  @override
  String get tradeDeliveryCountry => 'Land';

  @override
  String get tradeDeliveryPhone => 'Telefonnummer (optional)';

  @override
  String get tradeDeliveryMeetingDetails => 'Details zur persönlichen Übergabe';

  @override
  String get tradeDeliveryMeetingDetailsHint =>
      'Schlage Ort, Zeit oder Art der Vereinbarung vor.';

  @override
  String get tradeDeliveryCarrier => 'Versanddienst (optional)';

  @override
  String get tradeDeliveryCarrierHint => 'Zum Beispiel Post, GLS oder DPD';

  @override
  String get tradeDeliveryTrackingNumber => 'Sendungsnummer (optional)';

  @override
  String get tradeDeliveryNotes => 'Hinweis (optional)';

  @override
  String get tradeDeliveryNotesHint =>
      'Füge wichtige Hinweise für deinen Partner hinzu.';

  @override
  String get tradeDeliveryPrivateTitle => 'Private Angaben';

  @override
  String get tradeDeliveryPrivateDescription =>
      'Diese Angaben sind nicht öffentlich. Nur der andere Teilnehmer des angenommenen Tauschs kann sie sehen.';

  @override
  String get tradeDeliveryPrivateShortDescription =>
      'Diese Angaben sind nur für die beiden Teilnehmer dieses angenommenen oder abgeschlossenen Tauschs sichtbar.';

  @override
  String get tradeDeliveryRequiredField => 'Dieses Feld ist erforderlich.';

  @override
  String get tradeDeliverySave => 'Angaben speichern';

  @override
  String get tradeDeliverySaving => 'Wird gespeichert...';

  @override
  String get tradeDeliverySaved => 'Die Übergabedaten wurden gespeichert.';

  @override
  String tradeDeliverySaveError(String error) {
    return 'Die Angaben konnten nicht gespeichert werden: $error';
  }

  @override
  String get tradeDeliveryLoadError =>
      'Die Übergabedaten konnten nicht geladen werden.';

  @override
  String get tradeDeliveryAddress => 'Versandadresse';

  @override
  String get tradeDeliveryTrackingMissing =>
      'Es wurde noch keine Sendungsnummer hinzugefügt.';

  @override
  String get tradeDeliveryCopyAddress => 'Adresse kopieren';

  @override
  String get tradeDeliveryCopyPhone => 'Telefonnummer kopieren';

  @override
  String get tradeDeliveryCopyTracking => 'Sendungsnummer kopieren';

  @override
  String get tradeDeliveryCopied => 'Die Angabe wurde kopiert.';

  @override
  String get continueLabel => 'Weiter';

  @override
  String get done => 'Fertig';

  @override
  String get betaOnboardingTitle => 'App-Einführung';

  @override
  String get betaOnboardingSkip => 'Überspringen';

  @override
  String get betaOnboardingStart => 'Jetzt starten';

  @override
  String get betaOnboardingCollectionsTitle => 'Sammlungen an einem Ort';

  @override
  String get betaOnboardingCollectionsDescription =>
      'Markiere vorhandene, fehlende und doppelte Karten. Die Übersicht deiner Sammlung wird laufend aktualisiert.';

  @override
  String get betaOnboardingTradesTitle => 'Sinnvolle Tausche finden';

  @override
  String get betaOnboardingTradesDescription =>
      'SwapStash vergleicht doppelte und fehlende Karten und schlägt Sammler vor, mit denen ein beiderseitig nützlicher Tausch möglich sein kann.';

  @override
  String get betaOnboardingCompleteTradeTitle =>
      'Vereinbaren, übergeben und bewerten';

  @override
  String get betaOnboardingCompleteTradeDescription =>
      'Sende ein Angebot, chatte, teile Übergabe- oder Versanddaten privat und bewerte den Partner nach Abschluss des Tauschs.';

  @override
  String get betaOnboardingSafetyTitle => 'Sicherheit und Kontrolle';

  @override
  String get betaOnboardingSafetyDescription =>
      'Blockiere Benutzer, melde unangemessene Inhalte und bestimme, welche Daten öffentlich oder nur für den Tauschpartner sichtbar sind.';

  @override
  String get betaOnboardingShowAgain => 'Einführung erneut anzeigen';

  @override
  String get betaOnboardingShowAgainDescription =>
      'Sieh dir die wichtigsten Funktionen der App noch einmal an.';

  @override
  String get legalAcceptanceTitle => 'Bedingungen und Datenschutz';

  @override
  String get legalAcceptanceHeading => 'Bevor du fortfährst';

  @override
  String get legalAcceptanceDescription =>
      'Lies bitte die grundlegenden Nutzungsregeln und Informationen zur Verarbeitung personenbezogener Daten.';

  @override
  String get legalAgeConfirmation =>
      'Ich bestätige, dass ich mindestens 13 Jahre alt bin. Wenn ich in Slowenien unter 15 Jahre alt bin, habe ich die Erlaubnis eines Elternteils oder Erziehungsberechtigten.';

  @override
  String get legalDocumentsConfirmation =>
      'Ich habe die Nutzungsbedingungen und die Datenschutzerklärung gelesen und akzeptiere sie.';

  @override
  String get legalAcceptAndContinue => 'Akzeptieren und weiter';

  @override
  String get legalAcceptanceSaving => 'Zustimmung wird gespeichert...';

  @override
  String get legalBetaNoticeTitle => 'Geschlossene Beta-Version';

  @override
  String get legalBetaNoticeDescription =>
      'Die App wird noch getestet. Funktionen können sich ändern und gelegentliche Fehler oder Unterbrechungen sind möglich.';

  @override
  String get legalTermsTitle => 'Nutzungsbedingungen';

  @override
  String get legalPrivacyTitle => 'Datenschutzerklärung';

  @override
  String get legalEffectiveDate => 'Gültig ab: 24. Juli 2026';

  @override
  String get legalContactFooter =>
      'Verantwortlicher: SwapStash · Kontakt: uros2004@gmail.com';

  @override
  String get legalTermsIntro =>
      'Diese Bedingungen regeln die Nutzung der SwapStash-App. Mit der Nutzung stimmst du ihnen zu.';

  @override
  String get legalTermsEligibilityTitle => '1. Alter und Benutzerkonto';

  @override
  String get legalTermsEligibilityBody =>
      'Die App darf von Personen ab 13 Jahren genutzt werden. Wenn das anwendbare Recht ein höheres Alter für eine eigenständige Einwilligung verlangt, muss ein minderjähriger Benutzer die Erlaubnis eines Elternteils oder Erziehungsberechtigten einholen. In Slowenien benötigen Benutzer unter 15 Jahren eine solche Erlaubnis. Benutzer müssen richtige Angaben machen, Zugangsdaten schützen und sind für Aktivitäten ihres Kontos verantwortlich.';

  @override
  String get legalTermsServiceTitle => '2. Zweck des Dienstes und Beta-Version';

  @override
  String get legalTermsServiceBody =>
      'SwapStash ermöglicht Sammlungsverwaltung, Suche nach möglichen Tauschen, Angebote, Nachrichten, Übergabeabsprachen und Bewertungen abgeschlossener Tausche. SwapStash ist weder Verkäufer, Käufer, Vermittler, Versanddienst noch Partei einer Vereinbarung zwischen Benutzern. Während der Beta können Funktionen geändert oder vorübergehend nicht verfügbar sein.';

  @override
  String get legalTermsConductTitle => '3. Zulässige Nutzung';

  @override
  String get legalTermsConductBody =>
      'Belästigung, Drohungen, Hassrede, Spam, Täuschung, Betrug, Identitätsmissbrauch, rechtswidrige Inhalte, Eingriffe in die App und nicht genehmigte automatisierte Nutzung sind verboten. Daten anderer Personen dürfen nicht ohne geeignete Rechtsgrundlage veröffentlicht werden.';

  @override
  String get legalTermsTradesTitle => '4. Tausche und Versand';

  @override
  String get legalTermsTradesBody =>
      'Benutzer prüfen selbst Zustand, Echtheit und Wert der Gegenstände und vereinbaren Übergabe, Kosten und Sendungsverfolgung. SwapStash garantiert nicht die Erfüllung durch die andere Partei und ersetzt keine verlorenen, beschädigten oder strittigen Sendungen. Für persönliche Übergaben sollte ein sicherer öffentlicher Ort gewählt werden; Minderjährige sollten einen Erwachsenen einbeziehen.';

  @override
  String get legalTermsContentTitle => '5. Nachrichten und Benutzerinhalte';

  @override
  String get legalTermsContentBody =>
      'Benutzer bleiben für eingegebene oder gesendete Inhalte verantwortlich. Aus Sicherheitsgründen, bei Meldungen, zur Missbrauchsbekämpfung oder zur Erfüllung gesetzlicher Pflichten kann SwapStash den Zugang einschränken, Inhalte entfernen oder Informationen an zuständige Behörden weitergeben, soweit dies notwendig und rechtmäßig ist.';

  @override
  String get legalTermsSuspensionTitle => '6. Blockierung und Maßnahmen';

  @override
  String get legalTermsSuspensionBody =>
      'Benutzer können andere Benutzer blockieren oder melden. SwapStash kann ein Konto einschränken oder schließen, wenn ein begründeter Verdacht auf einen Verstoß, Missbrauch, ein Sicherheitsrisiko oder rechtswidriges Verhalten besteht. Soweit möglich, wird der Benutzer über den Grund informiert.';

  @override
  String get legalTermsLiabilityTitle => '7. Verfügbarkeit und Haftung';

  @override
  String get legalTermsLiabilityBody =>
      'Der Dienst wird „wie besehen“ bereitgestellt. SwapStash bemüht sich um einen sicheren und zuverlässigen Betrieb, garantiert jedoch keine ununterbrochene Verfügbarkeit, vollständige Richtigkeit oder den Erfolg eines Tauschs. Haftungsbeschränkungen gelten nur im gesetzlich zulässigen Umfang und schließen keine zwingenden Rechte aus.';

  @override
  String get legalTermsChangesTitle => '8. Änderungen, Recht und Kontakt';

  @override
  String get legalTermsChangesBody =>
      'Die Bedingungen können wegen neuer Funktionen, Sicherheitsanforderungen oder Rechtsänderungen aktualisiert werden. Bei wesentlichen Änderungen fordert die App eine erneute Zustimmung. Es gilt slowenisches Recht unter Wahrung zwingender Rechte nach dem Recht des Landes des Benutzers. Fragen an uros2004@gmail.com.';

  @override
  String get legalPrivacyIntro =>
      'Diese Erklärung erläutert, welche personenbezogenen Daten SwapStash verarbeitet, warum sie verwendet werden und welche Rechte Benutzer haben.';

  @override
  String get legalPrivacyControllerTitle => '1. Verantwortlicher und Kontakt';

  @override
  String get legalPrivacyControllerBody =>
      'Verantwortlicher für personenbezogene Daten ist SwapStash. Datenschutzfragen, Anträge oder Widersprüche können an uros2004@gmail.com gesendet werden.';

  @override
  String get legalPrivacyDataTitle => '2. Verarbeitete Daten';

  @override
  String get legalPrivacyDataBody =>
      'Wir verarbeiten Konto- und Anmeldedaten, E-Mail-Adresse, Anzeigename, Land, Ort, Sprache, Profilfoto und Beschreibung; Sammlungs-, Karten- und Duplikatdaten; Angebote, Tauschstatus, Bewertungen, Nachrichten und Meldungen; freiwillig eingegebene Übergabe- oder Versanddaten; Push-Token sowie grundlegende technische und sicherheitsbezogene Daten.';

  @override
  String get legalPrivacyPurposeTitle => '3. Zwecke und Rechtsgrundlagen';

  @override
  String get legalPrivacyPurposeBody =>
      'Daten werden zur Kontoverwaltung, Bereitstellung von Sammlungs- und Tauschfunktionen, Kommunikation, Benachrichtigungen, Missbrauchsabwehr, Bearbeitung von Meldungen, Sicherheit, Support und Erfüllung gesetzlicher Pflichten verwendet. Rechtsgrundlagen sind Vertragserfüllung, Einwilligung, berechtigte Sicherheits- und Verbesserungsinteressen sowie gesetzliche Pflichten.';

  @override
  String get legalPrivacyVisibilityTitle =>
      '4. Sichtbarkeit und Weitergabe an andere Benutzer';

  @override
  String get legalPrivacyVisibilityBody =>
      'Ein öffentliches Profil kann Name, Foto, Standort, Beschreibung, Bewertungen und Tauschstatistiken zeigen. Nachrichten sind für Gesprächsteilnehmer sichtbar. Adresse, Telefonnummer, Angaben zur persönlichen Übergabe und Sendungsverfolgung sind nur für Teilnehmer eines angenommenen oder abgeschlossenen Tauschs sichtbar. Meldungen sind im zulässigen Umfang für den Meldenden und für Administratoren sichtbar.';

  @override
  String get legalPrivacyRetentionTitle => '5. Speicherung und Löschung';

  @override
  String get legalPrivacyRetentionBody =>
      'Daten werden so lange gespeichert, wie dies für Kontonutzung, Sicherheit, Streitbeilegung und gesetzliche Pflichten erforderlich ist. Benutzer können die Kontolöschung verlangen. Bestimmte Datensätze können begrenzt aufbewahrt werden, wenn dies zur Missbrauchsverhinderung, Rechtsdurchsetzung oder aufgrund gesetzlicher Pflichten nötig ist. Die lokale Zustimmung wird auf dem Gerät gespeichert.';

  @override
  String get legalPrivacyProcessorsTitle =>
      '6. Dienstleister und Übermittlungen';

  @override
  String get legalPrivacyProcessorsBody =>
      'Für Hosting, Anmeldung, Datenbank, Fotospeicherung und Push-Benachrichtigungen nutzen wir Firebase beziehungsweise Google Cloud und weitere technische Anbieter. Sie verarbeiten Daten nach Weisung und vertraglichen Pflichten. Bei Verarbeitung außerhalb des Europäischen Wirtschaftsraums werden geeignete Garantien wie Angemessenheitsbeschlüsse oder Standardvertragsklauseln verwendet.';

  @override
  String get legalPrivacyRightsTitle => '7. Rechte der Benutzer';

  @override
  String get legalPrivacyRightsBody =>
      'Je nach Umständen kannst du Auskunft, Berichtigung, Löschung, Einschränkung oder Datenübertragbarkeit verlangen oder der Verarbeitung widersprechen. Eine Einwilligung kann für die Zukunft widerrufen werden. Anfragen an uros2004@gmail.com. Eine Beschwerde beim slowenischen Informationsbeauftragten oder der zuständigen Aufsichtsbehörde ist ebenfalls möglich.';

  @override
  String get legalPrivacyChildrenTitle => '8. Kinder und Jugendliche';

  @override
  String get legalPrivacyChildrenBody =>
      'SwapStash richtet sich nicht an Kinder unter 13 Jahren. Benutzer im Alter von 13 oder 14 Jahren benötigen in Slowenien die Erlaubnis eines Elternteils oder Erziehungsberechtigten. Eltern oder Erziehungsberechtigte können Einsicht oder Löschung der Daten Minderjähriger verlangen. Minderjährige sollten ihre Wohnadresse nicht öffentlich teilen und persönliche Übergaben mit einem Erwachsenen durchführen.';

  @override
  String get legalPrivacySecurityTitle => '9. Sicherheit und Änderungen';

  @override
  String get legalPrivacySecurityBody =>
      'Wir verwenden technische und organisatorische Maßnahmen wie Zugriffskontrollen, private Untersammlungen, Datenbankregeln, Blockierungen, Meldungen und sichere Anmeldung. Kein System ist vollständig sicher. Wesentliche Änderungen werden in der App angezeigt und können eine erneute Zustimmung erfordern.';

  @override
  String get aboutAppTitle => 'Über die App';

  @override
  String get aboutAppDescription =>
      'SwapStash hilft Sammlern, Sammlungen zu verwalten, passende Partner zu finden und Tausche sicherer abzuschließen.';

  @override
  String get aboutVersion => 'App-Version';

  @override
  String get aboutVersionLoading => 'Version wird geladen...';

  @override
  String get aboutOperator => 'Verantwortlicher';

  @override
  String get aboutContact => 'Kontakt und Support';

  @override
  String get aboutLegalSection => 'Rechtliche Informationen';

  @override
  String get aboutSendFeedback => 'Feedback senden';

  @override
  String get aboutFeedbackEmailSubject => 'SwapStash Beta – Feedback';

  @override
  String get aboutFeedbackOpenError =>
      'Die E-Mail-App konnte nicht geöffnet werden.';

  @override
  String get aboutBetaFooter =>
      'Geschlossene Beta-Version · Daten und Funktionen können sich vor der öffentlichen Veröffentlichung ändern.';

  @override
  String get settingsAboutAndLegalTitle => 'Über die App und Rechtliches';

  @override
  String get settingsAboutAppSubtitle =>
      'Version, Kontakt, Feedback und Dokumente';
}
