import '../models/product.dart';
import '../utils/dummy_data.dart';

class ProductService {
  // Get all products
  static Future<List<Product>> getAllProducts() async {
    // Simulate API call delay
    await Future.delayed(Duration(seconds: 1));
    return DummyData.getDummyProducts();
  }

  // Get products by category
  static Future<List<Product>> getProductsByCategory(String category) async {
    // Simulate API call delay
    await Future.delayed(Duration(seconds: 1));
  return DummyData.getDummyProducts()
    .where((product) => product.category == category.toString())
    .toList();
  }

  // Search products
  static Future<List<Product>> searchProducts(String query) async {
    // Simulate API call delay
    await Future.delayed(Duration(seconds: 1));
    return DummyData.getDummyProducts()
        .where((product) => 
            product.name.toLowerCase().contains(query.toLowerCase()) ||
            product.description.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  // Get product by ID
  static Future<Product?> getProductById(String id) async {
    // Simulate API call delay
    await Future.delayed(Duration(milliseconds: 500));
    try {
      return DummyData.getDummyProducts()
          .firstWhere((product) => product.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get products by farmer ID
  static Future<List<Product>> getProductsByFarmer(String farmerId) async {
    // Simulate API call delay
    await Future.delayed(Duration(seconds: 1));
    return DummyData.getDummyProducts()
        .where((product) => product.farmerId == farmerId)
        .toList();
  }

  // Add new product
  static Future<bool> addProduct(Product product) async {
    // Simulate API call delay
    await Future.delayed(Duration(seconds: 2));
    
    // For demo purposes, always succeed
    return true;
  }

  // Update product
  static Future<bool> updateProduct(Product product) async {
    // Simulate API call delay
    await Future.delayed(Duration(seconds: 1));
    
    // For demo purposes, always succeed
    return true;
  }

  // Delete product
  static Future<bool> deleteProduct(String productId) async {
    // Simulate API call delay
    await Future.delayed(Duration(seconds: 1));
    
    // For demo purposes, always succeed
    return true;
  }

  // Get featured products
  static Future<List<Product>> getFeaturedProducts() async {
    // Simulate API call delay
    await Future.delayed(Duration(seconds: 1));
    return DummyData.getDummyProducts()
        .where((product) => product.rating >= 4.5)
        .toList();
  }

  // Get trending products
  static Future<List<Product>> getTrendingProducts() async {
    // Simulate API call delay
    await Future.delayed(Duration(seconds: 1));
  return DummyData.getDummyProducts()
    .where((product) => product.reviewCount >= 100)
    .toList();
  }
}
