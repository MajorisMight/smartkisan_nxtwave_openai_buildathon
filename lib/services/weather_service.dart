import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/weather.dart';

class WeatherService {
  static const String _geoBaseUrl = 'https://geocoding-api.open-meteo.com/v1/search';
  static const String _forecastBaseUrl = 'https://api.open-meteo.com/v1/forecast';

  // Get current weather
  static Future<WeatherData> getCurrentWeather(String location) async {
    debugPrint('[WeatherService] getCurrentWeather start location="$location"');
    final resolved = await _resolveLocation(location);
    debugPrint(
      '[WeatherService] resolved location="${resolved.displayName}" lat=${resolved.latitude} lon=${resolved.longitude}',
    );
    final data = await _fetchForecast(
      latitude: resolved.latitude,
      longitude: resolved.longitude,
      days: 16,
    );
    debugPrint(
      '[WeatherService] forecast fetch success days=${data.forecast.length} currentTemp=${data.current.temperature}',
    );

    return _toWeatherData(
      locationLabel: resolved.displayName,
      current: data.current,
      forecast: data.forecast,
    );
  }

  // Get weather forecast
  static Future<List<WeatherData>> getWeatherForecast(String location, int days) async {
    final resolved = await _resolveLocation(location);
    final data = await _fetchForecast(
      latitude: resolved.latitude,
      longitude: resolved.longitude,
      days: days.clamp(1, 16),
    );

    final List<WeatherData> dailyData = [];
    for (final day in data.forecast) {
      dailyData.add(
        WeatherData(
          location: resolved.displayName,
          temperature: day.maxTemp,
          humidity: day.humidity,
          windSpeed: day.windSpeed,
          windDirection: '',
          pressure: 0,
          visibility: 0,
          condition: day.condition,
          description: day.description,
          icon: day.icon,
          timestamp: day.date,
          forecast: const [],
          alerts: WeatherAlerts(warnings: const [], advisories: const [], riskLevel: 'Low'),
          soilConditions: _deriveSoilConditions(day.maxTemp, day.precipitation),
          cropRecommendations: _deriveCropRecommendations(day.maxTemp, day.humidity, day.precipitation),
        ),
      );
    }

    return dailyData;
  }

  // Get agricultural recommendations based on weather
  static Future<List<String>> getAgriculturalRecommendations(WeatherData weather) async {
    final List<String> recommendations = [];

    if (weather.temperature > 30) {
      recommendations.add('High temperature detected. Ensure adequate irrigation for crops.');
    } else if (weather.temperature < 15) {
      recommendations.add('Low temperature detected. Protect sensitive crops from frost.');
    }
    
    if (weather.humidity > 80) {
      recommendations.add('High humidity detected. Monitor for fungal diseases.');
    }
    
    if (weather.windSpeed > 15) {
      recommendations.add('Strong winds detected. Secure greenhouse structures and protect young plants.');
    }
    
    if (weather.condition.toLowerCase().contains('rain')) {
      recommendations.add('Rain expected. Avoid pesticide application and prepare for drainage.');
    }
    
    // Default recommendations
    if (recommendations.isEmpty) {
      recommendations.add('Weather conditions are favorable for farming activities.');
      recommendations.add('Continue regular crop monitoring and maintenance.');
    }
    
    return recommendations;
  }

  // Get weather alerts
  static Future<List<String>> getWeatherAlerts(String location) async {
    final weather = await getCurrentWeather(location);
    final List<String> alerts = [];

    if (weather.temperature > 35) {
      alerts.add('Heat wave warning: Temperatures above 35°C expected.');
    }
    
    if (weather.windSpeed > 20) {
      alerts.add('Strong wind warning: Winds above 20 km/h expected.');
    }
    
    if (weather.humidity > 90) {
      alerts.add('High humidity alert: Risk of fungal diseases increased.');
    }
    
    return alerts;
  }

  // Get historical weather data
  static Future<List<WeatherData>> getHistoricalWeather(String location, DateTime startDate, DateTime endDate) async {
    // Open-Meteo historical archive endpoint is separate; return a best-effort
    // approximation using current forecast to preserve compatibility.
    final days = endDate.difference(startDate).inDays.clamp(1, 16);
    return getWeatherForecast(location, days);
  }

