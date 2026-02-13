import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class SessionService {
  static const String _isLoggedInKey = 'is_logged_in';
  static const String _onboardingCompleteKey = 'onboarding_complete';
  static const String _userNameKey = 'user_name';
  static const String _userAddressKey = 'user_address';
  static const String _onboardingDraftKey = 'onboarding_draft';
  static const String _profileKey = 'farmer_profile_v1';
  static const _languageCodeKey = 'languageCode';
  static const _languageSelectedKey = 'languageSelected';

  // --- Language Preferences ---

  /// Saves the user's selected language code (e.g., 'en', 'hi').
  static Future<void> saveLanguagePreference(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageCodeKey, languageCode);
    await prefs.setBool(_languageSelectedKey, true);
  }
  /// Retrieves the saved language code. Returns null if none is saved.
  static Future<String?> getLanguagePreference() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_languageCodeKey);
  }
  
  /// Checks if the user has ever selected a language.
  static Future<bool> isLanguageSelected() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_languageSelectedKey) ?? false;
  }




  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isLoggedInKey) ?? false;
  }

  static Future<void> setLoggedIn(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isLoggedInKey, value);
  }

  static Future<bool> isOnboardingComplete() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_onboardingCompleteKey) ?? false;
  }

  static Future<void> setOnboardingComplete(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingCompleteKey, value);
  }

  static Future<void> setUserName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userNameKey, name);
  }

  static Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userNameKey);
  }

  static Future<void> setUserAddress({
    String? state,
    String? district,
    String? village,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final address = {
      'state': state ?? '',
      'district': district ?? '',
      'village': village ?? '',
    };
    await prefs.setString(_userAddressKey, address.toString());
  }

  static Future<Map<String, String>> getUserAddress() async {
    final prefs = await SharedPreferences.getInstance();
    final addressStr = prefs.getString(_userAddressKey);
    if (addressStr == null || addressStr.isEmpty) return {};
    // Parse the string back to a map
    final regExp = RegExp(r"'([^']+)': '([^']*)'");
    final matches = regExp.allMatches(addressStr);
    final map = <String, String>{};
    for (final m in matches) {
      map[m.group(1)!] = m.group(2)!;
    }
    return map;
  }

  // Persist onboarding draft (JSON)
  static Future<void> saveOnboardingDraft(Map<String, dynamic> draft) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_onboardingDraftKey, jsonEncode(draft));
  }

  static Future<Map<String, dynamic>?> getOnboardingDraft() async {
    final prefs = await SharedPreferences.getInstance();
    final s = prefs.getString(_onboardingDraftKey);
    if (s == null) return null;
    try {
      final decoded = jsonDecode(s) as Map<String, dynamic>;
      return decoded;
    } catch (_) {
      return null;
    }
  }

  static Future<void> clearOnboardingDraft() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_onboardingDraftKey);
  }

  // Final structured profile storage
  static Future<void> saveProfile(Map<String, dynamic> profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_profileKey, jsonEncode(profile));
  }

  static Future<Map<String, dynamic>?> getStoredProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final s = prefs.getString(_profileKey);
    if (s == null) return null;
    try {
      return jsonDecode(s) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  /// Clears all locally persisted app data so the next launch behaves like a
  /// fresh login/onboarding.
  static Future<void> clearAllLocalData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
