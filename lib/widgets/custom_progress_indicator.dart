import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

class CustomProgressIndicator extends StatelessWidget {
  final double value;
  final double? height;
  final Color? backgroundColor;
  final Color? valueColor;
  final String? label;
  final double? fontSize;
  final EdgeInsetsGeometry? padding;

  const CustomProgressIndicator({
    super.key,
    required this.value,
    this.height,
    this.backgroundColor,
    this.valueColor,
    this.label,
    this.fontSize,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveHeight = height ?? 8.h;
    final effectiveBackgroundColor = backgroundColor ?? AppColors.greenLight.withOpacity(0.3);
    final effectiveValueColor = valueColor ?? AppColors.primaryGreen;
    final effectiveFontSize = fontSize ?? 12.sp;
    final effectivePadding = padding ?? EdgeInsets.symmetric(vertical: 8.h);

    return Container(
      padding: effectivePadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label != null) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  label!,
                  style: GoogleFonts.poppins(
                    fontSize: effectiveFontSize,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  '${(value * 100).toInt()}%',
                  style: GoogleFonts.poppins(
                    fontSize: effectiveFontSize,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
          ],
          ClipRRect(
            borderRadius: BorderRadius.circular(effectiveHeight / 2),
            child: LinearProgressIndicator(
              value: value,
              backgroundColor: effectiveBackgroundColor,
              valueColor: AlwaysStoppedAnimation<Color>(effectiveValueColor),
              minHeight: effectiveHeight,
            ),
          ),
        ],
      ),
    );
  }
}
