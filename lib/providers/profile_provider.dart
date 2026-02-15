import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kisan/models/onboarding_profile.dart';
import 'package:kisan/models/profile.dart' as db_profile;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
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

@immutable
class FarmerBasicProfile {
  final String name;
  final String village;
  final String district;
  final String state;
  final String email;
  final String? photoUrl;

  const FarmerBasicProfile({
    required this.name,
    required this.village,
    required this.district,
    required this.state,
    required this.email,
    required this.photoUrl,
  });

  String get languagePreference => 'English';

  String get location {
    final parts = <String>[village, district, state]
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    return parts.isEmpty ? 'Location not available' : parts.join(', ');
  }
}

final farmerBasicProfileProvider = FutureProvider<FarmerBasicProfile>((ref) async {
  final supabase = ref.watch(supabaseClientProvider);
  final profile = await ref.watch(farmerProfileProvider.future);
  return FarmerBasicProfile(
    name: (profile['name'] ?? '').toString().trim(),
    village: (profile['village'] ?? '').toString().trim(),
    district: (profile['district'] ?? '').toString().trim(),
    state: (profile['state'] ?? '').toString().trim(),
    email: (supabase.auth.currentUser?.email ?? '').trim(),
    photoUrl: (profile['photo_url'] as String?)?.trim().isEmpty == true
        ? null
        : (profile['photo_url'] as String?),
  );
});

class ProfilePhotoUploadNotifier extends StateNotifier<AsyncValue<void>> {
  ProfilePhotoUploadNotifier(this.ref) : super(const AsyncValue.data(null));

  final Ref ref;
  final ImagePicker _picker = ImagePicker();
  static const String _profileBucket = 'Profiles';

  Future<String?> pickAndUpload(ImageSource source) async {
    final supabase = ref.read(supabaseClientProvider);
    final user = supabase.auth.currentUser;
    if (user == null) {
      throw Exception('User not logged in');
    }

    final picked = await _picker.pickImage(
      source: source,
      requestFullMetadata: true,
    );
    if (picked == null) return null;

    state = const AsyncValue.loading();
    try {
      final sourceFile = File(picked.path);
      final fileToUpload = await _compressForUpload(sourceFile);
      // Policy requires first folder segment == auth uid.
      final filePath = '${user.id}/${user.id}.jpg';
      await supabase.storage.from(_profileBucket).upload(
            filePath,
            fileToUpload,
            fileOptions: const FileOptions(
              cacheControl: '3600',
              upsert: true,
            ),
          );
      final publicUrl = supabase.storage.from(_profileBucket).getPublicUrl(filePath);

      await supabase
          .from('farmers')
          .update({'photo_url': publicUrl})
          .eq('id', user.id);

      ref.invalidate(farmerProfileProvider);
      ref.invalidate(farmerBasicProfileProvider);
      ref.invalidate(fullProfileProvider);

      state = const AsyncValue.data(null);
      return publicUrl;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<File> _compressForUpload(File source) async {
    try {
      final sourceSize = source.lengthSync();
      final tempDir = await getTemporaryDirectory();
      final targetPath = p.join(
        tempDir.path,
        'profile_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );

      final compressed = await FlutterImageCompress.compressAndGetFile(
        source.path,
        targetPath,
        quality: 70,
        minWidth: 1280,
        minHeight: 1280,
        format: CompressFormat.jpeg,
      );

      if (compressed == null) {
        debugPrint(
          'Profile image: compression returned null, using original. bytes=$sourceSize',
        );
        return source;
      }

      final compressedFile = File(compressed.path);
      final compressedSize = compressedFile.lengthSync();
      final ratio =
          sourceSize == 0 ? 0 : ((sourceSize - compressedSize) / sourceSize) * 100;
      debugPrint(
        'Profile image: compressed. original=$sourceSize bytes, compressed=$compressedSize bytes, saved=${ratio.toStringAsFixed(1)}%',
      );
      return compressedFile;
    } on MissingPluginException catch (e) {
      debugPrint('Profile image: compression plugin missing, using original. $e');
      return source;
    } on PlatformException catch (e) {
      debugPrint('Profile image: compression failed, using original. $e');
      return source;
    } catch (e) {
      debugPrint('Profile image: unexpected compression error, using original. $e');
      return source;
    }
  }
}

final profilePhotoUploadProvider =
    StateNotifierProvider<ProfilePhotoUploadNotifier, AsyncValue<void>>((ref) {
  return ProfilePhotoUploadNotifier(ref);
});

class ProfileUpdateNotifier extends StateNotifier<AsyncValue<void>> {
  ProfileUpdateNotifier(this.ref) : super(const AsyncValue.data(null));

  final Ref ref;

  Future<void> updateBasicInfo({
    required String name,
    required String village,
    required String district,
    required String farmState,
    double? latitude,
    double? longitude,
  }) async {
    final supabase = ref.read(supabaseClientProvider);
    final user = supabase.auth.currentUser;
    if (user == null) {
      throw Exception('User not logged in');
    }

    state = const AsyncValue.loading();
    try {
      final locationPoint = _toPostgisPoint(
        latitude: latitude,
        longitude: longitude,
      );
      await supabase.from('farmers').update({
        'name': name.trim(),
        'village': village.trim(),
        'district': district.trim(),
        'state': farmState.trim(),
        if (locationPoint != null) 'location': locationPoint,
      }).eq('id', user.id);

      ref.invalidate(farmerProfileProvider);
      ref.invalidate(farmerBasicProfileProvider);
      ref.invalidate(fullProfileProvider);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  String? _toPostgisPoint({
    required double? latitude,
    required double? longitude,
  }) {
    if (latitude == null || longitude == null) return null;
    if (latitude < -90 || latitude > 90) return null;
    if (longitude < -180 || longitude > 180) return null;
    return 'SRID=4326;POINT($longitude $latitude)';
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final supabase = ref.read(supabaseClientProvider);
    final user = supabase.auth.currentUser;
    final email = user?.email?.trim() ?? '';
    if (email.isEmpty) {
      throw Exception('No email linked to current account');
    }
    state = const AsyncValue.loading();
    try {
      // Verify current password by re-authenticating.
      await supabase.auth.signInWithPassword(
        email: email,
        password: currentPassword.trim(),
      );
      await supabase.auth.updateUser(
        UserAttributes(password: newPassword.trim()),
      );
      state = const AsyncValue.data(null);
    } on AuthException catch (e, st) {
      final raw = (e.message).toLowerCase();
      final message = raw.contains('invalid login credentials') ||
              raw.contains('invalid credentials')
          ? 'Current password is incorrect.'
          : e.message;
      state = AsyncValue.error(Exception(message), st);
      rethrow;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> sendPasswordReset(String email) async {
    final supabase = ref.read(supabaseClientProvider);
    state = const AsyncValue.loading();
    try {
      final redirectTo = kIsWeb ? '${Uri.base.origin}/login' : null;
      await supabase.auth.resetPasswordForEmail(
        email.trim(),
        redirectTo: redirectTo,
      );
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}

final profileUpdateProvider =
    StateNotifierProvider<ProfileUpdateNotifier, AsyncValue<void>>((ref) {
  return ProfileUpdateNotifier(ref);
});

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
