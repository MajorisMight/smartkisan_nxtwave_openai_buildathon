import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:provider/provider.dart';

import '../constants/app_colors.dart';
import '../models/crop.dart';
import '../models/crop_action.dart';
import '../providers/profile_provider.dart';
import 'fertilizer_screen.dart';

class CropsScreen extends StatefulWidget {
  final Crop crop;

  const CropsScreen({super.key, required this.crop});

  @override
  State<CropsScreen> createState() => _CropsScreenState();
}

enum _CropSection { actionCenter, fertilizer, activityLog }

class _TaskItem {
  final String id;
  final String title;
  final String subtitle;
  final bool isIrrigation;
  bool isDone;

  _TaskItem({
    required this.id,
    required this.title,
    required this.subtitle,
    this.isIrrigation = false,
  }) : isDone = false;
}

class _GrowthStage {
  final String stage;
  final int startDay;
  final int endDay;
  final Color color;

  _GrowthStage({
    required this.stage,
    required this.startDay,
    required this.endDay,
    required this.color,
  });
}

class _PestRiskWindow {
  final String pestName;
  final int riskStartDay;
  final int riskEndDay;
  final String severity;

  _PestRiskWindow({
    required this.pestName,
    required this.riskStartDay,
    required this.riskEndDay,
    required this.severity,
  });
}

class _CropProfile {
  final int totalDurationDays;
  final List<_GrowthStage> growthStages;
  final List<_PestRiskWindow> pestRiskWindows;
  final int harvestStartBufferDays;
  final int harvestEndBufferDays;

  _CropProfile({
    required this.totalDurationDays,
    required this.growthStages,
    required this.pestRiskWindows,
    required this.harvestStartBufferDays,
    required this.harvestEndBufferDays,
  });
}

class _CropsScreenState extends State<CropsScreen> {
  late List<CropAction> cropLogs;
  late List<_TaskItem> tasks;
  _CropSection selectedSection = _CropSection.actionCenter;
  _CropProfile? _profile;

