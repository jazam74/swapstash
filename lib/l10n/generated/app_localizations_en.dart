// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'SwapStash';

  @override
  String get home => 'Home';

  @override
  String get collections => 'Collections';

  @override
  String get trades => 'Trades';

  @override
  String get messages => 'Messages';

  @override
  String get profile => 'Profile';

  @override
  String get welcomeUser => 'Welcome, Uroš!';

  @override
  String get welcomeDescription =>
      'Manage your collections and find the best trades.';

  @override
  String get newMatches => 'New matches';

  @override
  String get activeCollections => 'Active collections';

  @override
  String get addCollection => 'Add collection';

  @override
  String get sameCountry => 'Same country';

  @override
  String get international => 'International';

  @override
  String get reviewTrade => 'Review trade';

  @override
  String get noMessages => 'No messages';

  @override
  String get noMessagesDescription =>
      'Your trade conversations will appear here.';

  @override
  String get language => 'Language';

  @override
  String get internationalTrades => 'International trades';

  @override
  String get allowed => 'Allowed';

  @override
  String get successfulTrades => 'Successful trades';

  @override
  String get chooseLanguage => 'Choose your language';

  @override
  String get chooseLanguageDescription =>
      'Select the language you want to use in SwapStash. You can change it later in settings.';

  @override
  String get automaticLanguage => 'Automatic – device language';

  @override
  String get automaticLanguageDescription =>
      'Uses a supported device language automatically.';

  @override
  String get englishFallbackDescription =>
      'If the device language is not supported, English will be used.';

  @override
  String get continueButton => 'Continue';

  @override
  String get saving => 'Saving…';

  @override
  String get settings => 'Settings';

  @override
  String get applicationSettings => 'Application settings';

  @override
  String get languageSettingsDescription =>
      'Choose the application language. The change is applied immediately and saved for future launches.';

  @override
  String get languageChanged => 'The language has been changed.';

  @override
  String get profileLoadError => 'The profile could not be loaded:';

  @override
  String get profileMissing => 'The profile does not exist.';

  @override
  String get unnamedUser => 'Unnamed user';

  @override
  String get unknownUser => 'Unknown user';

  @override
  String get rating => 'Rating';

  @override
  String get completedTrades => 'Completed trades';

  @override
  String get profileVisibility => 'Profile visibility';

  @override
  String get publicProfile => 'Public';

  @override
  String get privateProfile => 'Private';

  @override
  String get notAllowed => 'Not allowed';

  @override
  String get editProfile => 'Edit profile';

  @override
  String get editProfileSubtitle => 'Name, city, description and privacy';

  @override
  String get signOut => 'Sign out';

  @override
  String get dashboardCatalogTooltip => 'Collection catalog';

  @override
  String get dashboardFavoritesTooltip => 'My favorites';

  @override
  String get dashboardLoadError => 'The dashboard could not be loaded';

  @override
  String get dashboardMyCollections => 'My collections';

  @override
  String get dashboardShowAll => 'Show all';

  @override
  String get dashboardOverview => 'Overview';

  @override
  String get dashboardYourCollections => 'Your collections';

  @override
  String get dashboardWelcomeTitle => 'Welcome!';

  @override
  String get dashboardWelcomeSubtitle =>
      'An overview of your collections and activity.';

  @override
  String get dashboardTodayTasks => 'Your tasks for today';

  @override
  String get dashboardAllDone => 'Everything is up to date';

  @override
  String get dashboardNoOpenTasks => 'You currently have no open tasks.';

  @override
  String get dashboardNoCollectionsTitle =>
      'You do not have any collections yet';

  @override
  String get dashboardNoCollectionsDescription =>
      'Open the Collections tab and add your first collection.';

  @override
  String get dashboardCollected => 'Collected';

  @override
  String get dashboardDuplicates => 'Duplicates';

  @override
  String get dashboardMissing => 'Missing';

  @override
  String get dashboardCollectionOpenError =>
      'The collection could not be opened.';

  @override
  String get dashboardCollectionNotFound =>
      'The collection could not be found.';

  @override
  String dashboardCollectionOpenErrorDetails(String error) {
    return 'The collection could not be opened: $error';
  }

  @override
  String dashboardUnreadMessages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count unread messages',
      one: '1 unread message',
    );
    return '$_temp0';
  }

  @override
  String get dashboardOpenConversation =>
      'Open the conversation and read the new messages.';

  @override
  String get dashboardRespondToCounterOffer => 'Respond to the counteroffer';

  @override
  String get dashboardRespondToOffer => 'Respond to the offer';

  @override
  String get dashboardConfirmHandover => 'Confirm card handover';

  @override
  String get dashboardConfirmReceipt => 'Confirm receipt of cards';

  @override
  String get dashboardOpenTrade => 'Open trade';

  @override
  String get dashboardOpenTradeAndContinue =>
      'Open the trade and continue the process.';

  @override
  String dashboardTradeWithUser(String userId) {
    return 'Trade with user $userId';
  }

  @override
  String get catalogAddToFavorites => 'Add to favorites';

  @override
  String get catalogAddedToFavorites => 'The item was added to favorites.';

  @override
  String catalogAdditionalFilterCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count additional filters',
      one: '$count additional filter',
    );
    return '$_temp0';
  }

  @override
  String get catalogAdditionalFilters => 'Additional filters';

  @override
  String catalogAdditionalFiltersCount(int count) {
    return 'Additional filters ($count)';
  }

  @override
  String get catalogAll => 'All';

  @override
  String get catalogAllRarities => 'All rarities';

  @override
  String get catalogApply => 'Apply';

  @override
  String get catalogAttributeBrand => 'Brand';

  @override
  String get catalogAttributeCharacter => 'Character';

  @override
  String get catalogAttributeCountry => 'Country';

  @override
  String get catalogAttributeDenomination => 'Denomination';

  @override
  String get catalogAttributeFranchise => 'Franchise';

  @override
  String get catalogAttributeManufacturer => 'Manufacturer';

  @override
  String get catalogAttributeMaterial => 'Material';

  @override
  String get catalogAttributeSeries => 'Series';

  @override
  String get catalogAttributeSet => 'Set';

  @override
  String get catalogAttributeTeam => 'Team';

  @override
  String get catalogAttributeTheme => 'Theme';

  @override
  String get catalogAttributeType => 'Type';

  @override
  String get catalogAttributeYear => 'Year';

  @override
  String get catalogCancel => 'Cancel';

  @override
  String get catalogCategory => 'Category';

  @override
  String get catalogChooseCsvOrXlsx => 'Choose CSV or XLSX';

  @override
  String get catalogClear => 'Clear';

  @override
  String get catalogClose => 'Close';

  @override
  String catalogCollectionAddError(String error) {
    return 'The collection could not be added: $error';
  }

  @override
  String catalogCollectionAdded(String name) {
    return '“$name” was added to your collections.';
  }

  @override
  String get catalogCollectionComplete =>
      'The collection is complete. No items are missing.';

  @override
  String catalogCollectionCreateError(String error) {
    return 'The collection could not be created: $error';
  }

  @override
  String get catalogCollectionCreatePermissionDenied =>
      'Firestore rejected collection creation. The signed-in user needs administrator permission.';

  @override
  String catalogCollectionCreatedForImport(String name) {
    return '“$name” was created and selected for import.';
  }

  @override
  String get catalogCollectionId => 'Collection ID';

  @override
  String catalogCollectionIdExists(String id) {
    return 'A collection with the ID “$id” already exists.';
  }

  @override
  String get catalogCollectionIdHelp =>
      'Lowercase letters, numbers and hyphens. Do not change it later.';

  @override
  String get catalogCollectionIdInvalid =>
      'Use only lowercase letters, numbers and hyphens.';

  @override
  String get catalogCollectionName => 'Collection name';

  @override
  String get catalogCollectionProgress => '📊 Collection progress';

  @override
  String catalogCollectionsLoadErrorDetails(String error) {
    return 'Collections could not be loaded:\n$error';
  }

  @override
  String get catalogCollectionsTitle => 'Collection catalog';

  @override
  String catalogColumnCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count columns',
      one: '$count column',
    );
    return '$_temp0';
  }

  @override
  String get catalogConfirmImport => 'Confirm import';

  @override
  String get catalogCreate => 'Create';

  @override
  String get catalogCreateNewCollection => 'Create new collection';

  @override
  String get catalogCreatingCollection => 'Creating collection ...';

  @override
  String get catalogDecreaseQuantity => 'Decrease quantity';

  @override
  String get catalogDisableQuickEntry => 'Disable quick entry';

  @override
  String get catalogDuplicates => 'Duplicates';

  @override
  String get catalogEnableQuickEntry => 'Enable quick entry';

  @override
  String get catalogEnterCollectionId => 'Enter the collection ID.';

  @override
  String get catalogEnterCollectionName => 'Enter the collection name.';

  @override
  String catalogFavoriteChangeError(String error) {
    return 'The favorite status could not be changed: $error';
  }

  @override
  String get catalogFileErrors => 'File errors';

  @override
  String get catalogFilterByRarity => 'Filter by rarity';

  @override
  String get catalogFindTrades => 'Find trades';

  @override
  String catalogFirstRows(int count) {
    return 'First $count';
  }

  @override
  String get catalogImageNotAdded => 'No image has been added yet';

  @override
  String get catalogImportAction => 'Import';

  @override
  String get catalogImportColumnHelp =>
      'The required columns are number and name. The rarity and imageUrl columns are optional. All other columns are automatically imported as additional attributes.';

  @override
  String get catalogImportCompleted => 'Import completed';

  @override
  String catalogImportConfirmRows(int count, String collectionName) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count valid rows will be processed',
      one: '$count valid row will be processed',
    );
    return '$_temp0 in “$collectionName”.';
  }

  @override
  String catalogImportCreated(int count) {
    return 'Created: $count';
  }

  @override
  String get catalogImportCsvAndExcel => 'CSV and Excel';

  @override
  String catalogImportCsvReadError(String error) {
    return 'The CSV file could not be read: $error';
  }

  @override
  String get catalogImportDescription =>
      'Import items from a CSV or XLSX file.';

  @override
  String get catalogImportDuplicateNumber =>
      'Duplicate number in the same file.';

  @override
  String get catalogImportExcelNoData => 'The Excel file contains no data.';

  @override
  String get catalogImportExistingSkipped => 'Existing items will be skipped.';

  @override
  String get catalogImportExistingUpdated =>
      'Existing items with the same number will be updated.';

  @override
  String catalogImportFailed(String error) {
    return 'Import failed: $error';
  }

  @override
  String get catalogImportFileNoData => 'The file contains no data.';

  @override
  String catalogImportFileOpenError(String error) {
    return 'The file could not be opened: $error';
  }

  @override
  String get catalogImportFileTooLarge =>
      'The file is larger than the allowed 20 MB.';

  @override
  String get catalogImportFileTooltip => 'Import CSV or XLSX';

  @override
  String catalogImportItems(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items',
      one: '$count item',
    );
    return 'Import $_temp0';
  }

  @override
  String get catalogImportMissingName => 'Name is missing.';

  @override
  String get catalogImportMissingNameColumn =>
      'The required “name” column is missing.';

  @override
  String get catalogImportMissingNumber => 'Number is missing.';

  @override
  String get catalogImportMissingNumberColumn =>
      'The required “number” column is missing.';

  @override
  String get catalogImportNoItemsBelowHeader =>
      'There are no items below the header row.';

  @override
  String get catalogImportPermissionDenied =>
      'Firestore rejected the import. The signed-in user must be an administrator to import into the central catalog.';

  @override
  String get catalogImportSkipHelp =>
      'Items with an existing number will not be changed.';

  @override
  String catalogImportSkipped(int count) {
    return 'Skipped: $count';
  }

  @override
  String get catalogImportSupportedFilesOnly =>
      'Only CSV and XLSX files are supported.';

  @override
  String get catalogImportTitle => 'Catalog import';

  @override
  String get catalogImportUpdateHelp =>
      'Items with an existing number will be updated.';

  @override
  String catalogImportUpdated(int count) {
    return 'Updated: $count';
  }

  @override
  String catalogImportXlsxReadError(String error) {
    return 'The XLSX file could not be read: $error';
  }

  @override
  String get catalogImporting => 'Importing ...';

  @override
  String get catalogIncreaseQuantity => 'Increase quantity';

  @override
  String get catalogInvalidNumber => 'Invalid number.';

  @override
  String catalogInvalidRows(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count invalid',
      one: '$count invalid',
    );
    return '$_temp0';
  }

  @override
  String get catalogInvalidYear => 'Invalid year.';

  @override
  String catalogInventoryLoadErrorDetails(String error) {
    return 'Inventory could not be loaded:\n$error';
  }

  @override
  String get catalogItemCount => 'Number of items';

  @override
  String catalogItemDefaultName(String number) {
    return 'Item $number';
  }

  @override
  String get catalogItemMarkedMissing => 'The item was marked as missing.';

  @override
  String get catalogItemMissing => 'Item is missing';

  @override
  String get catalogItemOwned => 'You own this item';

  @override
  String catalogItemStatusLoadErrorDetails(String error) {
    return 'The item status could not be loaded:\n$error';
  }

  @override
  String catalogItemsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items',
      one: '$count item',
    );
    return '$_temp0';
  }

  @override
  String catalogItemsLoadErrorDetails(String error) {
    return 'Items could not be loaded:\n$error';
  }

  @override
  String catalogLoadErrorDetails(String error) {
    return 'The catalog could not be loaded:\n$error';
  }

  @override
  String get catalogMissing => 'Missing';

  @override
  String get catalogMissingPlural => 'Missing';

  @override
  String get catalogNewCollection => 'New collection';

  @override
  String get catalogNoCollectionsFound => 'No collections found.';

  @override
  String get catalogNoDuplicates => 'You do not have any duplicates yet.';

  @override
  String get catalogNoFilterResults => 'No items match the selected filters.';

  @override
  String get catalogNoItems =>
      'This collection does not contain any items yet.';

  @override
  String get catalogNoOwnedItems => 'You do not own any items yet.';

  @override
  String get catalogNoSearchResults =>
      'No results match the search term and selected filters.';

  @override
  String get catalogNotOwned => 'Not owned';

  @override
  String get catalogOk => 'OK';

  @override
  String get catalogOpeningFile => 'Opening file ...';

  @override
  String get catalogOther => 'Other';

  @override
  String get catalogOwned => 'Owned';

  @override
  String catalogOwnedSurplusCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'You have $count duplicates.',
      one: 'You have $count duplicate.',
      zero: 'You have no duplicates.',
    );
    return '$_temp0';
  }

  @override
  String catalogPiecesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pieces',
      one: '$count piece',
    );
    return '$_temp0';
  }

  @override
  String get catalogPreview => 'Preview';

  @override
  String get catalogPublisher => 'Publisher';

  @override
  String get catalogQuantity => 'Quantity';

  @override
  String catalogQuantitySaveError(String error) {
    return 'The quantity could not be saved: $error';
  }

  @override
  String catalogQuantityUpdated(int quantity) {
    return 'The quantity was updated to $quantity.';
  }

  @override
  String get catalogRarity => 'Rarity';

  @override
  String get catalogRarityAll => 'Rarity: all';

  @override
  String get catalogRarityCommon => 'Common';

  @override
  String get catalogRarityLimitedEdition => 'Limited Edition';

  @override
  String get catalogRarityRare => 'Rare';

  @override
  String catalogRaritySelected(String value) {
    return 'Rarity: $value';
  }

  @override
  String get catalogRarityUltraRare => 'Ultra Rare';

  @override
  String catalogRarityValue(String value) {
    return 'Rarity: $value';
  }

  @override
  String get catalogRemoveFromFavorites => 'Remove from favorites';

  @override
  String get catalogRemovedFromFavorites =>
      'The item was removed from favorites.';

  @override
  String catalogResultsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count results',
      one: '$count result',
    );
    return '$_temp0';
  }

  @override
  String get catalogSearchHint => 'Search by number or name ...';

  @override
  String get catalogSelectTargetCollectionFirst =>
      'Select the target collection first.';

  @override
  String get catalogSelectValidFileFirst => 'Choose a valid file first.';

  @override
  String get catalogSelectedCollectionMissing =>
      'The selected collection no longer exists.';

  @override
  String catalogSheetName(String name) {
    return 'Sheet: $name';
  }

  @override
  String get catalogSkip => 'Skip';

  @override
  String get catalogSortItems => 'Sort items';

  @override
  String get catalogSortNameAscending => 'Name: A–Z';

  @override
  String get catalogSortNameDescending => 'Name: Z–A';

  @override
  String get catalogSortNumberAscending => 'Number: ascending';

  @override
  String get catalogSortNumberDescending => 'Number: descending';

  @override
  String get catalogSortRarityAscending => 'Rarity: A–Z';

  @override
  String get catalogSortRarityDescending => 'Rarity: Z–A';

  @override
  String catalogSurplusCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '+$count duplicates',
      one: '+$count duplicate',
    );
    return '$_temp0';
  }

  @override
  String get catalogTargetCollection => 'Target collection';

  @override
  String get catalogTotalPieces => 'Total pieces';

  @override
  String get catalogUnnamedItem => 'Unnamed item';

  @override
  String get catalogUpdate => 'Update';

  @override
  String catalogValidRows(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count valid',
      one: '$count valid',
    );
    return '$_temp0';
  }

  @override
  String get catalogYear => 'Year';

  @override
  String get cancel => 'Cancel';

  @override
  String get clearSearch => 'Clear search';

  @override
  String get noResults => 'No results';

  @override
  String get now => 'Now';

  @override
  String get sending => 'Sending...';

  @override
  String get tryAgain => 'Try again';

  @override
  String get yesterday => 'Yesterday';

  @override
  String get weekdayMondayShort => 'Mon';

  @override
  String get weekdayTuesdayShort => 'Tue';

  @override
  String get weekdayWednesdayShort => 'Wed';

  @override
  String get weekdayThursdayShort => 'Thu';

  @override
  String get weekdayFridayShort => 'Fri';

  @override
  String get weekdaySaturdayShort => 'Sat';

  @override
  String get weekdaySundayShort => 'Sun';

  @override
  String messageSendError(String error) {
    return 'The message could not be sent:\n$error';
  }

  @override
  String get messagesSearchHint => 'Search by user, collection, or message';

  @override
  String get messagesConversationEmptyPreview =>
      'This conversation has no messages yet.';

  @override
  String messagesYouPreview(String message) {
    return 'You: $message';
  }

  @override
  String get messagesEmptyTitle => 'You do not have any conversations yet';

  @override
  String get messagesEmptyDescription =>
      'You can start a conversation with a user you would like to trade with.';

  @override
  String get messagesTryAnotherSearch => 'Try a different search term.';

  @override
  String messagesNoConversationsForQuery(String query) {
    return 'No conversations were found for “$query”.';
  }

  @override
  String get messagesLoadError => 'Conversations could not be loaded';

  @override
  String get messagesSignInRequired => 'You must sign in to view messages.';

  @override
  String get messagesGenericUser => 'this user';

  @override
  String messagesStartConversationWith(String name) {
    return 'Start a conversation with $name';
  }

  @override
  String messagesConversationAboutCollection(String collectionName) {
    return 'This conversation is about the $collectionName collection.';
  }

  @override
  String get messagesWriteFirstMessage =>
      'Write the first message and arrange a trade.';

  @override
  String get messagesChatLoadError => 'Messages could not be loaded.';

  @override
  String get messagesWriteMessageHint => 'Write a message...';

  @override
  String get messagesSendMessage => 'Send message';

  @override
  String get tradeAccept => 'Accept';

  @override
  String get tradeArchiveEmpty => 'The archive is empty.';

  @override
  String tradeAutomaticProposalDescription(
    int offeredCount,
    int requestedCount,
  ) {
    return 'SwapStash suggests a balanced trade of $offeredCount for $requestedCount.';
  }

  @override
  String get tradeAutomaticProposalTitle => 'Automatic trade proposal';

  @override
  String get tradeBackToResults => 'Back to results';

  @override
  String get tradeCanOffer => 'You can offer';

  @override
  String get tradeCanReceive => 'You can receive';

  @override
  String get tradeCancelOffer => 'Cancel offer';

  @override
  String get tradeCardFromCollection => 'Card from the collection';

  @override
  String tradeCardsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cards',
      one: '$count card',
    );
    return '$_temp0';
  }

  @override
  String tradeCardsLoadError(String error) {
    return 'Cards could not be loaded:\n$error';
  }

  @override
  String get tradeCollectionMissing => 'The trade does not have a collection.';

  @override
  String get tradeCommentHint =>
      'For example: quick agreement and cards in excellent condition.';

  @override
  String get tradeComparisonTitle => 'Trade comparison';

  @override
  String tradeCompletedSteps(int completed, int total) {
    return '$completed of $total steps';
  }

  @override
  String get tradeConfirmHandoverButton => 'Yes, confirm handover';

  @override
  String get tradeConfirmHandoverDescription =>
      'Confirm only after you have actually handed the cards to the other party. After confirmation, the cards will be removed from your inventory. This step cannot be undone.';

  @override
  String get tradeConfirmHandoverTitle => 'Confirm card handover';

  @override
  String get tradeConfirmReceiptButton => 'Yes, confirm receipt';

  @override
  String get tradeConfirmReceiptDescription =>
      'Confirm only after you have actually received the agreed cards. After confirmation, they will be added to your inventory. This step cannot be undone.';

  @override
  String get tradeConfirmReceiptTitle => 'Confirm receipt of cards';

  @override
  String tradeConversationOpenError(String error) {
    return 'The conversation could not be opened:\n$error';
  }

  @override
  String get tradeCounterOfferDescription =>
      'Change the offer. The ratio is unrestricted, so you can change a 3-for-3 proposal to 5-for-3, for example.';

  @override
  String get tradeCounterOfferItemsUnavailable =>
      'The selected cards are no longer available for the counteroffer.';

  @override
  String get tradeCounterOfferNeedsBothSides =>
      'A counteroffer must contain at least one item on both sides.';

  @override
  String tradeCounterOfferSendError(String error) {
    return 'The counteroffer could not be sent: $error';
  }

  @override
  String get tradeCounterOfferTitle => 'Counteroffer';

  @override
  String get tradeDirectionCounterOffer => 'COUNTEROFFER';

  @override
  String get tradeDirectionReceivedOffer => 'RECEIVED OFFER';

  @override
  String get tradeDirectionSentOffer => 'SENT OFFER';

  @override
  String get tradeFilterCancelled => 'Cancelled';

  @override
  String get tradeFilterCompleted => 'Completed';

  @override
  String get tradeFilterRejected => 'Rejected';

  @override
  String get tradeFindTrades => 'Find trades';

  @override
  String get tradeFromTask => 'Trade from task';

  @override
  String get tradeHandoverConfirmed => 'Handover confirmed ✓';

  @override
  String get tradeHandoverConfirmedSuccess =>
      'The card handover has been confirmed and the inventory updated.';

  @override
  String get tradeIAmOffering => 'I am offering';

  @override
  String get tradeIWant => 'I want';

  @override
  String get tradeItemSelectionNextStep =>
      'Item selection comes in the next step.';

  @override
  String get tradeItemsNextStep => 'The item list comes in the next step.';

  @override
  String get tradeLoadError => 'Trades could not be loaded.';

  @override
  String tradeLoadErrorDetails(String error) {
    return 'Trades could not be loaded:\n$error';
  }

  @override
  String get tradeNewTrade => 'New trade';

  @override
  String get tradeNoAvailableItems => 'No items are available.';

  @override
  String get tradeNoCancelledTrades => 'There are no cancelled trades.';

  @override
  String get tradeNoCards => 'No cards.';

  @override
  String get tradeNoCompletedTrades => 'There are no completed trades.';

  @override
  String get tradeNoIncomingTrades => 'There are no received trades.';

  @override
  String get tradeNoMatchesFound =>
      'No possible trades were found at the moment.';

  @override
  String get tradeNoMatchesHint =>
      'Check that you have marked your duplicates and that other users use the same collection.';

  @override
  String get tradeNoOutgoingTrades => 'There are no sent trades.';

  @override
  String get tradeNoRejectedTrades => 'There are no rejected trades.';

  @override
  String get tradeNoTradesYet => 'You do not have any trades yet.';

  @override
  String get tradeNoUsersMatch => 'No users match the search.';

  @override
  String get tradeOfferAcceptedSuccess => 'The trade has been accepted.';

  @override
  String get tradeOfferCancelledSuccess => 'The offer has been cancelled.';

  @override
  String get tradeOfferRejectedSuccess => 'The offer has been rejected.';

  @override
  String get tradeOpeningConversation => 'Opening conversation...';

  @override
  String get tradeOptionalComment => 'Comment (optional)';

  @override
  String tradePossibleTradesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count possible trades',
      one: '$count possible trade',
    );
    return '$_temp0';
  }

  @override
  String get tradeProgressAgreed => 'Trade agreed';

  @override
  String get tradeProgressIHandedOver => 'I handed over the cards';

  @override
  String get tradeProgressIReceived => 'I received the cards';

  @override
  String get tradeProgressOtherHandedOver =>
      'The other party handed over the cards';

  @override
  String get tradeProgressOtherReceived => 'The other party received the cards';

  @override
  String get tradeProgressTitle => 'Trade progress';

  @override
  String tradeProposalSendError(String error) {
    return 'The trade proposal could not be sent:\n$error';
  }

  @override
  String get tradeProposalSentSuccessfully =>
      'The trade proposal was sent successfully.';

  @override
  String get tradeRateUser => 'Rate user';

  @override
  String get tradeRatingQuestion =>
      'How satisfied are you with the completed trade?';

  @override
  String tradeRatingSubmitError(String error) {
    return 'The rating could not be submitted: $error';
  }

  @override
  String get tradeRatingSubmitted => 'Rating submitted.';

  @override
  String get tradeRatingSubmittedSuccessfully =>
      'The rating was submitted successfully.';

  @override
  String get tradeRatingUnavailable =>
      'Rating is currently unavailable. Check whether the new Firestore rules have been deployed.';

  @override
  String get tradeReceiptConfirmed => 'Receipt confirmed ✓';

  @override
  String get tradeReceiptConfirmedSuccess =>
      'Receipt of the cards has been confirmed and the inventory updated.';

  @override
  String get tradeRecipient => 'Recipient';

  @override
  String get tradeReject => 'Reject';

  @override
  String get tradeRemoveRecipient => 'Remove recipient';

  @override
  String get tradeSearchUserHint => 'Search for a user by name...';

  @override
  String get tradeSendCounterOffer => 'Send counteroffer';

  @override
  String tradeSendMessageToUser(String name) {
    return 'Send a message to $name';
  }

  @override
  String get tradeSendProposal => 'Send proposal';

  @override
  String get tradeSendingProposal => 'Sending proposal...';

  @override
  String tradeStarsOutOfFive(int value) {
    return '$value out of 5';
  }

  @override
  String get tradeSubmitRating => 'Submit rating';

  @override
  String get tradeSubmittingRating => 'Submitting rating...';

  @override
  String get tradeSuggestAutomatically => 'Suggest a trade automatically';

  @override
  String get tradeSummaryTitle => 'Trade summary';

  @override
  String get tradeTabAll => 'All';

  @override
  String get tradeTabArchive => 'Archive';

  @override
  String get tradeTabReceived => 'Received';

  @override
  String get tradeTabSent => 'Sent';

  @override
  String get tradeTheirDuplicates => 'Their duplicates';

  @override
  String get tradeTheirDuplicatesYouNeed =>
      'Their duplicates that you do not have yet.';

  @override
  String tradeUserCanOffer(String name) {
    return '$name can offer';
  }

  @override
  String tradeUserHasNoDuplicatesYouNeed(String name) {
    return '$name currently has no duplicates that you need.';
  }

  @override
  String tradeUserNeedsNoneOfYourDuplicates(String name) {
    return '$name currently does not need any of your duplicates.';
  }

  @override
  String tradeUserOffers(String name) {
    return '$name offers:';
  }

  @override
  String tradeUserSearchError(String error) {
    return 'Users could not be searched:\n$error';
  }

  @override
  String get tradeWantedItemsNextStep =>
      'The wanted-item list comes in the next step.';

  @override
  String get tradeWith => 'Trade with';

  @override
  String get tradeYouCanOffer => 'You can offer';

  @override
  String get tradeYouGive => 'You give';

  @override
  String get tradeYouOfferColon => 'You offer:';

  @override
  String tradeYouOfferCount(int count) {
    return '$count offered';
  }

  @override
  String get tradeYouReceive => 'You receive';

  @override
  String tradeYouReceiveCount(int count) {
    return '$count received';
  }

  @override
  String get tradeYourDuplicatesTheyNeed =>
      'Your duplicates that this user does not have yet.';

  @override
  String get tradeAllowsInternationalTrades => 'Allows international trades';

  @override
  String tradeActionExecutionError(String error) {
    return 'The action could not be completed: $error';
  }

  @override
  String get tradeActionCompletedTitle => 'Trade completed';

  @override
  String get tradeActionCompletedDescription =>
      'Both parties confirmed handover and receipt of the cards. The inventories have been updated.';

  @override
  String get tradeActionRejectedTitle => 'The offer was rejected';

  @override
  String get tradeActionCancelledTitle => 'The offer was cancelled';

  @override
  String get tradeActionNoActionRequired =>
      'No further action is required for this offer.';

  @override
  String get tradeActionYourTurnTitle => 'It is your turn';

  @override
  String get tradeActionReviewOfferDescription =>
      'Review the cards and accept, reject, or send a counteroffer.';

  @override
  String get tradeActionOtherTurnTitle => 'It is the other party\'s turn';

  @override
  String get tradeActionWaitingResponseDescription =>
      'No action is required right now. Waiting for the other user\'s response.';

  @override
  String get tradeActionNoActionTitle => 'No action is currently required';

  @override
  String get tradeActionStatusNoResponseDescription =>
      'The trade status does not require your response.';

  @override
  String get tradeActionNextStepTitle => 'Next step';

  @override
  String get tradeActionConfirmHandoverDescription =>
      'After you actually hand your cards to the other party, confirm the handover. They will then be deducted from your inventory.';

  @override
  String get tradeActionConfirmReceiptDescription =>
      'After you actually receive the agreed cards, confirm receipt. They will then be added to your inventory.';

  @override
  String get tradeActionWaitingOtherHandoverDescription =>
      'You have already confirmed the handover. Waiting for the other party to hand over their cards.';

  @override
  String get tradeActionWaitingOtherConfirmationTitle =>
      'Waiting for the other party\'s confirmation';

  @override
  String get tradeActionWaitingOtherReceiptDescription =>
      'You have already confirmed receipt. The trade will finish when the other party confirms receipt as well.';

  @override
  String get tradeActionWaitingNextConfirmationDescription =>
      'Waiting for the other party\'s next confirmation.';

  @override
  String get tradeStatusCompletedTitle => 'Trade completed';

  @override
  String get tradeStatusCompletedSubtitle =>
      'Both users confirmed handover and receipt.';

  @override
  String get tradeStatusCompletedBadge => 'Completed';

  @override
  String get tradeStatusRejectedTitle => 'Offer rejected';

  @override
  String get tradeStatusRejectedSubtitle =>
      'This trade proposal was not accepted.';

  @override
  String get tradeStatusRejectedBadge => 'Rejected';

  @override
  String get tradeStatusCancelledTitle => 'Offer cancelled';

  @override
  String get tradeStatusCancelledSubtitle =>
      'The sender cancelled the trade proposal.';

  @override
  String get tradeStatusCancelledBadge => 'Cancelled';

  @override
  String get tradeStatusCounterOfferReceivedTitle =>
      'You received a counteroffer';

  @override
  String get tradeStatusAwaitingYourResponseTitle =>
      'The offer is waiting for your response';

  @override
  String get tradeStatusReviewOfferSubtitle =>
      'Review the cards and select Accept, Reject, or Counteroffer.';

  @override
  String get tradeStatusWaitingForYouBadge => 'Waiting for you';

  @override
  String get tradeStatusCounterOfferSentTitle => 'Counteroffer sent';

  @override
  String get tradeStatusOfferSentTitle => 'Offer sent';

  @override
  String get tradeStatusWaitingOtherUserSubtitle =>
      'Waiting for the other user\'s response.';

  @override
  String get tradeStatusWaitingResponseBadge => 'Waiting for response';

  @override
  String get tradeStatusReceivedTitle => 'You received the package';

  @override
  String get tradeStatusReceivedSubtitle =>
      'The received cards were added to your inventory. Waiting for the other party\'s confirmation.';

  @override
  String get tradeStatusReceivedBadge => 'Received';

  @override
  String get tradeStatusBothOnWayTitle => 'Both packages are on the way';

  @override
  String get tradeStatusPackageOnWayTitle => 'A package is on its way to you';

  @override
  String get tradeStatusBothOnWaySubtitle =>
      'Both packages have been handed over. Confirm receipt when your package arrives.';

  @override
  String get tradeStatusOtherSentSubtitle =>
      'The other party handed over the package. Your cards are still reserved.';

  @override
  String get tradeStatusOnWayBadge => 'On the way';

  @override
  String get tradeStatusSentTitle => 'You sent the package';

  @override
  String get tradeStatusSentSubtitle =>
      'The handed-over cards were removed from your inventory. Waiting for the other party.';

  @override
  String get tradeStatusSentBadge => 'Sent';

  @override
  String get tradeStatusOtherReceivedTitle =>
      'The other party received the package';

  @override
  String get tradeStatusConfirmWhenReceivedSubtitle =>
      'Confirm receipt when your package arrives.';

  @override
  String get tradeStatusWaitingReceiptBadge => 'Waiting for receipt';

  @override
  String get tradeStatusAgreedTitle => 'Trade agreed';

  @override
  String get tradeStatusAgreedSubtitle =>
      'The cards on both sides are reserved. The inventory changes only after handover or receipt is confirmed.';

  @override
  String get tradeStatusAgreedBadge => 'Agreed';

  @override
  String get authLoginSubtitle => 'Sign in to your account';

  @override
  String get authRegisterSubtitle => 'Create a new collector account';

  @override
  String get authDisplayNameLabel => 'Display name';

  @override
  String get authDisplayNameHint => 'For example Alex';

  @override
  String get authDisplayNameRequired => 'Enter a display name.';

  @override
  String get authDisplayNameMinLength =>
      'The name must contain at least 2 characters.';

  @override
  String get authDisplayNameMaxLength =>
      'The name can contain no more than 40 characters.';

  @override
  String get authEmailLabel => 'Email address';

  @override
  String get authEmailRequired => 'Enter your email address.';

  @override
  String get authEmailInvalid => 'Enter a valid email address.';

  @override
  String get authPasswordLabel => 'Password';

  @override
  String get authShowPassword => 'Show password';

  @override
  String get authHidePassword => 'Hide password';

  @override
  String get authPasswordRequired => 'Enter your password.';

  @override
  String get authPasswordMinLength =>
      'The password must contain at least 6 characters.';

  @override
  String get authConfirmPasswordLabel => 'Confirm password';

  @override
  String get authConfirmPasswordRequired => 'Enter your password again.';

  @override
  String get authPasswordsDoNotMatch => 'The passwords do not match.';

  @override
  String get authLoginButton => 'Sign in';

  @override
  String get authCreateAccountButton => 'Create account';

  @override
  String get authNoAccountRegister => 'Do not have an account? Register';

  @override
  String get authHaveAccountLogin => 'Already have an account? Sign in';

  @override
  String get authInvalidData => 'The entered data is not valid.';

  @override
  String authUnexpectedError(String error) {
    return 'An unexpected error occurred: $error';
  }

  @override
  String get authFirebaseInvalidEmail => 'The email address is not valid.';

  @override
  String get authFirebaseEmailAlreadyInUse =>
      'An account with this email address already exists.';

  @override
  String get authFirebaseWeakPassword => 'The password is too weak.';

  @override
  String get authFirebaseInvalidCredentials =>
      'The email address or password is incorrect.';

  @override
  String get authFirebaseTooManyRequests =>
      'Too many attempts. Try again later.';

  @override
  String get authFirebaseNetworkError => 'Check your internet connection.';

  @override
  String get authFirebaseGenericError => 'Sign-in or registration failed.';

  @override
  String get favoritesTitle => 'My favorites';

  @override
  String get favoritesSearchHint => 'Search favorites';

  @override
  String get favoritesClearSearch => 'Clear';

  @override
  String get favoritesRemoved => 'Removed from favorites.';

  @override
  String favoritesNamedItemRemoved(String name) {
    return '“$name” was removed from favorites.';
  }

  @override
  String favoritesRemoveError(String error) {
    return 'Could not remove the favorite: $error';
  }

  @override
  String get favoritesUnnamedItem => 'Unnamed item';

  @override
  String get favoritesRemoveTooltip => 'Remove from favorites';

  @override
  String get favoritesEmptyTitle => 'You do not have any favorites yet';

  @override
  String get favoritesEmptyDescription =>
      'Tap the heart on an item’s details page and it will appear here.';

  @override
  String get favoritesNoResults => 'No results.';

  @override
  String favoritesNoResultsForQuery(String query) {
    return 'No favorites were found for “$query”.';
  }

  @override
  String get favoritesLoadError => 'Favorites could not be loaded.';

  @override
  String get myCollectionsTitle => 'My collections';

  @override
  String get myCollectionsAddFromCatalog => 'Add a collection from the catalog';

  @override
  String get myCollectionsAddButton => 'Add collection';

  @override
  String get myCollectionsRemoveTitle => 'Remove collection';

  @override
  String myCollectionsRemoveQuestion(String name) {
    return 'Do you want to remove “$name” from your collections?';
  }

  @override
  String get myCollectionsRemoveButton => 'Remove';

  @override
  String myCollectionsRemoved(String name) {
    return '“$name” was removed from your collections.';
  }

  @override
  String myCollectionsRemoveError(String error) {
    return 'The collection could not be removed: $error';
  }

  @override
  String myCollectionsLoadError(String error) {
    return 'Your collections could not be loaded:\n$error';
  }

  @override
  String get myCollectionsCatalogLoadError =>
      'The collection could not be loaded.';

  @override
  String get myCollectionsCatalogMissing =>
      'The catalog collection does not exist.';

  @override
  String get myCollectionsStatisticsLoadError =>
      'Collection statistics could not be loaded.';

  @override
  String get myCollectionsStatisticsUnavailable =>
      'Collection statistics are unavailable.';

  @override
  String get myCollectionsEmptyTitle =>
      'You have not added any collections yet.';

  @override
  String get myCollectionsEmptyDescription =>
      'Choose a collection from the central catalog.';

  @override
  String get myCollectionsOpenCatalog => 'Open catalog';

  @override
  String get myCollectionsUnnamedCollection => 'Unnamed collection';

  @override
  String get myCollectionsMenuTooltip => 'Collection options';

  @override
  String get myCollectionsEditMenu => 'Edit';

  @override
  String get myCollectionsRemoveMenu => 'Remove';

  @override
  String myCollectionsProgressCount(int owned, int total) {
    return 'Collected: $owned / $total';
  }

  @override
  String myCollectionsDuplicateCount(int count) {
    return 'Duplicates: $count';
  }

  @override
  String myCollectionsMissingCount(int count) {
    return 'Missing: $count';
  }

  @override
  String get collectors => 'Collectors';

  @override
  String get editProfileDisplayName => 'Display name';

  @override
  String get editProfileCity => 'City';

  @override
  String get editProfileBio => 'About me';

  @override
  String get editProfilePublicTitle => 'Public profile';

  @override
  String get editProfilePublicSubtitle => 'Other users can find you.';

  @override
  String get editProfileInternationalTitle => 'Allow international trades';

  @override
  String get editProfileInternationalSubtitle =>
      'You can receive offers from other countries.';

  @override
  String get editProfileSave => 'Save';

  @override
  String get editProfileSaving => 'Saving…';

  @override
  String get editProfileSaved => 'The profile was saved successfully.';

  @override
  String editProfileSaveError(String error) {
    return 'The profile could not be saved: $error';
  }

  @override
  String editProfileLoadError(String error) {
    return 'The profile could not be loaded:\n$error';
  }

  @override
  String get editProfileMissing => 'The profile does not exist.';

  @override
  String get editProfileDisplayNameRequired => 'Enter a display name.';

  @override
  String get collectorsSearchLabel => 'Search collectors';

  @override
  String get collectorsSearchHint => 'Enter a display name';

  @override
  String collectorsSearchError(String error) {
    return 'Users could not be searched:\n$error';
  }

  @override
  String get collectorsNoResults => 'No collectors were found.';

  @override
  String get collectorsSearchDescription =>
      'Find other collectors by display name.';

  @override
  String get collectorsInternationalAllowed => 'International trades allowed';

  @override
  String get collectorsLocalOnly => 'Local trades only';

  @override
  String get collectorProfileTitle => 'Collector profile';

  @override
  String get collectorProfileMissing => 'The user profile does not exist.';

  @override
  String collectorChatOpenError(String error) {
    return 'The conversation could not be opened:\n$error';
  }

  @override
  String get collectorOpeningChat => 'Opening conversation…';

  @override
  String get collectorSendMessage => 'Send message';

  @override
  String get collectorInternationalTrades => 'International trades';

  @override
  String get collectorLocalTrades => 'Local trades';

  @override
  String get collectorAbout => 'About the collector';

  @override
  String get collectorPrivateTitle => 'This profile is private';

  @override
  String get collectorPrivateDescription =>
      'The location, description and rating comments are not shown publicly.';

  @override
  String collectorProfileLoadError(String error) {
    return 'The profile could not be loaded:\n$error';
  }

  @override
  String get ratingUnavailable => 'Rating unavailable';

  @override
  String get ratingLoading => 'Loading ratings';

  @override
  String get ratingNone => 'No ratings';

  @override
  String ratingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ratings',
      one: '1 rating',
    );
    return '$_temp0';
  }

  @override
  String get ratingCommentsLoadError => 'Rating comments could not be loaded.';

  @override
  String get ratingNoPublicComments =>
      'This collector has no public comments yet.';

  @override
  String get ratingRecentComments => 'Recent comments';

  @override
  String get catalogCategorySportsCards => 'Sports cards';

  @override
  String get collectorsNavigation => 'Collectors';

  @override
  String get tradeManualStepRecipient => 'Recipient';

  @override
  String get tradeManualStepItems => 'Cards';

  @override
  String get tradeManualStepSummary => 'Summary';

  @override
  String get tradeManualChooseRecipientDescription =>
      'Find the collector you want to send a trade offer to.';

  @override
  String get tradeManualChangeRecipient => 'Change';

  @override
  String get tradeManualLoadingOptions =>
      'Checking shared collections and available cards…';

  @override
  String tradeManualOptionsError(String error) {
    return 'Trade cards could not be loaded: $error';
  }

  @override
  String get tradeManualNoCommonCollections => 'No shared collection';

  @override
  String get tradeManualNoCommonCollectionsDescription =>
      'Both users must have at least one of the same collections to create a manual trade.';

  @override
  String get tradeManualNoAvailableItems => 'No cards are currently available';

  @override
  String get tradeManualNeedsBothDirections =>
      'Each user must have at least one available duplicate for an offer.';

  @override
  String get tradeManualChooseCollection => 'Collection';

  @override
  String get tradeManualSelectionsRemainAcrossCollections =>
      'One offer can contain cards from only one collection. Switching collections clears the selection.';

  @override
  String get tradeManualNoOfferedItemsInCollection =>
      'You have no available duplicates in this collection.';

  @override
  String get tradeManualNoRequestedItemsInCollection =>
      'The other user has no available duplicates in this collection.';

  @override
  String tradeManualSelectedItems(int count) {
    return 'Selected: $count';
  }

  @override
  String tradeManualAvailableQuantity(int count) {
    return 'Available to trade: $count';
  }

  @override
  String get tradeManualChooseAtLeastOneEach =>
      'Select at least one card on each side of the trade.';

  @override
  String get tradeManualReviewOffer => 'Review offer';

  @override
  String get tradeManualSummaryRecipient => 'Recipient';

  @override
  String get tradeManualSummaryOffering => 'I offer';

  @override
  String get tradeManualSummaryRequesting => 'I request';

  @override
  String get tradeManualSendOffer => 'Send offer';

  @override
  String get tradeManualSendingOffer => 'Sending offer…';

  @override
  String get tradeManualOfferCreated => 'The trade offer was sent.';

  @override
  String tradeManualOfferError(String error) {
    return 'The offer could not be sent: $error';
  }

  @override
  String tradeManualYourInventoryUnavailable(String itemNumber) {
    return 'Card #$itemNumber is no longer available among your duplicates.';
  }

  @override
  String tradeManualTheirInventoryUnavailable(String itemNumber) {
    return 'Card #$itemNumber is no longer available from the other user.';
  }

  @override
  String tradeManualCatalogItemUnavailable(String itemNumber) {
    return 'Card #$itemNumber could not be matched to the catalog.';
  }

  @override
  String get tradeManualInvalidOffer =>
      'The offer is not valid. Check the selected cards and quantities.';

  @override
  String get tradeManualBack => 'Back';

  @override
  String get forgotPassword => 'Forgot password?';

  @override
  String get forgotPasswordTitle => 'Reset password';

  @override
  String get forgotPasswordDescription =>
      'Enter the email address for your account. We will send you a link to set a new password.';

  @override
  String get sendPasswordResetEmail => 'Send reset link';

  @override
  String get sendingEmail => 'Sending…';

  @override
  String get passwordResetEmailSentTitle => 'Check your email';

  @override
  String get passwordResetEmailSentDescription =>
      'If an account with this email address exists, you will receive a password reset link.';

  @override
  String get backToSignIn => 'Back to sign in';

  @override
  String passwordResetError(String error) {
    return 'The password reset link could not be sent: $error';
  }

  @override
  String get verifyEmailTitle => 'Verify your email address';

  @override
  String verifyEmailDescription(String email) {
    return 'We sent a verification message to $email. Open the link in the message and then check the status.';
  }

  @override
  String get checkVerificationStatus => 'Check status';

  @override
  String get checkingVerification => 'Checking…';

  @override
  String get resendVerificationEmail => 'Resend verification email';

  @override
  String get verificationEmailSent => 'The verification email was sent.';

  @override
  String verificationEmailSendError(String error) {
    return 'The verification email could not be sent: $error';
  }

  @override
  String get emailVerificationConfirmed => 'The email address is verified.';

  @override
  String get emailStillNotVerified =>
      'The email address has not been verified yet.';

  @override
  String get continueWithoutVerification =>
      'Continue without verification for now';

  @override
  String get emailVerified => 'Email verified';

  @override
  String get emailNotVerified => 'Email not verified';

  @override
  String get emailVerificationReminder =>
      'The email address has not been verified';

  @override
  String get accountSecurityTitle => 'Account and security';

  @override
  String get accountSecuritySubtitle => 'Email, password and account deletion';

  @override
  String get changePasswordTitle => 'Change password';

  @override
  String get changePasswordSubtitle => 'Set a new sign-in password';

  @override
  String get changePasswordDescription =>
      'For security, enter your current password first and then choose a new one.';

  @override
  String get currentPassword => 'Current password';

  @override
  String get currentPasswordRequired => 'Enter your current password.';

  @override
  String get newPassword => 'New password';

  @override
  String get newPasswordRequired => 'Enter a new password.';

  @override
  String get newPasswordMustDiffer =>
      'The new password must be different from the current one.';

  @override
  String get confirmNewPassword => 'Confirm new password';

  @override
  String get confirmNewPasswordRequired => 'Enter the new password again.';

  @override
  String get changePasswordButton => 'Change password';

  @override
  String get changingPassword => 'Changing…';

  @override
  String get passwordChanged => 'The password was changed successfully.';

  @override
  String passwordChangeError(String error) {
    return 'The password could not be changed: $error';
  }

  @override
  String get deleteAccountTitle => 'Delete account';

  @override
  String get deleteAccountSubtitle =>
      'Permanently remove your profile, collections and favorites';

  @override
  String get deleteAccountWarningTitle => 'This action cannot be undone';

  @override
  String get deleteAccountWarning =>
      'Your profile, inventory, collections, favorites and sign-in account will be deleted.';

  @override
  String get deleteAccountHistoryNotice =>
      'To preserve other participants\' history, completed trades, messages and submitted ratings remain stored without your public profile.';

  @override
  String get deleteAccountConfirmationWord => 'DELETE';

  @override
  String deleteAccountConfirmationLabel(String word) {
    return 'Type $word to confirm';
  }

  @override
  String deleteAccountConfirmationInvalid(String word) {
    return 'Enter $word.';
  }

  @override
  String get deleteAccountButton => 'Permanently delete account';

  @override
  String get deletingAccount => 'Deleting account…';

  @override
  String get deleteAccountConfirmationTitle => 'Delete this account?';

  @override
  String get deleteAccountConfirmationMessage =>
      'The account and your personal profile data will be permanently removed.';

  @override
  String accountDeleteError(String error) {
    return 'The account could not be deleted: $error';
  }

  @override
  String get signOutConfirmationTitle => 'Sign out';

  @override
  String get signOutConfirmationMessage =>
      'Do you want to sign out of this account?';

  @override
  String get authFirebaseRequiresRecentLogin =>
      'For security, sign in again before continuing.';

  @override
  String get authFirebaseUserDisabled => 'This user account has been disabled.';

  @override
  String get authFirebaseOperationNotAllowed =>
      'This sign-in method is currently disabled.';

  @override
  String get accountDeleteActiveTrades =>
      'The account cannot be deleted while you have active or incomplete trades.';

  @override
  String get tradeManualShowAllSurpluses => 'Show all duplicates';

  @override
  String get tradeManualSuggestedSurplusesDescription =>
      'Only duplicates that help complete the other user\'s collection are shown first.';

  @override
  String get tradeManualAllSurplusesDescription =>
      'All available duplicates from both users are shown.';

  @override
  String get tradeManualNoSuggestedOfferedItemsInCollection =>
      'You have no duplicates that would help complete this user\'s collection.';

  @override
  String get tradeManualNoSuggestedRequestedItemsInCollection =>
      'This user has no duplicates that would help complete your collection.';

  @override
  String get tradeRatingTitle => 'Trade rating';

  @override
  String get tradeRatingYourRating => 'Your rating';

  @override
  String get tradeRatingEdit => 'Edit rating';

  @override
  String get tradeRatingCommentHint => 'Short comment (optional)';

  @override
  String get tradeRatingSaveChanges => 'Save changes';

  @override
  String get tradeRatingUpdating => 'Saving changes...';

  @override
  String get tradeRatingUpdatedSuccessfully =>
      'The rating was updated successfully.';

  @override
  String get tradeRatingSelectStars => 'Select from 1 to 5 stars.';

  @override
  String get ratingReviewsTitle => 'Received ratings';

  @override
  String get ratingNoReviews => 'This collector has no ratings yet.';

  @override
  String get safetySettingsTitle => 'Safety and privacy';

  @override
  String get safetyMenu => 'Safety options';

  @override
  String get safetyBlockUser => 'Block user';

  @override
  String get safetyBlockUserTitle => 'Block user';

  @override
  String get safetyBlockUserConfirmation =>
      'This user will not be able to send you messages or new trade offers. You will also be unable to message them or send a new offer.';

  @override
  String get safetyUserBlocked => 'The user has been blocked.';

  @override
  String get safetyUnblockUser => 'Unblock';

  @override
  String get safetyUnblockUserTitle => 'Unblock user';

  @override
  String get safetyUnblockUserConfirmation =>
      'Allow messages and new trade offers with this user again?';

  @override
  String get safetyUserUnblocked => 'The user has been unblocked.';

  @override
  String get safetyReportUser => 'Report user';

  @override
  String get safetyReportTrade => 'Report trade';

  @override
  String get safetyReportMessage => 'Report message';

  @override
  String get safetyReportTitle => 'Submit a report';

  @override
  String get safetyReportDescription =>
      'Choose a reason and optionally add details. Only an administrator can review the report.';

  @override
  String get safetyReportReason => 'Reason';

  @override
  String get safetyReportReasonSpam => 'Spam or unwanted content';

  @override
  String get safetyReportReasonHarassment => 'Harassment or abuse';

  @override
  String get safetyReportReasonFraud => 'Suspected fraud';

  @override
  String get safetyReportReasonInappropriate => 'Inappropriate content';

  @override
  String get safetyReportReasonOther => 'Other';

  @override
  String get safetyReportDetails => 'Details (optional)';

  @override
  String get safetyReportDetailsHint => 'Briefly describe what happened.';

  @override
  String get safetyReportSubmit => 'Submit report';

  @override
  String get safetyReportSubmitting => 'Submitting...';

  @override
  String get safetyReportSubmitted => 'The report was submitted.';

  @override
  String get safetyReportError => 'The report could not be submitted';

  @override
  String get safetyActionError => 'The action could not be completed';

  @override
  String get safetyBlockedUsers => 'Blocked users';

  @override
  String get safetyBlockedUsersDescription => 'Review and unblock users.';

  @override
  String get safetyBlockedUsersLoadError =>
      'Blocked users could not be loaded.';

  @override
  String get safetyNoBlockedUsers => 'You have no blocked users.';

  @override
  String get safetyConversationBlockedByYou =>
      'You blocked this user. The conversation remains visible, but new messages cannot be sent.';

  @override
  String get safetyConversationBlockedByOther =>
      'Sending new messages in this conversation is unavailable.';

  @override
  String get safetyProfileBlockedByYou => 'You blocked this user.';

  @override
  String get safetyProfileBlockedByOther =>
      'Communication with this user is unavailable.';

  @override
  String get safetyAdminReports => 'Review reports';

  @override
  String get safetyAdminReportsDescription =>
      'Administrative review of reported users and content.';

  @override
  String get safetyReportsLoadError => 'Reports could not be loaded.';

  @override
  String get safetyNoReports => 'There are no reports for the selected filter.';

  @override
  String get safetyReportTypeUser => 'User';

  @override
  String get safetyReportTypeMessage => 'Message';

  @override
  String get safetyReportTypeTrade => 'Trade';

  @override
  String get safetyReportStatusOpen => 'Open';

  @override
  String get safetyReportStatusReviewing => 'Reviewing';

  @override
  String get safetyReportStatusResolved => 'Resolved';

  @override
  String get safetyReportStatusDismissed => 'Dismissed';

  @override
  String get safetyReportStatusUpdated => 'The report status was updated.';

  @override
  String get safetyReporterId => 'Reporter';

  @override
  String get safetyReportedUserId => 'Reported user';

  @override
  String get safetyTargetId => 'Reported content';

  @override
  String get safetyConversationId => 'Conversation';

  @override
  String get tradeDeliverySectionTitle => 'Handover and shipping';

  @override
  String get tradeDeliverySectionDescription =>
      'Choose a handover method and share the required private details with your trade partner.';

  @override
  String get tradeDeliveryYourDetails => 'Your details';

  @override
  String get tradeDeliveryPartnerDetails => 'Partner\'s details';

  @override
  String get tradeDeliveryYourDetailsMissing =>
      'You have not added handover or shipping details yet.';

  @override
  String get tradeDeliveryPartnerDetailsMissing =>
      'Your partner has not added handover or shipping details yet.';

  @override
  String get tradeDeliveryAdd => 'Add';

  @override
  String get tradeDeliveryEdit => 'Edit';

  @override
  String get tradeDeliveryFormTitle => 'Handover details';

  @override
  String get tradeDeliveryChooseMethod => 'Handover method';

  @override
  String get tradeDeliveryByMail => 'By mail';

  @override
  String get tradeDeliveryInPerson => 'In person';

  @override
  String get tradeDeliveryFullName => 'Full name';

  @override
  String get tradeDeliveryAddressLine1 => 'Address';

  @override
  String get tradeDeliveryAddressLine2 => 'Additional address line (optional)';

  @override
  String get tradeDeliveryPostalCode => 'Postal code';

  @override
  String get tradeDeliveryCity => 'City';

  @override
  String get tradeDeliveryCountry => 'Country';

  @override
  String get tradeDeliveryPhone => 'Phone number (optional)';

  @override
  String get tradeDeliveryMeetingDetails => 'In-person handover details';

  @override
  String get tradeDeliveryMeetingDetailsHint =>
      'Suggest a place, time, or way to arrange the handover.';

  @override
  String get tradeDeliveryCarrier => 'Delivery company (optional)';

  @override
  String get tradeDeliveryCarrierHint =>
      'For example national post, GLS, or DPD';

  @override
  String get tradeDeliveryTrackingNumber => 'Tracking number (optional)';

  @override
  String get tradeDeliveryNotes => 'Note (optional)';

  @override
  String get tradeDeliveryNotesHint =>
      'Add important instructions for your partner.';

  @override
  String get tradeDeliveryPrivateTitle => 'Private details';

  @override
  String get tradeDeliveryPrivateDescription =>
      'These details are not public. Only the other participant in the accepted trade can see them.';

  @override
  String get tradeDeliveryPrivateShortDescription =>
      'These details are visible only to the two participants in this accepted or completed trade.';

  @override
  String get tradeDeliveryRequiredField => 'This field is required.';

  @override
  String get tradeDeliverySave => 'Save details';

  @override
  String get tradeDeliverySaving => 'Saving...';

  @override
  String get tradeDeliverySaved => 'Handover details were saved.';

  @override
  String tradeDeliverySaveError(String error) {
    return 'The details could not be saved: $error';
  }

  @override
  String get tradeDeliveryLoadError => 'Handover details could not be loaded.';

  @override
  String get tradeDeliveryAddress => 'Shipping address';

  @override
  String get tradeDeliveryTrackingMissing =>
      'A tracking number has not been added yet.';

  @override
  String get tradeDeliveryCopyAddress => 'Copy address';

  @override
  String get tradeDeliveryCopyPhone => 'Copy phone number';

  @override
  String get tradeDeliveryCopyTracking => 'Copy tracking number';

  @override
  String get tradeDeliveryCopied => 'The information was copied.';

  @override
  String get continueLabel => 'Continue';

  @override
  String get done => 'Done';

  @override
  String get betaOnboardingTitle => 'App introduction';

  @override
  String get betaOnboardingSkip => 'Skip';

  @override
  String get betaOnboardingStart => 'Get started';

  @override
  String get betaOnboardingCollectionsTitle => 'Your collections in one place';

  @override
  String get betaOnboardingCollectionsDescription =>
      'Mark the cards you own, the ones you are missing, and your duplicates. Your collection overview updates as you go.';

  @override
  String get betaOnboardingTradesTitle => 'Find meaningful swaps';

  @override
  String get betaOnboardingTradesDescription =>
      'SwapStash compares duplicates and missing cards and suggests collectors with whom a mutually useful swap may be possible.';

  @override
  String get betaOnboardingCompleteTradeTitle => 'Agree, hand over, and rate';

  @override
  String get betaOnboardingCompleteTradeDescription =>
      'Send an offer, chat, privately share handover or shipping details, and rate your partner after the swap is completed.';

  @override
  String get betaOnboardingSafetyTitle => 'Safety and control';

  @override
  String get betaOnboardingSafetyDescription =>
      'Block a user, report inappropriate content, and control which information is public and which is visible only to a trade partner.';

  @override
  String get betaOnboardingShowAgain => 'Show the introduction again';

  @override
  String get betaOnboardingShowAgainDescription =>
      'Review the app\'s main features again.';

  @override
  String get legalAcceptanceTitle => 'Terms and privacy';

  @override
  String get legalAcceptanceHeading => 'Before you continue';

  @override
  String get legalAcceptanceDescription =>
      'Please review the basic usage rules and information about personal data processing.';

  @override
  String get legalAgeConfirmation =>
      'I confirm that I am at least 13 years old. If I am under 15 in Slovenia, I have permission from a parent or guardian.';

  @override
  String get legalDocumentsConfirmation =>
      'I have read and accept the Terms of Use and Privacy Policy.';

  @override
  String get legalAcceptAndContinue => 'Accept and continue';

  @override
  String get legalAcceptanceSaving => 'Saving acceptance...';

  @override
  String get legalBetaNoticeTitle => 'Closed beta version';

  @override
  String get legalBetaNoticeDescription =>
      'The app is still being tested. Features may change and occasional errors or interruptions may occur.';

  @override
  String get legalTermsTitle => 'Terms of Use';

  @override
  String get legalPrivacyTitle => 'Privacy Policy';

  @override
  String get legalEffectiveDate => 'Effective date: 24 July 2026';

  @override
  String get legalContactFooter =>
      'Controller: SwapStash · Contact: uros2004@gmail.com';

  @override
  String get legalTermsIntro =>
      'These terms govern the use of the SwapStash application. By using the app, you agree to them.';

  @override
  String get legalTermsEligibilityTitle => '1. Age and user account';

  @override
  String get legalTermsEligibilityBody =>
      'The app may be used by a person aged at least 13. Where applicable law requires a higher age for independent consent, a minor must obtain permission from a parent or guardian. In Slovenia, a user under 15 needs such permission. Users must provide accurate information, protect their login credentials, and are responsible for activity on their accounts.';

  @override
  String get legalTermsServiceTitle =>
      '2. Purpose of the service and beta version';

  @override
  String get legalTermsServiceBody =>
      'SwapStash enables collection tracking, discovery of possible swaps, offers, messaging, handover arrangements, and ratings after completed swaps. SwapStash is not the seller, buyer, broker, carrier, or party to an agreement between users. During beta, features may change or temporarily be unavailable.';

  @override
  String get legalTermsConductTitle => '3. Permitted use';

  @override
  String get legalTermsConductBody =>
      'Harassment, threats, hate speech, spam, deception, fraud, impersonation, unlawful content, interference with the app, and unauthorized automated use are prohibited. A user must not publish another person\'s information without an appropriate legal basis.';

  @override
  String get legalTermsTradesTitle => '4. Swaps and delivery';

  @override
  String get legalTermsTradesBody =>
      'Users are responsible for checking the condition, authenticity, and value of items and agreeing on handover, costs, and shipment tracking. SwapStash does not guarantee that another user will perform an agreement and does not provide reimbursement for lost, damaged, or disputed shipments. Choose a safe public place for in-person handovers; minors should involve a parent or guardian.';

  @override
  String get legalTermsContentTitle => '5. Messages and user content';

  @override
  String get legalTermsContentBody =>
      'Users remain responsible for content they enter or send. For safety, reports, abuse prevention, or legal compliance, SwapStash may restrict access, remove content, or disclose information to competent authorities where necessary and lawful.';

  @override
  String get legalTermsSuspensionTitle => '6. Blocking and enforcement';

  @override
  String get legalTermsSuspensionBody =>
      'Users may block or report other users. SwapStash may restrict or close an account where there is a reasonable suspicion of a breach of these terms, abuse, a security risk, or unlawful conduct. Where possible, the user will be informed of the reason.';

  @override
  String get legalTermsLiabilityTitle => '7. Availability and liability';

  @override
  String get legalTermsLiabilityBody =>
      'The service is provided on an “as is” basis. SwapStash aims to operate safely and reliably but does not guarantee uninterrupted availability, complete accuracy, or the success of a particular swap. Liability limitations apply only to the extent permitted by law and do not exclude rights that cannot lawfully be limited.';

  @override
  String get legalTermsChangesTitle => '8. Changes, governing law, and contact';

  @override
  String get legalTermsChangesBody =>
      'The terms may be updated due to new features, security requirements, or legislation. The app will request renewed acceptance for material changes. Slovenian law applies, subject to mandatory consumer rights under the law of the user\'s country. Questions may be sent to uros2004@gmail.com.';

  @override
  String get legalPrivacyIntro =>
      'This policy explains which personal data SwapStash processes, why it is used, and the rights available to users.';

  @override
  String get legalPrivacyControllerTitle => '1. Controller and contact';

  @override
  String get legalPrivacyControllerBody =>
      'The personal data controller is SwapStash. Send privacy questions, requests, or objections to uros2004@gmail.com.';

  @override
  String get legalPrivacyDataTitle => '2. Data we process';

  @override
  String get legalPrivacyDataBody =>
      'We process account and sign-in information, email address, display name, country, city, language, profile photo and bio; collection, card, and duplicate data; offers, trade status, ratings, messages, and reports; handover or shipping information voluntarily entered by a user; push-notification tokens; and basic technical and security information required to operate the service.';

  @override
  String get legalPrivacyPurposeTitle => '3. Purposes and legal bases';

  @override
  String get legalPrivacyPurposeBody =>
      'We use data to create and manage accounts, provide collection and trade features, enable communication, deliver notifications, prevent abuse, handle reports, protect security, provide support, and comply with legal obligations. Legal bases include performance of the user agreement, consent, legitimate interests in security and service improvement, and legal obligations.';

  @override
  String get legalPrivacyVisibilityTitle =>
      '4. Visibility and disclosure to other users';

  @override
  String get legalPrivacyVisibilityBody =>
      'A public profile may show the selected name, photo, location, bio, ratings, and trade statistics. Messages are visible to conversation participants. Addresses, phone numbers, in-person handover details, and shipment tracking are visible only to participants in an accepted or completed trade. Reports are visible to the reporter where permitted and to administrators.';

  @override
  String get legalPrivacyRetentionTitle => '5. Retention and deletion';

  @override
  String get legalPrivacyRetentionBody =>
      'We retain data for as long as needed to operate the account, maintain safety, resolve disputes, and meet legal obligations. Users may request account deletion. Some records may be retained for a limited period where necessary to prevent abuse, establish legal claims, or comply with law. Local acceptance of legal documents is stored on the device.';

  @override
  String get legalPrivacyProcessorsTitle =>
      '6. Service providers and transfers';

  @override
  String get legalPrivacyProcessorsBody =>
      'We use Firebase or Google Cloud and other technical providers for hosting, authentication, databases, photo storage, and push notifications. They process data under instructions and contractual obligations. Where processing occurs outside the European Economic Area, appropriate safeguards such as adequacy decisions or standard contractual clauses are used.';

  @override
  String get legalPrivacyRightsTitle => '7. User rights';

  @override
  String get legalPrivacyRightsBody =>
      'Depending on the circumstances, you may request access, correction, deletion, restriction, data portability, or object to processing. Consent may be withdrawn for the future. Send requests to uros2004@gmail.com. You may also complain to the Slovenian Information Commissioner or the competent supervisory authority.';

  @override
  String get legalPrivacyChildrenTitle => '8. Children and young people';

  @override
  String get legalPrivacyChildrenBody =>
      'SwapStash is not intended for children under 13. A user aged 13 or 14 in Slovenia must have permission from a parent or guardian. Parents or guardians may request review or deletion of a minor\'s data. Minors should not publish a home address publicly and should attend in-person handovers with an adult.';

  @override
  String get legalPrivacySecurityTitle => '9. Security and policy changes';

  @override
  String get legalPrivacySecurityBody =>
      'We use technical and organizational measures such as access checks, private subcollections, database security rules, blocking, reports, and secure authentication. No system is completely secure. Material changes to this policy will be announced in the app and may require renewed acceptance.';

  @override
  String get aboutAppTitle => 'About the app';

  @override
  String get aboutAppDescription =>
      'SwapStash helps collectors organize collections, find suitable partners, and complete swaps more safely.';

  @override
  String get aboutVersion => 'App version';

  @override
  String get aboutVersionLoading => 'Loading version...';

  @override
  String get aboutOperator => 'Controller';

  @override
  String get aboutContact => 'Contact and support';

  @override
  String get aboutLegalSection => 'Legal information';

  @override
  String get aboutSendFeedback => 'Send feedback';

  @override
  String get aboutFeedbackEmailSubject => 'SwapStash beta feedback';

  @override
  String get aboutFeedbackOpenError =>
      'The email application could not be opened.';

  @override
  String get aboutBetaFooter =>
      'Closed beta version · data and features may change before public release.';

  @override
  String get settingsAboutAndLegalTitle => 'About and legal information';

  @override
  String get settingsAboutAppSubtitle =>
      'Version, contact, feedback, and documents';
}
