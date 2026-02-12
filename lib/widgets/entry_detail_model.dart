import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/diary_entry.dart';
import '../constants/app_colors.dart';

class EntryDetailModal extends StatelessWidget {
  final DiaryEntry entry;
  const EntryDetailModal({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Entry Details', style: GoogleFonts.poppins(fontSize: 20.sp, fontWeight: FontWeight.bold)),
          SizedBox(height: 16.h),
          Text('Activity: ${entry.activityType}'),
          Text('Product: ${entry.productName}'),
          Text('Quantity: ${entry.quantity} ${entry.unit}'),
          Text('Cost: ₹${entry.cost}'),
          Text('Date: ${DateFormat.yMMMd().format(entry.date)}'),
          SizedBox(height: 20.h),
          Row(
            children: [
              Expanded(child: ElevatedButton.icon(onPressed: () {}, icon: Icon(Icons.edit), label: Text('Edit'))),
              SizedBox(width: 12.w),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: Icon(Icons.delete),
                  label: Text('Delete'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
