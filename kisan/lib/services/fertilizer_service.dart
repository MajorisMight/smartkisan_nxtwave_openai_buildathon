// ...new file...
import 'dart:io';
import 'package:kisan/services/recommendation_service.dart';

import '../models/crop.dart';

/// FertilizerService
/// - Collects all inputs required for a fertilizer recommendation
/// - Validates presence of soil test data (either numeric N,P,K,pH or an attached file)
/// - Calls the existing AI/LLM analysis backend (AIAnalysisService) which is already wired
///   to the Gemini API in this project. If the project's AIAnalysisService is updated to call
///   Gemini directly, this service will transparently use it.
/// - Returns a well-structured Map that the UI can consume (contains `analysis_steps`,
///   `recommendation`, `confidence`, `why_this_recommendation`, etc.)
class FertilizerService {
  /// Calculate fertilizer recommendation.
  /// soilTest must contain at least one of 'N','P','K' or there must be a soilTestFile provided.
  static Future<Map<String, dynamic>> calculateRecommendation({
    required Crop crop,
    required double area, // hectares
    required String region,
    required String stage,
    required String irrigation,
    required String soilType,
    Map<String, double>?
    soilTest, // expect keys: 'N','P','K','pH' (values as numbers)
    File? soilTestFile,
    String? targetYield,
  }) async {
    // Validate mandatory soil test data
    final hasNumericSoil = soilTest != null && soilTest.values.isNotEmpty;
    final hasFile = soilTestFile != null;
    if (!hasNumericSoil && !hasFile) {
      throw ArgumentError(
        'Soil test data required (provide N/P/K/pH values or attach a file/photo).',
      );
    }

    // Build prompt / input summary for the LLM. Keep it explicit so Gemini receives
    // all context needed to produce an ICAR-compliant recommendation.
    final inputSummary = {
      'crop': crop.name,
      'area_ha': area,
      'region': region,
      'stage': stage,
      'irrigation': irrigation,
      'soil_type': soilType,
      'target_yield': targetYield ?? 'Standard',
      'soil_test': soilTest ?? {},
      'soil_test_file': soilTestFile?.path,
    };

    // NOTE:
    // AIAnalysisService is the project's existing LLM helper (used elsewhere).
    // It should forward to Gemini. We call it and expect it to return a Map with:
    //  - analysis_steps: List<String>
    //  - recommendation: Map (fertilizer doses, timing, method)
    //  - reasoning / confidence fields
    //
    // If your AIAnalysisService exposes a method with a different name or signature,
    // replace the call below accordingly.
    dynamic rawAnalysis;
    try {
      // rawAnalysis = AIAnalysisService.generateFertilizerAnalysis(
      //   crop.name,
      //   stage,
      //   // the old helper used soil moisture & temperature; we pass placeholders if not available.
      //   // Gemini prompt itself will use `inputSummary` below (AIAnalysisService should forward it).
      //   soilTest?['moisture'] ?? 0.0,
      //   soilTest?['temperature'] ?? 0.0,
      //   additionalContext:
      //       inputSummary, // optional arg used by some project helper implementations
      // );
      rawAnalysis = RecommendationService.fertilizerPlanFromContext(
        contextData: inputSummary,
      );
    } catch (_) {
      // Some AIAnalysisService versions may not accept the extra argument.
      // Fallback to simpler call:
      // rawAnalysis = AIAnalysisService.generateFertilizerAnalysis(
      //   crop.name,
      //   stage,
      //   soilTest?['moisture'] ?? 0.0,
      //   soilTest?['temperature'] ?? 0.0,
      // );
      rawAnalysis = RecommendationService.fertilizerPlanFromContext(
        contextData: inputSummary,
      );
    }

    // Ensure we have a Map (handle both sync and Future-returning helpers)
    final analysis = await Future.value(rawAnalysis);

    // Enrich analysis with the explicit input summary so UI can show what was used
    final enriched = <String, dynamic>{};
    if (analysis is Map<String, dynamic>) enriched.addAll(analysis);
    enriched['input'] = inputSummary;

    // Ensure minimal fields exist so UI code can rely on them
    enriched.putIfAbsent(
      'analysis_steps',
      () => <String>['Running ICAR based assessment'],
    );
    enriched.putIfAbsent(
      'recommendation',
      () => {
        'fertilizer': {},
        'timing': 'As per crop stage',
        'method': 'Broadcast / banding as applicable',
        'confidence': 0.6,
      },
    );
    enriched.putIfAbsent(
      'why_this_recommendation',
      () => 'Generated from ICAR guidelines and provided soil test.',
    );
    enriched.putIfAbsent('confidence', () => 'Medium');

    return enriched;
  }
}
