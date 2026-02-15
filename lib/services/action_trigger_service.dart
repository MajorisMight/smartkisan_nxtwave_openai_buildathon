import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/crop.dart';
import '../models/weather.dart';
import 'weather_service.dart';

enum ActionSignalSeverity { low, medium, high }

class ActionSignal {
  final String type;
  final String source;
  final ActionSignalSeverity severity;
  final String title;
  final String summary;
  final Map<String, dynamic> payload;

  const ActionSignal({
    required this.type,
    required this.source,
    required this.severity,
    required this.title,
    required this.summary,
    required this.payload,
  });
}

class LocalActionTask {
  final String id;
  final String title;
  final String subtitle;
  final bool isIrrigation;
  final bool isHighPriority;
  final bool requiresInput;
  final String? inputLabel;
  final String? inputHint;
  final String? inputUnit;

  const LocalActionTask({
    required this.id,
    required this.title,
    required this.subtitle,
    this.isIrrigation = false,
    this.isHighPriority = false,
    this.requiresInput = false,
    this.inputLabel,
    this.inputHint,
    this.inputUnit,
  });
}

class LocalActionTriggerResult {
  final List<ActionSignal> signals;
  final List<LocalActionTask> tasks;
  final bool shouldQueryLlm;
  final int triggerScore;
  final Map<String, dynamic> llmPayload;

  const LocalActionTriggerResult({
    required this.signals,
    required this.tasks,
    required this.shouldQueryLlm,
    required this.triggerScore,
    required this.llmPayload,
  });
}

class ActionTriggerService {
  static const int _llmScoreThreshold = 3;
  static const int _advanceDaysMin = 2;
  static const int _advanceDaysMax = 3;

  static Map<String, _CropProfileData>? _cropProfilesCache;

  static Future<LocalActionTriggerResult> generateLocalTriggers({
    required Crop crop,
  }) async {
    final locationContext = await _resolveLocationContext(crop.location);
    final profile = await _loadProfileForCrop(crop);

    WeatherData? weather;
    try {
      weather = await WeatherService.getCurrentWeather(locationContext);
    } catch (_) {
      weather = null;
    }

    final signals = <ActionSignal>[];

    final timelineSignals = _buildTimelineSignals(crop: crop, profile: profile);
    signals.addAll(timelineSignals);

    final weatherSignals = _buildWeatherSignals(weather);
    signals.addAll(weatherSignals);

    final triggerScore = signals.fold<int>(
      0,
      (score, signal) => score + _severityWeight(signal.severity),
    );

    final highSeverityCount =
        signals
            .where((signal) => signal.severity == ActionSignalSeverity.high)
            .length;

    final shouldQueryLlm =
        highSeverityCount > 0 ||
        triggerScore >= _llmScoreThreshold ||
        signals.length >= 2;

    return LocalActionTriggerResult(
      signals: signals,
      tasks: _buildTasks(signals),
      shouldQueryLlm: shouldQueryLlm,
      triggerScore: triggerScore,
      llmPayload: <String, dynamic>{
        'crop_id': crop.id,
        'crop_name': crop.name,
        'location': locationContext,
        'days_since_sowing': _daysSinceSowing(crop),
        'trigger_score': triggerScore,
        if (profile != null) 'crop_profile': profile.toMap(),
        'signals':
            signals
                .map(
                  (signal) => <String, dynamic>{
                    'type': signal.type,
                    'source': signal.source,
                    'severity': signal.severity.name,
                    'title': signal.title,
                    'summary': signal.summary,
                    'payload': signal.payload,
                  },
                )
                .toList(),
      },
    );
  }

