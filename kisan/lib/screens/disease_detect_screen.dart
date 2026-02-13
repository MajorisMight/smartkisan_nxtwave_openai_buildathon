import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_colors.dart';
import '../services/recommendation_service.dart';

class DiseaseDetectScreen extends StatefulWidget {
  const DiseaseDetectScreen({super.key});

  @override
  State<DiseaseDetectScreen> createState() => _DiseaseDetectScreenState();
}

class _DiseaseDetectScreenState extends State<DiseaseDetectScreen> {
  XFile? _image;
  bool _loading = false;
  Map<String, dynamic> profile = {};
  Map<String, dynamic> diagnosis = {};

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    //entire collection of inputs during onboarding
    final profileStr = prefs.getString('onboarding_draft');
    if (profileStr != null && profileStr.isNotEmpty) {
      setState(() {
        profile = Map<String, dynamic>.from(jsonDecode(profileStr));
      });
    }
  }

  Future<void> _pick(ImageSource src) async {
    if (_loading) return;
    final picker = ImagePicker();
    final file = await picker.pickImage(source: src, imageQuality: 70);
    if (file != null) {
      setState(() {
        _image = file;
        _loading = true;
        diagnosis = {};
      });
      try {
        await _loadProfile();
        final selectedCropName =
            profile['crop']?.toString() ??
            profile['crop_name']?.toString() ??
            'Unknown crop';

        final detected = await RecommendationService.diagnoseDisease(
          image: File(file.path),
          profile: profile,
          crop: selectedCropName,
        );
        if (!mounted) return;
        setState(() {
          diagnosis = detected;
        });

      // final json = jsonEncode(diagnosis);

      // final name = diagnosis['disease_name']?.toString() ?? 'Unknown';
      // final conf = (diagnosis['confidence'] is num)
      //     ? (diagnosis['confidence'] as num).toDouble()
      //     : 0.5;
      // final actions = (diagnosis['recommended_actions'] as List<dynamic>? ?? [])
      //     .cast<Map<String, dynamic>>();
      // final remedies = actions.map((a) => Remedy(
      //       type: (a['type'] ?? 'organic').toString(),
      //       name: (a['name'] ?? 'Remedy').toString(),
      //       instruction: (a['instruction'] ?? '').toString(),
      //       marketplaceQuery: null,
      //     )).toList();
      // setState(() {
      // _result = DiseaseDetectionResult(diseaseName: name, confidence: conf, remedies: remedies);
      //   _result = customAnalysisCard(context, diseaseJson);
      // });
      } catch (e, st) {
        debugPrint('Disease diagnose failed: $e');
        debugPrint('$st');
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_diagnosisErrorMessage(e)),
          ),
        );
      } finally {
        if (mounted) {
          setState(() {
            _loading = false;
          });
        }
      }
    }
  }

  String _diagnosisErrorMessage(Object error) {
    final message = error.toString().toLowerCase();
    if (message.contains('gemini_api_key') ||
        message.contains('missing gemini_api_key') ||
        message.contains('gemini not initialized')) {
      return 'AI service is not configured. Check GEMINI_API_KEY and restart.';
    }
    if (message.contains('401') || message.contains('403')) {
      return 'AI backend rejected the request (auth issue). Check API key/project.';
    }
    if (message.contains('429') || message.contains('quota')) {
      return 'AI backend quota limit reached. Try again later.';
    }
    if (message.contains('socketexception') ||
        message.contains('failed host lookup') ||
        message.contains('network')) {
      return 'Network error while contacting AI backend. Check internet and retry.';
    }
    return 'Unable to analyze image right now. Please try again.';
  }

  String get _diagnosisStatus =>
      diagnosis['result_status']?.toString().toUpperCase() ??
      RecommendationService.diseaseStatusDidNotIdentify;

  Widget _buildDiagnosisOutput(BuildContext context) {
    if (_diagnosisStatus == RecommendationService.diseaseStatusIdentified) {
      return customAnalysisCard(context, diagnosis);
    }

    final isIrrelevant =
        _diagnosisStatus == RecommendationService.diseaseStatusIrrelevant;
    final title = isIrrelevant ? 'Irrelevant Image' : 'Could Not Identify';
    final icon = isIrrelevant ? Icons.image_not_supported : Icons.photo_filter;
    final message =
        diagnosis['user_message']?.toString().trim().isNotEmpty == true
            ? diagnosis['user_message'].toString().trim()
            : isIrrelevant
            ? 'This image does not appear to be a crop or leaf. Please upload a crop image.'
            : 'Image quality is not sufficient to identify disease. Please retry with a clearer crop photo.';

    return Container(
      margin: EdgeInsets.only(top: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 24.sp, color: AppColors.secondaryOrange),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  message,
                  style: GoogleFonts.poppins(
                    fontSize: 13.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  'Tip: keep leaf area in focus, use daylight, and avoid blurry shots.',
                  style: GoogleFonts.poppins(
                    fontSize: 12.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map) return Map<String, dynamic>.from(value);
    return const <String, dynamic>{};
  }

  List<Map<String, dynamic>> _asListOfMap(dynamic value) {
    if (value is! List) return const <Map<String, dynamic>>[];
    return value
        .whereType<Map>()
        .map((entry) => Map<String, dynamic>.from(entry))
        .toList();
  }

  double _asDouble(dynamic value, {double fallback = 0.0}) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? fallback;
    return fallback;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundLight,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textPrimary, size: 22.sp),
          onPressed: () {
            if (context.canPop()) {
              Navigator.of(context).pop();
            } else {
              context.go('/home');
            }
          },
        ),
        title: Text(
          'Disease Detection',
          style: GoogleFonts.poppins(
            fontSize: 20.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              SizedBox(height: 12.h),
              _buildPickerRow(),
              SizedBox(height: 12.h),
              if (_image != null) _buildPreview(),
              if (_loading)
                Center(
                  child: Padding(
                    padding: EdgeInsets.all(20.w),
                    child: const CircularProgressIndicator(),
                  ),
                ),
              if (diagnosis.isNotEmpty) _buildDiagnosisOutput(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          Container(
            width: 40.w,
            height: 40.w,
            decoration: const BoxDecoration(
              color: AppColors.primaryGreen,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.camera_alt_outlined, color: AppColors.white, size: 20.sp),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Capture or upload crop image',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 14.sp,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Use clear daylight photos for better accuracy',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 12.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPickerRow() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _pick(ImageSource.camera),
            icon: const Icon(Icons.photo_camera),
            label: const Text('Camera'),
            style: ElevatedButton.styleFrom(
              minimumSize: Size(double.infinity, 48.h),
              backgroundColor: AppColors.primaryGreen,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
            ),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _pick(ImageSource.gallery),
            icon: const Icon(Icons.photo_library_outlined),
            label: const Text('Gallery'),
            style: ElevatedButton.styleFrom(
              minimumSize: Size(double.infinity, 48.h),
              backgroundColor: AppColors.white,
              foregroundColor: AppColors.primaryGreen,
              side: const BorderSide(color: AppColors.primaryGreen),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPreview() {
    return Container(
      margin: EdgeInsets.only(top: 8.h),
      height: 200.h,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [BoxShadow(color: AppColors.shadowLight, blurRadius: 8, offset: Offset(0, 4))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.r),
        child: Image.file(
          File(_image!.path),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
  //  Widget customAnalysisCard(BuildContext context, Map<String, dynamic> diseaseJson) {
  //   final diseaseName = diseaseJson['disease_name'] ?? 'Unknown';
  //   final confidence = (diseaseJson['confidence'] ?? 0.0) * 100;

  //   final probabilityDist =
  //       List<Map<String, dynamic>>.from(diseaseJson['probability_distribution'] ?? []);
  //   final actions =
  //       List<Map<String, dynamic>>.from(diseaseJson['recommended_actions'] ?? []);
  //   final explainability =
  //       List<Map<String, dynamic>>.from(diseaseJson['evidence_explainability'] ?? []);
  //   final notes = diseaseJson['notes'] ?? '';

  //   return SingleChildScrollView(
  //     padding: const EdgeInsets.all(16),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         // Main disease & confidence
  //         Card(
  //           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  //           elevation: 4,
  //           child: Padding(
  //             padding: const EdgeInsets.all(16),
  //             child: Column(
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               children: [
  //                 Text("Predicted Disease",
  //                     style: Theme.of(context).textTheme.titleLarge),
  //                 const SizedBox(height: 8),
  //                 Text(
  //                   diseaseName,
  //                   style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
  //                 ),
  //                 const SizedBox(height: 8),
  //                 LinearProgressIndicator(
  //                   value: (confidence / 100).clamp(0.0, 1.0),
  //                   backgroundColor: Colors.grey[300],
  //                   color: confidence >= 85
  //                       ? Colors.green
  //                       : confidence >= 60
  //                           ? Colors.orange
  //                           : Colors.red,
  //                 ),
  //                 const SizedBox(height: 4),
  //                 Text("Confidence: ${confidence.toStringAsFixed(1)}%"),
  //               ],
  //             ),
  //           ),
  //         ),

  //         const SizedBox(height: 16),

  //         // Why this disease (Explainability)
  //         if (explainability.isNotEmpty) ...[
  //           Text(
  //             "Why this disease?",
  //             style: Theme.of(context).textTheme.titleMedium,
  //           ),
  //           const SizedBox(height: 8),
  //           ...explainability.map((e) {
  //             return ListTile(
  //               leading: const Icon(Icons.lightbulb_outline, color: Colors.orange),
  //               title: Text(e['feature'] ?? ''),
  //               subtitle: Text(e['how_it_influenced_decision'] ?? ''),
  //             );
  //           }),
  //           const SizedBox(height: 16),
  //         ],

  //         // Probability distribution
  //         if (probabilityDist.isNotEmpty) ...[
  //           Text(
  //             "Other Possible Diseases",
  //             style: Theme.of(context).textTheme.titleMedium,
  //           ),
  //           const SizedBox(height: 8),
  //           ...probabilityDist.map((d) {
  //             final prob = ((d['probability'] ?? 0.0) * 100).toStringAsFixed(1);
  //             return ListTile(
  //               contentPadding: EdgeInsets.zero,
  //               title: Text(d['name'] ?? "Unknown"),
  //               subtitle: Text(d['evidence_rationale'] ?? ''),
  //               trailing: Text("$prob%"),
  //             );
  //           }),
  //           const SizedBox(height: 16),
  //         ],

  //         // Recommended actions
  //         if (actions.isNotEmpty) ...[
  //           Text(
  //             "Recommended Actions",
  //             style: Theme.of(context).textTheme.titleMedium,
  //           ),
  //           const SizedBox(height: 8),
  //           ...actions.map((a) {
  //             return Card(
  //               color: a['type'] == "chemical"
  //                   ? Colors.red[50]
  //                   : a['type'] == "organic"
  //                       ? Colors.green[50]
  //                       : Colors.blue[50],
  //               child: ListTile(
  //                 title: Text(a['name'] ?? ''),
  //                 subtitle: Column(
  //                   crossAxisAlignment: CrossAxisAlignment.start,
  //                   children: [
  //                     Text(a['instruction'] ?? ''),
  //                     if (a['justification'] != null)
  //                       Text("Reason: ${a['justification']}",
  //                           style: const TextStyle(
  //                               fontSize: 12, fontStyle: FontStyle.italic)),
  //                   ],
  //                 ),
  //                 trailing: Column(
  //                   mainAxisAlignment: MainAxisAlignment.center,
  //                   children: [
  //                     Text("Urgency: ${a['urgency'] ?? 'N/A'}"),
  //                     Text(
  //                         "Eff: ${(a['estimated_effectiveness'] ?? 0.0 * 100).toStringAsFixed(0)}%"),
  //                   ],
  //                 ),
  //               ),
  //             );
  //           }),
  //           const SizedBox(height: 16),
  //         ],

  //         // Notes
  //         if (notes.isNotEmpty) ...[
  //           Text(
  //             "Notes",
  //             style: Theme.of(context).textTheme.titleMedium,
  //           ),
  //           const SizedBox(height: 8),
  //           Text(notes),
  //         ],
  //       ],
  //     ),
  //   );
  // }

  /// Response from Claude
  Widget customAnalysisCard(BuildContext context, Map<String, dynamic> diseaseJson) {
  final diseaseName = diseaseJson['disease_name']?.toString() ?? 'Unknown';
  final confidence = _asDouble(diseaseJson['confidence']) * 100;
  final weatherSummary = _asMap(diseaseJson['weather_summary']);
  final fieldHistory = _asMap(diseaseJson['field_history_considerations']);
  final geoLocation = _asMap(diseaseJson['geo_location']);
  final differentials = _asListOfMap(diseaseJson['differentials']);
  final actions = _asListOfMap(diseaseJson['recommended_actions']);
  final explainability = _asListOfMap(diseaseJson['evidence_explainability']);
  final confirmTests = _asListOfMap(diseaseJson['recommended_confirmatory_tests']);
  final references = _asListOfMap(diseaseJson['references']);
  final notes = diseaseJson['notes']?.toString() ?? '';

  Color getConfidenceColor(double conf) {
    if (conf >= 85) return Colors.green;
    if (conf >= 70) return Colors.orange;
    return Colors.red;
  }

  Color getUrgencyColor(String urgency) {
    switch (urgency.toLowerCase()) {
      case 'high': return Colors.red[100]!;
      case 'medium': return Colors.orange[100]!;
      case 'low': return Colors.green[100]!;
      default: return Colors.grey[100]!;
    }
  }

  IconData getActionIcon(String type) {
    switch (type.toLowerCase()) {
      case 'chemical': return Icons.science;
      case 'organic': return Icons.eco;
      case 'cultural': return Icons.agriculture;
      case 'diagnostic': return Icons.search;
      default: return Icons.info;
    }
  }

  String getRiskLevel(String level) {
    switch (level.toLowerCase()) {
      case 'high': return '🔴 High Risk';
      case 'medium': return '🟡 Medium Risk';
      case 'low': return '🟢 Low Risk';
      default: return '⚪ Unknown';
    }
  }

  return Container(
    margin: EdgeInsets.only(top: 16.h),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with farm context
        Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 6,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                colors: [Colors.green[700]!, Colors.green[500]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.analytics, color: Colors.white, size: 28),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          "Digital Farm Analysis Report",
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (geoLocation.isNotEmpty) ...[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.location_on, color: Colors.white70, size: 16),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            "${geoLocation['district'] ?? ''}, ${geoLocation['state'] ?? ''}, ${geoLocation['country'] ?? ''}",
                            style: const TextStyle(color: Colors.white70),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (fieldHistory['crop_stage'] != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.timeline, color: Colors.white70, size: 16),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            "Crop Stage: ${fieldHistory['crop_stage']}",
                            style: const TextStyle(color: Colors.white70),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),

        const SizedBox(height: 20),

        // Primary Diagnosis
        Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.healing, color: getConfidenceColor(confidence)),
                    const SizedBox(width: 8),
                    Text(
                      "Primary Diagnosis",
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: getConfidenceColor(confidence).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: getConfidenceColor(confidence).withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        diseaseName,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: getConfidenceColor(confidence),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Diagnostic Confidence", 
                                     style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                                const SizedBox(height: 4),
                                LinearProgressIndicator(
                                  value: (confidence / 100).clamp(0.0, 1.0),
                                  backgroundColor: Colors.grey[300],
                                  color: getConfidenceColor(confidence),
                                  minHeight: 8,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: getConfidenceColor(confidence),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              "${confidence.toStringAsFixed(1)}%",
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Weather Impact Analysis
        if (weatherSummary.isNotEmpty) ...[
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.wb_cloudy, color: Colors.blue),
                      const SizedBox(width: 8),
                      Text("Weather Impact Analysis", 
                           style: Theme.of(context).textTheme.titleMedium?.copyWith(
                             fontWeight: FontWeight.bold,
                           )),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: _buildWeatherStat(
                                "🌧️",
                                "Rainfall",
                                "${weatherSummary['total_rainfall_mm'] ?? 0} mm",
                              ),
                            ),
                            Expanded(
                              child: _buildWeatherStat(
                                "🌡️",
                                "Avg Temp",
                                "${weatherSummary['avg_temperature_c'] ?? 0}°C",
                              ),
                            ),
                            Expanded(
                              child: _buildWeatherStat(
                                "💧",
                                "Humidity",
                                "${weatherSummary['avg_humidity_percent'] ?? 0}%",
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Icon(Icons.water_drop, size: 16, color: Colors.blue),
                            const SizedBox(width: 4),
                            Text("Leaf Wetness Risk: "),
                            Text(
                              getRiskLevel(weatherSummary['leaf_wetness_risk'] ?? 'unknown'),
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        if (weatherSummary['notes'] != null && weatherSummary['notes'].isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            "Weather Notes: ${weatherSummary['notes']}",
                            style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Evidence & Reasoning
        if (explainability.isNotEmpty) ...[
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.psychology, color: Colors.purple),
                      const SizedBox(width: 8),
                      Text("Why This Diagnosis?", 
                           style: Theme.of(context).textTheme.titleMedium?.copyWith(
                             fontWeight: FontWeight.bold,
                           )),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...explainability.map((e) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.purple[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border(left: BorderSide(width: 4, color: Colors.purple)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.check_circle, size: 16, color: Colors.purple),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  e['feature'] ?? '',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            e['how_it_influenced_decision'] ?? '',
                            style: TextStyle(color: Colors.grey[700]),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Differential Diagnoses
        if (differentials.isNotEmpty) ...[
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.compare_arrows, color: Colors.indigo),
                      const SizedBox(width: 8),
                      Text("Other Possible Diseases", 
                           style: Theme.of(context).textTheme.titleMedium?.copyWith(
                             fontWeight: FontWeight.bold,
                           )),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...differentials.take(3).map((d) {
                    final likelihood = ((d['likelihood'] ?? 0.0) * 100).toStringAsFixed(1);
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(vertical: 4),
                      leading: CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.indigo[100],
                        child: Text(
                          "$likelihood%",
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.indigo[700],
                          ),
                        ),
                      ),
                      title: Text(d['name'] ?? "Unknown"),
                      subtitle: Text(d['rationale'] ?? ''),
                    );
                  }),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Action Plan
        if (actions.isNotEmpty) ...[
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.task_alt, color: Colors.red),
                      const SizedBox(width: 8),
                      Text("Immediate Action Plan", 
                           style: Theme.of(context).textTheme.titleMedium?.copyWith(
                             fontWeight: FontWeight.bold,
                           )),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...actions.map((a) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: getUrgencyColor(a['urgency'] ?? 'low'),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(getActionIcon(a['type'] ?? ''), size: 20),
                        ),
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(a['name'] ?? '', maxLines: 2, overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 4),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: a['urgency'] == 'high'
                                      ? Colors.red
                                      : a['urgency'] == 'medium'
                                          ? Colors.orange
                                          : Colors.green,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  (a['urgency'] ?? 'N/A').toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(a['instruction'] ?? ''),
                            if (a['justification'] != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                "Why: ${a['justification']}",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontStyle: FontStyle.italic,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(Icons.trending_up, size: 14, color: Colors.grey[600]),
                                const SizedBox(width: 4),
                                Text(
                                  "Effectiveness: ${((a['estimated_effectiveness'] ?? 0.0) * 100).toStringAsFixed(0)}%",
                                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Confirmatory Tests
        if (confirmTests.isNotEmpty) ...[
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.biotech, color: Colors.teal),
                      const SizedBox(width: 8),
                      Text("Recommended Tests", 
                           style: Theme.of(context).textTheme.titleMedium?.copyWith(
                             fontWeight: FontWeight.bold,
                           )),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...confirmTests.map((test) {
                    return Card(
                      color: Colors.teal[50],
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.teal,
                          child: Text(
                            "${test['estimated_wait_days'] ?? 0}d",
                            style: const TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ),
                        title: Text(
                          test['test'] ?? '',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          test['reason'] ?? '',
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Field History Context
        if (fieldHistory.isNotEmpty && 
            (fieldHistory['previous_crops']?.isNotEmpty == true ||
             fieldHistory['recent_pesticides_fertilizers']?.isNotEmpty == true ||
             fieldHistory['notes']?.isNotEmpty == true)) ...[
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.history, color: Colors.brown),
                      const SizedBox(width: 8),
                      Text("Field History Context", 
                           style: Theme.of(context).textTheme.titleMedium?.copyWith(
                             fontWeight: FontWeight.bold,
                           )),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (fieldHistory['previous_crops']?.isNotEmpty == true) ...[
                    _buildHistoryItem("Previous Crops", fieldHistory['previous_crops'].join(', ')),
                  ],
                  if (fieldHistory['recent_pesticides_fertilizers']?.isNotEmpty == true) ...[
                    _buildHistoryItem("Recent Treatments", fieldHistory['recent_pesticides_fertilizers'].join(', ')),
                  ],
                  if (fieldHistory['planting_date'] != null) ...[
                    _buildHistoryItem("Planting Date", fieldHistory['planting_date']),
                  ],
                  if (fieldHistory['observed_symptom_start_date'] != null) ...[
                    _buildHistoryItem("Symptoms First Observed", fieldHistory['observed_symptom_start_date']),
                  ],
                  if (fieldHistory['notes']?.isNotEmpty == true) ...[
                    _buildHistoryItem("Additional Notes", fieldHistory['notes']),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Scientific References
        if (references.isNotEmpty) ...[
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.library_books, color: Colors.deepPurple),
                      const SizedBox(width: 8),
                      Text("Scientific References", 
                           style: Theme.of(context).textTheme.titleMedium?.copyWith(
                             fontWeight: FontWeight.bold,
                           )),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...references.map((ref) {
                    return ListTile(
                      leading: const Icon(Icons.article, color: Colors.deepPurple),
                      title: Text(ref['source'] ?? ''),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (ref['section_or_clause'] != null)
                            Text("Section: ${ref['section_or_clause']}"),
                          if (ref['note'] != null)
                            Text(ref['note'], style: const TextStyle(fontStyle: FontStyle.italic)),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Additional Notes
        if (notes.isNotEmpty) ...[
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 4,
            color: Colors.amber[50],
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.sticky_note_2, color: Colors.amber),
                      const SizedBox(width: 8),
                      Text("Important Notes", 
                           style: Theme.of(context).textTheme.titleMedium?.copyWith(
                             fontWeight: FontWeight.bold,
                           )),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(notes),
                ],
              ),
            ),
          ),
        ],

        const SizedBox(height: 20),

        // Footer disclaimer
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(Icons.info_outline, color: Colors.grey),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  "This analysis is based on available data and should be used as a guide. Always consult with local agricultural experts for critical decisions.",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

  Widget _buildWeatherStat(String emoji, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 20)),
        const SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 10, color: Colors.grey),
        ),
        Text(
          value,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ],
      ),
    );
  }

  Widget _buildHistoryItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 105,
            child: Text(
              "$label:",
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

}
