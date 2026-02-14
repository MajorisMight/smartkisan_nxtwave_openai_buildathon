// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get selectLanguagePrompt => 'Please select your preferred language';

  @override
  String get selectLanguageTitle => 'Select Language';

  @override
  String languageSelectedSnackbar(Object languageName) {
    return 'You selected: $languageName';
  }

  @override
  String get btnSave => 'Save';

  @override
  String get btnContinue => 'Continue';

  @override
  String get btnSaving => 'Saving...';

  @override
  String get btnPosting => 'Posting...';

  @override
  String get btnPost => 'Post';

  @override
  String get btnCancel => 'Cancel';

  @override
  String get btnClose => 'Close';

  @override
  String get btnView => 'View';

  @override
  String get btnViewAll => 'View All';

  @override
  String get btnRetry => 'Retry';

  @override
  String get btnRefresh => 'Refresh';

  @override
  String get lblComingSoon => 'Coming soon';

  @override
  String get lblSearch => 'Search...';

  @override
  String get lblLoading => 'Loading...';

  @override
  String get navHome => 'Home';

  @override
  String get navMarketplace => 'Marketplace';

  @override
  String get navWeather => 'Weather';

  @override
  String get navCommunity => 'Community';

  @override
  String get navProfile => 'Profile';

  @override
  String get homeGreeting => 'Good Morning!';

  @override
  String get homeDefaultName => 'Farmer';

  @override
  String get homeDefaultFarm => 'Farm not set';

  @override
  String get homeQuickStatsSales => 'Total Sales';

  @override
  String get homeQuickStatsOrders => 'Active Orders';

  @override
  String get homeQuickStatsProducts => 'Products';

  @override
  String get homeQuickActionsTitle => 'Quick Actions';

  @override
  String get homeActionCrops => 'My Crops';

  @override
  String get homeActionCropsDesc => 'Track fields and crop health';

  @override
  String get homeActionFertilizer => 'Baseline Fertilizer';

  @override
  String get homeActionFertilizerDesc =>
      'Pre-planting nutrient baseline planner';

  @override
  String get homeActionSuggestions => 'Crop Suggestions';

  @override
  String get homeActionSuggestionsDesc =>
      'AI crop plan using backend farm data';

  @override
  String get homeActionDisease => 'Disease Detection';

  @override
  String get homeActionSchemes => 'Govt Schemes';

  @override
  String get homeRecentOrders => 'Recent Orders';

  @override
  String get homeCommunityUpdates => 'Community Updates';

  @override
  String get marketTitle => 'Marketplace';

  @override
  String get marketSubtitle => 'Buy & Sell Agricultural Products';

  @override
  String get marketSearchHint => 'Search products...';

  @override
  String get marketLabelOrganic => 'ORGANIC';

  @override
  String get marketNoDescription => 'No description added.';

  @override
  String marketLabelStock(Object quantity, Object unit) {
    return 'Stock: $quantity $unit';
  }

  @override
  String get weightUnitKg => 'kg';

  @override
  String get weightUnitTon => 'ton';

  @override
  String get weightUnitQuintal => 'quintal';

  @override
  String get weightUnitPiece => 'piece';

  @override
  String get weightUnitBag => 'bag';

  @override
  String get unitLabel => 'Unit';

  @override
  String get marketEmptyState => 'No products found';

  @override
  String get marketErrorLoad => 'Unable to load products.';

  @override
  String get addProductTitle => 'Add Product';

  @override
  String get addProductLabelName => 'Name';

  @override
  String get addProductLabelDesc => 'Description';

  @override
  String get addProductLabelPrice => 'Price';

  @override
  String get addProductLabelStock => 'Stock Quantity';

  @override
  String get addProductLabelCategory => 'Category';

  @override
  String get addProductLabelUnit => 'Unit';

  @override
  String get addProductCheckboxOrganic => 'Organic product';

  @override
  String get addProductBtnAddPhoto => 'Add Product Photo';

  @override
  String get addProductBtnChangePhoto => 'Change Product Photo';

  @override
  String get addProductMsgSuccess => 'Product added successfully.';

  @override
  String addProductMsgError(Object error) {
    return 'Unable to add product: $error';
  }

  @override
  String get addProductMsgRequired => 'Name, price and stock are required.';

  @override
  String get catAll => 'All';

  @override
  String get catFertilizers => 'Fertilizers';

  @override
  String get catSeeds => 'Seeds';

  @override
  String get catPesticides => 'Pesticides';

  @override
  String get catEquipment => 'Equipment';

  @override
  String get catOrganic => 'Organic';

  @override
  String get commTitle => 'Community';

  @override
  String get commSubtitle => 'Connect with Fellow Farmers';

  @override
  String get commSearchHint => 'Search posts...';

  @override
  String get commEmptyState => 'No posts found';

  @override
  String get commErrorLoad => 'Unable to load posts.';

  @override
  String get commBtnCreate => 'Create New Post';

  @override
  String get commDialogTitle => 'Create New Post';

  @override
  String get commLabelTitle => 'Title';

  @override
  String get commLabelContent => 'Content';

  @override
  String get commLabelTags => 'Tags (comma separated)';

  @override
  String get commBtnAddPhoto => 'Add Post Photo';

  @override
  String get commBtnChangePhoto => 'Change Post Photo';

  @override
  String get commMsgSuccess => 'Post created successfully.';

  @override
  String get commMsgRequired => 'Title and content are required.';

  @override
  String get commCommentsTitle => 'Comments';

  @override
  String get commCommentsHint => 'Write a comment...';

  @override
  String get commCommentsEmpty => 'No comments yet';

  @override
  String get commCommentsError => 'Unable to load comments.';

  @override
  String commPostError(Object error) {
    return 'Unable to create post: $error';
  }

  @override
  String get catFarmingTips => 'Farming Tips';

  @override
  String get catMarketUpdates => 'Market Updates';

  @override
  String get catWeatherAlerts => 'Weather Alerts';

  @override
  String get catSuccessStories => 'Success Stories';

  @override
  String get catQA => 'Questions & Answers';

  @override
  String get profileTitle => 'Profile';

  @override
  String get profileEditHint => 'You can edit these anytime from your profile.';

  @override
  String get profileTabPersonal => 'Personal Information';

  @override
  String get profileTabAddress => 'Address';

  @override
  String get profileLabelName => 'Name';

  @override
  String get profileNameHint => 'Enter your name';

  @override
  String get profileLabelVillage => 'Village';

  @override
  String get profileLabelDistrict => 'District';

  @override
  String get selectDistrictHint => 'Select district';

  @override
  String get profileLabelState => 'State';

  @override
  String get stateHint => 'Select state';

  @override
  String get labelTehsil => 'Tehsil';

  @override
  String get villageTownHint => 'Type village/town';

  @override
  String get totalFarmAreaLabel => 'Total farm area';

  @override
  String get areaLabel => 'Area';

  @override
  String get farmAreaHint => 'e.g., 2.5';

  @override
  String get farmEmptyState => 'No crops found.';

  @override
  String get cropStatisticsTitle => 'Crop Statistics';

  @override
  String get totalcropsLabel => 'Total crops';

  @override
  String get avgYieldLabel => 'Average yield';

  @override
  String get activeCropsLabel => 'Active crops';

  @override
  String get readyForHarvestLabel => 'Ready for harvest';

  @override
  String get addCropTitle => 'Add Crop';

  @override
  String get cropTypeLabel => 'Crop Type';

  @override
  String get cropTypeHint => 'Select crop type';

  @override
  String get sownAreaLabel => 'Sown Area (acres)';

  @override
  String get sownAreaHint => 'e.g., 1.5';

  @override
  String get sownAreaHintError => 'Please enter a valid area';

  @override
  String get plantedDateLabel => 'Planted Date';

  @override
  String get cropLabelHint => 'e.g., Wheat - July Field';

  @override
  String get cropLabelHintError => 'Please enter a crop label';

  @override
  String get cropSaveError => 'Unable to save crop to server';

  @override
  String addCropSuccessful(Object cropName) {
    return '$cropName added successfully.';
  }

  @override
  String get profileLabelEmail => 'Email';

  @override
  String get profileLabelLanguage => 'Language';

  @override
  String get profileNotProvided => 'Not provided';

  @override
  String get profileErrorLoad => 'Unable to load profile';

  @override
  String get settingsEditProfile => 'Edit Profile';

  @override
  String get settingsChangePass => 'Change Password';

  @override
  String get settingsChangePassDesc => 'Set a new account password';

  @override
  String get settingsForgotPass => 'Forgot Password';

  @override
  String get settingsForgotPassDesc => 'Send reset link to email';

  @override
  String get settingsLogout => 'Logout';

  @override
  String get settingsLogoutDesc => 'Sign out from this device';

  @override
  String get settingsDelete => 'Delete Account (Coming soon)';

  @override
  String get formCurrentPass => 'Current Password';

  @override
  String get formNewPass => 'New Password';

  @override
  String get formConfirmPass => 'Confirm Password';

  @override
  String get formBtnUpdatePass => 'Update Password';

  @override
  String get formMsgPassSuccess => 'Password updated successfully';

  @override
  String get formMsgPassResetSent => 'Password reset link sent to your email';

  @override
  String get formErrorPassMatch =>
      'New password and confirm password do not match';

  @override
  String get formErrorPassLength => 'Minimum 6 characters required';

  @override
  String get imgPickCamera => 'Take photo';

  @override
  String get imgPickGallery => 'Choose from gallery';

  @override
  String get imgPreviewUnavailable => 'Preview unavailable';

  @override
  String get languageTooltip => 'Select Language';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageHindi => 'Hindi';

  @override
  String get profilePhone => 'Phone';

  @override
  String get diseaseDetectTitle => 'Disease Detection';

  @override
  String get diseaseIntruction => 'Capture or upload crop image';

  @override
  String get diseaseHint => 'Use clear daylight photos for better accuracy';

  @override
  String get cameraLabel => 'Camera';

  @override
  String get galleryLabel => 'Gallery';
}
