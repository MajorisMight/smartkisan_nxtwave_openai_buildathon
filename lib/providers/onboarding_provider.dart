// providers/onboarding_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kisan/main.dart';
import 'package:kisan/models/onboarding_draft.dart';
import 'package:kisan/providers/auth_provider.dart';
import 'package:kisan/services/session_service.dart';



// Notifier for managing onboarding state
class OnboardingNotifier extends StateNotifier<OnboardingDraft> {
  final Ref ref;
  OnboardingNotifier({required this.ref}) : super(OnboardingDraft()) {
    loadSavedDraft();
  }

  // Load saved draft from local storage
  Future<void> loadSavedDraft() async {
    final map = await SessionService.getOnboardingDraft();
    if (map != null) {
      state.applyFromMap(map);
      // Trigger rebuild
      state = state.copyWith();
    }
  }

  // Save current state to local storage
  Future<void> saveDraft() async {
    await SessionService.saveOnboardingDraft(state.toMap());
  }

  // Profile updates
  void updateName(String? name) {
    state = state.copyWith(name: name);
    saveDraft();
  }

  void updateAgeRange(String? ageRange) {
    state = state.copyWith(ageRange: ageRange);
    saveDraft();
  }

  void updateLanguage(String? language) {
    state = state.copyWith(language: language);
    saveDraft();
  }

  void updateExperienceLevel(String? level) {
    state = state.copyWith(experienceLevel: level);
    saveDraft();
  }

  void updateSocialCategory(String? category) {
    state = state.copyWith(socialCategory: category);
    saveDraft();
  }

  // Location updates
  void updateGpsLocation(double? lat, double? lon) {
    state = state.copyWith(gpsLat: lat, gpsLon: lon);
    saveDraft();
  }

  void updateVillage(String? village) {
    state = state.copyWith(village: village);
    saveDraft();
  }

  void updateDistrict(String? district) {
    state = state.copyWith(district: district);
    saveDraft();
  }

  void updateState(String? stateValue) {
    // Clear district when state changes
    state = state.copyWith(state: stateValue, district: null);
    saveDraft();
  }

  void updateTotalArea(double? area) {
    state = state.copyWith(totalArea: area);
    saveDraft();
  }

  void updateAreaUnit(String? unit) {
    state = state.copyWith(areaUnit: unit);
    saveDraft();
  }

  void updateWaterSources(List<String> sources) {
    state = state.copyWith(waterSources: sources);
    saveDraft();
  }

  void updateMembership(bool? isMember) {
    state = state.copyWith(isMember: isMember);
    saveDraft();
  }

  void updateGroupName(String? groupName) {
    state = state.copyWith(groupName: groupName);
    saveDraft();
  }

  // Crop updates
  void toggleCrop(String cropId) {
    final currentCrops = List<Map<String, dynamic>>.from(state.crops);
    final idx = currentCrops.indexWhere((c) => c['crop_id'] == cropId);
    
    if (idx >= 0) {
      currentCrops.removeAt(idx);
    } else {
      currentCrops.add({
        'crop_id': cropId,
        'sowing_month': null,
        'variety': null,
        'expected_area': null,
        'previous_crop': null,
        'common_pests': <String>[],
        'field_status': null,
        'planned_crop': null,
      });
    }
    
    state = state.copyWith(crops: currentCrops);
    saveDraft();
  }

  void updateCropProperty(int index, String property, dynamic value) {
    if (index >= 0 && index < state.crops.length) {
      final currentCrops = List<Map<String, dynamic>>.from(state.crops);
      currentCrops[index][property] = value;
      state = state.copyWith(crops: currentCrops);
      saveDraft();
    }
  }

  // Soil test updates
  void updateSoilTestEntry(bool manualEntry) {
    state = state.copyWith(manualSoilEntry: manualEntry);
    saveDraft();
  }

  void updateSoilTestValue(String key, dynamic value) {
    state.soilTest[key] = value;
    // Trigger rebuild without copyWith since we're modifying map directly
    state = state.copyWith();
    saveDraft();
  }

  void updateWaterQuality(String key, dynamic value) {
    state.waterQuality[key] = value;
    state = state.copyWith();
    saveDraft();
  }

