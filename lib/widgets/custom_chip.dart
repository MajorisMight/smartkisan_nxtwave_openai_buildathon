import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

class CustomChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback? onTap;
  final Color? selectedColor;
  final Color? unselectedColor;
  final Color? selectedTextColor;
  final Color? unselectedTextColor;
  final IconData? icon;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;

  const CustomChip({
    super.key,
    required this.label,
    this.isSelected = false,
    this.onTap,
    this.selectedColor,
    this.unselectedColor,
    this.selectedTextColor,
    this.unselectedTextColor,
    this.icon,
    this.padding,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveSelectedColor = selectedColor ?? AppColors.primaryGreen;
    final effectiveUnselectedColor = unselectedColor ?? AppColors.white;
    final effectiveSelectedTextColor = selectedTextColor ?? AppColors.white;
    final effectiveUnselectedTextColor = unselectedTextColor ?? AppColors.textPrimary;
    final effectivePadding = padding ?? EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h);
    final effectiveBorderRadius = borderRadius ?? BorderRadius.circular(20.r);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: effectivePadding,
        decoration: BoxDecoration(
          color: isSelected ? effectiveSelectedColor : effectiveUnselectedColor,
          borderRadius: effectiveBorderRadius,
          border: Border.all(
            color: isSelected ? effectiveSelectedColor : AppColors.borderLight,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 16.sp,
                color: isSelected ? effectiveSelectedTextColor : effectiveUnselectedTextColor,
              ),
              SizedBox(width: 6.w),
            ],
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: isSelected ? effectiveSelectedTextColor : effectiveUnselectedTextColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
