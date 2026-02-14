import 'dart:convert';
import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class GptService {
  GptService._();

  static const String _baseUrl = 'https://api.openai.com/v1/chat/completions';
  static String? _apiKey;

  static Future<void> ensureInitialized() async {
    if (_apiKey != null && _apiKey!.isNotEmpty) return;
    final key = dotenv.env['GPT_API_KEY'];
    if (key == null || key.trim().isEmpty) {
      throw Exception(
        'GPT_API_KEY missing. Add GPT_API_KEY in .env and restart the app.',
      );
    }
    _apiKey = key.trim();
  }

  static Future<Map<String, dynamic>> diagnoseDisease({
    required File imageFile,
    required Map<String, dynamic> ctx,
  }) async {
    await ensureInitialized();
    final imageBytes = await imageFile.readAsBytes();
    final b64 = base64Encode(imageBytes);
    final mimeType = _mimeTypeForPath(imageFile.path);

    final content = await _chatCompletion(
      model:
          dotenv.env['GPT_MODEL_VISION']?.trim().isNotEmpty == true
              ? dotenv.env['GPT_MODEL_VISION']!.trim()
              : 'gpt-4.1-mini',
      messages: [
        {
          'role': 'user',
          'content': [
            {'type': 'text', 'text': _buildDiseasePrompt(ctx)},
            {
              'type': 'image_url',
              'image_url': {'url': 'data:$mimeType;base64,$b64'},
            },
          ],
        },
      ],
      temperature: 0.0,
    );
    return _safeJson(content);
  }

  static Future<Map<String, dynamic>> weatherAdvisories({
    required Map<String, dynamic> contextData,
  }) async {
    await ensureInitialized();
    final content = await _chatCompletion(
      model:
          dotenv.env['GPT_MODEL_TEXT']?.trim().isNotEmpty == true
              ? dotenv.env['GPT_MODEL_TEXT']!.trim()
              : 'gpt-4.1-mini',
      messages: [
        {'role': 'user', 'content': _buildWeatherAdvisoryPrompt(contextData)},
      ],
      temperature: 0.1,
    );
    return _safeJson(content);
  }

  static Future<Map<String, dynamic>> extractSoilTestFromImage({
    required File imageFile,
  }) async {
    await ensureInitialized();
    final imageBytes = await imageFile.readAsBytes();
    final b64 = base64Encode(imageBytes);
    final mimeType = _mimeTypeForPath(imageFile.path);

    final content = await _chatCompletion(
      model:
          dotenv.env['GPT_MODEL_VISION']?.trim().isNotEmpty == true
              ? dotenv.env['GPT_MODEL_VISION']!.trim()
              : 'gpt-4.1-mini',
      messages: [
        {
          'role': 'user',
          'content': [
            {'type': 'text', 'text': _buildSoilTestImagePrompt()},
            {
              'type': 'image_url',
              'image_url': {'url': 'data:$mimeType;base64,$b64'},
            },
          ],
        },
      ],
      temperature: 0.0,
    );
    return _safeJson(content);
  }

  static Future<Map<String, dynamic>> fertilizerPlan({
    required Map<String, dynamic> contextData,
  }) async {
    await ensureInitialized();
    final content = await _chatCompletion(
      model:
          dotenv.env['GPT_MODEL_TEXT']?.trim().isNotEmpty == true
              ? dotenv.env['GPT_MODEL_TEXT']!.trim()
              : 'gpt-4.1-mini',
      messages: [
        {'role': 'user', 'content': _buildFertilizerPrompt(contextData)},
      ],
      temperature: 0.1,
    );
    return _safeJson(content);
  }

  static Future<Map<String, dynamic>> cropSuggestions({
    required Map<String, dynamic> contextData,
  }) async {
    await ensureInitialized();
    final content = await _chatCompletion(
      model:
          dotenv.env['GPT_MODEL_TEXT']?.trim().isNotEmpty == true
              ? dotenv.env['GPT_MODEL_TEXT']!.trim()
              : 'gpt-4.1-mini',
      messages: [
        {'role': 'user', 'content': _buildCropSuggestionPrompt(contextData)},
      ],
      temperature: 0.1,
    );
    return _safeJson(content);
  }

  static Future<List<Map<String, dynamic>>> applicableSchemes({
    required Map<String, dynamic> profile,
  }) async {
    await ensureInitialized();
    final prompt = _buildSchemesPrompt(profile);
    print('[GptService] Schemes prompt: $prompt');
    final content = await _chatCompletion(
      model:
          dotenv.env['GPT_MODEL_TEXT']?.trim().isNotEmpty == true
              ? dotenv.env['GPT_MODEL_TEXT']!.trim()
              : 'gpt-4.1-mini',
      messages: [
        {'role': 'user', 'content': prompt},
      ],
      temperature: 0.1,
      responseFormatJsonObject: false,
    );
    print('[GptService] Schemes raw response: $content');

    final parsed = _safeJsonDynamic(content);
    final extracted = _extractSchemeList(parsed);
    print('[GptService] Schemes parsed list count: ${extracted.length}');
    return extracted;
  }

  static Future<String> _chatCompletion({
    required String model,
    required List<Map<String, dynamic>> messages,
    required double temperature,
    bool responseFormatJsonObject = true,
  }) async {
    final body = <String, dynamic>{
      'model': model,
      'messages': messages,
      'temperature': temperature,
    };
    if (responseFormatJsonObject) {
      body['response_format'] = {'type': 'json_object'};
    }

    final res = await http.post(
      Uri.parse(_baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_apiKey',
      },
      body: jsonEncode(body),
    );

    final decoded = _safeJsonDynamic(res.body);
    if (res.statusCode < 200 || res.statusCode >= 300) {
      final message =
          decoded is Map<String, dynamic>
              ? (decoded['error']?['message']?.toString() ??
                  decoded['message']?.toString() ??
                  'Unknown error')
              : 'Unknown error';
      throw Exception('OpenAI API error ${res.statusCode}: $message');
    }

    if (decoded is! Map<String, dynamic>) {
      throw Exception('OpenAI API returned invalid response');
    }

    final choices = decoded['choices'];
    if (choices is List && choices.isNotEmpty) {
      final content = choices.first['message']?['content']?.toString();
      if (content != null && content.trim().isNotEmpty) return content;
    }
    throw Exception('OpenAI API returned empty content');
  }

  static String _mimeTypeForPath(String path) {
    final lower = path.toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.webp')) return 'image/webp';
    return 'image/jpeg';
  }

  static String _buildDiseasePrompt(Map<String, dynamic> ctx) {
    return '''
You are an agricultural plant pathologist and agronomist.
Analyze the image + context and output ONLY valid JSON object with this schema:
{
  "result_status": "IDENTIFIED"|"DID_NOT_IDENTIFY"|"IRRELEVANT",
  "user_message": string,
  "disease_name": string,
  "confidence": number,
  "probability_distribution": [{"name": string, "probability": number, "evidence_rationale": string}],
  "differentials": [{"name": string, "rationale": string, "likelihood": number}],
  "recommended_actions": [{"type": "organic"|"chemical"|"cultural"|"diagnostic", "name": string, "instruction": string, "urgency": "low"|"medium"|"high", "justification": string, "estimated_effectiveness": number}],
  "weather_summary": {"period_days": integer, "total_rainfall_mm": number, "avg_temperature_c": number, "avg_humidity_percent": number, "leaf_wetness_risk": "low"|"medium"|"high", "notes": string},
  "field_history_considerations": {"previous_crops": [string], "recent_pesticides_fertilizers": [string], "irrigation_history": string, "planting_date": string, "crop_stage": string, "observed_symptom_start_date": string, "notes": string},
  "geo_location": {"country": string, "state": string, "district": string, "latitude": number|null, "longitude": number|null, "soil_type": string|null},
  "evidence_explainability": [{"feature": string, "how_it_influenced_decision": string}],
  "recommended_confirmatory_tests": [{"test": string, "reason": string, "estimated_wait_days": integer}],
  "references": [{"source": string, "section_or_clause": string, "note": string}],
  "notes": string
}
Status rules:
- "IDENTIFIED": crop image is clear and disease diagnosis is reliable.
- "DID_NOT_IDENTIFY": crop image present but quality/clarity/angle is not enough to diagnose confidently.
- "IRRELEVANT": image is unrelated to crop disease diagnosis.
- If not IDENTIFIED, set disease_name to "Unknown", confidence <= 0.3, and provide a short retry hint in user_message.
Context JSON:
$ctx
''';
  }

  static String _buildFertilizerPrompt(Map<String, dynamic> ctx) {
    return '''
You are an agronomist assistant. Return ONLY valid JSON object.
Required keys:
{
  "analysis_steps": [{"step": number, "title": string, "description": string}],
  "target_crop": string,
  "stage": string,
  "area_ha": number,
  "fertilizer_items": [{"name": string, "quantity": string, "quantity_kg_per_ha": number, "quantity_total_kg": number, "note": string}],
  "split_schedule": [{"product": string, "total": string, "total_kg": number, "when": string, "amount": string, "amount_kg": number, "notes": string}],
  "why_this_recommendation": string,
  "caution": string,
  "confidence": "High"|"Medium"|"Low",
  "basis": string
}
Context JSON:
$ctx
''';
  }

  static String _buildSchemesPrompt(Map<String, dynamic> profile) {
    return '''
You are an Indian agriculture schemes assistant.
Return strict JSON ARRAY of objects:
{"title": string, "category": "subsidy"|"insurance"|"loan"|"training", "state": string, "description": string, "eligibilityTags": [string], "steps": [string]}
Profile:
$profile
''';
  }

  static String _buildWeatherAdvisoryPrompt(Map<String, dynamic> ctx) {
    return '''
You are a weather + farm operations advisor.
Use the provided weather forecast and return ONLY valid JSON.

JSON schema (strict):
{
  "summary": string,
  "advisories": [
    {
      "headline": string,
      "advice": string,
      "reason": string,
      "priority": "low" | "medium" | "high",
      "category": "weather" | "irrigation" | "planting" | "spraying" | "pest" | "harvest",
      "time_horizon": "today" | "1-3d" | "4-7d" | "8-16d"
    }
  ]
}

Rules:
- Give 3 to 6 advisories.
- Keep each "advice" concise and action-oriented.
- Prioritize practical field decisions (irrigation, sowing, spraying, harvest timing).
- No markdown, no explanation outside JSON.

Context JSON:
$ctx
''';
  }

  static String _buildCropSuggestionPrompt(Map<String, dynamic> ctx) {
    return '''
You are an agronomy planner for Indian farms.
Return ONLY valid JSON in this exact schema:
{
  "generated_at": "ISO-8601 string",
  "overall_summary": "string",
  "suggestions": [
    {
      "rank": number,
      "crop_name": "string",
      "growth_duration_days": number,
      "irrigation_requirements": "string",
      "estimated_yield": number,
      "estimated_yield_unit": "string",
      "estimated_cost": number,
      "estimated_revenue": number,
      "currency": "INR",
      "overall_summary": "string",
      "confidence": "High|Medium|Low"
    }
  ]
}
Rules:
- Provide at least 4 suggestions.
- Rank by highest estimated_revenue first; if tie, higher estimated_yield first.
- Use land area and location context for numbers.
- If marketplace data is unavailable, use regional averages and mark confidence accordingly.
- Keep output concise and actionable.

INPUT_CONTEXT:
$ctx
''';
  }

  static List<Map<String, dynamic>> _extractSchemeList(dynamic parsed) {
    if (parsed is List) {
      return parsed
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }
    if (parsed is Map<String, dynamic>) {
      final candidates = [
        parsed['schemes'],
        parsed['data'],
        parsed['items'],
        parsed['results'],
      ];
      for (final c in candidates) {
        if (c is List) {
          return c
              .whereType<Map>()
              .map((e) => Map<String, dynamic>.from(e))
              .toList();
        }
      }
    }
    return const [];
  }

  static String _buildSoilTestImagePrompt() {
    return '''
You are reading a soil test report image.
Return ONLY valid JSON object with this exact schema:
{
  "values": {
    "N": number|null,
    "P": number|null,
    "K": number|null,
    "pH": number|null,
    "OrganicMatter": number|null,
    "Ca": number|null,
    "Mg": number|null,
    "S": number|null,
    "B": number|null,
    "Cl": number|null,
    "Cu": number|null,
    "Fe": number|null,
    "Mn": number|null,
    "Mo": number|null,
    "Zn": number|null,
    "CEC": number|null
  },
  "notes": string
}
Rules:
- Extract only visible numeric values.
- Use null when unavailable.
- No extra text outside JSON.
''';
  }

  static Map<String, dynamic> _safeJson(String text) {
    try {
      final dynamic parsed =
          text.trim().startsWith('{') || text.trim().startsWith('[')
              ? jsonDecode(text)
              : jsonDecode(_extractJson(text));
      if (parsed is Map<String, dynamic>) return parsed;
      return {'data': parsed};
    } catch (_) {
      return {};
    }
  }

  static dynamic _safeJsonDynamic(String text) {
    try {
      final trimmed = text.trim();
      final dynamic parsed =
          trimmed.startsWith('{') || trimmed.startsWith('[')
              ? jsonDecode(text)
              : jsonDecode(_extractJson(text));
      return parsed;
    } catch (_) {
      return null;
    }
  }

  static String _extractJson(String s) {
    final start = s.indexOf('{');
    final end = s.lastIndexOf('}');
    if (start >= 0 && end > start) return s.substring(start, end + 1);
    final sb = s.indexOf('[');
    final eb = s.lastIndexOf(']');
    if (sb >= 0 && eb > sb) return s.substring(sb, eb + 1);
    return '{}';
  }
}
