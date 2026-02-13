import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/product_service.dart';

class ProductProvider with ChangeNotifier {
  List<Product> _products = [];
  List<Product> _filteredProducts = [];
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';
  String? _selectedCategory;

  // Getters
  List<Product> get products => _filteredProducts;
  List<Product> get allProducts => _products;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchQuery => _searchQuery;
  String? get selectedCategory => _selectedCategory;

  // Initialize products
  Future<void> loadProducts() async {
    _setLoading(true);
    _clearError();
    
    try {
      _products = await ProductService.getAllProducts();
      _filteredProducts = _products;
      notifyListeners();
    } catch (e) {
      _setError('Failed to load products: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Search products
  Future<void> searchProducts(String query) async {
    _searchQuery = query;
    _setLoading(true);
    _clearError();
    
    try {
      if (query.isEmpty) {
        _filteredProducts = _products;
      } else {
        _filteredProducts = await ProductService.searchProducts(query);
      }
      notifyListeners();
    } catch (e) {
      _setError('Search failed: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Filter by category
  Future<void> filterByCategory(String? category) async {
  _selectedCategory = category;
    _setLoading(true);
    _clearError();
    
    try {
      if (category == null) {
        _filteredProducts = _products;
      } else {
        _filteredProducts = await ProductService.getProductsByCategory(category);
      }
      notifyListeners();
    } catch (e) {
      _setError('Filter failed: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Get product by ID
  Future<Product?> getProductById(String id) async {
    try {
      return await ProductService.getProductById(id);
    } catch (e) {
      _setError('Failed to get product: $e');
      return null;
    }
  }

  // Get products by farmer
  Future<List<Product>> getProductsByFarmer(String farmerId) async {
    try {
      return await ProductService.getProductsByFarmer(farmerId);
    } catch (e) {
      _setError('Failed to get farmer products: $e');
      return [];
    }
  }

  // Add product
  Future<bool> addProduct(Product product) async {
    _setLoading(true);
    _clearError();
    
    try {
      final success = await ProductService.addProduct(product);
      if (success) {
        _products.add(product);
        _filteredProducts = _products;
        notifyListeners();
      }
      return success;
    } catch (e) {
      _setError('Failed to add product: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Update product
  Future<bool> updateProduct(Product product) async {
    _setLoading(true);
    _clearError();
    
    try {
      final success = await ProductService.updateProduct(product);
      if (success) {
        final index = _products.indexWhere((p) => p.id == product.id);
        if (index != -1) {
          _products[index] = product;
          _filteredProducts = _products;
          notifyListeners();
        }
      }
      return success;
    } catch (e) {
      _setError('Failed to update product: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Delete product
  Future<bool> deleteProduct(String productId) async {
    _setLoading(true);
    _clearError();
    
    try {
      final success = await ProductService.deleteProduct(productId);
      if (success) {
        _products.removeWhere((p) => p.id == productId);
        _filteredProducts = _products;
        notifyListeners();
      }
      return success;
    } catch (e) {
      _setError('Failed to delete product: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Get featured products
  Future<List<Product>> getFeaturedProducts() async {
    try {
      return await ProductService.getFeaturedProducts();
    } catch (e) {
      _setError('Failed to get featured products: $e');
      return [];
    }
  }

  // Get trending products
  Future<List<Product>> getTrendingProducts() async {
    try {
      return await ProductService.getTrendingProducts();
    } catch (e) {
      _setError('Failed to get trending products: $e');
      return [];
    }
  }

  // Clear filters
  void clearFilters() {
    _searchQuery = '';
    _selectedCategory = null;
    _filteredProducts = _products;
    notifyListeners();
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  void clearError() {
    _clearError();
  }
}
