import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:postgrest/postgrest.dart';

import '../models/crop_action.dart';

class ActivityLogsService {
  static const String _cacheKey = 'activity_logs_cache_v1';

  static Future<List<CropAction>> fetchLogsWithCache({
    required int farmId,
  }) async {
    try {
      final supabase = Supabase.instance.client;
      // ignore: avoid_print
      print('[ActivityLogs] Fetching logs for farm_id=$farmId');
      final rows =
          await supabase
              .from('activity_logs')
              .select(
                'activity_id, farm_id, title, activity_date, details, created_at',
              )
              .eq('farm_id', farmId)
              .order('activity_date', ascending: false);

      if (rows is List) {
        final logs =
            rows
                .whereType<Map>()
                .map((row) => Map<String, dynamic>.from(row))
                .map(CropAction.fromMap)
                .toList();
        await _saveCache(farmId, logs);
        // ignore: avoid_print
        print('[ActivityLogs] Loaded ${logs.length} logs from DB');
        return logs;
      }
    } catch (_) {
      // ignore: avoid_print
      print('[ActivityLogs] DB fetch failed, using cache');
      // Fall through to cache.
    }

    return await _loadCache(farmId);
  }

  static Future<CropAction?> addLog({
    required int farmId,
    required String title,
    required String details,
    DateTime? date,
  }) async {
    final supabase = Supabase.instance.client;
    final now = date ?? DateTime.now();
    final dateOnly = now.toIso8601String().split('T').first;

    try {
      // ignore: avoid_print
      print('[ActivityLogs] Inserting log for farm_id=$farmId');
      final inserted =
          await supabase
              .from('activity_logs')
              .insert({
                'farm_id': farmId,
                'title': title,
                'activity_date': dateOnly,
                'details': details,
              })
              .select(
                'activity_id, farm_id, title, activity_date, details, created_at',
              )
              .single();

      final log = CropAction.fromMap(Map<String, dynamic>.from(inserted));
      final cached = await _loadCache(farmId);
      await _saveCache(farmId, [log, ...cached]);
      // ignore: avoid_print
      print('[ActivityLogs] Inserted log activity_id=${log.id}');
      return log;
    } on PostgrestException catch (e) {
      // ignore: avoid_print
      print(
        '[ActivityLogs] Insert failed: ${e.message} (code=${e.code}, details=${e.details}, hint=${e.hint})',
      );
      return null;
    } catch (e) {
      // ignore: avoid_print
      print('[ActivityLogs] Insert failed: $e');
      return null;
    }
  }

  static Future<List<CropAction>> _loadCache(int farmId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_cacheKey);
      if (raw == null || raw.isEmpty) return const <CropAction>[];
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return const <CropAction>[];
      final map = Map<String, dynamic>.from(decoded);
      final list = map['$farmId'];
      if (list is! List) return const <CropAction>[];
      return list
          .whereType<Map>()
          .map((row) => Map<String, dynamic>.from(row))
          .map(CropAction.fromMap)
          .toList();
    } catch (_) {
      return const <CropAction>[];
    }
  }

  static Future<void> _saveCache(
    int farmId,
    List<CropAction> logs,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_cacheKey);
      Map<String, dynamic> map = <String, dynamic>{};
      if (raw != null && raw.isNotEmpty) {
        final decoded = jsonDecode(raw);
        if (decoded is Map) {
          map = Map<String, dynamic>.from(decoded);
        }
      }
      map['$farmId'] =
          logs
              .map(
                (log) => <String, dynamic>{
                  'activity_id': log.id,
                  'farm_id': log.farmCropId,
                  'title': log.action,
                  'activity_date': log.date.toIso8601String(),
                  'details': log.notes,
                },
              )
              .toList();
      await prefs.setString(_cacheKey, jsonEncode(map));
    } catch (_) {
      // Best-effort cache only.
    }
  }

  static Future<void> clearCacheForFarm(int farmId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_cacheKey);
      if (raw == null || raw.isEmpty) return;
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return;
      final map = Map<String, dynamic>.from(decoded);
      map.remove('$farmId');
      await prefs.setString(_cacheKey, jsonEncode(map));
    } catch (_) {
      // Best-effort cache only.
    }
  }
}
