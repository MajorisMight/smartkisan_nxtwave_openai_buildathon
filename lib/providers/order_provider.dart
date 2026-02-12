import 'package:flutter/material.dart';
import '../models/order.dart';
import '../services/order_service.dart';

class OrderProvider with ChangeNotifier {
  List<Order> _orders = [];
  List<Order> _filteredOrders = [];
  bool _isLoading = false;
  String? _error;
  String? _selectedStatus;
  String _farmerId = '';

  // Getters
  List<Order> get orders => _filteredOrders;
  List<Order> get allOrders => _orders;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get selectedStatus => _selectedStatus;
  String get farmerId => _farmerId;

  // Initialize orders
  Future<void> loadOrders(String farmerId) async {
    _farmerId = farmerId;
    _setLoading(true);
    _clearError();
    try {
      _orders = await OrderService.getFarmerOrders(farmerId);
      _filteredOrders = _orders;
      notifyListeners();
    } catch (e) {
      _setError('Failed to load orders: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Filter by status
  Future<void> filterByStatus(String? status) async {
    _selectedStatus = status;
    _setLoading(true);
    _clearError();
    try {
      if (status == null) {
        _filteredOrders = _orders;
      } else {
        _filteredOrders = _orders.where((order) => order.status == status).toList();
      }
      notifyListeners();
    } catch (e) {
      _setError('Filter failed: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Get order by ID
  Future<Order?> getOrderById(String id) async {
    try {
      return await OrderService.getOrderById(id);
    } catch (e) {
      _setError('Failed to get order: $e');
      return null;
    }
  }

  // Create order
  Future<bool> createOrder(Order order) async {
    _setLoading(true);
    _clearError();
    try {
      final success = await OrderService.createOrder(order);
      if (success) {
        _orders.insert(0, order);
        _filteredOrders = _orders;
        notifyListeners();
      }
      return success;
    } catch (e) {
      _setError('Failed to create order: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Update order status
  Future<bool> updateOrderStatus(String orderId, String status) async {
    _setLoading(true);
    _clearError();
    try {
      final success = await OrderService.updateOrderStatus(orderId, status);
      if (success) {
        final index = _orders.indexWhere((o) => o.id == orderId);
        if (index != -1) {
          final order = _orders[index];
          _orders[index] = Order(
            id: order.id,
            farmerId: order.farmerId,
            buyerId: order.buyerId,
            buyerName: order.buyerName,
            buyerPhone: order.buyerPhone,
            buyerAddress: order.buyerAddress,
            items: order.items,
            totalAmount: order.totalAmount,
            status: status,
            paymentMethod: order.paymentMethod,
            paymentStatus: order.paymentStatus,
            orderDate: order.orderDate,
            deliveryDate: order.deliveryDate,
            deliveryAddress: order.deliveryAddress,
            notes: order.notes,
            trackingNumber: order.trackingNumber,
            statusHistory: order.statusHistory,
            deliveryFee: order.deliveryFee,
            taxAmount: order.taxAmount,
            couponCode: order.couponCode,
            discountAmount: order.discountAmount,
          );
          _filteredOrders = _orders;
          notifyListeners();
        }
      }
      return success;
    } catch (e) {
      _setError('Failed to update order status: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Cancel order
  Future<bool> cancelOrder(String orderId, String reason) async {
    _setLoading(true);
    _clearError();
    try {
      final success = await OrderService.cancelOrder(orderId, reason);
      if (success) {
        await updateOrderStatus(orderId, 'cancelled');
      }
      return success;
    } catch (e) {
      _setError('Failed to cancel order: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Get orders by status
  Future<List<Order>> getOrdersByStatus(String status) async {
    try {
      switch (status) {
        case 'pending':
          return await OrderService.getPendingOrders(_farmerId);
        case 'confirmed':
          return await OrderService.getConfirmedOrders(_farmerId);
        case 'processing':
          return await OrderService.getProcessingOrders(_farmerId);
        case 'shipped':
          return await OrderService.getShippedOrders(_farmerId);
        case 'delivered':
          return await OrderService.getDeliveredOrders(_farmerId);
        case 'cancelled':
          return await OrderService.getCancelledOrders(_farmerId);
        default:
          return [];
      }
    } catch (e) {
      _setError('Failed to get orders by status: $e');
      return [];
    }
  }

  // Get orders by date range
  Future<List<Order>> getOrdersByDateRange(DateTime startDate, DateTime endDate) async {
    try {
      return await OrderService.getOrdersByDateRange(_farmerId, startDate, endDate);
    } catch (e) {
      _setError('Failed to get orders by date range: $e');
      return [];
    }
  }

  // Get order statistics
  Future<Map<String, dynamic>> getOrderStatistics() async {
    try {
      return await OrderService.getOrderStatistics(_farmerId);
    } catch (e) {
      _setError('Failed to get order statistics: $e');
      return {};
    }
  }

  // Clear filters
  void clearFilters() {
    _selectedStatus = null;
    _filteredOrders = _orders;
    notifyListeners();
  }

  // Refresh orders
  Future<void> refresh() async {
    if (_farmerId.isNotEmpty) {
      await loadOrders(_farmerId);
    }
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
