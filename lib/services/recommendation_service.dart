import 'dart:convert';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/onboarding_profile.dart';
import 'ai_provider.dart';
import 'gemini_service.dart';
import 'gpt_service.dart';

//filters data from the profile and adds contextual information

class RecommendationService {
  static const String diseaseStatusIdentified = 'IDENTIFIED';
  static const String diseaseStatusDidNotIdentify = 'DID_NOT_IDENTIFY';
  static const String diseaseStatusIrrelevant = 'IRRELEVANT';

  static AIProvider _defaultProvider = aiProviderFromString(
    dotenv.env['AI_PROVIDER'],
  );

  static AIProvider get defaultProvider => _defaultProvider;

  static void setDefaultProvider(AIProvider provider) {
    _defaultProvider = provider;
  }

  static AIProvider _effectiveProvider(AIProvider? provider) {
    return provider ?? _defaultProvider;
  }

  static Map<String, dynamic> _profileToContext(FarmerProfile p) {
    return p.toJson();
  }

  static Future<Map<String, dynamic>> diagnoseDisease({
    required File image,
    required Map<String, dynamic> profile,
    required String crop,
    AIProvider? provider,
  }) async {
    final addressRaw = profile['address'];
    final Map<String, dynamic> ctx =
        addressRaw is Map
            ? Map<String, dynamic>.from(addressRaw)
            : <String, dynamic>{};

    //TODO: add field history from field log.
    ctx["field history"] = '';
    ctx['district'] = profile['district']?.toString();
    ctx['state'] = profile['state']?.toString();
    ctx['village'] = profile['village']?.toString();
    ctx['location'] = profile['district'] ?? profile['state'] ?? 'location';
    ctx['crop'] = crop;
    ctx['current_month'] = DateTime.now().month;

    // The image, field history,
    // recent weather for that location, crop species & stage, geolocation/soil information,
    // ICAR guidelines, and Government of India / Ministry of Agriculture guidelines

    // Add recent weather summary if available (placeholder using WeatherService dummy)
    // final location = ctx['location'] ?? ctx['district'] ?? ctx['state'] ?? 'location';
    // final weather = await WeatherService.getCurrentWeather(location);
    // ctx['weather'] = {
    //   'temp_c': weather.temperature,
    //   'humidity': weather.humidity,
    //   'condition': weather.condition,
    // };
    final selectedProvider = _effectiveProvider(provider);
    final raw =
        selectedProvider == AIProvider.gpt
            ? await GptService.diagnoseDisease(imageFile: image, ctx: ctx)
            : await GeminiService.diagnoseDisease(imageFile: image, ctx: ctx);
    return _normalizeDiseaseDiagnosis(raw);
  }

  static Future<Map<String, dynamic>> fertilizerPlan({
    required FarmerProfile profile,
    required String targetCrop,
    String? stage,
    AIProvider? provider,
  }) async {
    final ctx = _profileToContext(profile);
    ctx['target_crop'] = targetCrop;
    ctx['stage'] = stage;
    return fertilizerPlanFromContext(contextData: ctx, provider: provider);
  }

  static Future<Map<String, dynamic>> fertilizerPlanFromContext({
    required Map<String, dynamic> contextData,
    AIProvider? provider,
  }) async {
    final selectedProvider = _effectiveProvider(provider);
    if (selectedProvider == AIProvider.gpt) {
      return GptService.fertilizerPlan(contextData: contextData);
    }
    return GeminiService.fertilizerPlan(contextData: contextData);
  }

  static Future<Map<String, dynamic>> cropSuggestionsFromContext({
    required Map<String, dynamic> contextData,
    AIProvider? provider,
  }) async {
    final selectedProvider = _effectiveProvider(provider);
    final raw =
        selectedProvider == AIProvider.gpt
            ? await GptService.cropSuggestions(contextData: contextData)
            : await GeminiService.cropSuggestions(contextData: contextData);
    return _normalizeCropSuggestions(raw);
  }

  static Future<List<Map<String, dynamic>>> applicableSchemes({
    required FarmerProfile profile,
    AIProvider? provider,
  }) async {
    final ctx = _profileToContext(profile);
    return applicableSchemesFromMap(profile: ctx, provider: provider);
  }

  static Future<List<Map<String, dynamic>>> applicableSchemesFromMap({
    required Map<String, dynamic> profile,
    AIProvider? provider,
  }) async {
    final selectedProvider = _effectiveProvider(provider);
    print(
      '[RecommendationService] Schemes request provider=$selectedProvider profile=${jsonEncode(profile)}',
    );
    if (selectedProvider == AIProvider.gpt) {
      return GptService.applicableSchemes(profile: profile);
    }
    return GeminiService.applicableSchemes(profile: profile);
  }

  static Future<Map<String, dynamic>> extractSoilTestFromImage({
    required File image,
    AIProvider? provider,
  }) async {
    final selectedProvider = _effectiveProvider(provider);
    if (selectedProvider == AIProvider.gpt) {
      return GptService.extractSoilTestFromImage(imageFile: image);
    }
    return GeminiService.extractSoilTestFromImage(imageFile: image);
  }

  static Map<String, dynamic> _normalizeDiseaseDiagnosis(
    Map<String, dynamic> raw,
  ) {
    final normalized = Map<String, dynamic>.from(raw);
    final status = _resolveDiseaseStatus(raw);

    normalized['result_status'] = status;
    normalized['user_message'] = _resolvedUserMessage(raw, status);

    if (status != diseaseStatusIdentified) {
      normalized['disease_name'] = 'Unknown';
      normalized['confidence'] = 0.0;
    }

    return normalized;
  }