  static List<ActionSignal> _buildTimelineSignals({
    required Crop crop,
    required _CropProfileData? profile,
  }) {
    if (profile == null) return const [];

    final signals = <ActionSignal>[];
    final daysSinceSowing = _daysSinceSowing(crop);

    final nextStage = _nextGrowthStage(profile.growthStages, daysSinceSowing);
    if (nextStage != null) {
      final daysUntilNextStage = nextStage.startDay - daysSinceSowing;
      if (_isInAdvanceWindow(daysUntilNextStage)) {
        signals.add(
          ActionSignal(
            type: 'stage_change_advance_alert',
            source: 'crop_timeline',
            severity: ActionSignalSeverity.medium,
            title: 'Stage change expected soon',
            summary:
                'Crop may enter ${nextStage.stage} in about $daysUntilNextStage days.',
            payload: <String, dynamic>{
              'crop_id': crop.id,
              'days_since_sowing': daysSinceSowing,
              'next_stage': nextStage.stage,
              'next_stage_start_day': nextStage.startDay,
              'days_to_next_stage': daysUntilNextStage,
              'recommended_action':
                  'Prepare stage-specific inputs and field operations before transition.',
            },
          ),
        );
      }
    }

    final nextCriticalIrrigationDay = profile.criticalIrrigationDays
        .where((day) => day >= daysSinceSowing)
        .cast<int?>()
        .firstWhere((day) => day != null, orElse: () => null);

    if (nextCriticalIrrigationDay != null) {
      final daysUntilCriticalIrrigation =
          nextCriticalIrrigationDay - daysSinceSowing;
      if (_isInAdvanceWindow(daysUntilCriticalIrrigation)) {
        signals.add(
          ActionSignal(
            type: 'irrigation_advance_alert',
            source: 'crop_timeline',
            severity: ActionSignalSeverity.high,
            title: 'Critical irrigation window approaching',
            summary:
                'Critical irrigation day is in about $daysUntilCriticalIrrigation days (day $nextCriticalIrrigationDay).',
            payload: <String, dynamic>{
              'crop_id': crop.id,
              'days_since_sowing': daysSinceSowing,
              'critical_irrigation_day': nextCriticalIrrigationDay,
              'days_to_critical_irrigation': daysUntilCriticalIrrigation,
              'method': profile.irrigationMethod,
              'recommended_action':
                  'Check soil moisture and prepare irrigation to avoid stress at the critical stage.',
            },
          ),
        );
      }
    }

    final harvestWindowStartDay =
        profile.totalDurationDays + profile.harvestStartBufferDays;
    final daysToHarvestWindowStart = harvestWindowStartDay - daysSinceSowing;
    if (_isInAdvanceWindow(daysToHarvestWindowStart)) {
      signals.add(
        ActionSignal(
          type: 'harvest_window_advance_alert',
          source: 'crop_timeline',
          severity: ActionSignalSeverity.medium,
          title: 'Harvest window approaching',
          summary:
              'Harvest window starts in about $daysToHarvestWindowStart days.',
          payload: <String, dynamic>{
            'crop_id': crop.id,
            'days_since_sowing': daysSinceSowing,
            'harvest_window_start_day': harvestWindowStartDay,
            'days_to_harvest_window': daysToHarvestWindowStart,
            'recommended_action':
                'Prepare labor, tools, transport, and storage before harvest starts.',
          },
        ),
      );
    }

    return signals;
  }

  static List<ActionSignal> _buildWeatherSignals(WeatherData? weather) {
    if (weather == null || weather.forecast.isEmpty) return const [];

    final signals = <ActionSignal>[];
    final leadDays = weather.forecast.take(3).toList();
    if (leadDays.isEmpty) return const [];

    final avgNextMax =
        leadDays.fold<double>(0, (sum, day) => sum + day.maxTemp) /
        leadDays.length;
    final avgRainChance =
        leadDays.fold<double>(0, (sum, day) => sum + day.precipitation) /
        leadDays.length;
    final avgWind =
        leadDays.fold<double>(0, (sum, day) => sum + day.windSpeed) /
        leadDays.length;
    final tempDelta = (avgNextMax - weather.temperature).abs();

    if (tempDelta >= 6) {
      signals.add(
        ActionSignal(
          type: 'temperature_shift_alert',
          source: 'weather',
          severity:
              tempDelta >= 8
                  ? ActionSignalSeverity.high
                  : ActionSignalSeverity.medium,
          title: 'Temperature swing expected',
          summary:
              '3-day max temperature shift is ${tempDelta.toStringAsFixed(1)}°C.',
          payload: <String, dynamic>{
            'location': weather.location,
            'temperature_delta_c': tempDelta,
            'recommended_action':
                'Adjust irrigation timing and monitor stress-prone crop patches.',
          },
        ),
      );
    }

    if (avgRainChance >= 70) {
      signals.add(
        ActionSignal(
          type: 'heavy_rain_alert',
          source: 'weather',
          severity:
              avgRainChance >= 80
                  ? ActionSignalSeverity.high
                  : ActionSignalSeverity.medium,
          title: 'High rain probability window',
          summary:
              'Average rain probability for next 3 days is ${avgRainChance.toStringAsFixed(0)}%.',
          payload: <String, dynamic>{
            'location': weather.location,
            'rain_probability_pct': avgRainChance,
            'recommended_action':
                'Delay spraying and verify field drainage before rainfall.',
          },
        ),
      );
    }

    if (avgWind >= 25) {
      signals.add(
        ActionSignal(
          type: 'wind_risk_alert',
          source: 'weather',
          severity:
              avgWind >= 30
                  ? ActionSignalSeverity.high
                  : ActionSignalSeverity.medium,
          title: 'Strong wind risk',
          summary:
              'Average wind speed for next 3 days is ${avgWind.toStringAsFixed(1)} km/h.',
          payload: <String, dynamic>{
            'location': weather.location,
            'wind_speed_kmh': avgWind,
            'recommended_action':
                'Avoid foliar applications during high-wind periods and support vulnerable plants.',
          },
        ),
      );
    }

    return signals;
  }

