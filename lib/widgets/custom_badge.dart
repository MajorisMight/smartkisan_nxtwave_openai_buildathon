import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

class CustomBadge extends StatelessWidget {
  final String text;
  final Color? backgroundColor;
  final Color? textColor;
  final double? fontSize;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final double? minWidth;
  final double? minHeight;

  const CustomBadge({
    super.key,
    required this.text,
    this.backgroundColor,
    this.textColor,
    this.fontSize,
    this.padding,
    this.borderRadius,
    this.minWidth,
    this.minHeight,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBackgroundColor = backgroundColor ?? AppColors.primaryGreen;
    final effectiveTextColor = textColor ?? AppColors.white;
    final effectiveFontSize = fontSize ?? 12.sp;
    final effectivePadding = padding ?? EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h);
    final effectiveBorderRadius = borderRadius ?? BorderRadius.circular(12.r);
    final effectiveMinWidth = minWidth ?? 20.w;
    final effectiveMinHeight = minHeight ?? 20.h;

    return Container(
      constraints: BoxConstraints(
        minWidth: effectiveMinWidth,
        minHeight: effectiveMinHeight,
      ),
      padding: effectivePadding,
      decoration: BoxDecoration(
        color: effectiveBackgroundColor,
        borderRadius: effectiveBorderRadius,
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: effectiveFontSize,
          fontWeight: FontWeight.w600,
          color: effectiveTextColor,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