  @override
  void initState() {
    super.initState();
    cropLogs = List<CropAction>.from(widget.crop.actionsHistory)
      ..sort((a, b) => b.date.compareTo(a.date));

    tasks = [
      _TaskItem(
        id: 'irrigation-weekly',
        title: 'Irrigation suggested this week',
        subtitle: 'Tap to mark complete and add an irrigation log entry.',
        isIrrigation: true,
      ),
      _TaskItem(
        id: 'pest-check',
        title: 'Scout border rows for pest signs',
        subtitle: 'Pest risk is currently medium this week.',
      ),
      _TaskItem(
        id: 'soil-check',
        title: 'Check soil moisture in 2 sample spots',
        subtitle: 'Record values before the next irrigation cycle.',
      ),
    ];
    _loadCropProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildOverviewCard(),
                    const SizedBox(height: 20),
                    _buildSectionPicker(),
                    const SizedBox(height: 16),
                    _buildSectionBody(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 12, 16, 8),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                Navigator.of(context).pop();
              }
            },
            icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              widget.crop.name,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewCard() {
    final daysSinceSowing = _daysSinceSowing;
    final profile = _profile;
    final currentStage = _currentStage(daysSinceSowing, profile);
    final stageLabel = currentStage?.stage ?? _getStageLabel(widget.crop.stage);
    final harvestWindow = _harvestWindowText(profile);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Crop Overview',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 14),
          _buildOverviewRow(
            'Area',
            '${widget.crop.areaAcres?.toStringAsFixed(1) ?? 'N/A'} acres',
          ),
          _buildOverviewRow(
            'Variety',
            widget.crop.type?.isNotEmpty == true
                ? widget.crop.type!
                : 'Not set',
          ),
          _buildOverviewRow('Planting date', _formatDate(widget.crop.sowDate)),
          _buildOverviewRow(
            'Expected harvest window',
            harvestWindow,
          ),
          const SizedBox(height: 14),
          const Text(
            'Growth timeline',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          _buildContinuousTimeline(daysSinceSowing, profile),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.backgroundLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              'You are in $stageLabel stage (Day $daysSinceSowing)',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 150,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStageChip(String label) {
    final isActive = _isStageActive(label);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isActive ? AppColors.primaryGreen : AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isActive ? AppColors.primaryGreen : AppColors.borderLight,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isActive ? AppColors.white : AppColors.textSecondary,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildContinuousTimeline(int dayNumber, _CropProfile? profile) {
    final stages = profile?.growthStages ?? _defaultGrowthStages;
    final totalDays = profile?.totalDurationDays ?? 110;
    final progress = (dayNumber / totalDays).clamp(0.0, 1.0).toDouble();
    final gradient = LinearGradient(
      colors: stages.map((stage) => stage.color).toList(),
      stops: _buildGradientStops(stages, totalDays),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            return Stack(
              children: [
                Container(
                  height: 12,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.backgroundLight,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: AppColors.borderLight),
                  ),
                ),
                Container(
                  height: 12,
                  width: width * progress,
                  decoration: BoxDecoration(
                    gradient: gradient,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children:
                stages
                    .map(
                      (stage) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: _buildStageChip(stage.stage),
                      ),
                    )
                    .toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionPicker() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          _sectionButton(_CropSection.actionCenter, 'Action Center'),
          _sectionButton(_CropSection.fertilizer, 'Fertilizer'),
          _sectionButton(_CropSection.activityLog, 'Activity Log'),
        ],
      ),
    );
  }

  Widget _sectionButton(_CropSection section, String title) {
    final selected = selectedSection == section;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => selectedSection = section),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? AppColors.primaryGreen : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: selected ? AppColors.white : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionBody() {
    switch (selectedSection) {
      case _CropSection.actionCenter:
        return _buildActionCenterSection();
      case _CropSection.fertilizer:
        return _buildFertilizerSection();
      case _CropSection.activityLog:
        return _buildActivityLogSection();
    }
  }

  Widget _buildActionCenterSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildPestRiskCard(),
        const SizedBox(height: 12),
        ...tasks.map(_buildTaskTile),
      ],
    );
  }

  Widget _buildPestRiskCard() {
    final profile = _profile;
    final activeRisk = _activePestRisk(profile);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            activeRisk == null ? 'Pest risk' : 'Pest risk (${activeRisk.pestName})',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            activeRisk?.severity ?? 'Low',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: _riskColor(activeRisk?.severity ?? 'Low'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskTile(_TaskItem task) {
    return Dismissible(
      key: ValueKey(task.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) {
        setState(() {
          tasks.removeWhere((item) => item.id == task.id);
        });
      },
      background: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        alignment: Alignment.centerRight,
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete_outline, color: AppColors.white),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: ListTile(
          onTap: () => _onTaskTap(task),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 2,
          ),
          title: Text(
            task.title,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
              decoration: task.isDone ? TextDecoration.lineThrough : null,
            ),
          ),
          subtitle: Text(
            task.subtitle,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
          trailing: Icon(
            task.isDone ? Icons.check_circle : Icons.radio_button_unchecked,
            color: task.isDone ? AppColors.success : AppColors.textHint,
          ),
        ),
      ),
    );
  }

  void _onTaskTap(_TaskItem task) {
    setState(() {
      task.isDone = !task.isDone;
    });

    if (task.isIrrigation && task.isDone) {
      final now = DateTime.now();
      cropLogs.insert(
        0,
        CropAction(
          id: now.millisecondsSinceEpoch,
          farmCropId: int.tryParse(widget.crop.id) ?? 0,
          date: now,
          action: 'Irrigated',
          notes: 'Marked complete from Action Center',
        ),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Irrigation logged on ${_formatDate(now)}')),
      );
    }
  }

  Widget _buildFertilizerSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Stage Based Fertilizer',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Calculate fertilizer for the current crop stage (for example: basal, tillering). Soil test is optional but recommended.',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _navigateToFertilizer,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                foregroundColor: AppColors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text('Open Stage Based Calculator'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityLogSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Crop Activity Log',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              IconButton(
                onPressed: _showAddLogDialog,
                icon: const Icon(Icons.add, color: AppColors.primaryGreen),
                tooltip: 'Add activity',
              ),
            ],
          ),
          const SizedBox(height: 4),
          if (cropLogs.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'No activity logged yet.',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            )
          else
            ...cropLogs.map(_buildLogRow),
        ],
      ),
    );
  }

  Widget _buildLogRow(CropAction action) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.borderLight)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              action.action,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Text(
            _formatDate(action.date),
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  void _showAddLogDialog() {
    final actionController = TextEditingController();

    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add activity'),
          content: TextField(
            controller: actionController,
            decoration: const InputDecoration(
              labelText: 'Activity',
              hintText: 'e.g. Fertilized, Weed removal',
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final text = actionController.text.trim();
                if (text.isEmpty) {
                  return;
                }
                setState(() {
                  final now = DateTime.now();
                  cropLogs.insert(
                    0,
                    CropAction(
                      id: now.millisecondsSinceEpoch,
                      farmCropId: int.tryParse(widget.crop.id) ?? 0,
                      date: now,
                      action: text,
                      notes: '',
                    ),
                  );
                });
                Navigator.of(context).pop();
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _navigateToFertilizer() {
    final currentStage =
        _currentStage(_daysSinceSowing, _profile)?.stage ??
        _getStageLabel(widget.crop.stage);
    final profile = context.read<ProfileProvider>().profile;
    final locationFromProfile = [
      profile?.village,
      profile?.district,
      profile?.state,
    ].where((v) => v != null && v.trim().isNotEmpty).join(', ');
    final resolvedLocation =
        widget.crop.location.trim().isNotEmpty
            ? widget.crop.location.trim()
            : (locationFromProfile.isEmpty ? 'Not provided' : locationFromProfile);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => FertilizerScreen.stageBased(
              crop: widget.crop,
              initialStage: currentStage,
              initialLocation: resolvedLocation,
            ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _getStageLabel(String stage) {
    switch (stage.toLowerCase()) {
      case 'sowing':
        return 'Seedling';
      case 'growth':
        return 'Vegetative';
      case 'fertilizer':
        return 'Flowering';
      case 'harvest':
        return 'Harvest';
      default:
        return 'Growth';
    }
  }

  int get _daysSinceSowing {
    final days = DateTime.now().difference(widget.crop.sowDate).inDays + 1;
    return days < 1 ? 1 : days;
  }

  List<_GrowthStage> get _defaultGrowthStages => [
    _GrowthStage(
      stage: 'Seedling',
      startDay: 0,
      endDay: 20,
      color: AppColors.primaryGreenLight,
    ),
    _GrowthStage(
      stage: 'Vegetative',
      startDay: 21,
      endDay: 55,
      color: AppColors.primaryGreen,
    ),
    _GrowthStage(
      stage: 'Flowering',
      startDay: 56,
      endDay: 85,
      color: AppColors.warning,
    ),
    _GrowthStage(
      stage: 'Harvest',
      startDay: 86,
      endDay: 110,
      color: Colors.orange,
    ),
  ];

  List<double> _buildGradientStops(List<_GrowthStage> stages, int totalDays) {
    if (stages.length <= 1) return const [0.0];
    return stages
        .map((stage) => (stage.endDay / totalDays).clamp(0.0, 1.0).toDouble())
        .toList();
  }

  bool _isStageActive(String stageLabel) {
    final current = _currentStage(_daysSinceSowing, _profile)?.stage;
    return current?.toLowerCase() == stageLabel.toLowerCase();
  }

  _GrowthStage? _currentStage(int dayNumber, _CropProfile? profile) {
    final stages = profile?.growthStages;
    if (stages == null || stages.isEmpty) return null;
    for (final stage in stages) {
      if (dayNumber >= stage.startDay && dayNumber <= stage.endDay) {
        return stage;
      }
    }
    if (dayNumber < stages.first.startDay) return stages.first;
    return stages.last;
  }

  String _harvestWindowText(_CropProfile? profile) {
    if (profile == null) {
      return '${_formatDate(widget.crop.sowDate.add(const Duration(days: 90)))} - ${_formatDate(widget.crop.sowDate.add(const Duration(days: 110)))}';
    }

    final maturityDate = widget.crop.sowDate.add(
      Duration(days: profile.totalDurationDays),
    );
    final harvestStart = maturityDate.add(
      Duration(days: profile.harvestStartBufferDays),
    );
    final harvestEnd = maturityDate.add(
      Duration(days: profile.harvestEndBufferDays),
    );

    return '${_formatDate(harvestStart)} - ${_formatDate(harvestEnd)}';
  }

  _PestRiskWindow? _activePestRisk(_CropProfile? profile) {
    final windows = profile?.pestRiskWindows;
    if (windows == null || windows.isEmpty) return null;
    final day = _daysSinceSowing;
    final active = windows.where(
      (risk) => day >= risk.riskStartDay && day <= risk.riskEndDay,
    );
    if (active.isEmpty) return null;
    return active.reduce((a, b) {
      return _severityRank(a.severity) >= _severityRank(b.severity) ? a : b;
    });
  }

  int _severityRank(String severity) {
    switch (severity.toLowerCase()) {
      case 'low':
        return 1;
      case 'medium':
        return 2;
      case 'high':
        return 3;
      case 'extreme':
        return 4;
      default:
        return 0;
    }
  }

  Color _riskColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'low':
        return AppColors.success;
      case 'medium':
        return AppColors.warning;
      case 'high':
      case 'extreme':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  Future<void> _loadCropProfile() async {
    try {
      final jsonString = await rootBundle.loadString(
        'lib/constants/crop_profiles.json',
      );
      final decoded = jsonDecode(jsonString);
      if (decoded is! Map<String, dynamic>) return;

      final cropType = widget.crop.type?.trim();
      final cropName = widget.crop.name.trim();
      final keyCandidates = <String>{
        if (cropType != null && cropType.isNotEmpty) cropType,
        cropName,
        if (cropType != null && cropType.isNotEmpty)
          cropType.split('(').first.trim(),
      };
      final normalizedCandidates =
          keyCandidates
              .map(_normalizeCropIdentifier)
              .where((value) => value.isNotEmpty)
              .toSet();

      Map<String, dynamic>? selected;
      for (final entry in decoded.entries) {
        final key = _normalizeCropIdentifier(entry.key);
        final value = entry.value;
        if (value is! Map) continue;
        final data = Map<String, dynamic>.from(value);
        final profileName = _normalizeCropIdentifier('${data['name'] ?? ''}');
        if (normalizedCandidates.contains(key) ||
            normalizedCandidates.contains(profileName)) {
          selected = data;
          break;
        }
      }

      if (selected == null) return;
      final profile = _parseCropProfile(selected);
      if (!mounted) return;
      setState(() {
        _profile = profile;
      });
    } catch (_) {
      // Fall back to existing defaults if profile loading fails.
    }
  }

  _CropProfile _parseCropProfile(Map<String, dynamic> json) {
    final stagesRaw = json['growth_stages'];
    final growthStages =
        stagesRaw is List
            ? stagesRaw.whereType<Map>().map((stage) {
              final map = Map<String, dynamic>.from(stage);
              return _GrowthStage(
                stage: '${map['stage'] ?? 'Stage'}',
                startDay: (map['start_day'] as num?)?.toInt() ?? 0,
                endDay: (map['end_day'] as num?)?.toInt() ?? 0,
                color: _parseHexColor('${map['color_code'] ?? '#4CAF50'}'),
              );
            }).toList()
            : <_GrowthStage>[];

    final pestsRaw = json['pest_risk_windows'];
    final pestRiskWindows =
        pestsRaw is List
            ? pestsRaw.whereType<Map>().map((pest) {
              final map = Map<String, dynamic>.from(pest);
              return _PestRiskWindow(
                pestName: '${map['pest_name'] ?? 'Pest'}',
                riskStartDay: (map['risk_start_day'] as num?)?.toInt() ?? 0,
                riskEndDay: (map['risk_end_day'] as num?)?.toInt() ?? 0,
                severity: '${map['severity'] ?? 'Low'}',
              );
            }).toList()
            : <_PestRiskWindow>[];

    final harvestWindow = Map<String, dynamic>.from(
      (json['harvest_window'] as Map?) ?? const {},
    );

    return _CropProfile(
      totalDurationDays: (json['total_duration_days'] as num?)?.toInt() ?? 110,
      growthStages: growthStages,
      pestRiskWindows: pestRiskWindows,
      harvestStartBufferDays:
          (harvestWindow['start_buffer_days'] as num?)?.toInt() ?? -5,
      harvestEndBufferDays:
          (harvestWindow['end_buffer_days'] as num?)?.toInt() ?? 10,
    );
  }

  String _normalizeCropIdentifier(String value) {
    return value
        .toLowerCase()
        .replaceAll(RegExp(r'\(.*\)'), '')
        .replaceAll(RegExp(r'[^a-z0-9]+'), '');
  }

  Color _parseHexColor(String hex) {
    final normalized = hex.replaceFirst('#', '').trim();
    final validHex = normalized.length == 6 ? 'FF$normalized' : normalized;
    final parsed = int.tryParse(validHex, radix: 16);
    if (parsed == null) return AppColors.primaryGreen;
    return Color(parsed);
  }
}
