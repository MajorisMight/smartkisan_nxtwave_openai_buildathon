import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import '../../constants/app_colors.dart';

class SoilTestDialog extends StatefulWidget {
  final Function(Map<String, double>?, File?) onSave;

  const SoilTestDialog({
    super.key,
    required this.onSave,
  });

  @override
  State<SoilTestDialog> createState() => _SoilTestDialogState();
}

class _SoilTestDialogState extends State<SoilTestDialog> {
  // Text controllers for all soil parameters
  final TextEditingController _nController = TextEditingController();
  final TextEditingController _pController = TextEditingController();
  final TextEditingController _kController = TextEditingController();
  final TextEditingController _phController = TextEditingController();
  final TextEditingController _omController = TextEditingController();
  final TextEditingController _caController = TextEditingController();
  final TextEditingController _mgController = TextEditingController();
  final TextEditingController _sController = TextEditingController();
  final TextEditingController _bController = TextEditingController();
  final TextEditingController _clController = TextEditingController();
  final TextEditingController _cuController = TextEditingController();
  final TextEditingController _feController = TextEditingController();
  final TextEditingController _mnController = TextEditingController();
  final TextEditingController _moController = TextEditingController();
  final TextEditingController _znController = TextEditingController();
  final TextEditingController _cecController = TextEditingController();

  XFile? _pickedImage;
  File? _pickedFile;
  String? _analysisResult;
  bool _isAnalyzing = false;

