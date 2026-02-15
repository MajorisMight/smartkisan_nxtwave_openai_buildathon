import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/app_colors.dart';
import '../models/product.dart';
import '../providers/marketplace_provider.dart';
import 'add_market_listing_screen.dart';

class MarketplaceScreen extends ConsumerStatefulWidget {
  const MarketplaceScreen({super.key});

  @override
  ConsumerState<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends ConsumerState<MarketplaceScreen> {
  final TextEditingController _searchController = TextEditingController();

  final List<String> _categories = const [
    'All',
    'Fertilizers',
    'Seeds',
    'Pesticides',
    'Equipment',
    'Organic',
  ];

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
              _buildHeader(),
              _buildSearchBar(),
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
                      itemBuilder:
                          (context, index) =>
                              _buildProductCard(filteredProducts[index]),
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

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(20.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Marketplace',
                style: GoogleFonts.poppins(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                'Buy & Sell Agricultural Products',
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
                tooltip: 'Refresh',
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

  Widget _buildSearchBar() {
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
            hintText: 'Search products...',
            prefixIcon: const Icon(
              Icons.search,
              color: AppColors.textSecondary,
            ),
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
                  category,
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

  Widget _buildProductCard(Product product) {
    final imageUrl =
        product.imageUrls.isNotEmpty ? product.imageUrls.first : null;
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
                          'ORGANIC',
                          style: GoogleFonts.poppins(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.organic,
                          ),
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 8.h),
                Text(
                  product.description.isEmpty
                      ? 'No description added.'
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
                      child: const Text('View'),
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
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(product.name),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Price: Rs ${product.price.toStringAsFixed(2)}/${product.unit}',
                ),
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
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Text(
        'No products found',
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