  static String _resolveDiseaseStatus(Map<String, dynamic> raw) {
    final statusRaw = raw['result_status']?.toString().trim().toUpperCase();
    if (statusRaw == diseaseStatusIdentified ||
        statusRaw == diseaseStatusDidNotIdentify ||
        statusRaw == diseaseStatusIrrelevant) {
      return statusRaw!;
    }

    final noteBag = [
      raw['disease_name'],
      raw['notes'],
      raw['user_message'],
      raw['message'],
    ].whereType<Object>().map((e) => e.toString().toLowerCase()).join(' ');

    if (_looksIrrelevant(noteBag)) {
      return diseaseStatusIrrelevant;
    }
    if (_looksIdentified(raw)) {
      return diseaseStatusIdentified;
    }
    return diseaseStatusDidNotIdentify;
  }

  static bool _looksIdentified(Map<String, dynamic> raw) {
    final diseaseName = raw['disease_name']?.toString().trim() ?? '';
    if (diseaseName.isEmpty) return false;
    final lower = diseaseName.toLowerCase();
    const badNames = {
      'unknown',
      'n/a',
      'none',
      'not identified',
      'cannot identify',
      'no disease',
    };
    if (badNames.contains(lower)) return false;

    final confidenceVal = raw['confidence'];
    final confidence =
        confidenceVal is num
            ? confidenceVal.toDouble()
            : double.tryParse('$confidenceVal') ?? 0.0;
    return confidence > 0.25;
  }

  static bool _looksIrrelevant(String text) {
    const irrelevantHints = [
      'not a crop',
      'non-crop',
      'irrelevant',
      'not related to plant',
      'not related to crop',
      'no plant',
      'no leaf',
      'not a field image',
      'unrelated image',
    ];
    return irrelevantHints.any(text.contains);
  }

  static String _resolvedUserMessage(Map<String, dynamic> raw, String status) {
    final fromModel = raw['user_message']?.toString().trim();
    if (fromModel != null && fromModel.isNotEmpty) return fromModel;

    switch (status) {
      case diseaseStatusIrrelevant:
        return 'The uploaded photo does not look like a crop image. Please upload a clear crop or leaf image.';
      case diseaseStatusDidNotIdentify:
        return 'We could not identify disease from this crop image. Please try again with a clearer, close-up photo in good lighting.';
      case diseaseStatusIdentified:
      default:
        return 'Disease identified successfully.';
    }
  }

  static Map<String, dynamic> _normalizeCropSuggestions(
    Map<String, dynamic> raw,
  ) {
    final normalized = Map<String, dynamic>.from(raw);
    final suggestionsRaw = raw['suggestions'];
    final List<Map<String, dynamic>> suggestions =
        suggestionsRaw is List
            ? suggestionsRaw
                .whereType<Map>()
                .map((e) => Map<String, dynamic>.from(e))
                .toList()
            : <Map<String, dynamic>>[];

    suggestions.sort((a, b) {
      final aRev = _toDouble(a['estimated_revenue']);
      final bRev = _toDouble(b['estimated_revenue']);
      final byRevenue = bRev.compareTo(aRev);
      if (byRevenue != 0) return byRevenue;
      final aYield = _toDouble(a['estimated_yield']);
      final bYield = _toDouble(b['estimated_yield']);
      return bYield.compareTo(aYield);
    });

    if (suggestions.length < 4) {
      final defaults = <Map<String, dynamic>>[
        {
          'crop_name': 'Bajra',
          'growth_duration_days': 110,
          'irrigation_requirements': 'Low, rain-supported',
          'estimated_yield': 0.0,
          'estimated_cost': 0.0,
          'estimated_revenue': 0.0,
          'overall_summary':
              'Fallback suggestion: complete market and soil details for accurate ranking.',
          'confidence': 'Low',
        },
        {
          'crop_name': 'Moong',
          'growth_duration_days': 70,
          'irrigation_requirements': 'Low to medium',
          'estimated_yield': 0.0,
          'estimated_cost': 0.0,
          'estimated_revenue': 0.0,
          'overall_summary':
              'Fallback suggestion: complete market and soil details for accurate ranking.',
          'confidence': 'Low',
        },
        {
          'crop_name': 'Mustard',
          'growth_duration_days': 125,
          'irrigation_requirements': 'Medium',
          'estimated_yield': 0.0,
          'estimated_cost': 0.0,
          'estimated_revenue': 0.0,
          'overall_summary':
              'Fallback suggestion: complete market and soil details for accurate ranking.',
          'confidence': 'Low',
        },
        {
          'crop_name': 'Chickpea',
          'growth_duration_days': 105,
          'irrigation_requirements': 'Low to medium',
          'estimated_yield': 0.0,
          'estimated_cost': 0.0,
          'estimated_revenue': 0.0,
          'overall_summary':
              'Fallback suggestion: complete market and soil details for accurate ranking.',
          'confidence': 'Low',
        },
      ];
      for (final fallback in defaults) {
        if (suggestions.length >= 4) break;
        final exists = suggestions.any(
          (s) =>
              '${s['crop_name']}'.toLowerCase() ==
              '${fallback['crop_name']}'.toLowerCase(),
        );
        if (!exists) suggestions.add(fallback);
      }
    }

    normalized['suggestions'] = suggestions.take(8).toList();
    normalized['generated_at'] =
        raw['generated_at']?.toString() ?? DateTime.now().toIso8601String();
    return normalized;
  }

  static double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse('$value') ?? 0.0;
  }
}
