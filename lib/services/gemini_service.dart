import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  GeminiService._();
  static GenerativeModel? _modelText;
  static GenerativeModel? _modelDisease;

  static Future<void> ensureInitialized() async {
    if (_modelText != null && _modelDisease != null) return;
    final apiKey = dotenv.env['GEMINI_API_KEY'];
    if (apiKey == null || apiKey.trim().isEmpty) {
      if (kDebugMode) {
        print('[GeminiService] Missing GEMINI_API_KEY');
      }
      throw Exception(
        'GEMINI_API_KEY missing. Add GEMINI_API_KEY in .env and restart the app.',
      );
    }
    _modelText = GenerativeModel(model: 'gemini-2.5-flash', apiKey: apiKey);
    _modelDisease = GenerativeModel(model: 'gemini-2.5-flash', apiKey: apiKey);
  }

  static Future<Map<String, dynamic>> diagnoseDisease({
    required File imageFile,
    required Map<String, dynamic> ctx,
  }) async {
    await ensureInitialized();
    if (_modelDisease == null) throw Exception('Gemini not initialized');

    final prompt = _buildDiseasePrompt(ctx);
    print("Prompt for disease diagnosis: $prompt");
    final imageBytes = await imageFile.readAsBytes();
    final content = [
      Content.multi([TextPart(prompt), DataPart('image/jpeg', imageBytes)]),
    ];
    final resp = await _modelDisease!.generateContent(
      content,
      generationConfig: GenerationConfig(responseMimeType: 'application/json'),
    );
    final text = resp.text ?? '{}';
    print("Raw response from Gemini: $text");
    return _safeJson(text);
  }

  static Future<Map<String, dynamic>> extractSoilTestFromImage({
    required File imageFile,
  }) async {
    await ensureInitialized();
    if (_modelDisease == null) throw Exception('Gemini not initialized');

    final imageBytes = await imageFile.readAsBytes();
    final content = [
      Content.multi([
        TextPart(_buildSoilTestImagePrompt()),
        DataPart('image/jpeg', imageBytes),
      ]),
    ];

    final resp = await _modelDisease!.generateContent(
      content,
      generationConfig: GenerationConfig(responseMimeType: 'application/json'),
    );
    final text = resp.text ?? '{}';
    return _safeJson(text);
  }

  static Future<Map<String, dynamic>> fertilizerPlan({
    required Map<String, dynamic> contextData,
  }) async {
    await ensureInitialized();
    // print("Fertilizer Plan Context: $contextData");
    if (_modelText == null) throw Exception('Gemini not initialized');
    // final prompt = _buildFertilizerPrompt(contextData);
    final prompt = _newbuildFertilizerPrompt(contextData);
    print("Prompt for fertilizer recommendation: $prompt");
    final resp = await _modelText!.generateContent(
      [Content.text(prompt)],
      generationConfig: GenerationConfig(
        responseMimeType: 'application/json',
        temperature: 0.0,
        topP: 1.0,
      ),
    );
    final text = resp.text ?? '{}';
    print(text);
    return _safeJson(text);
  }

  static Future<Map<String, dynamic>> cropSuggestions({
    required Map<String, dynamic> contextData,
  }) async {
    await ensureInitialized();
    if (_modelText == null) throw Exception('Gemini not initialized');
    final resp = await _modelText!.generateContent(
      [Content.text(_buildCropSuggestionPrompt(contextData))],
      generationConfig: GenerationConfig(
        responseMimeType: 'application/json',
        temperature: 0.1,
      ),
    );
    final text = resp.text ?? '{}';
    return _safeJson(text);
  }

  static Future<List<Map<String, dynamic>>> applicableSchemes({
    required Map<String, dynamic> profile,
  }) async {
    await ensureInitialized();
    if (_modelText == null) throw Exception('Gemini not initialized');
    final prompt = _buildSchemesPrompt(profile);
    print('[GeminiService] Schemes prompt: $prompt');
    final resp = await _modelText!.generateContent(
      [Content.text(prompt)],
      generationConfig: GenerationConfig(responseMimeType: 'application/json'),
    );
    final text = resp.text ?? '[]';
    print('[GeminiService] Schemes raw response: $text');
    final parsed = _safeJsonDynamic(text);
    if (parsed is List) {
      print('[GeminiService] Schemes parsed list count: ${parsed.length}');
      return parsed
          .map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e as Map))
          .toList();
    }
    print(
      '[GeminiService] Schemes parse returned non-list: ${parsed.runtimeType}',
    );
    return const [];
  }

  static String _buildDiseasePrompt(Map<String, dynamic> ctx) {
    //TODO: refine prompt after all the features and inputs are live.
    return '''
You are an agricultural plant pathologist and agronomist. Analyze the attached crop image and the provided context (which includes field history). Use all available signals — the image, field history, recent weather for that location, crop species & crop growth stage based on estimation for that crop during current month, geolocation/soil information, ICAR guidelines, and Government of India / Ministry of Agriculture guidelines — to predict disease probabilities and recommend actions.

Return **ONLY** valid JSON (no surrounding text) and follow this strict schema. Ensure numeric probabilities are in [0,1] and the probability_distribution values sum to (approximately) 1.0. Treat **confidence** as the model's estimated probability (0..1) that the top predicted disease is correct.

Required top-level keys and types:
{
  "result_status": "IDENTIFIED" | "DID_NOT_IDENTIFY" | "IRRELEVANT",
  "user_message": string,                          // short message shown directly in app UI
  "disease_name": string,                          // primary predicted disease
  "confidence": number,                            // probability 0..1 for disease_name (primary)
  "probability_distribution": [                    // ranked list of candidate diseases
    {"name": string, "probability": number, "evidence_rationale": string}
  ],
  "differentials": [                                // other plausible diagnoses
    {"name": string, "rationale": string, "likelihood": number}
  ],
  "recommended_actions": [                          // actionable steps sorted by urgency
    {
      "type": "organic" | "chemical" | "cultural" | "diagnostic",
      "name": string,
      "instruction": string,
      "urgency": "low" | "medium" | "high",
      "justification": string,                      // cite guideline name/section if applicable
      "estimated_effectiveness": number             // 0..1
    }
  ],
  "weather_summary": {                               // summary of recent weather risk factors
    "period_days": integer,                          // e.g., 14
    "total_rainfall_mm": number,
    "avg_temperature_c": number,
    "avg_humidity_percent": number,
    "leaf_wetness_risk": "low" | "medium" | "high",
    "notes": string
  },
  "field_history_considerations": {                  // key items drawn from history
    "previous_crops": [string],
    "recent_pesticides_fertilizers": [string],
    "irrigation_history": string,
    "planting_date": string,
    "crop_stage": string,
    "observed_symptom_start_date": string,
    "notes": string
  },
  "geo_location": {                                  // use whatever is available in context
    "country": string,
    "state": string,
    "district": string,
    "latitude": number | null,
    "longitude": number | null,
    "soil_type": string | null
  },
  "evidence_explainability": [                       // short, human-readable feature-level reasons
    {"feature": string, "how_it_influenced_decision": string}
  ],
  "recommended_confirmatory_tests": [                // lab/field tests to reduce uncertainty
    {"test": string, "reason": string, "estimated_wait_days": integer}
  ],
  "references": [                                    // guideline references consulted (ICAR / Ministry etc.)
    {"source": string, "section_or_clause": string, "note": string}
  ],
  "notes": string                                    // any extra caveats, data gaps, or important context
}

Status rules:
- Use "IDENTIFIED" only when the image clearly shows a crop and you can provide a meaningful disease diagnosis.
- Use "DID_NOT_IDENTIFY" when image appears to be a crop image but quality/angle/occlusion prevents reliable diagnosis.
- Use "IRRELEVANT" when image is unrelated to crop/plant disease diagnosis.
- If status is not "IDENTIFIED", keep disease_name as "Unknown", set low confidence (<=0.3), and provide a clear retry reason in user_message.

Context JSON:
$ctx

''';
  }

  static String _newbuildFertilizerPrompt(Map<String, dynamic> ctx) {
    return '''
             SYSTEM: You are **AgriAssist**, a conservative agronomist assistant built to produce strict, mobile-friendly, ICAR- and Ministry-of-Agriculture-aligned fertilizer guidance plus evidence-based yield and economic impact estimates. **Output ONLY valid JSON** (no surrounding text) that exactly follows the SCHEMA and RULES below. Use metric units (kg, ha, t/ha) and local currency for income (e.g., "INR"). Round numeric values to at most one decimal. Do NOT invent product brand names — only use generic fertilizer types (examples: `"Urea"`, `"DAP"`, `"MOP"`, `"ZN(SO4)"`, `"Gypsum"`, `"SSP"`, `"Borax"`). Keep short text fields concise and mobile-friendly (UI max implied).

NEW OUTPUT REQUIREMENT:

* In addition to fertilizer recommendations, **estimate the expected yield improvement** if the farmer follows the recommendation (report both % change and absolute change in t/ha) **rooted in ICAR / Ministry of Agriculture research results** (cite the research source short label in `price_basis`/`basis`).
* Estimate the **additional income** from the increased yield using **past year's average price for the crop in that location**. If a local past-year price is not provided in input, use the nearest reliable market average for that district/state and mark confidence appropriately.

Before producing numbers, analyze **all** input context fields (soil test results including N/P/K/pH in ppm, location, crop name, crop stage, past pest history, past fertilizer history, area, and any provided local price). If any key parameter is missing (especially lab soil test N/P/K/pH or past-year price), mark `"confidence":"Low"` and **use regional defaults appropriate to the provided location**; state this clearly in `basis`. Always follow ICAR recommendations and Ministry of Agriculture guidance when selecting rates, splits, and methods. If past fertilizer/pest history implies recent high N/P/K application or a recent foliar spray interaction, adjust current-stage recommendations accordingly and state the adjustment briefly in `why_this_recommendation` or `caution`. **Never** recommend fertilizers that are inappropriate for the CURRENT stage; do not backfill missed earlier stage doses.

SCHEMA (must match exactly) — **NEW FIELDS ADDED**:
{
"target_crop": "string",
"stage": "string",
"area_ha": number,
"fertilizer_items": [
{
"name": "string",                        // generic fertilizer short name, e.g., "DAP"
"quantity": "string",                    // display string for UI, e.g., "104 kg"
"quantity_kg_per_ha": number,            // numeric per-ha value (kg/ha)
"quantity_total_kg": number,             // numeric total for field (kg)
"note": "string"                         // short note for UI — MUST include (a) brief purpose (why), (b) a one-line purchasing checklist (what to check on the sack/label), and (c) one-line safety/application hint if space allows. Keep under ~80 chars.
}
],
"split_schedule": [
{
"product": "string",                     // same short name as in fertilizer_items
"total": "string",                       // display total e.g., "104 kg"
"total_kg": number,                      // numeric total
"when": "string",                        // timing label e.g., "Now", "30 DAS" — must start at current stage
"amount": "string",                      // display amount e.g., "52 kg"
"amount_kg": number,                     // numeric amount
"notes": "string"                        // short method & application instructions: method (broadcast/side-dress/foliar), depth/incorporation, water-in, PPE, and any compatibility notes — concise
}
],
"why_this_recommendation": "string",        // one concise paragraph: reference soil test or defaults, mention key deficits/excesses, mention relevant ICAR/MinAg rationale, and adjustments for past history/pests
"caution": "string",                        // concise safety, environmental cautions, and any conflicts with past treatments (e.g., recent pesticide spray), or note on over-application risk
"confidence": "High|Medium|Low",
"basis": "string",

// NEW FIELDS — YIELD & ECONOMICS (must be present)
"expected_yield_increase_percent": number,      // percent increase vs baseline yield (e.g., 8.5)
"expected_yield_increase_t_ha": number,         // absolute increase (t/ha)
"estimated_additional_income_currency": "string", // local currency code or name, e.g., "INR"
"estimated_additional_income_per_ha": number,   // currency per ha (rounded 1 decimal)
"estimated_additional_income_total": number,    // currency for area_ha * per_ha (rounded 1 decimal)
"price_basis": "string"                         // short note about price data used, e.g., "Local mandi avg 2024 + state agmarknet"
}

MANDATORY RULES (read carefully — violations will be treated as errors):

* ONLY recommend fertilizers appropriate for the CURRENT stage in the input context. Do NOT include actions from past stages.
* `split_schedule` must start from the current stage forward. If a previous stage dose was missed, DO NOT backfill it.
* Use only the allowed generic fertilizer names. Do not invent brands or trade names.
* For **each** fertilizer in `fertilizer_items[].note` include:

  1. **Why** (1–6 words) — the agronomic purpose;
  2. **Buy-check** (short): what to check when purchasing (e.g., "label N:P:K, manufacturing date, % purity, lumps, moisture");
  3. **Quick apply hint** (short): method or safety (e.g., "side-dress, incorporate, water-in; wear gloves").
     Keep this full `note` concise (mobile-friendly).
* For **each** entry in `split_schedule[].notes`, include concise application instructions: method (broadcast/side-dress/foliar/soil-incorporate), recommended equipment or action (e.g., hand-broadcast, fertilizer drill, band placement), irrigation/water-in guidance, and any immediate compatibility warnings with pesticides/fungicides.
* If soil_test is present in context, use the provided N/P/K/pH values to compute recommended doses following ICAR tables and Ministry guidelines; include those facts in `why_this_recommendation` and `"basis"` (e.g., `"Lab soil test + ICAR tables"`). If soil_test is missing or incomplete, set `"confidence":"Low"`, use regional defaults derived from `location`, and state that in `basis` (e.g., `"Regional defaults + ICAR/MinAg guidelines"`).
* Yield improvement estimates MUST be **rooted in ICAR / Ministry of Agriculture research or extension publications**. Do NOT output a random or invented percent. If multiple official experiments exist, use the conservative central estimate (median or lower-quartile) and state that in `basis` or `price_basis`. If no direct official study exists for the exact crop-stage-treatment in that agro-ecological zone, state that clearly, lower `confidence`, and provide a conservative modelled estimate with the phrase `"(inferred — no direct ICAR trial)"` in `basis`.
* Report yield change both as percent and absolute t/ha. Use the region's typical baseline yield (ICAR/state averages) as the denominator; state that baseline source in `basis`.
* Economic calculation rules: use **past year's average market price for the crop in the provided location** (local mandi/market price). Compute additional income = (expected_yield_increase_t_ha × price_per_t) per ha, then scale by `area_ha` for total. Put currency in `estimated_additional_income_currency`. Include the `price_basis` field describing the price source and year (e.g., `"Mandi avg 2024, [market], Source: Agmarknet"`). If price is missing in context, use nearest reliable market average and set `"confidence":"Low"` and explain in `basis`.
* If past fertilizer history shows recent heavy application of a nutrient, **reduce or omit** that nutrient now, and explain the reason briefly. If past pest control history creates interaction risks (e.g., recent foliar urea with pesticide), flag in `caution`.
* Keep all short text fields concise and UI-friendly. Numeric fields must be present and consistent with display strings. Round numeric values to at most one decimal. Display strings must match numeric values (e.g., `"104 kg"` vs `104.0`).
* If suggesting micronutrients (e.g., Zn, B), only do so when soil test or crop deficiency signs/past history support it; state the supporting reason. Use allowed names like `"ZN(SO4)"`, `"Borax"`, etc.
* The `basis` field must always state the source(s) of decision: either `"Lab soil test + ICAR tables"` or `"Regional defaults + ICAR/MinAg guidelines"`, and must append yield and price sources when used (examples: `"+ ICAR research (Year/short-ref)", "+ Agmarknet mandi avg 2024"` or `"+ inferred (no direct ICAR trial)"`, and may append `"+ past fert history"` if relevant).
* Do NOT invent research citations. If specific ICAR/minAg study identifiers are available in the input context, use them; otherwise select the most directly relevant ICAR/MinAg guidance and state the short label (e.g., `"ICAR bulletin 2019 — nutrient response trials"`). If no direct trial exists, state the limitation and lower `confidence`.
* Short warnings about local language or unit confusion are allowed but keep concise.

FEW-SHOT EXAMPLES (retain these styles — ensure new outputs follow same compact structure; include purchase-check and application hints in note & split_schedule.notes):

EXAMPLE 1 (soil test present, irrigated groundnut, flowering — High confidence):
{ ...same JSON as original example 1..., plus these new fields as numeric estimates consistent with ICAR trial results and local price info. }

EXAMPLE 2 (no soil test provided — use regional defaults — Low confidence):
{ ...same JSON as original example 2..., plus new yield & income fields set conservatively and confidence Low. }

INPUT CONTEXT:
$ctx

Produce JSON now.

  ''';
  }

  //old prompt for fertilizer recommendation
  static String _buildFertilizerPrompt(Map<String, dynamic> ctx) {
    return '''
SYSTEM: You are AgriAssist, a conservative agronomist assistant. Output ONLY valid JSON (no surrounding text) that exactly follows the SCHEMA and RULES below. Use metric units (kg, ha). If soil test is missing, mark "confidence":"Low" and use regional defaults. Do NOT invent product brand names — only use generic fertilizer types: "Urea","DAP","MOP","ZN(SO4)","Gypsum", etc. Keep all short text fields mobile-friendly (max lengths implied in UI). Round numeric values to at most one decimal.

SCHEMA (must match exactly):
{
  "target_crop": "string",
  "stage": "string",
  "area_ha": number,
  "fertilizer_items": [
    {
      "name": "string",                        // e.g., "DAP"
      "quantity": "string",                    // display string for UI, e.g., "104 kg"
      "quantity_kg_per_ha": number,            // numeric per-ha value (kg/ha)
      "quantity_total_kg": number,             // numeric total for field (kg)
      "note": "string"                         // short note for UI
    }
  ],
  "split_schedule": [
    {
      "product": "string",                     // same short name as in fertilizer_items
      "total": "string",                       // display total e.g., "104 kg"
      "total_kg": number,                      // numeric total
      "when": "string",                        // timing label e.g., "Now", "30 DAS"
      "amount": "string",                      // display amount e.g., "52 kg"
      "amount_kg": number,                     // numeric amount
      "notes": "string"
    }
  ],
  "why_this_recommendation": "string",
  "caution": "string",
  "confidence": "High|Medium|Low",
  "basis": "string"
}

RULES:
- ONLY recommend fertilizers appropriate for the CURRENT stage in the input context.
- Do NOT include actions from past stages (e.g., "At sowing") if the context stage is after sowing.
- Split_schedule must start from the current stage forward.
- If a previous stage dose was missed, DO NOT backfill it.
- Use only the generic fertilizer names allowed. Do not invent brands.
- Provide both display strings and numeric fields (as in SCHEMA).
- If soil_test is present in context, use provided N/P/K/pH values; otherwise state confidence Low and use regional defaults.
- Keep short text fields concise.

FEW-SHOT EXAMPLES:

EXAMPLE 1 (soil test present, irrigated groundnut, flowering — High confidence):
{
  "target_crop":"groundnut",
  "stage":"flowering",
  "area_ha":1.2,
  "fertilizer_items":[
    {
      "name":"DAP",
      "quantity":"104 kg",
      "quantity_kg_per_ha":86.7,
      "quantity_total_kg":104.0,
      "note":"Basal P & N"
    },
    {
      "name":"MOP",
      "quantity":"50 kg",
      "quantity_kg_per_ha":41.7,
      "quantity_total_kg":50.0,
      "note":"Topdress K"
    },
    {
      "name":"Urea",
      "quantity":"11 kg",
      "quantity_kg_per_ha":9.2,
      "quantity_total_kg":11.0,
      "note":"Small N top-up"
    }
  ],
  "split_schedule":[
    {
      "product":"DAP",
      "total":"104 kg",
      "total_kg":104.0,
      "when":"Now (flowering)",
      "amount":"104 kg",
      "amount_kg":104.0,
      "notes":"Apply single basal dose"
    },
    {
      "product":"MOP",
      "total":"50 kg",
      "total_kg":50.0,
      "when":"Now",
      "amount":"50 kg",
      "amount_kg":50.0,
      "notes":"Apply with DAP"
    },
    {
      "product":"Urea",
      "total":"11 kg",
      "total_kg":11.0,
      "when":"Now",
      "amount":"5.5 kg",
      "amount_kg":5.5,
      "notes":"Split into 2, 14d apart"
    },
    {
      "product":"Urea",
      "total":"11 kg",
      "total_kg":11.0,
      "when":"+14 days",
      "amount":"5.5 kg",
      "amount_kg":5.5,
      "notes":"Second split"
    }
  ],
  "why_this_recommendation":"Soil test shows low P; DAP basal to correct P, MOP for K, small urea top-up for N.",
  "caution":"Low risk of over-application; get follow-up soil test next season.",
  "confidence":"High",
  "basis":"Lab soil test + regional ICAR tables"
}

EXAMPLE 2 (no soil test provided — use regional defaults — Low confidence):
{
  "target_crop":"groundnut",
  "stage":"vegetative",
  "area_ha":0.5,
  "fertilizer_items":[
    {
      "name":"DAP",
      "quantity":"40 kg",
      "quantity_kg_per_ha":80.0,
      "quantity_total_kg":40.0,
      "note":"Basal P"
    },
    {
      "name":"Urea",
      "quantity":"20 kg",
      "quantity_kg_per_ha":40.0,
      "quantity_total_kg":20.0,
      "note":"N top-up"
    }
  ],
  "split_schedule":[
    {
      "product":"DAP",
      "total":"40 kg",
      "total_kg":40.0,
      "when":"Now",
      "amount":"40 kg",
      "amount_kg":40.0,
      "notes":"Apply basal"
    },
    {
      "product":"Urea",
      "total":"20 kg",
      "total_kg":20.0,
      "when":"Now",
      "amount":"10 kg",
      "amount_kg":10.0,
      "notes":"Split 2: 10 kg now, 10 kg 14d"
    },
    {
      "product":"Urea",
      "total":"20 kg",
      "total_kg":20.0,
      "when":"+14 days",
      "amount":"10 kg",
      "amount_kg":10.0,
      "notes":"Second split"
    }
  ],
  "why_this_recommendation":"Regional default for irrigated groundnut at vegetative stage; no soil test available.",
  "caution":"Low confidence due to missing soil test; consider lab test.",
  "confidence":"Low",
  "basis":"Regional defaults + AI"
}

INPUT_CONTEXT:
$ctx

Produce JSON now.
''';
  }

  static String _buildSchemesPrompt(Map<String, dynamic> profile) {
    return '''
You are a govt schemes assistant for Indian agriculture. 
Given the farmer profile (state, district, socialCategory, landholding, crops, insurance/bank), 
list 3-8 applicable central/state schemes. 
Return strict JSON array of objects {title, category: subsidy|insurance|loan|training, state, description, eligibilityTags: string[], steps: string[]}.

Profile JSON:
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
- Use the given land area for yield/cost/revenue estimation.
- Use rainfall normals, season, irrigation availability, risk tolerance, and preferences in reasoning.
- If marketplace data is sparse, still estimate using regional averages and keep confidence conservative.
- Keep responses concise and app-friendly.

INPUT_CONTEXT:
$ctx
''';
  }

  static String _buildSoilTestImagePrompt() {
    return '''
You are reading a soil test report image.
Extract values and return ONLY valid JSON object in this exact schema:
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
- Extract only visible numeric values from the report.
- Use null when not found.
- Do not add text outside JSON.
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

  // For endpoints that may return a top-level List JSON, return dynamic
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
