import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/crops_screen_models.dart';

class CropActionsService {
  static const List<String> _openStatuses = ['open', 'pending', 'active'];
  static const String _cacheKey = 'crop_actions_cache_v1';

  static Future<List<CropTaskItem>> fetchOpenTasks({
    required int farmId,
  }) async {
    final supabase = Supabase.instance.client;
    final rows =
        await supabase
            .from('crop_actions')
            .select('id, title, description, status, priority')
            .eq('farm_id', farmId)
            .inFilter('status', _openStatuses)
            .order('created_at', ascending: false);

    if (rows is! List) return const <CropTaskItem>[];

    return rows
        .whereType<Map>()
        .map((row) => Map<String, dynamic>.from(row))
        .map(_mapRowToTask)
        .toList();
  }

  static Future<List<CropTaskItem>> fetchOpenTasksWithCache({
    required int farmId,
  }) async {
    try {
      final tasks = await fetchOpenTasks(farmId: farmId);
      if (tasks.isNotEmpty) {
        await _saveCache(farmId, tasks);
        return tasks;
      }
      return await _loadCache(farmId);
    } catch (_) {
      return await _loadCache(farmId);
    }
  }

  static Future<void> saveGeneratedTasksIfNew({
    required int farmId,
    required List<CropTaskItem> tasks,
  }) async {
    if (tasks.isEmpty) return;

    final supabase = Supabase.instance.client;
    final existing = await fetchOpenTasks(farmId: farmId);
    final existingKeys =
        existing.map(_taskKey).where((key) => key.isNotEmpty).toSet();

    final payload =
        tasks
            .map(
              (task) => <String, dynamic>{
                'farm_id': farmId,
                'title': task.title,
                'description': task.subtitle,
                'status': 'open',
                'priority': task.isHighPriority ? 'high' : 'normal',
              },
            )
            .where(
              (row) =>
                  (row['title'] as String).trim().isNotEmpty &&
                  (row['description'] as String).trim().isNotEmpty &&
                  !existingKeys.contains(
                    _taskKeyFromStrings(
                      row['title'] as String,
                      row['description'] as String,
                    ),
                  ),
            )
            .toList();

    if (payload.isEmpty) return;
    await supabase.from('crop_actions').insert(payload);

    final merged = [...existing, ...tasks];
    await _saveCache(farmId, _dedupe(merged));
  }

  static Future<bool> markTaskCompleted({
    required int farmId,
    required CropTaskItem task,
  }) async {
    try {
      final supabase = Supabase.instance.client;
      final title = task.title.trim();
      final description = task.subtitle.trim();

      if (title.isNotEmpty && description.isNotEmpty) {
        await supabase
            .from('crop_actions')
            .update({'status': 'completed'})
            .eq('farm_id', farmId)
            .eq('title', title)
            .eq('description', description)
            .inFilter('status', _openStatuses);
      }

      final cached = await _loadCache(farmId);
      if (cached.isNotEmpty) {
        final key = _taskKey(task);
        final updated =
            cached.where((item) => _taskKey(item) != key).toList();
        await _saveCache(farmId, updated);
      }

      return true;
    } catch (_) {
      return false;
    }
  }

  static CropTaskItem _mapRowToTask(Map<String, dynamic> row) {
    final title = (row['title'] ?? '').toString();
    final description = (row['description'] ?? '').toString();
    final priority = (row['priority'] ?? '').toString().toLowerCase();
    final isHighPriority = priority == 'high' || priority == 'urgent';
    final isIrrigation = title.toLowerCase().contains('irrigat');

    return CropTaskItem(
      id: (row['id'] ?? '').toString(),
      title: title,
      subtitle: description,
      isHighPriority: isHighPriority,
      isIrrigation: isIrrigation,
    );
  }

  static String _taskKey(CropTaskItem task) {
    return _taskKeyFromStrings(task.title, task.subtitle);
  }

  static String _taskKeyFromStrings(String title, String description) {
    final t = _normalize(title);
    final d = _normalize(description);
    if (t.isEmpty || d.isEmpty) return '';
    return '$t|$d';
  }

  static String _normalize(String value) {
    return value
        .toLowerCase()
        .replaceAll(RegExp(r'\s+'), ' ')
        .replaceAll(RegExp(r'[^a-z0-9 ]+'), '')
        .trim();
  }

  static Future<List<CropTaskItem>> _loadCache(int farmId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_cacheKey);
      if (raw == null || raw.isEmpty) return const <CropTaskItem>[];
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return const <CropTaskItem>[];
      final map = Map<String, dynamic>.from(decoded);
      final list = map['$farmId'];
      if (list is! List) return const <CropTaskItem>[];
      return list
          .whereType<Map>()
          .map((row) => Map<String, dynamic>.from(row))
          .map(
            (row) => CropTaskItem(
              id: (row['id'] ?? '').toString(),
              title: (row['title'] ?? '').toString(),
              subtitle: (row['subtitle'] ?? '').toString(),
              isIrrigation: row['isIrrigation'] == true,
              isHighPriority: row['isHighPriority'] == true,
            ),
          )
          .toList();
    } catch (_) {
      return const <CropTaskItem>[];
    }
  }

  static Future<void> _saveCache(int farmId, List<CropTaskItem> tasks) async {
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
          tasks
              .map(
                (task) => <String, dynamic>{
                  'id': task.id,
                  'title': task.title,
                  'subtitle': task.subtitle,
                  'isIrrigation': task.isIrrigation,
                  'isHighPriority': task.isHighPriority,
                },
              )
              .toList();
      await prefs.setString(_cacheKey, jsonEncode(map));
    } catch (_) {
      // Best-effort cache only.
    }
  }

  static List<CropTaskItem> _dedupe(List<CropTaskItem> tasks) {
    final seen = <String>{};
    final out = <CropTaskItem>[];
    for (final task in tasks) {
      final key = _taskKey(task);
      if (key.isEmpty || seen.contains(key)) continue;
      seen.add(key);
      out.add(task);
    }
    return out;
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
