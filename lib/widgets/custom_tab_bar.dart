import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

class CustomTabBar extends StatelessWidget {
  final List<String> tabs;
  final int selectedIndex;
  final Function(int) onTap;
  final Color? selectedColor;
  final Color? unselectedColor;
  final Color? indicatorColor;
  final double? indicatorHeight;
  final EdgeInsetsGeometry? padding;
  final bool isScrollable;

  const CustomTabBar({
    super.key,
    required this.tabs,
    required this.selectedIndex,
    required this.onTap,
    this.selectedColor,
    this.unselectedColor,
    this.indicatorColor,
    this.indicatorHeight,
    this.padding,
    this.isScrollable = false,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveSelectedColor = selectedColor ?? AppColors.primaryGreen;
    final effectiveUnselectedColor = unselectedColor ?? AppColors.textSecondary;
    final effectiveIndicatorColor = indicatorColor ?? AppColors.primaryGreen;
    final effectiveIndicatorHeight = indicatorHeight ?? 3.h;
    final effectivePadding = padding ?? EdgeInsets.symmetric(horizontal: 20.w);

    return Container(
      padding: effectivePadding,
      child: TabBar(
        tabs: tabs.map((tab) => Tab(
          child: Text(
            tab,
            style: GoogleFonts.poppins(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        )).toList(),
        isScrollable: isScrollable,
        indicatorColor: effectiveIndicatorColor,
        indicatorWeight: effectiveIndicatorHeight,
        labelColor: effectiveSelectedColor,
        unselectedLabelColor: effectiveUnselectedColor,
        onTap: onTap,
      ),
    );
  }
}
