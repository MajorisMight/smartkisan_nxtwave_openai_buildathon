import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';
import '../app_extensions.dart';
import '../constants/app_colors.dart';
import '../models/product.dart';
import '../providers/marketplace_provider.dart';
import '../services/storage_service.dart';
import 'add_market_listing_screen.dart';

class MarketplaceScreen extends ConsumerStatefulWidget {
  const MarketplaceScreen({super.key});

  @override
  ConsumerState<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends ConsumerState<MarketplaceScreen> {
  final TextEditingController _searchController = TextEditingController();
  final StorageService _storageService = StorageService();

  final List<String> _categories = const [
    'All',
    'Fertilizers',
    'Seeds',
    'Pesticides',
    'Equipment',
    'Organic',
  ];

  // Helper to convert internal keys (database) to display text (UI)
  String _getLocalizedCategory(String key) {
    switch (key) {
      case 'All':
        return context.l10n.catAll;
      case 'Fertilizers':
        return context.l10n.catFertilizers;
      case 'Seeds':
        return context.l10n.catSeeds;
      case 'Pesticides':
        return context.l10n.catPesticides;
      case 'Equipment':
        return context.l10n.catEquipment;
      case 'Organic':
        return context.l10n.catOrganic;
      default:
        return key;
    }
  }

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      ref.read(productSearchProvider.notifier).state = _searchController.text;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(productsProvider);
    final filteredProducts = ref.watch(filteredProductsProvider);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              _buildSearchBar(context),
              _buildCategories(),
              Expanded(
                child: productsAsync.when(
                  loading:
                      () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) => _errorState('Unable to load products.\n$e'),
                  data: (_) {
                    if (filteredProducts.isEmpty) {
                      return _emptyState();
                    }
                    return ListView.builder(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      itemCount: filteredProducts.length,
                      itemBuilder: (context, index) =>
                          _buildProductCard(filteredProducts[index], context),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddMarketListingPage,
        backgroundColor: AppColors.primaryGreen,
        child: const Icon(Icons.add, color: AppColors.white),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.navMarketplace,
                style: GoogleFonts.poppins(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                context.l10n.marketSubtitle,
                style: GoogleFonts.poppins(
                  fontSize: 14.sp,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          Row(
            children: [
              IconButton(
                tooltip: context.l10n.btnRefresh,
                onPressed: () {
                  ref.invalidate(productsProvider);
                },
                icon: Icon(
                  Icons.refresh,
                  color: AppColors.primaryGreen,
                  size: 24.sp,
                ),
              ),
              Container(
                width: 40.w,
                height: 40.w,
                decoration: const BoxDecoration(
                  color: AppColors.primaryGreen,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.storefront_outlined,
                  color: AppColors.white,
                  size: 20.sp,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadowLight,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: context.l10n.marketSearchHint,
            prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 12.h,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategories() {
    final selected = ref.watch(selectedCategoryProvider);
    return SizedBox(
      height: 50.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = selected == category;

          return GestureDetector(
            onTap:
                () =>
                    ref.read(selectedCategoryProvider.notifier).state =
                        category,
            child: Container(
              margin: EdgeInsets.only(right: 12.w),
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primaryGreen : AppColors.white,
                borderRadius: BorderRadius.circular(20.r),
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.shadowLight,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  _getLocalizedCategory(category),
                  style: GoogleFonts.poppins(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: isSelected ? AppColors.white : AppColors.textPrimary,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductCard(Product product, BuildContext context) {
    final currentUserId = Supabase.instance.client.auth.currentUser?.id;
    final imageUrl = product.imageUrls.isNotEmpty ? product.imageUrls.first : null;
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
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
          ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16.r),
              topRight: Radius.circular(16.r),
            ),
            child: SizedBox(
              height: 180.h,
              width: double.infinity,
              child:
                  imageUrl == null || imageUrl.isEmpty
                      ? Image.asset(
                        'assets/images/farmer.jpg',
                        fit: BoxFit.cover,
                      )
                      : Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) {
                          return Image.asset(
                            'assets/images/farmer.jpg',
                            fit: BoxFit.cover,
                          );
                        },
                      ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        product.name,
                        style: GoogleFonts.poppins(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    if (product.isOrganic)
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.organic.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: Text(
                          context.l10n.marketLabelOrganic,
                          style: GoogleFonts.poppins(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.organic,
                          ),
                        ),
                      ),
                    if (currentUserId != null &&
                        currentUserId == product.farmerId)
                      IconButton(
                        icon: Icon(
                          Icons.delete_outline,
                          size: 18.sp,
                          color: AppColors.textSecondary,
                        ),
                        tooltip: 'Delete listing',
                        onPressed: () => _deleteProduct(product),
                      ),
                  ],
                ),
                SizedBox(height: 8.h),
                Text(
                  product.description.isEmpty
                      ? context.l10n.marketNoDescription
                      : product.description,
                  style: GoogleFonts.poppins(
                    fontSize: 14.sp,
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 10.h),
                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      color: AppColors.textSecondary,
                      size: 16.sp,
                    ),
                    SizedBox(width: 4.w),
                    Expanded(
                      child: Text(
                        product.location,
                        style: GoogleFonts.poppins(
                          fontSize: 12.sp,
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 14.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Rs ${product.price.toStringAsFixed(2)}/${product.unit}',
                          style: GoogleFonts.poppins(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryGreen,
                          ),
                        ),
                        Text(
                          'Stock: ${product.stockQuantity.toStringAsFixed(1)} ${product.unit}',
                          style: GoogleFonts.poppins(
                            fontSize: 12.sp,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    OutlinedButton(
                      onPressed: () => _showProductDetails(product),
                      child: Text(context.l10n.btnView),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showAddProductDialog() async {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final priceController = TextEditingController();
    final stockController = TextEditingController();

    String selectedCategory = _categories[1];
    String selectedUnit = 'kg';
    bool isOrganic = false;
    bool isSaving = false;
    File? selectedImageFile;

    await showDialog<void>(
      context: this.context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(context.l10n.addProductTitle),
              content: SizedBox(
                width: 320,
                child: SingleChildScrollView(
                  child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(labelText: context.l10n.addProductLabelName),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: descriptionController,
                      maxLines: 3,
                      decoration: InputDecoration(labelText: context.l10n.addProductLabelDesc),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: priceController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(labelText: context.l10n.addProductLabelPrice),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: stockController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(labelText: context.l10n.addProductLabelStock),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      initialValue: selectedCategory,
                      items: _categories
                          .where((e) => e != 'All')
                          .map(
                            (c) => DropdownMenuItem<String>(
                              value: c,
                              child: Text(_getLocalizedCategory(c)),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value == null) return;
                        setDialogState(() => selectedCategory = value);
                      },
                      decoration: InputDecoration(labelText: context.l10n.addProductLabelCategory),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      initialValue: selectedUnit,
                      items:  [context.l10n.weightUnitKg, context.l10n.weightUnitQuintal, context.l10n.weightUnitTon, context.l10n.weightUnitBag, context.l10n.weightUnitPiece]
                          .map(
                            (u) => DropdownMenuItem<String>(
                              value: u,
                              child: Text(u),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value == null) return;
                        setDialogState(() => selectedUnit = value);
                      },
                      decoration: InputDecoration(labelText: context.l10n.addProductLabelUnit),
                    ),
                    const SizedBox(height: 8),
                    CheckboxListTile(
                      value: isOrganic,
                      contentPadding: EdgeInsets.zero,
                      title: Text(context.l10n.addProductCheckboxOrganic),
                      onChanged: (value) {
                        setDialogState(() => isOrganic = value ?? false);
                      },
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: isSaving
                          ? null
                          : () async {
                              final file =
                                  await _storageService.pickAndCompressImage();
                              if (file == null) return;
                              setDialogState(() => selectedImageFile = file);
                            },
                      icon: const Icon(Icons.photo_library_outlined),
                      label: Text(
                        selectedImageFile == null
                            ? context.l10n.addProductBtnAddPhoto
                            : context.l10n.addProductBtnChangePhoto,
                      ),
                    ),
                    if (selectedImageFile != null) ...[
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 120,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            selectedImageFile!,
                            fit: BoxFit.cover,
                            cacheWidth: 720,
                            filterQuality: FilterQuality.low,
                            errorBuilder: (_, __, ___) {
                              return Container(
                                height: 120,
                                color: AppColors.greyLight,
                                alignment: Alignment.center,
                                child: Text(context.l10n.imgPreviewUnavailable),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: Text(context.l10n.btnCancel),
                ),
                ElevatedButton(
                  onPressed: isSaving
                      ? null
                      : () async {
                          final name = nameController.text.trim();
                          final description = descriptionController.text.trim();
                          final price = double.tryParse(priceController.text.trim());
                          final stock = double.tryParse(stockController.text.trim());

                          if (name.isEmpty || price == null || stock == null) {
                            ScaffoldMessenger.of(dialogContext).showSnackBar(
                              SnackBar(
                                content: Text(context.l10n.addProductMsgRequired),
                              ),
                            );
                            return;
                          }

                          setDialogState(() => isSaving = true);
                          try {
                            await ref
                                .read(marketplaceActionsProvider.notifier)
                                .addProduct(
                                  name: name,
                                  description: description,
                                  price: price,
                                  category: selectedCategory,
                                  unit: selectedUnit,
                                  stockQuantity: stock,
                                  isOrganic: isOrganic,
                                  imageFile: selectedImageFile,
                                );

                            ref.invalidate(productsProvider);

                            if (!dialogContext.mounted) return;
                            Navigator.pop(dialogContext);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(context.l10n.addProductMsgSuccess),
                              ),
                            );
                          } catch (e) {
                            if (!dialogContext.mounted) return;
                            ScaffoldMessenger.of(dialogContext).showSnackBar(
                              SnackBar(content: Text(context.l10n.addProductMsgError(e.toString()))),
                            );
                          } finally {
                            if (dialogContext.mounted) {
                              setDialogState(() => isSaving = false);
                            }
                          }
                        },
                  child: Text(isSaving ? context.l10n.btnSaving : context.l10n.btnSave),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _deleteProduct(Product product) async {
    try {
      debugPrint('UI delete tap: productId=${product.id}');
      await ref.read(marketplaceActionsProvider.notifier).deleteProduct(
            productId: product.id,
            farmerId: product.farmerId,
          );
      ref.invalidate(productsProvider);
    } catch (e) {
      if (!mounted) return;
      debugPrint('UI delete failed: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not delete listing. $e')),
      );
    }
  }

  Future<void> _openAddMarketListingPage() async {
    final created = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder:
            (_) => AddMarketListingScreen(
              categories: _categories.where((e) => e != 'All').toList(),
            ),
      ),
    );
    if (created == true) {
      ref.invalidate(productsProvider);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product added successfully.')),
      );
    }
  }

  void _showProductDetails(Product product) {
    showDialog<void>(
      context: this.context,
      builder: (context) => AlertDialog(
        title: Text(product.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Price: Rs ${product.price.toStringAsFixed(2)}/${product.unit}'),
            Text('Seller: ${product.farmerName ?? 'Unknown'}'),
            Text('Location: ${product.location}'),
            Text(
              'Stock: ${product.stockQuantity.toStringAsFixed(1)} ${product.unit}',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.l10n.btnClose),
          ),
        ],
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Text(
        context.l10n.marketEmptyState,
        style: GoogleFonts.poppins(
          color: AppColors.textSecondary,
          fontSize: 14.sp,
        ),
      ),
    );
  }

  Widget _errorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(color: AppColors.textSecondary),
        ),
      ),
    );
  }
}
