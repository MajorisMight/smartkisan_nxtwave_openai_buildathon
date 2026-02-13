// OnboardingScreen: 7-step onboarding UI (in-memory only; single save later)
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../constants/app_colors.dart';
import '../services/session_service.dart';
import 'package:kisan/l10n/app_localizations.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _current = 0;

  // In-memory draft (no persistence yet)
  final _draft = _OnboardingDraft();

  @override
  void initState() {
    super.initState();
    _loadSavedDraft();
  }

  Future<void> _loadSavedDraft() async {
    final map = await SessionService.getOnboardingDraft();
    if (map != null) {
      setState(() {
        _draft.applyFromMap(map);
      });
    }
  }

  // UI helpers
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  final _groupNameController = TextEditingController();

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _otpController.dispose();
    _groupNameController.dispose();
    super.dispose();
  }

  Future<void> _next() async {
    // Only allow up to last step (5, since 6 screens: 0..5)
    if (_current < 5) {
      setState(() => _current++);
      _pageController.animateToPage(
        _current,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
      );
      // save progress
      await SessionService.saveOnboardingDraft(_draft.toMap());
    } else {
      // Finish: persist structured profile and mark onboarding complete
      final map = _draft.toMap();
      //saving to sharedPreferences
      await SessionService.saveOnboardingDraft(map);
      await _saveProfileToSupabase(map);
      await SessionService.setOnboardingComplete(true);
      context.go('/home');
    }
  }

  Future<void> _saveProfileToSupabase(Map<String, dynamic> map) async {
    final client = Supabase.instance.client;
    final user = client.auth.currentUser;
    if (user == null) return;

    await client.from('farmers').upsert({
      'id': user.id,
      'name': (map['name'] ?? '').toString(),
      'language_pref': (map['language'] ?? '').toString(),
      'experience_level': (map['experienceLevel'] ?? '').toString(),
      'social_category': (map['socialCategory'] ?? '').toString(),
      'phone_number': (map['phone'] ?? '').toString(),
    });
  }

  void _back() {
    if (_current > 0) {
      setState(() => _current--);
      _pageController.animateToPage(
        _current,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final List<String> stepTitles = [
      l10n.stepTitleBasicInfo,
      l10n.stepTitleLocation,
      l10n.stepTitleCrops,
      l10n.stepTitleSoilAndWater,
      l10n.stepTitlePastYields,
      l10n.stepTitleFinanceAndFinish,
    ];

    final progress = (_current + 1) / 6.0;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              _buildProgressHeader(
                progress,
                l10n.onboardingStepLabel(_current + 1, 6, stepTitles[_current]),
              ),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _buildStep1BasicInfo(),
                    _buildStep2Location(),
                    // _buildStep3Fields(), // commented out
                    _buildStep4Crops(),
                    _buildStep5SoilWater(),
                    _buildStep6History(),
                    _buildStep7FinanceFinish(),
                  ],
                ),
              ),
              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

  // Header: linear progress + label + language toggle
  Widget _buildProgressHeader(double progress, String label) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.r),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8.h,
                    color: AppColors.primaryGreen,
                    backgroundColor: AppColors.greyLight,
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              IconButton(
                onPressed: () {
                  // Immediate language toggle for onboarding screens only
                  setState(() {
                    _draft.language =
                        _draft.language == 'English' ? 'Hindi' : 'English';
                  });
                },
                icon: Icon(Icons.translate, color: AppColors.textPrimary),
                tooltip: 'Language',
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  // Footer with Back / Next
  Widget _buildFooter() {
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Row(
        children: [
          if (_current > 0)
            SizedBox(
              height: 48.h,
              child: OutlinedButton(
                onPressed: _back,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primaryGreen,
                  side: BorderSide(color: AppColors.primaryGreen),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Text(
                  'Back',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          if (_current > 0) SizedBox(width: 12.w),
          Expanded(child: const SizedBox()),
          SizedBox(
            height: 48.h,
            child: ElevatedButton(
              onPressed: _next,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              // Show "Finish & Go to Dashboard" only on last step
              child: Text(
                _current == 5 ? 'Finish & Go to Dashboard' : 'Next',
                style: GoogleFonts.poppins(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // STEP 1 — Basic Info
  Widget _buildStep1BasicInfo() {
    final l10n = AppLocalizations.of(context)!;

    return _stepContainer(
      title: l10n.tellUsAboutYouTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label(l10n.nameLabel),
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              hintText: l10n.nameHint,
              suffixIcon: Icon(Icons.mic_none, color: AppColors.textSecondary),
              filled: true,
              fillColor: AppColors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            onChanged: (v) => _draft.name = v.trim(),
          ),
          SizedBox(height: 12.h),
          _label(l10n.ageRangeLabel),
          _segmentedChips(
            values: <String>[
              l10n.ageRangeUnder30,
              l10n.ageRange30to55,
              l10n.ageRangeOver55,
            ],
            selected: _draft.ageRange,
            onSelected: (v) => setState(() => _draft.ageRange = v),
          ),
          SizedBox(height: 12.h),
          _label(l10n.preferredLanguageLabel),
          DropdownButtonFormField<String>(
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            initialValue: _draft.language,
            hint: Text(l10n.selectLanguageHint),
            items:
                {
                      'English': l10n.languageEnglish,
                      'Hindi': l10n.languageHindi,
                      'Regional': l10n.languageRegional,
                    }.entries
                    .map(
                      (entry) => DropdownMenuItem(
                        value: entry.key,
                        child: Text(entry.value),
                      ),
                    )
                    .toList(),
            onChanged: (v) => setState(() => _draft.language = v),
          ),
          SizedBox(height: 12.h),
          // _label('Phone number *'),
          // Row(children: [
          //   Expanded(
          //     child: TextField(
          //       controller: _phoneController,
          //       keyboardType: TextInputType.phone,
          //       decoration: InputDecoration(
          //         hintText: '+91 98xxxxxx',
          //         filled: true,
          //         fillColor: AppColors.white,
          //         border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
          //       ),
          //       onChanged: (v) => _draft.phoneNumber = v.trim(),
          //     ),
          //   ),
          //   SizedBox(width: 8.w),
          //   TextButton(
          //     onPressed: () => _openOtpSheet(),
          //     child: Text(_draft.phoneVerified ? 'Verified' : 'Send OTP'),
          //   ),
          // ]),
          // SizedBox(height: 12.h),
          _label(l10n.farmingExperienceLabel),
          DropdownButtonFormField<String>(
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            initialValue: _draft.experienceLevel,
            hint: Text(l10n.selectExperienceHint),
            items:
                {
                      'Beginner <5 yrs': l10n.experienceBeginner,
                      'Intermediate 5–15 yrs': l10n.experienceIntermediate,
                      'Expert >15 yrs': l10n.experienceExpert,
                    }.entries
                    .map(
                      (entry) => DropdownMenuItem(
                        value: entry.key,
                        child: Text(entry.value),
                      ),
                    )
                    .toList(),
            onChanged: (v) => setState(() => _draft.experienceLevel = v),
          ),
          SizedBox(height: 12.h),
          _label(l10n.casteCategoryLabel),
          DropdownButtonFormField<String>(
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            initialValue: _draft.socialCategory,
            hint: Text(l10n.selectCasteHint),
            items:
                {
                      'General': l10n.casteGeneral,
                      'SC': l10n.casteSC,
                      'ST': l10n.casteST,
                      'OBC': l10n.casteOBC,
                      'Other': l10n.casteOther,
                      'Prefer not to say': l10n.castePreferNotToSay,
                    }.entries
                    .map(
                      (entry) => DropdownMenuItem(
                        value: entry.key,
                        child: Text(entry.value),
                      ),
                    )
                    .toList(),
            onChanged: (v) => setState(() => _draft.socialCategory = v),
          ),
        ],
      ),
    );
  }

  // STEP 2 — Location
  Widget _buildStep2Location() {
    final l10n = AppLocalizations.of(context)!;

    return _stepContainer(
      title: l10n.farmLocationTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 44.h,
            child: OutlinedButton.icon(
              onPressed: _useGps,
              icon: const Icon(Icons.my_location),
              label: Text(l10n.useMyLocationButton),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: AppColors.primaryGreen),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            ),
          ),
          SizedBox(height: 8.h),
          if (_draft.gpsLat != null && _draft.gpsLon != null)
            Container(
              width: double.infinity,
              height: 120.h,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12.r),
              ),
              alignment: Alignment.center,
              child: Text(
                l10n.mapPreviewPlaceholder(
                  _draft.gpsLat!.toStringAsFixed(3),
                  _draft.gpsLon!.toStringAsFixed(3),
                ),
              ),
            ),
          SizedBox(height: 12.h),
          _label(l10n.tehsilLabel),
          TextField(
            decoration: InputDecoration(
              hintText: l10n.villageTownHint,
              filled: true,
              fillColor: AppColors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            onChanged: (v) => _draft.village = v.trim(),
          ),
          SizedBox(height: 10.h),
          _label(l10n.stateLabel),
          _searchableDropdown(
            hint: _draft.state ?? l10n.selectStateHint,
            value: _draft.state,
            options: _stateOptions,
            onSelected:
                (v) => setState(() {
                  _draft.state = v;
                  _draft.district = null;
                }),
          ),
          SizedBox(height: 10.h),
          _label(l10n.districtLabel),
          _searchableDropdown(
            hint: _draft.district ?? l10n.selectDistrictHint,
            value: _draft.district,
            options: _districtOptionsFor(_draft.state),
            onSelected: (v) => setState(() => _draft.district = v),
          ),

          SizedBox(height: 12.h),
          _label(l10n.totalFarmAreaLabel),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextField(
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: l10n.farmAreaHint,
                    filled: true,
                    fillColor: AppColors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  onChanged: (v) => _draft.totalArea = double.tryParse(v),
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: _searchableDropdown(
                  hint: _draft.areaUnit,
                  value: _draft.areaUnit,
                  options: ['acre', 'hectare'],
                  onSelected: (v) => setState(() => _draft.areaUnit = v),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          // Wrap(spacing: 8.w, children: [0.25, 0.5, 1, 2].map((e) {
          //   return ChoiceChip(
          //     label: Text('$e'),
          //     selected: _draft.totalArea == e,
          //     onSelected: (_) => setState(() => _draft.totalArea = e.toDouble()),
          //   );
          // }).toList()),
          SizedBox(height: 12.h),
          _label(l10n.waterSourceLabel),
          _multiSelectChips(
            options: {
              'Canal': l10n.waterSourceCanal,
              'Tube well': l10n.waterSourceBorewell,
              'Open well': l10n.waterSourceWell,
              'River': l10n.waterSourceRiver,
              'Rainfed': l10n.waterSourceRainfed,
            },
            selected: _draft.waterSources,
            onChanged: (list) => setState(() => _draft.waterSources = list),
          ),
          SizedBox(height: 12.h),
          // _label('Equipment owned (optional)'),
          // _multiSelectChips(
          //   options: const ['Tractor', 'Pump', 'Sprayer', 'None'],
          //   selected: _draft.equipment,
          //   onChanged: (list) => setState(() => _draft.equipment = list),
          // ),
          SizedBox(height: 12.h),
          _label('Farmer group / Co-op membership'),
          Row(
            children: [
              ChoiceChip(
                label: const Text('Yes'),
                selected: _draft.isMember == true,
                onSelected: (_) => setState(() => _draft.isMember = true),
              ),
              SizedBox(width: 8.w),
              ChoiceChip(
                label: const Text('No'),
                selected: _draft.isMember == false,
                onSelected: (_) => setState(() => _draft.isMember = false),
              ),
            ],
          ),
          if (_draft.isMember == true) ...[
            SizedBox(height: 8.h),
            TextField(
              controller: _groupNameController,
              decoration: InputDecoration(
                hintText: 'Name of group',
                filled: true,
                fillColor: AppColors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              onChanged: (v) => _draft.groupName = v.trim(),
            ),
          ],
        ],
      ),
    );
  }

  // STEP 3 — Fields (repeatable)
  // ignore: unused_element
  Widget _buildStep3Fields() {
    return _stepContainer(
      title: 'Fields',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Add your fields for per-field advice',
                style: GoogleFonts.poppins(
                  fontSize: 12.sp,
                  color: AppColors.textSecondary,
                ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: _openAddOrEditFieldSheet,
                icon: const Icon(Icons.add),
                label: const Text('Add Field'),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          if (_draft.fields.isEmpty)
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Text(
                'No fields added yet',
                style: GoogleFonts.poppins(color: AppColors.textSecondary),
              ),
            ),
          ..._draft.fields.asMap().entries.map((e) {
            final i = e.key;
            final f = e.value;
            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Padding(
                padding: EdgeInsets.all(12.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if ((f['photos'] as List?) != null &&
                            (f['photos'] as List).isNotEmpty)
                          Container(
                            width: 56.w,
                            height: 56.w,
                            margin: EdgeInsets.only(right: 8.w),
                            clipBehavior: Clip.antiAlias,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8.r),
                              color: AppColors.greyLight,
                            ),
                            child: Image.asset(
                              ((f['photos'] as List).first as String),
                              fit: BoxFit.cover,
                            ),
                          ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${f['name'] ?? 'Field'} • ${f['area'] ?? '-'} ${f['unit'] ?? ''}',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                'Stage: ${f['crop_stage'] ?? '-'}',
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
                    SizedBox(height: 6.h),
                    Wrap(
                      spacing: 8.w,
                      runSpacing: 6.h,
                      children: [
                        _fieldChip('Soil: ${f['soil_type'] ?? '-'}'),
                        _fieldChip('Irrig: ${f['irrigation_type'] ?? '-'}'),
                        if (f['primary_crop'] != null)
                          _fieldChip('Crop: ${f['primary_crop']}'),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    Row(
                      children: [
                        TextButton.icon(
                          onPressed: () => _openAddOrEditFieldSheet(index: i),
                          icon: const Icon(Icons.edit),
                          label: const Text('Edit'),
                        ),
                        TextButton.icon(
                          onPressed:
                              () => setState(() => _draft.fields.removeAt(i)),
                          icon: const Icon(Icons.delete_outline),
                          label: const Text('Remove'),
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
    );
  }

  // STEP 4 — Crops & Practices
  Widget _buildStep4Crops() {
    return _stepContainer(
      title: 'Crops & Practices',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label('Primary crops (multi-select)'),
          _cropGridMultiSelect(
            options: const [
              'Wheat',
              'Moong',
              'Isabogl',
              'Mustard',
              'Groundnut',
              'Cotton',
            ],
            selected: _draft.crops.map((e) => e['crop_id'] as String).toList(),
            onTapped: (crop) {
              final idx = _draft.crops.indexWhere((c) => c['crop_id'] == crop);
              if (idx >= 0) {
                setState(() => _draft.crops.removeAt(idx));
              } else {
                setState(
                  () => _draft.crops.add({
                    'crop_id': crop,
                    'sowing_month': null,
                    'variety': null,
                    'expected_area': null,
                    'previous_crop': null,
                    'common_pests': <String>[],
                  }),
                );
              }
            },
          ),
          SizedBox(height: 12.h),
          ..._draft.crops.asMap().entries.map((e) {
            final i = e.key;
            final c = e.value;
            return ExpansionTile(
              title: Text(
                c['crop_id'] ?? '-',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(12.w, 0, 12.w, 12.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Change label and dropdown for field status
                      _label('Current Status of Field'),
                      _searchableDropdown(
                        hint: c['field_status'] ?? 'Select',
                        value: c['field_status'],
                        options: const [
                          'Preparing',
                          'Sowing',
                          'Growing',
                          'Harvesting',
                        ],
                        onSelected:
                            (v) => setState(
                              () => _draft.crops[i]['field_status'] = v,
                            ),
                      ),
                      SizedBox(height: 10.h),
                      // _label('Seed variety'),
                      // Autocomplete<String>(
                      //   optionsBuilder: (text) {
                      //     final crop = (c['crop_id'] as String?) ?? '';
                      //     final all = _varietyOptions[crop] ?? const <String>[];
                      //     final q = text.text.toLowerCase();
                      //     if (q.isEmpty) return all;
                      //     return all.where((v) => v.toLowerCase().contains(q));
                      //   },
                      //   onSelected: (val) => setState(() => _draft.crops[i]['variety'] = val),
                      //   fieldViewBuilder: (ctx, controller, focus, onSubmit) {
                      //     return TextField(
                      //       controller: controller,
                      //       focusNode: focus,
                      //       decoration: _inputDecoration('Type to search or enter custom'),
                      //       onChanged: (v) => _draft.crops[i]['variety'] = v.trim(),
                      //     );
                      //   },
                      // ),
                      // SizedBox(height: 10.h),
                      _label('Expected acreage for this crop'),
                      TextField(
                        keyboardType: TextInputType.number,
                        decoration: _inputDecoration('e.g., 1.5'),
                        onChanged:
                            (v) =>
                                _draft.crops[i]['expected_area'] =
                                    double.tryParse(v),
                      ),
                      SizedBox(height: 10.h),
                      _label('Previous crop (last season)'),
                      _searchableDropdown(
                        hint: c['previous_crop'] ?? 'Select',
                        value: c['previous_crop'],
                        options: _previousCropOptionsFor(c['crop_id'] ?? ''),
                        onSelected:
                            (v) => setState(
                              () => _draft.crops[i]['previous_crop'] = v,
                            ),
                      ),
                      SizedBox(height: 10.h),
                      // _label('Common pests/diseases'),
                      // Wrap(spacing: 8.w, runSpacing: 8.h, children: [
                      //   ...['Blight','Aphids','Rust','None'].map((p) {
                      //     final icons = {'Blight': Icons.bug_report_outlined, 'Aphids': Icons.bug_report, 'Rust': Icons.energy_savings_leaf_outlined, 'None': Icons.block};
                      //     final selected = ((c['common_pests'] as List?) ?? const <String>[]).contains(p);
                      //     return FilterChip(
                      //       avatar: Icon(icons[p] ?? Icons.sick_outlined, size: 16),
                      //       label: Text(p),
                      //       selected: selected,
                      //       onSelected: (sel) {
                      //         final list = List<String>.from((c['common_pests'] as List?) ?? const <String>[]);
                      //         if (sel && !list.contains(p)) list.add(p);
                      //         if (!sel) list.remove(p);
                      //         setState(() => _draft.crops[i]['common_pests'] = list);
                      //       },
                      //     );
                      //   }).toList(),
                      //   ActionChip(
                      //     avatar: const Icon(Icons.add),
                      //     label: const Text('Add Other'),
                      //     onPressed: () async {
                      //       final other = await _promptText('Add pest/disease');
                      //       if (other != null && other.isNotEmpty) {
                      //         final list = List<String>.from((c['common_pests'] as List?) ?? const <String>[])..add(other);
                      //         setState(() => _draft.crops[i]['common_pests'] = list);
                      //       }
                      //     },
                      //   ),
                      // ]),
                    ],
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  // STEP 5 — Soil & Water
  Widget _buildStep5SoilWater() {
    return _stepContainer(
      title: 'Soil & Water Reports',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label('Soil test report (optional)'),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.upload),
                  label: const Text('Upload Photo / PDF'),
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed:
                      () => setState(() => _draft.manualSoilEntry = true),
                  icon: const Icon(Icons.edit),
                  label: const Text('Enter Manually'),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          if (_draft.manualSoilEntry) ...[
            _label('N (ppm)'),
            TextField(
              keyboardType: TextInputType.number,
              decoration: _inputDecoration('e.g., 120'),
              onChanged: (v) => _draft.soilTest['N'] = double.tryParse(v),
            ),
            SizedBox(height: 8.h),
            _label('P (ppm)'),
            TextField(
              keyboardType: TextInputType.number,
              decoration: _inputDecoration('e.g., 18'),
              onChanged: (v) => _draft.soilTest['P'] = double.tryParse(v),
            ),
            SizedBox(height: 8.h),
            _label('K (ppm)'),
            TextField(
              keyboardType: TextInputType.number,
              decoration: _inputDecoration('e.g., 200'),
              onChanged: (v) => _draft.soilTest['K'] = double.tryParse(v),
            ),
            SizedBox(height: 8.h),
            _label('pH (1–14)'),
            TextField(
              keyboardType: TextInputType.number,
              decoration: _inputDecoration('e.g., 6.8'),
              onChanged: (v) => _draft.soilTest['pH'] = double.tryParse(v),
            ),
            SizedBox(height: 8.h),
            _label('Organic matter %'),
            TextField(
              keyboardType: TextInputType.number,
              decoration: _inputDecoration('e.g., 1.5'),
              onChanged:
                  (v) => _draft.soilTest['organic_matter'] = double.tryParse(v),
            ),
            SizedBox(height: 8.h),
            _label('Last soil test date'),
            TextField(
              decoration: _inputDecoration('YYYY-MM-DD'),
              onChanged: (v) => _draft.soilTest['date'] = v.trim(),
            ),
          ],
          SizedBox(height: 12.h),
          _label('Water quality'),
          Row(
            children: [
              Expanded(
                child: _searchableDropdown(
                  hint: _draft.waterQuality['salinity'] ?? 'Salinity',
                  value: _draft.waterQuality['salinity'],
                  options: const ['Low', 'Medium', 'High'],
                  onSelected:
                      (v) =>
                          setState(() => _draft.waterQuality['salinity'] = v),
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: TextField(
                  keyboardType: TextInputType.number,
                  decoration: _inputDecoration('Water pH'),
                  onChanged:
                      (v) => _draft.waterQuality['pH'] = double.tryParse(v),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Checkbox(
                value: _draft.wantSoilKit ?? false,
                onChanged:
                    (v) => setState(() => _draft.wantSoilKit = v ?? false),
              ),
              Text('Book for soil test?', style: GoogleFonts.poppins()),
            ],
          ),
        ],
      ),
    );
  }

  // STEP 6 — History
  Widget _buildStep6History() {

    final l10n = AppLocalizations.of(context)!;

    return _stepContainer(
      title: 'Historical Data & Past Yields',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ..._draft.crops.map((c) {
            final id = c['crop_id'] as String;
            return Padding(
              padding: EdgeInsets.only(bottom: 10.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _label('Last season yield — $id'),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          keyboardType: TextInputType.number,
                          decoration: _inputDecoration('Value'),
                          onChanged:
                              (v) =>
                                  _draft.lastSeasonYields[id] =
                                      double.tryParse(v) ?? 0,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: _searchableDropdown(
                          hint: (_draft.yieldUnit[id]) ?? 'Unit',
                          value: _draft.yieldUnit[id],
                          options: const ['kg/acre', 'quintal/acre'],
                          onSelected:
                              (v) => setState(() => _draft.yieldUnit[id] = v),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  // New: Planning for this year
                  _label(
                    'What are you planning to grow this year on that place?',
                  ),
                  _searchableDropdown(
                    hint: c['planned_crop'] ?? 'Select crop',
                    value: c['planned_crop'],
                    options: const [
                      'Wheat',
                      'Moong',
                      'Isabogl',
                      'Mustard',
                      'Groundnut',
                      'Cotton',
                      'Nothing',
                    ],
                    onSelected: (v) => setState(() => c['planned_crop'] = v),
                  ),
                ],
              ),
            );
          }),
          SizedBox(height: 12.h),
          _label('Previous inputs (optional)'),
          _multiSelectChips(
            options: {'Urea': l10n.inputUrea, 'DAP': l10n.inputDAP, 'NPKBlends': l10n.inputNPKBlends, 'Imidacloprid': l10n.inputImidacloprid, 'Mancozed': l10n.inputMancozeb, },
            selected: _draft.pastInputs,
            onChanged: (list) => setState(() => _draft.pastInputs = list),
          ),
          SizedBox(height: 12.h),
          _label('Historical weather impacts (optional)'),
          _multiSelectChips(
            options: {'Drought': l10n.impactDrought, 'Flood': l10n.impactFlood, 'PestAttack': l10n.impactPestOutbreak, 'Heatwave': l10n.impactHeatwave, },
            selected: _draft.historicalImpacts,
            onChanged:
                (list) => setState(() => _draft.historicalImpacts = list),
          ),
          SizedBox(height: 12.h),
          _label('Upload past farm photos or diary scans (optional)'),
          OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.photo_library_outlined),
            label: const Text('Select from gallery'),
          ),
          SizedBox(height: 12.h),
          _label('Government schemes last season?'),
          Row(
            children: [
              ChoiceChip(
                label: const Text('Yes'),
                selected: _draft.usedSchemes == true,
                onSelected: (_) => setState(() => _draft.usedSchemes = true),
              ),
              SizedBox(width: 8.w),
              ChoiceChip(
                label: const Text('No'),
                selected: _draft.usedSchemes == false,
                onSelected: (_) => setState(() => _draft.usedSchemes = false),
              ),
            ],
          ),
          if (_draft.usedSchemes == true) ...[
            SizedBox(height: 8.h),
            TextField(
              decoration: _inputDecoration('Which schemes?'),
              onChanged:
                  (v) =>
                      _draft.participatedSchemes =
                          v
                              .split(',')
                              .map((e) => e.trim())
                              .where((e) => e.isNotEmpty)
                              .toList(),
            ),
          ],
        ],
      ),
    );
  }

  // STEP 7 — Finance & Finish
  Widget _buildStep7FinanceFinish() {
    return _stepContainer(
      title: 'Finance & Finish',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label('Bank account linked?'),
          Row(
            children: [
              ChoiceChip(
                label: const Text('Yes'),
                selected: _draft.hasBankAccount == true,
                onSelected: (_) => setState(() => _draft.hasBankAccount = true),
              ),
              SizedBox(width: 8.w),
              ChoiceChip(
                label: const Text('No'),
                selected: _draft.hasBankAccount == false,
                onSelected:
                    (_) => setState(() => _draft.hasBankAccount = false),
              ),
            ],
          ),
          if (_draft.hasBankAccount == true) ...[
            SizedBox(height: 8.h),
            TextField(
              decoration: _inputDecoration('Bank name (optional)'),
              onChanged: (v) => _draft.bankName = v.trim(),
            ),
          ],
          SizedBox(height: 12.h),
          _label('Crop insurance enrolled?'),
          Row(
            children: [
              ChoiceChip(
                label: const Text('Yes'),
                selected: _draft.hasInsurance == true,
                onSelected: (_) => setState(() => _draft.hasInsurance = true),
              ),
              SizedBox(width: 8.w),
              ChoiceChip(
                label: const Text('No'),
                selected: _draft.hasInsurance == false,
                onSelected: (_) => setState(() => _draft.hasInsurance = false),
              ),
            ],
          ),
          if (_draft.hasInsurance == true) ...[
            SizedBox(height: 8.h),
            TextField(
              decoration: _inputDecoration('Provider (optional)'),
              onChanged: (v) => _draft.insuranceProvider = v.trim(),
            ),
          ],
          SizedBox(height: 12.h),
          _label('Annual farm income range'),
          _searchableDropdown(
            hint: _draft.incomeBracket ?? 'Select',
            value: _draft.incomeBracket,
            options: const ['Low <₹1L', 'Medium ₹1–5L', 'High >₹5L'],
            onSelected: (v) => setState(() => _draft.incomeBracket = v),
          ),
          SizedBox(height: 12.h),
          _label('Preferred payment method'),
          _searchableDropdown(
            hint: _draft.preferredPayment ?? 'Select',
            value: _draft.preferredPayment,
            options: const ['UPI', 'COD', 'Wallet'],
            onSelected: (v) => setState(() => _draft.preferredPayment = v),
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Checkbox(
                value: _draft.consentAnalytics,
                onChanged:
                    (v) => setState(() => _draft.consentAnalytics = v ?? false),
              ),
              Expanded(
                child: Text(
                  'Receive AI suggestions & upload anonymized data to improve recommendations.',
                  style: GoogleFonts.poppins(fontSize: 12.sp),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          // Summary card (condensed)
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Summary',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
                ),
                SizedBox(height: 8.h),
                // Fields = number of crops selected
                _summaryRow('Fields', '${_draft.crops.length}'),
                // Acreage for each crop
                ..._draft.crops.map((c) {
                  final cropName = c['crop_id'] ?? '-';
                  final area =
                      c['expected_area'] != null
                          ? '${c['expected_area']} ${_draft.areaUnit}'
                          : '-';
                  return _summaryRow('$cropName acreage', area);
                }),
                _summaryRow(
                  'Primary crops',
                  _draft.crops.map((e) => e['crop_id']).join(', '),
                ),
                _summaryRow(
                  'Total area',
                  _draft.totalArea != null
                      ? '${_draft.totalArea} ${_draft.areaUnit}'
                      : '-',
                ),
                _summaryRow(
                  'Soil test',
                  _draft.manualSoilEntry || (_draft.soilTest.isNotEmpty)
                      ? 'Present'
                      : 'Absent',
                ),
                _summaryRow(
                  'Bank',
                  _draft.hasBankAccount == true ? 'Yes' : 'No',
                ),
                _summaryRow(
                  'Insurance',
                  _draft.hasInsurance == true ? 'Yes' : 'No',
                ),
              ],
            ),
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Checkbox(
                value: _draft.termsAccepted,
                onChanged:
                    (v) => setState(() => _draft.termsAccepted = v ?? false),
              ),
              Expanded(
                child: Text(
                  'I agree to terms & privacy',
                  style: GoogleFonts.poppins(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Common step container
  Widget _stepContainer({required String title, required Widget child}) {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 8.h),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 12.h),
          Expanded(child: SingleChildScrollView(child: child)),
        ],
      ),
    );
  }

  // UI helpers
  InputDecoration _inputDecoration(String hint) => InputDecoration(
    hintText: hint,
    filled: true,
    fillColor: AppColors.white,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
  );

  Widget _label(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6.h),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 12.sp,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _summaryRow(String title, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6.h),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 13.sp,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _segmentedChips({
    required List<String> values,
    required String? selected,
    required ValueChanged<String> onSelected,
  }) {
    return Wrap(
      spacing: 8.w,
      children:
          values.map((v) {
            final sel = v == selected;
            return ChoiceChip(
              label: Text(v),
              selected: sel,
              onSelected: (_) => onSelected(v),
            );
          }).toList(),
    );
  }

  Widget _multiSelectChips({
    // MODIFIED: 'options' is now a Map of stable keys to translated display text.
    required Map<String, String> options,
    // 'selected' will now store the stable keys, e.g., ["river", "well"].
    required List<String> selected,
    required ValueChanged<List<String>> onChanged,
  }) {
    return Wrap(
      spacing: 8.w,
      runSpacing: 8.h,
      // MODIFIED: Iterate over the map's entries.
      children:
          options.entries.map((entry) {
            final key = entry.key;
            final value = entry.value;

            // MODIFIED: Selection is checked against the key.
            final isSelected = selected.contains(key);

            return FilterChip(
              // MODIFIED: The label shows the translated value.
              label: Text(value),
              selected: isSelected,
              onSelected: (bool wasSelected) {
                final updatedSelection = [...selected];
                if (wasSelected) {
                  // MODIFIED: Add the key to the list.
                  updatedSelection.add(key);
                } else {
                  // MODIFIED: Remove the key from the list.
                  updatedSelection.remove(key);
                }
                onChanged(updatedSelection);
              },
            );
          }).toList(),
    );
  }

  // Icon choice chips
  Widget _iconSelectChips({
    required Map<String, IconData> options,
    required String? selected,
    required ValueChanged<String> onSelected,
  }) {
    return Wrap(
      spacing: 8.w,
      runSpacing: 8.h,
      children:
          options.entries.map((e) {
            final isSel = e.key == selected;
            return ChoiceChip(
              avatar: Icon(
                e.value,
                size: 16,
                color: isSel ? AppColors.white : AppColors.textSecondary,
              ),
              label: Text(e.key),
              selected: isSel,
              onSelected: (_) => onSelected(e.key),
            );
          }).toList(),
    );
  }

  // Crop stage selector (progress-like)
  Widget _stageSelector({
    required List<String> stages,
    required String? selected,
    required ValueChanged<String> onSelected,
  }) {
    final icons = <String, IconData>{
      'Preparation': Icons.plumbing,
      'Sowing': Icons.grass,
      'Growth': Icons.eco_outlined,
      'Harvest': Icons.agriculture,
      'Fallow': Icons.pause_circle_outline,
    };
    return Row(
      children:
          stages.map((s) {
            final sel = s == selected;
            return Expanded(
              child: GestureDetector(
                onTap: () => onSelected(s),
                child: Container(
                  margin: EdgeInsets.only(right: 6.w),
                  padding: EdgeInsets.symmetric(vertical: 10.h),
                  decoration: BoxDecoration(
                    color: sel ? AppColors.primaryGreen : AppColors.white,
                    borderRadius: BorderRadius.circular(10.r),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.shadowLight,
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Icon(
                        icons[s] ?? Icons.check_circle_outline,
                        color: sel ? AppColors.white : AppColors.textPrimary,
                        size: 18.sp,
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        s,
                        style: GoogleFonts.poppins(
                          fontSize: 11.sp,
                          color: sel ? AppColors.white : AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
    );
  }

  Widget _cropGridMultiSelect({
    required List<String> options,
    required List<String> selected,
    required ValueChanged<String> onTapped,
  }) {
    imageFor(String name) {
      switch (name) {
        case 'Wheat':
          return 'assets/images/wheat.jpg';
        case 'Cotton':
          return 'assets/images/cotton.jpg';
        case 'Groundnut':
          return 'assets/images/groundnut.jpg';
        case 'Moong':
          return 'assets/images/moong.jpeg';
        case 'Mustard':
          return 'assets/images/Mustard.jpeg';
        case 'Isabgol':
          return 'assets/images/Isabgol.jpeg';
        default:
          return null;
      }
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 8.h,
        crossAxisSpacing: 8.w,
        childAspectRatio: 0.9,
      ),
      itemCount: options.length,
      itemBuilder: (context, i) {
        final name = options[i];
        final isSel = selected.contains(name);
        final img = imageFor(name);
        return GestureDetector(
          onTap: () => onTapped(name),
          child: Container(
            decoration: BoxDecoration(
              color: isSel ? AppColors.primaryGreen : AppColors.white,
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadowLight,
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 40.h,
                  child:
                      img != null
                          ? Image.asset(img, fit: BoxFit.contain)
                          : Icon(
                            Icons.agriculture,
                            color:
                                isSel ? AppColors.white : AppColors.textPrimary,
                          ),
                ),
                SizedBox(height: 6.h),
                Text(
                  name,
                  style: GoogleFonts.poppins(
                    color: isSel ? AppColors.white : AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _fieldChip(String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(text, style: GoogleFonts.poppins(fontSize: 12.sp)),
    );
  }

  // Searchable dropdown as full-screen bottom sheet
  Widget _searchableDropdown({
    required String hint,
    required String? value,
    required List<String> options,
    required ValueChanged<String> onSelected,
    bool enabled = true,
  }) {
    return GestureDetector(
      onTap:
          !enabled
              ? null
              : () async {
                final sel = await _openSearchSheet(
                  hint: hint,
                  options: options,
                  initial: value,
                );
                if (sel != null) onSelected(sel);
              },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: enabled ? AppColors.white : AppColors.greyLight,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowLight,
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(Icons.keyboard_arrow_down, color: AppColors.textSecondary),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                value ?? hint,
                style: GoogleFonts.poppins(
                  color:
                      value == null
                          ? AppColors.textSecondary
                          : AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<String?> _openSearchSheet({
    required String hint,
    required List<String> options,
    String? initial,
  }) async {
    final controller = TextEditingController();
    List<String> results = List.of(options);
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 24.h),
          child: StatefulBuilder(
            builder: (context, setStateSheet) {
              void filter(String q) {
                final lower = q.toLowerCase();
                results =
                    options
                        .where((o) => o.toLowerCase().contains(lower))
                        .toList();
                setStateSheet(() {});
              }

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: controller,
                    onChanged: filter,
                    decoration: InputDecoration(
                      hintText: hint,
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: AppColors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                  ),
                  SizedBox(height: 12.h),
                  SizedBox(
                    height: 300.h,
                    child: ListView.builder(
                      itemCount: results.length,
                      itemBuilder: (context, i) {
                        final item = results[i];
                        return ListTile(
                          leading: const Icon(Icons.checklist),
                          title: _highlightMatch(item, controller.text),
                          onTap: () => Navigator.pop(context, item),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Widget _highlightMatch(String text, String query) {
    if (query.isEmpty) return Text(text);
    final lower = text.toLowerCase();
    final q = query.toLowerCase();
    final start = lower.indexOf(q);
    if (start == -1) return Text(text);
    final end = start + q.length;
    return RichText(
      text: TextSpan(
        style: GoogleFonts.poppins(color: AppColors.textPrimary),
        children: [
          TextSpan(text: text.substring(0, start)),
          TextSpan(
            text: text.substring(start, end),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          TextSpan(text: text.substring(end)),
        ],
      ),
    );
  }

  // GPS -> fills state/district if available
  Future<void> _useGps() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        return;
      }
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      final placemarks = await placemarkFromCoordinates(
        pos.latitude,
        pos.longitude,
      );
      setState(() {
        _draft.gpsLat = pos.latitude;
        _draft.gpsLon = pos.longitude;
        if (placemarks.isNotEmpty) {
          _draft.state = placemarks.first.administrativeArea;
          _draft.district = placemarks.first.subAdministrativeArea;
        }
      });
    } catch (_) {}
  }

  // Field add/edit bottom sheet
  // Field add/edit bottom sheet — 3-step wizard
  Future<void> _openAddOrEditFieldSheet({int? index}) async {
    final isEdit = index != null;
    final existing =
        (index != null)
            ? Map<String, dynamic>.from(_draft.fields[index])
            : <String, dynamic>{};

    String name = existing['name'] ?? '';
    String unit = existing['unit'] ?? _draft.areaUnit;
    String area = existing['area']?.toString() ?? '';
    String? soil = existing['soil_type'];
    String? irrig = existing['irrigation_type'];
    String? stage = existing['crop_stage'];
    String? primaryCrop = existing['primary_crop'];
    List<String> photos = List<String>.from(
      existing['photos'] ?? const <String>[],
    );

    int step = 0;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheet) {
            void next() => setSheet(() => step = (step + 1).clamp(0, 2));
            void back() => setSheet(() => step = (step - 1).clamp(0, 2));

            Widget stepBody() {
              if (step == 0) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isEdit ? 'Edit Field — Step 1/3' : 'Add Field — Step 1/3',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w700,
                        fontSize: 16.sp,
                      ),
                    ),
                    SizedBox(height: 10.h),
                    _label('Nickname *'),
                    TextField(
                      decoration: _inputDecoration('e.g., Field A'),
                      controller: TextEditingController(text: name),
                      onChanged: (v) => name = v.trim(),
                    ),
                    SizedBox(height: 10.h),
                    _label('Area & unit'),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            keyboardType: TextInputType.number,
                            decoration: _inputDecoration('Area'),
                            controller: TextEditingController(text: area),
                            onChanged: (v) => area = v,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: _searchableDropdown(
                            hint: unit,
                            value: unit,
                            options: const ['acre', 'hectare'],
                            onSelected: (v) => unit = v,
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              }
              if (step == 1) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isEdit ? 'Edit Field — Step 2/3' : 'Add Field — Step 2/3',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w700,
                        fontSize: 16.sp,
                      ),
                    ),
                    SizedBox(height: 10.h),
                    _label('Soil type'),
                    _iconSelectChips(
                      options: const {
                        'Loam': Icons.landscape,
                        'Sandy': Icons.grain,
                        'Clay': Icons.terrain,
                        'Silt': Icons.filter_hdr,
                        'Unknown': Icons.help_outline,
                      },
                      selected: soil,
                      onSelected: (v) => setSheet(() => soil = v),
                    ),
                    SizedBox(height: 10.h),
                    _label('How do you water your field?'),
                    _iconSelectChips(
                      options: const {
                        'Drip': Icons.waterfall_chart,
                        'Sprinkler':
                            Icons
                                .grass, // replace with better spray icon if available
                        'Flood': Icons.waves,
                        'None': Icons.block,
                      },
                      selected: irrig,
                      onSelected: (v) => setSheet(() => irrig = v),
                    ),
                    SizedBox(height: 10.h),
                    _label('Current crop stage'),
                    _stageSelector(
                      stages: const [
                        'Preparation',
                        'Sowing',
                        'Growth',
                        'Harvest',
                        'Fallow',
                      ],
                      selected: stage,
                      onSelected: (v) => setSheet(() => stage = v),
                    ),
                  ],
                );
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isEdit ? 'Edit Field — Step 3/3' : 'Add Field — Step 3/3',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w700,
                      fontSize: 16.sp,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      OutlinedButton.icon(
                        onPressed: () {
                          /* TODO: polygon draw */
                        },
                        icon: const Icon(Icons.map_outlined),
                        label: const Text('Draw on map'),
                      ),
                      SizedBox(width: 8.w),
                      OutlinedButton.icon(
                        onPressed: () {
                          /* TODO: add photos */
                        },
                        icon: const Icon(Icons.photo_camera_outlined),
                        label: const Text('Add photos'),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  _label('Primary crop (optional)'),
                  _searchableDropdown(
                    hint: primaryCrop ?? 'Select',
                    value: primaryCrop,
                    options: const [
                      'Wheat',
                      'Barley',
                      'Moong',
                      'Isabogl',
                      'Mustard',
                      'Groundnut',
                      'Cotton',
                    ],
                    onSelected: (v) => setSheet(() => primaryCrop = v),
                  ),
                  SizedBox(height: 12.h),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Confirmation',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 6.h),
                        _summaryRow('Name', name.isEmpty ? '-' : name),
                        _summaryRow('Area', area.isEmpty ? '-' : '$area $unit'),
                        _summaryRow('Soil', soil ?? '-'),
                        _summaryRow('Irrigation', irrig ?? '-'),
                        _summaryRow('Stage', stage ?? '-'),
                        _summaryRow('Primary crop', primaryCrop ?? '-'),
                      ],
                    ),
                  ),
                ],
              );
            }

            return Padding(
              padding: EdgeInsets.fromLTRB(
                16.w,
                16.h,
                16.w,
                MediaQuery.of(context).viewInsets.bottom + 16.h,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  stepBody(),
                  SizedBox(height: 12.h),
                  Row(
                    children: [
                      if (step > 0)
                        OutlinedButton(
                          onPressed: back,
                          style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                          ),
                          child: const Text('Back'),
                        ),
                      if (step > 0) SizedBox(width: 8.w),
                      Expanded(child: const SizedBox()),
                      ElevatedButton(
                        onPressed: () {
                          if (step < 2) {
                            if (step == 0) {
                              final val = double.tryParse(area);
                              if (name.isEmpty || val == null || val <= 0) {
                                return;
                              }
                            }
                            next();
                          } else {
                            final val = double.tryParse(area);
                            if (name.isEmpty || val == null || val <= 0) return;
                            final data = {
                              'id':
                                  isEdit
                                      ? existing['id']
                                      : 'field_${DateTime.now().millisecondsSinceEpoch}',
                              'name': name,
                              'area': val,
                              'unit': unit,
                              'polygon': existing['polygon'],
                              'soil_type': soil,
                              'irrigation_type': irrig,
                              'crop_stage': stage,
                              'photos': photos,
                              'primary_crop': primaryCrop,
                            };
                            setState(() {
                              if (index != null) {
                                _draft.fields[index] = data;
                              } else {
                                _draft.fields.add(data);
                              }
                            });
                            Navigator.pop(context);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryGreen,
                          foregroundColor: AppColors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                        child: Text(
                          step < 2 ? 'Next' : (isEdit ? 'Save' : 'Add Field'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // OTP bottom sheet (UI only)
  // ignore: unused_element
  Future<void> _openOtpSheet() async {
    _otpController.clear();
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            16.w,
            16.h,
            16.w,
            MediaQuery.of(context).viewInsets.bottom + 16.h,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Verify Phone',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
              ),
              SizedBox(height: 10.h),
              TextField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                decoration: _inputDecoration('Enter OTP'),
              ),
              SizedBox(height: 12.h),
              SizedBox(
                width: double.infinity,
                height: 48.h,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() => _draft.phoneVerified = true);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    foregroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: const Text('Verify'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Mock cascading location data
  List<String> get _stateOptions => [
    'Punjab',
    'Maharashtra',
    'Haryana',
    'Rajasthan',
    'Gujarat',
    'UP',
  ];
  List<String> _districtOptionsFor(String? state) {
    if (state == 'Punjab') return ['Ludhiana', 'Amritsar'];
    if (state == 'Maharashtra') return ['Pune', 'Nashik'];
    if (state == 'Haryana') return ['Karnal', 'Hisar'];
    if (state == 'Rajasthan') return ['Jaipur', 'Bikaner'];
    return [];
  }

  // Smart defaults for sowing months and previous crop
  // ignore: unused_element
  List<String> _orderedMonthsFor(String crop) {
    final rec = _recommendedMonthsFor(_draft.state, crop);
    final months = const [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final set = rec.toSet();
    final rest = months.where((m) => !set.contains(m)).toList();
    return [...rec, ...rest];
  }

  List<String> _recommendedMonthsFor(String? state, String crop) {
    if (crop == 'Wheat') return ['Oct', 'Nov', 'Dec'];
    if (crop == 'Rice') return ['Jun', 'Jul'];
    if (crop == 'Maize') return ['Jun', 'Jul'];
    return ['Jul', 'Aug'];
  }

  List<String> _previousCropOptionsFor(String crop) {
    final historyCrops =
        _draft.crops.map((e) => e['crop_id'] as String).toSet().toList();
    final typicalRotation = {
      'Wheat': ['Pulses', 'Maize', 'Fallow'],
      'Rice': ['Wheat', 'Pulses'],
      'Maize': ['Pulses', 'Wheat'],
    };
    final base = const [
      'Fallow',
      'Wheat',
      'Rice',
      'Maize',
      'Pulses',
      'Oilseeds',
      'Vegetables',
      'Other',
    ];
    final prior = typicalRotation[crop] ?? const <String>[];
    final merged = {...prior, ...historyCrops, ...base};
    return merged.toList();
  }

  // ignore: unused_field
  final Map<String, List<String>> _varietyOptions = const {
    'Wheat': ['HD 2967', 'PBW 343', 'PBW 550', 'HD 3086'],
    'Rice': ['IR64', 'Swarna', 'MTU 1010'],
    'Maize': ['DKC 9144', 'Pioneer 30V92'],
  };

  // Prompt user for custom pest/disease name
  // ignore: unused_element
  Future<String?> _promptText(String title) async {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              title,
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
            content: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: 'Type here',
                filled: true,
                fillColor: AppColors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              autofocus: true,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, controller.text.trim()),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  foregroundColor: AppColors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: const Text('Add'),
              ),
            ],
          ),
    );
  }
}

class _OnboardingDraft {
  // profile
  String? name;
  String? ageRange;
  String? language = 'English';
  String? phoneNumber;
  bool phoneVerified = false;
  String? experienceLevel;
  String? socialCategory;

  // location
  double? gpsLat;
  double? gpsLon;
  String? village;
  String? district;
  String? state;
  double? totalArea;
  String areaUnit = 'acre';
  List<String> waterSources = [];
  List<String> equipment = [];
  bool? isMember;
  String? groupName;

  // fields
  List<Map<String, dynamic>> fields = [];

  // crops
  List<Map<String, dynamic>> crops = [];

  // soil/water
  bool manualSoilEntry = false;
  final Map<String, dynamic> soilTest = {};
  final Map<String, dynamic> waterQuality = {};
  bool? wantSoilKit;

  // history
  final Map<String, double> lastSeasonYields = {};
  final Map<String, String> yieldUnit = {};
  List<String> pastInputs = [];
  List<String> historicalImpacts = [];
  bool? usedSchemes;
  List<String> participatedSchemes = [];

  // finance
  bool? hasBankAccount;
  String? bankName;
  bool? hasInsurance;
  String? insuranceProvider;
  String? incomeBracket;
  String? preferredPayment;
  bool consentAnalytics = false;

  // consent
  bool termsAccepted = false;
}

// Add serialization helpers for the in-memory draft
extension _OnboardingDraftSer on _OnboardingDraft {
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'ageRange': ageRange,
      'language': language,
      'phoneNumber': phoneNumber,
      'phoneVerified': phoneVerified,
      'experienceLevel': experienceLevel,
      'socialCategory': socialCategory,
      'gpsLat': gpsLat,
      'gpsLon': gpsLon,
      'village': village,
      'district': district,
      'state': state,
      'totalArea': totalArea,
      'areaUnit': areaUnit,
      'waterSources': waterSources,
      'equipment': equipment,
      'isMember': isMember,
      'groupName': groupName,
      'fields': fields,
      'crops': crops,
      'manualSoilEntry': manualSoilEntry,
      'soilTest': soilTest,
      'waterQuality': waterQuality,
      'wantSoilKit': wantSoilKit,
      'lastSeasonYields': lastSeasonYields,
      'yieldUnit': yieldUnit,
      'pastInputs': pastInputs,
      'historicalImpacts': historicalImpacts,
      'usedSchemes': usedSchemes,
      'participatedSchemes': participatedSchemes,
      'hasBankAccount': hasBankAccount,
      'bankName': bankName,
      'hasInsurance': hasInsurance,
      'insuranceProvider': insuranceProvider,
      'incomeBracket': incomeBracket,
      'preferredPayment': preferredPayment,
      'consentAnalytics': consentAnalytics,
      'termsAccepted': termsAccepted,
    };
  }

  void applyFromMap(Map<String, dynamic> m) {
    try {
      name = m['name'] as String?;
      ageRange = m['ageRange'] as String?;
      language = m['language'] as String?;
      phoneNumber = m['phoneNumber'] as String?;
      phoneVerified = m['phoneVerified'] as bool? ?? false;
      experienceLevel = m['experienceLevel'] as String?;
      socialCategory = m['socialCategory'] as String?;
      gpsLat = (m['gpsLat'] is num) ? (m['gpsLat'] as num).toDouble() : null;
      gpsLon = (m['gpsLon'] is num) ? (m['gpsLon'] as num).toDouble() : null;
      village = m['village'] as String?;
      district = m['district'] as String?;
      state = m['state'] as String?;
      totalArea =
          (m['totalArea'] is num) ? (m['totalArea'] as num).toDouble() : null;
      areaUnit = m['areaUnit'] as String? ?? areaUnit;
      waterSources = List<String>.from(m['waterSources'] ?? []);
      equipment = List<String>.from(m['equipment'] ?? []);
      isMember = m['isMember'] as bool?;
      groupName = m['groupName'] as String?;
      fields = List<Map<String, dynamic>>.from(m['fields'] ?? []);
      crops = List<Map<String, dynamic>>.from(m['crops'] ?? []);
      manualSoilEntry = m['manualSoilEntry'] as bool? ?? manualSoilEntry;
      (soilTest..clear()).addAll(
        Map<String, dynamic>.from(m['soilTest'] ?? {}),
      );
      (waterQuality..clear()).addAll(
        Map<String, dynamic>.from(m['waterQuality'] ?? {}),
      );
      wantSoilKit = m['wantSoilKit'] as bool?;
      (lastSeasonYields..clear()).addAll(
        Map<String, dynamic>.from(
          m['lastSeasonYields'] ?? {},
        ).map((k, v) => MapEntry(k, (v is num) ? v.toDouble() : 0.0)),
      );
      (yieldUnit..clear()).addAll(
        Map<String, String>.from(
          (m['yieldUnit'] ?? {}).map(
            (k, v) => MapEntry(k.toString(), v.toString()),
          ),
        ),
      );
      pastInputs = List<String>.from(m['pastInputs'] ?? []);
      historicalImpacts = List<String>.from(m['historicalImpacts'] ?? []);
      usedSchemes = m['usedSchemes'] as bool?;
      participatedSchemes = List<String>.from(m['participatedSchemes'] ?? []);
      hasBankAccount = m['hasBankAccount'] as bool?;
      bankName = m['bankName'] as String?;
      hasInsurance = m['hasInsurance'] as bool?;
      insuranceProvider = m['insuranceProvider'] as String?;
      incomeBracket = m['incomeBracket'] as String?;
      preferredPayment = m['preferredPayment'] as String?;
      consentAnalytics = m['consentAnalytics'] as bool? ?? false;
      termsAccepted = m['termsAccepted'] as bool? ?? false;
    } catch (_) {
      // if parsing fails, keep defaults
    }
  }
}
