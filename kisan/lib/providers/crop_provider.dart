import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kisan/providers/profile_provider.dart';
import '../models/crop.dart'; // Make sure your Crop model can be created from a map

// Provider 1: Manages the search query state
final cropSearchQueryProvider = StateProvider<String>((ref) => '');

// Provider 2: Fetches the raw list of crops from Supabase
final cropsProvider = FutureProvider<List<Crop>>((ref) async {
  final supabase = ref.watch(supabaseClientProvider);
  final userId = supabase.auth.currentUser!.id;

  // Canonical source for crop list is farms table in current flow.
  final response = await supabase
      .from('farms')
      .select('farm_id, farmer_id, crop_name, crop_type, sown_date, area')
      .eq('farmer_id', userId)
      .order('sown_date', ascending: false);

  final rows = List<Map<String, dynamic>>.from(response as List);
  return rows
      .map(
        (row) => Crop(
          id: (row['farm_id'] ?? '').toString(),
          name: (row['crop_name'] ?? 'Unnamed crop').toString(),
          type: row['crop_type']?.toString(),
          sowDate: DateTime.tryParse((row['sown_date'] ?? '').toString()) ??
              DateTime.now(),
          stage: 'sowing',
          areaAcres: (row['area'] as num?)?.toDouble(),
          location: 'Not provided',
          actionsHistory: const [],
        ),
      )
      .toList();
});

// Provider 3: Provides the final, filtered list to the UI
final filteredCropsProvider = Provider<List<Crop>>((ref) {
  // Watch the raw data and the search query
  final cropsAsync = ref.watch(cropsProvider);
  final query = ref.watch(cropSearchQueryProvider);

  // When the data is available, apply the filter
  return cropsAsync.when(
    data: (crops) {
      if (query.isEmpty) {
        return crops;
      }
      final lowerQuery = query.toLowerCase();
      return crops.where((crop) => crop.name.toLowerCase().contains(lowerQuery)).toList();
    },
    // Return empty lists for loading/error states
    loading: () => [],
    error: (e, s) => [],
  );
});

// A Notifier to handle adding new crops
class CropListNotifier extends StateNotifier<AsyncValue<List<Crop>>> {
  final Ref ref;
  CropListNotifier(this.ref) : super(const AsyncValue.loading());
  
  Future<int?> addCrop({
    required String name,
    required String cropType,
    required double area,
    required DateTime sowDate,
    required String stage,
  }) async {
    final supabase = ref.watch(supabaseClientProvider);
    final userId = supabase.auth.currentUser!.id;

    try {
      // stage kept in signature for UI compatibility; farms schema doesn't use it.
      final inserted = await supabase
          .from('farms')
          .insert({
            'farmer_id': userId,
            'crop_name': name,
            'crop_type': cropType,
            'sown_date': sowDate.toIso8601String(),
            'area': area,
          })
          .select('farm_id')
          .single();

      ref.invalidate(cropsProvider);
      return inserted['farm_id'] as int?;
    } catch (e) {
      // Handle error, maybe expose it in the state
      print('Error adding crop: $e');
      rethrow;
    }
  }
}

final cropListNotifierProvider = StateNotifierProvider<CropListNotifier, AsyncValue<List<Crop>>>(
  (ref) => CropListNotifier(ref),
);
