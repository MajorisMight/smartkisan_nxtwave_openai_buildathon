import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_hi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
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
    Locale('en'),
    Locale('hi'),
  ];

  /// No description provided for @selectLanguagePrompt.
  ///
  /// In en, this message translates to:
  /// **'Please select your preferred language'**
  String get selectLanguagePrompt;

  /// No description provided for @selectLanguageTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguageTitle;

  /// No description provided for @languageSelectedSnackbar.
  ///
  /// In en, this message translates to:
  /// **'You selected: {languageName}'**
  String languageSelectedSnackbar(Object languageName);

  /// No description provided for @btnSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get btnSave;

  /// No description provided for @btnContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get btnContinue;

  /// No description provided for @btnSaving.
  ///
  /// In en, this message translates to:
  /// **'Saving...'**
  String get btnSaving;

  /// No description provided for @btnPosting.
  ///
  /// In en, this message translates to:
  /// **'Posting...'**
  String get btnPosting;

  /// No description provided for @btnPost.
  ///
  /// In en, this message translates to:
  /// **'Post'**
  String get btnPost;

  /// No description provided for @btnCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get btnCancel;

  /// No description provided for @btnClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get btnClose;

  /// No description provided for @btnView.
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get btnView;

  /// No description provided for @btnViewAll.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get btnViewAll;

  /// No description provided for @btnRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get btnRetry;

  /// No description provided for @btnRefresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get btnRefresh;

  /// No description provided for @lblComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get lblComingSoon;

  /// No description provided for @lblSearch.
  ///
  /// In en, this message translates to:
  /// **'Search...'**
  String get lblSearch;

  /// No description provided for @lblLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get lblLoading;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navMarketplace.
  ///
  /// In en, this message translates to:
  /// **'Marketplace'**
  String get navMarketplace;

  /// No description provided for @navWeather.
  ///
  /// In en, this message translates to:
  /// **'Weather'**
  String get navWeather;

  /// No description provided for @navCommunity.
  ///
  /// In en, this message translates to:
  /// **'Community'**
  String get navCommunity;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @homeGreeting.
  ///
  /// In en, this message translates to:
  /// **'Good Morning!'**
  String get homeGreeting;

  /// No description provided for @homeDefaultName.
  ///
  /// In en, this message translates to:
  /// **'Farmer'**
  String get homeDefaultName;

  /// No description provided for @homeDefaultFarm.
  ///
  /// In en, this message translates to:
  /// **'Farm not set'**
  String get homeDefaultFarm;

  /// No description provided for @homeQuickStatsSales.
  ///
  /// In en, this message translates to:
  /// **'Total Sales'**
  String get homeQuickStatsSales;

  /// No description provided for @homeQuickStatsOrders.
  ///
  /// In en, this message translates to:
  /// **'Active Orders'**
  String get homeQuickStatsOrders;

  /// No description provided for @homeQuickStatsProducts.
  ///
  /// In en, this message translates to:
  /// **'Products'**
  String get homeQuickStatsProducts;

  /// No description provided for @homeQuickActionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get homeQuickActionsTitle;

  /// No description provided for @homeActionCrops.
  ///
  /// In en, this message translates to:
  /// **'My Crops'**
  String get homeActionCrops;

  /// No description provided for @homeActionCropsDesc.
  ///
  /// In en, this message translates to:
  /// **'Track fields and crop health'**
  String get homeActionCropsDesc;

  /// No description provided for @homeActionFertilizer.
  ///
  /// In en, this message translates to:
  /// **'Baseline Fertilizer'**
  String get homeActionFertilizer;

  /// No description provided for @homeActionFertilizerDesc.
  ///
  /// In en, this message translates to:
  /// **'Pre-planting nutrient baseline planner'**
  String get homeActionFertilizerDesc;

  /// No description provided for @homeActionSuggestions.
  ///
  /// In en, this message translates to:
  /// **'Crop Suggestions'**
  String get homeActionSuggestions;

  /// No description provided for @homeActionSuggestionsDesc.
  ///
  /// In en, this message translates to:
  /// **'AI crop plan using backend farm data'**
  String get homeActionSuggestionsDesc;

  /// No description provided for @homeActionDisease.
  ///
  /// In en, this message translates to:
  /// **'Disease Detection'**
  String get homeActionDisease;

  /// No description provided for @homeActionSchemes.
  ///
  /// In en, this message translates to:
  /// **'Govt Schemes'**
  String get homeActionSchemes;

  /// No description provided for @homeRecentOrders.
  ///
  /// In en, this message translates to:
  /// **'Recent Orders'**
  String get homeRecentOrders;

  /// No description provided for @homeCommunityUpdates.
  ///
  /// In en, this message translates to:
  /// **'Community Updates'**
  String get homeCommunityUpdates;

  /// No description provided for @marketTitle.
  ///
  /// In en, this message translates to:
  /// **'Marketplace'**
  String get marketTitle;

  /// No description provided for @marketSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Buy & Sell Agricultural Products'**
  String get marketSubtitle;

  /// No description provided for @marketSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search products...'**
  String get marketSearchHint;

  /// No description provided for @marketLabelOrganic.
  ///
  /// In en, this message translates to:
  /// **'ORGANIC'**
  String get marketLabelOrganic;

  /// No description provided for @marketNoDescription.
  ///
  /// In en, this message translates to:
  /// **'No description added.'**
  String get marketNoDescription;

  /// No description provided for @marketLabelStock.
  ///
  /// In en, this message translates to:
  /// **'Stock: {quantity} {unit}'**
  String marketLabelStock(Object quantity, Object unit);

  /// No description provided for @weightUnitKg.
  ///
  /// In en, this message translates to:
  /// **'kg'**
  String get weightUnitKg;

  /// No description provided for @weightUnitTon.
  ///
  /// In en, this message translates to:
  /// **'ton'**
  String get weightUnitTon;

  /// No description provided for @weightUnitQuintal.
  ///
  /// In en, this message translates to:
  /// **'quintal'**
  String get weightUnitQuintal;

  /// No description provided for @weightUnitPiece.
  ///
  /// In en, this message translates to:
  /// **'piece'**
  String get weightUnitPiece;

  /// No description provided for @weightUnitBag.
  ///
  /// In en, this message translates to:
  /// **'bag'**
  String get weightUnitBag;

  /// No description provided for @unitLabel.
  ///
  /// In en, this message translates to:
  /// **'Unit'**
  String get unitLabel;

  /// No description provided for @marketEmptyState.
  ///
  /// In en, this message translates to:
  /// **'No products found'**
  String get marketEmptyState;

  /// No description provided for @marketErrorLoad.
  ///
  /// In en, this message translates to:
  /// **'Unable to load products.'**
  String get marketErrorLoad;

  /// No description provided for @addProductTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Product'**
  String get addProductTitle;

  /// No description provided for @addProductLabelName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get addProductLabelName;

  /// No description provided for @addProductLabelDesc.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get addProductLabelDesc;

  /// No description provided for @addProductLabelPrice.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get addProductLabelPrice;

  /// No description provided for @addProductLabelStock.
  ///
  /// In en, this message translates to:
  /// **'Stock Quantity'**
  String get addProductLabelStock;

  /// No description provided for @addProductLabelCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get addProductLabelCategory;

  /// No description provided for @addProductLabelUnit.
  ///
  /// In en, this message translates to:
  /// **'Unit'**
  String get addProductLabelUnit;

  /// No description provided for @addProductCheckboxOrganic.
  ///
  /// In en, this message translates to:
  /// **'Organic product'**
  String get addProductCheckboxOrganic;

  /// No description provided for @addProductBtnAddPhoto.
  ///
  /// In en, this message translates to:
  /// **'Add Product Photo'**
  String get addProductBtnAddPhoto;

  /// No description provided for @addProductBtnChangePhoto.
  ///
  /// In en, this message translates to:
  /// **'Change Product Photo'**
  String get addProductBtnChangePhoto;

  /// No description provided for @addProductMsgSuccess.
  ///
  /// In en, this message translates to:
  /// **'Product added successfully.'**
  String get addProductMsgSuccess;

  /// No description provided for @addProductMsgError.
  ///
  /// In en, this message translates to:
  /// **'Unable to add product: {error}'**
  String addProductMsgError(Object error);

  /// No description provided for @addProductMsgRequired.
  ///
  /// In en, this message translates to:
  /// **'Name, price and stock are required.'**
  String get addProductMsgRequired;

  /// No description provided for @catAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get catAll;

  /// No description provided for @catFertilizers.
  ///
  /// In en, this message translates to:
  /// **'Fertilizers'**
  String get catFertilizers;

  /// No description provided for @catSeeds.
  ///
  /// In en, this message translates to:
  /// **'Seeds'**
  String get catSeeds;

  /// No description provided for @catPesticides.
  ///
  /// In en, this message translates to:
  /// **'Pesticides'**
  String get catPesticides;

  /// No description provided for @catEquipment.
  ///
  /// In en, this message translates to:
  /// **'Equipment'**
  String get catEquipment;

  /// No description provided for @catOrganic.
  ///
  /// In en, this message translates to:
  /// **'Organic'**
  String get catOrganic;

  /// No description provided for @commTitle.
  ///
  /// In en, this message translates to:
  /// **'Community'**
  String get commTitle;

  /// No description provided for @commSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Connect with Fellow Farmers'**
  String get commSubtitle;

  /// No description provided for @commSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search posts...'**
  String get commSearchHint;

  /// No description provided for @commEmptyState.
  ///
  /// In en, this message translates to:
  /// **'No posts found'**
  String get commEmptyState;

  /// No description provided for @commErrorLoad.
  ///
  /// In en, this message translates to:
  /// **'Unable to load posts.'**
  String get commErrorLoad;

  /// No description provided for @commBtnCreate.
  ///
  /// In en, this message translates to:
  /// **'Create New Post'**
  String get commBtnCreate;

  /// No description provided for @commDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Create New Post'**
  String get commDialogTitle;

  /// No description provided for @commLabelTitle.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get commLabelTitle;

  /// No description provided for @commLabelContent.
  ///
  /// In en, this message translates to:
  /// **'Content'**
  String get commLabelContent;

  /// No description provided for @commLabelTags.
  ///
  /// In en, this message translates to:
  /// **'Tags (comma separated)'**
  String get commLabelTags;

  /// No description provided for @commBtnAddPhoto.
  ///
  /// In en, this message translates to:
  /// **'Add Post Photo'**
  String get commBtnAddPhoto;

  /// No description provided for @commBtnChangePhoto.
  ///
  /// In en, this message translates to:
  /// **'Change Post Photo'**
  String get commBtnChangePhoto;

  /// No description provided for @commMsgSuccess.
  ///
  /// In en, this message translates to:
  /// **'Post created successfully.'**
  String get commMsgSuccess;

  /// No description provided for @commMsgRequired.
  ///
  /// In en, this message translates to:
  /// **'Title and content are required.'**
  String get commMsgRequired;

  /// No description provided for @commCommentsTitle.
  ///
  /// In en, this message translates to:
  /// **'Comments'**
  String get commCommentsTitle;

  /// No description provided for @commCommentsHint.
  ///
  /// In en, this message translates to:
  /// **'Write a comment...'**
  String get commCommentsHint;

  /// No description provided for @commCommentsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No comments yet'**
  String get commCommentsEmpty;

  /// No description provided for @commCommentsError.
  ///
  /// In en, this message translates to:
  /// **'Unable to load comments.'**
  String get commCommentsError;

  /// No description provided for @commPostError.
  ///
  /// In en, this message translates to:
  /// **'Unable to create post: {error}'**
  String commPostError(Object error);

  /// No description provided for @catFarmingTips.
  ///
  /// In en, this message translates to:
  /// **'Farming Tips'**
  String get catFarmingTips;

  /// No description provided for @catMarketUpdates.
  ///
  /// In en, this message translates to:
  /// **'Market Updates'**
  String get catMarketUpdates;

  /// No description provided for @catWeatherAlerts.
  ///
  /// In en, this message translates to:
  /// **'Weather Alerts'**
  String get catWeatherAlerts;

  /// No description provided for @catSuccessStories.
  ///
  /// In en, this message translates to:
  /// **'Success Stories'**
  String get catSuccessStories;

  /// No description provided for @catQA.
  ///
  /// In en, this message translates to:
  /// **'Questions & Answers'**
  String get catQA;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @profileEditHint.
  ///
  /// In en, this message translates to:
  /// **'You can edit these anytime from your profile.'**
  String get profileEditHint;

  /// No description provided for @profileTabPersonal.
  ///
  /// In en, this message translates to:
  /// **'Personal Information'**
  String get profileTabPersonal;

  /// No description provided for @profileTabAddress.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get profileTabAddress;

  /// No description provided for @profileLabelName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get profileLabelName;

  /// No description provided for @profileNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your name'**
  String get profileNameHint;

  /// No description provided for @profileLabelVillage.
  ///
  /// In en, this message translates to:
  /// **'Village'**
  String get profileLabelVillage;

  /// No description provided for @profileLabelDistrict.
  ///
  /// In en, this message translates to:
  /// **'District'**
  String get profileLabelDistrict;

  /// No description provided for @selectDistrictHint.
  ///
  /// In en, this message translates to:
  /// **'Select district'**
  String get selectDistrictHint;

  /// No description provided for @profileLabelState.
  ///
  /// In en, this message translates to:
  /// **'State'**
  String get profileLabelState;

  /// No description provided for @stateHint.
  ///
  /// In en, this message translates to:
  /// **'Select state'**
  String get stateHint;

  /// No description provided for @labelTehsil.
  ///
  /// In en, this message translates to:
  /// **'Tehsil'**
  String get labelTehsil;

  /// No description provided for @villageTownHint.
  ///
  /// In en, this message translates to:
  /// **'Type village/town'**
  String get villageTownHint;

  /// No description provided for @totalFarmAreaLabel.
  ///
  /// In en, this message translates to:
  /// **'Total farm area'**
  String get totalFarmAreaLabel;

  /// No description provided for @areaLabel.
  ///
  /// In en, this message translates to:
  /// **'Area'**
  String get areaLabel;

  /// No description provided for @farmAreaHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., 2.5'**
  String get farmAreaHint;

  /// No description provided for @farmEmptyState.
  ///
  /// In en, this message translates to:
  /// **'No crops found.'**
  String get farmEmptyState;

  /// No description provided for @cropStatisticsTitle.
  ///
  /// In en, this message translates to:
  /// **'Crop Statistics'**
  String get cropStatisticsTitle;

  /// No description provided for @totalcropsLabel.
  ///
  /// In en, this message translates to:
  /// **'Total crops'**
  String get totalcropsLabel;

  /// No description provided for @avgYieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Average yield'**
  String get avgYieldLabel;

  /// No description provided for @activeCropsLabel.
  ///
  /// In en, this message translates to:
  /// **'Active crops'**
  String get activeCropsLabel;

  /// No description provided for @readyForHarvestLabel.
  ///
  /// In en, this message translates to:
  /// **'Ready for harvest'**
  String get readyForHarvestLabel;

  /// No description provided for @addCropTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Crop'**
  String get addCropTitle;

  /// No description provided for @cropTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Crop Type'**
  String get cropTypeLabel;

  /// No description provided for @cropTypeHint.
  ///
  /// In en, this message translates to:
  /// **'Select crop type'**
  String get cropTypeHint;

  /// No description provided for @sownAreaLabel.
  ///
  /// In en, this message translates to:
  /// **'Sown Area (acres)'**
  String get sownAreaLabel;

  /// No description provided for @sownAreaHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., 1.5'**
  String get sownAreaHint;

  /// No description provided for @sownAreaHintError.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid area'**
  String get sownAreaHintError;

  /// No description provided for @plantedDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Planted Date'**
  String get plantedDateLabel;

  /// No description provided for @cropLabelHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., Wheat - July Field'**
  String get cropLabelHint;

  /// No description provided for @cropLabelHintError.
  ///
  /// In en, this message translates to:
  /// **'Please enter a crop label'**
  String get cropLabelHintError;

  /// No description provided for @cropSaveError.
  ///
  /// In en, this message translates to:
  /// **'Unable to save crop to server'**
  String get cropSaveError;

  /// No description provided for @addCropSuccessful.
  ///
  /// In en, this message translates to:
  /// **'{cropName} added successfully.'**
  String addCropSuccessful(Object cropName);

  /// No description provided for @profileLabelEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get profileLabelEmail;

  /// No description provided for @profileLabelLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get profileLabelLanguage;

  /// No description provided for @profileNotProvided.
  ///
  /// In en, this message translates to:
  /// **'Not provided'**
  String get profileNotProvided;

  /// No description provided for @profileErrorLoad.
  ///
  /// In en, this message translates to:
  /// **'Unable to load profile'**
  String get profileErrorLoad;

  /// No description provided for @settingsEditProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get settingsEditProfile;

  /// No description provided for @settingsChangePass.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get settingsChangePass;

  /// No description provided for @settingsChangePassDesc.
  ///
  /// In en, this message translates to:
  /// **'Set a new account password'**
  String get settingsChangePassDesc;

  /// No description provided for @settingsForgotPass.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password'**
  String get settingsForgotPass;

  /// No description provided for @settingsForgotPassDesc.
  ///
  /// In en, this message translates to:
  /// **'Send reset link to email'**
  String get settingsForgotPassDesc;

  /// No description provided for @settingsLogout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get settingsLogout;

  /// No description provided for @settingsLogoutDesc.
  ///
  /// In en, this message translates to:
  /// **'Sign out from this device'**
  String get settingsLogoutDesc;

  /// No description provided for @settingsDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete Account (Coming soon)'**
  String get settingsDelete;

  /// No description provided for @formCurrentPass.
  ///
  /// In en, this message translates to:
  /// **'Current Password'**
  String get formCurrentPass;

  /// No description provided for @formNewPass.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get formNewPass;

  /// No description provided for @formConfirmPass.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get formConfirmPass;

  /// No description provided for @formBtnUpdatePass.
  ///
  /// In en, this message translates to:
  /// **'Update Password'**
  String get formBtnUpdatePass;

  /// No description provided for @formMsgPassSuccess.
  ///
  /// In en, this message translates to:
  /// **'Password updated successfully'**
  String get formMsgPassSuccess;

  /// No description provided for @formMsgPassResetSent.
  ///
  /// In en, this message translates to:
  /// **'Password reset link sent to your email'**
  String get formMsgPassResetSent;

  /// No description provided for @formErrorPassMatch.
  ///
  /// In en, this message translates to:
  /// **'New password and confirm password do not match'**
  String get formErrorPassMatch;

  /// No description provided for @formErrorPassLength.
  ///
  /// In en, this message translates to:
  /// **'Minimum 6 characters required'**
  String get formErrorPassLength;

  /// No description provided for @imgPickCamera.
  ///
  /// In en, this message translates to:
  /// **'Take photo'**
  String get imgPickCamera;

  /// No description provided for @imgPickGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from gallery'**
  String get imgPickGallery;

  /// No description provided for @imgPreviewUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Preview unavailable'**
  String get imgPreviewUnavailable;

  /// No description provided for @languageTooltip.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get languageTooltip;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageHindi.
  ///
  /// In en, this message translates to:
  /// **'Hindi'**
  String get languageHindi;

  /// No description provided for @profilePhone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get profilePhone;

  /// No description provided for @diseaseDetectTitle.
  ///
  /// In en, this message translates to:
  /// **'Disease Detection'**
  String get diseaseDetectTitle;

  /// No description provided for @diseaseIntruction.
  ///
  /// In en, this message translates to:
  /// **'Capture or upload crop image'**
  String get diseaseIntruction;

  /// No description provided for @diseaseHint.
  ///
  /// In en, this message translates to:
  /// **'Use clear daylight photos for better accuracy'**
  String get diseaseHint;

  /// No description provided for @cameraLabel.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get cameraLabel;

  /// No description provided for @galleryLabel.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get galleryLabel;
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
      <String>['en', 'hi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'hi':
      return AppLocalizationsHi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
