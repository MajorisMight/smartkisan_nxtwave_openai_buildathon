// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get selectLanguageTitle => 'Select Language';

  @override
  String get selectLanguagePrompt => 'Please select your preferred language';

  @override
  String get continueButton => 'CONTINUE';

  @override
  String languageSelectedSnackbar(Object languageName) {
    return 'You selected: $languageName';
  }

  @override
  String get phoneVer => 'Phone Verification';

  @override
  String get verStatement => 'Enter your mobile number to receive OTP';

  @override
  String get phoneNo => 'Phone Number';

  @override
  String get sendbtn => 'Send OTP';

  @override
  String get verifyBtn => 'Verify OTP';

  @override
  String get resendBtn => 'Resend OTP';

  @override
  String onboardingStepLabel(
    int currentStep,
    int totalSteps,
    String stepTitle,
  ) {
    return 'Step $currentStep/$totalSteps • $stepTitle';
  }

  @override
  String get stepTitleBasicInfo => 'Basic Info';

  @override
  String get stepTitleLocation => 'Location';

  @override
  String get stepTitleCrops => 'Crops';

  @override
  String get stepTitleSoilAndWater => 'Soil & Water';

  @override
  String get stepTitlePastYields => 'Past Yields';

  @override
  String get stepTitleFinanceAndFinish => 'Finance & Finish';

  @override
  String get backButton => 'Back';

  @override
  String get nextButton => 'Next';

  @override
  String get finishAndGoToDashboardButton => 'Finish & Go to Dashboard';

  @override
  String get languageTooltip => 'Language';

  @override
  String get tellUsAboutYouTitle => 'Tell us about you';

  @override
  String get nameLabel => 'Name (optional)';

  @override
  String get nameHint => 'e.g., Ram Kumar';

  @override
  String get ageRangeLabel => 'Age range *';

  @override
  String get ageRangeUnder30 => 'Under 30';

  @override
  String get ageRange30to55 => '30–55';

  @override
  String get ageRangeOver55 => 'Over 55';

  @override
  String get preferredLanguageLabel => 'Preferred language *';

  @override
  String get selectLanguageHint => 'Select language';

  @override
  String get languageHindi => 'Hindi';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageRegional => 'Regional';

  @override
  String get farmingExperienceLabel => 'Farming experience *';

  @override
  String get selectExperienceHint => 'Select experience';

  @override
  String get experienceBeginner => 'Beginner <5 yrs';

  @override
  String get experienceIntermediate => 'Intermediate 5–15 yrs';

  @override
  String get experienceExpert => 'Expert >15 yrs';

  @override
  String get casteCategoryLabel => 'Caste/Category (optional)';

  @override
  String get selectCasteHint => 'Select';

  @override
  String get casteGeneral => 'General';

  @override
  String get casteSC => 'SC';

  @override
  String get casteST => 'ST';

  @override
  String get casteOBC => 'OBC';

  @override
  String get casteOther => 'Other';

  @override
  String get castePreferNotToSay => 'Prefer not to say';

  @override
  String get farmLocationTitle => 'Farm Location & General Details';

  @override
  String get useMyLocationButton => 'Use my location';

  @override
  String mapPreviewPlaceholder(String lat, String lon) {
    return 'Map preview here ($lat, $lon)';
  }

  @override
  String get tehsilLabel => 'Tehsil';

  @override
  String get villageTownHint => 'Type village/town';

  @override
  String get districtLabel => 'District';

  @override
  String get selectDistrictHint => 'Select district';

  @override
  String get stateLabel => 'State';

  @override
  String get selectStateHint => 'Select state';

  @override
  String get totalFarmAreaLabel => 'Total farm area *';

  @override
  String get farmAreaHint => 'e.g., 2.5';

  @override
  String get areaUnitAcre => 'acre';

  @override
  String get areaUnitHectare => 'hectare';

  @override
  String get waterSourceLabel => 'Water source (multi-select)';

  @override
  String get waterSourceRiver => 'River';

  @override
  String get waterSourceWell => 'Well';

  @override
  String get waterSourceCanal => 'Canal';

  @override
  String get waterSourceRainfed => 'Rainfed';

  @override
  String get waterSourceBorewell => 'Borewell';

  @override
  String get farmerGroupMembershipLabel => 'Farmer group / Co-op membership';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get groupNameHint => 'Name of group';

  @override
  String get cropsAndPracticesTitle => 'Crops & Practices';

  @override
  String get primaryCropsLabel => 'Primary crops (multi-select)';

  @override
  String get cropWheat => 'Wheat';

  @override
  String get cropMoong => 'Moong';

  @override
  String get cropIsabgol => 'Isabogl';

  @override
  String get cropMustard => 'Mustard';

  @override
  String get cropGroundnut => 'Groundnut';

  @override
  String get cropCotton => 'Cotton';

  @override
  String get currentFieldStatusLabel => 'Current Status of Field';

  @override
  String get selectStatusHint => 'Select';

  @override
  String get fieldStatusPreparing => 'Preparing';

  @override
  String get fieldStatusSowing => 'Sowing';

  @override
  String get fieldStatusGrowing => 'Growing';

  @override
  String get fieldStatusHarvesting => 'Harvesting';

  @override
  String get expectedAcreageLabel => 'Expected acreage for this crop';

  @override
  String get expectedAcreageHint => 'e.g., 1.5';

  @override
  String get previousCropLabel => 'Previous crop (last season)';

  @override
  String get selectPreviousCropHint => 'Select';

  @override
  String get previousCropFallow => 'Fallow';

  @override
  String get previousCropPulses => 'Pulses';

  @override
  String get previousCropMaize => 'Maize';

  @override
  String get previousCropRice => 'Rice';

  @override
  String get previousCropOilseeds => 'Oilseeds';

  @override
  String get previousCropVegetables => 'Vegetables';

  @override
  String get previousCropOther => 'Other';

  @override
  String get soilAndWaterReportsTitle => 'Soil & Water Reports';

  @override
  String get soilTestReportLabel => 'Soil test report (optional)';

  @override
  String get uploadPhotoPdfButton => 'Upload Photo / PDF';

  @override
  String get enterManuallyButton => 'Enter Manually';

  @override
  String get nValueLabel => 'N (ppm)';

  @override
  String get nValueHint => 'e.g., 120';

  @override
  String get pValueLabel => 'P (ppm)';

  @override
  String get pValueHint => 'e.g., 18';

  @override
  String get kValueLabel => 'K (ppm)';

  @override
  String get kValueHint => 'e.g., 200';

  @override
  String get phLabel => 'pH (1–14)';

  @override
  String get phHint => 'e.g., 6.8';

  @override
  String get organicMatterLabel => 'Organic matter %';

  @override
  String get organicMatterHint => 'e.g., 1.5';

  @override
  String get lastSoilTestDateLabel => 'Last soil test date';

  @override
  String get lastSoilTestDateHint => 'YYYY-MM-DD';

  @override
  String get waterQualityLabel => 'Water quality';

  @override
  String get salinityHint => 'Salinity';

  @override
  String get salinityLow => 'Low';

  @override
  String get salinityMedium => 'Medium';

  @override
  String get salinityHigh => 'High';

  @override
  String get waterPhHint => 'Water pH';

  @override
  String get bookSoilTestPrompt => 'Book for soil test?';

  @override
  String get historicalDataTitle => 'Historical Data & Past Yields';

  @override
  String lastSeasonYieldLabel(String cropName) {
    return 'Last season yield — $cropName';
  }

  @override
  String get yieldValueHint => 'Value';

  @override
  String get yieldUnitHint => 'Unit';

  @override
  String get yieldUnitKgPerAcre => 'kg/acre';

  @override
  String get yieldUnitQuintalPerAcre => 'quintal/acre';

  @override
  String get planningForThisYearLabel =>
      'What are you planning to grow this year on that place?';

  @override
  String get plannedCropHint => 'Select crop';

  @override
  String get plannedCropNothing => 'Nothing';

  @override
  String get previousInputsLabel => 'Previous inputs (optional)';

  @override
  String get inputUrea => 'Urea';

  @override
  String get inputDAP => 'DAP';

  @override
  String get inputNPKBlends => 'NPK blends';

  @override
  String get inputImidacloprid => 'Imidacloprid';

  @override
  String get inputMancozeb => 'Mancozeb';

  @override
  String get inputOther => 'Other';

  @override
  String get historicalWeatherImpactsLabel =>
      'Historical weather impacts (optional)';

  @override
  String get impactDrought => 'Drought';

  @override
  String get impactFlood => 'Flood';

  @override
  String get impactHeatwave => 'Heatwave';

  @override
  String get impactPestOutbreak => 'Pest outbreak';

  @override
  String get impactNone => 'None';

  @override
  String get uploadPastFarmPhotosLabel =>
      'Upload past farm photos or diary scans (optional)';

  @override
  String get selectFromGalleryButton => 'Select from gallery';

  @override
  String get usedGovSchemesLabel => 'Government schemes last season?';

  @override
  String get whichSchemesHint => 'Which schemes?';

  @override
  String get financeAndFinishTitle => 'Finance & Finish';

  @override
  String get bankAccountLinkedLabel => 'Bank account linked?';

  @override
  String get bankNameHint => 'Bank name (optional)';

  @override
  String get cropInsuranceEnrolledLabel => 'Crop insurance enrolled?';

  @override
  String get insuranceProviderHint => 'Provider (optional)';

  @override
  String get annualFarmIncomeLabel => 'Annual farm income range';

  @override
  String get selectIncomeHint => 'Select';

  @override
  String get incomeLow => 'Low <₹1L';

  @override
  String get incomeMedium => 'Medium ₹1–5L';

  @override
  String get incomeHigh => 'High >₹5L';

  @override
  String get preferredPaymentMethodLabel => 'Preferred payment method';

  @override
  String get selectPaymentMethodHint => 'Select';

  @override
  String get paymentUPI => 'UPI';

  @override
  String get paymentCOD => 'COD';

  @override
  String get paymentWallet => 'Wallet';

  @override
  String get consentAnalyticsPrompt =>
      'Receive AI suggestions & upload anonymized data to improve recommendations.';

  @override
  String get summaryTitle => 'Summary';

  @override
  String get summaryFields => 'Fields';

  @override
  String summaryAcreage(String cropName) {
    return '$cropName acreage';
  }

  @override
  String get summaryPrimaryCrops => 'Primary crops';

  @override
  String get summaryTotalArea => 'Total area';

  @override
  String get summarySoilTest => 'Soil test';

  @override
  String get summarySoilTestPresent => 'Present';

  @override
  String get summarySoilTestAbsent => 'Absent';

  @override
  String get summaryBank => 'Bank';

  @override
  String get summaryInsurance => 'Insurance';

  @override
  String get termsAcceptedPrompt => 'I agree to terms & privacy';

  @override
  String get searchHint => 'Search...';

  @override
  String get addOtherButton => 'Add Other';

  @override
  String get cancelButton => 'Cancel';

  @override
  String get addButton => 'Add';

  @override
  String get verifyButton => 'Verify';
}
