import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:kisan/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../constants/app_colors.dart';
import '../models/onboarding_profile.dart';
import '../providers/profile_provider.dart';
import '../services/session_service.dart';

class NewOnboardingScreen extends StatefulWidget {
  const NewOnboardingScreen({super.key});

  @override
  State<NewOnboardingScreen> createState() => _NewOnboardingScreenState();
}

enum LocationInputMode { detect, manual }

class _NewOnboardingScreenState extends State<NewOnboardingScreen> {
  final _nameController = TextEditingController();
  final _landSizeController = TextEditingController();

  static const _locationBaseUrl = 'https://india-location-hub.in/api';
  static const Duration _locationRequestTimeout = Duration(seconds: 12);

  List<LocationOption> _states = [];
  List<LocationOption> _districts = [];
  List<LocationOption> _towns = [];

  LocationOption? _selectedState;
  LocationOption? _selectedDistrict;
  LocationOption? _selectedTown;

  String? _pendingStateName;
  String? _pendingDistrictName;
  String? _pendingTownName;

  bool _loadingStates = false;
  bool _loadingDistricts = false;
  bool _loadingTowns = false;
  bool _detectingLocation = false;
  bool _isSaving = false;
  String? _detectedAdministrativeArea;
  String? _detectedSubAdministrativeArea;
  String? _detectedLocality;
  LocationInputMode _locationInputMode = LocationInputMode.manual;
  final List<String> _areaUnits = const [
    'Acre',
    'Hectare',
    'Beegha',
    'KM2',
  ];
  String _selectedAreaUnit = 'Acre';