  static List<LocalActionTask> _buildTasks(List<ActionSignal> signals) {
    final tasks =
        signals.map((signal) {
          final isIrrigation = signal.type.contains('irrigation');
          final isInputTask =
              signal.type == 'irrigation_advance_alert' ||
              signal.type == 'temperature_shift_alert';

          return LocalActionTask(
            id: '${signal.type}-${signal.source}',
            title: signal.title,
            subtitle: signal.summary,
            isIrrigation: isIrrigation,
            isHighPriority: signal.severity == ActionSignalSeverity.high,
            requiresInput: isInputTask,
            inputLabel: isInputTask ? 'Field observation' : null,
            inputHint: isInputTask ? 'Enter observed value/notes' : null,
            inputUnit: null,
          );
        }).toList();

    tasks.sort((a, b) {
      if (a.isHighPriority == b.isHighPriority) {
        return a.title.compareTo(b.title);
      }
      return a.isHighPriority ? -1 : 1;
    });

    return tasks.take(6).toList();
  }

  static Future<String> _resolveLocationContext(String cropLocation) async {
    final supabase = Supabase.instance.client;
    final userId = supabase.auth.currentUser?.id;
    String district = '';
    String state = '';

    if (userId != null) {
      try {
        final row =
            await supabase
                .from('farmers')
                .select('district, state')
                .eq('id', userId)
                .maybeSingle();

        if (row != null) {
          district = (row['district'] ?? '').toString().trim();
          state = (row['state'] ?? '').toString().trim();
        }
      } catch (_) {
        // Ignore profile lookup failures and keep fallback behavior.
      }
    }

    final locationLabel =
        cropLocation.trim().isNotEmpty &&
                cropLocation.trim().toLowerCase() != 'not provided'
            ? cropLocation.trim()
            : [district, state].where((value) => value.isNotEmpty).join(', ');

    return locationLabel.isEmpty ? 'Jaipur, Rajasthan' : locationLabel;
  }

  static Future<_CropProfileData?> _loadProfileForCrop(Crop crop) async {
    final all = await _loadCropProfiles();
    final candidates = <String>{
      _normalizeCropIdentifier(crop.name),
      _normalizeCropIdentifier(crop.type ?? ''),
      _normalizeCropIdentifier((crop.type ?? '').split('(').first),
    }..removeWhere((entry) => entry.isEmpty);

    for (final candidate in candidates) {
      final profile = all[candidate];
      if (profile != null) return profile;
    }

    return null;
  }

  static Future<Map<String, _CropProfileData>> _loadCropProfiles() async {
    final existing = _cropProfilesCache;
    if (existing != null) return existing;

    try {
      final jsonString = await rootBundle.loadString(
        'lib/constants/crop_profiles.json',
      );
      final decoded = jsonDecode(jsonString);
      if (decoded is! Map<String, dynamic>) {
        _cropProfilesCache = const <String, _CropProfileData>{};
        return _cropProfilesCache!;
      }

      final map = <String, _CropProfileData>{};
      for (final entry in decoded.entries) {
        final value = entry.value;
        if (value is! Map) continue;

        final profile = _CropProfileData.fromJson(
          key: entry.key,
          json: Map<String, dynamic>.from(value),
        );

        map[_normalizeCropIdentifier(entry.key)] = profile;
        map[_normalizeCropIdentifier(profile.name)] = profile;
      }

      _cropProfilesCache = map;
      return map;
    } catch (_) {
      _cropProfilesCache = const <String, _CropProfileData>{};
      return _cropProfilesCache!;
    }
  }

  static String _normalizeCropIdentifier(String value) {
    return value
        .toLowerCase()
        .replaceAll(RegExp(r'\(.*\)'), '')
        .replaceAll(RegExp(r'[^a-z0-9]+'), '');
  }

