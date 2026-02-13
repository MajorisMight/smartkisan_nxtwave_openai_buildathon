import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import 'package:kisan/services/gemini_service.dart';
import '../models/crop.dart';

// State class for fertilizer screen
class FertilizerState {
  final String selectedGrowthStage;
  final String selectedIrrigationType;
  final String selectedSoilType;
  final bool hasCalculated;
  final bool isCalculating;
  final Map<String, dynamic>? fertilizerResults;
  final Map<String, double>? soilTestValues;
  final File? soilTestFile;
  final String? errorMessage;

  const FertilizerState({
    this.selectedGrowthStage = 'Flowering',
    this.selectedIrrigationType = 'Rainfed',
    this.selectedSoilType = 'Not provided',
    this.hasCalculated = false,
    this.isCalculating = false,
    this.fertilizerResults,
    this.soilTestValues,
    this.soilTestFile,
    this.errorMessage,
  });

  FertilizerState copyWith({
    String? selectedGrowthStage,
    String? selectedIrrigationType,
    String? selectedSoilType,
    bool? hasCalculated,
    bool? isCalculating,
    Map<String, dynamic>? fertilizerResults,
    Map<String, double>? soilTestValues,
    File? soilTestFile,
    String? errorMessage,
  }) {
    return FertilizerState(
      selectedGrowthStage: selectedGrowthStage ?? this.selectedGrowthStage,
      selectedIrrigationType: selectedIrrigationType ?? this.selectedIrrigationType,
      selectedSoilType: selectedSoilType ?? this.selectedSoilType,
      hasCalculated: hasCalculated ?? this.hasCalculated,
      isCalculating: isCalculating ?? this.isCalculating,
      fertilizerResults: fertilizerResults ?? this.fertilizerResults,
      soilTestValues: soilTestValues ?? this.soilTestValues,
      soilTestFile: soilTestFile ?? this.soilTestFile,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

// StateNotifier for managing fertilizer screen state
class FertilizerStateNotifier extends StateNotifier<FertilizerState> {
  FertilizerStateNotifier() : super(const FertilizerState());

  // Constants
  static const List<String> growthStages = [
    'Germination',
    'Vegetative',
    'Flowering',
    'Fruiting',
    'Harvest prep',
  ];

  static const List<String> irrigationTypes = [
    'Rainfed',
    'Canal',
    'Tubewell',
    'Sprinkler',
    'Drip',
  ];

  static const List<String> soilTypes = [
    'Sandy',
    'Loam',
    'Clay',
    'Mixed',
    'Not provided',
  ];

  // Initialize form based on crop data
  void initializeForm(Crop crop) {
    String initialGrowthStage = 'Flowering';
    
    switch (crop.stage.toLowerCase()) {
      case 'sowing':
        initialGrowthStage = 'Germination';
        break;
      case 'growth':
        initialGrowthStage = 'Vegetative';
        break;
      case 'fertilizer':
        initialGrowthStage = 'Flowering';
        break;
      case 'harvest':
        initialGrowthStage = 'Harvest prep';
        break;
      default:
        initialGrowthStage = 'Flowering';
    }

    state = state.copyWith(
      selectedGrowthStage: initialGrowthStage,
    );
  }

  // Update growth stage
  void updateGrowthStage(String stage) {
    state = state.copyWith(selectedGrowthStage: stage);
  }

  // Update irrigation type
  void updateIrrigationType(String type) {
    state = state.copyWith(selectedIrrigationType: type);
  }

  // Update soil type
  void updateSoilType(String type) {
    state = state.copyWith(selectedSoilType: type);
  }

  // Update soil test data
  void updateSoilTestData(Map<String, double>? values, File? file) {
    state = state.copyWith(
      soilTestValues: values,
      soilTestFile: file,
      errorMessage: null,
    );
  }

  // Clear error message
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  // Validate inputs before calculation
  bool validateInputs() {
    if ((state.soilTestValues == null || state.soilTestValues!.isEmpty) && 
        state.soilTestFile == null) {
      state = state.copyWith(
        errorMessage: 'Please provide soil test results (values or attach a file) before calculating.',
      );
      return false;
    }
    return true;
  }

  // Calculate fertilizer requirement
  Future<void> calculateFertilizer(Crop crop, String area) async {
    if (!validateInputs()) return;

    state = state.copyWith(
      isCalculating: true,
      errorMessage: null,
    );

    try {
      final areaValue = double.tryParse(area) ?? crop.areaAcres ?? 1.0;

      final contextData = {
        'crop_name': crop.name,
        'growth_stage': state.selectedGrowthStage,
        'area_acres': crop.areaAcres,
        'location': crop.location,
        'irrigation_type': state.selectedIrrigationType,
        'soil_type': state.selectedSoilType,
        'soil_test_values': state.soilTestValues ?? {},
      };

      debugPrint("Calling Fertilizer Plan with context: $contextData");
      final analysis = await GeminiService.fertilizerPlan(contextData: contextData);
      debugPrint("Fertilizer analysis received");

      _processAnalysisResults(analysis);
    } catch (e) {
      state = state.copyWith(
        isCalculating: false,
        errorMessage: 'Calculation failed: ${e.toString()}',
      );
    }
  }

  // Process analysis results
  void _processAnalysisResults(Map<String, dynamic> analysis) {
    try {
      state = state.copyWith(
        hasCalculated: true,
        isCalculating: false,
        fertilizerResults: {'analysis': analysis},
        errorMessage: null,
      );
    } catch (e, stackTrace) {
      debugPrint('Error parsing fertilizer analysis: $e\n$stackTrace\nRaw analysis: $analysis');
      
      state = state.copyWith(
        hasCalculated: true,
        isCalculating: false,
        fertilizerResults: {
          'analysis': {
            'fertilizer_items': [
              {'name': 'Unable to parse recommendation', 'quantity': '', 'note': ''}
            ],
            'split_schedule': [],
            'why_this_recommendation': 'Parsing failed: ${e.toString()}',
            'caution': 'Error in analysis processing',
            'confidence': 'Low',
            'basis': 'Raw AI output',
          },
        },
        errorMessage: 'Failed to parse analysis results',
      );
    }
  }

  // Reset calculation state
  void resetCalculation() {
    state = state.copyWith(
      hasCalculated: false,
      isCalculating: false,
      fertilizerResults: null,
      errorMessage: null,
    );
  }

  // Reset all state to initial values
  void resetState() {
    state = const FertilizerState();
  }
}

// Providers
final fertilizerStateProvider = StateNotifierProvider<FertilizerStateNotifier, FertilizerState>(
  (ref) => FertilizerStateNotifier(),
);

// Computed providers for UI state
final canCalculateProvider = Provider<bool>((ref) {
  final state = ref.watch(fertilizerStateProvider);
  return !state.isCalculating && 
         ((state.soilTestValues != null && state.soilTestValues!.isNotEmpty) || 
          state.soilTestFile != null);
});

final hasErrorProvider = Provider<bool>((ref) {
  final state = ref.watch(fertilizerStateProvider);
  return state.errorMessage != null;
});

final errorMessageProvider = Provider<String?>((ref) {
  final state = ref.watch(fertilizerStateProvider);
  return state.errorMessage;
});

final isLoadingProvider = Provider<bool>((ref) {
  final state = ref.watch(fertilizerStateProvider);
  return state.isCalculating;
});

final hasResultsProvider = Provider<bool>((ref) {
  final state = ref.watch(fertilizerStateProvider);
  return state.hasCalculated && state.fertilizerResults != null;
});

final soilTestStatusProvider = Provider<String>((ref) {
  final state = ref.watch(fertilizerStateProvider);
  
  if (state.soilTestValues != null && state.soilTestValues!.isNotEmpty) {
    final count = state.soilTestValues!.length;
    return 'Manual values ($count parameters)';
  } else if (state.soilTestFile != null) {
    final fileName = state.soilTestFile!.path.split('/').last;
    return 'File attached: $fileName';
  } else {
    return 'No soil test data';
  }
});