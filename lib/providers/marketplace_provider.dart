import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';
import '../models/product.dart';

// 1. Fetch Products Provider
final productsProvider = FutureProvider<List<Product>>((ref) async {
  final supabase = Supabase.instance.client;
  
  // Fetch products and join with 'farmers' table to get the seller's name
  final response = await supabase
      .from('products')
      .select('*, farmers(name)')
      .order('created_at', ascending: false);

  return (response as List).map((e) => Product.fromMap(e)).toList();
});

// 2. Filter Logic (Category & Search)
final selectedCategoryProvider = StateProvider<String>((ref) => 'All');
final productSearchProvider = StateProvider<String>((ref) => '');

final filteredProductsProvider = Provider<List<Product>>((ref) {
  final products = ref.watch(productsProvider).value ?? [];
  final category = ref.watch(selectedCategoryProvider);
  final search = ref.watch(productSearchProvider).toLowerCase();

  return products.where((product) {
    final matchesCategory = category == 'All' || product.category == category;
    final matchesSearch = product.name.toLowerCase().contains(search) || 
                          product.description.toLowerCase().contains(search);
    return matchesCategory && matchesSearch;
  }).toList();
});

class MarketplaceActionsNotifier extends StateNotifier<AsyncValue<void>> {
  MarketplaceActionsNotifier() : super(const AsyncValue.data(null));

  Future<void> addProduct({
    required String name,
    required double price,
    required String category,
    required String unit,
    required String description,
    required double stockQuantity,
    required bool isOrganic,
    File? imageFile,
    String location = 'Jaipur, Rajasthan',
    String imageUrl = 'https://via.placeholder.com/600x400.png?text=Product',
  }) async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;
    if (user == null) {
      throw Exception('User not logged in');
    }

    state = const AsyncValue.loading();
    try {
      var finalImageUrl = imageUrl;
      if (imageFile != null) {
        final uploadedUrl = await _uploadProductImage(
          supabase: supabase,
          userId: user.id,
          imageFile: imageFile,
        );
        if (uploadedUrl == null || uploadedUrl.isEmpty) {
          throw Exception('Image upload failed');
        }
        finalImageUrl = uploadedUrl;
      }

      await supabase.from('products').insert({
        'farmer_id': user.id,
        'name': name,
        'description': description,
        'price': price,
        'category': category,
        'unit': unit,
        'stock_quantity': stockQuantity,
        'is_organic': isOrganic,
        'image_urls': <String>[finalImageUrl],
        'location': location,
      });
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> deleteProduct({
    required String productId,
    required String farmerId,
  }) async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception('User not logged in');
    if (user.id != farmerId) {
      debugPrint(
        'Marketplace delete blocked: user=${user.id} productFarmer=$farmerId',
      );
      throw Exception('Not authorized');
    }

    state = const AsyncValue.loading();
    try {
      debugPrint('Marketplace delete start: productId=$productId user=${user.id}');
      final deleted = await supabase
          .from('products')
          .delete()
          .eq('id', productId)
          .eq('farmer_id', user.id)
          .select('id');

      final deletedList = deleted is List ? deleted : const [];
      if (deletedList.isEmpty) {
        debugPrint(
          'Marketplace delete no-op: productId=$productId user=${user.id}',
        );
        throw Exception('Delete failed: no matching row');
      }

      debugPrint(
        'Marketplace delete success: productId=$productId rows=${deletedList.length}',
      );
      state = const AsyncValue.data(null);
    } catch (e, st) {
      debugPrint('Marketplace delete failed: $e');
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<String?> _uploadProductImage({
    required SupabaseClient supabase,
    required String userId,
    required File imageFile,
  }) async {
    final fileToUpload = await _compressForUpload(imageFile);
    final ext = p.extension(fileToUpload.path).toLowerCase();
    final fileExt = ext.isEmpty ? '.jpg' : ext;
    final fileName = '${DateTime.now().millisecondsSinceEpoch}$fileExt';
    // Inside the 'marketplace' bucket, first folder must be auth uid for RLS.
    final filePath = '$userId/$fileName';

    await supabase.storage.from('marketplace').upload(
          filePath,
          fileToUpload,
          fileOptions: const FileOptions(
            cacheControl: '3600',
            upsert: false,
          ),
        );

    return supabase.storage.from('marketplace').getPublicUrl(filePath);
  }

  Future<File> _compressForUpload(File source) async {
    try {
      final sourceSize = source.lengthSync();
      final tempDir = await getTemporaryDirectory();
      final targetPath =
          p.join(tempDir.path, 'market_${DateTime.now().millisecondsSinceEpoch}.jpg');

      final compressed = await FlutterImageCompress.compressAndGetFile(
        source.path,
        targetPath,
        quality: 70,
        minWidth: 1280,
        minHeight: 1280,
        format: CompressFormat.jpeg,
      );

      if (compressed == null) {
        debugPrint(
          'Marketplace image: compression returned null, using original. bytes=$sourceSize',
        );
        return source;
      }

      final compressedFile = File(compressed.path);
      final compressedSize = compressedFile.lengthSync();
      final ratio =
          sourceSize == 0 ? 0 : ((sourceSize - compressedSize) / sourceSize) * 100;
      debugPrint(
        'Marketplace image: compressed. original=$sourceSize bytes, compressed=$compressedSize bytes, saved=${ratio.toStringAsFixed(1)}%',
      );
      return compressedFile;
    } on MissingPluginException catch (e) {
      debugPrint('Marketplace image: compression plugin missing, using original. $e');
      return source;
    } on PlatformException catch (e) {
      debugPrint('Marketplace image: compression failed, using original. $e');
      return source;
    } catch (e) {
      debugPrint('Marketplace image: unexpected compression error, using original. $e');
      return source;
    }
  }
}

final marketplaceActionsProvider =
    StateNotifierProvider<MarketplaceActionsNotifier, AsyncValue<void>>((ref) {
  return MarketplaceActionsNotifier();
});
