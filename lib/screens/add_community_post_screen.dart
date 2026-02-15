import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/app_colors.dart';
import '../providers/community_provider.dart';
import '../services/storage_service.dart';

class AddCommunityPostScreen extends ConsumerStatefulWidget {
  const AddCommunityPostScreen({required this.categories, super.key});

  final List<String> categories;

  @override
  ConsumerState<AddCommunityPostScreen> createState() =>
      _AddCommunityPostScreenState();
}

class _AddCommunityPostScreenState
    extends ConsumerState<AddCommunityPostScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _tagsController = TextEditingController();
  final StorageService _storageService = StorageService();

  late String _selectedCategory;
  bool _isSubmitting = false;
  File? _selectedImageFile;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.categories.first;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Post')),
      body: Container(
        decoration: BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(20.w),
            child: Form(
              key: _formKey,
              child: Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(16.r),
                  boxShadow: const [
                    BoxShadow(
                      color: AppColors.shadowLight,
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Share with the community',
                      style: GoogleFonts.poppins(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 14.h),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedCategory,
                      items:
                          widget.categories
                              .map(
                                (category) => DropdownMenuItem<String>(
                                  value: category,
                                  child: Text(category),
                                ),
                              )
                              .toList(),
                      decoration: const InputDecoration(labelText: 'Category'),
                      onChanged:
                          _isSubmitting
                              ? null
                              : (value) {
                                if (value == null) return;
                                setState(() => _selectedCategory = value);
                              },
                    ),
                    SizedBox(height: 12.h),
                    TextFormField(
                      controller: _titleController,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(labelText: 'Title'),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Title is required';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 12.h),
                    TextFormField(
                      controller: _contentController,
                      minLines: 4,
                      maxLines: 6,
                      decoration: const InputDecoration(labelText: 'Content'),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Content is required';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 12.h),
                    TextField(
                      controller: _tagsController,
                      decoration: const InputDecoration(
                        labelText: 'Tags (comma separated)',
                      ),
                    ),
                    SizedBox(height: 12.h),
                    OutlinedButton.icon(
                      onPressed:
                          _isSubmitting
                              ? null
                              : () async {
                                final file =
                                    await _storageService
                                        .pickAndCompressImage();
                                if (file == null) return;
                                setState(() => _selectedImageFile = file);
                              },
                      icon: const Icon(Icons.photo_library_outlined),
                      label: Text(
                        _selectedImageFile == null
                            ? 'Add Post Photo'
                            : 'Change Post Photo',
                      ),
                    ),
                    if (_selectedImageFile != null) ...[
                      SizedBox(height: 10.h),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8.r),
                        child: Image.file(
                          _selectedImageFile!,
                          height: 160.h,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          cacheWidth: 900,
                          filterQuality: FilterQuality.low,
                          errorBuilder:
                              (_, __, ___) => Container(
                                height: 160.h,
                                color: AppColors.greyLight,
                                alignment: Alignment.center,
                                child: const Text('Preview unavailable'),
                              ),
                        ),
                      ),
                    ],
                    SizedBox(height: 20.h),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _submit,
                        child: Text(_isSubmitting ? 'Posting...' : 'Post'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    final form = _formKey.currentState;
    if (form == null || !form.validate()) return;

    final title = _titleController.text.trim();
    final content = _contentController.text.trim();
    final tags =
        _tagsController.text
            .split(',')
            .map((tag) => tag.trim())
            .where((tag) => tag.isNotEmpty)
            .toList();

    setState(() => _isSubmitting = true);
    try {
      await ref
          .read(communityActionsProvider.notifier)
          .createPost(
            category: _selectedCategory,
            title: title,
            content: content,
            tags: tags,
            imageFile: _selectedImageFile,
          );

      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Unable to create post: $e')));
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }
}
