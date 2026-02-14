import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:provider/provider.dart';

import '../constants/app_colors.dart';
import '../models/crop.dart';
import '../models/crop_action.dart';
import '../providers/profile_provider.dart';
import '../services/action_trigger_service.dart';
import '../services/gpt_service.dart';
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
  final bool isHighPriority;
  final bool requiresInput;
  final String? inputLabel;
  final String? inputHint;
  final String? inputUnit;
  bool isDone;

  _TaskItem({
    required this.id,
    required this.title,
    required this.subtitle,
    this.isIrrigation = false,
    this.isHighPriority = false,
    this.requiresInput = false,
    this.inputLabel,
    this.inputHint,
    this.inputUnit,
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
  bool _isLoadingTasks = true;
  bool _localThresholdReached = false;
  int _triggerScore = 0;
  bool _isLoadingLlmTasks = false;

  @override
  void initState() {
    super.initState();
    cropLogs = List<CropAction>.from(widget.crop.actionsHistory)
      ..sort((a, b) => b.date.compareTo(a.date));

    tasks = [];
    _loadCropProfile();
    _loadLocalActionTriggers();
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
          _buildOverviewRow('Expected harvest window', harvestWindow),
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
        if (_localThresholdReached) ...[
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF5E8),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFFFD7A8)),
            ),
            child: Text(
              'High-signal context detected (score $_triggerScore). Strategic task generation is enabled.',
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
        _buildPestRiskCard(),
        const SizedBox(height: 12),
        if (_isLoadingLlmTasks) _buildLlmLoadingCard(),
        if (_isLoadingTasks)
          _buildLoadingTasksCard()
        else if (tasks.isEmpty)
          _buildNoTasksCard()
        else
          ...tasks.map(_buildTaskTile),
      ],
    );
  }

  Widget _buildLoadingTasksCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: const Row(
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Scanning local signals for actionable triggers...',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoTasksCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: const Text(
        'No urgent action triggers right now. Continue regular monitoring.',
        style: TextStyle(
          fontSize: 13,
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildLlmLoadingCard() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: const Row(
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Prioritizing tasks with AI based on current triggers...',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
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
            activeRisk == null
                ? 'Pest risk'
                : 'Pest risk (${activeRisk.pestName})',
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
              color:
                  task.isHighPriority ? AppColors.error : AppColors.textPrimary,
              decoration: task.isDone ? TextDecoration.lineThrough : null,
            ),
          ),
          subtitle: Text(
            task.requiresInput
                ? '${task.subtitle} • Input required'
                : task.subtitle,
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

  Future<void> _loadLocalActionTriggers() async {
    setState(() {
      _isLoadingTasks = true;
    });

    try {
      final result = await ActionTriggerService.generateLocalTriggers(
        crop: widget.crop,
      );
      if (!mounted) return;

      setState(() {
        tasks =
            result.tasks
                .map(
                  (task) => _TaskItem(
                    id: task.id,
                    title: task.title,
                    subtitle: task.subtitle,
                    isIrrigation: task.isIrrigation,
                    isHighPriority: task.isHighPriority,
                    requiresInput: task.requiresInput,
                    inputLabel: task.inputLabel,
                    inputHint: task.inputHint,
                    inputUnit: task.inputUnit,
                  ),
                )
                .toList();
        _localThresholdReached = result.shouldQueryLlm;
        _triggerScore = result.triggerScore;
        _isLoadingTasks = false;
      });

      if (result.shouldQueryLlm && result.signals.isNotEmpty) {
        final recentLogs =
            cropLogs
                .take(10)
                .map(
                  (log) => <String, dynamic>{
                    'date': log.date.toIso8601String(),
                    'action': log.action,
                    'notes': log.notes,
                  },
                )
                .toList();
        await _loadLlmActionSuggestions({
          ...result.llmPayload,
          'recent_action_logs': recentLogs,
        });
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoadingTasks = false;
      });
    }
  }

  Future<void> _loadLlmActionSuggestions(
    Map<String, dynamic> llmPayload,
  ) async {
    setState(() {
      _isLoadingLlmTasks = true;
    });

    try {
      final response = await GptService.actionCenterSuggestions(
        contextData: llmPayload,
      );
      if (!mounted) return;

      final rawTasks = response['tasks'];
      if (rawTasks is List && rawTasks.isNotEmpty) {
        final mapped =
            rawTasks
                .whereType<Map>()
                .map((task) => Map<String, dynamic>.from(task))
                .toList();
        final parsed =
            mapped.asMap().entries.map((entry) {
              final index = entry.key;
              final task = entry.value;
              final completionType =
                  (task['completion_type'] ?? '')
                      .toString()
                      .toLowerCase()
                      .trim();
              final requiresInput = completionType == 'with_input';
              final inputConfig = task['input_config'];
              final inputMap =
                  inputConfig is Map
                      ? Map<String, dynamic>.from(inputConfig)
                      : const <String, dynamic>{};

              return _TaskItem(
                id:
                    (task['id'] ?? '').toString().trim().isNotEmpty
                        ? task['id'].toString().trim()
                        : 'llm-${DateTime.now().microsecondsSinceEpoch}-$index',
                title:
                    (task['title'] ?? '').toString().trim().isNotEmpty
                        ? task['title'].toString().trim()
                        : 'Field monitoring task',
                subtitle:
                    (task['subtitle'] ?? '').toString().trim().isNotEmpty
                        ? task['subtitle'].toString().trim()
                        : 'Review current field condition and take required action.',
                isIrrigation: task['is_irrigation'] == true,
                isHighPriority:
                    (task['priority'] ?? '').toString().toLowerCase() == 'high',
                requiresInput: requiresInput,
                inputLabel: _nullableText(inputMap['label']),
                inputHint: _nullableText(inputMap['placeholder']),
                inputUnit: _nullableText(inputMap['unit']),
              );
            }).toList();

        if (parsed.isNotEmpty) {
          setState(() {
            tasks = parsed.take(6).toList();
          });
        }
      }
    } catch (_) {
      // Fallback to deterministic tasks if LLM fails.
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingLlmTasks = false;
        });
      }
    }
  }

  void _onTaskTap(_TaskItem task) {
    if (task.isDone) {
      setState(() {
        task.isDone = false;
      });
      return;
    }

    _completeTask(task);
  }

  Future<void> _completeTask(_TaskItem task) async {
    String? capturedInput;
    if (task.requiresInput) {
      capturedInput = await _showTaskInputDialog(task);
      if (!mounted || capturedInput == null) return;
    }

    setState(() {
      task.isDone = true;
    });

    _appendTaskToActionLog(task, capturedInput: capturedInput);

    if (task.isIrrigation) {
      final now = DateTime.now();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Irrigation logged on ${_formatDate(now)}')),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Task marked complete and logged')),
    );
  }

  Future<String?> _showTaskInputDialog(_TaskItem task) async {
    final controller = TextEditingController();
    final label = task.inputLabel ?? 'Observation';
    final hint = task.inputHint ?? 'Enter value';
    final unit = task.inputUnit?.trim() ?? '';

    final value = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(label),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: InputDecoration(
              hintText: hint,
              suffixText: unit.isEmpty ? null : unit,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final input = controller.text.trim();
                if (input.isEmpty) return;
                Navigator.of(context).pop(input);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    controller.dispose();
    return value;
  }

  void _appendTaskToActionLog(_TaskItem task, {String? capturedInput}) {
    final now = DateTime.now();
    final inputLabel = (task.inputLabel ?? 'Input').trim();
    final inputUnit = (task.inputUnit ?? '').trim();
    final inputSuffix =
        capturedInput == null
            ? ''
            : ' | $inputLabel: $capturedInput${inputUnit.isEmpty ? '' : ' $inputUnit'}';
    final baseNotes = 'Marked complete from Action Center';

    cropLogs.insert(
      0,
      CropAction(
        id: now.millisecondsSinceEpoch,
        farmCropId: int.tryParse(widget.crop.id) ?? 0,
        date: now,
        action: task.isIrrigation ? 'Irrigated' : task.title,
        notes: '$baseNotes$inputSuffix',
      ),
    );
  }

  String? _nullableText(dynamic value) {
    final text = value?.toString().trim() ?? '';
    return text.isEmpty ? null : text;
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
            : (locationFromProfile.isEmpty
                ? 'Not provided'
                : locationFromProfile);

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
