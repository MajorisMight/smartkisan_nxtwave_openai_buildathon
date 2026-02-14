import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../constants/app_colors.dart';
import '../constants/crop_options.dart';
import '../models/crop.dart';
import '../services/recommendation_service.dart';
import '../services/session_service.dart';
import '../Widgets/custom_button.dart';

enum FertilizerFlow { baseline, stageBased }

class FertilizerScreen extends StatefulWidget {
  final FertilizerFlow flow;
  final Crop? crop;
  final String? initialStage;
  final String? initialLocation;

  const FertilizerScreen.baseline({super.key})
    : flow = FertilizerFlow.baseline,
      crop = null,
      initialStage = null,
      initialLocation = null;

  const FertilizerScreen.stageBased({
    super.key,
    required Crop this.crop,
    this.initialStage,
    this.initialLocation,
  }) : flow = FertilizerFlow.stageBased;

  @override
  State<FertilizerScreen> createState() => _FertilizerScreenState();
}

class _FertilizerScreenState extends State<FertilizerScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _areaController = TextEditingController();
  final TextEditingController _targetCropController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _nController = TextEditingController();
  final TextEditingController _pController = TextEditingController();
  final TextEditingController _kController = TextEditingController();
  final TextEditingController _phController = TextEditingController();

  String _selectedStage = 'Basal';
  String _selectedBaselineCrop = CropOptions.supportedCropTypes.first;
  String _selectedIrrigationType = 'Rainfed';
  String _selectedSoilType = 'Not provided';

  File? _soilTestFile;
  bool _isLoading = false;
  Map<String, dynamic>? _analysis;

  final List<String> _irrigationTypes = const [
    'Rainfed',
    'Canal',
    'Tubewell',
    'Sprinkler',
    'Drip',
  ];

  final List<String> _soilTypes = const [
    'Sandy',
    'Loam',
    'Clay',
    'Black',
    'Mixed',
    'Not provided',
  ];

  bool get _isBaseline => widget.flow == FertilizerFlow.baseline;

  @override
  void initState() {
    super.initState();
    final crop = widget.crop;
    _areaController.text = crop?.areaAcres?.toStringAsFixed(1) ?? '1.0';
    _targetCropController.text =
        _isBaseline ? (crop?.name ?? '') : _resolveCropType(crop);
    if (_isBaseline && _targetCropController.text.isEmpty) {
      _targetCropController.text = _selectedBaselineCrop;
    } else if (_isBaseline &&
        CropOptions.supportedCropTypes.contains(
      _targetCropController.text,
    )) {
      _selectedBaselineCrop = _targetCropController.text;
    }
    _selectedStage = widget.initialStage?.trim().isNotEmpty == true
        ? _coerceStage(widget.initialStage!.trim())
        : _coerceStage(_stageFromCrop(crop?.stage));
    _locationController.text = widget.initialLocation?.trim() ?? crop?.location ?? '';
    _loadLocationFallbackIfMissing();
  }

  @override
  void dispose() {
    _areaController.dispose();
    _targetCropController.dispose();
    _locationController.dispose();
    _nController.dispose();
    _pController.dispose();
    _kController.dispose();
    _phController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundLight,
        elevation: 0,
        centerTitle: false,
        titleSpacing: 0,
        title: Text(
          _isBaseline ? 'Baseline Fertilizer' : 'Stage Based Fertilizer',
          style: GoogleFonts.poppins(
            color: AppColors.textPrimary,
            fontSize: 20.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 24.h),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildModeBanner(),
                    SizedBox(height: 12.h),
                    _buildMainInputCard(),
                    SizedBox(height: 12.h),
                    _buildSoilTestCard(),
                    SizedBox(height: 16.h),
                    CustomButton(
                      text:
                          _isBaseline
                              ? 'Calculate Baseline Recommendation'
                              : 'Calculate Stage Recommendation',
                      onPressed: _calculate,
                      isLoading: _isLoading,
                      icon: Icons.calculate,
                    ),
                    if (_analysis != null) ...[
                      SizedBox(height: 16.h),
                      _buildResultCard(_analysis!),
                    ],
                  ],
                ),
              ),
            ),
            if (_isLoading)
              Container(
                color: Colors.black26,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(),
                      SizedBox(height: 12.h),
                      Text(
                        'Generating recommendation...',
                        style: GoogleFonts.poppins(
                          color: AppColors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildModeBanner() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: _isBaseline ? const Color(0xFFE8F5E9) : const Color(0xFFE3F2FD),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color:
              _isBaseline ? AppColors.primaryGreenLight : AppColors.accentBlue,
        ),
      ),
      child: Text(
        _isBaseline
            ? 'Use this only before planting. It is meant to bring soil nutrients to baseline.'
            : 'Use this on the crop page for stage-wise doses (example: basal, tillering). Soil test is optional but recommended.',
        style: GoogleFonts.poppins(
          fontSize: 12.sp,
          color: AppColors.textPrimary,
          height: 1.4,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildMainInputCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Field Inputs',
            style: GoogleFonts.poppins(
              fontSize: 15.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 12.h),
          _buildTextField(
            controller: _areaController,
            label:
                _isBaseline
                    ? 'Land area (ha)'
                    : 'Land area (acres, from crop page)',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            readOnly: !_isBaseline,
            validator: (value) {
              final parsed = double.tryParse((value ?? '').trim());
              if (parsed == null || parsed <= 0) {
                return 'Enter a valid land area';
              }
              return null;
            },
          ),
          SizedBox(height: 10.h),
          if (_isBaseline)
            _buildDropdown(
              label: 'Crop type',
              value: _selectedBaselineCrop,
              items: CropOptions.supportedCropTypes,
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedBaselineCrop = value;
                    _targetCropController.text = value;
                  });
                }
              },
            )
          else
            _buildTextField(
              controller: _targetCropController,
              label: 'Crop type',
              readOnly: true,
              validator: (value) {
                if ((value ?? '').trim().isEmpty) {
                  return 'Crop type is required';
                }
                return null;
              },
            ),
          SizedBox(height: 10.h),
          if (!_isBaseline) ...[
            _buildDropdown(
              label: 'Stage (prefilled from crop page)',
              value: _selectedStage,
              items: _stageOptions,
              onChanged: (value) {
                if (value == null || value.trim().isEmpty) return;
                setState(() => _selectedStage = value.trim());
              },
            ),
            SizedBox(height: 10.h),
            _buildTextField(
              controller: _locationController,
              label: 'Location (prefilled from crop page)',
            ),
            SizedBox(height: 10.h),
          ],
          _buildDropdown(
            label: 'Irrigation type',
            value: _selectedIrrigationType,
            items: _irrigationTypes,
            onChanged: (value) {
              if (value != null) {
                setState(() => _selectedIrrigationType = value);
              }
            },
          ),
          SizedBox(height: 10.h),
          _buildDropdown(
            label: 'Soil type',
            value: _selectedSoilType,
            items: _soilTypes,
            onChanged: (value) {
              if (value != null) {
                setState(() => _selectedSoilType = value);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSoilTestCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Soil Test',
                style: GoogleFonts.poppins(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(width: 8.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  color: _isBaseline ? const Color(0xFFFFEBEE) : const Color(0xFFE8F5E9),
                ),
                child: Text(
                  _isBaseline ? 'Required' : 'Recommended',
                  style: GoogleFonts.poppins(
                    fontSize: 11.sp,
                    color: _isBaseline ? AppColors.error : AppColors.success,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _nController,
                  label: 'N (ppm)',
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: _buildTextField(
                  controller: _pController,
                  label: 'P (ppm)',
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _kController,
                  label: 'K (ppm)',
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: _buildTextField(
                  controller: _phController,
                  label: 'pH',
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          OutlinedButton.icon(
            onPressed: _pickSoilTestFile,
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.primaryGreen),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
            icon: const Icon(Icons.upload_file, color: AppColors.primaryGreen),
            label: Text(
              _soilTestFile == null ? 'Attach soil report' : 'Change attached report',
              style: GoogleFonts.poppins(
                color: AppColors.primaryGreen,
                fontWeight: FontWeight.w600,
                fontSize: 12.sp,
              ),
            ),
          ),
          if (_soilTestFile != null) ...[
            SizedBox(height: 6.h),
            Text(
              'Attached: ${_soilTestFile!.path.split('/').last}',
              style: GoogleFonts.poppins(
                fontSize: 11.sp,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildResultCard(Map<String, dynamic> analysis) {
    final confidence = analysis['confidence']?.toString() ?? 'Low';
    final basis = analysis['basis']?.toString() ?? 'AI recommendation';
    final why = analysis['why_this_recommendation']?.toString() ?? '';
    final caution = analysis['caution']?.toString() ?? '';
    final fertilizerItems =
        (analysis['fertilizer_items'] is List)
            ? List<Map<String, dynamic>>.from(analysis['fertilizer_items'])
            : <Map<String, dynamic>>[];
    final splitSchedule =
        (analysis['split_schedule'] is List)
            ? List<Map<String, dynamic>>.from(analysis['split_schedule'])
            : <Map<String, dynamic>>[];

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recommendation',
                style: GoogleFonts.poppins(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              _confidenceChip(confidence),
            ],
          ),
          SizedBox(height: 10.h),
          if (fertilizerItems.isEmpty)
            Text(
              'No fertilizer item returned by AI.',
              style: GoogleFonts.poppins(
                fontSize: 12.sp,
                color: AppColors.textSecondary,
              ),
            )
          else
            ...fertilizerItems.map(_buildFertilizerItemTile),
          if (splitSchedule.isNotEmpty) ...[
            SizedBox(height: 10.h),
            Text(
              'Schedule',
              style: GoogleFonts.poppins(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 6.h),
            ...splitSchedule.map(_buildScheduleTile),
          ],
          if (why.isNotEmpty) ...[
            SizedBox(height: 10.h),
            Text(
              why,
              style: GoogleFonts.poppins(
                fontSize: 12.sp,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
          ],
          if (caution.isNotEmpty) ...[
            SizedBox(height: 8.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3E0),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Text(
                caution,
                style: GoogleFonts.poppins(
                  fontSize: 12.sp,
                  color: AppColors.secondaryOrangeDark,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
          SizedBox(height: 8.h),
          Text(
            'Basis: $basis',
            style: GoogleFonts.poppins(
              fontSize: 11.sp,
              color: AppColors.textSecondary,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFertilizerItemTile(Map<String, dynamic> item) {
    final name = item['name']?.toString() ?? 'Fertilizer';
    final quantity = item['quantity']?.toString() ?? '';
    final note = item['note']?.toString() ?? '';

    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF6FAF6),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  name,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                    fontSize: 13.sp,
                  ),
                ),
              ),
              if (quantity.isNotEmpty)
                Text(
                  quantity,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryGreen,
                    fontSize: 12.sp,
                  ),
                ),
            ],
          ),
          if (note.isNotEmpty) ...[
            SizedBox(height: 3.h),
            Text(
              note,
              style: GoogleFonts.poppins(
                fontSize: 11.sp,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildScheduleTile(Map<String, dynamic> schedule) {
    final product = schedule['product']?.toString() ?? '-';
    final when = schedule['when']?.toString() ?? '-';
    final amount = schedule['amount']?.toString() ?? '-';

    return Container(
      margin: EdgeInsets.only(bottom: 6.h),
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: AppColors.greyLight,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '$product • $amount',
              style: GoogleFonts.poppins(
                color: AppColors.textPrimary,
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(width: 8.w),
          Text(
            when,
            style: GoogleFonts.poppins(
              color: AppColors.textSecondary,
              fontSize: 11.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _confidenceChip(String value) {
    Color color = AppColors.error;
    if (value.toLowerCase() == 'medium') color = AppColors.warning;
    if (value.toLowerCase() == 'high') color = AppColors.success;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        value,
        style: GoogleFonts.poppins(
          fontSize: 11.sp,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    bool readOnly = false,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      readOnly: readOnly,
      style: GoogleFonts.poppins(fontSize: 13.sp, color: AppColors.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(
          fontSize: 12.sp,
          color: AppColors.textSecondary,
        ),
        filled: true,
        fillColor: readOnly ? const Color(0xFFF8F8F8) : AppColors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: const BorderSide(color: AppColors.borderLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: const BorderSide(color: AppColors.borderLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: const BorderSide(color: AppColors.primaryGreen),
        ),
        isDense: true,
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(
          fontSize: 12.sp,
          color: AppColors.textSecondary,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: const BorderSide(color: AppColors.borderLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: const BorderSide(color: AppColors.borderLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: const BorderSide(color: AppColors.primaryGreen),
        ),
        isDense: true,
      ),
      items:
          items
              .map((item) => DropdownMenuItem(value: item, child: Text(item)))
              .toList(),
      onChanged: onChanged,
    );
  }

  String _resolveCropType(Crop? crop) {
    if (crop == null) return '';
    final fromType = (crop.type ?? '').trim();
    if (fromType.isNotEmpty) return fromType;
    return crop.name.trim();
  }

  Future<void> _loadLocationFallbackIfMissing() async {
    if (_isBaseline) return;
    if (_locationController.text.trim().isNotEmpty) return;
    final address = await SessionService.getUserAddress();
    final fallback = [
      address['village'],
      address['district'],
      address['state'],
    ].where((v) => v != null && v.trim().isNotEmpty).join(', ');
    if (!mounted || fallback.isEmpty) return;
    setState(() {
      _locationController.text = fallback;
    });
  }

  Future<void> _pickSoilTestFile() async {
    showModalBottomSheet<void>(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Select photo'),
                onTap: () async {
                  Navigator.pop(context);
                  await _pickImage();
                },
              ),
              ListTile(
                leading: const Icon(Icons.attach_file),
                title: const Text('Select document'),
                onTap: () async {
                  Navigator.pop(context);
                  await _pickDocument();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;

    setState(() {
      _soilTestFile = File(image.path);
    });

    await _tryAutoExtractFromFile(_soilTestFile!);
  }

  Future<void> _pickDocument() async {
    final result = await FilePicker.platform.pickFiles(withData: false);
    if (result == null || result.files.isEmpty) return;

    final path = result.files.first.path;
    if (path == null) return;

    setState(() {
      _soilTestFile = File(path);
    });

    await _tryAutoExtractFromFile(_soilTestFile!);
  }

  Future<void> _tryAutoExtractFromFile(File file) async {
    try {
      final parsed = await _parseSoilReport(file);
      final values = parsed['values'] as Map<String, double>;
      if (values.isNotEmpty && mounted) {
        _applyParsedSoilValues(values);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(parsed['summary'] as String)),
        );
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Attached file saved. Could not auto-extract values.'),
        ),
      );
    }
  }

  Future<Map<String, dynamic>> _parseSoilReport(File file) async {
    final lowerPath = file.path.toLowerCase();
    final isImage =
        lowerPath.endsWith('.jpg') ||
        lowerPath.endsWith('.jpeg') ||
        lowerPath.endsWith('.png') ||
        lowerPath.endsWith('.webp');

    if (isImage) {
      final ai = await RecommendationService.extractSoilTestFromImage(image: file);
      final values = _normalizeSoilMap(ai);
      return {
        'values': values,
        'summary':
            values.isEmpty
                ? 'Could not detect values from image.'
                : 'Soil values extracted from image.',
      };
    }

    String content;
    try {
      content = await file.readAsString();
    } catch (_) {
      final bytes = await file.readAsBytes();
      content = String.fromCharCodes(bytes);
    }

    return _parseSoilText(content);
  }

  Map<String, dynamic> _parseSoilText(String content) {
    final values = <String, double>{};
    final decoded = _tryDecodeJson(content);
    if (decoded is Map) {
      _readSoilAliasesFromMap(decoded, values);
    }

    final patterns = {
      'N': RegExp(
        r'\b(?:n|nitrogen)\b\s*[:=\-]?\s*(-?\d+(?:\.\d+)?)',
        caseSensitive: false,
      ),
      'P': RegExp(
        r'\b(?:p|phosphorus|phosphate)\b\s*[:=\-]?\s*(-?\d+(?:\.\d+)?)',
        caseSensitive: false,
      ),
      'K': RegExp(
        r'\b(?:k|potassium)\b\s*[:=\-]?\s*(-?\d+(?:\.\d+)?)',
        caseSensitive: false,
      ),
      'pH': RegExp(
        r'\bph\b\s*[:=\-]?\s*(-?\d+(?:\.\d+)?)',
        caseSensitive: false,
      ),
    };

    for (final entry in patterns.entries) {
      if (values.containsKey(entry.key)) continue;
      final match = entry.value.firstMatch(content);
      if (match == null) continue;
      final parsed = double.tryParse(match.group(1) ?? '');
      if (parsed != null) values[entry.key] = parsed;
    }

    return {
      'values': values,
      'summary':
          values.isEmpty
              ? 'Could not auto-extract values from file.'
              : 'Soil values extracted from file.',
    };
  }

  dynamic _tryDecodeJson(String text) {
    try {
      return jsonDecode(text);
    } catch (_) {
      return null;
    }
  }

  void _readSoilAliasesFromMap(Map<dynamic, dynamic> source, Map<String, double> out) {
    final aliases = <String, String>{
      'n': 'N',
      'nitrogen': 'N',
      'p': 'P',
      'phosphorus': 'P',
      'k': 'K',
      'potassium': 'K',
      'ph': 'pH',
    };

    for (final entry in source.entries) {
      final key = entry.key.toString().toLowerCase().trim();
      final canonical = aliases[key];
      if (canonical == null) continue;
      final value = entry.value;
      final parsed = value is num ? value.toDouble() : double.tryParse('$value');
      if (parsed != null) {
        out[canonical] = parsed;
      }
    }
  }

  Map<String, double> _normalizeSoilMap(Map<String, dynamic> source) {
    final out = <String, double>{};
    final aliases = <String, String>{
      'n': 'N',
      'nitrogen': 'N',
      'p': 'P',
      'phosphorus': 'P',
      'k': 'K',
      'potassium': 'K',
      'ph': 'pH',
    };

    void addMap(Map<dynamic, dynamic> map) {
      for (final entry in map.entries) {
        final key = entry.key.toString().toLowerCase().trim();
        final canonical = aliases[key];
        if (canonical == null) continue;
        final value = entry.value;
        final parsed = value is num ? value.toDouble() : double.tryParse('$value');
        if (parsed != null) {
          out[canonical] = parsed;
        }
      }
    }

    addMap(source);
    final nested = source['values'];
    if (nested is Map) {
      addMap(nested);
    }

    return out;
  }

  void _applyParsedSoilValues(Map<String, double> values) {
    if (values.containsKey('N')) _nController.text = values['N']!.toString();
    if (values.containsKey('P')) _pController.text = values['P']!.toString();
    if (values.containsKey('K')) _kController.text = values['K']!.toString();
    if (values.containsKey('pH')) _phController.text = values['pH']!.toString();
  }

  String _stageFromCrop(String? stage) {
    switch ((stage ?? '').toLowerCase()) {
      case 'sowing':
        return 'Basal';
      case 'growth':
        return 'Vegetative';
      case 'fertilizer':
        return 'Tillering';
      case 'harvest':
        return 'Maturity';
      default:
        return 'Basal';
    }
  }

  String _coerceStage(String stage) {
    if (_stageOptions.contains(stage)) return stage;
    final lower = stage.toLowerCase();
    if (lower.contains('tiller')) return 'Tillering';
    if (lower.contains('flower')) return 'Flowering';
    if (lower.contains('fruit')) return 'Fruiting';
    if (lower.contains('matur') || lower.contains('harvest')) return 'Maturity';
    if (lower.contains('basal') ||
        lower.contains('sow') ||
        lower.contains('germin') ||
        lower.contains('seed')) {
      return 'Basal';
    }
    return 'Vegetative';
  }

  bool _hasSoilValues() {
    final n = double.tryParse(_nController.text.trim());
    final p = double.tryParse(_pController.text.trim());
    final k = double.tryParse(_kController.text.trim());
    final ph = double.tryParse(_phController.text.trim());
    return n != null || p != null || k != null || ph != null;
  }

  Map<String, double> _soilValuesMap() {
    final map = <String, double>{};
    final n = double.tryParse(_nController.text.trim());
    final p = double.tryParse(_pController.text.trim());
    final k = double.tryParse(_kController.text.trim());
    final ph = double.tryParse(_phController.text.trim());

    if (n != null) map['N'] = n;
    if (p != null) map['P'] = p;
    if (k != null) map['K'] = k;
    if (ph != null) map['pH'] = ph;
    return map;
  }

  Future<void> _calculate() async {
    if (!_formKey.currentState!.validate()) return;

    final hasSoilData = _hasSoilValues() || _soilTestFile != null;
    if (_isBaseline && !hasSoilData) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Baseline mode requires soil test results. Add values or attach a soil report.',
          ),
        ),
      );
      return;
    }

    if (!_isBaseline && !hasSoilData) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Soil test is optional in Stage Based mode, but adding it improves recommendation quality.',
          ),
        ),
      );
    }

    setState(() => _isLoading = true);
    try {
      final areaRaw =
          _isBaseline
              ? double.parse(_areaController.text.trim())
              : (widget.crop?.areaAcres ?? double.parse(_areaController.text.trim()));
      final areaHa = _isBaseline ? areaRaw : areaRaw / 2.47105;
      final cropName =
          _isBaseline
              ? _selectedBaselineCrop.trim()
              : (widget.crop?.name.trim() ?? _targetCropController.text.trim());
      final selectedStage = _selectedStage.trim().isEmpty
          ? _coerceStage(_stageFromCrop(widget.crop?.stage))
          : _coerceStage(_selectedStage.trim());
      final soilValues = _soilValuesMap();

      final contextData = <String, dynamic>{
        'mode': _isBaseline ? 'baseline' : 'stage_based',
        'purpose':
            _isBaseline
                ? 'Bring soil nutrients to baseline before planting.'
                : 'Recommend crop-stage fertilizer requirement.',
        'target_crop': cropName,
        'crop_type': cropName,
        'stage': _isBaseline ? 'Pre-planting baseline' : selectedStage,
        'area_ha': areaHa,
        'area_acres': _isBaseline ? areaRaw * 2.47105 : areaRaw,
        'location': _locationController.text.trim().isEmpty
            ? 'Not provided'
            : _locationController.text.trim(),
        if (!_isBaseline) ...{
          'crop_page_stage': widget.initialStage ?? widget.crop?.stage,
          'crop_page_crop_type': _resolveCropType(widget.crop),
          'crop_page_variety': widget.crop?.type,
        },
        'irrigation_type': _selectedIrrigationType,
        'soil_type': _selectedSoilType,
        'soil_test': soilValues,
        'soil_test_file_path': _soilTestFile?.path,
        'soil_test_available': hasSoilData,
      };

      final result = await RecommendationService.fertilizerPlanFromContext(
        contextData: contextData,
      );

      if (!mounted) return;
      setState(() {
        _analysis = result;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Calculation failed: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
  final List<String> _stageOptions = const [
    'Basal',
    'Tillering',
    'Vegetative',
    'Flowering',
    'Fruiting',
    'Maturity',
  ];
