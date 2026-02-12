import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../constants/app_colors.dart';

class CustomDivider extends StatelessWidget {
  final double? height;
  final Color? color;
  final EdgeInsetsGeometry? margin;
  final double? thickness;
  final double? indent;
  final double? endIndent;

  const CustomDivider({
    super.key,
    this.height,
    this.color,
    this.margin,
    this.thickness,
    this.indent,
    this.endIndent,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveHeight = height ?? 1.h;
    final effectiveColor = color ?? AppColors.borderLight;
    final effectiveThickness = thickness ?? 1.0;
    final effectiveIndent = indent ?? 0.0;
    final effectiveEndIndent = endIndent ?? 0.0;

    return Container(
      margin: margin,
      child: Divider(
        height: effectiveHeight,
        color: effectiveColor,
        thickness: effectiveThickness,
        indent: effectiveIndent,
        endIndent: effectiveEndIndent,
      ),
    );
  }
}
