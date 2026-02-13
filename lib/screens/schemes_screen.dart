import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_colors.dart';
import '../models/scheme.dart';
import '../services/recommendation_service.dart';

class SchemesScreen extends StatefulWidget {
  const SchemesScreen({super.key});

  @override
  State<SchemesScreen> createState() => _SchemesScreenState();
}

class _SchemesScreenState extends State<SchemesScreen> {
  static const String _schemesProfileKey = 'schemes_profile_v1';
  static const String _schemesProfileDoneKey = 'schemes_profile_done_v1';
  static const String _onboardingDraftKey = 'onboarding_draft';

  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'Subsidy', 'Insurance', 'Loan', 'Training'];
  final TextEditingController _searchController = TextEditingController();
  
  bool _isLoading = false;
  bool _showFirstTimeSetup = false;
  List<Map<String, dynamic>> _schemes = [];
  Map<String, dynamic> profile = _defaultSchemeProfile();

  static Map<String, dynamic> _defaultSchemeProfile() {
    return {
      'state': 'Punjab',
      'district': 'Ludhiana',
      'farmer_type': 'Landowner',
      'landholding_size': 'Small (1–2 ha)',
      'primary_crop_type': 'Food grains',
      'irrigation_type': 'Canal',
      'season': 'Rabi',
      'caste_category': 'OBC',
      'annual_income_bracket': '₹1.5–3L',
      'farmer_age_group': '30-45',
      'women_farmer': 'No',
      'existing_assets': ['Tractor', 'Pump set'],
      'pm_kisan_registered': 'Yes',
    };
  }

  Future<void> _loadProfileFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final onboardingStr = prefs.getString(_onboardingDraftKey);
    if (onboardingStr != null && onboardingStr.isNotEmpty) {
      final onboarding = Map<String, dynamic>.from(jsonDecode(onboardingStr));
      profile = {
        ...profile,
        ..._mapToSchemesProfile(onboarding),
      };
    }

    final profileStr = prefs.getString('farmer_profile_v1');
    if (profileStr != null && profileStr.isNotEmpty) {
      final decoded = Map<String, dynamic>.from(jsonDecode(profileStr));
      profile = {
        ...profile,
        ..._mapToSchemesProfile(decoded),
      };
    }
    final schemesProfileStr = prefs.getString(_schemesProfileKey);
    if (schemesProfileStr != null && schemesProfileStr.isNotEmpty) {
      profile = {
        ...profile,
        ...Map<String, dynamic>.from(jsonDecode(schemesProfileStr)),
      };
    }
  }

  Map<String, dynamic> _mapToSchemesProfile(Map<String, dynamic> src) {
    final mapped = <String, dynamic>{};
    final name = _asString(src['name']);
    final state = _asString(src['state']);
    final district = _asString(src['district']);
    final socialCategory = _asString(src['socialCategory']);
    final income = _asString(src['incomeBracket']);
    final waterSources = src['waterSources'];
    final crops = src['crops'];

    if (name != null && name.isNotEmpty) mapped['name'] = name;
    if (state != null && state.isNotEmpty) mapped['state'] = state;
    if (district != null && district.isNotEmpty) mapped['district'] = district;
    if (socialCategory != null && socialCategory.isNotEmpty) {
      mapped['caste_category'] = _normalizeCasteCategory(socialCategory);
    }
    if (income != null && income.isNotEmpty) {
      mapped['annual_income_bracket'] = _normalizeIncomeBracket(income);
    }

    final areaHa = _areaInHectares(src);
    if (areaHa != null) {
      mapped['landholding_size'] = _landholdingFromArea(areaHa);
      mapped['land_area_ha'] = areaHa;
    }

    final cropType = _derivePrimaryCropType(crops);
    if (cropType != null) mapped['primary_crop_type'] = cropType;

    final irrigation = _deriveIrrigationType(waterSources);
    if (irrigation != null) mapped['irrigation_type'] = irrigation;

    return mapped;
  }

  String? _asString(dynamic value) {
    if (value == null) return null;
    final s = value.toString().trim();
    return s.isEmpty ? null : s;
  }

  double? _areaInHectares(Map<String, dynamic> src) {
    final totalAreaRaw = src['totalArea'];
    if (totalAreaRaw == null) return null;
    final totalArea = totalAreaRaw is num
        ? totalAreaRaw.toDouble()
        : double.tryParse(totalAreaRaw.toString());
    if (totalArea == null) return null;

    final unit = _asString(src['areaUnit'])?.toLowerCase() ?? 'acre';
    if (unit.contains('ha') || unit.contains('hect')) {
      return totalArea;
    }
    return totalArea * 0.404686; // acres -> ha
  }

  String _landholdingFromArea(double areaHa) {
    if (areaHa <= 0) return 'Landless';
    if (areaHa < 1) return 'Marginal (<1 ha)';
    if (areaHa <= 2) return 'Small (1–2 ha)';
    return 'Medium / Large';
  }

  String? _derivePrimaryCropType(dynamic cropsRaw) {
    if (cropsRaw is! List || cropsRaw.isEmpty) return null;
    final joined = cropsRaw
        .map((e) {
          if (e is Map) {
            final cropId = e['crop_id'] ?? e['planned_crop'] ?? e['cropId'];
            return cropId?.toString().toLowerCase() ?? '';
          }
          return e.toString().toLowerCase();
        })
        .join(' ');

    if (joined.contains('milk') ||
        joined.contains('dairy') ||
        joined.contains('fish') ||
        joined.contains('fisher')) {
      return 'Livestock / Dairy / Fisheries';
    }
    if (joined.contains('tea') ||
        joined.contains('coffee') ||
        joined.contains('rubber')) {
      return 'Plantation';
    }
    if (joined.contains('vegetable') ||
        joined.contains('fruit') ||
        joined.contains('mango') ||
        joined.contains('banana')) {
      return 'Horticulture';
    }
    if (joined.contains('cotton') ||
        joined.contains('sugarcane') ||
        joined.contains('tobacco')) {
      return 'Cash crops';
    }
    return 'Food grains';
  }

  String? _deriveIrrigationType(dynamic sourcesRaw) {
    if (sourcesRaw is! List || sourcesRaw.isEmpty) return null;
    final joined = sourcesRaw.map((e) => e.toString().toLowerCase()).join(' ');
    if (joined.contains('canal')) return 'Canal';
    if (joined.contains('tube') || joined.contains('bore')) {
      return 'Borewell / Tube well';
    }
    if (joined.contains('rain')) return 'Rainfed';
    return null;
  }

  String _normalizeCasteCategory(String raw) {
    final v = raw.toLowerCase();
    if (v.contains('sc') || v.contains('st')) return 'SC / ST';
    if (v.contains('obc')) return 'OBC';
    return 'General';
  }

  String _normalizeIncomeBracket(String raw) {
    final v = raw.toLowerCase();
    if (v.contains('1.5') || v.contains('150000') || v.contains('1,50,000')) {
      return '< ₹1.5L';
    }
    if (v.contains('3l') || v.contains('300000') || v.contains('3,00,000')) {
      return '₹3L';
    }
    if (v.contains('1.5') || v.contains('3')) {
      return '₹1.5–3L';
    }
    return '₹1.5–3L';
  }

  @override
  void initState() {
    super.initState();
    _initializeSchemesFlow();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _initializeSchemesFlow() async {
    final prefs = await SharedPreferences.getInstance();
    await _loadProfileFromStorage();
    final isProfileDone = prefs.getBool(_schemesProfileDoneKey) ?? false;

    if (!mounted) return;
    if (!isProfileDone) {
      setState(() {
        _showFirstTimeSetup = true;
        _isLoading = false;
      });
      return;
    }
    await _fetchSchemes();
  }

  Future<void> _fetchSchemes() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }
    try {
      print('[SchemesScreen] Fetching schemes with profile: ${jsonEncode(profile)}');
      final schemes = await RecommendationService.applicableSchemesFromMap(
        profile: profile,
      );
      print('[SchemesScreen] Schemes received count: ${schemes.length}');

      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/scheme.txt');
      await file.writeAsString(jsonEncode(schemes));

      if (!mounted) return;
      setState(() {
        _schemes = schemes;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load schemes: $e')),
      );
    }
  }

  Future<void> _saveFirstTimeProfileAndFetch() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_schemesProfileKey, jsonEncode(profile));
    await prefs.setBool(_schemesProfileDoneKey, true);

    if (!mounted) return;
    setState(() {
      _showFirstTimeSetup = false;
    });
    await _fetchSchemes();
  }

  // Removed from here. Move this static method to the Scheme model class.
  List<Scheme> _applyFilters(List<Map<String, dynamic>> schemes) {
    final query = _searchController.text.trim().toLowerCase();
    List<Scheme> filtered = schemes.map((s) => Scheme.fromMap(s)).toList();
    if (_selectedFilter != 'All') {
      final cat = _selectedFilter.toLowerCase();
      filtered = filtered.where((s) => s.category == cat).toList();
    }
    if (query.isNotEmpty) {
      filtered = filtered.where((s) => s.title.toLowerCase().contains(query) || s.description.toLowerCase().contains(query)).toList();
    }
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildLoadingScreen();
    }
    if (_showFirstTimeSetup) {
      return _buildFirstLaunchSetup();
    }

    final filtered = _applyFilters(_schemes);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildSearchAndChips(),
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) => _buildSchemeCard(filtered[index]),
                ),
              ),
              // Padding(
              //   padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 16.h),
              //   child: SizedBox(
              //     width: double.infinity,
              //     height: 48.h,
              //     child: ElevatedButton.icon(
              //       onPressed: _isLoading ? null : _fetchAiSchemes,
              //       icon: const Icon(Icons.auto_awesome),
              //       label: Text('Check applicable schemes with AI'),
              //       style: ElevatedButton.styleFrom(
              //         backgroundColor: AppColors.primaryGreen,
              //         foregroundColor: AppColors.white,
              //         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
              //       ),
              //     ),
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFirstLaunchSetup() {
    final farmerTypeOptions = ['Landowner', 'Tenant farmer', 'Sharecropper'];
    final landholdingOptions = [
      'Landless',
      'Marginal (<1 ha)',
      'Small (1–2 ha)',
      'Medium / Large',
    ];
    final cropTypeOptions = [
      'Food grains',
      'Cash crops',
      'Horticulture',
      'Plantation',
      'Livestock / Dairy / Fisheries',
    ];
    final irrigationOptions = ['Rainfed', 'Canal', 'Borewell / Tube well'];
    final seasonOptions = ['Kharif', 'Rabi', 'Zaid'];
    final casteOptions = ['General', 'SC / ST', 'OBC'];
    final incomeOptions = ['< ₹1.5L', '₹1.5–3L', '₹3L'];
    final ageOptions = ['18-29', '30-45', '46-60', '60+'];
    final womenOptions = ['Yes', 'No'];
    final registrationOptions = ['Yes', 'No', 'Don’t know'];
    final assetOptions = ['Tractor', 'Pump set', 'Dairy animals'];

    Widget dropdown({
      required String label,
      required String keyName,
      required List<String> options,
    }) {
      final currentRaw = profile[keyName]?.toString();
      final matched = currentRaw == null
          ? null
          : options.cast<String?>().firstWhere(
              (opt) => opt?.toLowerCase() == currentRaw.toLowerCase(),
              orElse: () => null,
            );
      return Padding(
        padding: EdgeInsets.only(bottom: 12.h),
        child: DropdownButtonFormField<String>(
          initialValue: matched,
          decoration: InputDecoration(
            labelText: label,
            filled: true,
            fillColor: AppColors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r)),
          ),
          items: options
              .map((e) => DropdownMenuItem<String>(value: e, child: Text(e)))
              .toList(),
          onChanged: (value) {
            if (value == null) return;
            setState(() {
              profile[keyName] = value;
            });
          },
        ),
      );
    }

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 16.h),
                  child: Container(
                    padding: EdgeInsets.all(14.w),
                    decoration: BoxDecoration(
                      color: AppColors.white.withOpacity(0.96),
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'First-time Scheme Setup',
                          style: GoogleFonts.poppins(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 6.h),
                        Text(
                          'All fields are prefilled with dummy data. Tap Next to continue.',
                          style: GoogleFonts.poppins(
                            fontSize: 12.sp,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        SizedBox(height: 14.h),
                        Text('Tier 1 (Required)', style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
                        SizedBox(height: 8.h),
                        dropdown(label: 'State', keyName: 'state', options: const ['Punjab', 'Maharashtra', 'Haryana', 'Rajasthan']),
                        dropdown(label: 'District (Optional)', keyName: 'district', options: const ['Ludhiana', 'Amritsar', 'Pune', 'Nashik', 'Hisar', 'Jaipur']),
                        dropdown(label: 'Farmer Type', keyName: 'farmer_type', options: farmerTypeOptions),
                        dropdown(label: 'Landholding Size', keyName: 'landholding_size', options: landholdingOptions),
                        dropdown(label: 'Primary Crop Type', keyName: 'primary_crop_type', options: cropTypeOptions),
                        dropdown(label: 'Irrigation Type', keyName: 'irrigation_type', options: irrigationOptions),
                        SizedBox(height: 8.h),
                        Text('Tier 2 (High Value)', style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
                        SizedBox(height: 8.h),
                        dropdown(label: 'Season', keyName: 'season', options: seasonOptions),
                        dropdown(label: 'Caste Category', keyName: 'caste_category', options: casteOptions),
                        dropdown(label: 'Annual Income Bracket', keyName: 'annual_income_bracket', options: incomeOptions),
                        SizedBox(height: 8.h),
                        Text('Tier 3 (Optional)', style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
                        SizedBox(height: 8.h),
                        dropdown(label: 'Farmer Age', keyName: 'farmer_age_group', options: ageOptions),
                        dropdown(label: 'Women Farmer', keyName: 'women_farmer', options: womenOptions),
                        dropdown(label: 'PM-KISAN Registered', keyName: 'pm_kisan_registered', options: registrationOptions),
                        SizedBox(height: 10.h),
                        Text(
                          'Existing Assets',
                          style: GoogleFonts.poppins(fontSize: 14.sp, fontWeight: FontWeight.w600),
                        ),
                        SizedBox(height: 8.h),
                        Wrap(
                          spacing: 8.w,
                          runSpacing: 8.h,
                          children: assetOptions.map((asset) {
                            final selected = (profile['existing_assets'] as List<dynamic>? ?? []).contains(asset);
                            return FilterChip(
                              label: Text(asset),
                              selected: selected,
                              onSelected: (value) {
                                final assets = List<String>.from(profile['existing_assets'] as List<dynamic>? ?? []);
                                if (value) {
                                  if (!assets.contains(asset)) assets.add(asset);
                                } else {
                                  assets.remove(asset);
                                }
                                setState(() {
                                  profile['existing_assets'] = assets;
                                });
                              },
                            );
                          }).toList(),
                        ),
                        SizedBox(height: 16.h),
                        SizedBox(
                          width: double.infinity,
                          height: 48.h,
                          child: ElevatedButton(
                            onPressed: _saveFirstTimeProfileAndFetch,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryGreen,
                              foregroundColor: AppColors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                            ),
                            child: Text(
                              'Next',
                              style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Future<void> _fetchAiSchemes() async {
  //   final profile = context.read<ProfileProvider>().profile;
  //   if (profile == null) return;
  //   setState(() { _isLoading = true; });
  //   try {
  //     final list = await RecommendationService.applicableSchemes(profile: profile);
  //     final converted = list.map((e) => Scheme(
  //       id: e['title'] ?? '',
  //       title: e['title'] ?? '',
  //       description: e['description'] ?? '',
  //       category: (e['category'] ?? 'training').toString(),
  //       state: e['state'] ?? (profile.state ?? ''),
  //       eligibilityTags: (e['eligibilityTags'] as List<dynamic>? ?? const [])
  //           .map((x) => x.toString()).toList(),
  //       steps: (e['steps'] as List<dynamic>? ?? const [])
  //           .map((x) => x.toString()).toList(),
  //     )).toList();
  //     setState(() { _schemes = converted; });
  //   } catch (_) {
  //     // ignore errors and keep current list
  //   } finally {
  //     setState(() { _isLoading = false; });
  //   }
  // }

  Widget _buildLoadingScreen() {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Loading animation
                Container(
                  width: 80.w,
                  height: 80.w,
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.agriculture,
                    color: AppColors.white,
                    size: 40.sp,
                  ),
                ),
                SizedBox(height: 24.h),
                
                // Loading indicator
                SizedBox(
                  width: 40.w,
                  height: 40.w,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryGreen),
                    strokeWidth: 3,
                  ),
                ),
                SizedBox(height: 24.h),
                
                // Loading text
                Text(
                  'Fetching personalized govt. schemes',
                  style: GoogleFonts.poppins(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8.h),
                
                Text(
                  'Please wait while we find the best schemes for you...',
                  style: GoogleFonts.poppins(
                    fontSize: 14.sp,
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.fromLTRB(0, 2.h, 0, 0),
      child: Container(
        padding: EdgeInsets.all(10.w),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(children: [
              IconButton(
                icon: Icon(Icons.arrow_back, color: AppColors.primaryGreen, size: 24.sp),
                onPressed: () => context.go('/home'),
              ),
              SizedBox(width: 8.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Govt Schemes', style: GoogleFonts.poppins(fontSize: 28.sp, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  Text('Personalized recommendations', style: GoogleFonts.poppins(fontSize: 14.sp, color: AppColors.textSecondary)),
                ],
              ),
            ]),
            // Container(
            //   width: 40.w,
            //   height: 40.w,
            //   decoration: BoxDecoration(color: AppColors.primaryGreen, shape: BoxShape.circle),
            //   child: Icon(Icons.info_outline, color: AppColors.white, size: 20.sp),
            // ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchAndChips() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: [BoxShadow(color: AppColors.shadowLight, blurRadius: 8, offset: Offset(0, 4))],
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Search schemes... ',
                prefixIcon: Icon(Icons.search, color: AppColors.textSecondary),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              ),
            ),
          ),
          SizedBox(height: 12.h),
          SizedBox(
            height: 40.h,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _filters.length,
              separatorBuilder: (_, __) => SizedBox(width: 8.w),
              itemBuilder: (context, i) {
                final f = _filters[i];
                final selected = f == _selectedFilter;
                return GestureDetector(
                  onTap: () => setState(() => _selectedFilter = f),
                  child: Container(
                    padding: EdgeInsets.all(5.w),
                    decoration: BoxDecoration(
                      color: selected ? AppColors.primaryGreen : AppColors.white,
                      borderRadius: BorderRadius.circular(20.r),
                      boxShadow: [BoxShadow(color: const Color.fromARGB(255, 85, 85, 85), blurRadius: 4, offset: Offset(0, 2))],
                    ),
                    child: Center(
                      child: Text(
                        f,
                        style: GoogleFonts.poppins(color: selected ? AppColors.white : AppColors.textPrimary, fontSize: 13.sp, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 12.h),
        ],
      ),
    );
  }

  Widget _buildSchemeCard(Scheme s) {
    Color badgeColor = AppColors.info;
    String badge = '🎓 Training';
    if (s.category == 'subsidy') { badgeColor = AppColors.success; badge = '✅ Subsidy'; }
    if (s.category == 'insurance') { badgeColor = AppColors.warning; badge = '🛡 Insurance'; }
    if (s.category == 'loan') { badgeColor = AppColors.secondaryOrange; badge = '💰 Loan'; }

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(16.r), boxShadow: [BoxShadow(color: AppColors.shadowLight, blurRadius: 10, offset: Offset(0, 5))]),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              decoration: BoxDecoration(color: badgeColor.withOpacity(0.1), borderRadius: BorderRadius.circular(6.r)),
              child: Text(badge, style: GoogleFonts.poppins(fontSize: 11.sp, fontWeight: FontWeight.w600, color: badgeColor)),
            ),
            const Spacer(),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              decoration: BoxDecoration(color: AppColors.greyLight, borderRadius: BorderRadius.circular(6.r)),
              child: Text(s.state, style: GoogleFonts.poppins(fontSize: 11.sp, color: AppColors.textSecondary)),
            )
          ]),
          SizedBox(height: 8.h),
          Text(s.title, style: GoogleFonts.poppins(fontSize: 18.sp, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          SizedBox(height: 6.h),
          Text(s.description, maxLines: 3, overflow: TextOverflow.ellipsis, style: GoogleFonts.poppins(fontSize: 14.sp, color: AppColors.textSecondary)),
          SizedBox(height: 12.h),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: () => _showSchemeDetails(s),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGreen, foregroundColor: AppColors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r))),
              child: Text('How to Apply', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
            ),
          )
        ]),
      ),
    );
  }

  void _showSchemeDetails(Scheme s) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16.r))),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 24.h),
          child: SingleChildScrollView(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(child: Text(s.title, style: GoogleFonts.poppins(fontSize: 18.sp, fontWeight: FontWeight.w700))),
                IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close))
              ]),
              SizedBox(height: 8.h),
              Text(s.description, style: GoogleFonts.poppins(fontSize: 14.sp)),
              SizedBox(height: 12.h),
              Text('Eligibility', style: GoogleFonts.poppins(fontSize: 16.sp, fontWeight: FontWeight.w600)),
              SizedBox(height: 8.h),
              Wrap(spacing: 8.w, runSpacing: 8.h, children: s.eligibilityTags.map((e) => Chip(label: Text(e))).toList()),
              SizedBox(height: 12.h),
              Text('Steps to Apply', style: GoogleFonts.poppins(fontSize: 16.sp, fontWeight: FontWeight.w600)),
              SizedBox(height: 8.h),
              ...s.steps.map((st) => Padding(
                padding: EdgeInsets.only(bottom: 6.h),
                child: Row(children: [
                  Container(width: 6.w, height: 6.w, margin: EdgeInsets.only(right: 8.w), decoration: BoxDecoration(color: AppColors.primaryGreen, shape: BoxShape.circle)),
                  Expanded(child: Text(st, style: GoogleFonts.poppins(fontSize: 14.sp)))
                ]),
              )),
              SizedBox(height: 16.h),
              SizedBox(
                width: double.infinity,
                height: 48.h,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGreen, foregroundColor: AppColors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r))),
                  child: Text('Got It', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                ),
              )
            ]),
          ),
        );
      },
    );
  }
}
