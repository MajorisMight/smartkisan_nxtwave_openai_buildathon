import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';

import '../constants/app_colors.dart';
import '../models/field.dart';
import '../models/diary_entry.dart';
import '../widgets/diary_entry_card.dart';
import '../widgets/entry_detail_model.dart';
import '../widgets/quick_log_sheet.dart';
import '../services/demo_data_service.dart';

class FieldDiaryScreen extends StatefulWidget {
  final Field field;
  const FieldDiaryScreen({super.key, required this.field});

  @override
  State<FieldDiaryScreen> createState() => _FieldDiaryScreenState();
}

class _FieldDiaryScreenState extends State<FieldDiaryScreen> {
  List<DiaryEntry> _diaryEntries = [];
  
  @override
  void initState() {
    super.initState();
    _loadDiaryEntries();
  }
  
  void _loadDiaryEntries() {
    // Load demo diary entries for this field
    final allEntries = DemoDataService.getDemoDiaryEntries();
    _diaryEntries = allEntries.where((entry) => entry.fieldId == widget.field.id).toList();
  }

  void _openEntryDetail(DiaryEntry entry) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EntryDetailModal(entry: entry),
    );
  }

  void _openQuickLog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => QuickLogSheet(fields: [widget.field]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildFiltersAndSearch(),
              Expanded(child: _buildTimeline()),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primaryGreen,
        onPressed: _openQuickLog,
        child: Icon(Icons.add, color: AppColors.white),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.fromLTRB(4.w, 20.w, 20.w, 10.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(children: [
              IconButton(
                icon: Icon(Icons.arrow_back, color: AppColors.primaryGreen, size: 24.sp),
                onPressed: () => context.go('/home'),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${widget.field.name} - Diary', style: GoogleFonts.poppins(fontSize: 24.sp, fontWeight: FontWeight.bold, color: AppColors.textPrimary), overflow: TextOverflow.ellipsis),
                    Text('Chronological farm history', style: GoogleFonts.poppins(fontSize: 14.sp, color: AppColors.textSecondary), overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
            ]),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(color: AppColors.primaryGreen.withOpacity(0.1), borderRadius: BorderRadius.circular(20.r)),
            child: Row(
              children: [
                Icon(Icons.sync, color: AppColors.primaryGreen, size: 16.sp),
                SizedBox(width: 6.w),
                Text('Synced', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: AppColors.primaryGreen)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltersAndSearch() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
      child: Row(
        children: [
          ElevatedButton.icon(
            onPressed: () {},
            icon: Icon(Icons.filter_list, size: 16.sp),
            label: Text('Filter'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.white,
              foregroundColor: AppColors.textPrimary,
              elevation: 2,
              shadowColor: AppColors.shadowLight,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search in diary...',
                prefixIcon: Icon(Icons.search, color: AppColors.textSecondary),
                filled: true,
                fillColor: AppColors.white,
                contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 16.w),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(30.r), borderSide: BorderSide.none),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeline() {
    if (_diaryEntries.isEmpty) {
      return Center(child: Text("No diary entries yet."));
    }

    Map<DateTime, List<DiaryEntry>> groupedEntries = {};
    for (var entry in _diaryEntries) {
      final date = DateTime(entry.date.year, entry.date.month, entry.date.day);
      groupedEntries.putIfAbsent(date, () => []).add(entry);
    }

    final sortedDates = groupedEntries.keys.toList()..sort((a, b) => b.compareTo(a));

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      itemCount: sortedDates.length,
      itemBuilder: (context, index) {
        final date = sortedDates[index];
        final entries = groupedEntries[date]!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(vertical: 16.h),
              child: Text(
                DateFormat('EEEE, d MMM yyyy').format(date),
                style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: AppColors.textSecondary),
              ),
            ),
            ...entries.map((entry) => DiaryEntryCard(entry: entry, onTap: () => _openEntryDetail(entry))),
          ],
        );
      },
    );
  }
}
