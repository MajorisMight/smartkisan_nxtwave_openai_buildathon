import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/app_colors.dart';
import '../providers/marketplace_provider.dart';
import '../services/storage_service.dart';

class AddMarketListingScreen extends ConsumerStatefulWidget {
  const AddMarketListingScreen({required this.categories, super.key});

  final List<String> categories;

  @override
  ConsumerState<AddMarketListingScreen> createState() =>
      _AddMarketListingScreenState();
}

class _AddMarketListingScreenState
    extends ConsumerState<AddMarketListingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();
  final StorageService _storageService = StorageService();

  late String _selectedCategory;
  String _selectedUnit = 'kg';
  bool _isOrganic = false;
  bool _isSaving = false;
  File? _selectedImageFile;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.categories.first;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Listing')),
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
                      'Create a market listing',
                      style: GoogleFonts.poppins(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 14.h),
                    TextFormField(
                      controller: _nameController,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Product Name',
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Product name is required';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 12.h),
                    TextFormField(
                      controller: _descriptionController,
                      minLines: 3,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                      ),
                    ),
                    SizedBox(height: 12.h),
                    TextFormField(
                      controller: _priceController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(labelText: 'Price'),
                      validator: (value) {
                        final parsed = double.tryParse((value ?? '').trim());
                        if (parsed == null || parsed <= 0) {
                          return 'Enter a valid price';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 12.h),
                    TextFormField(
                      controller: _stockController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      textInputAction: TextInputAction.done,
                      decoration: const InputDecoration(
                        labelText: 'Stock Quantity',
                      ),
                      validator: (value) {
                        final parsed = double.tryParse((value ?? '').trim());
                        if (parsed == null || parsed <= 0) {
                          return 'Enter a valid stock quantity';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 12.h),
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
                          _isSaving
                              ? null
                              : (value) {
                                if (value == null) return;
                                setState(() => _selectedCategory = value);
                              },
                    ),
                    SizedBox(height: 12.h),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedUnit,
                      items:
                          const ['kg', 'quintal', 'ton', 'packet', 'piece']
                              .map(
                                (unit) => DropdownMenuItem<String>(
                                  value: unit,
                                  child: Text(unit),
                                ),
                              )
                              .toList(),
                      decoration: const InputDecoration(labelText: 'Unit'),
                      onChanged:
                          _isSaving
                              ? null
                              : (value) {
                                if (value == null) return;
                                setState(() => _selectedUnit = value);
                              },
                    ),
                    SizedBox(height: 4.h),
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      value: _isOrganic,
                      title: const Text('Organic product'),
                      onChanged:
                          _isSaving
                              ? null
                              : (value) {
                                setState(() => _isOrganic = value ?? false);
                              },
                    ),
                    SizedBox(height: 8.h),
                    OutlinedButton.icon(
                      onPressed:
                          _isSaving
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
                            ? 'Add Product Photo'
                            : 'Change Product Photo',
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
                        onPressed: _isSaving ? null : _submit,
                        child: Text(_isSaving ? 'Saving...' : 'Save Listing'),
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

    final name = _nameController.text.trim();
    final description = _descriptionController.text.trim();
    final price = double.parse(_priceController.text.trim());
    final stock = double.parse(_stockController.text.trim());

    setState(() => _isSaving = true);
    try {
      await ref
          .read(marketplaceActionsProvider.notifier)
          .addProduct(
            name: name,
            description: description,
            price: price,
            category: _selectedCategory,
            unit: _selectedUnit,
            stockQuantity: stock,
            isOrganic: _isOrganic,
            imageFile: _selectedImageFile,
          );

      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Unable to add product: $e')));
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }
}
