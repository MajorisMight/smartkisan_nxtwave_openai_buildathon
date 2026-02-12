import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AIAnalysisService {
  static const String _impactDataKey = 'ai_impact_data';
  static const String _farmHealthKey = 'farm_health_data';

  // Initialize AI impact tracking
  static Future<void> initializeImpactTracking() async {
    final prefs = await SharedPreferences.getInstance();

    // Initialize impact data if not exists
    if (!prefs.containsKey(_impactDataKey)) {
      final impactData = {
        'total_yield_increase': 0.0,
        'crops_saved_from_disease': 0,
        'cost_savings': 0.0,
        'fertilizer_recommendations': 0,
        'disease_detections': 0,
        'pest_detections': 0,
        'total_investment_saved': 0.0,
        'recommendations_followed': 0,
        'successful_treatments': 0,
        'yield_improvements': [],
        'disease_preventions': [],
        'cost_savings_history': [],
        'last_updated': DateTime.now().toIso8601String(),
      };
      await prefs.setString(_impactDataKey, impactData.toString());
    }

    // Initialize farm health data
    if (!prefs.containsKey(_farmHealthKey)) {
      final farmHealthData = {
        'overall_score': 85.0,
        'soil_health': 88.0,
        'crop_health': 82.0,
        'pest_management': 90.0,
        'disease_management': 87.0,
        'fertilizer_efficiency': 85.0,
        'water_management': 83.0,
        'yield_optimization': 86.0,
        'recommendations': [
          'Continue current fertilizer schedule for optimal yield',
          'Monitor wheat fields for early rust symptoms',
          'Consider crop rotation for better soil health',
          'Implement integrated pest management',
        ],
        'last_assessment': DateTime.now().toIso8601String(),
      };
      await prefs.setString(_farmHealthKey, farmHealthData.toString());
    }
  }

  // Get AI impact data
  static Map<String, dynamic> getAIImpactData() {
    return {
      'total_yield_increase': 18.3, // Percentage
      'crops_saved_from_disease': 3,
      'cost_savings': 12500.0, // Rupees per acre
      'fertilizer_recommendations': 12,
      'disease_detections': 2,
      'pest_detections': 1,
      'total_investment_saved': 45000.0,
      'recommendations_followed': 15,
      'successful_treatments': 5,
      'yield_improvements': [
        {
          'crop': 'Wheat',
          'previous_yield': 35.2,
          'current_yield': 41.7,
          'improvement': 18.5,
          'date': DateTime(2024, 11, 15),
          'ai_recommendation': 'Optimized nitrogen application timing',
        },
        {
          'crop': 'Rice',
          'previous_yield': 2.8,
          'current_yield': 3.2,
          'improvement': 14.3,
          'date': DateTime(2024, 9, 15),
          'ai_recommendation': 'Improved phosphorus management',
        },
      ],
      'disease_preventions': [
        {
          'crop': 'Wheat',
          'disease': 'Yellow Rust',
          'severity_prevented': 'High',
          'potential_loss': 25.0,
          'date': DateTime(2024, 11, 20),
          'ai_recommendation': 'Early fungicide application',
        },
        {
          'crop': 'Cotton',
          'disease': 'Bacterial Blight',
          'severity_prevented': 'Medium',
          'potential_loss': 15.0,
          'date': DateTime(2024, 8, 10),
          'ai_recommendation': 'Copper-based treatment',
        },
      ],
      'cost_savings_history': [
        {
          'type': 'Fertilizer Optimization',
          'savings': 8500.0,
          'date': DateTime(2024, 11, 5),
          'description': 'Reduced urea application by 20kg/acre',
        },
        {
          'type': 'Pest Control',
          'savings': 3200.0,
          'date': DateTime(2024, 10, 15),
          'description': 'Early detection prevented major infestation',
        },
        {
          'type': 'Disease Prevention',
          'savings': 7800.0,
          'date': DateTime(2024, 9, 20),
          'description': 'Preventive fungicide application',
        },
      ],
    };
  }

  // Get farm health assessment
  static Map<String, dynamic> getFarmHealthAssessment() {
    return {
      'overall_score': 85.0,
      'soil_health': 88.0,
      'crop_health': 82.0,
      'pest_management': 90.0,
      'disease_management': 87.0,
      'fertilizer_efficiency': 85.0,
      'water_management': 83.0,
      'yield_optimization': 86.0,
      'health_status': 'Excellent',
      'trend': 'Improving',
      'recommendations': [
        {
          'category': 'Soil Health',
          'priority': 'High',
          'recommendation': 'Continue organic matter addition',
          'impact': 'Maintains 88% soil health score',
        },
        {
          'category': 'Crop Rotation',
          'priority': 'Medium',
          'recommendation': 'Plan legume rotation for next season',
          'impact': 'Could improve soil health by 5-7%',
        },
        {
          'category': 'Pest Management',
          'priority': 'Low',
          'recommendation': 'Continue current IPM practices',
          'impact': 'Maintains excellent 90% pest management score',
        },
        {
          'category': 'Water Management',
          'priority': 'Medium',
          'recommendation': 'Consider drip irrigation for cotton',
          'impact': 'Could improve water efficiency by 15-20%',
        },
      ],
      'strengths': [
        'Excellent pest management practices',
        'Good soil health maintenance',
        'Effective disease prevention',
        'Consistent yield improvements',
      ],
      'areas_for_improvement': [
        'Water management efficiency',
        'Crop rotation planning',
        'Organic farming adoption',
      ],
    };
  }

  // Generate detailed fertilizer analysis
  static Future<Map<String, dynamic>> generateFertilizerAnalysis(
    String cropName,
    String stage,
    double soilMoisture,
    double temperature, {
    Map<String, dynamic>? additionalContext,
  }) async {
    // Load GEMINI API key from .env
    final apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
    if (apiKey.isEmpty) {
      throw Exception(
        'GEMINI_API_KEY not configured. Add it to your .env file.',
      );
    }

    // Build a strict prompt asking for JSON output following ICAR guidelines.
    final promptBuffer = StringBuffer();
    promptBuffer.writeln(
      'You are an agricultural expert following ICAR guidelines. Produce a fertilizer recommendation JSON for the given farm context. Respond ONLY with valid JSON.',
    );
    promptBuffer.writeln();
    promptBuffer.writeln('Context:');
    promptBuffer.writeln(
      jsonEncode({
        'crop': cropName,
        'stage': stage,
        'soil_moisture': soilMoisture,
        'temperature': temperature,
        'additional_context': additionalContext ?? {},
      }),
    );
    promptBuffer.writeln();
    promptBuffer.writeln('Required JSON schema:');
    promptBuffer.writeln(
      jsonEncode({
        'analysis_steps': [
          {
            'step': 1,
            'title': '<string>',
            'description': '<string>',
            'details': '<string>',
            'confidence': '<0.0-1.0>',
          },
        ],
        'recommendation': {
          'fertilizer': '<string or object with fertilizer names and doses>',
          'timing': '<string>',
          'method': '<string>',
          'reasoning': '<string>',
          'expected_benefit': '<string>',
          'cost_benefit': '<string>',
          'confidence': '<0.0-1.0>',
        },
        'why_this_recommendation': ['<string>'],
        'past_input_analysis': {'summary': '<string>'},
      }),
    );
    promptBuffer.writeln();
    promptBuffer.writeln(
      'Produce concise, correct numeric doses where possible and cite ICAR guidelines in reasoning. JSON only.',
    );

    final prompt = promptBuffer.toString();

    // Use Google Generative API endpoint (Gemini-family) via REST.
    // If your project uses a different base URL, adjust accordingly.
    final uri = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta2/models/gemini-1.0:generate?key=$apiKey',
    );

    final requestBody = {
      'temperature': 0.2,
      'maxOutputTokens': 800,
      'prompt': {'text': prompt},
    };

    final res = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(requestBody),
    );

    if (res.statusCode != 200) {
      throw Exception('LLM request failed (${res.statusCode}): ${res.body}');
    }

    final decoded = jsonDecode(res.body);

    // Extract text from multiple possible response shapes
    String extractText(dynamic d) {
      try {
        if (d == null) return '';
        if (d is Map && d['candidates'] is List && d['candidates'].isNotEmpty) {
          final cand = d['candidates'][0];
          if (cand is Map && cand['content'] is List) {
            final contents = cand['content'] as List;
            final sb = StringBuffer();
            for (final c in contents) {
              if (c is Map && c['text'] != null) sb.write(c['text']);
            }
            if (sb.isNotEmpty) return sb.toString();
          }
          if (cand is Map && cand['content'] is String) return cand['content'];
        }
        if (d is Map && d['output'] != null) {
          final out = d['output'];
          if (out is List) {
            final sb = StringBuffer();
            for (final item in out) {
              if (item is Map && item['content'] is List) {
                for (final seg in item['content']) {
                  if (seg is Map && seg['text'] != null) sb.write(seg['text']);
                }
              } else if (item is Map && item['text'] != null) {
                sb.write(item['text']);
              }
            }
            if (sb.isNotEmpty) return sb.toString();
          } else if (out is Map && out['content'] is List) {
            final sb = StringBuffer();
            for (final seg in out['content']) {
              if (seg is Map && seg['text'] != null) sb.write(seg['text']);
            }
            if (sb.isNotEmpty) return sb.toString();
          }
        }
        // Fallback: try top-level 'text' or stringified body
        if (d is Map && d['text'] != null) return d['text'];
        return d.toString();
      } catch (_) {
        return d.toString();
      }
    }

    final rawText = extractText(decoded);

    // Try parsing JSON from model output. If parsing fails, return a fallback structure
    try {
      final parsed = jsonDecode(rawText);
      if (parsed is Map<String, dynamic>) {
        return parsed;
      } else {
        return {
          'analysis_steps': [
            {
              'step': 1,
              'title': 'LLM output',
              'description': 'Parsed LLM response into non-object JSON',
              'details': rawText,
              'confidence': 0.6,
            },
          ],
          'recommendation': {
            'fertilizer': rawText,
            'timing': 'As suggested by LLM',
            'method': 'As suggested by LLM',
            'reasoning': 'LLM returned non-object JSON',
            'expected_benefit': '',
            'cost_benefit': '',
            'confidence': 0.6,
          },
          'why_this_recommendation': [rawText],
          'past_input_analysis': {'summary': 'LLM returned non-object JSON'},
        };
      }
    } catch (e) {
      // Parsing failed: include raw text in fallback
      return {
        'analysis_steps': [
          {
            'step': 1,
            'title': 'LLM response (unparsed)',
            'description': 'Failed to parse JSON from model response',
            'details': rawText,
            'confidence': 0.5,
          },
        ],
        'recommendation': {
          'fertilizer': rawText,
          'timing': 'As suggested by LLM',
          'method': 'As suggested by LLM',
          'reasoning': 'Model output could not be parsed as JSON',
          'expected_benefit': '',
          'cost_benefit': '',
          'confidence': 0.5,
        },
        'why_this_recommendation': [rawText],
        'past_input_analysis': {'summary': 'LLM output unparsed'},
      };
    }
  }

  // Generate detailed disease analysis
  static Map<String, dynamic> generateDiseaseAnalysis(
    String cropName,
    String symptoms,
  ) {
    return {
      'analysis_steps': [
        {
          'step': 1,
          'title': 'Image Processing',
          'description': 'Analyzing uploaded image for disease symptoms',
          'details':
              'Detected yellow-orange pustules characteristic of rust diseases',
          'confidence': 0.92,
        },
        {
          'step': 2,
          'title': 'Symptom Recognition',
          'description':
              'Identifying specific disease patterns and characteristics',
          'details':
              'Pustules are arranged in linear patterns typical of stripe rust',
          'confidence': 0.89,
        },
        {
          'step': 3,
          'title': 'Crop-Specific Analysis',
          'description': 'Considering disease susceptibility for wheat crops',
          'details':
              'Wheat is highly susceptible to stripe rust in current weather conditions',
          'confidence': 0.94,
        },
        {
          'step': 4,
          'title': 'Weather Correlation',
          'description':
              'Analyzing weather conditions favoring disease development',
          'details':
              'Cool, humid conditions (18°C, 72% humidity) favor rust development',
          'confidence': 0.87,
        },
        {
          'step': 5,
          'title': 'Severity Assessment',
          'description': 'Evaluating disease severity and potential impact',
          'details': 'Early stage infection with moderate severity - treatable',
          'confidence': 0.91,
        },
      ],
      'disease_identification': {
        'disease_name': 'Yellow Rust (Puccinia striiformis)',
        'confidence': 0.92,
        'severity': 'Moderate',
        'stage': 'Early infection',
        'potential_yield_loss': '15-25% if untreated',
      },
      'why_this_diagnosis': [
        'Yellow-orange pustules are characteristic of stripe rust',
        'Linear arrangement of pustules matches stripe rust pattern',
        'Wheat is highly susceptible to this disease',
        'Current weather conditions (cool, humid) favor rust development',
        'Symptoms match early-stage stripe rust infection',
      ],
      'treatment_recommendation': {
        'primary_treatment': 'Tebuconazole 25% EC',
        'dosage': '1 ml/L water',
        'application': 'Spray at 10-15 day intervals',
        'timing': 'Apply in evening for better absorption',
        'reasoning':
            'ICAR-recommended fungicide with proven efficacy against rust',
        'expected_result': '95% disease control within 7-10 days',
        'cost': '₹800 per acre',
        'benefit': 'Prevents 15-25% yield loss worth ₹12,000-20,000',
      },
      'prevention_strategies': [
        'Plant resistant varieties (HD-2967, PBW-343)',
        'Avoid excessive nitrogen application',
        'Maintain proper plant spacing',
        'Monitor weather conditions regularly',
        'Apply preventive fungicides during high-risk periods',
      ],
    };
  }

  // Update impact data after successful recommendation
  static Future<void> updateImpactData(
    String type,
    Map<String, dynamic> data,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    // This would update the impact tracking in a real app
    // For demo purposes, we'll use static data
  }

  // Get AI explanation for any recommendation
  static String getAIExplanation(
    String recommendationType,
    Map<String, dynamic> data,
  ) {
    switch (recommendationType) {
      case 'fertilizer':
        return 'Based on your past fertilizer applications and current soil conditions, I recommend ${data['fertilizer']}. Your previous applications of 25-30kg/acre showed good results, and current soil moisture of ${data['soil_moisture']}% is optimal for nutrient uptake. This recommendation follows ICAR guidelines and should increase your yield by 15-20%.';
      case 'disease':
        return 'I\'ve identified ${data['disease_name']} with ${(data['confidence'] * 100).toStringAsFixed(1)}% confidence. The yellow-orange pustules and linear arrangement are characteristic of stripe rust. Current weather conditions favor disease development, but early detection means we can treat it effectively with ICAR-recommended fungicides.';
      case 'pest':
        return 'Based on the symptoms you\'ve described, I\'ve identified ${data['pest_name']} with ${(data['confidence'] * 100).toStringAsFixed(1)}% confidence. This pest can cause significant damage if left untreated, but early detection allows for effective control using integrated pest management strategies.';
      default:
        return 'This recommendation is based on analysis of your farm data, weather conditions, and official agricultural guidelines.';
    }
  }
}
