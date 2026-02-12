import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

class CustomDialog extends StatelessWidget {
  final String title;
  final String content;
  final String? confirmText;
  final String? cancelText;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final Color? confirmColor;
  final Color? cancelColor;
  final IconData? icon;
  final Color? iconColor;

  const CustomDialog({
    super.key,
    required this.title,
    required this.content,
    this.confirmText,
    this.cancelText,
    this.onConfirm,
    this.onCancel,
    this.confirmColor,
    this.cancelColor,
    this.icon,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveConfirmText = confirmText ?? 'Confirm';
    final effectiveCancelText = cancelText ?? 'Cancel';
    final effectiveConfirmColor = confirmColor ?? AppColors.primaryGreen;
    final effectiveCancelColor = cancelColor ?? AppColors.textSecondary;
    final effectiveIconColor = iconColor ?? AppColors.primaryGreen;

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
      ),
      title: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, color: effectiveIconColor, size: 24.sp),
            SizedBox(width: 12.w),
          ],
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
      content: Text(
        content,
        style: GoogleFonts.poppins(
          fontSize: 14.sp,
          color: AppColors.textPrimary,
        ),
      ),
      actions: [
        if (onCancel != null)
          TextButton(
            onPressed: onCancel,
            child: Text(
              effectiveCancelText,
              style: GoogleFonts.poppins(
                fontSize: 14.sp,
                color: effectiveCancelColor,
              ),
            ),
          ),
        ElevatedButton(
          onPressed: onConfirm,
          style: ElevatedButton.styleFrom(
            backgroundColor: effectiveConfirmColor,
            foregroundColor: AppColors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.r),
            ),
          ),
          child: Text(
            effectiveConfirmText,
            style: GoogleFonts.poppins(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
