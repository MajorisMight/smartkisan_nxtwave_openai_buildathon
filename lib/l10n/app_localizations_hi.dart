// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get selectLanguagePrompt => 'कृपया अपनी पसंदीदा भाषा चुनें';

  @override
  String get selectLanguageTitle => 'भाषा चुनें';

  @override
  String languageSelectedSnackbar(Object languageName) {
    return 'आपने चुना: $languageName';
  }

  @override
  String get btnSave => 'सहेजें';

  @override
  String get btnContinue => 'जारी रखें';

  @override
  String get btnSaving => 'सहेजा जा रहा है...';

  @override
  String get btnPosting => 'पोस्ट हो रहा है...';

  @override
  String get btnPost => 'पोस्ट करें';

  @override
  String get btnCancel => 'रद्द करें';

  @override
  String get btnClose => 'बंद करें';

  @override
  String get btnView => 'देखें';

  @override
  String get btnViewAll => 'सभी देखें';

  @override
  String get btnRetry => 'पुनः प्रयास करें';

  @override
  String get btnRefresh => 'ताज़ा करें';

  @override
  String get lblComingSoon => 'जल्द आ रहा है';

  @override
  String get lblSearch => 'खोजें...';

  @override
  String get lblLoading => 'लोड हो रहा है...';

  @override
  String get navHome => 'होम';

  @override
  String get navMarketplace => 'बाज़ार';

  @override
  String get navWeather => 'मौसम';

  @override
  String get navCommunity => 'समुदाय';

  @override
  String get navProfile => 'प्रोफ़ाइल';

  @override
  String get homeGreeting => 'सुप्रभात!';

  @override
  String get homeDefaultName => 'किसान';

  @override
  String get homeDefaultFarm => 'खेत सेट नहीं है';

  @override
  String get homeQuickStatsSales => 'कुल बिक्री';

  @override
  String get homeQuickStatsOrders => 'सक्रिय ऑर्डर';

  @override
  String get homeQuickStatsProducts => 'उत्पाद';

  @override
  String get homeQuickActionsTitle => 'त्वरित कार्य';

  @override
  String get homeActionCrops => 'मेरी फसलें';

  @override
  String get homeActionCropsDesc => 'खेतों और फसल स्वास्थ्य को ट्रैक करें';

  @override
  String get homeActionFertilizer => 'उर्वरक योजना';

  @override
  String get homeActionFertilizerDesc => 'बुवाई पूर्व पोषक तत्व योजना';

  @override
  String get homeActionSuggestions => 'फसल सुझाव';

  @override
  String get homeActionSuggestionsDesc => 'AI द्वारा फसल योजना';

  @override
  String get homeActionDisease => 'रोग पहचान';

  @override
  String get homeActionSchemes => 'सरकारी योजनाएं';

  @override
  String get homeRecentOrders => 'हाल के ऑर्डर';

  @override
  String get homeCommunityUpdates => 'समुदाय अपडेट';

  @override
  String get marketTitle => 'बाज़ार';

  @override
  String get marketSubtitle => 'कृषि उत्पाद खरीदें और बेचें';

  @override
  String get marketSearchHint => 'उत्पाद खोजें...';

  @override
  String get marketLabelOrganic => 'जैविक';

  @override
  String get marketNoDescription => 'कोई विवरण नहीं जोड़ा गया।';

  @override
  String marketLabelStock(Object quantity, Object unit) {
    return 'स्टॉक: $quantity $unit';
  }

  @override
  String get weightUnitKg => 'किग्रा';

  @override
  String get weightUnitTon => 'टन';

  @override
  String get weightUnitQuintal => 'क्विंटल';

  @override
  String get weightUnitPiece => 'नग';

  @override
  String get weightUnitBag => 'बोरी';

  @override
  String get unitLabel => 'इकाई';

  @override
  String get marketEmptyState => 'कोई उत्पाद नहीं मिला';

  @override
  String get marketErrorLoad => 'उत्पाद लोड करने में असमर्थ।';

  @override
  String get addProductTitle => 'उत्पाद जोड़ें';

  @override
  String get addProductLabelName => 'नाम';

  @override
  String get addProductLabelDesc => 'विवरण';

  @override
  String get addProductLabelPrice => 'कीमत';

  @override
  String get addProductLabelStock => 'स्टॉक मात्रा';

  @override
  String get addProductLabelCategory => 'श्रेणी';

  @override
  String get addProductLabelUnit => 'इकाई';

  @override
  String get addProductCheckboxOrganic => 'जैविक उत्पाद';

  @override
  String get addProductBtnAddPhoto => 'फोटो जोड़ें';

  @override
  String get addProductBtnChangePhoto => 'फोटो बदलें';

  @override
  String get addProductMsgSuccess => 'उत्पाद सफलतापूर्वक जोड़ा गया।';

  @override
  String addProductMsgError(Object error) {
    return 'उत्पाद जोड़ने में असमर्थ: $error';
  }

  @override
  String get addProductMsgRequired => 'नाम, कीमत और स्टॉक आवश्यक हैं।';

  @override
  String get catAll => 'सभी';

  @override
  String get catFertilizers => 'उर्वरक';

  @override
  String get catSeeds => 'बीज';

  @override
  String get catPesticides => 'कीटनाशक';

  @override
  String get catEquipment => 'उपकरण';

  @override
  String get catOrganic => 'जैविक';

  @override
  String get commTitle => 'समुदाय';

  @override
  String get commSubtitle => 'साथी किसानों से जुड़ें';

  @override
  String get commSearchHint => 'पोस्ट खोजें...';

  @override
  String get commEmptyState => 'कोई पोस्ट नहीं मिली';

  @override
  String get commErrorLoad => 'पोस्ट लोड करने में असमर्थ।';

  @override
  String get commBtnCreate => 'नई पोस्ट बनाएं';

  @override
  String get commDialogTitle => 'नई पोस्ट बनाएं';

  @override
  String get commLabelTitle => 'शीर्षक';

  @override
  String get commLabelContent => 'सामग्री';

  @override
  String get commLabelTags => 'टैग (अल्पविराम से अलग करें)';

  @override
  String get commBtnAddPhoto => 'फोटो जोड़ें';

  @override
  String get commBtnChangePhoto => 'फोटो बदलें';

  @override
  String get commMsgSuccess => 'पोस्ट सफलतापूर्वक बनाई गई।';

  @override
  String get commMsgRequired => 'शीर्षक और सामग्री आवश्यक हैं।';

  @override
  String get commCommentsTitle => 'टिप्पणियाँ';

  @override
  String get commCommentsHint => 'एक टिप्पणी लिखें...';

  @override
  String get commCommentsEmpty => 'अभी तक कोई टिप्पणी नहीं';

  @override
  String get commCommentsError => 'टिप्पणियाँ लोड करने में असमर्थ।';

  @override
  String commPostError(Object error) {
    return 'पोस्ट बनाने में असमर्थ: $error';
  }

  @override
  String get catFarmingTips => 'खेती के टिप्स';

  @override
  String get catMarketUpdates => 'बाज़ार अपडेट';

  @override
  String get catWeatherAlerts => 'मौसम अलर्ट';

  @override
  String get catSuccessStories => 'सफलता की कहानियां';

  @override
  String get catQA => 'प्रश्न और उत्तर';

  @override
  String get profileTitle => 'प्रोफ़ाइल';

  @override
  String get profileEditHint =>
      'आप इन्हें अपनी प्रोफ़ाइल से कभी भी संपादित कर सकते हैं।';

  @override
  String get profileTabPersonal => 'व्यक्तिगत जानकारी';

  @override
  String get profileTabAddress => 'पता';

  @override
  String get profileLabelName => 'नाम';

  @override
  String get profileNameHint => 'अपना नाम दर्ज करें';

  @override
  String get profileLabelVillage => 'गाँव';

  @override
  String get profileLabelDistrict => 'ज़िला';

  @override
  String get selectDistrictHint => 'ज़िला चुनें';

  @override
  String get profileLabelState => 'राज्य';

  @override
  String get stateHint => 'राज्य चुनें';

  @override
  String get labelTehsil => 'तहसील';

  @override
  String get villageTownHint => 'गाँव/कस्बा टाइप करें';

  @override
  String get totalFarmAreaLabel => 'कुल खेत क्षेत्र';

  @override
  String get areaLabel => 'क्षेत्रफल';

  @override
  String get farmAreaHint => 'उदाहरण: 2.5';

  @override
  String get farmEmptyState => 'कोई फसल नहीं मिली।';

  @override
  String get cropStatisticsTitle => 'फसल आंकड़े';

  @override
  String get totalcropsLabel => 'कुल फसलें';

  @override
  String get avgYieldLabel => 'औसत उपज';

  @override
  String get activeCropsLabel => 'सक्रिय फसलें';

  @override
  String get readyForHarvestLabel => 'कटाई के लिए तैयार';

  @override
  String get addCropTitle => 'फसल जोड़ें';

  @override
  String get cropTypeLabel => 'फसल का प्रकार';

  @override
  String get cropTypeHint => 'फसल प्रकार चुनें';

  @override
  String get sownAreaLabel => 'बोया गया क्षेत्र (एकड़)';

  @override
  String get sownAreaHint => 'उदाहरण: 1.5';

  @override
  String get sownAreaHintError => 'कृपया मान्य क्षेत्र दर्ज करें';

  @override
  String get plantedDateLabel => 'रोपण की तारीख';

  @override
  String get cropLabelHint => 'उदाहरण: गेहूं - जुलाई खेत';

  @override
  String get cropLabelHintError => 'कृपया फसल लेबल दर्ज करें';

  @override
  String get cropSaveError => 'सर्वर पर फसल सहेजने में असमर्थ';

  @override
  String addCropSuccessful(Object cropName) {
    return '$cropName सफलतापूर्वक जोड़ी गई।';
  }

  @override
  String get profileLabelEmail => 'ईमेल';

  @override
  String get profileLabelLanguage => 'भाषा';

  @override
  String get profileNotProvided => 'उपलब्ध नहीं';

  @override
  String get profileErrorLoad => 'प्रोफ़ाइल लोड करने में असमर्थ';

  @override
  String get settingsEditProfile => 'प्रोफ़ाइल संपादित करें';

  @override
  String get settingsChangePass => 'पासवर्ड बदलें';

  @override
  String get settingsChangePassDesc => 'नया पासवर्ड सेट करें';

  @override
  String get settingsForgotPass => 'पासवर्ड भूल गए';

  @override
  String get settingsForgotPassDesc => 'ईमेल पर रीसेट लिंक भेजें';

  @override
  String get settingsLogout => 'लॉग आउट';

  @override
  String get settingsLogoutDesc => 'इस डिवाइस से साइन आउट करें';

  @override
  String get settingsDelete => 'खाता हटाएं (जल्द आ रहा है)';

  @override
  String get formCurrentPass => 'वर्तमान पासवर्ड';

  @override
  String get formNewPass => 'नया पासवर्ड';

  @override
  String get formConfirmPass => 'पासवर्ड की पुष्टि करें';

  @override
  String get formBtnUpdatePass => 'पासवर्ड अपडेट करें';

  @override
  String get formMsgPassSuccess => 'पासवर्ड सफलतापूर्वक अपडेट किया गया';

  @override
  String get formMsgPassResetSent => 'पासवर्ड रीसेट लिंक आपके ईमेल पर भेजा गया';

  @override
  String get formErrorPassMatch =>
      'नया पासवर्ड और पुष्टि पासवर्ड मेल नहीं खाते';

  @override
  String get formErrorPassLength => 'न्यूनतम 6 अक्षर आवश्यक हैं';

  @override
  String get imgPickCamera => 'फोटो लें';

  @override
  String get imgPickGallery => 'गैलरी से चुनें';

  @override
  String get imgPreviewUnavailable => 'पूर्वावलोकन उपलब्ध नहीं है';

  @override
  String get languageTooltip => 'भाषा चुनें';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageHindi => 'हिंदी';

  @override
  String get profilePhone => 'फ़ोन';

  @override
  String get diseaseDetectTitle => 'रोग पहचान';

  @override
  String get diseaseIntruction => 'फसल की फोटो लें या अपलोड करें';

  @override
  String get diseaseHint => 'बेहतर सटीकता के लिए दिन के उजाले में साफ फोटो लें';

  @override
  String get cameraLabel => 'कैमरा';

  @override
  String get galleryLabel => 'गैलरी';
}
