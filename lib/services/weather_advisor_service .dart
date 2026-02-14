import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';

import '../models/weather.dart';
import 'ai_provider.dart';
import 'gemini_service.dart';
import 'gpt_service.dart';

class WeatherAdvisory {
  final String headline;
  final String advice;
  final String reason;
  final String priority;
  final String category;
  final String timeHorizon;

  const WeatherAdvisory({
    required this.headline,
    required this.advice,
    required this.reason,
    required this.priority,
    required this.category,
    required this.timeHorizon,
  });
}

class WeatherAdvisoryResponse {
  final String summary;
  final List<WeatherAdvisory> advisories;

  const WeatherAdvisoryResponse({
    required this.summary,
    required this.advisories,
  });
}

class WeatherAdvisorService {
  static Future<WeatherAdvisoryResponse> getAdvisories({
    required String location,
    required WeatherData weather,
  }) async {
    final provider = aiProviderFromString(dotenv.env['AI_PROVIDER']);
    debugPrint(
      '[WeatherAdvisorService] getAdvisories provider=$provider location="$location"',
    );
    final context = _buildContext(
      location: location,
      weather: weather,
    );
    debugPrint(
      '[WeatherAdvisorService] context shortDays=${weather.forecast.length}',
    );

    final Map<String, dynamic> raw =
        provider == AIProvider.gpt
            ? await GptService.weatherAdvisories(contextData: context)
            : await GeminiService.weatherAdvisories(contextData: context);
    debugPrint(
      '[WeatherAdvisorService] raw keys=${raw.keys.join(",")}',
    );

    final advisoriesRaw =
        raw['advisories'] is List
            ? List<dynamic>.from(raw['advisories'] as List)
            : const <dynamic>[];

    final advisories =
        advisoriesRaw
            .whereType<Map>()
            .map((item) => _toAdvisory(Map<String, dynamic>.from(item)))
            .whereType<WeatherAdvisory>()
            .toList();
    debugPrint(
      '[WeatherAdvisorService] parsed advisories=${advisories.length}',
    );

    if (advisories.isEmpty) {
      throw Exception('Model returned no advisories');
    }

    return WeatherAdvisoryResponse(
      summary: (raw['summary'] ?? '').toString().trim(),
      advisories: advisories.take(6).toList(),
    );
  }

  static Map<String, dynamic> _buildContext({
    required String location,
    required WeatherData weather,
  }) {
    final daily =
        weather.forecast
            .map(
              (f) => {
                'date': f.date.toIso8601String(),
                'condition': f.condition,
                'min_temp_c': f.minTemp,
                'max_temp_c': f.maxTemp,
                'humidity_percent': f.humidity,
                'wind_kmh': f.windSpeed,
                'rain_probability_percent': f.precipitation,
              },
            )
            .toList();

    return {
      'location': location,
      'current': {
        'temperature_c': weather.temperature,
        'condition': weather.condition,
        'description': weather.description,
        'humidity_percent': weather.humidity,
        'wind_kmh': weather.windSpeed,
        'pressure_hpa': weather.pressure,
      },
      'daily_forecast': daily,
      'forecast_days': daily.length,
      'generated_at': DateTime.now().toIso8601String(),
    };
  }

  static WeatherAdvisory? _toAdvisory(Map<String, dynamic> json) {
    final headline = (json['headline'] ?? '').toString().trim();
    final advice = (json['advice'] ?? '').toString().trim();
    if (headline.isEmpty || advice.isEmpty) return null;

    final priority = (json['priority'] ?? 'medium').toString().trim().toLowerCase();
    final category = (json['category'] ?? 'weather').toString().trim().toLowerCase();
    final horizon = (json['time_horizon'] ?? '1-3d').toString().trim().toLowerCase();
    final reason = (json['reason'] ?? '').toString().trim();

    return WeatherAdvisory(
      headline: headline,
      advice: advice,
      reason: reason,
      priority: priority.isEmpty ? 'medium' : priority,
      category: category.isEmpty ? 'weather' : category,
      timeHorizon: horizon.isEmpty ? '1-3d' : horizon,
    );
  }
}
