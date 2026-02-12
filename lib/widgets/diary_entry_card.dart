import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';
import '../models/diary_entry.dart';

class DiaryEntryCard extends StatelessWidget {
  final DiaryEntry entry;
  final VoidCallback onTap;

  const DiaryEntryCard({super.key, required this.entry, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final activity = _getActivityDetails(entry.activityType);

    return InkWell(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 16.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowLight,
              blurRadius: 10,
              offset: Offset(0, 4),
            )
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24.r,
              backgroundColor: activity['color'].withOpacity(0.1),
              child: Icon(activity['icon'], color: activity['color'], size: 24.sp),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${activity['name']}${entry.productName.isNotEmpty ? ' - ${entry.productName}' : ''}',
                    style: GoogleFonts.poppins(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    '${entry.quantity} ${entry.unit} • ₹${entry.cost.toStringAsFixed(0)}',
                    style: GoogleFonts.poppins(fontSize: 13.sp, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            if (!entry.synced)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  'Unsynced',
                  style: GoogleFonts.poppins(fontSize: 10.sp, color: AppColors.warning, fontWeight: FontWeight.w600),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Map<String, dynamic> _getActivityDetails(String activityType) {
    switch (activityType) {
      case 'fertilizer':
        return {'name': 'Fertilizer', 'icon': Icons.grain, 'color': Colors.brown};
      case 'pesticide':
        return {'name': 'Pesticide', 'icon': Icons.bug_report, 'color': Colors.red};
      case 'irrigation':
        return {'name': 'Irrigation', 'icon': Icons.water_drop, 'color': Colors.blue};
      case 'sowing':
        return {'name': 'Sowing', 'icon': Icons.agriculture, 'color': Colors.green};
      default:
        return {'name': 'Activity', 'icon': Icons.article, 'color': Colors.grey};
    }
  }
}
