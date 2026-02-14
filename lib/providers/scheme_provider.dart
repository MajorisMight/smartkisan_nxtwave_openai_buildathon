import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/scheme.dart';
import '../services/gemini_service.dart';
import 'profile_provider.dart';

// Provider 1: Manages the currently selected category filter.
final schemeCategoryFilterProvider = StateProvider<String>((ref) => 'All');

// Provider 2: Manages the current search query.
final schemeSearchQueryProvider = StateProvider<String>((ref) => '');

// Provider 3: Fetches the raw, unfiltered list of schemes from the GeminiService.
// It depends on the farmer's profile to make the API call.
final schemesProvider = FutureProvider<List<Scheme>>((ref) async {
  // Watch the farmerProfileProvider to get the profile data.
  // This will automatically re-fetch if the profile ever changes.
  final profileData = await ref.watch(farmerProfileProvider.future);

  // Call the Gemini service to get the schemes
  final schemesMap = await GeminiService.applicableSchemes(profile: profileData);

  // Convert the map to a list of Scheme objects
  return schemesMap.map((s) => Scheme.fromMap(s)).toList();
});

// Provider 4: The final, filtered list that the UI will display.
// This is the "smart" provider that combines the data and the filters.
final filteredSchemesProvider = Provider<List<Scheme>>((ref) {
  // Watch the three providers this one depends on
  final category = ref.watch(schemeCategoryFilterProvider);
  final query = ref.watch(schemeSearchQueryProvider);
  final schemesAsync = ref.watch(schemesProvider);

  // Handle the loading/error states of the initial fetch
  return schemesAsync.when(
    data: (schemes) {
      // Apply the category filter
      List<Scheme> filtered = schemes;
      if (category != 'All') {
        filtered = schemes.where((s) => s.category.toLowerCase() == category.toLowerCase()).toList();
      }
      
      // Apply the search query filter
      if (query.isNotEmpty) {
        final lowerQuery = query.toLowerCase();
        filtered = filtered.where((s) => 
          s.title.toLowerCase().contains(lowerQuery) || 
          s.description.toLowerCase().contains(lowerQuery)
        ).toList();
      }

      return filtered;
    },
    loading: () => [], // Return an empty list while loading
    error: (e, s) => [], // Return an empty list on error
  );
});