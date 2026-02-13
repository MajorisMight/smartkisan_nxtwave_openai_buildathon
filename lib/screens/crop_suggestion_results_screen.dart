import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import 'crop_suggestion_screen.dart';

class CropSuggestionResultsScreen extends StatelessWidget {
  const CropSuggestionResultsScreen({
    super.key,
    required this.location,
    required this.season,
    required this.landAreaAcres,
    required this.overallSummary,
    required this.suggestions,
  });

  final String location;
  final String season;
  final double landAreaAcres;
  final String overallSummary;
  final List<Map<String, dynamic>> suggestions;

  double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse('$value') ?? 0.0;
  }

  Color _rankColor(int rank) {
    if (rank == 1) return const Color(0xFF2E7D32);
    if (rank == 2) return const Color(0xFF1976D2);
    if (rank == 3) return const Color(0xFFF57C00);
    return AppColors.textSecondary;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Suggested Crops'),
        backgroundColor: AppColors.backgroundLight,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'Run new suggestion',
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const CropSuggestionScreen()),
              );
            },
            icon: const Icon(
              Icons.auto_awesome,
              color: AppColors.secondaryOrange,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 6, 16, 20),
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFE8F5E9), Color(0xFFFFF3E0)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFDCEAD8)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Ranked by yield and revenue',
                    style: TextStyle(
                      color: AppColors.primaryGreenDark,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Location: $location',
                    style: const TextStyle(color: AppColors.textPrimary),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _contextPill('Season: $season'),
                      _contextPill(
                        'Area: ${landAreaAcres.toStringAsFixed(1)} acre',
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    overallSummary,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            ...suggestions.asMap().entries.map((entry) {
              final rank = entry.key + 1;
              final s = entry.value;
              final cropName = s['crop_name']?.toString() ?? 'Unknown crop';
              final duration = s['growth_duration_days']?.toString() ?? '-';
              final irrigation =
                  s['irrigation_requirements']?.toString() ?? 'Not specified';
              final yieldValue = _toDouble(s['estimated_yield']);
              final yieldUnit =
                  s['estimated_yield_unit']?.toString() ?? 'per acre';
              final cost = _toDouble(s['estimated_cost']);
              final revenue = _toDouble(s['estimated_revenue']);
              final currency = s['currency']?.toString() ?? 'INR';
              final confidence = s['confidence']?.toString() ?? 'Medium';
              final summary = s['overall_summary']?.toString() ?? '';

              return LayoutBuilder(
                builder: (context, constraints) {
                  final chipMaxWidth = constraints.maxWidth * 0.82;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.borderLight),
                      boxShadow: const [
                        BoxShadow(
                          color: AppColors.shadowLight,
                          blurRadius: 8,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                color: _rankColor(rank),
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                '$rank',
                                style: const TextStyle(
                                  color: AppColors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                cropName,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE3F2FD),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            confidence,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF0D47A1),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _metricChip(
                              Icons.timer,
                              '$duration days',
                              const Color(0xFFF1F8E9),
                              maxWidth: chipMaxWidth,
                            ),
                            _metricChip(
                              Icons.grass,
                              '${yieldValue.toStringAsFixed(1)} $yieldUnit',
                              const Color(0xFFE3F2FD),
                              maxWidth: chipMaxWidth,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        _irrigationRow(irrigation),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: _valueTile(
                                label: 'Estimated cost',
                                value: '$currency ${cost.toStringAsFixed(1)}',
                                valueColor: AppColors.warning,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _valueTile(
                                label: 'Estimated revenue',
                                value:
                                    '$currency ${revenue.toStringAsFixed(1)}',
                                valueColor: AppColors.success,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          summary,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            height: 1.3,
                          ),
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  );
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _metricChip(
    IconData icon,
    String label,
    Color bgColor, {
    required double maxWidth,
  }) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: AppColors.textPrimary),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _valueTile({
    required String label,
    required String value,
    required Color valueColor,
  }) {
    return SizedBox(
      height: 78,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFE5EAF1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    value,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: valueColor,
                    ),
                    maxLines: 1,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _irrigationRow(String irrigation) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.water_drop_outlined,
            size: 16,
            color: AppColors.textPrimary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Irrigation: $irrigation',
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
                height: 1.25,
              ),
              softWrap: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _contextPill(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFDCE3EC)),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}