  void updateWantSoilKit(bool? want) {
    state = state.copyWith(wantSoilKit: want);
    saveDraft();
  }

  // History updates
  void updateLastSeasonYield(String cropId, double yield) {
    state.lastSeasonYields[cropId] = yield;
    state = state.copyWith();
    saveDraft();
  }

  void updateYieldUnit(String cropId, String unit) {
    state.yieldUnit[cropId] = unit;
    state = state.copyWith();
    saveDraft();
  }

  void updatePastInputs(List<String> inputs) {
    state = state.copyWith(pastInputs: inputs);
    saveDraft();
  }

  void updateHistoricalImpacts(List<String> impacts) {
    state = state.copyWith(historicalImpacts: impacts);
    saveDraft();
  }

  void updateUsedSchemes(bool? used) {
    state = state.copyWith(usedSchemes: used);
    saveDraft();
  }

  void updateParticipatedSchemes(List<String> schemes) {
    state = state.copyWith(participatedSchemes: schemes);
    saveDraft();
  }

  // Finance updates
  void updateBankAccount(bool? hasAccount) {
    state = state.copyWith(hasBankAccount: hasAccount);
    saveDraft();
  }

  void updateBankName(String? bankName) {
    state = state.copyWith(bankName: bankName);
    saveDraft();
  }

  void updateInsurance(bool? hasInsurance) {
    state = state.copyWith(hasInsurance: hasInsurance);
    saveDraft();
  }

  void updateInsuranceProvider(String? provider) {
    state = state.copyWith(insuranceProvider: provider);
    saveDraft();
  }

  void updateIncomeBracket(String? bracket) {
    state = state.copyWith(incomeBracket: bracket);
    saveDraft();
  }

  void updatePreferredPayment(String? payment) {
    state = state.copyWith(preferredPayment: payment);
    saveDraft();
  }

  void updateConsentAnalytics(bool consent) {
    state = state.copyWith(consentAnalytics: consent);
    saveDraft();
  }

  void updateTermsAccepted(bool accepted) {
    state = state.copyWith(termsAccepted: accepted);
    saveDraft();
  }

  // Field management
  void addField(Map<String, dynamic> fieldData) {
    final currentFields = List<Map<String, dynamic>>.from(state.fields);
    currentFields.add(fieldData);
    state = state.copyWith(fields: currentFields);
    saveDraft();
  }

  void updateField(int index, Map<String, dynamic> fieldData) {
    if (index >= 0 && index < state.fields.length) {
      final currentFields = List<Map<String, dynamic>>.from(state.fields);
      currentFields[index] = fieldData;
      state = state.copyWith(fields: currentFields);
      saveDraft();
    }
  }

  void removeField(int index) {
    if (index >= 0 && index < state.fields.length) {
      final currentFields = List<Map<String, dynamic>>.from(state.fields);
      currentFields.removeAt(index);
      state = state.copyWith(fields: currentFields);
      saveDraft();
    }
  }

