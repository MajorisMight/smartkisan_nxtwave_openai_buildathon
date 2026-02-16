import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

enum CropTaskCategory { generalSuggestion, actionTask, queryTask }

CropTaskCategory parseCropTaskCategory(dynamic value) {
  final raw = value?.toString().toLowerCase().trim() ?? '';
  switch (raw) {
    case 'general_suggestion':
      return CropTaskCategory.generalSuggestion;
    case 'query_task':
      return CropTaskCategory.queryTask;
    case 'action_task':
    default:
      return CropTaskCategory.actionTask;
  }
}

String cropTaskCategoryWireValue(CropTaskCategory category) {
  switch (category) {
    case CropTaskCategory.generalSuggestion:
      return 'general_suggestion';
    case CropTaskCategory.queryTask:
      return 'query_task';
    case CropTaskCategory.actionTask:
      return 'action_task';
  }
}

class CropTaskItem {
  final String id;
  final String title;
  final String subtitle;
  final bool isIrrigation;
  final bool isHighPriority;
  final CropTaskCategory category;
  final bool requiresInput;
  final String? inputLabel;
  final String? inputHint;
  final String? inputUnit;
  bool isDone;

  CropTaskItem({
    required this.id,
    required this.title,
    required this.subtitle,
    this.isIrrigation = false,
    this.isHighPriority = false,
    this.category = CropTaskCategory.actionTask,
    this.requiresInput = false,
    this.inputLabel,
    this.inputHint,
    this.inputUnit,
  }) : isDone = false;
}

class CropGrowthStage {
  final String stage;
  final int startDay;
  final int endDay;
  final Color color;

  CropGrowthStage({
    required this.stage,
    required this.startDay,
    required this.endDay,
    required this.color,
  });
}

class PestRiskWindow {
  final String pestName;
  final int riskStartDay;
  final int riskEndDay;
  final String severity;

  PestRiskWindow({
    required this.pestName,
    required this.riskStartDay,
    required this.riskEndDay,
    required this.severity,
  });
}

class CropProfile {
  final int totalDurationDays;
  final List<CropGrowthStage> growthStages;
  final List<PestRiskWindow> pestRiskWindows;
  final int harvestStartBufferDays;
  final int harvestEndBufferDays;

  CropProfile({
    required this.totalDurationDays,
    required this.growthStages,
    required this.pestRiskWindows,
    required this.harvestStartBufferDays,
    required this.harvestEndBufferDays,
  });
}

CropProfile parseCropProfile(Map<String, dynamic> json) {
  final stagesRaw = json['growth_stages'];
  final growthStages =
      stagesRaw is List
          ? stagesRaw.whereType<Map>().map((stage) {
            final map = Map<String, dynamic>.from(stage);
            return CropGrowthStage(
              stage: '${map['stage'] ?? 'Stage'}',
              startDay: (map['start_day'] as num?)?.toInt() ?? 0,
              endDay: (map['end_day'] as num?)?.toInt() ?? 0,
              color: parseHexColor('${map['color_code'] ?? '#4CAF50'}'),
            );
          }).toList()
          : <CropGrowthStage>[];

  final pestsRaw = json['pest_risk_windows'];
  final pestRiskWindows =
      pestsRaw is List
          ? pestsRaw.whereType<Map>().map((pest) {
            final map = Map<String, dynamic>.from(pest);
            return PestRiskWindow(
              pestName: '${map['pest_name'] ?? 'Pest'}',
              riskStartDay: (map['risk_start_day'] as num?)?.toInt() ?? 0,
              riskEndDay: (map['risk_end_day'] as num?)?.toInt() ?? 0,
              severity: '${map['severity'] ?? 'Low'}',
            );
          }).toList()
          : <PestRiskWindow>[];

  final harvestWindow = Map<String, dynamic>.from(
    (json['harvest_window'] as Map?) ?? const {},
  );

  return CropProfile(
    totalDurationDays: (json['total_duration_days'] as num?)?.toInt() ?? 110,
    growthStages: growthStages,
    pestRiskWindows: pestRiskWindows,
    harvestStartBufferDays:
        (harvestWindow['start_buffer_days'] as num?)?.toInt() ?? -5,
    harvestEndBufferDays:
        (harvestWindow['end_buffer_days'] as num?)?.toInt() ?? 10,
  );
}

String normalizeCropIdentifier(String value) {
  return value
      .toLowerCase()
      .replaceAll(RegExp(r'\(.*\)'), '')
      .replaceAll(RegExp(r'[^a-z0-9]+'), '');
}

Color parseHexColor(String hex) {
  final normalized = hex.replaceFirst('#', '').trim();
  final validHex = normalized.length == 6 ? 'FF$normalized' : normalized;
  final parsed = int.tryParse(validHex, radix: 16);
  if (parsed == null) return AppColors.primaryGreen;
  return Color(parsed);
}
