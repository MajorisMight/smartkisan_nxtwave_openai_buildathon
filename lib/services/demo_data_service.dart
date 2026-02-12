import 'package:shared_preferences/shared_preferences.dart';
import '../models/farmer.dart';
import '../models/crop.dart';
import '../models/field.dart';
import '../models/diary_entry.dart';
import '../models/weather.dart';
import '../models/community_post.dart';
import '../models/product.dart';
import '../models/scheme.dart';
import 'consistent_data_service.dart';

class DemoDataService {
  static const String _farmerDataKey = 'demo_farmer_data';
  static const String _onboardingCompletedKey = 'demo_onboarding_completed';
  
  // Realistic farmer profile for demo
  static Farmer getDemoFarmer() {
    return ConsistentDataService.getFarmer();
  }

  // Realistic crops based on farmer's selection
  static List<Crop> getDemoCrops() {
    return ConsistentDataService.getCrops();
  }

  // Realistic fields
  static List<Field> getDemoFields() {
    return ConsistentDataService.getFields();
  }

  // Comprehensive diary entries
  static List<DiaryEntry> getDemoDiaryEntries() {
    return ConsistentDataService.getDiaryEntries();
  }

  // Weather data for Punjab location
  static WeatherData getDemoWeatherData() {
    return ConsistentDataService.getWeatherData();
  }

  // Personalized schemes based on farmer's crops and location
  static List<Scheme> getPersonalizedSchemes() {
    return ConsistentDataService.getGovernmentSchemes();
  }

  // Marketplace products relevant to farmer's crops
  static List<Product> getRelevantProducts() {
    return ConsistentDataService.getMarketplaceProducts();
  }

  // Community posts from the farmer
  static List<CommunityPost> getFarmerCommunityPosts() {
    return ConsistentDataService.getCommunityPosts();
  }

  // Initialize demo data
  static Future<void> initializeDemoData() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Mark onboarding as completed
    await prefs.setBool(_onboardingCompletedKey, true);
    
    // Store farmer data
    final farmer = getDemoFarmer();
    await prefs.setString(_farmerDataKey, farmer.toJson().toString());
  }

  // Check if demo data is initialized
  static Future<bool> isDemoDataInitialized() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_onboardingCompletedKey) ?? false;
  }

  // Clear demo data (for testing)
  static Future<void> clearDemoData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_farmerDataKey);
    await prefs.remove(_onboardingCompletedKey);
  }
}