  // Final submission
  Future<void> submitOnboarding() async {
    try {
      final userId = supabase.auth.currentUser!.id;

      // Save to farmers table
      await supabase.from('farmers').upsert({
        'id': userId,
        'phone_number': state.phoneNumber,
        'name': state.name,
        'age_range': state.ageRange,
        'experience_level': state.experienceLevel,
        'social_category': state.socialCategory,
        'language_pref': state.language,
      });

      // Handle GPS coordinates (only set location when we actually have them)
      final gpsLon = state.gpsLon;
      final gpsLat = state.gpsLat;
      final location =
          (gpsLon != null && gpsLat != null)
              ? 'SRID=4326;POINT($gpsLon $gpsLat)'
              : null;

      // Save to farms table
      final farmResponse = await supabase.from('farms').upsert({
        'farmer_id': userId,
        'farm_name': 'Primary Farm',
        'area_in_acres': state.totalArea,
        'village': state.village,
        'district': state.district,
        'state': state.state,
        'water_sources': state.waterSources,
        'is_in_coop': state.isMember,
        'coop_name': state.groupName,
        if (location != null) 'location': location,
      }).select('farm_id').single();
      
      final farmId = farmResponse['farm_id'];

      // Save soil data if entered
      if (state.manualSoilEntry) {
        await supabase.from('soil_health_cards').upsert({
          'farm_id': farmId,
          'test_date': state.soilTest['date'],
          'ph_level': state.soilTest['pH'],
          'nitrogen': state.soilTest['N'],
          'phosphorus': state.soilTest['P'],
          'potassium': state.soilTest['K'],
          'calcium': state.soilTest['calcium'],
          'magnesium': state.soilTest['magnesium'],
          'sulphur': state.soilTest['sulphur'],
          'boron': state.soilTest['boron'],
          'copper': state.soilTest['copper'],
          'iron': state.soilTest['iron'],
          'manganese': state.soilTest['manganese'],
          'zinc': state.soilTest['zinc'],
          'molybdenum': state.soilTest['molybdenum'],
          'organic_matter': state.soilTest['organic_matter'],
          'cation_exchange_capacity': state.soilTest['cation_exchange_capacity'],
          'electrical_conductivity': state.soilTest['electrical_conductivity'],
          'lime_index': state.soilTest['lime_index'],
        });
      }

      // Save financial data
      await supabase.from('farmer_finances').upsert({
        'farmer_id': userId,
        'has_bank_account': state.hasBankAccount,
        'bank_name': state.bankName,
        'has_insurance': state.hasInsurance,
        'insurance_provider': state.insuranceProvider,
        'income_bracket': state.incomeBracket,
      },
      onConflict: 'farmer_id', 
      );

      // Save crop data
      for (var cropData in state.crops) {
        await supabase.from('farm_crops').upsert({
          'farm_id': farmId,
          'crop_name': cropData['crop_id'],
          'field_status': cropData['field_status'],
          'area_in_acres': cropData['expected_area'],
          'previous_crop': cropData['previous_crop'],
          'last_season_yield': state.lastSeasonYields[cropData['crop_id']],
          'yield_unit': state.yieldUnit[cropData['crop_id']],
        });
      }

      // Clear the draft after successful submission
      await SessionService.clearOnboardingDraft();
      ref.invalidate(onboardingCompleteProvider); // Invalidate the checking provider to refresh onboarding status
      
    } catch (error) {
      print('🛑 Error saving onboarding data(from provider): $error');
      rethrow;
    }
  }

    bool isStepValid(int step) {
    return state.isStepValid(step);
  }
}

// Current step provider
final currentStepProvider = StateProvider<int>((ref) => 0);

// Loading state provider
final onboardingLoadingProvider = StateProvider<bool>((ref) => false);

// Main onboarding provider
final onboardingProvider = StateNotifierProvider<OnboardingNotifier, OnboardingDraft>((ref) {
  return OnboardingNotifier(ref: ref);
});

// Helper providers for computed values
final selectedCropsProvider = Provider<List<String>>((ref) {
  final draft = ref.watch(onboardingProvider);
  return draft.crops.map((e) => e['crop_id'] as String).toList();
});

final hasEmailPendingProvider = Provider<bool>((ref) {
  final pendingEmail = ref.watch(pendingEmailConfirmationProvider);
  return pendingEmail != null;
});

// Districts provider (computed based on selected state)
final availableDistrictsProvider = Provider<List<String>>((ref) {
  final draft = ref.watch(onboardingProvider);
  return _getDistrictsForState(draft.state);
});

final stepValidationProvider = Provider.family<bool, int>((ref, step) {
  final notifier = ref.watch(onboardingProvider.notifier);
  return notifier.isStepValid(step);
});

// Overall form completion percentage
final onboardingProgressProvider = Provider<double>((ref) {
  final draft = ref.watch(onboardingProvider);
  int completedSteps = 0;
  final totalSteps = 6;
  
  for (int i = 0; i < totalSteps; i++) {
    if (draft.isStepValid(i)) {
      completedSteps++;
    }
  }
  
  return completedSteps / totalSteps;
});

// Helper function for districts
List<String> _getDistrictsForState(String? state) {
  switch (state) {
    case 'Punjab':
      return ['Ludhiana', 'Amritsar'];
    case 'Maharashtra':
      return ['Pune', 'Nashik'];
    case 'Haryana':
      return ['Karnal', 'Hisar'];
    case 'Rajasthan':
      return ['Jaipur', 'Bikaner'];
    default:
      return [];
  }
}
