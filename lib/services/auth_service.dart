import 'package:shared_preferences/shared_preferences.dart';
import '../models/farmer.dart';
import '../utils/dummy_data.dart';

class AuthService {
  static const String _userKey = 'current_user';
  static const String _isLoggedInKey = 'is_logged_in';

  // Simulate login
  static Future<bool> login(String phoneNumber, String password) async {
    // Simulate API call delay
    await Future.delayed(Duration(seconds: 2));
    
    // For demo purposes, accept any valid phone number and password
    if (phoneNumber.length >= 10 && password.length >= 6) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_isLoggedInKey, true);
      await prefs.setString(_userKey, phoneNumber);
      return true;
    }
    return false;
  }

  // Simulate registration
  static Future<bool> register(Farmer farmer, String password) async {
    // Simulate API call delay
    await Future.delayed(Duration(seconds: 2));
    
    // For demo purposes, always succeed
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isLoggedInKey, true);
    await prefs.setString(_userKey, farmer.id);
    return true;
  }

  // Logout
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_isLoggedInKey);
    await prefs.remove(_userKey);
  }

  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isLoggedInKey) ?? false;
  }

  // Get current user
  static Future<Farmer?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString(_userKey);
    
    if (userId != null) {
      // Return dummy farmer data for demo
      return DummyData.getDummyFarmers().first;
    }
    return null;
  }

  // Update user profile
  static Future<bool> updateProfile(Farmer farmer) async {
    // Simulate API call delay
    await Future.delayed(Duration(seconds: 1));
    
    // For demo purposes, always succeed
    return true;
  }

  // Change password
  static Future<bool> changePassword(String oldPassword, String newPassword) async {
    // Simulate API call delay
    await Future.delayed(Duration(seconds: 1));
    
    // For demo purposes, always succeed
    return true;
  }

  // Forgot password
  static Future<bool> forgotPassword(String phoneNumber) async {
    // Simulate API call delay
    await Future.delayed(Duration(seconds: 1));
    
    // For demo purposes, always succeed
    return true;
  }
}