  @override
  void initState() {
    super.initState();
    _loadDraft();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadStates();
    });
  }

  Future<void> _loadDraft() async {
    final draft = await SessionService.getOnboardingDraft();
    if (draft != null) {
      _nameController.text = (draft['name'] ?? '').toString();
      _pendingTownName = (draft['village'] ?? '').toString().trim();
      _pendingDistrictName = (draft['district'] ?? '').toString().trim();
      _pendingStateName = (draft['state'] ?? '').toString().trim();
      _landSizeController.text = (draft['landSize'] ?? '').toString();
      final unit = (draft['areaUnit'] ?? '').toString().trim();
      if (unit.isNotEmpty && _areaUnits.contains(unit)) {
        _selectedAreaUnit = unit;
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _landSizeController.dispose();
    super.dispose();
  }

  Future<void> _loadStates() async {
    if (_loadingStates) return;
    setState(() => _loadingStates = true);
    try {
      final uri = Uri.parse('$_locationBaseUrl/locations/states');
      final response = await _getWithRetry(uri);
      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      final data = Map<String, dynamic>.from(decoded['data'] ?? {});
      final rawStates = List<dynamic>.from(data['states'] ?? const []);
      final states =
          rawStates
              .whereType<Map>()
              .map((entry) => LocationOption.fromJson(Map<String, dynamic>.from(entry)))
              .where((entry) => entry.name.trim().isNotEmpty)
              .toList();
      if (!mounted) return;
      setState(() => _states = states);
      await _applyPendingSelection();
    } catch (_) {
      if (mounted) {
        _showSnack('Could not load states. Please try again.');
      }
    } finally {
      if (mounted) setState(() => _loadingStates = false);
    }
  }

  Future<void> _loadDistricts(String stateName) async {
    if (_loadingDistricts) return;
    setState(() => _loadingDistricts = true);
    try {
      final uri = Uri.parse('$_locationBaseUrl/locations/districts');
      final response = await _getWithRetry(uri);
      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      final data = Map<String, dynamic>.from(decoded['data'] ?? {});
      final allDistricts = List<dynamic>.from(data['districts'] ?? const []);

      final filteredDistricts =
          allDistricts
              .where(
                (d) =>
                    d['state_name'].toString().toUpperCase() ==
                    stateName.toUpperCase(),
              )
              .whereType<Map>()
              .map((json) => LocationOption.fromJson(Map<String, dynamic>.from(json)))
              .toList();
      if (!mounted) return;
      setState(() {
        _districts = filteredDistricts;
        final matchedDistrict = _matchOption(_districts, _selectedDistrict);
        _selectedDistrict = matchedDistrict;
        if (matchedDistrict == null) {
          _selectedTown = null;
          _towns = [];
        }
      });

      await _applyPendingSelection();
    } catch (_) {
      if (mounted) {
        _showSnack('Could not load districts. Please try again.');
      }
    } finally {
      if (mounted) setState(() => _loadingDistricts = false);
    }
  }

  Future<void> _loadTowns(String districtName, String stateName) async {
    if (_loadingTowns) return;
    setState(() => _loadingTowns = true);
    try {
      final uri = Uri.parse('$_locationBaseUrl/locations/talukas');
      final response = await _getWithRetry(uri);
      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      final data = Map<String, dynamic>.from(decoded['data'] ?? {});
      final allTalukas = List<dynamic>.from(data['talukas'] ?? const []);

      final filteredTalukas =
          allTalukas
              .where(
                (d) =>
                    d['district_name'].toString().toUpperCase() ==
                        districtName.toUpperCase() &&
                    d['state_name'].toString().toUpperCase() ==
                        stateName.toUpperCase(),
              )
              .whereType<Map>()
              .map((json) => LocationOption.fromJson(Map<String, dynamic>.from(json)))
              .toList();
      if (!mounted) return;
      setState(() {
        _towns = filteredTalukas;
        _selectedTown = _matchOption(_towns, _selectedTown);
      });
      await _applyPendingSelection();
    } catch (_) {
      if (mounted) {
        _showSnack('Could not load towns. Please try again.');
      }
    } finally {
      if (mounted) setState(() => _loadingTowns = false);
    }
  }

  Future<void> _applyPendingSelection() async {
    if (_pendingStateName != null &&
        _pendingStateName!.trim().isNotEmpty &&
        _selectedState == null &&
        _states.isNotEmpty) {
      final match = _findByName(_states, _pendingStateName!);
      _pendingStateName = null;
      if (match != null) {
        setState(() {
          _selectedState = match;
          _selectedDistrict = null;
          _selectedTown = null;
          _districts = [];
          _towns = [];
        });
        if (match.code != null) {
          await _loadDistricts(match.name);
        } else {
          _showSnack('Selected state has no code.');
        }
      }
    }

    if (_pendingDistrictName != null &&
        _pendingDistrictName!.trim().isNotEmpty &&
        _selectedDistrict == null &&
        _districts.isNotEmpty) {
      final match = _findByName(_districts, _pendingDistrictName!);
      _pendingDistrictName = null;
      if (match != null) {
        setState(() {
          _selectedDistrict = match;
          _selectedTown = null;
          _towns = [];
        });
        if (match.code != null) {
          await _loadTowns(match.name, _selectedState!.name);
        } else {
          _showSnack('Selected district has no code.');
        }
      }
    }

    if (_pendingTownName != null &&
        _pendingTownName!.trim().isNotEmpty &&
        _selectedTown == null &&
        _towns.isNotEmpty) {
      final match = _findByName(_towns, _pendingTownName!);
      _pendingTownName = null;
      if (match != null) {
        setState(() => _selectedTown = match);
      }
    }
  }

  LocationOption? _findByName(List<LocationOption> options, String name) {
    final normalizedTarget = _normalize(name);
    for (final option in options) {
      if (_normalize(option.name) == normalizedTarget) return option;
    }
    for (final option in options) {
      if (_normalize(option.name).contains(normalizedTarget)) return option;
    }
    return null;
  }

  LocationOption? _matchOption(
    List<LocationOption> options,
    LocationOption? selected,
  ) {
    if (selected == null) return null;
    final target = _normalize(selected.name);
    final targetCode = selected.code?.toLowerCase().trim();
    for (final option in options) {
      final sameName = _normalize(option.name) == target;
      final sameCode = option.code?.toLowerCase().trim() == targetCode;
      if (sameCode && sameName) return option;
    }
    for (final option in options) {
      if (_normalize(option.name) == target) return option;
    }
    return null;
  }

  String _normalize(String value) {
    return value.toLowerCase().replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  Future<http.Response> _getWithRetry(
    Uri uri, {
    int attempts = 3,
  }) async {
    Object? lastError;
    for (var attempt = 0; attempt < attempts; attempt++) {
      try {
        final response = await http.get(uri).timeout(_locationRequestTimeout);
        if (response.statusCode == 200) {
          return response;
        }
        lastError = Exception('HTTP ${response.statusCode}');
      } catch (error) {
        lastError = error;
      }

      if (attempt < attempts - 1) {
        await Future.delayed(Duration(milliseconds: 600 * (attempt + 1)));
      }
    }

    throw lastError ?? Exception('Request failed');
  }

  String? _nullIfEmpty(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;
    return trimmed;
  }

  bool get _hasDetectedLocation =>
      (_detectedAdministrativeArea != null &&
          _detectedAdministrativeArea!.isNotEmpty) ||
      (_detectedSubAdministrativeArea != null &&
          _detectedSubAdministrativeArea!.isNotEmpty) ||
      (_detectedLocality != null && _detectedLocality!.isNotEmpty);

  Widget _detectedLocationField() {
    final lines = <String>[];
    if (_detectedAdministrativeArea != null) {
      lines.add('State: ${_detectedAdministrativeArea!}');
    }
    if (_detectedSubAdministrativeArea != null) {
      lines.add('District: ${_detectedSubAdministrativeArea!}');
    }
    if (_detectedLocality != null) {
      lines.add('Taluka: ${_detectedLocality!}');
    }

    return InputDecorator(
      decoration: InputDecoration(
        labelText: 'Detected location',
        filled: true,
        fillColor: AppColors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.borderLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.borderLight),
        ),
      ),
      child: Text(
        lines.join('\n'),
        style: GoogleFonts.poppins(
          color: AppColors.textPrimary,
          fontSize: 13,
        ),
      ),
    );
  }

  Widget _locationModeSelector() {
    return Row(
      children: [
        Expanded(
          child: ChoiceChip(
            label: Text('Detect location'),
            selected: _locationInputMode == LocationInputMode.detect,
            onSelected: (selected) {
              if (!selected) return;
              setState(() => _locationInputMode = LocationInputMode.detect);
            },
            selectedColor: AppColors.primaryGreen.withOpacity(0.15),
            labelStyle: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              color:
                  _locationInputMode == LocationInputMode.detect
                      ? AppColors.primaryGreen
                      : AppColors.textPrimary,
            ),
            side: BorderSide(color: AppColors.borderLight),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ChoiceChip(
            label: Text('Enter manually'),
            selected: _locationInputMode == LocationInputMode.manual,
            onSelected: (selected) {
              if (!selected) return;
              setState(() => _locationInputMode = LocationInputMode.manual);
            },
            selectedColor: AppColors.primaryGreen.withOpacity(0.15),
            labelStyle: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              color:
                  _locationInputMode == LocationInputMode.manual
                      ? AppColors.primaryGreen
                      : AppColors.textPrimary,
            ),
            side: BorderSide(color: AppColors.borderLight),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _detectLocation() async {
    if (_detectingLocation) return;
    setState(() => _detectingLocation = true);

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showSnack('Location services are disabled.');
        await Geolocator.openLocationSettings();
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        _showSnack('Location permission denied.');
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (placemarks.isEmpty) {
        _showSnack('Unable to resolve address from GPS.');
        return;
      }

      final place = placemarks.first;
      setState(() {
        _detectedAdministrativeArea = _nullIfEmpty(place.administrativeArea);
        _detectedSubAdministrativeArea =
            _nullIfEmpty(place.subAdministrativeArea);
        _detectedLocality = _nullIfEmpty(place.locality);
      });

      final state = _detectedAdministrativeArea;
      final district = _detectedSubAdministrativeArea ?? _detectedLocality;
      final town =
          _detectedLocality ??
          _nullIfEmpty(place.subLocality) ??
          _nullIfEmpty(place.name);

      _pendingStateName = state;
      _pendingDistrictName = district;
      _pendingTownName = town;
      await _applyPendingSelection();
    } catch (_) {
      _showSnack('Could not detect location. Please try again.');
    } finally {
      if (mounted) setState(() => _detectingLocation = false);
    }
  }

  Future<void> _finish() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);

    final name = _nameController.text.trim();
    String village = '';
    String district = '';
    String state = '';
    if (_locationInputMode == LocationInputMode.detect) {
      state = _detectedAdministrativeArea ?? '';
      district = _detectedSubAdministrativeArea ?? '';
      village = _detectedLocality ?? '';
    } else {
      village = _selectedTown?.name ?? '';
      district = _selectedDistrict?.name ?? '';
      state = _selectedState?.name ?? '';
    }
    final landSize = _landSizeController.text.trim();
    final totalArea = double.tryParse(landSize);
    final missingLocation = state.isEmpty || district.isEmpty || village.isEmpty;
    if (name.isEmpty ||
        missingLocation ||
        landSize.isEmpty ||
        totalArea == null) {
      _showSnack('Please fill all the fields before continuing.');
      if (mounted) setState(() => _isSaving = false);
      return;
    }

    final draft = <String, dynamic>{
      'name': name.isEmpty ? null : name,
      'village': village.isEmpty ? null : village,
      'district': district.isEmpty ? null : district,
      'state': state.isEmpty ? null : state,
      'landSize': landSize.isEmpty ? null : landSize,
      'totalArea': totalArea,
      'areaUnit': _selectedAreaUnit,
    };

    await SessionService.saveOnboardingDraft(draft);
    final profile = FarmerProfile.fromDraft(draft);
    final provider = context.read<ProfileProvider>();
    await provider.saveProfile(profile);
    await SessionService.setOnboardingComplete(true);
    await SessionService.setLoggedIn(true);
    if (!mounted) return;
    context.go('/home');
  }

  Future<void> _skip() async {
    final draft = <String, dynamic>{'name': 'Guest'};
    final profile = FarmerProfile.fromDraft(draft);
    final provider = context.read<ProfileProvider>();
    await provider.saveProfile(profile);
    await SessionService.setOnboardingComplete(true);
    await SessionService.setLoggedIn(true);
    if (!mounted) return;
    context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Quick Setup',
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: _skip,
                    child: Text(
                      'Skip for now',
                      style: GoogleFonts.poppins(
                        color: AppColors.primaryGreen,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Tell us a few basics to personalize your experience.',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 24),
              _sectionTitle(l10n.nameLabel),
              _textField(
                controller: _nameController,
                hint: l10n.nameHint,
                icon: Icons.person_outline,
              ),
              const SizedBox(height: 24),
              _sectionTitle('Location'),
              const SizedBox(height: 8),
              _locationModeSelector(),
              const SizedBox(height: 12),
              if (_locationInputMode == LocationInputMode.detect) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    OutlinedButton.icon(
                      onPressed: _detectingLocation ? null : _detectLocation,
                      icon: const Icon(Icons.my_location, size: 18),
                      label: Text(
                        _detectingLocation ? 'Detecting...' : 'Detect location',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primaryGreen,
                        side: BorderSide(color: AppColors.primaryGreen),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                ),
                if (_hasDetectedLocation) ...[
                  const SizedBox(height: 12),
                  _detectedLocationField(),
                ],
              ] else ...[
                _sectionTitle(l10n.stateLabel),
                _dropdownField(
                  hint:
                      _loadingStates
                          ? 'Loading states...'
                          : l10n.selectStateHint,
                  value: _selectedState,
                  items: _states,
                  loading: _loadingStates,
                  onChanged: (value) async {
                    setState(() {
                      _selectedState = value;
                      _selectedDistrict = null;
                      _selectedTown = null;
                      _districts = [];
                      _towns = [];
                    });
                    if (value != null) {
                      if (value.code != null) {
                        await _loadDistricts(value.name);
                      } else {
                        _showSnack('Selected state has no code.');
                      }
                    }
                  },
                ),
                const SizedBox(height: 12),
                _sectionTitle(l10n.districtLabel),
                _dropdownField(
                  hint:
                      _selectedState == null
                          ? 'Select a state first'
                          : _loadingDistricts
                          ? 'Loading districts...'
                          : l10n.selectDistrictHint,
                  value: _selectedDistrict,
                  items: _districts,
                  loading: _loadingDistricts,
                  onChanged: (value) async {
                    setState(() {
                      _selectedDistrict = value;
                      _selectedTown = null;
                      _towns = [];
                    });
                    if (value != null) {
                      if (value.code != null) {
                        await _loadTowns(value.name, _selectedState!.name);
                      } else {
                        _showSnack('Selected district has no code.');
                      }
                    }
                  },
                ),
                const SizedBox(height: 12),
                _sectionTitle(l10n.tehsilLabel),
                _dropdownField(
                  hint:
                      _selectedDistrict == null
                          ? 'Select a district first'
                          : _loadingTowns
                          ? 'Loading towns...'
                          : l10n.villageTownHint,
                  value: _selectedTown,
                  items: _towns,
                  loading: _loadingTowns,
                  onChanged: (value) {
                    setState(() => _selectedTown = value);
                  },
                ),
              ],
              const SizedBox(height: 24),
              _sectionTitle(l10n.totalFarmAreaLabel),
              Row(
                children: [
                  Expanded(
                    child: _textField(
                      controller: _landSizeController,
                      hint: l10n.farmAreaHint,
                      icon: Icons.square_foot,
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 140,
                    child: DropdownButtonFormField<String>(
                      value: _selectedAreaUnit,
                      items:
                          _areaUnits
                              .map(
                                (unit) => DropdownMenuItem<String>(
                                  value: unit,
                                  child: Text(
                                    unit,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              )
                              .toList(),
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() => _selectedAreaUnit = value);
                      },
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: AppColors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppColors.borderLight),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppColors.borderLight),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppColors.primaryGreen),
                        ),
                      ),
                      style: GoogleFonts.poppins(color: AppColors.textPrimary),
                      icon: Icon(
                        Icons.arrow_drop_down,
                        color: AppColors.textSecondary,
                      ),
                      isExpanded: true,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _finish,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    foregroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    _isSaving ? 'Saving...' : 'Continue',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'You can edit these anytime from your profile.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _textField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: AppColors.textSecondary),
        filled: true,
        fillColor: AppColors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.borderLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.borderLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.primaryGreen),
        ),
      ),
      style: GoogleFonts.poppins(color: AppColors.textPrimary),
    );
  }

  Widget _dropdownField({
    required String hint,
    required List<LocationOption> items,
    required LocationOption? value,
    required bool loading,
    required ValueChanged<LocationOption?> onChanged,
  }) {
    return DropdownButtonFormField<LocationOption>(
      value: value,
      items:
          items
              .map(
                (item) => DropdownMenuItem<LocationOption>(
                  value: item,
                  child: Text(item.name, overflow: TextOverflow.ellipsis),
                ),
              )
              .toList(),
      onChanged: loading ? null : onChanged,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: AppColors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.borderLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.borderLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.primaryGreen),
        ),
      ),
      style: GoogleFonts.poppins(color: AppColors.textPrimary),
      icon: Icon(Icons.arrow_drop_down, color: AppColors.textSecondary),
      isExpanded: true,
    );
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

class LocationOption {
  final int id;
  final String name;
  final String? code;

  const LocationOption({required this.id, required this.name, this.code});

  factory LocationOption.fromJson(Map<String, dynamic> json) {
    return LocationOption(
      id: (json['id'] is num) ? (json['id'] as num).toInt() : 0,
      name: (json['name'] ?? '').toString(),
      code: (json['code'] ?? '').toString(),
    );
  }
}
