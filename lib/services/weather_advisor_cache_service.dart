import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'weather_advisor_service.dart';

class CachedWeatherAdvisory {
  final String summary;
  final List<WeatherAdvisory> advisories;
  final DateTime cachedAt;

  const CachedWeatherAdvisory({
    required this.summary,
    required this.advisories,
    required this.cachedAt,
  });
}

class WeatherAdvisorCacheService {
  static const Duration _ttl = Duration(hours: 24);

  static String _keyForLocation(String location) {
    final normalized = location.trim().toLowerCase().replaceAll(RegExp(r'\s+'), '_');
    return 'weather_ai_notes_$normalized';
  }

  static Future<CachedWeatherAdvisory?> readValid({required String location}) async {
    final cached = await _readRaw(location: location);
    if (cached == null) return null;
    if (DateTime.now().difference(cached.cachedAt) > _ttl) return null;
    return cached;
  }

  static Future<void> write({
    required String location,
    required String summary,
    required List<WeatherAdvisory> advisories,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final payload = {
      'summary': summary,
      'cached_at': DateTime.now().toIso8601String(),
      'advisories': advisories
          .map(
            (item) => {
              'headline': item.headline,
              'advice': item.advice,
              'reason': item.reason,
              'priority': item.priority,
              'category': item.category,
              'time_horizon': item.timeHorizon,
            },
          )
          .toList(),
    };

    await prefs.setString(_keyForLocation(location), jsonEncode(payload));
  }

  static Future<void> clear({required String location}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyForLocation(location));
  }

  static Future<CachedWeatherAdvisory?> _readRaw({required String location}) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyForLocation(location));
    if (raw == null || raw.isEmpty) return null;

    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      final cachedAt = DateTime.tryParse((decoded['cached_at'] ?? '').toString());
      if (cachedAt == null) return null;

      final advisoriesRaw = decoded['advisories'];
      if (advisoriesRaw is! List) return null;

      final advisories = advisoriesRaw
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .map(
            (item) => WeatherAdvisory(
              headline: (item['headline'] ?? '').toString(),
              advice: (item['advice'] ?? '').toString(),
              reason: (item['reason'] ?? '').toString(),
              priority: (item['priority'] ?? 'medium').toString(),
              category: (item['category'] ?? 'weather').toString(),
              timeHorizon: (item['time_horizon'] ?? '1-3d').toString(),
            ),
          )
          .where((item) => item.headline.trim().isNotEmpty && item.advice.trim().isNotEmpty)
          .toList();

      if (advisories.isEmpty) return null;

      return CachedWeatherAdvisory(
        summary: (decoded['summary'] ?? '').toString(),
        advisories: advisories,
        cachedAt: cachedAt,
      );
    } catch (_) {
      return null;
    }
  }
}
