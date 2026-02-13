import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kisan/models/onboarding_profile.dart';
import 'package:kisan/models/profile.dart' as db_profile;
import 'package:kisan/services/session_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// A simple provider to expose the Supabase client
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});
/// StateProvider holds a simple, changeable value.
/// Here, it holds an integer, and its default value is 0.
final bottomNavIndexProvider = StateProvider<int>((ref) => 0);

// A provider to fetch the farmer's profile data
// FutureProvider is perfect for asynchronous operations like fetching data
final farmerProfileProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  // Get the Supabase client from the provider we just created
  final supabaseClient = ref.watch(supabaseClientProvider);
  
  // Get the current user's ID
  final userId = supabaseClient.auth.currentUser?.id;

  if (userId == null) {
    throw Exception('User not logged in');
  }

  // Fetch the data from the 'farmers' table
  final response = await supabaseClient
      .from('farmers')
      .select()
      .eq('id', userId)
      .single();

  return response;
});

/// Manages the selected tab state on the profile screen
// Fetches the complete, combined profile data for the user.
final fullProfileProvider = FutureProvider<db_profile.FarmerProfile>((ref) async {
  final supabase = ref.watch(supabaseClientProvider);
  final user = supabase.auth.currentUser;

  if (user == null) {
    throw Exception('User not logged in');
  }

  // This single query fetches the farmer, their farms, and the crops on those farms.
  final response = await supabase
      .from('farmers')
      .select('*, farms(*, farm_crops(*))')
      .eq('id', user.id)
      .single();

  // Convert the raw map into a structured FarmerProfile object
  return db_profile.FarmerProfile.fromMap(response);
});


final profileTabProvider = StateProvider<int>((ref) => 0); // 0: Profile, 1: Farm, 2: Settings

class ProfileProvider extends ChangeNotifier {
  FarmerProfile? _profile;

  FarmerProfile? get profile => _profile;

  Future<void> loadProfile() async {
    final raw = await SessionService.getStoredProfile();
    if (raw != null) {
      _profile = FarmerProfile.fromJson(raw);
      notifyListeners();
    }
  }

  Future<void> saveProfile(FarmerProfile profile) async {
    _profile = profile;
    await SessionService.saveProfile(profile.toJson());
    notifyListeners();
  }
}
