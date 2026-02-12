import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool centerTitle;
  final Color? backgroundColor;
  final Color? titleColor;
  final double? elevation;
  final VoidCallback? onBackPressed;

  const CustomAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.centerTitle = false,
    this.backgroundColor,
    this.titleColor,
    this.elevation,
    this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBackgroundColor = backgroundColor ?? AppColors.white;
    final effectiveTitleColor = titleColor ?? AppColors.textPrimary;
    final effectiveElevation = elevation ?? 0;

    return AppBar(
      title: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 20.sp,
          fontWeight: FontWeight.bold,
          color: effectiveTitleColor,
        ),
      ),
      backgroundColor: effectiveBackgroundColor,
      elevation: effectiveElevation,
      centerTitle: centerTitle,
      leading: leading ?? (onBackPressed != null
          ? IconButton(
              icon: Icon(Icons.arrow_back_ios, color: effectiveTitleColor),
              onPressed: onBackPressed,
            )
          : null),
      actions: actions,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