  static _GrowthStageData? _nextGrowthStage(
    List<_GrowthStageData> stages,
    int dayNumber,
  ) {
    final sorted = [...stages]
      ..sort((a, b) => a.startDay.compareTo(b.startDay));
    for (final stage in sorted) {
      if (stage.startDay > dayNumber) return stage;
    }
    return null;
  }

  static int _daysSinceSowing(Crop crop) {
    final days = DateTime.now().difference(crop.sowDate).inDays + 1;
    return days < 1 ? 1 : days;
  }

  static bool _isInAdvanceWindow(int daysUntilEvent) {
    return daysUntilEvent >= _advanceDaysMin &&
        daysUntilEvent <= _advanceDaysMax;
  }

  static int _severityWeight(ActionSignalSeverity severity) {
    switch (severity) {
      case ActionSignalSeverity.low:
        return 1;
      case ActionSignalSeverity.medium:
        return 2;
      case ActionSignalSeverity.high:
        return 3;
    }
  }
}

class _CropProfileData {
  final String cropId;
  final String name;
  final int totalDurationDays;
  final List<_GrowthStageData> growthStages;
  final List<int> criticalIrrigationDays;
  final String irrigationMethod;
  final int harvestStartBufferDays;
  final int harvestEndBufferDays;

  const _CropProfileData({
    required this.cropId,
    required this.name,
    required this.totalDurationDays,
    required this.growthStages,
    required this.criticalIrrigationDays,
    required this.irrigationMethod,
    required this.harvestStartBufferDays,
    required this.harvestEndBufferDays,
  });

  factory _CropProfileData.fromJson({
    required String key,
    required Map<String, dynamic> json,
  }) {
    final growthRaw = json['growth_stages'];
    final growthStages =
        growthRaw is List
            ? growthRaw
                .whereType<Map>()
                .map(
                  (entry) => _GrowthStageData.fromJson(
                    Map<String, dynamic>.from(entry),
                  ),
                )
                .toList()
            : const <_GrowthStageData>[];

    final irrigation =
        json['irrigation'] is Map
            ? Map<String, dynamic>.from(json['irrigation'] as Map)
            : const <String, dynamic>{};
    final criticalDaysRaw = irrigation['critical_days'];
    final criticalDays =
        criticalDaysRaw is List
            ? criticalDaysRaw
                .map((entry) => (entry as num?)?.toInt())
                .whereType<int>()
                .toList()
            : const <int>[];

    final harvestWindow =
        json['harvest_window'] is Map
            ? Map<String, dynamic>.from(json['harvest_window'] as Map)
            : const <String, dynamic>{};

    return _CropProfileData(
      cropId: (json['crop_id'] ?? key).toString(),
      name: (json['name'] ?? key).toString(),
      totalDurationDays: (json['total_duration_days'] as num?)?.toInt() ?? 110,
      growthStages: growthStages,
      criticalIrrigationDays: criticalDays,
      irrigationMethod: (irrigation['method'] ?? 'Unknown').toString(),
      harvestStartBufferDays:
          (harvestWindow['start_buffer_days'] as num?)?.toInt() ?? -5,
      harvestEndBufferDays:
          (harvestWindow['end_buffer_days'] as num?)?.toInt() ?? 10,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'crop_id': cropId,
      'name': name,
      'total_duration_days': totalDurationDays,
      'growth_stages':
          growthStages
              .map(
                (stage) => <String, dynamic>{
                  'stage': stage.stage,
                  'start_day': stage.startDay,
                  'end_day': stage.endDay,
                },
              )
              .toList(),
      'irrigation': <String, dynamic>{
        'critical_days': criticalIrrigationDays,
        'method': irrigationMethod,
      },
      'harvest_window': <String, dynamic>{
        'start_buffer_days': harvestStartBufferDays,
        'end_buffer_days': harvestEndBufferDays,
      },
    };
  }
}

class _GrowthStageData {
  final String stage;
  final int startDay;
  final int endDay;

  const _GrowthStageData({
    required this.stage,
    required this.startDay,
    required this.endDay,
  });

  factory _GrowthStageData.fromJson(Map<String, dynamic> json) {
    return _GrowthStageData(
      stage: (json['stage'] ?? 'Stage').toString(),
      startDay: (json['start_day'] as num?)?.toInt() ?? 0,
      endDay: (json['end_day'] as num?)?.toInt() ?? 0,
    );
  }
}
