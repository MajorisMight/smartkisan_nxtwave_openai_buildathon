import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

class AIAnalysisLoading extends StatefulWidget {
  final String title;
  final String subtitle;
  final List<Map<String, dynamic>> analysisSteps;
  final VoidCallback? onComplete;
  final Duration duration;

  const AIAnalysisLoading({
    super.key,
    required this.title,
    required this.subtitle,
    required this.analysisSteps,
    this.onComplete,
    this.duration = const Duration(seconds: 5),
  });

  @override
  State<AIAnalysisLoading> createState() => _AIAnalysisLoadingState();
}

class _AIAnalysisLoadingState extends State<AIAnalysisLoading>
    with TickerProviderStateMixin {
  late AnimationController _progressController;
  late AnimationController _stepController;
  late Animation<double> _progressAnimation;
  late Animation<double> _stepAnimation;
  
  int _currentStep = 0;
  bool _isComplete = false;

  @override
  void initState() {
    super.initState();
    
    _progressController = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    
    _stepController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOut,
    ));
    
    _stepAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _stepController,
      curve: Curves.easeInOut,
    ));
    
    _startAnalysis();
  }

  void _startAnalysis() async {
    // Start progress animation
    _progressController.forward();
    
    // Animate through each step
    for (int i = 0; i < widget.analysisSteps.length; i++) {
      setState(() {
        _currentStep = i;
      });
      
      await _stepController.forward();
      await Future.delayed(Duration(milliseconds: 1200));
      
      if (i < widget.analysisSteps.length - 1) {
        _stepController.reset();
      }
    }
    
    setState(() {
      _isComplete = true;
    });
    
    // Wait a bit then call onComplete
    await Future.delayed(Duration(milliseconds: 1000));
    if (widget.onComplete != null) {
      widget.onComplete!();
    }
  }

  @override
  void dispose() {
    _progressController.dispose();
    _stepController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: Container(
        decoration: BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(20.w),
            child: Column(
              children: [
                SizedBox(height: 40.h),
                
                // AI Brain Icon
                Container(
                  width: 100.w,
                  height: 100.w,
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryGreen.withValues(alpha: 0.3),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.psychology,
                    color: AppColors.white,
                    size: 50.sp,
                  ),
                ),
                
                SizedBox(height: 30.h),
                
                // Title
                Text(
                  widget.title,
                  style: GoogleFonts.poppins(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                SizedBox(height: 8.h),
                
                // Subtitle
                Text(
                  widget.subtitle,
                  style: GoogleFonts.poppins(
                    fontSize: 16.sp,
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                SizedBox(height: 40.h),
                
                // Progress Bar
                Container(
                  width: double.infinity,
                  height: 8.h,
                  decoration: BoxDecoration(
                    color: AppColors.greyLight,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: AnimatedBuilder(
                    animation: _progressAnimation,
                    builder: (context, child) {
                      return FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: _progressAnimation.value,
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.primaryGreen,
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                
                SizedBox(height: 20.h),
                
                // Current Step
                if (_currentStep < widget.analysisSteps.length)
                  _buildCurrentStep(),
                
                SizedBox(height: 30.h),
                
                // Analysis Steps
                Expanded(
                  child: ListView.builder(
                    itemCount: widget.analysisSteps.length,
                    itemBuilder: (context, index) {
                      return _buildAnalysisStep(index);
                    },
                  ),
                ),
                
                SizedBox(height: 20.h),
                
                // Loading Indicator
                if (!_isComplete)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 20.w,
                        height: 20.w,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryGreen),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Text(
                        'AI is analyzing...',
                        style: GoogleFonts.poppins(
                          fontSize: 14.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                
                if (_isComplete)
                  Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: AppColors.success),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle, color: AppColors.success, size: 20.sp),
                        SizedBox(width: 8.w),
                        Text(
                          'Analysis Complete!',
                          style: GoogleFonts.poppins(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.success,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentStep() {
    if (_currentStep >= widget.analysisSteps.length) return SizedBox.shrink();
    
    final step = widget.analysisSteps[_currentStep];
    
    return AnimatedBuilder(
      animation: _stepAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: 0.8 + (_stepAnimation.value * 0.2),
          child: Opacity(
            opacity: 0.6 + (_stepAnimation.value * 0.4),
            child: Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: AppColors.primaryGreen.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: AppColors.primaryGreen),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 24.w,
                        height: 24.w,
                        decoration: BoxDecoration(
                          color: AppColors.primaryGreen,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${step['step']}',
                            style: GoogleFonts.poppins(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.bold,
                              color: AppColors.white,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Text(
                          step['title'],
                          style: GoogleFonts.poppins(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryGreen,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    step['description'],
                    style: GoogleFonts.poppins(
                      fontSize: 14.sp,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    step['details'],
                    style: GoogleFonts.poppins(
                      fontSize: 12.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnalysisStep(int index) {
    final step = widget.analysisSteps[index];
    final isCompleted = index < _currentStep;
    final isCurrent = index == _currentStep;
    
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isCompleted 
            ? AppColors.success.withValues(alpha: 0.1)
            : isCurrent
                ? AppColors.primaryGreen.withValues(alpha: 0.1)
                : AppColors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: isCompleted 
              ? AppColors.success
              : isCurrent
                  ? AppColors.primaryGreen
                  : AppColors.greyLight,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 32.w,
            height: 32.w,
            decoration: BoxDecoration(
              color: isCompleted 
                  ? AppColors.success
                  : isCurrent
                      ? AppColors.primaryGreen
                      : AppColors.greyLight,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: isCompleted
                  ? Icon(Icons.check, color: AppColors.white, size: 16.sp)
                  : Text(
                      '${step['step']}',
                      style: GoogleFonts.poppins(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.white,
                      ),
                    ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step['title'],
                  style: GoogleFonts.poppins(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: isCompleted || isCurrent 
                        ? AppColors.textPrimary 
                        : AppColors.textSecondary,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  step['description'],
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
    );
  }
}
