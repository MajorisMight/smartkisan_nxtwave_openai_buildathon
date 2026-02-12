import '../models/order.dart';
import '../utils/dummy_data.dart';

class OrderService {
  // Get all orders for a farmer
  static Future<List<Order>> getFarmerOrders(String farmerId) async {
    // Simulate API call delay
    await Future.delayed(Duration(seconds: 1));
    return DummyData.getDummyOrders()
        .where((order) => order.farmerId == farmerId)
        .toList();
  }

  // Get all orders for a buyer
  static Future<List<Order>> getBuyerOrders(String buyerId) async {
    // Simulate API call delay
    await Future.delayed(Duration(seconds: 1));
    return DummyData.getDummyOrders()
        .where((order) => order.buyerId == buyerId)
        .toList();
  }

  // Get order by ID
  static Future<Order?> getOrderById(String id) async {
    // Simulate API call delay
    await Future.delayed(Duration(milliseconds: 500));
    try {
      return DummyData.getDummyOrders()
          .firstWhere((order) => order.id == id);
    } catch (e) {
      return null;
    }
  }

  // Create new order
  static Future<bool> createOrder(Order order) async {
    // Simulate API call delay
    await Future.delayed(Duration(seconds: 2));
    
    // For demo purposes, always succeed
    return true;
  }

  // Update order status
  static Future<bool> updateOrderStatus(String orderId, String status) async {
    // Simulate API call delay
    await Future.delayed(Duration(seconds: 1));
    
    // For demo purposes, always succeed
    return true;
  }

  // Cancel order
  static Future<bool> cancelOrder(String orderId, String reason) async {
    // Simulate API call delay
    await Future.delayed(Duration(seconds: 1));
    
    // For demo purposes, always succeed
    return true;
  }

  // Get pending orders
  static Future<List<Order>> getPendingOrders(String farmerId) async {
    // Simulate API call delay
    await Future.delayed(Duration(seconds: 1));
  return DummyData.getDummyOrders()
    .where((order) => 
      order.farmerId == farmerId && 
      order.status == 'pending')
    .toList();
  }

  // Get confirmed orders
  static Future<List<Order>> getConfirmedOrders(String farmerId) async {
    // Simulate API call delay
    await Future.delayed(Duration(seconds: 1));
  return DummyData.getDummyOrders()
    .where((order) => 
      order.farmerId == farmerId && 
      order.status == 'confirmed')
    .toList();
  }

  // Get processing orders
  static Future<List<Order>> getProcessingOrders(String farmerId) async {
    // Simulate API call delay
    await Future.delayed(Duration(seconds: 1));
  return DummyData.getDummyOrders()
    .where((order) => 
      order.farmerId == farmerId && 
      order.status == 'processing')
    .toList();
  }

  // Get shipped orders
  static Future<List<Order>> getShippedOrders(String farmerId) async {
    // Simulate API call delay
    await Future.delayed(Duration(seconds: 1));
  return DummyData.getDummyOrders()
    .where((order) => 
      order.farmerId == farmerId && 
      order.status == 'shipped')
    .toList();
  }

  // Get delivered orders
  static Future<List<Order>> getDeliveredOrders(String farmerId) async {
    // Simulate API call delay
    await Future.delayed(Duration(seconds: 1));
  return DummyData.getDummyOrders()
    .where((order) => 
      order.farmerId == farmerId && 
      order.status == 'delivered')
    .toList();
  }

  // Get cancelled orders
  static Future<List<Order>> getCancelledOrders(String farmerId) async {
    // Simulate API call delay
    await Future.delayed(Duration(seconds: 1));
  return DummyData.getDummyOrders()
    .where((order) => 
      order.farmerId == farmerId && 
      order.status == 'cancelled')
    .toList();
  }

  // Get orders by date range
  static Future<List<Order>> getOrdersByDateRange(
      String farmerId, DateTime startDate, DateTime endDate) async {
    // Simulate API call delay
    await Future.delayed(Duration(seconds: 1));
    return DummyData.getDummyOrders()
        .where((order) => 
            order.farmerId == farmerId &&
            order.orderDate.isAfter(startDate) &&
            order.orderDate.isBefore(endDate))
        .toList();
  }

  // Get order statistics
  static Future<Map<String, dynamic>> getOrderStatistics(String farmerId) async {
    // Simulate API call delay
    await Future.delayed(Duration(seconds: 1));
    
    final orders = DummyData.getDummyOrders()
        .where((order) => order.farmerId == farmerId)
        .toList();
    
    return {
      'totalOrders': orders.length,
  'pendingOrders': orders.where((o) => o.status == 'pending').length,
  'confirmedOrders': orders.where((o) => o.status == 'confirmed').length,
  'processingOrders': orders.where((o) => o.status == 'processing').length,
  'shippedOrders': orders.where((o) => o.status == 'shipped').length,
  'deliveredOrders': orders.where((o) => o.status == 'delivered').length,
  'cancelledOrders': orders.where((o) => o.status == 'cancelled').length,
      'totalRevenue': orders.fold(0.0, (sum, order) => sum + order.totalAmount),
    };
  }

  // Add order tracking
  static Future<bool> addOrderTracking(String orderId, String trackingNumber) async {
    // Simulate API call delay
    await Future.delayed(Duration(seconds: 1));
    
    // For demo purposes, always succeed
    return true;
  }

  // Get order tracking info
  static Future<Map<String, dynamic>> getOrderTracking(String orderId) async {
    // Simulate API call delay
    await Future.delayed(Duration(seconds: 1));
    
    // Return dummy tracking info
    return {
      'trackingNumber': 'TRK${orderId.substring(1)}',
      'status': 'In Transit',
      'currentLocation': 'Mumbai Distribution Center',
      'estimatedDelivery': DateTime.now().add(Duration(days: 2)),
      'trackingHistory': [
        {
          'status': 'Order Placed',
          'timestamp': DateTime.now().subtract(Duration(days: 3)),
          'location': 'Origin',
        },
        {
          'status': 'Packed',
          'timestamp': DateTime.now().subtract(Duration(days: 2)),
          'location': 'Origin',
        },
        {
          'status': 'Shipped',
          'timestamp': DateTime.now().subtract(Duration(days: 1)),
          'location': 'Origin',
        },
        {
          'status': 'In Transit',
          'timestamp': DateTime.now(),
          'location': 'Mumbai Distribution Center',
        },
      ],
    };
  }
}
