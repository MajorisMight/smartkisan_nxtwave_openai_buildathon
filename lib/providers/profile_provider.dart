import 'package:flutter/foundation.dart';
import '../models/onboarding_profile.dart';
import '../services/session_service.dart';

class ProfileProvider extends ChangeNotifier {
  FarmerProfile? _profile;
  FarmerProfile? get profile => _profile;
  bool get hasProfile => _profile != null;

  Future<void> loadFromStorage() async {
    final map = await SessionService.getStoredProfile();
    if (map != null) {
      _profile = FarmerProfile.fromJson(map);
      notifyListeners();
    }
  }

  Future<void> saveProfile(FarmerProfile profile) async {
    _profile = profile;
    await SessionService.saveProfile(profile.toJson());
    if (profile.name != null && profile.name!.isNotEmpty) {
      await SessionService.setUserName(profile.name!);
    }
    await SessionService.setUserAddress(
      state: profile.state,
      district: profile.district,
      village: profile.village,
    );
    notifyListeners();
  }
}
