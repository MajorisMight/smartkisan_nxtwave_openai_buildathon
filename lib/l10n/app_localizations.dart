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

  /// No description provided for @selectLanguageTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguageTitle;

  /// No description provided for @selectLanguagePrompt.
  ///
  /// In en, this message translates to:
  /// **'Please select your preferred language'**
  String get selectLanguagePrompt;

  /// No description provided for @continueButton.
  ///
  /// In en, this message translates to:
  /// **'CONTINUE'**
  String get continueButton;

  /// No description provided for @languageSelectedSnackbar.
  ///
  /// In en, this message translates to:
  /// **'You selected: {languageName}'**
  String languageSelectedSnackbar(Object languageName);

  /// No description provided for @phoneVer.
  ///
  /// In en, this message translates to:
  /// **'Phone Verification'**
  String get phoneVer;

  /// No description provided for @verStatement.
  ///
  /// In en, this message translates to:
  /// **'Enter your mobile number to receive OTP'**
  String get verStatement;

  /// No description provided for @phoneNo.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNo;

  /// No description provided for @sendbtn.
  ///
  /// In en, this message translates to:
  /// **'Send OTP'**
  String get sendbtn;

  /// No description provided for @verifyBtn.
  ///
  /// In en, this message translates to:
  /// **'Verify OTP'**
  String get verifyBtn;

  /// No description provided for @resendBtn.
  ///
  /// In en, this message translates to:
  /// **'Resend OTP'**
  String get resendBtn;

  /// The header label for the current onboarding step
  ///
  /// In en, this message translates to:
  /// **'Step {currentStep}/{totalSteps} • {stepTitle}'**
  String onboardingStepLabel(int currentStep, int totalSteps, String stepTitle);

  /// No description provided for @stepTitleBasicInfo.
  ///
  /// In en, this message translates to:
  /// **'Basic Info'**
  String get stepTitleBasicInfo;

  /// No description provided for @stepTitleLocation.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get stepTitleLocation;

  /// No description provided for @stepTitleCrops.
  ///
  /// In en, this message translates to:
  /// **'Crops'**
  String get stepTitleCrops;

  /// No description provided for @stepTitleSoilAndWater.
  ///
  /// In en, this message translates to:
  /// **'Soil & Water'**
  String get stepTitleSoilAndWater;

  /// No description provided for @stepTitlePastYields.
  ///
  /// In en, this message translates to:
  /// **'Past Yields'**
  String get stepTitlePastYields;

  /// No description provided for @stepTitleFinanceAndFinish.
  ///
  /// In en, this message translates to:
  /// **'Finance & Finish'**
  String get stepTitleFinanceAndFinish;

  /// No description provided for @backButton.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get backButton;

  /// No description provided for @nextButton.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get nextButton;

  /// No description provided for @finishAndGoToDashboardButton.
  ///
  /// In en, this message translates to:
  /// **'Finish & Go to Dashboard'**
  String get finishAndGoToDashboardButton;

  /// No description provided for @languageTooltip.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageTooltip;

  /// No description provided for @tellUsAboutYouTitle.
  ///
  /// In en, this message translates to:
  /// **'Tell us about you'**
  String get tellUsAboutYouTitle;

  /// No description provided for @nameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name (optional)'**
  String get nameLabel;

  /// No description provided for @nameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., Ram Kumar'**
  String get nameHint;

  /// No description provided for @ageRangeLabel.
  ///
  /// In en, this message translates to:
  /// **'Age range *'**
  String get ageRangeLabel;

  /// No description provided for @ageRangeUnder30.
  ///
  /// In en, this message translates to:
  /// **'Under 30'**
  String get ageRangeUnder30;

  /// No description provided for @ageRange30to55.
  ///
  /// In en, this message translates to:
  /// **'30–55'**
  String get ageRange30to55;

  /// No description provided for @ageRangeOver55.
  ///
  /// In en, this message translates to:
  /// **'Over 55'**
  String get ageRangeOver55;

  /// No description provided for @preferredLanguageLabel.
  ///
  /// In en, this message translates to:
  /// **'Preferred language *'**
  String get preferredLanguageLabel;

  /// No description provided for @selectLanguageHint.
  ///
  /// In en, this message translates to:
  /// **'Select language'**
  String get selectLanguageHint;

  /// No description provided for @languageHindi.
  ///
  /// In en, this message translates to:
  /// **'Hindi'**
  String get languageHindi;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageRegional.
  ///
  /// In en, this message translates to:
  /// **'Regional'**
  String get languageRegional;

  /// No description provided for @farmingExperienceLabel.
  ///
  /// In en, this message translates to:
  /// **'Farming experience *'**
  String get farmingExperienceLabel;

  /// No description provided for @selectExperienceHint.
  ///
  /// In en, this message translates to:
  /// **'Select experience'**
  String get selectExperienceHint;

  /// No description provided for @experienceBeginner.
  ///
  /// In en, this message translates to:
  /// **'Beginner <5 yrs'**
  String get experienceBeginner;

  /// No description provided for @experienceIntermediate.
  ///
  /// In en, this message translates to:
  /// **'Intermediate 5–15 yrs'**
  String get experienceIntermediate;

  /// No description provided for @experienceExpert.
  ///
  /// In en, this message translates to:
  /// **'Expert >15 yrs'**
  String get experienceExpert;

  /// No description provided for @casteCategoryLabel.
  ///
  /// In en, this message translates to:
  /// **'Caste/Category (optional)'**
  String get casteCategoryLabel;

  /// No description provided for @selectCasteHint.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get selectCasteHint;

  /// No description provided for @casteGeneral.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get casteGeneral;

  /// No description provided for @casteSC.
  ///
  /// In en, this message translates to:
  /// **'SC'**
  String get casteSC;

  /// No description provided for @casteST.
  ///
  /// In en, this message translates to:
  /// **'ST'**
  String get casteST;

  /// No description provided for @casteOBC.
  ///
  /// In en, this message translates to:
  /// **'OBC'**
  String get casteOBC;

  /// No description provided for @casteOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get casteOther;

  /// No description provided for @castePreferNotToSay.
  ///
  /// In en, this message translates to:
  /// **'Prefer not to say'**
  String get castePreferNotToSay;

  /// No description provided for @farmLocationTitle.
  ///
  /// In en, this message translates to:
  /// **'Farm Location & General Details'**
  String get farmLocationTitle;

  /// No description provided for @useMyLocationButton.
  ///
  /// In en, this message translates to:
  /// **'Use my location'**
  String get useMyLocationButton;

  /// Placeholder for the map preview showing coordinates
  ///
  /// In en, this message translates to:
  /// **'Map preview here ({lat}, {lon})'**
  String mapPreviewPlaceholder(String lat, String lon);

  /// No description provided for @tehsilLabel.
  ///
  /// In en, this message translates to:
  /// **'Tehsil'**
  String get tehsilLabel;

  /// No description provided for @villageTownHint.
  ///
  /// In en, this message translates to:
  /// **'Type village/town'**
  String get villageTownHint;

  /// No description provided for @districtLabel.
  ///
  /// In en, this message translates to:
  /// **'District'**
  String get districtLabel;

  /// No description provided for @selectDistrictHint.
  ///
  /// In en, this message translates to:
  /// **'Select district'**
  String get selectDistrictHint;

  /// No description provided for @stateLabel.
  ///
  /// In en, this message translates to:
  /// **'State'**
  String get stateLabel;

  /// No description provided for @selectStateHint.
  ///
  /// In en, this message translates to:
  /// **'Select state'**
  String get selectStateHint;

  /// No description provided for @totalFarmAreaLabel.
  ///
  /// In en, this message translates to:
  /// **'Total farm area *'**
  String get totalFarmAreaLabel;

  /// No description provided for @farmAreaHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., 2.5'**
  String get farmAreaHint;

  /// No description provided for @areaUnitAcre.
  ///
  /// In en, this message translates to:
  /// **'acre'**
  String get areaUnitAcre;

  /// No description provided for @areaUnitHectare.
  ///
  /// In en, this message translates to:
  /// **'hectare'**
  String get areaUnitHectare;

  /// No description provided for @waterSourceLabel.
  ///
  /// In en, this message translates to:
  /// **'Water source (multi-select)'**
  String get waterSourceLabel;

  /// No description provided for @waterSourceRiver.
  ///
  /// In en, this message translates to:
  /// **'River'**
  String get waterSourceRiver;

  /// No description provided for @waterSourceWell.
  ///
  /// In en, this message translates to:
  /// **'Well'**
  String get waterSourceWell;

  /// No description provided for @waterSourceCanal.
  ///
  /// In en, this message translates to:
  /// **'Canal'**
  String get waterSourceCanal;

  /// No description provided for @waterSourceRainfed.
  ///
  /// In en, this message translates to:
  /// **'Rainfed'**
  String get waterSourceRainfed;

  /// No description provided for @waterSourceBorewell.
  ///
  /// In en, this message translates to:
  /// **'Borewell'**
  String get waterSourceBorewell;

  /// No description provided for @farmerGroupMembershipLabel.
  ///
  /// In en, this message translates to:
  /// **'Farmer group / Co-op membership'**
  String get farmerGroupMembershipLabel;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @groupNameHint.
  ///
  /// In en, this message translates to:
  /// **'Name of group'**
  String get groupNameHint;

  /// No description provided for @cropsAndPracticesTitle.
  ///
  /// In en, this message translates to:
  /// **'Crops & Practices'**
  String get cropsAndPracticesTitle;

  /// No description provided for @primaryCropsLabel.
  ///
  /// In en, this message translates to:
  /// **'Primary crops (multi-select)'**
  String get primaryCropsLabel;

  /// No description provided for @cropWheat.
  ///
  /// In en, this message translates to:
  /// **'Wheat'**
  String get cropWheat;

  /// No description provided for @cropMoong.
  ///
  /// In en, this message translates to:
  /// **'Moong'**
  String get cropMoong;

  /// No description provided for @cropIsabgol.
  ///
  /// In en, this message translates to:
  /// **'Isabogl'**
  String get cropIsabgol;

  /// No description provided for @cropMustard.
  ///
  /// In en, this message translates to:
  /// **'Mustard'**
  String get cropMustard;

  /// No description provided for @cropGroundnut.
  ///
  /// In en, this message translates to:
  /// **'Groundnut'**
  String get cropGroundnut;

  /// No description provided for @cropCotton.
  ///
  /// In en, this message translates to:
  /// **'Cotton'**
  String get cropCotton;

  /// No description provided for @currentFieldStatusLabel.
  ///
  /// In en, this message translates to:
  /// **'Current Status of Field'**
  String get currentFieldStatusLabel;

  /// No description provided for @selectStatusHint.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get selectStatusHint;

  /// No description provided for @fieldStatusPreparing.
  ///
  /// In en, this message translates to:
  /// **'Preparing'**
  String get fieldStatusPreparing;

  /// No description provided for @fieldStatusSowing.
  ///
  /// In en, this message translates to:
  /// **'Sowing'**
  String get fieldStatusSowing;

  /// No description provided for @fieldStatusGrowing.
  ///
  /// In en, this message translates to:
  /// **'Growing'**
  String get fieldStatusGrowing;

  /// No description provided for @fieldStatusHarvesting.
  ///
  /// In en, this message translates to:
  /// **'Harvesting'**
  String get fieldStatusHarvesting;

  /// No description provided for @expectedAcreageLabel.
  ///
  /// In en, this message translates to:
  /// **'Expected acreage for this crop'**
  String get expectedAcreageLabel;

  /// No description provided for @expectedAcreageHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., 1.5'**
  String get expectedAcreageHint;

  /// No description provided for @previousCropLabel.
  ///
  /// In en, this message translates to:
  /// **'Previous crop (last season)'**
  String get previousCropLabel;

  /// No description provided for @selectPreviousCropHint.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get selectPreviousCropHint;

  /// No description provided for @previousCropFallow.
  ///
  /// In en, this message translates to:
  /// **'Fallow'**
  String get previousCropFallow;

  /// No description provided for @previousCropPulses.
  ///
  /// In en, this message translates to:
  /// **'Pulses'**
  String get previousCropPulses;

  /// No description provided for @previousCropMaize.
  ///
  /// In en, this message translates to:
  /// **'Maize'**
  String get previousCropMaize;

  /// No description provided for @previousCropRice.
  ///
  /// In en, this message translates to:
  /// **'Rice'**
  String get previousCropRice;

  /// No description provided for @previousCropOilseeds.
  ///
  /// In en, this message translates to:
  /// **'Oilseeds'**
  String get previousCropOilseeds;

  /// No description provided for @previousCropVegetables.
  ///
  /// In en, this message translates to:
  /// **'Vegetables'**
  String get previousCropVegetables;

  /// No description provided for @previousCropOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get previousCropOther;

  /// No description provided for @soilAndWaterReportsTitle.
  ///
  /// In en, this message translates to:
  /// **'Soil & Water Reports'**
  String get soilAndWaterReportsTitle;

  /// No description provided for @soilTestReportLabel.
  ///
  /// In en, this message translates to:
  /// **'Soil test report (optional)'**
  String get soilTestReportLabel;

  /// No description provided for @uploadPhotoPdfButton.
  ///
  /// In en, this message translates to:
  /// **'Upload Photo / PDF'**
  String get uploadPhotoPdfButton;

  /// No description provided for @enterManuallyButton.
  ///
  /// In en, this message translates to:
  /// **'Enter Manually'**
  String get enterManuallyButton;

  /// No description provided for @nValueLabel.
  ///
  /// In en, this message translates to:
  /// **'N (ppm)'**
  String get nValueLabel;

  /// No description provided for @nValueHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., 120'**
  String get nValueHint;

  /// No description provided for @pValueLabel.
  ///
  /// In en, this message translates to:
  /// **'P (ppm)'**
  String get pValueLabel;

  /// No description provided for @pValueHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., 18'**
  String get pValueHint;

  /// No description provided for @kValueLabel.
  ///
  /// In en, this message translates to:
  /// **'K (ppm)'**
  String get kValueLabel;

  /// No description provided for @kValueHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., 200'**
  String get kValueHint;

  /// No description provided for @phLabel.
  ///
  /// In en, this message translates to:
  /// **'pH (1–14)'**
  String get phLabel;

  /// No description provided for @phHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., 6.8'**
  String get phHint;

  /// No description provided for @organicMatterLabel.
  ///
  /// In en, this message translates to:
  /// **'Organic matter %'**
  String get organicMatterLabel;

  /// No description provided for @organicMatterHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., 1.5'**
  String get organicMatterHint;

  /// No description provided for @lastSoilTestDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Last soil test date'**
  String get lastSoilTestDateLabel;

  /// No description provided for @lastSoilTestDateHint.
  ///
  /// In en, this message translates to:
  /// **'YYYY-MM-DD'**
  String get lastSoilTestDateHint;

  /// No description provided for @waterQualityLabel.
  ///
  /// In en, this message translates to:
  /// **'Water quality'**
  String get waterQualityLabel;

  /// No description provided for @salinityHint.
  ///
  /// In en, this message translates to:
  /// **'Salinity'**
  String get salinityHint;

  /// No description provided for @salinityLow.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get salinityLow;

  /// No description provided for @salinityMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get salinityMedium;

  /// No description provided for @salinityHigh.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get salinityHigh;

  /// No description provided for @waterPhHint.
  ///
  /// In en, this message translates to:
  /// **'Water pH'**
  String get waterPhHint;

  /// No description provided for @bookSoilTestPrompt.
  ///
  /// In en, this message translates to:
  /// **'Book for soil test?'**
  String get bookSoilTestPrompt;

  /// No description provided for @historicalDataTitle.
  ///
  /// In en, this message translates to:
  /// **'Historical Data & Past Yields'**
  String get historicalDataTitle;

  /// Label for entering last season's yield for a specific crop.
  ///
  /// In en, this message translates to:
  /// **'Last season yield — {cropName}'**
  String lastSeasonYieldLabel(String cropName);

  /// No description provided for @yieldValueHint.
  ///
  /// In en, this message translates to:
  /// **'Value'**
  String get yieldValueHint;

  /// No description provided for @yieldUnitHint.
  ///
  /// In en, this message translates to:
  /// **'Unit'**
  String get yieldUnitHint;

  /// No description provided for @yieldUnitKgPerAcre.
  ///
  /// In en, this message translates to:
  /// **'kg/acre'**
  String get yieldUnitKgPerAcre;

  /// No description provided for @yieldUnitQuintalPerAcre.
  ///
  /// In en, this message translates to:
  /// **'quintal/acre'**
  String get yieldUnitQuintalPerAcre;

  /// No description provided for @planningForThisYearLabel.
  ///
  /// In en, this message translates to:
  /// **'What are you planning to grow this year on that place?'**
  String get planningForThisYearLabel;

  /// No description provided for @plannedCropHint.
  ///
  /// In en, this message translates to:
  /// **'Select crop'**
  String get plannedCropHint;

  /// No description provided for @plannedCropNothing.
  ///
  /// In en, this message translates to:
  /// **'Nothing'**
  String get plannedCropNothing;

  /// No description provided for @previousInputsLabel.
  ///
  /// In en, this message translates to:
  /// **'Previous inputs (optional)'**
  String get previousInputsLabel;

  /// No description provided for @inputUrea.
  ///
  /// In en, this message translates to:
  /// **'Urea'**
  String get inputUrea;

  /// No description provided for @inputDAP.
  ///
  /// In en, this message translates to:
  /// **'DAP'**
  String get inputDAP;

  /// No description provided for @inputNPKBlends.
  ///
  /// In en, this message translates to:
  /// **'NPK blends'**
  String get inputNPKBlends;

  /// No description provided for @inputImidacloprid.
  ///
  /// In en, this message translates to:
  /// **'Imidacloprid'**
  String get inputImidacloprid;

  /// No description provided for @inputMancozeb.
  ///
  /// In en, this message translates to:
  /// **'Mancozeb'**
  String get inputMancozeb;

  /// No description provided for @inputOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get inputOther;

  /// No description provided for @historicalWeatherImpactsLabel.
  ///
  /// In en, this message translates to:
  /// **'Historical weather impacts (optional)'**
  String get historicalWeatherImpactsLabel;

  /// No description provided for @impactDrought.
  ///
  /// In en, this message translates to:
  /// **'Drought'**
  String get impactDrought;

  /// No description provided for @impactFlood.
  ///
  /// In en, this message translates to:
  /// **'Flood'**
  String get impactFlood;

  /// No description provided for @impactHeatwave.
  ///
  /// In en, this message translates to:
  /// **'Heatwave'**
  String get impactHeatwave;

  /// No description provided for @impactPestOutbreak.
  ///
  /// In en, this message translates to:
  /// **'Pest outbreak'**
  String get impactPestOutbreak;

  /// No description provided for @impactNone.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get impactNone;

  /// No description provided for @uploadPastFarmPhotosLabel.
  ///
  /// In en, this message translates to:
  /// **'Upload past farm photos or diary scans (optional)'**
  String get uploadPastFarmPhotosLabel;

  /// No description provided for @selectFromGalleryButton.
  ///
  /// In en, this message translates to:
  /// **'Select from gallery'**
  String get selectFromGalleryButton;

  /// No description provided for @usedGovSchemesLabel.
  ///
  /// In en, this message translates to:
  /// **'Government schemes last season?'**
  String get usedGovSchemesLabel;

  /// No description provided for @whichSchemesHint.
  ///
  /// In en, this message translates to:
  /// **'Which schemes?'**
  String get whichSchemesHint;

  /// No description provided for @financeAndFinishTitle.
  ///
  /// In en, this message translates to:
  /// **'Finance & Finish'**
  String get financeAndFinishTitle;

  /// No description provided for @bankAccountLinkedLabel.
  ///
  /// In en, this message translates to:
  /// **'Bank account linked?'**
  String get bankAccountLinkedLabel;

  /// No description provided for @bankNameHint.
  ///
  /// In en, this message translates to:
  /// **'Bank name (optional)'**
  String get bankNameHint;

  /// No description provided for @cropInsuranceEnrolledLabel.
  ///
  /// In en, this message translates to:
  /// **'Crop insurance enrolled?'**
  String get cropInsuranceEnrolledLabel;

  /// No description provided for @insuranceProviderHint.
  ///
  /// In en, this message translates to:
  /// **'Provider (optional)'**
  String get insuranceProviderHint;

  /// No description provided for @annualFarmIncomeLabel.
  ///
  /// In en, this message translates to:
  /// **'Annual farm income range'**
  String get annualFarmIncomeLabel;

  /// No description provided for @selectIncomeHint.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get selectIncomeHint;

  /// No description provided for @incomeLow.
  ///
  /// In en, this message translates to:
  /// **'Low <₹1L'**
  String get incomeLow;

  /// No description provided for @incomeMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium ₹1–5L'**
  String get incomeMedium;

  /// No description provided for @incomeHigh.
  ///
  /// In en, this message translates to:
  /// **'High >₹5L'**
  String get incomeHigh;

  /// No description provided for @preferredPaymentMethodLabel.
  ///
  /// In en, this message translates to:
  /// **'Preferred payment method'**
  String get preferredPaymentMethodLabel;

  /// No description provided for @selectPaymentMethodHint.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get selectPaymentMethodHint;

  /// No description provided for @paymentUPI.
  ///
  /// In en, this message translates to:
  /// **'UPI'**
  String get paymentUPI;

  /// No description provided for @paymentCOD.
  ///
  /// In en, this message translates to:
  /// **'COD'**
  String get paymentCOD;

  /// No description provided for @paymentWallet.
  ///
  /// In en, this message translates to:
  /// **'Wallet'**
  String get paymentWallet;

  /// No description provided for @consentAnalyticsPrompt.
  ///
  /// In en, this message translates to:
  /// **'Receive AI suggestions & upload anonymized data to improve recommendations.'**
  String get consentAnalyticsPrompt;

  /// No description provided for @summaryTitle.
  ///
  /// In en, this message translates to:
  /// **'Summary'**
  String get summaryTitle;

  /// No description provided for @summaryFields.
  ///
  /// In en, this message translates to:
  /// **'Fields'**
  String get summaryFields;

  /// Summary row for a specific crop's acreage.
  ///
  /// In en, this message translates to:
  /// **'{cropName} acreage'**
  String summaryAcreage(String cropName);

  /// No description provided for @summaryPrimaryCrops.
  ///
  /// In en, this message translates to:
  /// **'Primary crops'**
  String get summaryPrimaryCrops;

  /// No description provided for @summaryTotalArea.
  ///
  /// In en, this message translates to:
  /// **'Total area'**
  String get summaryTotalArea;

  /// No description provided for @summarySoilTest.
  ///
  /// In en, this message translates to:
  /// **'Soil test'**
  String get summarySoilTest;

  /// No description provided for @summarySoilTestPresent.
  ///
  /// In en, this message translates to:
  /// **'Present'**
  String get summarySoilTestPresent;

  /// No description provided for @summarySoilTestAbsent.
  ///
  /// In en, this message translates to:
  /// **'Absent'**
  String get summarySoilTestAbsent;

  /// No description provided for @summaryBank.
  ///
  /// In en, this message translates to:
  /// **'Bank'**
  String get summaryBank;

  /// No description provided for @summaryInsurance.
  ///
  /// In en, this message translates to:
  /// **'Insurance'**
  String get summaryInsurance;

  /// No description provided for @termsAcceptedPrompt.
  ///
  /// In en, this message translates to:
  /// **'I agree to terms & privacy'**
  String get termsAcceptedPrompt;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search...'**
  String get searchHint;

  /// No description provided for @addOtherButton.
  ///
  /// In en, this message translates to:
  /// **'Add Other'**
  String get addOtherButton;

  /// No description provided for @cancelButton.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelButton;

  /// No description provided for @addButton.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get addButton;

  /// No description provided for @verifyButton.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get verifyButton;
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
