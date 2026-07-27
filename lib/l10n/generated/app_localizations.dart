import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_hr.dart';
import 'app_localizations_sl.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('hr'),
    Locale('sl'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'SwapStash'**
  String get appName;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @collections.
  ///
  /// In en, this message translates to:
  /// **'Collections'**
  String get collections;

  /// No description provided for @trades.
  ///
  /// In en, this message translates to:
  /// **'Trades'**
  String get trades;

  /// No description provided for @messages.
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get messages;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @welcomeUser.
  ///
  /// In en, this message translates to:
  /// **'Welcome, Uroš!'**
  String get welcomeUser;

  /// No description provided for @welcomeDescription.
  ///
  /// In en, this message translates to:
  /// **'Manage your collections and find the best trades.'**
  String get welcomeDescription;

  /// No description provided for @newMatches.
  ///
  /// In en, this message translates to:
  /// **'New matches'**
  String get newMatches;

  /// No description provided for @activeCollections.
  ///
  /// In en, this message translates to:
  /// **'Active collections'**
  String get activeCollections;

  /// No description provided for @addCollection.
  ///
  /// In en, this message translates to:
  /// **'Add collection'**
  String get addCollection;

  /// No description provided for @sameCountry.
  ///
  /// In en, this message translates to:
  /// **'Same country'**
  String get sameCountry;

  /// No description provided for @international.
  ///
  /// In en, this message translates to:
  /// **'International'**
  String get international;

  /// No description provided for @reviewTrade.
  ///
  /// In en, this message translates to:
  /// **'Review trade'**
  String get reviewTrade;

  /// No description provided for @noMessages.
  ///
  /// In en, this message translates to:
  /// **'No messages'**
  String get noMessages;

  /// No description provided for @noMessagesDescription.
  ///
  /// In en, this message translates to:
  /// **'Your trade conversations will appear here.'**
  String get noMessagesDescription;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @internationalTrades.
  ///
  /// In en, this message translates to:
  /// **'International trades'**
  String get internationalTrades;

  /// No description provided for @allowed.
  ///
  /// In en, this message translates to:
  /// **'Allowed'**
  String get allowed;

  /// No description provided for @successfulTrades.
  ///
  /// In en, this message translates to:
  /// **'Successful trades'**
  String get successfulTrades;

  /// No description provided for @chooseLanguage.
  ///
  /// In en, this message translates to:
  /// **'Choose your language'**
  String get chooseLanguage;

  /// No description provided for @chooseLanguageDescription.
  ///
  /// In en, this message translates to:
  /// **'Select the language you want to use in SwapStash. You can change it later in settings.'**
  String get chooseLanguageDescription;

  /// No description provided for @automaticLanguage.
  ///
  /// In en, this message translates to:
  /// **'Automatic – device language'**
  String get automaticLanguage;

  /// No description provided for @automaticLanguageDescription.
  ///
  /// In en, this message translates to:
  /// **'Uses a supported device language automatically.'**
  String get automaticLanguageDescription;

  /// No description provided for @englishFallbackDescription.
  ///
  /// In en, this message translates to:
  /// **'If the device language is not supported, English will be used.'**
  String get englishFallbackDescription;

  /// No description provided for @continueButton.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// No description provided for @saving.
  ///
  /// In en, this message translates to:
  /// **'Saving…'**
  String get saving;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @applicationSettings.
  ///
  /// In en, this message translates to:
  /// **'Application settings'**
  String get applicationSettings;

  /// No description provided for @languageSettingsDescription.
  ///
  /// In en, this message translates to:
  /// **'Choose the application language. The change is applied immediately and saved for future launches.'**
  String get languageSettingsDescription;

  /// No description provided for @languageChanged.
  ///
  /// In en, this message translates to:
  /// **'The language has been changed.'**
  String get languageChanged;

  /// No description provided for @profileLoadError.
  ///
  /// In en, this message translates to:
  /// **'The profile could not be loaded:'**
  String get profileLoadError;

  /// No description provided for @profileMissing.
  ///
  /// In en, this message translates to:
  /// **'The profile does not exist.'**
  String get profileMissing;

  /// No description provided for @unnamedUser.
  ///
  /// In en, this message translates to:
  /// **'Unnamed user'**
  String get unnamedUser;

  /// No description provided for @unknownUser.
  ///
  /// In en, this message translates to:
  /// **'Unknown user'**
  String get unknownUser;

  /// No description provided for @rating.
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get rating;

  /// No description provided for @completedTrades.
  ///
  /// In en, this message translates to:
  /// **'Completed trades'**
  String get completedTrades;

  /// No description provided for @profileVisibility.
  ///
  /// In en, this message translates to:
  /// **'Profile visibility'**
  String get profileVisibility;

  /// No description provided for @publicProfile.
  ///
  /// In en, this message translates to:
  /// **'Public'**
  String get publicProfile;

  /// No description provided for @privateProfile.
  ///
  /// In en, this message translates to:
  /// **'Private'**
  String get privateProfile;

  /// No description provided for @notAllowed.
  ///
  /// In en, this message translates to:
  /// **'Not allowed'**
  String get notAllowed;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit profile'**
  String get editProfile;

  /// No description provided for @editProfileSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Name, city, description and privacy'**
  String get editProfileSubtitle;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOut;

  /// No description provided for @dashboardCatalogTooltip.
  ///
  /// In en, this message translates to:
  /// **'Collection catalog'**
  String get dashboardCatalogTooltip;

  /// No description provided for @dashboardFavoritesTooltip.
  ///
  /// In en, this message translates to:
  /// **'My favorites'**
  String get dashboardFavoritesTooltip;

  /// No description provided for @dashboardLoadError.
  ///
  /// In en, this message translates to:
  /// **'The dashboard could not be loaded'**
  String get dashboardLoadError;

  /// No description provided for @dashboardMyCollections.
  ///
  /// In en, this message translates to:
  /// **'My collections'**
  String get dashboardMyCollections;

  /// No description provided for @dashboardShowAll.
  ///
  /// In en, this message translates to:
  /// **'Show all'**
  String get dashboardShowAll;

  /// No description provided for @dashboardOverview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get dashboardOverview;

  /// No description provided for @dashboardYourCollections.
  ///
  /// In en, this message translates to:
  /// **'Your collections'**
  String get dashboardYourCollections;

  /// No description provided for @dashboardWelcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome!'**
  String get dashboardWelcomeTitle;

  /// No description provided for @dashboardWelcomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'An overview of your collections and activity.'**
  String get dashboardWelcomeSubtitle;

  /// No description provided for @dashboardTodayTasks.
  ///
  /// In en, this message translates to:
  /// **'Your tasks for today'**
  String get dashboardTodayTasks;

  /// No description provided for @dashboardAllDone.
  ///
  /// In en, this message translates to:
  /// **'Everything is up to date'**
  String get dashboardAllDone;

  /// No description provided for @dashboardNoOpenTasks.
  ///
  /// In en, this message translates to:
  /// **'You currently have no open tasks.'**
  String get dashboardNoOpenTasks;

  /// No description provided for @dashboardNoCollectionsTitle.
  ///
  /// In en, this message translates to:
  /// **'You do not have any collections yet'**
  String get dashboardNoCollectionsTitle;

  /// No description provided for @dashboardNoCollectionsDescription.
  ///
  /// In en, this message translates to:
  /// **'Open the Collections tab and add your first collection.'**
  String get dashboardNoCollectionsDescription;

  /// No description provided for @dashboardCollected.
  ///
  /// In en, this message translates to:
  /// **'Collected'**
  String get dashboardCollected;

  /// No description provided for @dashboardDuplicates.
  ///
  /// In en, this message translates to:
  /// **'Duplicates'**
  String get dashboardDuplicates;

  /// No description provided for @dashboardMissing.
  ///
  /// In en, this message translates to:
  /// **'Missing'**
  String get dashboardMissing;

  /// No description provided for @dashboardCollectionOpenError.
  ///
  /// In en, this message translates to:
  /// **'The collection could not be opened.'**
  String get dashboardCollectionOpenError;

  /// No description provided for @dashboardCollectionNotFound.
  ///
  /// In en, this message translates to:
  /// **'The collection could not be found.'**
  String get dashboardCollectionNotFound;

  /// No description provided for @dashboardCollectionOpenErrorDetails.
  ///
  /// In en, this message translates to:
  /// **'The collection could not be opened: {error}'**
  String dashboardCollectionOpenErrorDetails(String error);

  /// No description provided for @dashboardUnreadMessages.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 unread message} other{{count} unread messages}}'**
  String dashboardUnreadMessages(int count);

  /// No description provided for @dashboardOpenConversation.
  ///
  /// In en, this message translates to:
  /// **'Open the conversation and read the new messages.'**
  String get dashboardOpenConversation;

  /// No description provided for @dashboardRespondToCounterOffer.
  ///
  /// In en, this message translates to:
  /// **'Respond to the counteroffer'**
  String get dashboardRespondToCounterOffer;

  /// No description provided for @dashboardRespondToOffer.
  ///
  /// In en, this message translates to:
  /// **'Respond to the offer'**
  String get dashboardRespondToOffer;

  /// No description provided for @dashboardConfirmHandover.
  ///
  /// In en, this message translates to:
  /// **'Confirm card handover'**
  String get dashboardConfirmHandover;

  /// No description provided for @dashboardConfirmReceipt.
  ///
  /// In en, this message translates to:
  /// **'Confirm receipt of cards'**
  String get dashboardConfirmReceipt;

  /// No description provided for @dashboardOpenTrade.
  ///
  /// In en, this message translates to:
  /// **'Open trade'**
  String get dashboardOpenTrade;

  /// No description provided for @dashboardOpenTradeAndContinue.
  ///
  /// In en, this message translates to:
  /// **'Open the trade and continue the process.'**
  String get dashboardOpenTradeAndContinue;

  /// No description provided for @dashboardTradeWithUser.
  ///
  /// In en, this message translates to:
  /// **'Trade with user {userId}'**
  String dashboardTradeWithUser(String userId);

  /// No description provided for @catalogAddToFavorites.
  ///
  /// In en, this message translates to:
  /// **'Add to favorites'**
  String get catalogAddToFavorites;

  /// No description provided for @catalogAddedToFavorites.
  ///
  /// In en, this message translates to:
  /// **'The item was added to favorites.'**
  String get catalogAddedToFavorites;

  /// No description provided for @catalogAdditionalFilterCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} additional filter} other{{count} additional filters}}'**
  String catalogAdditionalFilterCount(int count);

  /// No description provided for @catalogAdditionalFilters.
  ///
  /// In en, this message translates to:
  /// **'Additional filters'**
  String get catalogAdditionalFilters;

  /// No description provided for @catalogAdditionalFiltersCount.
  ///
  /// In en, this message translates to:
  /// **'Additional filters ({count})'**
  String catalogAdditionalFiltersCount(int count);

  /// No description provided for @catalogAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get catalogAll;

  /// No description provided for @catalogAllRarities.
  ///
  /// In en, this message translates to:
  /// **'All rarities'**
  String get catalogAllRarities;

  /// No description provided for @catalogApply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get catalogApply;

  /// No description provided for @catalogAttributeBrand.
  ///
  /// In en, this message translates to:
  /// **'Brand'**
  String get catalogAttributeBrand;

  /// No description provided for @catalogAttributeCharacter.
  ///
  /// In en, this message translates to:
  /// **'Character'**
  String get catalogAttributeCharacter;

  /// No description provided for @catalogAttributeCountry.
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get catalogAttributeCountry;

  /// No description provided for @catalogAttributeDenomination.
  ///
  /// In en, this message translates to:
  /// **'Denomination'**
  String get catalogAttributeDenomination;

  /// No description provided for @catalogAttributeFranchise.
  ///
  /// In en, this message translates to:
  /// **'Franchise'**
  String get catalogAttributeFranchise;

  /// No description provided for @catalogAttributeManufacturer.
  ///
  /// In en, this message translates to:
  /// **'Manufacturer'**
  String get catalogAttributeManufacturer;

  /// No description provided for @catalogAttributeMaterial.
  ///
  /// In en, this message translates to:
  /// **'Material'**
  String get catalogAttributeMaterial;

  /// No description provided for @catalogAttributeSeries.
  ///
  /// In en, this message translates to:
  /// **'Series'**
  String get catalogAttributeSeries;

  /// No description provided for @catalogAttributeSet.
  ///
  /// In en, this message translates to:
  /// **'Set'**
  String get catalogAttributeSet;

  /// No description provided for @catalogAttributeTeam.
  ///
  /// In en, this message translates to:
  /// **'Team'**
  String get catalogAttributeTeam;

  /// No description provided for @catalogAttributeTheme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get catalogAttributeTheme;

  /// No description provided for @catalogAttributeType.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get catalogAttributeType;

  /// No description provided for @catalogAttributeYear.
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get catalogAttributeYear;

  /// No description provided for @catalogCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get catalogCancel;

  /// No description provided for @catalogCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get catalogCategory;

  /// No description provided for @catalogChooseCsvOrXlsx.
  ///
  /// In en, this message translates to:
  /// **'Choose CSV or XLSX'**
  String get catalogChooseCsvOrXlsx;

  /// No description provided for @catalogClear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get catalogClear;

  /// No description provided for @catalogClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get catalogClose;

  /// No description provided for @catalogCollectionAddError.
  ///
  /// In en, this message translates to:
  /// **'The collection could not be added: {error}'**
  String catalogCollectionAddError(String error);

  /// No description provided for @catalogCollectionAdded.
  ///
  /// In en, this message translates to:
  /// **'“{name}” was added to your collections.'**
  String catalogCollectionAdded(String name);

  /// No description provided for @catalogCollectionComplete.
  ///
  /// In en, this message translates to:
  /// **'The collection is complete. No items are missing.'**
  String get catalogCollectionComplete;

  /// No description provided for @catalogCollectionCreateError.
  ///
  /// In en, this message translates to:
  /// **'The collection could not be created: {error}'**
  String catalogCollectionCreateError(String error);

  /// No description provided for @catalogCollectionCreatePermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Firestore rejected collection creation. The signed-in user needs administrator permission.'**
  String get catalogCollectionCreatePermissionDenied;

  /// No description provided for @catalogCollectionCreatedForImport.
  ///
  /// In en, this message translates to:
  /// **'“{name}” was created and selected for import.'**
  String catalogCollectionCreatedForImport(String name);

  /// No description provided for @catalogCollectionId.
  ///
  /// In en, this message translates to:
  /// **'Collection ID'**
  String get catalogCollectionId;

  /// No description provided for @catalogCollectionIdExists.
  ///
  /// In en, this message translates to:
  /// **'A collection with the ID “{id}” already exists.'**
  String catalogCollectionIdExists(String id);

  /// No description provided for @catalogCollectionIdHelp.
  ///
  /// In en, this message translates to:
  /// **'Lowercase letters, numbers and hyphens. Do not change it later.'**
  String get catalogCollectionIdHelp;

  /// No description provided for @catalogCollectionIdInvalid.
  ///
  /// In en, this message translates to:
  /// **'Use only lowercase letters, numbers and hyphens.'**
  String get catalogCollectionIdInvalid;

  /// No description provided for @catalogCollectionName.
  ///
  /// In en, this message translates to:
  /// **'Collection name'**
  String get catalogCollectionName;

  /// No description provided for @catalogCollectionProgress.
  ///
  /// In en, this message translates to:
  /// **'📊 Collection progress'**
  String get catalogCollectionProgress;

  /// No description provided for @catalogCollectionsLoadErrorDetails.
  ///
  /// In en, this message translates to:
  /// **'Collections could not be loaded:\n{error}'**
  String catalogCollectionsLoadErrorDetails(String error);

  /// No description provided for @catalogCollectionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Collection catalog'**
  String get catalogCollectionsTitle;

  /// No description provided for @catalogColumnCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} column} other{{count} columns}}'**
  String catalogColumnCount(int count);

  /// No description provided for @catalogConfirmImport.
  ///
  /// In en, this message translates to:
  /// **'Confirm import'**
  String get catalogConfirmImport;

  /// No description provided for @catalogCreate.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get catalogCreate;

  /// No description provided for @catalogCreateNewCollection.
  ///
  /// In en, this message translates to:
  /// **'Create new collection'**
  String get catalogCreateNewCollection;

  /// No description provided for @catalogCreatingCollection.
  ///
  /// In en, this message translates to:
  /// **'Creating collection ...'**
  String get catalogCreatingCollection;

  /// No description provided for @catalogDecreaseQuantity.
  ///
  /// In en, this message translates to:
  /// **'Decrease quantity'**
  String get catalogDecreaseQuantity;

  /// No description provided for @catalogDisableQuickEntry.
  ///
  /// In en, this message translates to:
  /// **'Disable quick entry'**
  String get catalogDisableQuickEntry;

  /// No description provided for @catalogDuplicates.
  ///
  /// In en, this message translates to:
  /// **'Duplicates'**
  String get catalogDuplicates;

  /// No description provided for @catalogEnableQuickEntry.
  ///
  /// In en, this message translates to:
  /// **'Enable quick entry'**
  String get catalogEnableQuickEntry;

  /// No description provided for @catalogEnterCollectionId.
  ///
  /// In en, this message translates to:
  /// **'Enter the collection ID.'**
  String get catalogEnterCollectionId;

  /// No description provided for @catalogEnterCollectionName.
  ///
  /// In en, this message translates to:
  /// **'Enter the collection name.'**
  String get catalogEnterCollectionName;

  /// No description provided for @catalogFavoriteChangeError.
  ///
  /// In en, this message translates to:
  /// **'The favorite status could not be changed: {error}'**
  String catalogFavoriteChangeError(String error);

  /// No description provided for @catalogFileErrors.
  ///
  /// In en, this message translates to:
  /// **'File errors'**
  String get catalogFileErrors;

  /// No description provided for @catalogFilterByRarity.
  ///
  /// In en, this message translates to:
  /// **'Filter by rarity'**
  String get catalogFilterByRarity;

  /// No description provided for @catalogFindTrades.
  ///
  /// In en, this message translates to:
  /// **'Find trades'**
  String get catalogFindTrades;

  /// No description provided for @catalogFirstRows.
  ///
  /// In en, this message translates to:
  /// **'First {count}'**
  String catalogFirstRows(int count);

  /// No description provided for @catalogImageNotAdded.
  ///
  /// In en, this message translates to:
  /// **'No image has been added yet'**
  String get catalogImageNotAdded;

  /// No description provided for @catalogImportAction.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get catalogImportAction;

  /// No description provided for @catalogImportColumnHelp.
  ///
  /// In en, this message translates to:
  /// **'The required columns are number and name. The rarity and imageUrl columns are optional. All other columns are automatically imported as additional attributes.'**
  String get catalogImportColumnHelp;

  /// No description provided for @catalogImportCompleted.
  ///
  /// In en, this message translates to:
  /// **'Import completed'**
  String get catalogImportCompleted;

  /// No description provided for @catalogImportConfirmRows.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} valid row will be processed} other{{count} valid rows will be processed}} in “{collectionName}”.'**
  String catalogImportConfirmRows(int count, String collectionName);

  /// No description provided for @catalogImportCreated.
  ///
  /// In en, this message translates to:
  /// **'Created: {count}'**
  String catalogImportCreated(int count);

  /// No description provided for @catalogImportCsvAndExcel.
  ///
  /// In en, this message translates to:
  /// **'CSV and Excel'**
  String get catalogImportCsvAndExcel;

  /// No description provided for @catalogImportCsvReadError.
  ///
  /// In en, this message translates to:
  /// **'The CSV file could not be read: {error}'**
  String catalogImportCsvReadError(String error);

  /// No description provided for @catalogImportDescription.
  ///
  /// In en, this message translates to:
  /// **'Import items from a CSV or XLSX file.'**
  String get catalogImportDescription;

  /// No description provided for @catalogImportDuplicateNumber.
  ///
  /// In en, this message translates to:
  /// **'Duplicate number in the same file.'**
  String get catalogImportDuplicateNumber;

  /// No description provided for @catalogImportExcelNoData.
  ///
  /// In en, this message translates to:
  /// **'The Excel file contains no data.'**
  String get catalogImportExcelNoData;

  /// No description provided for @catalogImportExistingSkipped.
  ///
  /// In en, this message translates to:
  /// **'Existing items will be skipped.'**
  String get catalogImportExistingSkipped;

  /// No description provided for @catalogImportExistingUpdated.
  ///
  /// In en, this message translates to:
  /// **'Existing items with the same number will be updated.'**
  String get catalogImportExistingUpdated;

  /// No description provided for @catalogImportFailed.
  ///
  /// In en, this message translates to:
  /// **'Import failed: {error}'**
  String catalogImportFailed(String error);

  /// No description provided for @catalogImportFileNoData.
  ///
  /// In en, this message translates to:
  /// **'The file contains no data.'**
  String get catalogImportFileNoData;

  /// No description provided for @catalogImportFileOpenError.
  ///
  /// In en, this message translates to:
  /// **'The file could not be opened: {error}'**
  String catalogImportFileOpenError(String error);

  /// No description provided for @catalogImportFileTooLarge.
  ///
  /// In en, this message translates to:
  /// **'The file is larger than the allowed 20 MB.'**
  String get catalogImportFileTooLarge;

  /// No description provided for @catalogImportFileTooltip.
  ///
  /// In en, this message translates to:
  /// **'Import CSV or XLSX'**
  String get catalogImportFileTooltip;

  /// No description provided for @catalogImportItems.
  ///
  /// In en, this message translates to:
  /// **'Import {count, plural, one{{count} item} other{{count} items}}'**
  String catalogImportItems(int count);

  /// No description provided for @catalogImportMissingName.
  ///
  /// In en, this message translates to:
  /// **'Name is missing.'**
  String get catalogImportMissingName;

  /// No description provided for @catalogImportMissingNameColumn.
  ///
  /// In en, this message translates to:
  /// **'The required “name” column is missing.'**
  String get catalogImportMissingNameColumn;

  /// No description provided for @catalogImportMissingNumber.
  ///
  /// In en, this message translates to:
  /// **'Number is missing.'**
  String get catalogImportMissingNumber;

  /// No description provided for @catalogImportMissingNumberColumn.
  ///
  /// In en, this message translates to:
  /// **'The required “number” column is missing.'**
  String get catalogImportMissingNumberColumn;

  /// No description provided for @catalogImportNoItemsBelowHeader.
  ///
  /// In en, this message translates to:
  /// **'There are no items below the header row.'**
  String get catalogImportNoItemsBelowHeader;

  /// No description provided for @catalogImportPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Firestore rejected the import. The signed-in user must be an administrator to import into the central catalog.'**
  String get catalogImportPermissionDenied;

  /// No description provided for @catalogImportSkipHelp.
  ///
  /// In en, this message translates to:
  /// **'Items with an existing number will not be changed.'**
  String get catalogImportSkipHelp;

  /// No description provided for @catalogImportSkipped.
  ///
  /// In en, this message translates to:
  /// **'Skipped: {count}'**
  String catalogImportSkipped(int count);

  /// No description provided for @catalogImportSupportedFilesOnly.
  ///
  /// In en, this message translates to:
  /// **'Only CSV and XLSX files are supported.'**
  String get catalogImportSupportedFilesOnly;

  /// No description provided for @catalogImportTitle.
  ///
  /// In en, this message translates to:
  /// **'Catalog import'**
  String get catalogImportTitle;

  /// No description provided for @catalogImportUpdateHelp.
  ///
  /// In en, this message translates to:
  /// **'Items with an existing number will be updated.'**
  String get catalogImportUpdateHelp;

  /// No description provided for @catalogImportUpdated.
  ///
  /// In en, this message translates to:
  /// **'Updated: {count}'**
  String catalogImportUpdated(int count);

  /// No description provided for @catalogImportXlsxReadError.
  ///
  /// In en, this message translates to:
  /// **'The XLSX file could not be read: {error}'**
  String catalogImportXlsxReadError(String error);

  /// No description provided for @catalogImporting.
  ///
  /// In en, this message translates to:
  /// **'Importing ...'**
  String get catalogImporting;

  /// No description provided for @catalogIncreaseQuantity.
  ///
  /// In en, this message translates to:
  /// **'Increase quantity'**
  String get catalogIncreaseQuantity;

  /// No description provided for @catalogInvalidNumber.
  ///
  /// In en, this message translates to:
  /// **'Invalid number.'**
  String get catalogInvalidNumber;

  /// No description provided for @catalogInvalidRows.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} invalid} other{{count} invalid}}'**
  String catalogInvalidRows(int count);

  /// No description provided for @catalogInvalidYear.
  ///
  /// In en, this message translates to:
  /// **'Invalid year.'**
  String get catalogInvalidYear;

  /// No description provided for @catalogInventoryLoadErrorDetails.
  ///
  /// In en, this message translates to:
  /// **'Inventory could not be loaded:\n{error}'**
  String catalogInventoryLoadErrorDetails(String error);

  /// No description provided for @catalogItemCount.
  ///
  /// In en, this message translates to:
  /// **'Number of items'**
  String get catalogItemCount;

  /// No description provided for @catalogItemDefaultName.
  ///
  /// In en, this message translates to:
  /// **'Item {number}'**
  String catalogItemDefaultName(String number);

  /// No description provided for @catalogItemMarkedMissing.
  ///
  /// In en, this message translates to:
  /// **'The item was marked as missing.'**
  String get catalogItemMarkedMissing;

  /// No description provided for @catalogItemMissing.
  ///
  /// In en, this message translates to:
  /// **'Item is missing'**
  String get catalogItemMissing;

  /// No description provided for @catalogItemOwned.
  ///
  /// In en, this message translates to:
  /// **'You own this item'**
  String get catalogItemOwned;

  /// No description provided for @catalogItemStatusLoadErrorDetails.
  ///
  /// In en, this message translates to:
  /// **'The item status could not be loaded:\n{error}'**
  String catalogItemStatusLoadErrorDetails(String error);

  /// No description provided for @catalogItemsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} item} other{{count} items}}'**
  String catalogItemsCount(int count);

  /// No description provided for @catalogItemsLoadErrorDetails.
  ///
  /// In en, this message translates to:
  /// **'Items could not be loaded:\n{error}'**
  String catalogItemsLoadErrorDetails(String error);

  /// No description provided for @catalogLoadErrorDetails.
  ///
  /// In en, this message translates to:
  /// **'The catalog could not be loaded:\n{error}'**
  String catalogLoadErrorDetails(String error);

  /// No description provided for @catalogMissing.
  ///
  /// In en, this message translates to:
  /// **'Missing'**
  String get catalogMissing;

  /// No description provided for @catalogMissingPlural.
  ///
  /// In en, this message translates to:
  /// **'Missing'**
  String get catalogMissingPlural;

  /// No description provided for @catalogNewCollection.
  ///
  /// In en, this message translates to:
  /// **'New collection'**
  String get catalogNewCollection;

  /// No description provided for @catalogNoCollectionsFound.
  ///
  /// In en, this message translates to:
  /// **'No collections found.'**
  String get catalogNoCollectionsFound;

  /// No description provided for @catalogNoDuplicates.
  ///
  /// In en, this message translates to:
  /// **'You do not have any duplicates yet.'**
  String get catalogNoDuplicates;

  /// No description provided for @catalogNoFilterResults.
  ///
  /// In en, this message translates to:
  /// **'No items match the selected filters.'**
  String get catalogNoFilterResults;

  /// No description provided for @catalogNoItems.
  ///
  /// In en, this message translates to:
  /// **'This collection does not contain any items yet.'**
  String get catalogNoItems;

  /// No description provided for @catalogNoOwnedItems.
  ///
  /// In en, this message translates to:
  /// **'You do not own any items yet.'**
  String get catalogNoOwnedItems;

  /// No description provided for @catalogNoSearchResults.
  ///
  /// In en, this message translates to:
  /// **'No results match the search term and selected filters.'**
  String get catalogNoSearchResults;

  /// No description provided for @catalogNotOwned.
  ///
  /// In en, this message translates to:
  /// **'Not owned'**
  String get catalogNotOwned;

  /// No description provided for @catalogOk.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get catalogOk;

  /// No description provided for @catalogOpeningFile.
  ///
  /// In en, this message translates to:
  /// **'Opening file ...'**
  String get catalogOpeningFile;

  /// No description provided for @catalogOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get catalogOther;

  /// No description provided for @catalogOwned.
  ///
  /// In en, this message translates to:
  /// **'Owned'**
  String get catalogOwned;

  /// No description provided for @catalogOwnedSurplusCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{You have no duplicates.} one{You have {count} duplicate.} other{You have {count} duplicates.}}'**
  String catalogOwnedSurplusCount(int count);

  /// No description provided for @catalogPiecesCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} piece} other{{count} pieces}}'**
  String catalogPiecesCount(int count);

  /// No description provided for @catalogPreview.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get catalogPreview;

  /// No description provided for @catalogPublisher.
  ///
  /// In en, this message translates to:
  /// **'Publisher'**
  String get catalogPublisher;

  /// No description provided for @catalogQuantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get catalogQuantity;

  /// No description provided for @catalogQuantitySaveError.
  ///
  /// In en, this message translates to:
  /// **'The quantity could not be saved: {error}'**
  String catalogQuantitySaveError(String error);

  /// No description provided for @catalogQuantityUpdated.
  ///
  /// In en, this message translates to:
  /// **'The quantity was updated to {quantity}.'**
  String catalogQuantityUpdated(int quantity);

  /// No description provided for @catalogRarity.
  ///
  /// In en, this message translates to:
  /// **'Rarity'**
  String get catalogRarity;

  /// No description provided for @catalogRarityAll.
  ///
  /// In en, this message translates to:
  /// **'Rarity: all'**
  String get catalogRarityAll;

  /// No description provided for @catalogRarityCommon.
  ///
  /// In en, this message translates to:
  /// **'Common'**
  String get catalogRarityCommon;

  /// No description provided for @catalogRarityLimitedEdition.
  ///
  /// In en, this message translates to:
  /// **'Limited Edition'**
  String get catalogRarityLimitedEdition;

  /// No description provided for @catalogRarityRare.
  ///
  /// In en, this message translates to:
  /// **'Rare'**
  String get catalogRarityRare;

  /// No description provided for @catalogRaritySelected.
  ///
  /// In en, this message translates to:
  /// **'Rarity: {value}'**
  String catalogRaritySelected(String value);

  /// No description provided for @catalogRarityUltraRare.
  ///
  /// In en, this message translates to:
  /// **'Ultra Rare'**
  String get catalogRarityUltraRare;

  /// No description provided for @catalogRarityValue.
  ///
  /// In en, this message translates to:
  /// **'Rarity: {value}'**
  String catalogRarityValue(String value);

  /// No description provided for @catalogRemoveFromFavorites.
  ///
  /// In en, this message translates to:
  /// **'Remove from favorites'**
  String get catalogRemoveFromFavorites;

  /// No description provided for @catalogRemovedFromFavorites.
  ///
  /// In en, this message translates to:
  /// **'The item was removed from favorites.'**
  String get catalogRemovedFromFavorites;

  /// No description provided for @catalogResultsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} result} other{{count} results}}'**
  String catalogResultsCount(int count);

  /// No description provided for @catalogSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search by number or name ...'**
  String get catalogSearchHint;

  /// No description provided for @catalogSelectTargetCollectionFirst.
  ///
  /// In en, this message translates to:
  /// **'Select the target collection first.'**
  String get catalogSelectTargetCollectionFirst;

  /// No description provided for @catalogSelectValidFileFirst.
  ///
  /// In en, this message translates to:
  /// **'Choose a valid file first.'**
  String get catalogSelectValidFileFirst;

  /// No description provided for @catalogSelectedCollectionMissing.
  ///
  /// In en, this message translates to:
  /// **'The selected collection no longer exists.'**
  String get catalogSelectedCollectionMissing;

  /// No description provided for @catalogSheetName.
  ///
  /// In en, this message translates to:
  /// **'Sheet: {name}'**
  String catalogSheetName(String name);

  /// No description provided for @catalogSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get catalogSkip;

  /// No description provided for @catalogSortItems.
  ///
  /// In en, this message translates to:
  /// **'Sort items'**
  String get catalogSortItems;

  /// No description provided for @catalogSortNameAscending.
  ///
  /// In en, this message translates to:
  /// **'Name: A–Z'**
  String get catalogSortNameAscending;

  /// No description provided for @catalogSortNameDescending.
  ///
  /// In en, this message translates to:
  /// **'Name: Z–A'**
  String get catalogSortNameDescending;

  /// No description provided for @catalogSortNumberAscending.
  ///
  /// In en, this message translates to:
  /// **'Number: ascending'**
  String get catalogSortNumberAscending;

  /// No description provided for @catalogSortNumberDescending.
  ///
  /// In en, this message translates to:
  /// **'Number: descending'**
  String get catalogSortNumberDescending;

  /// No description provided for @catalogSortRarityAscending.
  ///
  /// In en, this message translates to:
  /// **'Rarity: A–Z'**
  String get catalogSortRarityAscending;

  /// No description provided for @catalogSortRarityDescending.
  ///
  /// In en, this message translates to:
  /// **'Rarity: Z–A'**
  String get catalogSortRarityDescending;

  /// No description provided for @catalogSurplusCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{+{count} duplicate} other{+{count} duplicates}}'**
  String catalogSurplusCount(int count);

  /// No description provided for @catalogTargetCollection.
  ///
  /// In en, this message translates to:
  /// **'Target collection'**
  String get catalogTargetCollection;

  /// No description provided for @catalogTotalPieces.
  ///
  /// In en, this message translates to:
  /// **'Total pieces'**
  String get catalogTotalPieces;

  /// No description provided for @catalogUnnamedItem.
  ///
  /// In en, this message translates to:
  /// **'Unnamed item'**
  String get catalogUnnamedItem;

  /// No description provided for @catalogUpdate.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get catalogUpdate;

  /// No description provided for @catalogValidRows.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} valid} other{{count} valid}}'**
  String catalogValidRows(int count);

  /// No description provided for @catalogYear.
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get catalogYear;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @clearSearch.
  ///
  /// In en, this message translates to:
  /// **'Clear search'**
  String get clearSearch;

  /// No description provided for @noResults.
  ///
  /// In en, this message translates to:
  /// **'No results'**
  String get noResults;

  /// No description provided for @now.
  ///
  /// In en, this message translates to:
  /// **'Now'**
  String get now;

  /// No description provided for @sending.
  ///
  /// In en, this message translates to:
  /// **'Sending...'**
  String get sending;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get tryAgain;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @weekdayMondayShort.
  ///
  /// In en, this message translates to:
  /// **'Mon'**
  String get weekdayMondayShort;

  /// No description provided for @weekdayTuesdayShort.
  ///
  /// In en, this message translates to:
  /// **'Tue'**
  String get weekdayTuesdayShort;

  /// No description provided for @weekdayWednesdayShort.
  ///
  /// In en, this message translates to:
  /// **'Wed'**
  String get weekdayWednesdayShort;

  /// No description provided for @weekdayThursdayShort.
  ///
  /// In en, this message translates to:
  /// **'Thu'**
  String get weekdayThursdayShort;

  /// No description provided for @weekdayFridayShort.
  ///
  /// In en, this message translates to:
  /// **'Fri'**
  String get weekdayFridayShort;

  /// No description provided for @weekdaySaturdayShort.
  ///
  /// In en, this message translates to:
  /// **'Sat'**
  String get weekdaySaturdayShort;

  /// No description provided for @weekdaySundayShort.
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get weekdaySundayShort;

  /// No description provided for @messageSendError.
  ///
  /// In en, this message translates to:
  /// **'The message could not be sent:\n{error}'**
  String messageSendError(String error);

  /// No description provided for @messagesSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search by user, collection, or message'**
  String get messagesSearchHint;

  /// No description provided for @messagesConversationEmptyPreview.
  ///
  /// In en, this message translates to:
  /// **'This conversation has no messages yet.'**
  String get messagesConversationEmptyPreview;

  /// No description provided for @messagesYouPreview.
  ///
  /// In en, this message translates to:
  /// **'You: {message}'**
  String messagesYouPreview(String message);

  /// No description provided for @messagesEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'You do not have any conversations yet'**
  String get messagesEmptyTitle;

  /// No description provided for @messagesEmptyDescription.
  ///
  /// In en, this message translates to:
  /// **'You can start a conversation with a user you would like to trade with.'**
  String get messagesEmptyDescription;

  /// No description provided for @messagesTryAnotherSearch.
  ///
  /// In en, this message translates to:
  /// **'Try a different search term.'**
  String get messagesTryAnotherSearch;

  /// No description provided for @messagesNoConversationsForQuery.
  ///
  /// In en, this message translates to:
  /// **'No conversations were found for “{query}”.'**
  String messagesNoConversationsForQuery(String query);

  /// No description provided for @messagesLoadError.
  ///
  /// In en, this message translates to:
  /// **'Conversations could not be loaded'**
  String get messagesLoadError;

  /// No description provided for @messagesSignInRequired.
  ///
  /// In en, this message translates to:
  /// **'You must sign in to view messages.'**
  String get messagesSignInRequired;

  /// No description provided for @messagesGenericUser.
  ///
  /// In en, this message translates to:
  /// **'this user'**
  String get messagesGenericUser;

  /// No description provided for @messagesStartConversationWith.
  ///
  /// In en, this message translates to:
  /// **'Start a conversation with {name}'**
  String messagesStartConversationWith(String name);

  /// No description provided for @messagesConversationAboutCollection.
  ///
  /// In en, this message translates to:
  /// **'This conversation is about the {collectionName} collection.'**
  String messagesConversationAboutCollection(String collectionName);

  /// No description provided for @messagesWriteFirstMessage.
  ///
  /// In en, this message translates to:
  /// **'Write the first message and arrange a trade.'**
  String get messagesWriteFirstMessage;

  /// No description provided for @messagesChatLoadError.
  ///
  /// In en, this message translates to:
  /// **'Messages could not be loaded.'**
  String get messagesChatLoadError;

  /// No description provided for @messagesWriteMessageHint.
  ///
  /// In en, this message translates to:
  /// **'Write a message...'**
  String get messagesWriteMessageHint;

  /// No description provided for @messagesSendMessage.
  ///
  /// In en, this message translates to:
  /// **'Send message'**
  String get messagesSendMessage;

  /// No description provided for @tradeAccept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get tradeAccept;

  /// No description provided for @tradeArchiveEmpty.
  ///
  /// In en, this message translates to:
  /// **'The archive is empty.'**
  String get tradeArchiveEmpty;

  /// No description provided for @tradeAutomaticProposalDescription.
  ///
  /// In en, this message translates to:
  /// **'SwapStash suggests a balanced trade of {offeredCount} for {requestedCount}.'**
  String tradeAutomaticProposalDescription(
    int offeredCount,
    int requestedCount,
  );

  /// No description provided for @tradeAutomaticProposalTitle.
  ///
  /// In en, this message translates to:
  /// **'Automatic trade proposal'**
  String get tradeAutomaticProposalTitle;

  /// No description provided for @tradeBackToResults.
  ///
  /// In en, this message translates to:
  /// **'Back to results'**
  String get tradeBackToResults;

  /// No description provided for @tradeCanOffer.
  ///
  /// In en, this message translates to:
  /// **'You can offer'**
  String get tradeCanOffer;

  /// No description provided for @tradeCanReceive.
  ///
  /// In en, this message translates to:
  /// **'You can receive'**
  String get tradeCanReceive;

  /// No description provided for @tradeCancelOffer.
  ///
  /// In en, this message translates to:
  /// **'Cancel offer'**
  String get tradeCancelOffer;

  /// No description provided for @tradeCardFromCollection.
  ///
  /// In en, this message translates to:
  /// **'Card from the collection'**
  String get tradeCardFromCollection;

  /// No description provided for @tradeCardsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} card} other{{count} cards}}'**
  String tradeCardsCount(int count);

  /// No description provided for @tradeCardsLoadError.
  ///
  /// In en, this message translates to:
  /// **'Cards could not be loaded:\n{error}'**
  String tradeCardsLoadError(String error);

  /// No description provided for @tradeCollectionMissing.
  ///
  /// In en, this message translates to:
  /// **'The trade does not have a collection.'**
  String get tradeCollectionMissing;

  /// No description provided for @tradeCommentHint.
  ///
  /// In en, this message translates to:
  /// **'For example: quick agreement and cards in excellent condition.'**
  String get tradeCommentHint;

  /// No description provided for @tradeComparisonTitle.
  ///
  /// In en, this message translates to:
  /// **'Trade comparison'**
  String get tradeComparisonTitle;

  /// No description provided for @tradeCompletedSteps.
  ///
  /// In en, this message translates to:
  /// **'{completed} of {total} steps'**
  String tradeCompletedSteps(int completed, int total);

  /// No description provided for @tradeConfirmHandoverButton.
  ///
  /// In en, this message translates to:
  /// **'Yes, confirm handover'**
  String get tradeConfirmHandoverButton;

  /// No description provided for @tradeConfirmHandoverDescription.
  ///
  /// In en, this message translates to:
  /// **'Confirm only after you have actually handed the cards to the other party. After confirmation, the cards will be removed from your inventory. This step cannot be undone.'**
  String get tradeConfirmHandoverDescription;

  /// No description provided for @tradeConfirmHandoverTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm card handover'**
  String get tradeConfirmHandoverTitle;

  /// No description provided for @tradeConfirmReceiptButton.
  ///
  /// In en, this message translates to:
  /// **'Yes, confirm receipt'**
  String get tradeConfirmReceiptButton;

  /// No description provided for @tradeConfirmReceiptDescription.
  ///
  /// In en, this message translates to:
  /// **'Confirm only after you have actually received the agreed cards. After confirmation, they will be added to your inventory. This step cannot be undone.'**
  String get tradeConfirmReceiptDescription;

  /// No description provided for @tradeConfirmReceiptTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm receipt of cards'**
  String get tradeConfirmReceiptTitle;

  /// No description provided for @tradeConversationOpenError.
  ///
  /// In en, this message translates to:
  /// **'The conversation could not be opened:\n{error}'**
  String tradeConversationOpenError(String error);

  /// No description provided for @tradeCounterOfferDescription.
  ///
  /// In en, this message translates to:
  /// **'Change the offer. The ratio is unrestricted, so you can change a 3-for-3 proposal to 5-for-3, for example.'**
  String get tradeCounterOfferDescription;

  /// No description provided for @tradeCounterOfferItemsUnavailable.
  ///
  /// In en, this message translates to:
  /// **'The selected cards are no longer available for the counteroffer.'**
  String get tradeCounterOfferItemsUnavailable;

  /// No description provided for @tradeCounterOfferNeedsBothSides.
  ///
  /// In en, this message translates to:
  /// **'A counteroffer must contain at least one item on both sides.'**
  String get tradeCounterOfferNeedsBothSides;

  /// No description provided for @tradeCounterOfferSendError.
  ///
  /// In en, this message translates to:
  /// **'The counteroffer could not be sent: {error}'**
  String tradeCounterOfferSendError(String error);

  /// No description provided for @tradeCounterOfferTitle.
  ///
  /// In en, this message translates to:
  /// **'Counteroffer'**
  String get tradeCounterOfferTitle;

  /// No description provided for @tradeDirectionCounterOffer.
  ///
  /// In en, this message translates to:
  /// **'COUNTEROFFER'**
  String get tradeDirectionCounterOffer;

  /// No description provided for @tradeDirectionReceivedOffer.
  ///
  /// In en, this message translates to:
  /// **'RECEIVED OFFER'**
  String get tradeDirectionReceivedOffer;

  /// No description provided for @tradeDirectionSentOffer.
  ///
  /// In en, this message translates to:
  /// **'SENT OFFER'**
  String get tradeDirectionSentOffer;

  /// No description provided for @tradeFilterCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get tradeFilterCancelled;

  /// No description provided for @tradeFilterCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get tradeFilterCompleted;

  /// No description provided for @tradeFilterRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get tradeFilterRejected;

  /// No description provided for @tradeFindTrades.
  ///
  /// In en, this message translates to:
  /// **'Find trades'**
  String get tradeFindTrades;

  /// No description provided for @tradeFromTask.
  ///
  /// In en, this message translates to:
  /// **'Trade from task'**
  String get tradeFromTask;

  /// No description provided for @tradeHandoverConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Handover confirmed ✓'**
  String get tradeHandoverConfirmed;

  /// No description provided for @tradeHandoverConfirmedSuccess.
  ///
  /// In en, this message translates to:
  /// **'The card handover has been confirmed and the inventory updated.'**
  String get tradeHandoverConfirmedSuccess;

  /// No description provided for @tradeIAmOffering.
  ///
  /// In en, this message translates to:
  /// **'I am offering'**
  String get tradeIAmOffering;

  /// No description provided for @tradeIWant.
  ///
  /// In en, this message translates to:
  /// **'I want'**
  String get tradeIWant;

  /// No description provided for @tradeItemSelectionNextStep.
  ///
  /// In en, this message translates to:
  /// **'Item selection comes in the next step.'**
  String get tradeItemSelectionNextStep;

  /// No description provided for @tradeItemsNextStep.
  ///
  /// In en, this message translates to:
  /// **'The item list comes in the next step.'**
  String get tradeItemsNextStep;

  /// No description provided for @tradeLoadError.
  ///
  /// In en, this message translates to:
  /// **'Trades could not be loaded.'**
  String get tradeLoadError;

  /// No description provided for @tradeLoadErrorDetails.
  ///
  /// In en, this message translates to:
  /// **'Trades could not be loaded:\n{error}'**
  String tradeLoadErrorDetails(String error);

  /// No description provided for @tradeNewTrade.
  ///
  /// In en, this message translates to:
  /// **'New trade'**
  String get tradeNewTrade;

  /// No description provided for @tradeNoAvailableItems.
  ///
  /// In en, this message translates to:
  /// **'No items are available.'**
  String get tradeNoAvailableItems;

  /// No description provided for @tradeNoCancelledTrades.
  ///
  /// In en, this message translates to:
  /// **'There are no cancelled trades.'**
  String get tradeNoCancelledTrades;

  /// No description provided for @tradeNoCards.
  ///
  /// In en, this message translates to:
  /// **'No cards.'**
  String get tradeNoCards;

  /// No description provided for @tradeNoCompletedTrades.
  ///
  /// In en, this message translates to:
  /// **'There are no completed trades.'**
  String get tradeNoCompletedTrades;

  /// No description provided for @tradeNoIncomingTrades.
  ///
  /// In en, this message translates to:
  /// **'There are no received trades.'**
  String get tradeNoIncomingTrades;

  /// No description provided for @tradeNoMatchesFound.
  ///
  /// In en, this message translates to:
  /// **'No possible trades were found at the moment.'**
  String get tradeNoMatchesFound;

  /// No description provided for @tradeNoMatchesHint.
  ///
  /// In en, this message translates to:
  /// **'Check that you have marked your duplicates and that other users use the same collection.'**
  String get tradeNoMatchesHint;

  /// No description provided for @tradeNoOutgoingTrades.
  ///
  /// In en, this message translates to:
  /// **'There are no sent trades.'**
  String get tradeNoOutgoingTrades;

  /// No description provided for @tradeNoRejectedTrades.
  ///
  /// In en, this message translates to:
  /// **'There are no rejected trades.'**
  String get tradeNoRejectedTrades;

  /// No description provided for @tradeNoTradesYet.
  ///
  /// In en, this message translates to:
  /// **'You do not have any trades yet.'**
  String get tradeNoTradesYet;

  /// No description provided for @tradeNoUsersMatch.
  ///
  /// In en, this message translates to:
  /// **'No users match the search.'**
  String get tradeNoUsersMatch;

  /// No description provided for @tradeOfferAcceptedSuccess.
  ///
  /// In en, this message translates to:
  /// **'The trade has been accepted.'**
  String get tradeOfferAcceptedSuccess;

  /// No description provided for @tradeOfferCancelledSuccess.
  ///
  /// In en, this message translates to:
  /// **'The offer has been cancelled.'**
  String get tradeOfferCancelledSuccess;

  /// No description provided for @tradeOfferRejectedSuccess.
  ///
  /// In en, this message translates to:
  /// **'The offer has been rejected.'**
  String get tradeOfferRejectedSuccess;

  /// No description provided for @tradeOpeningConversation.
  ///
  /// In en, this message translates to:
  /// **'Opening conversation...'**
  String get tradeOpeningConversation;

  /// No description provided for @tradeOptionalComment.
  ///
  /// In en, this message translates to:
  /// **'Comment (optional)'**
  String get tradeOptionalComment;

  /// No description provided for @tradePossibleTradesCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} possible trade} other{{count} possible trades}}'**
  String tradePossibleTradesCount(int count);

  /// No description provided for @tradeProgressAgreed.
  ///
  /// In en, this message translates to:
  /// **'Trade agreed'**
  String get tradeProgressAgreed;

  /// No description provided for @tradeProgressIHandedOver.
  ///
  /// In en, this message translates to:
  /// **'I handed over the cards'**
  String get tradeProgressIHandedOver;

  /// No description provided for @tradeProgressIReceived.
  ///
  /// In en, this message translates to:
  /// **'I received the cards'**
  String get tradeProgressIReceived;

  /// No description provided for @tradeProgressOtherHandedOver.
  ///
  /// In en, this message translates to:
  /// **'The other party handed over the cards'**
  String get tradeProgressOtherHandedOver;

  /// No description provided for @tradeProgressOtherReceived.
  ///
  /// In en, this message translates to:
  /// **'The other party received the cards'**
  String get tradeProgressOtherReceived;

  /// No description provided for @tradeProgressTitle.
  ///
  /// In en, this message translates to:
  /// **'Trade progress'**
  String get tradeProgressTitle;

  /// No description provided for @tradeProposalSendError.
  ///
  /// In en, this message translates to:
  /// **'The trade proposal could not be sent:\n{error}'**
  String tradeProposalSendError(String error);

  /// No description provided for @tradeProposalSentSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'The trade proposal was sent successfully.'**
  String get tradeProposalSentSuccessfully;

  /// No description provided for @tradeRateUser.
  ///
  /// In en, this message translates to:
  /// **'Rate user'**
  String get tradeRateUser;

  /// No description provided for @tradeRatingQuestion.
  ///
  /// In en, this message translates to:
  /// **'How satisfied are you with the completed trade?'**
  String get tradeRatingQuestion;

  /// No description provided for @tradeRatingSubmitError.
  ///
  /// In en, this message translates to:
  /// **'The rating could not be submitted: {error}'**
  String tradeRatingSubmitError(String error);

  /// No description provided for @tradeRatingSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Rating submitted.'**
  String get tradeRatingSubmitted;

  /// No description provided for @tradeRatingSubmittedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'The rating was submitted successfully.'**
  String get tradeRatingSubmittedSuccessfully;

  /// No description provided for @tradeRatingUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Rating is currently unavailable. Check whether the new Firestore rules have been deployed.'**
  String get tradeRatingUnavailable;

  /// No description provided for @tradeReceiptConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Receipt confirmed ✓'**
  String get tradeReceiptConfirmed;

  /// No description provided for @tradeReceiptConfirmedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Receipt of the cards has been confirmed and the inventory updated.'**
  String get tradeReceiptConfirmedSuccess;

  /// No description provided for @tradeRecipient.
  ///
  /// In en, this message translates to:
  /// **'Recipient'**
  String get tradeRecipient;

  /// No description provided for @tradeReject.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get tradeReject;

  /// No description provided for @tradeRemoveRecipient.
  ///
  /// In en, this message translates to:
  /// **'Remove recipient'**
  String get tradeRemoveRecipient;

  /// No description provided for @tradeSearchUserHint.
  ///
  /// In en, this message translates to:
  /// **'Search for a user by name...'**
  String get tradeSearchUserHint;

  /// No description provided for @tradeSendCounterOffer.
  ///
  /// In en, this message translates to:
  /// **'Send counteroffer'**
  String get tradeSendCounterOffer;

  /// No description provided for @tradeSendMessageToUser.
  ///
  /// In en, this message translates to:
  /// **'Send a message to {name}'**
  String tradeSendMessageToUser(String name);

  /// No description provided for @tradeSendProposal.
  ///
  /// In en, this message translates to:
  /// **'Send proposal'**
  String get tradeSendProposal;

  /// No description provided for @tradeSendingProposal.
  ///
  /// In en, this message translates to:
  /// **'Sending proposal...'**
  String get tradeSendingProposal;

  /// No description provided for @tradeStarsOutOfFive.
  ///
  /// In en, this message translates to:
  /// **'{value} out of 5'**
  String tradeStarsOutOfFive(int value);

  /// No description provided for @tradeSubmitRating.
  ///
  /// In en, this message translates to:
  /// **'Submit rating'**
  String get tradeSubmitRating;

  /// No description provided for @tradeSubmittingRating.
  ///
  /// In en, this message translates to:
  /// **'Submitting rating...'**
  String get tradeSubmittingRating;

  /// No description provided for @tradeSuggestAutomatically.
  ///
  /// In en, this message translates to:
  /// **'Suggest a trade automatically'**
  String get tradeSuggestAutomatically;

  /// No description provided for @tradeSummaryTitle.
  ///
  /// In en, this message translates to:
  /// **'Trade summary'**
  String get tradeSummaryTitle;

  /// No description provided for @tradeTabAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get tradeTabAll;

  /// No description provided for @tradeTabArchive.
  ///
  /// In en, this message translates to:
  /// **'Archive'**
  String get tradeTabArchive;

  /// No description provided for @tradeTabReceived.
  ///
  /// In en, this message translates to:
  /// **'Received'**
  String get tradeTabReceived;

  /// No description provided for @tradeTabSent.
  ///
  /// In en, this message translates to:
  /// **'Sent'**
  String get tradeTabSent;

  /// No description provided for @tradeTheirDuplicates.
  ///
  /// In en, this message translates to:
  /// **'Their duplicates'**
  String get tradeTheirDuplicates;

  /// No description provided for @tradeTheirDuplicatesYouNeed.
  ///
  /// In en, this message translates to:
  /// **'Their duplicates that you do not have yet.'**
  String get tradeTheirDuplicatesYouNeed;

  /// No description provided for @tradeUserCanOffer.
  ///
  /// In en, this message translates to:
  /// **'{name} can offer'**
  String tradeUserCanOffer(String name);

  /// No description provided for @tradeUserHasNoDuplicatesYouNeed.
  ///
  /// In en, this message translates to:
  /// **'{name} currently has no duplicates that you need.'**
  String tradeUserHasNoDuplicatesYouNeed(String name);

  /// No description provided for @tradeUserNeedsNoneOfYourDuplicates.
  ///
  /// In en, this message translates to:
  /// **'{name} currently does not need any of your duplicates.'**
  String tradeUserNeedsNoneOfYourDuplicates(String name);

  /// No description provided for @tradeUserOffers.
  ///
  /// In en, this message translates to:
  /// **'{name} offers:'**
  String tradeUserOffers(String name);

  /// No description provided for @tradeUserSearchError.
  ///
  /// In en, this message translates to:
  /// **'Users could not be searched:\n{error}'**
  String tradeUserSearchError(String error);

  /// No description provided for @tradeWantedItemsNextStep.
  ///
  /// In en, this message translates to:
  /// **'The wanted-item list comes in the next step.'**
  String get tradeWantedItemsNextStep;

  /// No description provided for @tradeWith.
  ///
  /// In en, this message translates to:
  /// **'Trade with'**
  String get tradeWith;

  /// No description provided for @tradeYouCanOffer.
  ///
  /// In en, this message translates to:
  /// **'You can offer'**
  String get tradeYouCanOffer;

  /// No description provided for @tradeYouGive.
  ///
  /// In en, this message translates to:
  /// **'You give'**
  String get tradeYouGive;

  /// No description provided for @tradeYouOfferColon.
  ///
  /// In en, this message translates to:
  /// **'You offer:'**
  String get tradeYouOfferColon;

  /// No description provided for @tradeYouOfferCount.
  ///
  /// In en, this message translates to:
  /// **'{count} offered'**
  String tradeYouOfferCount(int count);

  /// No description provided for @tradeYouReceive.
  ///
  /// In en, this message translates to:
  /// **'You receive'**
  String get tradeYouReceive;

  /// No description provided for @tradeYouReceiveCount.
  ///
  /// In en, this message translates to:
  /// **'{count} received'**
  String tradeYouReceiveCount(int count);

  /// No description provided for @tradeYourDuplicatesTheyNeed.
  ///
  /// In en, this message translates to:
  /// **'Your duplicates that this user does not have yet.'**
  String get tradeYourDuplicatesTheyNeed;

  /// No description provided for @tradeAllowsInternationalTrades.
  ///
  /// In en, this message translates to:
  /// **'Allows international trades'**
  String get tradeAllowsInternationalTrades;

  /// No description provided for @tradeActionExecutionError.
  ///
  /// In en, this message translates to:
  /// **'The action could not be completed: {error}'**
  String tradeActionExecutionError(String error);

  /// No description provided for @tradeActionCompletedTitle.
  ///
  /// In en, this message translates to:
  /// **'Trade completed'**
  String get tradeActionCompletedTitle;

  /// No description provided for @tradeActionCompletedDescription.
  ///
  /// In en, this message translates to:
  /// **'Both parties confirmed handover and receipt of the cards. The inventories have been updated.'**
  String get tradeActionCompletedDescription;

  /// No description provided for @tradeActionRejectedTitle.
  ///
  /// In en, this message translates to:
  /// **'The offer was rejected'**
  String get tradeActionRejectedTitle;

  /// No description provided for @tradeActionCancelledTitle.
  ///
  /// In en, this message translates to:
  /// **'The offer was cancelled'**
  String get tradeActionCancelledTitle;

  /// No description provided for @tradeActionNoActionRequired.
  ///
  /// In en, this message translates to:
  /// **'No further action is required for this offer.'**
  String get tradeActionNoActionRequired;

  /// No description provided for @tradeActionYourTurnTitle.
  ///
  /// In en, this message translates to:
  /// **'It is your turn'**
  String get tradeActionYourTurnTitle;

  /// No description provided for @tradeActionReviewOfferDescription.
  ///
  /// In en, this message translates to:
  /// **'Review the cards and accept, reject, or send a counteroffer.'**
  String get tradeActionReviewOfferDescription;

  /// No description provided for @tradeActionOtherTurnTitle.
  ///
  /// In en, this message translates to:
  /// **'It is the other party\'s turn'**
  String get tradeActionOtherTurnTitle;

  /// No description provided for @tradeActionWaitingResponseDescription.
  ///
  /// In en, this message translates to:
  /// **'No action is required right now. Waiting for the other user\'s response.'**
  String get tradeActionWaitingResponseDescription;

  /// No description provided for @tradeActionNoActionTitle.
  ///
  /// In en, this message translates to:
  /// **'No action is currently required'**
  String get tradeActionNoActionTitle;

  /// No description provided for @tradeActionStatusNoResponseDescription.
  ///
  /// In en, this message translates to:
  /// **'The trade status does not require your response.'**
  String get tradeActionStatusNoResponseDescription;

  /// No description provided for @tradeActionNextStepTitle.
  ///
  /// In en, this message translates to:
  /// **'Next step'**
  String get tradeActionNextStepTitle;

  /// No description provided for @tradeActionConfirmHandoverDescription.
  ///
  /// In en, this message translates to:
  /// **'After you actually hand your cards to the other party, confirm the handover. They will then be deducted from your inventory.'**
  String get tradeActionConfirmHandoverDescription;

  /// No description provided for @tradeActionConfirmReceiptDescription.
  ///
  /// In en, this message translates to:
  /// **'After you actually receive the agreed cards, confirm receipt. They will then be added to your inventory.'**
  String get tradeActionConfirmReceiptDescription;

  /// No description provided for @tradeActionWaitingOtherHandoverDescription.
  ///
  /// In en, this message translates to:
  /// **'You have already confirmed the handover. Waiting for the other party to hand over their cards.'**
  String get tradeActionWaitingOtherHandoverDescription;

  /// No description provided for @tradeActionWaitingOtherConfirmationTitle.
  ///
  /// In en, this message translates to:
  /// **'Waiting for the other party\'s confirmation'**
  String get tradeActionWaitingOtherConfirmationTitle;

  /// No description provided for @tradeActionWaitingOtherReceiptDescription.
  ///
  /// In en, this message translates to:
  /// **'You have already confirmed receipt. The trade will finish when the other party confirms receipt as well.'**
  String get tradeActionWaitingOtherReceiptDescription;

  /// No description provided for @tradeActionWaitingNextConfirmationDescription.
  ///
  /// In en, this message translates to:
  /// **'Waiting for the other party\'s next confirmation.'**
  String get tradeActionWaitingNextConfirmationDescription;

  /// No description provided for @tradeStatusCompletedTitle.
  ///
  /// In en, this message translates to:
  /// **'Trade completed'**
  String get tradeStatusCompletedTitle;

  /// No description provided for @tradeStatusCompletedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Both users confirmed handover and receipt.'**
  String get tradeStatusCompletedSubtitle;

  /// No description provided for @tradeStatusCompletedBadge.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get tradeStatusCompletedBadge;

  /// No description provided for @tradeStatusRejectedTitle.
  ///
  /// In en, this message translates to:
  /// **'Offer rejected'**
  String get tradeStatusRejectedTitle;

  /// No description provided for @tradeStatusRejectedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'This trade proposal was not accepted.'**
  String get tradeStatusRejectedSubtitle;

  /// No description provided for @tradeStatusRejectedBadge.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get tradeStatusRejectedBadge;

  /// No description provided for @tradeStatusCancelledTitle.
  ///
  /// In en, this message translates to:
  /// **'Offer cancelled'**
  String get tradeStatusCancelledTitle;

  /// No description provided for @tradeStatusCancelledSubtitle.
  ///
  /// In en, this message translates to:
  /// **'The sender cancelled the trade proposal.'**
  String get tradeStatusCancelledSubtitle;

  /// No description provided for @tradeStatusCancelledBadge.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get tradeStatusCancelledBadge;

  /// No description provided for @tradeStatusCounterOfferReceivedTitle.
  ///
  /// In en, this message translates to:
  /// **'You received a counteroffer'**
  String get tradeStatusCounterOfferReceivedTitle;

  /// No description provided for @tradeStatusAwaitingYourResponseTitle.
  ///
  /// In en, this message translates to:
  /// **'The offer is waiting for your response'**
  String get tradeStatusAwaitingYourResponseTitle;

  /// No description provided for @tradeStatusReviewOfferSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Review the cards and select Accept, Reject, or Counteroffer.'**
  String get tradeStatusReviewOfferSubtitle;

  /// No description provided for @tradeStatusWaitingForYouBadge.
  ///
  /// In en, this message translates to:
  /// **'Waiting for you'**
  String get tradeStatusWaitingForYouBadge;

  /// No description provided for @tradeStatusCounterOfferSentTitle.
  ///
  /// In en, this message translates to:
  /// **'Counteroffer sent'**
  String get tradeStatusCounterOfferSentTitle;

  /// No description provided for @tradeStatusOfferSentTitle.
  ///
  /// In en, this message translates to:
  /// **'Offer sent'**
  String get tradeStatusOfferSentTitle;

  /// No description provided for @tradeStatusWaitingOtherUserSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Waiting for the other user\'s response.'**
  String get tradeStatusWaitingOtherUserSubtitle;

  /// No description provided for @tradeStatusWaitingResponseBadge.
  ///
  /// In en, this message translates to:
  /// **'Waiting for response'**
  String get tradeStatusWaitingResponseBadge;

  /// No description provided for @tradeStatusReceivedTitle.
  ///
  /// In en, this message translates to:
  /// **'You received the package'**
  String get tradeStatusReceivedTitle;

  /// No description provided for @tradeStatusReceivedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'The received cards were added to your inventory. Waiting for the other party\'s confirmation.'**
  String get tradeStatusReceivedSubtitle;

  /// No description provided for @tradeStatusReceivedBadge.
  ///
  /// In en, this message translates to:
  /// **'Received'**
  String get tradeStatusReceivedBadge;

  /// No description provided for @tradeStatusBothOnWayTitle.
  ///
  /// In en, this message translates to:
  /// **'Both packages are on the way'**
  String get tradeStatusBothOnWayTitle;

  /// No description provided for @tradeStatusPackageOnWayTitle.
  ///
  /// In en, this message translates to:
  /// **'A package is on its way to you'**
  String get tradeStatusPackageOnWayTitle;

  /// No description provided for @tradeStatusBothOnWaySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Both packages have been handed over. Confirm receipt when your package arrives.'**
  String get tradeStatusBothOnWaySubtitle;

  /// No description provided for @tradeStatusOtherSentSubtitle.
  ///
  /// In en, this message translates to:
  /// **'The other party handed over the package. Your cards are still reserved.'**
  String get tradeStatusOtherSentSubtitle;

  /// No description provided for @tradeStatusOnWayBadge.
  ///
  /// In en, this message translates to:
  /// **'On the way'**
  String get tradeStatusOnWayBadge;

  /// No description provided for @tradeStatusSentTitle.
  ///
  /// In en, this message translates to:
  /// **'You sent the package'**
  String get tradeStatusSentTitle;

  /// No description provided for @tradeStatusSentSubtitle.
  ///
  /// In en, this message translates to:
  /// **'The handed-over cards were removed from your inventory. Waiting for the other party.'**
  String get tradeStatusSentSubtitle;

  /// No description provided for @tradeStatusSentBadge.
  ///
  /// In en, this message translates to:
  /// **'Sent'**
  String get tradeStatusSentBadge;

  /// No description provided for @tradeStatusOtherReceivedTitle.
  ///
  /// In en, this message translates to:
  /// **'The other party received the package'**
  String get tradeStatusOtherReceivedTitle;

  /// No description provided for @tradeStatusConfirmWhenReceivedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm receipt when your package arrives.'**
  String get tradeStatusConfirmWhenReceivedSubtitle;

  /// No description provided for @tradeStatusWaitingReceiptBadge.
  ///
  /// In en, this message translates to:
  /// **'Waiting for receipt'**
  String get tradeStatusWaitingReceiptBadge;

  /// No description provided for @tradeStatusAgreedTitle.
  ///
  /// In en, this message translates to:
  /// **'Trade agreed'**
  String get tradeStatusAgreedTitle;

  /// No description provided for @tradeStatusAgreedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'The cards on both sides are reserved. The inventory changes only after handover or receipt is confirmed.'**
  String get tradeStatusAgreedSubtitle;

  /// No description provided for @tradeStatusAgreedBadge.
  ///
  /// In en, this message translates to:
  /// **'Agreed'**
  String get tradeStatusAgreedBadge;

  /// No description provided for @authLoginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to your account'**
  String get authLoginSubtitle;

  /// No description provided for @authRegisterSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create a new collector account'**
  String get authRegisterSubtitle;

  /// No description provided for @authDisplayNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Display name'**
  String get authDisplayNameLabel;

  /// No description provided for @authDisplayNameHint.
  ///
  /// In en, this message translates to:
  /// **'For example Alex'**
  String get authDisplayNameHint;

  /// No description provided for @authDisplayNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter a display name.'**
  String get authDisplayNameRequired;

  /// No description provided for @authDisplayNameMinLength.
  ///
  /// In en, this message translates to:
  /// **'The name must contain at least 2 characters.'**
  String get authDisplayNameMinLength;

  /// No description provided for @authDisplayNameMaxLength.
  ///
  /// In en, this message translates to:
  /// **'The name can contain no more than 40 characters.'**
  String get authDisplayNameMaxLength;

  /// No description provided for @authEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email address'**
  String get authEmailLabel;

  /// No description provided for @authEmailRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter your email address.'**
  String get authEmailRequired;

  /// No description provided for @authEmailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address.'**
  String get authEmailInvalid;

  /// No description provided for @authPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get authPasswordLabel;

  /// No description provided for @authShowPassword.
  ///
  /// In en, this message translates to:
  /// **'Show password'**
  String get authShowPassword;

  /// No description provided for @authHidePassword.
  ///
  /// In en, this message translates to:
  /// **'Hide password'**
  String get authHidePassword;

  /// No description provided for @authPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter your password.'**
  String get authPasswordRequired;

  /// No description provided for @authPasswordMinLength.
  ///
  /// In en, this message translates to:
  /// **'The password must contain at least 6 characters.'**
  String get authPasswordMinLength;

  /// No description provided for @authConfirmPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get authConfirmPasswordLabel;

  /// No description provided for @authConfirmPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter your password again.'**
  String get authConfirmPasswordRequired;

  /// No description provided for @authPasswordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'The passwords do not match.'**
  String get authPasswordsDoNotMatch;

  /// No description provided for @authLoginButton.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get authLoginButton;

  /// No description provided for @authCreateAccountButton.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get authCreateAccountButton;

  /// No description provided for @authNoAccountRegister.
  ///
  /// In en, this message translates to:
  /// **'Do not have an account? Register'**
  String get authNoAccountRegister;

  /// No description provided for @authHaveAccountLogin.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Sign in'**
  String get authHaveAccountLogin;

  /// No description provided for @authInvalidData.
  ///
  /// In en, this message translates to:
  /// **'The entered data is not valid.'**
  String get authInvalidData;

  /// No description provided for @authUnexpectedError.
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred: {error}'**
  String authUnexpectedError(String error);

  /// No description provided for @authFirebaseInvalidEmail.
  ///
  /// In en, this message translates to:
  /// **'The email address is not valid.'**
  String get authFirebaseInvalidEmail;

  /// No description provided for @authFirebaseEmailAlreadyInUse.
  ///
  /// In en, this message translates to:
  /// **'An account with this email address already exists.'**
  String get authFirebaseEmailAlreadyInUse;

  /// No description provided for @authFirebaseWeakPassword.
  ///
  /// In en, this message translates to:
  /// **'The password is too weak.'**
  String get authFirebaseWeakPassword;

  /// No description provided for @authFirebaseInvalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'The email address or password is incorrect.'**
  String get authFirebaseInvalidCredentials;

  /// No description provided for @authFirebaseTooManyRequests.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Try again later.'**
  String get authFirebaseTooManyRequests;

  /// No description provided for @authFirebaseNetworkError.
  ///
  /// In en, this message translates to:
  /// **'Check your internet connection.'**
  String get authFirebaseNetworkError;

  /// No description provided for @authFirebaseGenericError.
  ///
  /// In en, this message translates to:
  /// **'Sign-in or registration failed.'**
  String get authFirebaseGenericError;

  /// No description provided for @favoritesTitle.
  ///
  /// In en, this message translates to:
  /// **'My favorites'**
  String get favoritesTitle;

  /// No description provided for @favoritesSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search favorites'**
  String get favoritesSearchHint;

  /// No description provided for @favoritesClearSearch.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get favoritesClearSearch;

  /// No description provided for @favoritesRemoved.
  ///
  /// In en, this message translates to:
  /// **'Removed from favorites.'**
  String get favoritesRemoved;

  /// No description provided for @favoritesNamedItemRemoved.
  ///
  /// In en, this message translates to:
  /// **'“{name}” was removed from favorites.'**
  String favoritesNamedItemRemoved(String name);

  /// No description provided for @favoritesRemoveError.
  ///
  /// In en, this message translates to:
  /// **'Could not remove the favorite: {error}'**
  String favoritesRemoveError(String error);

  /// No description provided for @favoritesUnnamedItem.
  ///
  /// In en, this message translates to:
  /// **'Unnamed item'**
  String get favoritesUnnamedItem;

  /// No description provided for @favoritesRemoveTooltip.
  ///
  /// In en, this message translates to:
  /// **'Remove from favorites'**
  String get favoritesRemoveTooltip;

  /// No description provided for @favoritesEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'You do not have any favorites yet'**
  String get favoritesEmptyTitle;

  /// No description provided for @favoritesEmptyDescription.
  ///
  /// In en, this message translates to:
  /// **'Tap the heart on an item’s details page and it will appear here.'**
  String get favoritesEmptyDescription;

  /// No description provided for @favoritesNoResults.
  ///
  /// In en, this message translates to:
  /// **'No results.'**
  String get favoritesNoResults;

  /// No description provided for @favoritesNoResultsForQuery.
  ///
  /// In en, this message translates to:
  /// **'No favorites were found for “{query}”.'**
  String favoritesNoResultsForQuery(String query);

  /// No description provided for @favoritesLoadError.
  ///
  /// In en, this message translates to:
  /// **'Favorites could not be loaded.'**
  String get favoritesLoadError;

  /// No description provided for @myCollectionsTitle.
  ///
  /// In en, this message translates to:
  /// **'My collections'**
  String get myCollectionsTitle;

  /// No description provided for @myCollectionsAddFromCatalog.
  ///
  /// In en, this message translates to:
  /// **'Add a collection from the catalog'**
  String get myCollectionsAddFromCatalog;

  /// No description provided for @myCollectionsAddButton.
  ///
  /// In en, this message translates to:
  /// **'Add collection'**
  String get myCollectionsAddButton;

  /// No description provided for @myCollectionsRemoveTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove collection'**
  String get myCollectionsRemoveTitle;

  /// No description provided for @myCollectionsRemoveQuestion.
  ///
  /// In en, this message translates to:
  /// **'Do you want to remove “{name}” from your collections?'**
  String myCollectionsRemoveQuestion(String name);

  /// No description provided for @myCollectionsRemoveButton.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get myCollectionsRemoveButton;

  /// No description provided for @myCollectionsRemoved.
  ///
  /// In en, this message translates to:
  /// **'“{name}” was removed from your collections.'**
  String myCollectionsRemoved(String name);

  /// No description provided for @myCollectionsRemoveError.
  ///
  /// In en, this message translates to:
  /// **'The collection could not be removed: {error}'**
  String myCollectionsRemoveError(String error);

  /// No description provided for @myCollectionsLoadError.
  ///
  /// In en, this message translates to:
  /// **'Your collections could not be loaded:\n{error}'**
  String myCollectionsLoadError(String error);

  /// No description provided for @myCollectionsCatalogLoadError.
  ///
  /// In en, this message translates to:
  /// **'The collection could not be loaded.'**
  String get myCollectionsCatalogLoadError;

  /// No description provided for @myCollectionsCatalogMissing.
  ///
  /// In en, this message translates to:
  /// **'The catalog collection does not exist.'**
  String get myCollectionsCatalogMissing;

  /// No description provided for @myCollectionsStatisticsLoadError.
  ///
  /// In en, this message translates to:
  /// **'Collection statistics could not be loaded.'**
  String get myCollectionsStatisticsLoadError;

  /// No description provided for @myCollectionsStatisticsUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Collection statistics are unavailable.'**
  String get myCollectionsStatisticsUnavailable;

  /// No description provided for @myCollectionsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'You have not added any collections yet.'**
  String get myCollectionsEmptyTitle;

  /// No description provided for @myCollectionsEmptyDescription.
  ///
  /// In en, this message translates to:
  /// **'Choose a collection from the central catalog.'**
  String get myCollectionsEmptyDescription;

  /// No description provided for @myCollectionsOpenCatalog.
  ///
  /// In en, this message translates to:
  /// **'Open catalog'**
  String get myCollectionsOpenCatalog;

  /// No description provided for @myCollectionsUnnamedCollection.
  ///
  /// In en, this message translates to:
  /// **'Unnamed collection'**
  String get myCollectionsUnnamedCollection;

  /// No description provided for @myCollectionsMenuTooltip.
  ///
  /// In en, this message translates to:
  /// **'Collection options'**
  String get myCollectionsMenuTooltip;

  /// No description provided for @myCollectionsEditMenu.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get myCollectionsEditMenu;

  /// No description provided for @myCollectionsRemoveMenu.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get myCollectionsRemoveMenu;

  /// No description provided for @myCollectionsProgressCount.
  ///
  /// In en, this message translates to:
  /// **'Collected: {owned} / {total}'**
  String myCollectionsProgressCount(int owned, int total);

  /// No description provided for @myCollectionsDuplicateCount.
  ///
  /// In en, this message translates to:
  /// **'Duplicates: {count}'**
  String myCollectionsDuplicateCount(int count);

  /// No description provided for @myCollectionsMissingCount.
  ///
  /// In en, this message translates to:
  /// **'Missing: {count}'**
  String myCollectionsMissingCount(int count);

  /// No description provided for @collectors.
  ///
  /// In en, this message translates to:
  /// **'Collectors'**
  String get collectors;

  /// No description provided for @editProfileDisplayName.
  ///
  /// In en, this message translates to:
  /// **'Display name'**
  String get editProfileDisplayName;

  /// No description provided for @editProfileCity.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get editProfileCity;

  /// No description provided for @editProfileBio.
  ///
  /// In en, this message translates to:
  /// **'About me'**
  String get editProfileBio;

  /// No description provided for @editProfilePublicTitle.
  ///
  /// In en, this message translates to:
  /// **'Public profile'**
  String get editProfilePublicTitle;

  /// No description provided for @editProfilePublicSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Other users can find you.'**
  String get editProfilePublicSubtitle;

  /// No description provided for @editProfileInternationalTitle.
  ///
  /// In en, this message translates to:
  /// **'Allow international trades'**
  String get editProfileInternationalTitle;

  /// No description provided for @editProfileInternationalSubtitle.
  ///
  /// In en, this message translates to:
  /// **'You can receive offers from other countries.'**
  String get editProfileInternationalSubtitle;

  /// No description provided for @editProfileSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get editProfileSave;

  /// No description provided for @editProfileSaving.
  ///
  /// In en, this message translates to:
  /// **'Saving…'**
  String get editProfileSaving;

  /// No description provided for @editProfileSaved.
  ///
  /// In en, this message translates to:
  /// **'The profile was saved successfully.'**
  String get editProfileSaved;

  /// No description provided for @editProfileSaveError.
  ///
  /// In en, this message translates to:
  /// **'The profile could not be saved: {error}'**
  String editProfileSaveError(String error);

  /// No description provided for @editProfileLoadError.
  ///
  /// In en, this message translates to:
  /// **'The profile could not be loaded:\n{error}'**
  String editProfileLoadError(String error);

  /// No description provided for @editProfileMissing.
  ///
  /// In en, this message translates to:
  /// **'The profile does not exist.'**
  String get editProfileMissing;

  /// No description provided for @editProfileDisplayNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter a display name.'**
  String get editProfileDisplayNameRequired;

  /// No description provided for @collectorsSearchLabel.
  ///
  /// In en, this message translates to:
  /// **'Search collectors'**
  String get collectorsSearchLabel;

  /// No description provided for @collectorsSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Enter a display name'**
  String get collectorsSearchHint;

  /// No description provided for @collectorsSearchError.
  ///
  /// In en, this message translates to:
  /// **'Users could not be searched:\n{error}'**
  String collectorsSearchError(String error);

  /// No description provided for @collectorsNoResults.
  ///
  /// In en, this message translates to:
  /// **'No collectors were found.'**
  String get collectorsNoResults;

  /// No description provided for @collectorsSearchDescription.
  ///
  /// In en, this message translates to:
  /// **'Find other collectors by display name.'**
  String get collectorsSearchDescription;

  /// No description provided for @collectorsInternationalAllowed.
  ///
  /// In en, this message translates to:
  /// **'International trades allowed'**
  String get collectorsInternationalAllowed;

  /// No description provided for @collectorsLocalOnly.
  ///
  /// In en, this message translates to:
  /// **'Local trades only'**
  String get collectorsLocalOnly;

  /// No description provided for @collectorProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'Collector profile'**
  String get collectorProfileTitle;

  /// No description provided for @collectorProfileMissing.
  ///
  /// In en, this message translates to:
  /// **'The user profile does not exist.'**
  String get collectorProfileMissing;

  /// No description provided for @collectorChatOpenError.
  ///
  /// In en, this message translates to:
  /// **'The conversation could not be opened:\n{error}'**
  String collectorChatOpenError(String error);

  /// No description provided for @collectorOpeningChat.
  ///
  /// In en, this message translates to:
  /// **'Opening conversation…'**
  String get collectorOpeningChat;

  /// No description provided for @collectorSendMessage.
  ///
  /// In en, this message translates to:
  /// **'Send message'**
  String get collectorSendMessage;

  /// No description provided for @collectorInternationalTrades.
  ///
  /// In en, this message translates to:
  /// **'International trades'**
  String get collectorInternationalTrades;

  /// No description provided for @collectorLocalTrades.
  ///
  /// In en, this message translates to:
  /// **'Local trades'**
  String get collectorLocalTrades;

  /// No description provided for @collectorAbout.
  ///
  /// In en, this message translates to:
  /// **'About the collector'**
  String get collectorAbout;

  /// No description provided for @collectorPrivateTitle.
  ///
  /// In en, this message translates to:
  /// **'This profile is private'**
  String get collectorPrivateTitle;

  /// No description provided for @collectorPrivateDescription.
  ///
  /// In en, this message translates to:
  /// **'The location, description and rating comments are not shown publicly.'**
  String get collectorPrivateDescription;

  /// No description provided for @collectorProfileLoadError.
  ///
  /// In en, this message translates to:
  /// **'The profile could not be loaded:\n{error}'**
  String collectorProfileLoadError(String error);

  /// No description provided for @ratingUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Rating unavailable'**
  String get ratingUnavailable;

  /// No description provided for @ratingLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading ratings'**
  String get ratingLoading;

  /// No description provided for @ratingNone.
  ///
  /// In en, this message translates to:
  /// **'No ratings'**
  String get ratingNone;

  /// No description provided for @ratingCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 rating} other{{count} ratings}}'**
  String ratingCount(int count);

  /// No description provided for @ratingCommentsLoadError.
  ///
  /// In en, this message translates to:
  /// **'Rating comments could not be loaded.'**
  String get ratingCommentsLoadError;

  /// No description provided for @ratingNoPublicComments.
  ///
  /// In en, this message translates to:
  /// **'This collector has no public comments yet.'**
  String get ratingNoPublicComments;

  /// No description provided for @ratingRecentComments.
  ///
  /// In en, this message translates to:
  /// **'Recent comments'**
  String get ratingRecentComments;

  /// No description provided for @catalogCategorySportsCards.
  ///
  /// In en, this message translates to:
  /// **'Sports cards'**
  String get catalogCategorySportsCards;

  /// No description provided for @collectorsNavigation.
  ///
  /// In en, this message translates to:
  /// **'Collectors'**
  String get collectorsNavigation;

  /// No description provided for @tradeManualStepRecipient.
  ///
  /// In en, this message translates to:
  /// **'Recipient'**
  String get tradeManualStepRecipient;

  /// No description provided for @tradeManualStepItems.
  ///
  /// In en, this message translates to:
  /// **'Cards'**
  String get tradeManualStepItems;

  /// No description provided for @tradeManualStepSummary.
  ///
  /// In en, this message translates to:
  /// **'Summary'**
  String get tradeManualStepSummary;

  /// No description provided for @tradeManualChooseRecipientDescription.
  ///
  /// In en, this message translates to:
  /// **'Find the collector you want to send a trade offer to.'**
  String get tradeManualChooseRecipientDescription;

  /// No description provided for @tradeManualChangeRecipient.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get tradeManualChangeRecipient;

  /// No description provided for @tradeManualLoadingOptions.
  ///
  /// In en, this message translates to:
  /// **'Checking shared collections and available cards…'**
  String get tradeManualLoadingOptions;

  /// No description provided for @tradeManualOptionsError.
  ///
  /// In en, this message translates to:
  /// **'Trade cards could not be loaded: {error}'**
  String tradeManualOptionsError(String error);

  /// No description provided for @tradeManualNoCommonCollections.
  ///
  /// In en, this message translates to:
  /// **'No shared collection'**
  String get tradeManualNoCommonCollections;

  /// No description provided for @tradeManualNoCommonCollectionsDescription.
  ///
  /// In en, this message translates to:
  /// **'Both users must have at least one of the same collections to create a manual trade.'**
  String get tradeManualNoCommonCollectionsDescription;

  /// No description provided for @tradeManualNoAvailableItems.
  ///
  /// In en, this message translates to:
  /// **'No cards are currently available'**
  String get tradeManualNoAvailableItems;

  /// No description provided for @tradeManualNeedsBothDirections.
  ///
  /// In en, this message translates to:
  /// **'Each user must have at least one available duplicate for an offer.'**
  String get tradeManualNeedsBothDirections;

  /// No description provided for @tradeManualChooseCollection.
  ///
  /// In en, this message translates to:
  /// **'Collection'**
  String get tradeManualChooseCollection;

  /// No description provided for @tradeManualSelectionsRemainAcrossCollections.
  ///
  /// In en, this message translates to:
  /// **'One offer can contain cards from only one collection. Switching collections clears the selection.'**
  String get tradeManualSelectionsRemainAcrossCollections;

  /// No description provided for @tradeManualNoOfferedItemsInCollection.
  ///
  /// In en, this message translates to:
  /// **'You have no available duplicates in this collection.'**
  String get tradeManualNoOfferedItemsInCollection;

  /// No description provided for @tradeManualNoRequestedItemsInCollection.
  ///
  /// In en, this message translates to:
  /// **'The other user has no available duplicates in this collection.'**
  String get tradeManualNoRequestedItemsInCollection;

  /// No description provided for @tradeManualSelectedItems.
  ///
  /// In en, this message translates to:
  /// **'Selected: {count}'**
  String tradeManualSelectedItems(int count);

  /// No description provided for @tradeManualAvailableQuantity.
  ///
  /// In en, this message translates to:
  /// **'Available to trade: {count}'**
  String tradeManualAvailableQuantity(int count);

  /// No description provided for @tradeManualChooseAtLeastOneEach.
  ///
  /// In en, this message translates to:
  /// **'Select at least one card on each side of the trade.'**
  String get tradeManualChooseAtLeastOneEach;

  /// No description provided for @tradeManualReviewOffer.
  ///
  /// In en, this message translates to:
  /// **'Review offer'**
  String get tradeManualReviewOffer;

  /// No description provided for @tradeManualSummaryRecipient.
  ///
  /// In en, this message translates to:
  /// **'Recipient'**
  String get tradeManualSummaryRecipient;

  /// No description provided for @tradeManualSummaryOffering.
  ///
  /// In en, this message translates to:
  /// **'I offer'**
  String get tradeManualSummaryOffering;

  /// No description provided for @tradeManualSummaryRequesting.
  ///
  /// In en, this message translates to:
  /// **'I request'**
  String get tradeManualSummaryRequesting;

  /// No description provided for @tradeManualSendOffer.
  ///
  /// In en, this message translates to:
  /// **'Send offer'**
  String get tradeManualSendOffer;

  /// No description provided for @tradeManualSendingOffer.
  ///
  /// In en, this message translates to:
  /// **'Sending offer…'**
  String get tradeManualSendingOffer;

  /// No description provided for @tradeManualOfferCreated.
  ///
  /// In en, this message translates to:
  /// **'The trade offer was sent.'**
  String get tradeManualOfferCreated;

  /// No description provided for @tradeManualOfferError.
  ///
  /// In en, this message translates to:
  /// **'The offer could not be sent: {error}'**
  String tradeManualOfferError(String error);

  /// No description provided for @tradeManualYourInventoryUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Card #{itemNumber} is no longer available among your duplicates.'**
  String tradeManualYourInventoryUnavailable(String itemNumber);

  /// No description provided for @tradeManualTheirInventoryUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Card #{itemNumber} is no longer available from the other user.'**
  String tradeManualTheirInventoryUnavailable(String itemNumber);

  /// No description provided for @tradeManualCatalogItemUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Card #{itemNumber} could not be matched to the catalog.'**
  String tradeManualCatalogItemUnavailable(String itemNumber);

  /// No description provided for @tradeManualInvalidOffer.
  ///
  /// In en, this message translates to:
  /// **'The offer is not valid. Check the selected cards and quantities.'**
  String get tradeManualInvalidOffer;

  /// No description provided for @tradeManualBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get tradeManualBack;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPassword;

  /// No description provided for @forgotPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset password'**
  String get forgotPasswordTitle;

  /// No description provided for @forgotPasswordDescription.
  ///
  /// In en, this message translates to:
  /// **'Enter the email address for your account. We will send you a link to set a new password.'**
  String get forgotPasswordDescription;

  /// No description provided for @sendPasswordResetEmail.
  ///
  /// In en, this message translates to:
  /// **'Send reset link'**
  String get sendPasswordResetEmail;

  /// No description provided for @sendingEmail.
  ///
  /// In en, this message translates to:
  /// **'Sending…'**
  String get sendingEmail;

  /// No description provided for @passwordResetEmailSentTitle.
  ///
  /// In en, this message translates to:
  /// **'Check your email'**
  String get passwordResetEmailSentTitle;

  /// No description provided for @passwordResetEmailSentDescription.
  ///
  /// In en, this message translates to:
  /// **'If an account with this email address exists, you will receive a password reset link.'**
  String get passwordResetEmailSentDescription;

  /// No description provided for @backToSignIn.
  ///
  /// In en, this message translates to:
  /// **'Back to sign in'**
  String get backToSignIn;

  /// No description provided for @passwordResetError.
  ///
  /// In en, this message translates to:
  /// **'The password reset link could not be sent: {error}'**
  String passwordResetError(String error);

  /// No description provided for @verifyEmailTitle.
  ///
  /// In en, this message translates to:
  /// **'Verify your email address'**
  String get verifyEmailTitle;

  /// No description provided for @verifyEmailDescription.
  ///
  /// In en, this message translates to:
  /// **'We sent a verification message to {email}. Open the link in the message and then check the status.'**
  String verifyEmailDescription(String email);

  /// No description provided for @checkVerificationStatus.
  ///
  /// In en, this message translates to:
  /// **'Check status'**
  String get checkVerificationStatus;

  /// No description provided for @checkingVerification.
  ///
  /// In en, this message translates to:
  /// **'Checking…'**
  String get checkingVerification;

  /// No description provided for @resendVerificationEmail.
  ///
  /// In en, this message translates to:
  /// **'Resend verification email'**
  String get resendVerificationEmail;

  /// No description provided for @verificationEmailSent.
  ///
  /// In en, this message translates to:
  /// **'The verification email was sent.'**
  String get verificationEmailSent;

  /// No description provided for @verificationEmailSendError.
  ///
  /// In en, this message translates to:
  /// **'The verification email could not be sent: {error}'**
  String verificationEmailSendError(String error);

  /// No description provided for @emailVerificationConfirmed.
  ///
  /// In en, this message translates to:
  /// **'The email address is verified.'**
  String get emailVerificationConfirmed;

  /// No description provided for @emailStillNotVerified.
  ///
  /// In en, this message translates to:
  /// **'The email address has not been verified yet.'**
  String get emailStillNotVerified;

  /// No description provided for @continueWithoutVerification.
  ///
  /// In en, this message translates to:
  /// **'Continue without verification for now'**
  String get continueWithoutVerification;

  /// No description provided for @emailVerified.
  ///
  /// In en, this message translates to:
  /// **'Email verified'**
  String get emailVerified;

  /// No description provided for @emailNotVerified.
  ///
  /// In en, this message translates to:
  /// **'Email not verified'**
  String get emailNotVerified;

  /// No description provided for @emailVerificationReminder.
  ///
  /// In en, this message translates to:
  /// **'The email address has not been verified'**
  String get emailVerificationReminder;

  /// No description provided for @accountSecurityTitle.
  ///
  /// In en, this message translates to:
  /// **'Account and security'**
  String get accountSecurityTitle;

  /// No description provided for @accountSecuritySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Email, password and account deletion'**
  String get accountSecuritySubtitle;

  /// No description provided for @changePasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Change password'**
  String get changePasswordTitle;

  /// No description provided for @changePasswordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Set a new sign-in password'**
  String get changePasswordSubtitle;

  /// No description provided for @changePasswordDescription.
  ///
  /// In en, this message translates to:
  /// **'For security, enter your current password first and then choose a new one.'**
  String get changePasswordDescription;

  /// No description provided for @currentPassword.
  ///
  /// In en, this message translates to:
  /// **'Current password'**
  String get currentPassword;

  /// No description provided for @currentPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter your current password.'**
  String get currentPasswordRequired;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get newPassword;

  /// No description provided for @newPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter a new password.'**
  String get newPasswordRequired;

  /// No description provided for @newPasswordMustDiffer.
  ///
  /// In en, this message translates to:
  /// **'The new password must be different from the current one.'**
  String get newPasswordMustDiffer;

  /// No description provided for @confirmNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm new password'**
  String get confirmNewPassword;

  /// No description provided for @confirmNewPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter the new password again.'**
  String get confirmNewPasswordRequired;

  /// No description provided for @changePasswordButton.
  ///
  /// In en, this message translates to:
  /// **'Change password'**
  String get changePasswordButton;

  /// No description provided for @changingPassword.
  ///
  /// In en, this message translates to:
  /// **'Changing…'**
  String get changingPassword;

  /// No description provided for @passwordChanged.
  ///
  /// In en, this message translates to:
  /// **'The password was changed successfully.'**
  String get passwordChanged;

  /// No description provided for @passwordChangeError.
  ///
  /// In en, this message translates to:
  /// **'The password could not be changed: {error}'**
  String passwordChangeError(String error);

  /// No description provided for @deleteAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get deleteAccountTitle;

  /// No description provided for @deleteAccountSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Permanently remove your profile, collections and favorites'**
  String get deleteAccountSubtitle;

  /// No description provided for @deleteAccountWarningTitle.
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone'**
  String get deleteAccountWarningTitle;

  /// No description provided for @deleteAccountWarning.
  ///
  /// In en, this message translates to:
  /// **'Your profile, inventory, collections, favorites and sign-in account will be deleted.'**
  String get deleteAccountWarning;

  /// No description provided for @deleteAccountHistoryNotice.
  ///
  /// In en, this message translates to:
  /// **'To preserve other participants\' history, completed trades, messages and submitted ratings remain stored without your public profile.'**
  String get deleteAccountHistoryNotice;

  /// No description provided for @deleteAccountConfirmationWord.
  ///
  /// In en, this message translates to:
  /// **'DELETE'**
  String get deleteAccountConfirmationWord;

  /// No description provided for @deleteAccountConfirmationLabel.
  ///
  /// In en, this message translates to:
  /// **'Type {word} to confirm'**
  String deleteAccountConfirmationLabel(String word);

  /// No description provided for @deleteAccountConfirmationInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter {word}.'**
  String deleteAccountConfirmationInvalid(String word);

  /// No description provided for @deleteAccountButton.
  ///
  /// In en, this message translates to:
  /// **'Permanently delete account'**
  String get deleteAccountButton;

  /// No description provided for @deletingAccount.
  ///
  /// In en, this message translates to:
  /// **'Deleting account…'**
  String get deletingAccount;

  /// No description provided for @deleteAccountConfirmationTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this account?'**
  String get deleteAccountConfirmationTitle;

  /// No description provided for @deleteAccountConfirmationMessage.
  ///
  /// In en, this message translates to:
  /// **'The account and your personal profile data will be permanently removed.'**
  String get deleteAccountConfirmationMessage;

  /// No description provided for @accountDeleteError.
  ///
  /// In en, this message translates to:
  /// **'The account could not be deleted: {error}'**
  String accountDeleteError(String error);

  /// No description provided for @signOutConfirmationTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOutConfirmationTitle;

  /// No description provided for @signOutConfirmationMessage.
  ///
  /// In en, this message translates to:
  /// **'Do you want to sign out of this account?'**
  String get signOutConfirmationMessage;

  /// No description provided for @authFirebaseRequiresRecentLogin.
  ///
  /// In en, this message translates to:
  /// **'For security, sign in again before continuing.'**
  String get authFirebaseRequiresRecentLogin;

  /// No description provided for @authFirebaseUserDisabled.
  ///
  /// In en, this message translates to:
  /// **'This user account has been disabled.'**
  String get authFirebaseUserDisabled;

  /// No description provided for @authFirebaseOperationNotAllowed.
  ///
  /// In en, this message translates to:
  /// **'This sign-in method is currently disabled.'**
  String get authFirebaseOperationNotAllowed;

  /// No description provided for @accountDeleteActiveTrades.
  ///
  /// In en, this message translates to:
  /// **'The account cannot be deleted while you have active or incomplete trades.'**
  String get accountDeleteActiveTrades;

  /// No description provided for @tradeManualShowAllSurpluses.
  ///
  /// In en, this message translates to:
  /// **'Show all duplicates'**
  String get tradeManualShowAllSurpluses;

  /// No description provided for @tradeManualSuggestedSurplusesDescription.
  ///
  /// In en, this message translates to:
  /// **'Only duplicates that help complete the other user\'s collection are shown first.'**
  String get tradeManualSuggestedSurplusesDescription;

  /// No description provided for @tradeManualAllSurplusesDescription.
  ///
  /// In en, this message translates to:
  /// **'All available duplicates from both users are shown.'**
  String get tradeManualAllSurplusesDescription;

  /// No description provided for @tradeManualNoSuggestedOfferedItemsInCollection.
  ///
  /// In en, this message translates to:
  /// **'You have no duplicates that would help complete this user\'s collection.'**
  String get tradeManualNoSuggestedOfferedItemsInCollection;

  /// No description provided for @tradeManualNoSuggestedRequestedItemsInCollection.
  ///
  /// In en, this message translates to:
  /// **'This user has no duplicates that would help complete your collection.'**
  String get tradeManualNoSuggestedRequestedItemsInCollection;

  /// No description provided for @tradeRatingTitle.
  ///
  /// In en, this message translates to:
  /// **'Trade rating'**
  String get tradeRatingTitle;

  /// No description provided for @tradeRatingYourRating.
  ///
  /// In en, this message translates to:
  /// **'Your rating'**
  String get tradeRatingYourRating;

  /// No description provided for @tradeRatingEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit rating'**
  String get tradeRatingEdit;

  /// No description provided for @tradeRatingCommentHint.
  ///
  /// In en, this message translates to:
  /// **'Short comment (optional)'**
  String get tradeRatingCommentHint;

  /// No description provided for @tradeRatingSaveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get tradeRatingSaveChanges;

  /// No description provided for @tradeRatingUpdating.
  ///
  /// In en, this message translates to:
  /// **'Saving changes...'**
  String get tradeRatingUpdating;

  /// No description provided for @tradeRatingUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'The rating was updated successfully.'**
  String get tradeRatingUpdatedSuccessfully;

  /// No description provided for @tradeRatingSelectStars.
  ///
  /// In en, this message translates to:
  /// **'Select from 1 to 5 stars.'**
  String get tradeRatingSelectStars;

  /// No description provided for @ratingReviewsTitle.
  ///
  /// In en, this message translates to:
  /// **'Received ratings'**
  String get ratingReviewsTitle;

  /// No description provided for @ratingNoReviews.
  ///
  /// In en, this message translates to:
  /// **'This collector has no ratings yet.'**
  String get ratingNoReviews;

  /// No description provided for @safetySettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Safety and privacy'**
  String get safetySettingsTitle;

  /// No description provided for @safetyMenu.
  ///
  /// In en, this message translates to:
  /// **'Safety options'**
  String get safetyMenu;

  /// No description provided for @safetyBlockUser.
  ///
  /// In en, this message translates to:
  /// **'Block user'**
  String get safetyBlockUser;

  /// No description provided for @safetyBlockUserTitle.
  ///
  /// In en, this message translates to:
  /// **'Block user'**
  String get safetyBlockUserTitle;

  /// No description provided for @safetyBlockUserConfirmation.
  ///
  /// In en, this message translates to:
  /// **'This user will not be able to send you messages or new trade offers. You will also be unable to message them or send a new offer.'**
  String get safetyBlockUserConfirmation;

  /// No description provided for @safetyUserBlocked.
  ///
  /// In en, this message translates to:
  /// **'The user has been blocked.'**
  String get safetyUserBlocked;

  /// No description provided for @safetyUnblockUser.
  ///
  /// In en, this message translates to:
  /// **'Unblock'**
  String get safetyUnblockUser;

  /// No description provided for @safetyUnblockUserTitle.
  ///
  /// In en, this message translates to:
  /// **'Unblock user'**
  String get safetyUnblockUserTitle;

  /// No description provided for @safetyUnblockUserConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Allow messages and new trade offers with this user again?'**
  String get safetyUnblockUserConfirmation;

  /// No description provided for @safetyUserUnblocked.
  ///
  /// In en, this message translates to:
  /// **'The user has been unblocked.'**
  String get safetyUserUnblocked;

  /// No description provided for @safetyReportUser.
  ///
  /// In en, this message translates to:
  /// **'Report user'**
  String get safetyReportUser;

  /// No description provided for @safetyReportTrade.
  ///
  /// In en, this message translates to:
  /// **'Report trade'**
  String get safetyReportTrade;

  /// No description provided for @safetyReportMessage.
  ///
  /// In en, this message translates to:
  /// **'Report message'**
  String get safetyReportMessage;

  /// No description provided for @safetyReportTitle.
  ///
  /// In en, this message translates to:
  /// **'Submit a report'**
  String get safetyReportTitle;

  /// No description provided for @safetyReportDescription.
  ///
  /// In en, this message translates to:
  /// **'Choose a reason and optionally add details. Only an administrator can review the report.'**
  String get safetyReportDescription;

  /// No description provided for @safetyReportReason.
  ///
  /// In en, this message translates to:
  /// **'Reason'**
  String get safetyReportReason;

  /// No description provided for @safetyReportReasonSpam.
  ///
  /// In en, this message translates to:
  /// **'Spam or unwanted content'**
  String get safetyReportReasonSpam;

  /// No description provided for @safetyReportReasonHarassment.
  ///
  /// In en, this message translates to:
  /// **'Harassment or abuse'**
  String get safetyReportReasonHarassment;

  /// No description provided for @safetyReportReasonFraud.
  ///
  /// In en, this message translates to:
  /// **'Suspected fraud'**
  String get safetyReportReasonFraud;

  /// No description provided for @safetyReportReasonInappropriate.
  ///
  /// In en, this message translates to:
  /// **'Inappropriate content'**
  String get safetyReportReasonInappropriate;

  /// No description provided for @safetyReportReasonOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get safetyReportReasonOther;

  /// No description provided for @safetyReportDetails.
  ///
  /// In en, this message translates to:
  /// **'Details (optional)'**
  String get safetyReportDetails;

  /// No description provided for @safetyReportDetailsHint.
  ///
  /// In en, this message translates to:
  /// **'Briefly describe what happened.'**
  String get safetyReportDetailsHint;

  /// No description provided for @safetyReportSubmit.
  ///
  /// In en, this message translates to:
  /// **'Submit report'**
  String get safetyReportSubmit;

  /// No description provided for @safetyReportSubmitting.
  ///
  /// In en, this message translates to:
  /// **'Submitting...'**
  String get safetyReportSubmitting;

  /// No description provided for @safetyReportSubmitted.
  ///
  /// In en, this message translates to:
  /// **'The report was submitted.'**
  String get safetyReportSubmitted;

  /// No description provided for @safetyReportError.
  ///
  /// In en, this message translates to:
  /// **'The report could not be submitted'**
  String get safetyReportError;

  /// No description provided for @safetyActionError.
  ///
  /// In en, this message translates to:
  /// **'The action could not be completed'**
  String get safetyActionError;

  /// No description provided for @safetyBlockedUsers.
  ///
  /// In en, this message translates to:
  /// **'Blocked users'**
  String get safetyBlockedUsers;

  /// No description provided for @safetyBlockedUsersDescription.
  ///
  /// In en, this message translates to:
  /// **'Review and unblock users.'**
  String get safetyBlockedUsersDescription;

  /// No description provided for @safetyBlockedUsersLoadError.
  ///
  /// In en, this message translates to:
  /// **'Blocked users could not be loaded.'**
  String get safetyBlockedUsersLoadError;

  /// No description provided for @safetyNoBlockedUsers.
  ///
  /// In en, this message translates to:
  /// **'You have no blocked users.'**
  String get safetyNoBlockedUsers;

  /// No description provided for @safetyConversationBlockedByYou.
  ///
  /// In en, this message translates to:
  /// **'You blocked this user. The conversation remains visible, but new messages cannot be sent.'**
  String get safetyConversationBlockedByYou;

  /// No description provided for @safetyConversationBlockedByOther.
  ///
  /// In en, this message translates to:
  /// **'Sending new messages in this conversation is unavailable.'**
  String get safetyConversationBlockedByOther;

  /// No description provided for @safetyProfileBlockedByYou.
  ///
  /// In en, this message translates to:
  /// **'You blocked this user.'**
  String get safetyProfileBlockedByYou;

  /// No description provided for @safetyProfileBlockedByOther.
  ///
  /// In en, this message translates to:
  /// **'Communication with this user is unavailable.'**
  String get safetyProfileBlockedByOther;

  /// No description provided for @safetyAdminReports.
  ///
  /// In en, this message translates to:
  /// **'Review reports'**
  String get safetyAdminReports;

  /// No description provided for @safetyAdminReportsDescription.
  ///
  /// In en, this message translates to:
  /// **'Administrative review of reported users and content.'**
  String get safetyAdminReportsDescription;

  /// No description provided for @safetyReportsLoadError.
  ///
  /// In en, this message translates to:
  /// **'Reports could not be loaded.'**
  String get safetyReportsLoadError;

  /// No description provided for @safetyNoReports.
  ///
  /// In en, this message translates to:
  /// **'There are no reports for the selected filter.'**
  String get safetyNoReports;

  /// No description provided for @safetyReportTypeUser.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get safetyReportTypeUser;

  /// No description provided for @safetyReportTypeMessage.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get safetyReportTypeMessage;

  /// No description provided for @safetyReportTypeTrade.
  ///
  /// In en, this message translates to:
  /// **'Trade'**
  String get safetyReportTypeTrade;

  /// No description provided for @safetyReportStatusOpen.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get safetyReportStatusOpen;

  /// No description provided for @safetyReportStatusReviewing.
  ///
  /// In en, this message translates to:
  /// **'Reviewing'**
  String get safetyReportStatusReviewing;

  /// No description provided for @safetyReportStatusResolved.
  ///
  /// In en, this message translates to:
  /// **'Resolved'**
  String get safetyReportStatusResolved;

  /// No description provided for @safetyReportStatusDismissed.
  ///
  /// In en, this message translates to:
  /// **'Dismissed'**
  String get safetyReportStatusDismissed;

  /// No description provided for @safetyReportStatusUpdated.
  ///
  /// In en, this message translates to:
  /// **'The report status was updated.'**
  String get safetyReportStatusUpdated;

  /// No description provided for @safetyReporterId.
  ///
  /// In en, this message translates to:
  /// **'Reporter'**
  String get safetyReporterId;

  /// No description provided for @safetyReportedUserId.
  ///
  /// In en, this message translates to:
  /// **'Reported user'**
  String get safetyReportedUserId;

  /// No description provided for @safetyTargetId.
  ///
  /// In en, this message translates to:
  /// **'Reported content'**
  String get safetyTargetId;

  /// No description provided for @safetyConversationId.
  ///
  /// In en, this message translates to:
  /// **'Conversation'**
  String get safetyConversationId;

  /// No description provided for @tradeDeliverySectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Handover and shipping'**
  String get tradeDeliverySectionTitle;

  /// No description provided for @tradeDeliverySectionDescription.
  ///
  /// In en, this message translates to:
  /// **'Choose a handover method and share the required private details with your trade partner.'**
  String get tradeDeliverySectionDescription;

  /// No description provided for @tradeDeliveryYourDetails.
  ///
  /// In en, this message translates to:
  /// **'Your details'**
  String get tradeDeliveryYourDetails;

  /// No description provided for @tradeDeliveryPartnerDetails.
  ///
  /// In en, this message translates to:
  /// **'Partner\'s details'**
  String get tradeDeliveryPartnerDetails;

  /// No description provided for @tradeDeliveryYourDetailsMissing.
  ///
  /// In en, this message translates to:
  /// **'You have not added handover or shipping details yet.'**
  String get tradeDeliveryYourDetailsMissing;

  /// No description provided for @tradeDeliveryPartnerDetailsMissing.
  ///
  /// In en, this message translates to:
  /// **'Your partner has not added handover or shipping details yet.'**
  String get tradeDeliveryPartnerDetailsMissing;

  /// No description provided for @tradeDeliveryAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get tradeDeliveryAdd;

  /// No description provided for @tradeDeliveryEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get tradeDeliveryEdit;

  /// No description provided for @tradeDeliveryFormTitle.
  ///
  /// In en, this message translates to:
  /// **'Handover details'**
  String get tradeDeliveryFormTitle;

  /// No description provided for @tradeDeliveryChooseMethod.
  ///
  /// In en, this message translates to:
  /// **'Handover method'**
  String get tradeDeliveryChooseMethod;

  /// No description provided for @tradeDeliveryByMail.
  ///
  /// In en, this message translates to:
  /// **'By mail'**
  String get tradeDeliveryByMail;

  /// No description provided for @tradeDeliveryInPerson.
  ///
  /// In en, this message translates to:
  /// **'In person'**
  String get tradeDeliveryInPerson;

  /// No description provided for @tradeDeliveryFullName.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get tradeDeliveryFullName;

  /// No description provided for @tradeDeliveryAddressLine1.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get tradeDeliveryAddressLine1;

  /// No description provided for @tradeDeliveryAddressLine2.
  ///
  /// In en, this message translates to:
  /// **'Additional address line (optional)'**
  String get tradeDeliveryAddressLine2;

  /// No description provided for @tradeDeliveryPostalCode.
  ///
  /// In en, this message translates to:
  /// **'Postal code'**
  String get tradeDeliveryPostalCode;

  /// No description provided for @tradeDeliveryCity.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get tradeDeliveryCity;

  /// No description provided for @tradeDeliveryCountry.
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get tradeDeliveryCountry;

  /// No description provided for @tradeDeliveryPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone number (optional)'**
  String get tradeDeliveryPhone;

  /// No description provided for @tradeDeliveryMeetingDetails.
  ///
  /// In en, this message translates to:
  /// **'In-person handover details'**
  String get tradeDeliveryMeetingDetails;

  /// No description provided for @tradeDeliveryMeetingDetailsHint.
  ///
  /// In en, this message translates to:
  /// **'Suggest a place, time, or way to arrange the handover.'**
  String get tradeDeliveryMeetingDetailsHint;

  /// No description provided for @tradeDeliveryCarrier.
  ///
  /// In en, this message translates to:
  /// **'Delivery company (optional)'**
  String get tradeDeliveryCarrier;

  /// No description provided for @tradeDeliveryCarrierHint.
  ///
  /// In en, this message translates to:
  /// **'For example national post, GLS, or DPD'**
  String get tradeDeliveryCarrierHint;

  /// No description provided for @tradeDeliveryTrackingNumber.
  ///
  /// In en, this message translates to:
  /// **'Tracking number (optional)'**
  String get tradeDeliveryTrackingNumber;

  /// No description provided for @tradeDeliveryNotes.
  ///
  /// In en, this message translates to:
  /// **'Note (optional)'**
  String get tradeDeliveryNotes;

  /// No description provided for @tradeDeliveryNotesHint.
  ///
  /// In en, this message translates to:
  /// **'Add important instructions for your partner.'**
  String get tradeDeliveryNotesHint;

  /// No description provided for @tradeDeliveryPrivateTitle.
  ///
  /// In en, this message translates to:
  /// **'Private details'**
  String get tradeDeliveryPrivateTitle;

  /// No description provided for @tradeDeliveryPrivateDescription.
  ///
  /// In en, this message translates to:
  /// **'These details are not public. Only the other participant in the accepted trade can see them.'**
  String get tradeDeliveryPrivateDescription;

  /// No description provided for @tradeDeliveryPrivateShortDescription.
  ///
  /// In en, this message translates to:
  /// **'These details are visible only to the two participants in this accepted or completed trade.'**
  String get tradeDeliveryPrivateShortDescription;

  /// No description provided for @tradeDeliveryRequiredField.
  ///
  /// In en, this message translates to:
  /// **'This field is required.'**
  String get tradeDeliveryRequiredField;

  /// No description provided for @tradeDeliverySave.
  ///
  /// In en, this message translates to:
  /// **'Save details'**
  String get tradeDeliverySave;

  /// No description provided for @tradeDeliverySaving.
  ///
  /// In en, this message translates to:
  /// **'Saving...'**
  String get tradeDeliverySaving;

  /// No description provided for @tradeDeliverySaved.
  ///
  /// In en, this message translates to:
  /// **'Handover details were saved.'**
  String get tradeDeliverySaved;

  /// No description provided for @tradeDeliverySaveError.
  ///
  /// In en, this message translates to:
  /// **'The details could not be saved: {error}'**
  String tradeDeliverySaveError(String error);

  /// No description provided for @tradeDeliveryLoadError.
  ///
  /// In en, this message translates to:
  /// **'Handover details could not be loaded.'**
  String get tradeDeliveryLoadError;

  /// No description provided for @tradeDeliveryAddress.
  ///
  /// In en, this message translates to:
  /// **'Shipping address'**
  String get tradeDeliveryAddress;

  /// No description provided for @tradeDeliveryTrackingMissing.
  ///
  /// In en, this message translates to:
  /// **'A tracking number has not been added yet.'**
  String get tradeDeliveryTrackingMissing;

  /// No description provided for @tradeDeliveryCopyAddress.
  ///
  /// In en, this message translates to:
  /// **'Copy address'**
  String get tradeDeliveryCopyAddress;

  /// No description provided for @tradeDeliveryCopyPhone.
  ///
  /// In en, this message translates to:
  /// **'Copy phone number'**
  String get tradeDeliveryCopyPhone;

  /// No description provided for @tradeDeliveryCopyTracking.
  ///
  /// In en, this message translates to:
  /// **'Copy tracking number'**
  String get tradeDeliveryCopyTracking;

  /// No description provided for @tradeDeliveryCopied.
  ///
  /// In en, this message translates to:
  /// **'The information was copied.'**
  String get tradeDeliveryCopied;

  /// No description provided for @continueLabel.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueLabel;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @betaOnboardingTitle.
  ///
  /// In en, this message translates to:
  /// **'App introduction'**
  String get betaOnboardingTitle;

  /// No description provided for @betaOnboardingSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get betaOnboardingSkip;

  /// No description provided for @betaOnboardingStart.
  ///
  /// In en, this message translates to:
  /// **'Get started'**
  String get betaOnboardingStart;

  /// No description provided for @betaOnboardingCollectionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Your collections in one place'**
  String get betaOnboardingCollectionsTitle;

  /// No description provided for @betaOnboardingCollectionsDescription.
  ///
  /// In en, this message translates to:
  /// **'Mark the cards you own, the ones you are missing, and your duplicates. Your collection overview updates as you go.'**
  String get betaOnboardingCollectionsDescription;

  /// No description provided for @betaOnboardingTradesTitle.
  ///
  /// In en, this message translates to:
  /// **'Find meaningful swaps'**
  String get betaOnboardingTradesTitle;

  /// No description provided for @betaOnboardingTradesDescription.
  ///
  /// In en, this message translates to:
  /// **'SwapStash compares duplicates and missing cards and suggests collectors with whom a mutually useful swap may be possible.'**
  String get betaOnboardingTradesDescription;

  /// No description provided for @betaOnboardingCompleteTradeTitle.
  ///
  /// In en, this message translates to:
  /// **'Agree, hand over, and rate'**
  String get betaOnboardingCompleteTradeTitle;

  /// No description provided for @betaOnboardingCompleteTradeDescription.
  ///
  /// In en, this message translates to:
  /// **'Send an offer, chat, privately share handover or shipping details, and rate your partner after the swap is completed.'**
  String get betaOnboardingCompleteTradeDescription;

  /// No description provided for @betaOnboardingSafetyTitle.
  ///
  /// In en, this message translates to:
  /// **'Safety and control'**
  String get betaOnboardingSafetyTitle;

  /// No description provided for @betaOnboardingSafetyDescription.
  ///
  /// In en, this message translates to:
  /// **'Block a user, report inappropriate content, and control which information is public and which is visible only to a trade partner.'**
  String get betaOnboardingSafetyDescription;

  /// No description provided for @betaOnboardingShowAgain.
  ///
  /// In en, this message translates to:
  /// **'Show the introduction again'**
  String get betaOnboardingShowAgain;

  /// No description provided for @betaOnboardingShowAgainDescription.
  ///
  /// In en, this message translates to:
  /// **'Review the app\'s main features again.'**
  String get betaOnboardingShowAgainDescription;

  /// No description provided for @legalAcceptanceTitle.
  ///
  /// In en, this message translates to:
  /// **'Terms and privacy'**
  String get legalAcceptanceTitle;

  /// No description provided for @legalAcceptanceHeading.
  ///
  /// In en, this message translates to:
  /// **'Before you continue'**
  String get legalAcceptanceHeading;

  /// No description provided for @legalAcceptanceDescription.
  ///
  /// In en, this message translates to:
  /// **'Please review the basic usage rules and information about personal data processing.'**
  String get legalAcceptanceDescription;

  /// No description provided for @legalAgeConfirmation.
  ///
  /// In en, this message translates to:
  /// **'I confirm that I am at least 13 years old. If I am under 15 in Slovenia, I have permission from a parent or guardian.'**
  String get legalAgeConfirmation;

  /// No description provided for @legalDocumentsConfirmation.
  ///
  /// In en, this message translates to:
  /// **'I have read and accept the Terms of Use and Privacy Policy.'**
  String get legalDocumentsConfirmation;

  /// No description provided for @legalAcceptAndContinue.
  ///
  /// In en, this message translates to:
  /// **'Accept and continue'**
  String get legalAcceptAndContinue;

  /// No description provided for @legalAcceptanceSaving.
  ///
  /// In en, this message translates to:
  /// **'Saving acceptance...'**
  String get legalAcceptanceSaving;

  /// No description provided for @legalBetaNoticeTitle.
  ///
  /// In en, this message translates to:
  /// **'Closed beta version'**
  String get legalBetaNoticeTitle;

  /// No description provided for @legalBetaNoticeDescription.
  ///
  /// In en, this message translates to:
  /// **'The app is still being tested. Features may change and occasional errors or interruptions may occur.'**
  String get legalBetaNoticeDescription;

  /// No description provided for @legalTermsTitle.
  ///
  /// In en, this message translates to:
  /// **'Terms of Use'**
  String get legalTermsTitle;

  /// No description provided for @legalPrivacyTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get legalPrivacyTitle;

  /// No description provided for @legalEffectiveDate.
  ///
  /// In en, this message translates to:
  /// **'Effective date: 24 July 2026'**
  String get legalEffectiveDate;

  /// No description provided for @legalContactFooter.
  ///
  /// In en, this message translates to:
  /// **'Controller: SwapStash · Contact: uros2004@gmail.com'**
  String get legalContactFooter;

  /// No description provided for @legalTermsIntro.
  ///
  /// In en, this message translates to:
  /// **'These terms govern the use of the SwapStash application. By using the app, you agree to them.'**
  String get legalTermsIntro;

  /// No description provided for @legalTermsEligibilityTitle.
  ///
  /// In en, this message translates to:
  /// **'1. Age and user account'**
  String get legalTermsEligibilityTitle;

  /// No description provided for @legalTermsEligibilityBody.
  ///
  /// In en, this message translates to:
  /// **'The app may be used by a person aged at least 13. Where applicable law requires a higher age for independent consent, a minor must obtain permission from a parent or guardian. In Slovenia, a user under 15 needs such permission. Users must provide accurate information, protect their login credentials, and are responsible for activity on their accounts.'**
  String get legalTermsEligibilityBody;

  /// No description provided for @legalTermsServiceTitle.
  ///
  /// In en, this message translates to:
  /// **'2. Purpose of the service and beta version'**
  String get legalTermsServiceTitle;

  /// No description provided for @legalTermsServiceBody.
  ///
  /// In en, this message translates to:
  /// **'SwapStash enables collection tracking, discovery of possible swaps, offers, messaging, handover arrangements, and ratings after completed swaps. SwapStash is not the seller, buyer, broker, carrier, or party to an agreement between users. During beta, features may change or temporarily be unavailable.'**
  String get legalTermsServiceBody;

  /// No description provided for @legalTermsConductTitle.
  ///
  /// In en, this message translates to:
  /// **'3. Permitted use'**
  String get legalTermsConductTitle;

  /// No description provided for @legalTermsConductBody.
  ///
  /// In en, this message translates to:
  /// **'Harassment, threats, hate speech, spam, deception, fraud, impersonation, unlawful content, interference with the app, and unauthorized automated use are prohibited. A user must not publish another person\'s information without an appropriate legal basis.'**
  String get legalTermsConductBody;

  /// No description provided for @legalTermsTradesTitle.
  ///
  /// In en, this message translates to:
  /// **'4. Swaps and delivery'**
  String get legalTermsTradesTitle;

  /// No description provided for @legalTermsTradesBody.
  ///
  /// In en, this message translates to:
  /// **'Users are responsible for checking the condition, authenticity, and value of items and agreeing on handover, costs, and shipment tracking. SwapStash does not guarantee that another user will perform an agreement and does not provide reimbursement for lost, damaged, or disputed shipments. Choose a safe public place for in-person handovers; minors should involve a parent or guardian.'**
  String get legalTermsTradesBody;

  /// No description provided for @legalTermsContentTitle.
  ///
  /// In en, this message translates to:
  /// **'5. Messages and user content'**
  String get legalTermsContentTitle;

  /// No description provided for @legalTermsContentBody.
  ///
  /// In en, this message translates to:
  /// **'Users remain responsible for content they enter or send. For safety, reports, abuse prevention, or legal compliance, SwapStash may restrict access, remove content, or disclose information to competent authorities where necessary and lawful.'**
  String get legalTermsContentBody;

  /// No description provided for @legalTermsSuspensionTitle.
  ///
  /// In en, this message translates to:
  /// **'6. Blocking and enforcement'**
  String get legalTermsSuspensionTitle;

  /// No description provided for @legalTermsSuspensionBody.
  ///
  /// In en, this message translates to:
  /// **'Users may block or report other users. SwapStash may restrict or close an account where there is a reasonable suspicion of a breach of these terms, abuse, a security risk, or unlawful conduct. Where possible, the user will be informed of the reason.'**
  String get legalTermsSuspensionBody;

  /// No description provided for @legalTermsLiabilityTitle.
  ///
  /// In en, this message translates to:
  /// **'7. Availability and liability'**
  String get legalTermsLiabilityTitle;

  /// No description provided for @legalTermsLiabilityBody.
  ///
  /// In en, this message translates to:
  /// **'The service is provided on an “as is” basis. SwapStash aims to operate safely and reliably but does not guarantee uninterrupted availability, complete accuracy, or the success of a particular swap. Liability limitations apply only to the extent permitted by law and do not exclude rights that cannot lawfully be limited.'**
  String get legalTermsLiabilityBody;

  /// No description provided for @legalTermsChangesTitle.
  ///
  /// In en, this message translates to:
  /// **'8. Changes, governing law, and contact'**
  String get legalTermsChangesTitle;

  /// No description provided for @legalTermsChangesBody.
  ///
  /// In en, this message translates to:
  /// **'The terms may be updated due to new features, security requirements, or legislation. The app will request renewed acceptance for material changes. Slovenian law applies, subject to mandatory consumer rights under the law of the user\'s country. Questions may be sent to uros2004@gmail.com.'**
  String get legalTermsChangesBody;

  /// No description provided for @legalPrivacyIntro.
  ///
  /// In en, this message translates to:
  /// **'This policy explains which personal data SwapStash processes, why it is used, and the rights available to users.'**
  String get legalPrivacyIntro;

  /// No description provided for @legalPrivacyControllerTitle.
  ///
  /// In en, this message translates to:
  /// **'1. Controller and contact'**
  String get legalPrivacyControllerTitle;

  /// No description provided for @legalPrivacyControllerBody.
  ///
  /// In en, this message translates to:
  /// **'The personal data controller is SwapStash. Send privacy questions, requests, or objections to uros2004@gmail.com.'**
  String get legalPrivacyControllerBody;

  /// No description provided for @legalPrivacyDataTitle.
  ///
  /// In en, this message translates to:
  /// **'2. Data we process'**
  String get legalPrivacyDataTitle;

  /// No description provided for @legalPrivacyDataBody.
  ///
  /// In en, this message translates to:
  /// **'We process account and sign-in information, email address, display name, country, city, language, profile photo and bio; collection, card, and duplicate data; offers, trade status, ratings, messages, and reports; handover or shipping information voluntarily entered by a user; push-notification tokens; and basic technical and security information required to operate the service.'**
  String get legalPrivacyDataBody;

  /// No description provided for @legalPrivacyPurposeTitle.
  ///
  /// In en, this message translates to:
  /// **'3. Purposes and legal bases'**
  String get legalPrivacyPurposeTitle;

  /// No description provided for @legalPrivacyPurposeBody.
  ///
  /// In en, this message translates to:
  /// **'We use data to create and manage accounts, provide collection and trade features, enable communication, deliver notifications, prevent abuse, handle reports, protect security, provide support, and comply with legal obligations. Legal bases include performance of the user agreement, consent, legitimate interests in security and service improvement, and legal obligations.'**
  String get legalPrivacyPurposeBody;

  /// No description provided for @legalPrivacyVisibilityTitle.
  ///
  /// In en, this message translates to:
  /// **'4. Visibility and disclosure to other users'**
  String get legalPrivacyVisibilityTitle;

  /// No description provided for @legalPrivacyVisibilityBody.
  ///
  /// In en, this message translates to:
  /// **'A public profile may show the selected name, photo, location, bio, ratings, and trade statistics. Messages are visible to conversation participants. Addresses, phone numbers, in-person handover details, and shipment tracking are visible only to participants in an accepted or completed trade. Reports are visible to the reporter where permitted and to administrators.'**
  String get legalPrivacyVisibilityBody;

  /// No description provided for @legalPrivacyRetentionTitle.
  ///
  /// In en, this message translates to:
  /// **'5. Retention and deletion'**
  String get legalPrivacyRetentionTitle;

  /// No description provided for @legalPrivacyRetentionBody.
  ///
  /// In en, this message translates to:
  /// **'We retain data for as long as needed to operate the account, maintain safety, resolve disputes, and meet legal obligations. Users may request account deletion. Some records may be retained for a limited period where necessary to prevent abuse, establish legal claims, or comply with law. Local acceptance of legal documents is stored on the device.'**
  String get legalPrivacyRetentionBody;

  /// No description provided for @legalPrivacyProcessorsTitle.
  ///
  /// In en, this message translates to:
  /// **'6. Service providers and transfers'**
  String get legalPrivacyProcessorsTitle;

  /// No description provided for @legalPrivacyProcessorsBody.
  ///
  /// In en, this message translates to:
  /// **'We use Firebase or Google Cloud and other technical providers for hosting, authentication, databases, photo storage, and push notifications. They process data under instructions and contractual obligations. Where processing occurs outside the European Economic Area, appropriate safeguards such as adequacy decisions or standard contractual clauses are used.'**
  String get legalPrivacyProcessorsBody;

  /// No description provided for @legalPrivacyRightsTitle.
  ///
  /// In en, this message translates to:
  /// **'7. User rights'**
  String get legalPrivacyRightsTitle;

  /// No description provided for @legalPrivacyRightsBody.
  ///
  /// In en, this message translates to:
  /// **'Depending on the circumstances, you may request access, correction, deletion, restriction, data portability, or object to processing. Consent may be withdrawn for the future. Send requests to uros2004@gmail.com. You may also complain to the Slovenian Information Commissioner or the competent supervisory authority.'**
  String get legalPrivacyRightsBody;

  /// No description provided for @legalPrivacyChildrenTitle.
  ///
  /// In en, this message translates to:
  /// **'8. Children and young people'**
  String get legalPrivacyChildrenTitle;

  /// No description provided for @legalPrivacyChildrenBody.
  ///
  /// In en, this message translates to:
  /// **'SwapStash is not intended for children under 13. A user aged 13 or 14 in Slovenia must have permission from a parent or guardian. Parents or guardians may request review or deletion of a minor\'s data. Minors should not publish a home address publicly and should attend in-person handovers with an adult.'**
  String get legalPrivacyChildrenBody;

  /// No description provided for @legalPrivacySecurityTitle.
  ///
  /// In en, this message translates to:
  /// **'9. Security and policy changes'**
  String get legalPrivacySecurityTitle;

  /// No description provided for @legalPrivacySecurityBody.
  ///
  /// In en, this message translates to:
  /// **'We use technical and organizational measures such as access checks, private subcollections, database security rules, blocking, reports, and secure authentication. No system is completely secure. Material changes to this policy will be announced in the app and may require renewed acceptance.'**
  String get legalPrivacySecurityBody;

  /// No description provided for @aboutAppTitle.
  ///
  /// In en, this message translates to:
  /// **'About the app'**
  String get aboutAppTitle;

  /// No description provided for @aboutAppDescription.
  ///
  /// In en, this message translates to:
  /// **'SwapStash helps collectors organize collections, find suitable partners, and complete swaps more safely.'**
  String get aboutAppDescription;

  /// No description provided for @aboutVersion.
  ///
  /// In en, this message translates to:
  /// **'App version'**
  String get aboutVersion;

  /// No description provided for @aboutVersionLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading version...'**
  String get aboutVersionLoading;

  /// No description provided for @aboutOperator.
  ///
  /// In en, this message translates to:
  /// **'Controller'**
  String get aboutOperator;

  /// No description provided for @aboutContact.
  ///
  /// In en, this message translates to:
  /// **'Contact and support'**
  String get aboutContact;

  /// No description provided for @aboutLegalSection.
  ///
  /// In en, this message translates to:
  /// **'Legal information'**
  String get aboutLegalSection;

  /// No description provided for @aboutSendFeedback.
  ///
  /// In en, this message translates to:
  /// **'Send feedback'**
  String get aboutSendFeedback;

  /// No description provided for @aboutFeedbackEmailSubject.
  ///
  /// In en, this message translates to:
  /// **'SwapStash beta feedback'**
  String get aboutFeedbackEmailSubject;

  /// No description provided for @aboutFeedbackOpenError.
  ///
  /// In en, this message translates to:
  /// **'The email application could not be opened.'**
  String get aboutFeedbackOpenError;

  /// No description provided for @aboutBetaFooter.
  ///
  /// In en, this message translates to:
  /// **'Closed beta version · data and features may change before public release.'**
  String get aboutBetaFooter;

  /// No description provided for @settingsAboutAndLegalTitle.
  ///
  /// In en, this message translates to:
  /// **'About and legal information'**
  String get settingsAboutAndLegalTitle;

  /// No description provided for @settingsAboutAppSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Version, contact, feedback, and documents'**
  String get settingsAboutAppSubtitle;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de', 'en', 'hr', 'sl'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'hr':
      return AppLocalizationsHr();
    case 'sl':
      return AppLocalizationsSl();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
