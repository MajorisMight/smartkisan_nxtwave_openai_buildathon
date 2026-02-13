import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../models/onboarding_profile.dart';
import 'crop_suggestion_results_screen.dart';
import '../services/market_intelligence_service.dart';
import '../services/rainfall_normals_service.dart';
import '../services/recommendation_service.dart';
import '../services/session_service.dart';

class CropSuggestionScreen extends StatefulWidget {
  const CropSuggestionScreen({super.key});

  @override
  State<CropSuggestionScreen> createState() => _CropSuggestionScreenState();
}

class _CropSuggestionScreenState extends State<CropSuggestionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _locationController = TextEditingController();
  final _areaController = TextEditingController();
  final _soilTypeController = TextEditingController();

  final List<String> _irrigationMethods = <String>[
    'Rain',
    'Borewell',
    'Canal',
    'Drip',
    'Sprinkler',
    'Tank',
    'River',
  ];
  final Set<String> _selectedIrrigation = <String>{'Rain'};

  String _riskTolerance = 'Medium';
  String _experienceLevel = 'Beginner';
  String _cropPreference = 'Food crop';

  bool _loading = false;
  String? _error;

  FarmerProfile? _profile;

  @override
  void initState() {
    super.initState();
    _loadDefaults();
  }

  @override
  void dispose() {
    _locationController.dispose();
    _areaController.dispose();
    _soilTypeController.dispose();
    super.dispose();
  }

  Future<void> _loadDefaults() async {
    final stored = await SessionService.getStoredProfile();
    final profile = stored == null ? null : FarmerProfile.fromJson(stored);

    final locationParts =
        [profile?.village, profile?.district, profile?.state]
            .whereType<String>()
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();

    final fromFields =
        profile?.fields.map((f) => f.irrigationType).whereType<String>() ??
        const Iterable<String>.empty();
    final fromWater = profile?.waterSources ?? const <String>[];

    for (final option in [...fromFields, ...fromWater]) {
      final normalized = option.trim();
      if (normalized.isEmpty) continue;
      final match = _irrigationMethods.firstWhere(
        (m) => m.toLowerCase() == normalized.toLowerCase(),
        orElse: () => '',
      );
      if (match.isNotEmpty) _selectedIrrigation.add(match);
    }

    if (!mounted) return;
    setState(() {
      _profile = profile;
      _locationController.text = locationParts.join(', ');
      if (profile?.totalArea != null && (profile!.totalArea ?? 0) > 0) {
        _areaController.text = profile.totalArea!.toStringAsFixed(1);
      }
      if (profile?.soilTest.ph != null) {
        _soilTypeController.text =
            'Based on soil test pH ${profile!.soilTest.ph!.toStringAsFixed(1)}';
      } else {
        final fieldSoil = profile?.fields
            .map((f) => f.soilType)
            .whereType<String>()
            .firstWhere((s) => s.trim().isNotEmpty, orElse: () => '');
        if (fieldSoil != null && fieldSoil.trim().isNotEmpty) {
          _soilTypeController.text = fieldSoil;
        }
      }
      _experienceLevel = _normalizeExperience(profile?.experienceLevel);
      if (!_selectedIrrigation.contains('Rain')) {
        _selectedIrrigation.add('Rain');
      }
    });
  }

  String _normalizeExperience(String? value) {
    final raw = value?.trim().toLowerCase() ?? '';
    if (raw.contains('expert') || raw.contains('advanced')) return 'Expert';
    if (raw.contains('intermediate') || raw.contains('mid')) {
      return 'Intermediate';
    }
    return 'Beginner';
  }

  Future<void> _generateSuggestions() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final now = DateTime.now();
    final district = _profile?.district?.trim() ?? '';
    final state = _profile?.state?.trim() ?? '';

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final rainfall = await RainfallNormalsService.getNormalsForLocation(
        state: state,
        district: district,
      );
      final market = await MarketIntelligenceService.buildMarketFactor(
        location: _locationController.text.trim(),
        district: district,
        state: state,
      );

      final payload = <String, dynamic>{
        'location': _locationController.text.trim(),
        'district': district,
        'state': state,
        'land_area': double.parse(_areaController.text.trim()),
        'land_area_unit': 'acre',
        'soil_type':
            _soilTypeController.text.trim().isEmpty
                ? null
                : _soilTypeController.text.trim(),
        'irrigation_methods': _selectedIrrigation.toList(),
        'farmer_preferences': {
          'risk_tolerance': _riskTolerance,
          'experience_level': _experienceLevel,
          'crop_preference': _cropPreference,
        },
        'date': now.toIso8601String(),
        'season': _resolveSeason(now),
        'rainfall_normals': rainfall,
        'market_factor': market,
        'profile_context': _profile?.toJson(),
      };

      final response = await RecommendationService.cropSuggestionsFromContext(
        contextData: payload,
      );

      final suggestionsRaw = response['suggestions'];
      final list =
          suggestionsRaw is List
              ? suggestionsRaw
                  .whereType<Map>()
                  .map((e) => Map<String, dynamic>.from(e))
                  .toList()
              : <Map<String, dynamic>>[];

      list.sort((a, b) {
        final byRevenue = _toDouble(
          b['estimated_revenue'],
        ).compareTo(_toDouble(a['estimated_revenue']));
        if (byRevenue != 0) return byRevenue;
        return _toDouble(
          b['estimated_yield'],
        ).compareTo(_toDouble(a['estimated_yield']));
      });

      if (!mounted) return;
      final finalSuggestions = list.take(8).toList();
      final finalSummary =
          response['overall_summary']?.toString() ?? 'Generated suggestions';
      final landArea = double.tryParse(_areaController.text.trim()) ?? 0.0;
      final locationText = _locationController.text.trim();
      final season = _resolveSeason(now);

      await SessionService.saveCropSuggestionCache({
        'location': locationText,
        'district': district,
        'state': state,
        'season': season,
        'land_area_acres': landArea,
        'overall_summary': finalSummary,
        'suggestions': finalSuggestions,
        'generated_at': DateTime.now().toIso8601String(),
        'query_payload': payload,
      });

      if (!mounted) return;
      await Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder:
              (_) => CropSuggestionResultsScreen(
                location: locationText,
                season: season,
                landAreaAcres: landArea,
                overallSummary: finalSummary,
                suggestions: finalSuggestions,
              ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  String _resolveSeason(DateTime date) {
    final m = date.month;
    if (m >= 6 && m <= 10) return 'Kharif';
    if (m >= 11 || m <= 3) return 'Rabi';
    return 'Zaid';
  }

  double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse('$value') ?? 0.0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Crop Suggestions'),
        backgroundColor: AppColors.backgroundLight,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
            children: [
              _buildInputCard(),
              const SizedBox(height: 12),
              SizedBox(
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: _loading ? null : _generateSuggestions,
                  icon:
                      _loading
                          ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                          : const Icon(Icons.auto_awesome),
                  label: Text(
                    _loading ? 'Generating suggestions...' : 'Suggest Crops',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    foregroundColor: AppColors.white,
                  ),
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 10),
                Text(_error!, style: const TextStyle(color: AppColors.error)),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Input Details',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _locationController,
            decoration: const InputDecoration(
              labelText: 'Location',
              hintText: 'Village, district, state',
            ),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Location is required';
              return null;
            },
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _areaController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Land area (acre)',
              hintText: 'e.g., 2.5',
            ),
            validator: (v) {
              final n = double.tryParse(v?.trim() ?? '');
              if (n == null || n <= 0) return 'Enter a valid area';
              return null;
            },
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _soilTypeController,
            decoration: const InputDecoration(
              labelText: 'Soil type (optional)',
              hintText: 'Recommended for better suggestions',
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Irrigation methods available',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                _irrigationMethods.map((method) {
                  final selected = _selectedIrrigation.contains(method);
                  return FilterChip(
                    label: Text(method),
                    selected: selected,
                    onSelected: (value) {
                      setState(() {
                        if (value) {
                          _selectedIrrigation.add(method);
                        } else {
                          _selectedIrrigation.remove(method);
                        }
                        if (_selectedIrrigation.isEmpty) {
                          _selectedIrrigation.add('Rain');
                        }
                      });
                    },
                  );
                }).toList(),
          ),
          const SizedBox(height: 14),
          DropdownButtonFormField<String>(
            initialValue: _riskTolerance,
            decoration: const InputDecoration(labelText: 'Risk tolerance'),
            items: const [
              DropdownMenuItem(value: 'Low', child: Text('Low')),
              DropdownMenuItem(value: 'Medium', child: Text('Medium')),
              DropdownMenuItem(value: 'High', child: Text('High')),
            ],
            onChanged: (value) {
              if (value == null) return;
              setState(() => _riskTolerance = value);
            },
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _experienceLevel,
            decoration: const InputDecoration(labelText: 'Experience level'),
            items: const [
              DropdownMenuItem(value: 'Beginner', child: Text('Beginner')),
              DropdownMenuItem(
                value: 'Intermediate',
                child: Text('Intermediate'),
              ),
              DropdownMenuItem(value: 'Expert', child: Text('Expert')),
            ],
            onChanged: (value) {
              if (value == null) return;
              setState(() => _experienceLevel = value);
            },
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _cropPreference,
            decoration: const InputDecoration(labelText: 'Preference'),
            items: const [
              DropdownMenuItem(value: 'Food crop', child: Text('Food crop')),
              DropdownMenuItem(value: 'Cash crop', child: Text('Cash crop')),
            ],
            onChanged: (value) {
              if (value == null) return;
              setState(() => _cropPreference = value);
            },
          ),
        ],
      ),
    );
  }
}
