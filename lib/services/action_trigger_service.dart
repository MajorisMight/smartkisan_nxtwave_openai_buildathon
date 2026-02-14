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

  static Future<LocalActionTriggerResult> generateLocalTriggers({
    required Crop crop,
  }) async {
    final locationContext = await _resolveLocationContext(crop.location);

    WeatherData? weather;
    try {
      weather = await WeatherService.getCurrentWeather(locationContext);
    } catch (_) {
      weather = null;
    }

    final signals = <ActionSignal>[];

    final timelineSignals = _buildTimelineSignals(crop);
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
        'trigger_score': triggerScore,
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

  static List<ActionSignal> _buildTimelineSignals(Crop crop) {
    final signals = <ActionSignal>[];
    final now = DateTime.now();
    final daysSinceSowing = now.difference(crop.sowDate).inDays;
    final irrigationGapDays = _daysSinceLastIrrigation(crop);

    if (irrigationGapDays >= 8) {
      signals.add(
        ActionSignal(
          type: 'irrigation_gap_alert',
          source: 'crop_timeline',
          severity:
              irrigationGapDays >= 12
                  ? ActionSignalSeverity.high
                  : ActionSignalSeverity.medium,
          title: 'Irrigation cycle overdue',
          summary: 'Last irrigation appears $irrigationGapDays days ago.',
          payload: <String, dynamic>{
            'crop_id': crop.id,
            'days_since_sowing': daysSinceSowing,
            'irrigation_gap_days': irrigationGapDays,
            'recommended_action':
                'Check soil moisture and irrigate if moisture is low.',
          },
        ),
      );
    }

    if (daysSinceSowing >= 18 && daysSinceSowing <= 30) {
      signals.add(
        ActionSignal(
          type: 'growth_stage_alert',
          source: 'crop_timeline',
          severity: ActionSignalSeverity.medium,
          title: 'Likely active tillering window',
          summary: 'Crop is around day $daysSinceSowing from sowing.',
          payload: <String, dynamic>{
            'crop_id': crop.id,
            'current_stage': 'Tillering',
            'days_to_next_stage': 5,
            'recommended_action': 'Plan stage-specific nutrient top dressing.',
          },
        ),
      );
    }

    final harvestEtaDays = 115 - daysSinceSowing;
    if (harvestEtaDays >= 0 && harvestEtaDays <= 12) {
      signals.add(
        ActionSignal(
          type: 'harvest_window_alert',
          source: 'crop_timeline',
          severity:
              harvestEtaDays <= 7
                  ? ActionSignalSeverity.high
                  : ActionSignalSeverity.medium,
          title: 'Harvest window approaching',
          summary:
              'Estimated harvest window starts in about $harvestEtaDays days.',
          payload: <String, dynamic>{
            'crop_id': crop.id,
            'days_to_harvest_window': harvestEtaDays,
            'recommended_action':
                'Prepare labor, storage, and harvest logistics for the coming window.',
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
          final isIrrigation = signal.type == 'irrigation_gap_alert';
          return LocalActionTask(
            id: '${signal.type}-${signal.source}',
            title: signal.title,
            subtitle: signal.summary,
            isIrrigation: isIrrigation,
            isHighPriority: signal.severity == ActionSignalSeverity.high,
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

  static int _daysSinceLastIrrigation(Crop crop) {
    final irrigationLogs =
        crop.actionsHistory.where((action) {
          final text = '${action.action} ${action.notes}'.toLowerCase();
          return text.contains('irrigat');
        }).toList();
    if (irrigationLogs.isEmpty) {
      return DateTime.now().difference(crop.sowDate).inDays;
    }
    irrigationLogs.sort((a, b) => b.date.compareTo(a.date));
    return DateTime.now().difference(irrigationLogs.first.date).inDays;
  }
}
