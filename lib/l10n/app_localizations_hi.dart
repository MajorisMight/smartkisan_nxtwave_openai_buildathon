// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get selectLanguageTitle => 'भाषा चुनें';

  @override
  String get selectLanguagePrompt => 'कृपया अपनी पसंदीदा भाषा चुनें';

  @override
  String get continueButton => 'जारी रखें';

  @override
  String languageSelectedSnackbar(Object languageName) {
    return 'आपने चुना: $languageName';
  }

  @override
  String get phoneVer => 'फ़ोन सत्यापन';

  @override
  String get verStatement =>
      'ओटीपी प्राप्त करने के लिए अपना मोबाइल नंबर दर्ज करें';

  @override
  String get phoneNo => 'फ़ोन नंबर';

  @override
  String get sendbtn => 'ओटीपी भेजें';

  @override
  String get verifyBtn => 'ओटीपी सत्यापित करें';

  @override
  String get resendBtn => 'ओटीपी फिर से भेजें';

  @override
  String onboardingStepLabel(
    int currentStep,
    int totalSteps,
    String stepTitle,
  ) {
    return 'चरण $currentStep/$totalSteps • $stepTitle';
  }

  @override
  String get stepTitleBasicInfo => 'मूल जानकारी';

  @override
  String get stepTitleLocation => 'स्थान';

  @override
  String get stepTitleCrops => 'फसलें';

  @override
  String get stepTitleSoilAndWater => 'मिट्टी और पानी';

  @override
  String get stepTitlePastYields => 'पिछली पैदावार';

  @override
  String get stepTitleFinanceAndFinish => 'वित्त और समाप्त';

  @override
  String get backButton => 'वापस';

  @override
  String get nextButton => 'अगला';

  @override
  String get finishAndGoToDashboardButton => 'समाप्त करें और डैशबोर्ड पर जाएं';

  @override
  String get languageTooltip => 'भाषा';

  @override
  String get tellUsAboutYouTitle => 'हमें अपने बारे में बताएं';

  @override
  String get nameLabel => 'नाम (वैकल्पिक)';

  @override
  String get nameHint => 'उदा., राम कुमार';

  @override
  String get ageRangeLabel => 'आयु सीमा *';

  @override
  String get ageRangeUnder30 => '30 से कम';

  @override
  String get ageRange30to55 => '30-55';

  @override
  String get ageRangeOver55 => '55 से अधिक';

  @override
  String get preferredLanguageLabel => 'पसंदीदा भाषा *';

  @override
  String get selectLanguageHint => 'भाषा चुनें';

  @override
  String get languageHindi => 'हिन्दी';

  @override
  String get languageEnglish => 'अंग्रेज़ी';

  @override
  String get languageRegional => 'क्षेत्रीय';

  @override
  String get farmingExperienceLabel => 'खेती का अनुभव *';

  @override
  String get selectExperienceHint => 'अनुभव चुनें';

  @override
  String get experienceBeginner => 'शुरुआती <5 वर्ष';

  @override
  String get experienceIntermediate => 'मध्यम 5-15 वर्ष';

  @override
  String get experienceExpert => 'विशेषज्ञ >15 वर्ष';

  @override
  String get casteCategoryLabel => 'जाति/श्रेणी (वैकल्पिक)';

  @override
  String get selectCasteHint => 'चुनें';

  @override
  String get casteGeneral => 'सामान्य';

  @override
  String get casteSC => 'अनुसूचित जाति';

  @override
  String get casteST => 'अनुसूचित जनजाति';

  @override
  String get casteOBC => 'अन्य पिछड़ा वर्ग';

  @override
  String get casteOther => 'अन्य';

  @override
  String get castePreferNotToSay => 'बताना नहीं चाहते';

  @override
  String get farmLocationTitle => 'खेत का स्थान और सामान्य विवरण';

  @override
  String get useMyLocationButton => 'मेरे स्थान का उपयोग करें';

  @override
  String mapPreviewPlaceholder(String lat, String lon) {
    return 'मानचित्र पूर्वावलोकन यहाँ ($lat, $lon)';
  }

  @override
  String get tehsilLabel => 'गाँव / कस्बा';

  @override
  String get villageTownHint => 'गाँव/कस्बा टाइप करें';

  @override
  String get districtLabel => 'ज़िला';

  @override
  String get selectDistrictHint => 'ज़िला चुनें';

  @override
  String get stateLabel => 'राज्य';

  @override
  String get selectStateHint => 'राज्य चुनें';

  @override
  String get totalFarmAreaLabel => 'कुल खेत का क्षेत्रफल *';

  @override
  String get farmAreaHint => 'उदा., 2.5';

  @override
  String get areaUnitAcre => 'एकड़';

  @override
  String get areaUnitHectare => 'हेक्टेयर';

  @override
  String get waterSourceLabel => 'पानी का स्रोत (एकाधिक चुनें)';

  @override
  String get waterSourceRiver => 'नदी';

  @override
  String get waterSourceWell => 'कुआँ';

  @override
  String get waterSourceCanal => 'नहर';

  @override
  String get waterSourceRainfed => 'वर्षा';

  @override
  String get waterSourceBorewell => 'बोरवेल';

  @override
  String get farmerGroupMembershipLabel =>
      'किसान समूह / सहकारी समिति की सदस्यता';

  @override
  String get yes => 'हाँ';

  @override
  String get no => 'नहीं';

  @override
  String get groupNameHint => 'समूह का नाम';

  @override
  String get cropsAndPracticesTitle => 'फसलें और प्रथाएँ';

  @override
  String get primaryCropsLabel => 'मुख्य फसलें (एकाधिक चुनें)';

  @override
  String get cropWheat => 'गेहूँ';

  @override
  String get cropMoong => 'मूँग';

  @override
  String get cropIsabgol => 'इसबगोल';

  @override
  String get cropMustard => 'सरसों';

  @override
  String get cropGroundnut => 'मूँगफली';

  @override
  String get cropCotton => 'कपास';

  @override
  String get currentFieldStatusLabel => 'खेत की वर्तमान स्थिति';

  @override
  String get selectStatusHint => 'स्थिति चुनें';

  @override
  String get fieldStatusPreparing => 'तैयारी';

  @override
  String get fieldStatusSowing => 'बुवाई';

  @override
  String get fieldStatusGrowing => 'बढ़वार';

  @override
  String get fieldStatusHarvesting => 'कटाई';

  @override
  String get expectedAcreageLabel => 'इस फसल के लिए अपेक्षित रकबा';

  @override
  String get expectedAcreageHint => 'उदा., 1.5';

  @override
  String get previousCropLabel => 'पिछली फसल (पिछला मौसम)';

  @override
  String get selectPreviousCropHint => 'पिछली फसल चुनें';

  @override
  String get previousCropFallow => 'परती';

  @override
  String get previousCropPulses => 'दालें';

  @override
  String get previousCropMaize => 'मक्का';

  @override
  String get previousCropRice => 'चावल';

  @override
  String get previousCropOilseeds => 'तिलहन';

  @override
  String get previousCropVegetables => 'सब्जियाँ';

  @override
  String get previousCropOther => 'अन्य';

  @override
  String get soilAndWaterReportsTitle => 'मिट्टी और पानी की रिपोर्ट';

  @override
  String get soilTestReportLabel => 'मिट्टी परीक्षण रिपोर्ट (वैकल्पिक)';

  @override
  String get uploadPhotoPdfButton => 'फोटो / पीडीएफ अपलोड करें';

  @override
  String get enterManuallyButton => 'मैन्युअल रूप से दर्ज करें';

  @override
  String get nValueLabel => 'नाइट्रोजन (ppm)';

  @override
  String get nValueHint => 'उदा., 120';

  @override
  String get pValueLabel => 'फॉस्फोरस (ppm)';

  @override
  String get pValueHint => 'उदा., 18';

  @override
  String get kValueLabel => 'पोटेशियम (ppm)';

  @override
  String get kValueHint => 'उदा., 200';

  @override
  String get phLabel => 'पीएच (1-14)';

  @override
  String get phHint => 'उदा., 6.8';

  @override
  String get organicMatterLabel => 'जैविक पदार्थ %';

  @override
  String get organicMatterHint => 'उदा., 1.5';

  @override
  String get lastSoilTestDateLabel => 'पिछली मिट्टी परीक्षण की तारीख';

  @override
  String get lastSoilTestDateHint => 'YYYY-MM-DD';

  @override
  String get waterQualityLabel => 'पानी की गुणवत्ता';

  @override
  String get salinityHint => 'खारापन';

  @override
  String get salinityLow => 'कम';

  @override
  String get salinityMedium => 'मध्यम';

  @override
  String get salinityHigh => 'अधिक';

  @override
  String get waterPhHint => 'पानी का पीएच';

  @override
  String get bookSoilTestPrompt => 'मिट्टी परीक्षण के लिए बुक करें?';

  @override
  String get historicalDataTitle => 'ऐतिहासिक डेटा और पिछली पैदावार';

  @override
  String lastSeasonYieldLabel(String cropName) {
    return 'पिछले मौसम की पैदावार — $cropName';
  }

  @override
  String get yieldValueHint => 'मात्रा';

  @override
  String get yieldUnitHint => 'इकाई';

  @override
  String get yieldUnitKgPerAcre => 'किग्रा/एकड़';

  @override
  String get yieldUnitQuintalPerAcre => 'क्विंटल/एकड़';

  @override
  String get planningForThisYearLabel =>
      'आप इस साल उस जगह पर क्या उगाने की योजना बना रहे हैं?';

  @override
  String get plannedCropHint => 'फसल चुनें';

  @override
  String get plannedCropNothing => 'कुछ नहीं';

  @override
  String get previousInputsLabel => 'पिछली लागतें (वैकल्पिक)';

  @override
  String get inputUrea => 'यूरिया';

  @override
  String get inputDAP => 'डीएपी';

  @override
  String get inputNPKBlends => 'एनपीके मिश्रण';

  @override
  String get inputImidacloprid => 'इमिडाक्लोप्रिड';

  @override
  String get inputMancozeb => 'मैन्कोज़ेब';

  @override
  String get inputOther => 'अन्य';

  @override
  String get historicalWeatherImpactsLabel => 'ऐतिहासिक मौसम प्रभाव (वैकल्पिक)';

  @override
  String get impactDrought => 'सूखा';

  @override
  String get impactFlood => 'बाढ़';

  @override
  String get impactHeatwave => 'लू';

  @override
  String get impactPestOutbreak => 'कीट प्रकोप';

  @override
  String get impactNone => 'कोई नहीं';

  @override
  String get uploadPastFarmPhotosLabel =>
      'पिछले खेत की तस्वीरें या डायरी स्कैन अपलोड करें (वैकल्पिक)';

  @override
  String get selectFromGalleryButton => 'गैलरी से चुनें';

  @override
  String get usedGovSchemesLabel => 'पिछले मौसम में सरकारी योजनाएं उपयोग कीं?';

  @override
  String get whichSchemesHint => 'कौन सी योजनाएं?';

  @override
  String get financeAndFinishTitle => 'वित्त और समाप्त';

  @override
  String get bankAccountLinkedLabel => 'बैंक खाता लिंक है?';

  @override
  String get bankNameHint => 'बैंक का नाम (वैकल्पिक)';

  @override
  String get cropInsuranceEnrolledLabel => 'फसल बीमा में नामांकित हैं?';

  @override
  String get insuranceProviderHint => 'प्रदाता (वैकल्पिक)';

  @override
  String get annualFarmIncomeLabel => 'वार्षिक कृषि आय सीमा';

  @override
  String get selectIncomeHint => 'आय सीमा चुनें';

  @override
  String get incomeLow => 'कम <₹1 लाख';

  @override
  String get incomeMedium => 'मध्यम ₹1-5 लाख';

  @override
  String get incomeHigh => 'अधिक >₹5 लाख';

  @override
  String get preferredPaymentMethodLabel => 'पसंदीदा भुगतान विधि';

  @override
  String get selectPaymentMethodHint => 'भुगतान विधि चुनें';

  @override
  String get paymentUPI => 'यूपीआई';

  @override
  String get paymentCOD => 'कैश ऑन डिलीवरी';

  @override
  String get paymentWallet => 'वॉलेट';

  @override
  String get consentAnalyticsPrompt =>
      'AI सुझाव प्राप्त करें और अनुशंसाओं को बेहतर बनाने के लिए अनाम डेटा अपलोड करें।';

  @override
  String get summaryTitle => 'सारांश';

  @override
  String get summaryFields => 'खेत';

  @override
  String summaryAcreage(String cropName) {
    return '$cropName रकबा';
  }

  @override
  String get summaryPrimaryCrops => 'मुख्य फसलें';

  @override
  String get summaryTotalArea => 'कुल क्षेत्रफल';

  @override
  String get summarySoilTest => 'मिट्टी परीक्षण';

  @override
  String get summarySoilTestPresent => 'उपस्थित';

  @override
  String get summarySoilTestAbsent => 'अनुपस्थित';

  @override
  String get summaryBank => 'बैंक';

  @override
  String get summaryInsurance => 'बीमा';

  @override
  String get termsAcceptedPrompt => 'मैं नियमों और गोपनीयता नीति से सहमत हूँ';

  @override
  String get searchHint => 'खोजें...';

  @override
  String get addOtherButton => 'अन्य जोड़ें';

  @override
  String get cancelButton => 'रद्द करें';

  @override
  String get addButton => 'जोड़ें';

  @override
  String get verifyButton => 'सत्यापित करें';
}
