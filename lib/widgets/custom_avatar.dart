import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../constants/app_colors.dart';

class CustomAvatar extends StatelessWidget {
  final String? imageUrl;
  final String? name;
  final double? radius;
  final Color? backgroundColor;
  final Color? textColor;
  final IconData? fallbackIcon;
  final bool showBorder;
  final Color? borderColor;
  final double? borderWidth;

  const CustomAvatar({
    super.key,
    this.imageUrl,
    this.name,
    this.radius,
    this.backgroundColor,
    this.textColor,
    this.fallbackIcon,
    this.showBorder = false,
    this.borderColor,
    this.borderWidth,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveRadius = radius ?? 20.r;
    final effectiveBackgroundColor = backgroundColor ?? AppColors.primaryGreen;
    final effectiveTextColor = textColor ?? AppColors.white;
    final effectiveFallbackIcon = fallbackIcon ?? Icons.person;
    final effectiveBorderColor = borderColor ?? AppColors.primaryGreen;
    final effectiveBorderWidth = borderWidth ?? 2.0;

    Widget avatar = CircleAvatar(
      radius: effectiveRadius,
      backgroundColor: effectiveBackgroundColor,
      child: imageUrl != null && imageUrl!.isNotEmpty
          ? ClipOval(
              child: imageUrl!.startsWith('assets/')
                  ? Image.asset(
                      imageUrl!,
                      width: effectiveRadius * 2,
                      height: effectiveRadius * 2,
                      fit: BoxFit.cover,
                    )
                  : CachedNetworkImage(
                      imageUrl: imageUrl!,
                      width: effectiveRadius * 2,
                      height: effectiveRadius * 2,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        width: effectiveRadius * 2,
                        height: effectiveRadius * 2,
                        color: effectiveBackgroundColor,
                        child: Icon(
                          effectiveFallbackIcon,
                          color: effectiveTextColor,
                          size: effectiveRadius,
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        width: effectiveRadius * 2,
                        height: effectiveRadius * 2,
                        color: effectiveBackgroundColor,
                        child: Icon(
                          effectiveFallbackIcon,
                          color: effectiveTextColor,
                          size: effectiveRadius,
                        ),
                      ),
                    ),
            )
          : name != null && name!.isNotEmpty
              ? Text(
                  name!.substring(0, 1).toUpperCase(),
                  style: TextStyle(
                    fontSize: effectiveRadius * 0.6,
                    fontWeight: FontWeight.bold,
                    color: effectiveTextColor,
                  ),
                )
              : Icon(
                  effectiveFallbackIcon,
                  color: effectiveTextColor,
                  size: effectiveRadius,
                ),
    );

    if (showBorder) {
      return Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: effectiveBorderColor,
            width: effectiveBorderWidth,
          ),
        ),
        child: avatar,
      );
    }

    return avatar;
  }
}
