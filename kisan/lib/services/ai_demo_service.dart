import 'package:shared_preferences/shared_preferences.dart';
import '../models/disease.dart';

class AIDemoService {
  static const String _demoModeKey = 'demo_mode_enabled';
  static const String _onboardingCompletedKey = 'onboarding_completed';
  static const String _weeklyLogsKey = 'weekly_logs_data';
  
  // Enable demo mode - bypasses OTP and onboarding
  static Future<void> enableDemoMode() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_demoModeKey, true);
    await prefs.setBool(_onboardingCompletedKey, true);
    await _initializeWeeklyLogs();
  }
  
  // Check if demo mode is enabled
  static Future<bool> isDemoModeEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_demoModeKey) ?? false;
  }
  
  // Initialize weekly logs showing model training data
  static Future<void> _initializeWeeklyLogs() async {
    final prefs = await SharedPreferences.getInstance();
    final weeklyLogs = [
      {
        'date': DateTime(2024, 11, 1).toIso8601String(),
        'crop': 'Wheat',
        'stage': 'Vegetative',
        'soil_moisture': 65.2,
        'temperature': 18.5,
        'rainfall': 0.0,
        'fertilizer_applied': 'Urea 25kg',
        'pest_issues': 'None',
        'disease_issues': 'None',
        'yield_prediction': 'Good',
        'ai_confidence': 0.87,
      },
      {
        'date': DateTime(2024, 11, 8).toIso8601String(),
        'crop': 'Wheat',
        'stage': 'Tillering',
        'soil_moisture': 58.7,
        'temperature': 16.2,
        'rainfall': 2.5,
        'fertilizer_applied': 'DAP 20kg',
        'pest_issues': 'Minor aphid activity',
        'disease_issues': 'None',
        'yield_prediction': 'Good',
        'ai_confidence': 0.91,
      },
      {
        'date': DateTime(2024, 11, 15).toIso8601String(),
        'crop': 'Wheat',
        'stage': 'Stem Elongation',
        'soil_moisture': 62.1,
        'temperature': 19.8,
        'rainfall': 0.0,
        'fertilizer_applied': 'Urea 30kg',
        'pest_issues': 'None',
        'disease_issues': 'None',
        'yield_prediction': 'Excellent',
        'ai_confidence': 0.94,
      },
      {
        'date': DateTime(2024, 11, 22).toIso8601String(),
        'crop': 'Wheat',
        'stage': 'Heading',
        'soil_moisture': 59.3,
        'temperature': 17.4,
        'rainfall': 1.2,
        'fertilizer_applied': 'Potash 15kg',
        'pest_issues': 'None',
        'disease_issues': 'None',
        'yield_prediction': 'Excellent',
        'ai_confidence': 0.96,
      },
      {
        'date': DateTime(2024, 11, 29).toIso8601String(),
        'crop': 'Wheat',
        'stage': 'Flowering',
        'soil_moisture': 61.8,
        'temperature': 18.9,
        'rainfall': 0.0,
        'fertilizer_applied': 'None',
        'pest_issues': 'None',
        'disease_issues': 'None',
        'yield_prediction': 'Excellent',
        'ai_confidence': 0.98,
      },
    ];
    await prefs.setString(_weeklyLogsKey, weeklyLogs.toString());
  }
  
  // Get weekly logs for AI model training display
  static List<Map<String, dynamic>> getWeeklyLogs() {
    return [
      {
        'date': DateTime(2024, 11, 1),
        'crop': 'Wheat',
        'stage': 'Vegetative',
        'soil_moisture': 65.2,
        'temperature': 18.5,
        'rainfall': 0.0,
        'fertilizer_applied': 'Urea 25kg',
        'pest_issues': 'None',
        'disease_issues': 'None',
        'yield_prediction': 'Good',
        'ai_confidence': 0.87,
      },
      {
        'date': DateTime(2024, 11, 8),
        'crop': 'Wheat',
        'stage': 'Tillering',
        'soil_moisture': 58.7,
        'temperature': 16.2,
        'rainfall': 2.5,
        'fertilizer_applied': 'DAP 20kg',
        'pest_issues': 'Minor aphid activity',
        'disease_issues': 'None',
        'yield_prediction': 'Good',
        'ai_confidence': 0.91,
      },
      {
        'date': DateTime(2024, 11, 15),
        'crop': 'Wheat',
        'stage': 'Stem Elongation',
        'soil_moisture': 62.1,
        'temperature': 19.8,
        'rainfall': 0.0,
        'fertilizer_applied': 'Urea 30kg',
        'pest_issues': 'None',
        'disease_issues': 'None',
        'yield_prediction': 'Excellent',
        'ai_confidence': 0.94,
      },
      {
        'date': DateTime(2024, 11, 22),
        'crop': 'Wheat',
        'stage': 'Heading',
        'soil_moisture': 59.3,
        'temperature': 17.4,
        'rainfall': 1.2,
        'fertilizer_applied': 'Potash 15kg',
        'pest_issues': 'None',
        'disease_issues': 'None',
        'yield_prediction': 'Excellent',
        'ai_confidence': 0.96,
      },
      {
        'date': DateTime(2024, 11, 29),
        'crop': 'Wheat',
        'stage': 'Flowering',
        'soil_moisture': 61.8,
        'temperature': 18.9,
        'rainfall': 0.0,
        'fertilizer_applied': 'None',
        'pest_issues': 'None',
        'disease_issues': 'None',
        'yield_prediction': 'Excellent',
        'ai_confidence': 0.98,
      },
    ];
  }

  // AI-Powered Fertilizer Recommendations based on ICAR guidelines
  static Map<String, dynamic> getAIFertilizerRecommendation(String cropName, String stage, double soilMoisture, double temperature) {
    // ICAR Guidelines for Wheat Fertilization
    if (cropName.toLowerCase() == 'wheat') {
      switch (stage.toLowerCase()) {
        case 'vegetative':
          return {
            'recommendation': 'Apply Nitrogen (N) at 60-80 kg/ha',
            'specific_fertilizer': 'Urea 130-175 kg/ha',
            'timing': 'Apply in 2-3 split doses',
            'method': 'Broadcast or drill application',
            'icar_guideline': 'ICAR recommends 60-80 kg N/ha for wheat in Punjab',
            'ai_confidence': 0.94,
            'soil_condition': 'Optimal soil moisture (${soilMoisture.toStringAsFixed(1)}%)',
            'weather_factor': 'Temperature ${temperature.toStringAsFixed(1)}°C is suitable for nitrogen uptake',
            'expected_yield_increase': '15-20%',
            'cost_benefit': '₹2,500 investment for ₹8,000 additional yield',
          };
        case 'tillering':
          return {
            'recommendation': 'Apply Phosphorus (P) at 40-50 kg/ha',
            'specific_fertilizer': 'DAP 87-109 kg/ha',
            'timing': 'Apply at tillering stage',
            'method': 'Placement near root zone',
            'icar_guideline': 'ICAR recommends 40-50 kg P2O5/ha for wheat',
            'ai_confidence': 0.91,
            'soil_condition': 'Good soil moisture for phosphorus availability',
            'weather_factor': 'Cool temperature favors phosphorus uptake',
            'expected_yield_increase': '12-18%',
            'cost_benefit': '₹1,800 investment for ₹6,000 additional yield',
          };
        case 'stem elongation':
          return {
            'recommendation': 'Apply Potassium (K) at 30-40 kg/ha',
            'specific_fertilizer': 'MOP 50-67 kg/ha',
            'timing': 'Apply during stem elongation',
            'method': 'Broadcast application',
            'icar_guideline': 'ICAR recommends 30-40 kg K2O/ha for wheat',
            'ai_confidence': 0.89,
            'soil_condition': 'Soil moisture optimal for potassium mobility',
            'weather_factor': 'Temperature supports potassium uptake',
            'expected_yield_increase': '10-15%',
            'cost_benefit': '₹1,200 investment for ₹4,500 additional yield',
          };
        default:
          return {
            'recommendation': 'Monitor crop stage and apply balanced nutrition',
            'specific_fertilizer': 'NPK 20:20:20 at 25 kg/ha',
            'timing': 'Apply based on crop growth stage',
            'method': 'Foliar spray or soil application',
            'icar_guideline': 'ICAR recommends balanced nutrition for optimal yield',
            'ai_confidence': 0.85,
            'soil_condition': 'Maintain soil moisture for nutrient availability',
            'weather_factor': 'Monitor weather conditions for application timing',
            'expected_yield_increase': '8-12%',
            'cost_benefit': '₹1,000 investment for ₹3,000 additional yield',
          };
      }
    }
    
    // Default recommendation
    return {
      'recommendation': 'Apply balanced NPK fertilizer',
      'specific_fertilizer': 'NPK 19:19:19 at 50 kg/ha',
      'timing': 'Apply during active growth period',
      'method': 'Broadcast or placement',
      'icar_guideline': 'ICAR recommends balanced nutrition for all crops',
      'ai_confidence': 0.82,
      'soil_condition': 'Monitor soil conditions regularly',
      'weather_factor': 'Consider weather conditions for application',
      'expected_yield_increase': '10-15%',
      'cost_benefit': '₹2,000 investment for ₹5,000 additional yield',
    };
  }

  // AI-Powered Disease Detection with ICAR guidelines
  static DiseaseDetectionResult getAIDiseaseDetection(String cropName, String symptoms) {
    // ICAR Guidelines for Wheat Disease Management
    if (cropName.toLowerCase() == 'wheat') {
      if (symptoms.toLowerCase().contains('yellow') || symptoms.toLowerCase().contains('rust')) {
        return DiseaseDetectionResult(
          diseaseName: 'Yellow Rust (Puccinia striiformis)',
          confidence: 0.92,
          remedies: [
            Remedy(
              type: 'chemical',
              name: 'Tebuconazole 25% EC',
              instruction: 'Apply 1 ml/L water, spray at 10-15 day intervals. ICAR recommended fungicide.',
              marketplaceQuery: 'Tebuconazole fungicide',
            ),
            Remedy(
              type: 'organic',
              name: 'Neem Oil + Garlic Extract',
              instruction: 'Mix 5ml neem oil + 10ml garlic extract per liter. Apply weekly.',
              marketplaceQuery: 'Neem oil organic fungicide',
            ),
            Remedy(
              type: 'cultural',
              name: 'Resistant Varieties',
              instruction: 'Plant HD-2967, PBW-343 varieties as per ICAR recommendations.',
              marketplaceQuery: 'Wheat resistant varieties',
            ),
          ],
        );
      } else if (symptoms.toLowerCase().contains('brown') || symptoms.toLowerCase().contains('spot')) {
        return DiseaseDetectionResult(
          diseaseName: 'Brown Spot (Bipolaris sorokiniana)',
          confidence: 0.88,
          remedies: [
            Remedy(
              type: 'chemical',
              name: 'Mancozeb 75% WP',
              instruction: 'Apply 2g/L water, spray every 7-10 days. ICAR approved fungicide.',
              marketplaceQuery: 'Mancozeb fungicide',
            ),
            Remedy(
              type: 'organic',
              name: 'Copper-based Fungicide',
              instruction: 'Apply copper oxychloride 3g/L water, spray weekly.',
              marketplaceQuery: 'Copper fungicide organic',
            ),
            Remedy(
              type: 'cultural',
              name: 'Crop Rotation',
              instruction: 'Practice 2-year crop rotation with legumes as per ICAR guidelines.',
              marketplaceQuery: 'Crop rotation seeds',
            ),
          ],
        );
      }
    }
    
    // Default disease detection
    return DiseaseDetectionResult(
      diseaseName: 'General Plant Disease',
      confidence: 0.75,
      remedies: [
        Remedy(
          type: 'organic',
          name: 'Neem Oil Spray',
          instruction: 'Apply 5ml/L water, spray in evening, repeat after 7 days',
          marketplaceQuery: 'Neem Oil',
        ),
        Remedy(
          type: 'chemical',
          name: 'Broad Spectrum Fungicide',
          instruction: 'Apply as per label instructions, follow ICAR guidelines',
          marketplaceQuery: 'Broad spectrum fungicide',
        ),
      ],
    );
  }

  // AI-Powered Pest Detection with ICAR guidelines
  static Map<String, dynamic> getAIPestDetection(String cropName, String pestSymptoms) {
    if (cropName.toLowerCase() == 'wheat') {
      if (pestSymptoms.toLowerCase().contains('aphid')) {
        return {
          'pest_name': 'Wheat Aphid (Sitobion avenae)',
          'confidence': 0.91,
          'icar_threshold': 'ICAR threshold: 5-10 aphids per tiller',
          'damage_potential': 'High - Can cause 20-30% yield loss',
          'recommendations': [
            {
              'type': 'chemical',
              'name': 'Imidacloprid 17.8% SL',
              'instruction': 'Apply 0.5ml/L water, spray in evening. ICAR recommended insecticide.',
              'marketplace_query': 'Imidacloprid insecticide',
            },
            {
              'type': 'organic',
              'name': 'Neem Oil + Soap Solution',
              'instruction': 'Mix 5ml neem oil + 2ml soap per liter. Apply weekly.',
              'marketplace_query': 'Neem oil organic pesticide',
            },
            {
              'type': 'biological',
              'name': 'Ladybird Beetles',
              'instruction': 'Release 1000 ladybird beetles per acre as per ICAR guidelines.',
              'marketplace_query': 'Ladybird beetles biological control',
            },
          ],
          'prevention': 'Plant early, use resistant varieties, maintain field hygiene',
          'economic_threshold': 'Apply when 5-10 aphids per tiller observed',
        };
      } else if (pestSymptoms.toLowerCase().contains('armyworm')) {
        return {
          'pest_name': 'Armyworm (Mythimna separata)',
          'confidence': 0.89,
          'icar_threshold': 'ICAR threshold: 2-3 larvae per square meter',
          'damage_potential': 'Very High - Can cause 40-50% yield loss',
          'recommendations': [
            {
              'type': 'chemical',
              'name': 'Chlorantraniliprole 18.5% SC',
              'instruction': 'Apply 1ml/L water, spray in evening. ICAR recommended insecticide.',
              'marketplace_query': 'Chlorantraniliprole insecticide',
            },
            {
              'type': 'organic',
              'name': 'Bacillus thuringiensis',
              'instruction': 'Apply 2g/L water, spray weekly. Organic control method.',
              'marketplace_query': 'Bacillus thuringiensis organic',
            },
            {
              'type': 'cultural',
              'name': 'Deep Plowing',
              'instruction': 'Deep plow after harvest to destroy pupae as per ICAR guidelines.',
              'marketplace_query': 'Deep plowing equipment',
            },
          ],
          'prevention': 'Monitor regularly, use pheromone traps, maintain field hygiene',
          'economic_threshold': 'Apply when 2-3 larvae per square meter observed',
        };
      }
    }
    
    // Default pest detection
    return {
      'pest_name': 'General Pest Infestation',
      'confidence': 0.78,
      'icar_threshold': 'Monitor regularly as per ICAR guidelines',
      'damage_potential': 'Moderate - Monitor for escalation',
      'recommendations': [
        {
          'type': 'organic',
          'name': 'Neem Oil Spray',
          'instruction': 'Apply 5ml/L water, spray weekly for prevention',
          'marketplace_query': 'Neem oil pesticide',
        },
        {
          'type': 'chemical',
          'name': 'Broad Spectrum Insecticide',
          'instruction': 'Apply as per label instructions and ICAR guidelines',
          'marketplace_query': 'Broad spectrum insecticide',
        },
      ],
      'prevention': 'Regular monitoring, field hygiene, resistant varieties',
      'economic_threshold': 'Apply when economic threshold is reached',
    };
  }

  // Get AI Model Performance Metrics
  static Map<String, dynamic> getAIModelMetrics() {
    return {
      'model_accuracy': 94.2,
      'training_data_points': 2847,
      'last_updated': DateTime(2024, 11, 30),
      'crop_coverage': ['Wheat', 'Rice', 'Cotton', 'Mustard'],
      'feature_accuracy': {
        'fertilizer_recommendation': 96.8,
        'disease_detection': 92.4,
        'pest_detection': 89.7,
        'yield_prediction': 91.3,
      },
      'icar_compliance': 98.5,
      'farmer_satisfaction': 4.7,
      'cost_savings': '₹12,500 per acre average',
      'yield_improvement': '18.3% average increase',
    };
  }

  // Clear demo mode (for testing)
  static Future<void> clearDemoMode() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_demoModeKey);
    await prefs.remove(_onboardingCompletedKey);
    await prefs.remove(_weeklyLogsKey);
  }
}