  static Future<_ResolvedLocation> _resolveLocation(String location) async {
    final query = location.trim();
    if (query.isEmpty) {
      throw Exception('Location is required.');
    }
    debugPrint('[WeatherService] resolving query="$query"');
    final uri = Uri.parse(_geoBaseUrl).replace(
      queryParameters: {
        'name': query,
        'count': '1',
        'language': 'en',
        'format': 'json',
      },
    );

    final response = await http.get(uri);
    debugPrint(
      '[WeatherService] geocode response status=${response.statusCode} url=${uri.toString()}',
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to resolve location. Please try again.');
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final results = decoded['results'] as List<dynamic>?;
    if (results == null || results.isEmpty) {
      throw Exception('Location not found. Try a nearby city name.');
    }

    final first = results.first as Map<String, dynamic>;
    final name = (first['name'] ?? '').toString();
    final country = (first['country'] ?? '').toString();
    final admin = (first['admin1'] ?? '').toString();
    final display = [name, admin, country].where((value) => value.isNotEmpty).join(', ');

    return _ResolvedLocation(
      latitude: (first['latitude'] as num).toDouble(),
      longitude: (first['longitude'] as num).toDouble(),
      displayName: display.isEmpty ? query : display,
    );
  }

  static Future<_ForecastPayload> _fetchForecast({
    required double latitude,
    required double longitude,
    required int days,
  }) async {
    debugPrint(
      '[WeatherService] _fetchForecast lat=$latitude lon=$longitude days=$days',
    );
    final uri = Uri.parse(_forecastBaseUrl).replace(
      queryParameters: {
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
        'current': 'temperature_2m,relative_humidity_2m,pressure_msl,wind_speed_10m,wind_direction_10m,weather_code,visibility',
        'daily': 'weather_code,temperature_2m_max,temperature_2m_min,precipitation_probability_max,relative_humidity_2m_mean,wind_speed_10m_max',
        'forecast_days': days.toString(),
        'timezone': 'auto',
      },
    );

    final response = await http.get(uri);
    debugPrint(
      '[WeatherService] forecast response status=${response.statusCode} url=${uri.toString()}',
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to fetch weather data. Please try again.');
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final currentJson = decoded['current'] as Map<String, dynamic>?;
    final dailyJson = decoded['daily'] as Map<String, dynamic>?;
    if (currentJson == null || dailyJson == null) {
      throw Exception('Unexpected weather response. Please try again.');
    }

    final current = _CurrentSnapshot(
      temperature: (currentJson['temperature_2m'] as num?)?.toDouble() ?? 0,
      humidity: (currentJson['relative_humidity_2m'] as num?)?.toDouble() ?? 0,
      pressure: (currentJson['pressure_msl'] as num?)?.toDouble() ?? 0,
      windSpeed: (currentJson['wind_speed_10m'] as num?)?.toDouble() ?? 0,
      windDirection: _windDirection((currentJson['wind_direction_10m'] as num?)?.toDouble() ?? 0),
      visibility: (((currentJson['visibility'] as num?)?.toDouble() ?? 0) / 1000).clamp(0, 100),
      weatherCode: (currentJson['weather_code'] as num?)?.toInt() ?? 0,
      timestamp: DateTime.tryParse((currentJson['time'] ?? '').toString()) ?? DateTime.now(),
    );

    final times = List<String>.from(dailyJson['time'] ?? const <String>[]);
    final maxTemps = List<num>.from(dailyJson['temperature_2m_max'] ?? const <num>[]);
    final minTemps = List<num>.from(dailyJson['temperature_2m_min'] ?? const <num>[]);
    final weatherCodes = List<num>.from(dailyJson['weather_code'] ?? const <num>[]);
    final rainChance = List<num>.from(dailyJson['precipitation_probability_max'] ?? const <num>[]);
    final humidities = List<num>.from(dailyJson['relative_humidity_2m_mean'] ?? const <num>[]);
    final winds = List<num>.from(dailyJson['wind_speed_10m_max'] ?? const <num>[]);

    final len = [
      times.length,
      maxTemps.length,
      minTemps.length,
      weatherCodes.length,
      rainChance.length,
      humidities.length,
      winds.length,
    ].reduce((a, b) => a < b ? a : b);

    final List<WeatherForecast> forecast = [];
    for (var i = 0; i < len; i++) {
      final code = weatherCodes[i].toInt();
      final condition = _conditionLabel(code);

      forecast.add(
        WeatherForecast(
          date: DateTime.tryParse(times[i]) ?? DateTime.now().add(Duration(days: i)),
          maxTemp: maxTemps[i].toDouble(),
          minTemp: minTemps[i].toDouble(),
          condition: condition,
          description: _conditionDescription(code),
          icon: _iconCode(code),
          precipitation: rainChance[i].toDouble(),
          humidity: humidities[i].toDouble(),
          windSpeed: winds[i].toDouble(),
        ),
      );
    }

    return _ForecastPayload(current: current, forecast: forecast);
  }

  static WeatherData _toWeatherData({
    required String locationLabel,
    required _CurrentSnapshot current,
    required List<WeatherForecast> forecast,
  }) {
    final condition = _conditionLabel(current.weatherCode);
    final description = _conditionDescription(current.weatherCode);
    final warnings = _deriveWarnings(
      temperature: current.temperature,
      humidity: current.humidity,
      windSpeed: current.windSpeed,
      condition: condition,
    );

    return WeatherData(
      location: locationLabel,
      temperature: current.temperature,
      humidity: current.humidity,
      windSpeed: current.windSpeed,
      windDirection: current.windDirection,
      pressure: current.pressure,
      visibility: current.visibility,
      condition: condition,
      description: description,
      icon: _iconCode(current.weatherCode),
      timestamp: current.timestamp,
      forecast: forecast,
      alerts: WeatherAlerts(
        warnings: warnings,
        advisories: _deriveAdvisories(
          temperature: current.temperature,
          humidity: current.humidity,
          windSpeed: current.windSpeed,
          condition: condition,
        ),
        riskLevel: _riskLevel(warnings.length),
      ),
      soilConditions: _deriveSoilConditions(
        current.temperature,
        forecast.isNotEmpty ? forecast.first.precipitation : 0,
      ),
      cropRecommendations: _deriveCropRecommendations(
        current.temperature,
        current.humidity,
        forecast.isNotEmpty ? forecast.first.precipitation : 0,
      ),
    );
  }

  static SoilConditions _deriveSoilConditions(double temperature, double precipitationChance) {
    final moisture = (40 + precipitationChance * 0.45).clamp(20, 95).toDouble();
    final condition = moisture > 70 ? 'Wet' : (moisture > 45 ? 'Balanced' : 'Dry');
    final recommendation = moisture > 70
        ? 'Avoid over-irrigation and ensure proper drainage.'
        : (moisture > 45
            ? 'Soil moisture is balanced. Maintain regular checks.'
            : 'Soil may dry quickly. Increase irrigation frequency.');

    return SoilConditions(
      moisture: moisture,
      temperature: temperature,
      condition: condition,
      recommendation: recommendation,
    );
  }

  static CropRecommendations _deriveCropRecommendations(
    double temperature,
    double humidity,
    double precipitationChance,
  ) {
    final suitable = <String>[
      if (temperature >= 18 && temperature <= 32) 'Rice',
      if (temperature >= 15 && temperature <= 30) 'Wheat',
      if (temperature >= 22 && temperature <= 35) 'Maize',
      if (temperature >= 20 && temperature <= 34) 'Cotton',
    ];

    return CropRecommendations(
      suitableCrops: suitable.isEmpty ? const ['Millets', 'Pulses'] : suitable,
      plantingTips: <String>[
        if (precipitationChance > 60) 'Delay sowing and field sprays until rain risk drops.',
        if (temperature > 32) 'Prefer early-morning field operations.',
        if (humidity > 80) 'Increase scouting for fungal symptoms.',
      ],
      irrigationAdvice: precipitationChance > 65
          ? 'High rain chance. Pause planned irrigation and monitor field runoff.'
          : (temperature > 30
              ? 'Temperatures are high. Use shorter, frequent irrigation cycles.'
              : 'Maintain normal irrigation schedule based on crop stage.'),
      pestControl: humidity > 80
          ? 'Humidity is elevated. Prioritize preventive fungal disease monitoring.'
          : 'Weather risk is moderate. Continue routine pest scouting.',
    );
  }

  static List<String> _deriveWarnings({
    required double temperature,
    required double humidity,
    required double windSpeed,
    required String condition,
  }) {
    final warnings = <String>[];
    if (temperature >= 35) warnings.add('Heat stress risk is high for crops and livestock.');
    if (windSpeed >= 30) warnings.add('Strong winds expected. Avoid spraying and secure supports.');
    if (humidity >= 90) warnings.add('Very high humidity may accelerate fungal disease spread.');
    if (condition.toLowerCase().contains('thunderstorm')) {
      warnings.add('Thunderstorm conditions possible. Avoid open-field operations.');
    }
    return warnings;
  }

  static List<String> _deriveAdvisories({
    required double temperature,
    required double humidity,
    required double windSpeed,
    required String condition,
  }) {
    final advisories = <String>[
      if (condition.toLowerCase().contains('rain')) 'Plan drainage checks and postpone chemical sprays.',
      if (temperature < 12) 'Protect young plants from cold stress during early morning hours.',
      if (windSpeed > 20) 'Use drip or furrow irrigation to reduce water loss from wind.',
      if (humidity > 80) 'Increase interval scouting for leaf wetness and disease lesions.',
    ];
    if (advisories.isEmpty) {
      advisories.add('Weather is stable. Continue regular irrigation and crop monitoring.');
    }
    return advisories;
  }

  static String _riskLevel(int warningCount) {
    if (warningCount >= 3) return 'High';
    if (warningCount >= 1) return 'Medium';
    return 'Low';
  }

  static String _conditionLabel(int code) {
    if (code == 0) return 'Clear';
    if (code == 1) return 'Mostly Clear';
    if (code == 2) return 'Partly Cloudy';
    if (code == 3) return 'Overcast';
    if (code == 45 || code == 48) return 'Fog';
    if ([51, 53, 55, 56, 57].contains(code)) return 'Drizzle';
    if ([61, 63, 65, 66, 67, 80, 81, 82].contains(code)) return 'Rain';
    if ([71, 73, 75, 77, 85, 86].contains(code)) return 'Snow';
    if (code == 95 || code == 96 || code == 99) return 'Thunderstorm';
    return 'Cloudy';
  }

  static String _conditionDescription(int code) {
    if (code == 0) return 'Clear sky conditions.';
    if (code == 1) return 'Mostly clear with mild cloud cover.';
    if (code == 2) return 'Partly cloudy conditions.';
    if (code == 3) return 'Overcast sky.';
    if (code == 45 || code == 48) return 'Fog reducing visibility.';
    if ([51, 53, 55, 56, 57].contains(code)) return 'Light to moderate drizzle expected.';
    if ([61, 63, 65, 66, 67, 80, 81, 82].contains(code)) return 'Rainfall expected.';
    if ([71, 73, 75, 77, 85, 86].contains(code)) return 'Snowfall conditions.';
    if (code == 95 || code == 96 || code == 99) return 'Thunderstorm risk in the area.';
    return 'Variable weather conditions.';
  }

  static String _iconCode(int code) {
    if (code == 0) return '01d';
    if (code == 1) return '02d';
    if (code == 2 || code == 3) return '03d';
    if (code == 45 || code == 48) return '50d';
    if ([51, 53, 55, 56, 57, 61, 63, 65, 66, 67, 80, 81, 82].contains(code)) {
      return '10d';
    }
    if ([71, 73, 75, 77, 85, 86].contains(code)) return '13d';
    if (code == 95 || code == 96 || code == 99) return '11d';
    return '04d';
  }

  static String _windDirection(double degrees) {
    const directions = <String>[
      'N',
      'NNE',
      'NE',
      'ENE',
      'E',
      'ESE',
      'SE',
      'SSE',
      'S',
      'SSW',
      'SW',
      'WSW',
      'W',
      'WNW',
      'NW',
      'NNW',
    ];
    final index = ((degrees + 11.25) / 22.5).floor() % 16;
    return directions[index];
  }
}

class _ResolvedLocation {
  final double latitude;
  final double longitude;
  final String displayName;

  const _ResolvedLocation({
    required this.latitude,
    required this.longitude,
    required this.displayName,
  });
}

class _CurrentSnapshot {
  final double temperature;
  final double humidity;
  final double pressure;
  final double windSpeed;
  final String windDirection;
  final double visibility;
  final int weatherCode;
  final DateTime timestamp;

  const _CurrentSnapshot({
    required this.temperature,
    required this.humidity,
    required this.pressure,
    required this.windSpeed,
    required this.windDirection,
    required this.visibility,
    required this.weatherCode,
    required this.timestamp,
  });
}

class _ForecastPayload {
  final _CurrentSnapshot current;
  final List<WeatherForecast> forecast;

  const _ForecastPayload({
    required this.current,
    required this.forecast,
  });
}
