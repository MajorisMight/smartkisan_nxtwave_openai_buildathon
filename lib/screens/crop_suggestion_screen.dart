import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../constants/app_colors.dart';
import '../models/crop.dart';
import '../models/profile.dart' as db_profile;
import '../providers/crop_provider.dart';
import '../providers/profile_provider.dart';
import '../services/rainfall_normals_service.dart';
import '../services/recommendation_service.dart';
import '../services/session_service.dart';
import 'crop_suggestion_results_screen.dart';

class CropSuggestionScreen extends ConsumerStatefulWidget {
  const CropSuggestionScreen({super.key});

  @override
  ConsumerState<CropSuggestionScreen> createState() =>
      _CropSuggestionScreenState();
}

class _CropSuggestionScreenState extends ConsumerState<CropSuggestionScreen> {
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
  final List<String> _backendCropHistory = <String>[];

  String _riskTolerance = 'Medium';
  String _experienceLevel = 'Beginner';
  String _cropPreference = 'Food crop';
  String _district = '';
  String _state = '';

  bool _bootstrapping = true;
  bool _loading = false;
  String? _error;

  db_profile.FarmerProfile? _fullProfile;

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
    db_profile.FarmerProfile? profile;
    List<Crop> crops = const <Crop>[];

    try {
      profile = await ref.read(fullProfileProvider.future);
    } catch (_) {}

    try {
      crops = await ref.read(cropsProvider.future);
    } catch (_) {}

    final farm =
        profile?.farms.isNotEmpty == true ? profile!.farms.first : null;
    final locationParts =
        [farm?.village, farm?.district, farm?.state]
            .whereType<String>()
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty && e != 'N/A')
            .toList();

    final cropNames = <String>{
      for (final crop in crops)
        if (crop.name.trim().isNotEmpty) crop.name.trim(),
      for (final f in profile?.farms ?? const <db_profile.Farm>[])
        for (final crop in f.crops)
          if (crop.cropName.trim().isNotEmpty) crop.cropName.trim(),
    };

    if (!mounted) return;
    setState(() {
      _fullProfile = profile;
      _district = farm?.district == 'N/A' ? '' : (farm?.district ?? '');
      _state = farm?.state == 'N/A' ? '' : (farm?.state ?? '');
      _locationController.text = locationParts.join(', ');
      _areaController.clear();
      _backendCropHistory
        ..clear()
        ..addAll(cropNames);
      _experienceLevel = _normalizeExperience(profile?.experience);
      _bootstrapping = false;
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
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final rainfall = await RainfallNormalsService.getNormalsForLocation(
        state: _state,
        district: _district,
      );

      final payload = <String, dynamic>{
        'location': _locationController.text.trim(),
        'district': _district,
        'state': _state,
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
        'current_crops': _backendCropHistory,
        'date': now.toIso8601String(),
        'season': _resolveSeason(now),
        'rainfall_normals': rainfall,
        'profile_context': {
          'name': _fullProfile?.name,
          'language': _fullProfile?.language,
          'experience': _fullProfile?.experience,
          'farms_count': _fullProfile?.farms.length ?? 0,
          'crop_count': _backendCropHistory.length,
        },
        'data_sources': <String>[
          'supabase.farmers',
          'supabase.farms',
          'supabase.farm_crops',
        ],
      };

      final response = await RecommendationService.cropSuggestionsFromContext(
        contextData: payload,
      );

      final suggestionsRaw = response['suggestions'];
      final suggestions =
          suggestionsRaw is List
              ? suggestionsRaw
                  .whereType<Map>()
                  .map((e) => Map<String, dynamic>.from(e))
                  .toList()
              : <Map<String, dynamic>>[];

      suggestions.sort((a, b) {
        final byRevenue = _toDouble(
          b['estimated_revenue'],
        ).compareTo(_toDouble(a['estimated_revenue']));
        if (byRevenue != 0) return byRevenue;
        return _toDouble(
          b['estimated_yield'],
        ).compareTo(_toDouble(a['estimated_yield']));
      });

      final finalSuggestions = suggestions.take(8).toList();
      final finalSummary =
          response['overall_summary']?.toString() ?? 'Generated suggestions';
      final landArea = double.tryParse(_areaController.text.trim()) ?? 0.0;
      final locationText = _locationController.text.trim();
      final season = _resolveSeason(now);

      await SessionService.saveCropSuggestionCache({
        'location': locationText,
        'district': _district,
        'state': _state,
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
        _error = e.toString().replaceFirst('Exception: ', '');
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
      body:
          _bootstrapping
              ? const Center(child: CircularProgressIndicator())
              : SafeArea(
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
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                  : const Icon(Icons.auto_awesome),
                          label: Text(
                            _loading
                                ? 'Generating suggestions...'
                                : 'Suggest Crops',
                          ),
                        ),
                      ),
                      if (_error != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          _error!,
                          style: const TextStyle(color: AppColors.error),
                        ),
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
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Using backend profile + farm data',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Location is prefilled from Supabase. Enter land area manually.',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _locationController,
            decoration: const InputDecoration(
              labelText: 'Location',
              hintText: 'Village, district, state',
            ),
            validator: (value) {
              final text = value?.trim() ?? '';
              if (text.isEmpty) return 'Location is required';
              return null;
            },
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _areaController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Land area (acre)',
              hintText: 'Enter land area in acres',
            ),
            validator: (value) {
              final parsed = double.tryParse((value ?? '').trim());
              if (parsed == null || parsed <= 0) {
                return 'Enter valid land area';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _soilTypeController,
            decoration: const InputDecoration(
              labelText: 'Soil type (optional)',
              hintText: 'e.g., Loamy',
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _riskTolerance,
            decoration: const InputDecoration(labelText: 'Risk tolerance'),
            items:
                const ['Low', 'Medium', 'High']
                    .map(
                      (e) => DropdownMenuItem<String>(value: e, child: Text(e)),
                    )
                    .toList(),
            onChanged: (value) {
              if (value == null) return;
              setState(() => _riskTolerance = value);
            },
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _cropPreference,
            decoration: const InputDecoration(labelText: 'Crop preference'),
            items:
                const ['Food crop', 'Cash crop', 'Pulses', 'Oilseed', 'Any']
                    .map(
                      (e) => DropdownMenuItem<String>(value: e, child: Text(e)),
                    )
                    .toList(),
            onChanged: (value) {
              if (value == null) return;
              setState(() => _cropPreference = value);
            },
          ),
          const SizedBox(height: 12),
          const Text(
            'Irrigation methods',
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
          if (_backendCropHistory.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              'Detected current crops: ${_backendCropHistory.join(', ')}',
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ],
      ),
    );
  }
}