  @override
  void dispose() {
    _nController.dispose();
    _pController.dispose();
    _kController.dispose();
    _phController.dispose();
    _omController.dispose();
    _caController.dispose();
    _mgController.dispose();
    _sController.dispose();
    _bController.dispose();
    _clController.dispose();
    _cuController.dispose();
    _feController.dispose();
    _mnController.dispose();
    _moController.dispose();
    _znController.dispose();
    _cecController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Soil Test Results',
        style: GoogleFonts.poppins(
          fontSize: 18.sp,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildBasicParameters(),
            SizedBox(height: 16.h),
            _buildSecondaryParameters(),
            SizedBox(height: 16.h),
            _buildMicronutrients(),
            SizedBox(height: 16.h),
            _buildFileAttachmentSection(),
            if (_isAnalyzing) ...[
              SizedBox(height: 12.h),
              const CircularProgressIndicator(),
            ],
            if (_analysisResult != null) ...[
              SizedBox(height: 12.h),
              _buildAnalysisResultCard(),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Cancel',
            style: GoogleFonts.poppins(color: AppColors.textSecondary),
          ),
        ),
        TextButton(
          onPressed: _runAnalysis,
          child: Text(
            _isAnalyzing ? 'Analyzing...' : 'Analyze',
            style: GoogleFonts.poppins(color: AppColors.primaryGreen),
          ),
        ),
        TextButton(
          onPressed: _saveResults,
          child: Text(
            'Save',
            style: GoogleFonts.poppins(
              color: AppColors.primaryGreen,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBasicParameters() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Basic Parameters',
          style: GoogleFonts.poppins(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 12.h),
        _buildTextField(
          controller: _nController,
          label: 'Nitrogen (N) ppm',
          hint: 'Enter N value',
        ),
        SizedBox(height: 12.h),
        _buildTextField(
          controller: _pController,
          label: 'Phosphorus (P) ppm',
          hint: 'Enter P value',
        ),
        SizedBox(height: 12.h),
        _buildTextField(
          controller: _kController,
          label: 'Potassium (K) ppm',
          hint: 'Enter K value',
        ),
        SizedBox(height: 12.h),
        _buildTextField(
          controller: _phController,
          label: 'pH Level',
          hint: 'Enter pH value',
        ),
      ],
    );
  }

  Widget _buildSecondaryParameters() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Secondary Parameters',
          style: GoogleFonts.poppins(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 12.h),
        _buildTextField(
          controller: _omController,
          label: 'Organic Matter (%)',
          hint: 'Enter organic matter %',
        ),
        SizedBox(height: 12.h),
        _buildTextField(
          controller: _caController,
          label: 'Calcium (Ca) ppm',
          hint: 'Enter Ca value',
        ),
        SizedBox(height: 12.h),
        _buildTextField(
          controller: _mgController,
          label: 'Magnesium (Mg) ppm',
          hint: 'Enter Mg value',
        ),
        SizedBox(height: 12.h),
        _buildTextField(
          controller: _sController,
          label: 'Sulphur (S) ppm',
          hint: 'Enter S value',
        ),
        SizedBox(height: 12.h),
        _buildTextField(
          controller: _cecController,
          label: 'Cation Exchange Capacity (CEC)',
          hint: 'Enter CEC value',
        ),
      ],
    );
  }

  Widget _buildMicronutrients() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Micronutrients',
          style: GoogleFonts.poppins(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 12.h),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: _bController,
                label: 'Boron (B) ppm',
                hint: 'B value',
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: _buildTextField(
                controller: _clController,
                label: 'Chlorine (Cl) ppm',
                hint: 'Cl value',
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: _cuController,
                label: 'Copper (Cu) ppm',
                hint: 'Cu value',
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: _buildTextField(
                controller: _feController,
                label: 'Iron (Fe) ppm',
                hint: 'Fe value',
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: _mnController,
                label: 'Manganese (Mn) ppm',
                hint: 'Mn value',
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: _buildTextField(
                controller: _moController,
                label: 'Molybdenum (Mo) ppm',
                hint: 'Mo value',
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        _buildTextField(
          controller: _znController,
          label: 'Zinc (Zn) ppm',
          hint: 'Enter Zn value',
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: GoogleFonts.poppins(
          fontSize: 14.sp,
          color: AppColors.textSecondary,
        ),
        hintStyle: GoogleFonts.poppins(
          fontSize: 14.sp,
          color: AppColors.textSecondary.withOpacity(0.7),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: const BorderSide(color: AppColors.borderLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: const BorderSide(color: AppColors.primaryGreen),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
    );
  }

  Widget _buildFileAttachmentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Or Attach File',
          style: GoogleFonts.poppins(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 12.h),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.photo, color: AppColors.primaryGreen),
                label: Text(
                  'Attach Photo',
                  style: GoogleFonts.poppins(color: AppColors.primaryGreen),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.primaryGreen),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _pickDocument,
                icon: const Icon(Icons.attach_file, color: AppColors.primaryGreen),
                label: Text(
                  'Attach Document',
                  style: GoogleFonts.poppins(color: AppColors.primaryGreen),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.primaryGreen),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
              ),
            ),
          ],
        ),
        if (_pickedFile != null) ...[
          SizedBox(height: 12.h),
          _buildAttachedFileInfo(),
        ],
      ],
    );
  }

  Widget _buildAttachedFileInfo() {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.greyLight.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.attachment, color: AppColors.primaryGreen, size: 16),
              SizedBox(width: 4.w),
              Expanded(
                child: Text(
                  'Attached: ${_pickedFile!.path.split('/').last}',
                  style: GoogleFonts.poppins(
                    fontSize: 12.sp,
                    color: AppColors.textSecondary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                onPressed: () => setState(() {
                  _pickedFile = null;
                  _pickedImage = null;
                  _analysisResult = null;
                }),
                icon: const Icon(Icons.close, size: 16),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          if (_pickedImage != null) ...[
            SizedBox(height: 8.h),
            ClipRRect(
              borderRadius: BorderRadius.circular(8.r),
              child: Image.file(
                File(_pickedImage!.path),
                height: 120.h,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAnalysisResultCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.greyLight.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.analytics, color: AppColors.primaryGreen, size: 16),
              SizedBox(width: 4.w),
              Text(
                'Analysis Result',
                style: GoogleFonts.poppins(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            _analysisResult!,
            style: GoogleFonts.poppins(
              fontSize: 13.sp,
              color: AppColors.textPrimary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      if (image != null) {
        setState(() {
          _pickedImage = image;
          _pickedFile = File(image.path);
          _analysisResult = null;
        });
      }
    } catch (e) {
      _showErrorSnackBar('Failed to pick image: ${e.toString()}');
    }
  }

  Future<void> _pickDocument() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png', 'doc', 'docx'],
        withData: false,
      );
      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _pickedFile = File(result.files.first.path!);
          _pickedImage = null;
          _analysisResult = null;
        });
      }
    } catch (e) {
      _showErrorSnackBar('Failed to pick document: ${e.toString()}');
    }
  }

  Future<void> _runAnalysis() async {
    if (_pickedFile == null && _isAllFieldsEmpty()) {
      _showErrorSnackBar('Provide values or attach a file/photo for analysis');
      return;
    }

    setState(() => _isAnalyzing = true);

    try {
      String result;
      if (_pickedFile != null) {
        result = await _analyzeSoilTestFile(_pickedFile!);
      } else {
        result = _analyzeManualInputs();
      }
      setState(() => _analysisResult = result);
    } catch (e) {
      setState(() => _analysisResult = 'Analysis failed: ${e.toString()}');
    } finally {
      setState(() => _isAnalyzing = false);
    }
  }

  bool _isAllFieldsEmpty() {
    return _nController.text.isEmpty &&
        _pController.text.isEmpty &&
        _kController.text.isEmpty &&
        _phController.text.isEmpty &&
        _omController.text.isEmpty &&
        _caController.text.isEmpty &&
        _mgController.text.isEmpty &&
        _sController.text.isEmpty &&
        _bController.text.isEmpty &&
        _clController.text.isEmpty &&
        _cuController.text.isEmpty &&
        _feController.text.isEmpty &&
        _mnController.text.isEmpty &&
        _moController.text.isEmpty &&
        _znController.text.isEmpty &&
        _cecController.text.isEmpty;
  }

  String _analyzeManualInputs() {
    final n = double.tryParse(_nController.text) ?? 0;
    final p = double.tryParse(_pController.text) ?? 0;
    final k = double.tryParse(_kController.text) ?? 0;
    final ph = double.tryParse(_phController.text) ?? 7;

    String analysis = 'Manual analysis: ';
    List<String> nutrients = [];
    List<String> recommendations = [];

    if (n > 0) nutrients.add('N=${n.toStringAsFixed(1)} ppm');
    if (p > 0) nutrients.add('P=${p.toStringAsFixed(1)} ppm');
    if (k > 0) nutrients.add('K=${k.toStringAsFixed(1)} ppm');
    if (ph != 7) nutrients.add('pH=${ph.toStringAsFixed(1)}');

    analysis += nutrients.join(', ');

    // Basic recommendations based on typical ranges
    if (n < 280) recommendations.add('Low N - Apply nitrogen fertilizer');
    if (p < 11) recommendations.add('Low P - Apply phosphorus fertilizer');
    if (k < 140) recommendations.add('Low K - Apply potassium fertilizer');
    if (ph < 6.0) recommendations.add('Low pH - Consider liming');
    if (ph > 8.0) recommendations.add('High pH - Consider sulfur application');

    if (recommendations.isNotEmpty) {
      analysis += '. Recommendations: ${recommendations.join('; ')}.';
    } else {
      analysis += '. Nutrient levels appear adequate.';
    }

    return analysis;
  }

  Future<String> _analyzeSoilTestFile(File file) async {
    // Simulate API call delay
    await Future.delayed(const Duration(seconds: 2));
    
    final fileName = file.path.split('/').last;
    final extension = fileName.split('.').last.toLowerCase();
    
    String analysis = 'Automated analysis for "$fileName": ';
    
    if (['jpg', 'jpeg', 'png'].contains(extension)) {
      analysis += 'Image analysis detected soil test report. ';
    } else if (extension == 'pdf') {
      analysis += 'PDF document processed. ';
    }
    
    // Placeholder analysis result
    analysis += 'Nitrogen moderate, Phosphorus adequate, Potassium low, pH slightly acidic. '
        'Recommendation: Apply 15-20 kg N/ha and 8-12 kg K/ha; consider liming if pH < 6.2.';
    
    return analysis;
  }

  void _saveResults() {
    final values = <String, double>{};
    
    // Parse all input values
    final inputMap = {
      'N': _nController.text,
      'P': _pController.text,
      'K': _kController.text,
      'pH': _phController.text,
      'OrganicMatter': _omController.text,
      'Ca': _caController.text,
      'Mg': _mgController.text,
      'S': _sController.text,
      'B': _bController.text,
      'Cl': _clController.text,
      'Cu': _cuController.text,
      'Fe': _feController.text,
      'Mn': _mnController.text,
      'Mo': _moController.text,
      'Zn': _znController.text,
      'CEC': _cecController.text,
    };

    for (final entry in inputMap.entries) {
      final value = double.tryParse(entry.value);
      if (value != null) {
        values[entry.key] = value;
      }
    }

    // Call the callback with parsed values and file
    widget.onSave(values.isNotEmpty ? values : null, _pickedFile);
    Navigator.pop(context);
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
      ),
    );
  }
}