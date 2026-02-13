class AppConstants {
  // App Information
  static const String appName = 'Kisan';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Farmer Ecosystem App';

  // API Configuration
  static const String baseUrl = 'https://api.kisan.com';
  static const String apiVersion = 'v1';
  static const Duration apiTimeout = Duration(seconds: 30);

  // Storage Keys
  static const String userTokenKey = 'user_token';
  static const String userDataKey = 'user_data';
  static const String themeKey = 'theme_mode';
  static const String languageKey = 'language';
  static const String notificationsKey = 'notifications_enabled';

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // Image Configuration
  static const int maxImageSize = 5 * 1024 * 1024; // 5MB
  static const List<String> allowedImageTypes = ['jpg', 'jpeg', 'png', 'webp'];

  // Validation
  static const int minPasswordLength = 8;
  static const int maxBioLength = 500;
  static const int maxPostContentLength = 2000;

  // Weather
  static const String defaultWeatherLocation = 'Delhi, India';
  static const Duration weatherUpdateInterval = Duration(minutes: 30);

  // Marketplace
  static const int maxProductImages = 5;
  static const double maxProductPrice = 1000000.0;
  static const int maxStockQuantity = 10000;

  // Community
  static const int maxPostImages = 10;
  static const int maxTagsPerPost = 5;

  // Orders
  static const List<String> orderStatuses = [
    'pending',
    'confirmed',
    'processing',
    'shipped',
    'delivered',
    'cancelled',
    'returned',
  ];

  static const List<String> paymentMethods = [
    'cash_on_delivery',
    'online_payment',
    'bank_transfer',
    'upi',
  ];

  // Categories
  static const List<String> productCategories = [
    'Vegetables',
    'Fruits',
    'Grains',
    'Spices',
    'Herbs',
    'Dairy',
    'Meat',
    'Seafood',
    'Organic',
    'Seeds',
    'Fertilizers',
    'Tools',
  ];

  static const List<String> communityCategories = [
    'Farming Tips',
    'Market Updates',
    'Weather Alerts',
    'Success Stories',
    'Questions & Answers',
    'Equipment Reviews',
    'Crop Diseases',
    'Government Schemes',
    'Technology',
    'Events',
  ];

  // Crop Types
  static const List<String> cropTypes = [
    'Rice',
    'Wheat',
    'Maize',
    'Sugarcane',
    'Cotton',
    'Potato',
    'Tomato',
    'Onion',
    'Chilli',
    'Turmeric',
    'Ginger',
    'Garlic',
    'Cabbage',
    'Cauliflower',
    'Spinach',
    'Carrot',
    'Radish',
    'Cucumber',
    'Brinjal',
    'Okra',
  ];

  // Units
  static const List<String> weightUnits = ['kg', 'lb', 'ton', 'quintal'];
  static const List<String> volumeUnits = ['liter', 'gallon', 'ml'];
  static const List<String> countUnits = ['piece', 'dozen', 'bunch', 'bag'];

  // Languages
  static const List<String> supportedLanguages = [
    'English',
    'Hindi',
    'Bengali',
    'Telugu',
    'Marathi',
    'Tamil',
    'Gujarati',
    'Kannada',
    'Malayalam',
    'Punjabi',
  ];

  // Error Messages
  static const String networkError = 'Network connection error';
  static const String serverError = 'Server error occurred';
  static const String unknownError = 'Unknown error occurred';
  static const String invalidCredentials = 'Invalid credentials';
  static const String userNotFound = 'User not found';
  static const String productNotFound = 'Product not found';
  static const String orderNotFound = 'Order not found';

  // Success Messages
  static const String loginSuccess = 'Login successful';
  static const String registrationSuccess = 'Registration successful';
  static const String orderPlacedSuccess = 'Order placed successfully';
  static const String profileUpdatedSuccess = 'Profile updated successfully';
  static const String postCreatedSuccess = 'Post created successfully';
}
