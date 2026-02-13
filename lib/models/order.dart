class Order {
  final String id;
  final String farmerId;
  final String buyerId;
  final String buyerName;
  final String buyerPhone;
  final String buyerAddress;
  final List<OrderItem> items;
  final double totalAmount;
  final String status;
  final String paymentMethod;
  final String paymentStatus;
  final DateTime orderDate;
  final DateTime? deliveryDate;
  final String deliveryAddress;
  final String notes;
  final String trackingNumber;
  final List<OrderStatus> statusHistory;
  final double deliveryFee;
  final double taxAmount;
  final String couponCode;
  final double discountAmount;

  Order({
    required this.id,
    required this.farmerId,
    required this.buyerId,
    required this.buyerName,
    required this.buyerPhone,
    required this.buyerAddress,
    required this.items,
    required this.totalAmount,
    required this.status,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.orderDate,
    this.deliveryDate,
    required this.deliveryAddress,
    required this.notes,
    required this.trackingNumber,
    required this.statusHistory,
    required this.deliveryFee,
    required this.taxAmount,
    required this.couponCode,
    required this.discountAmount,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] ?? '',
      farmerId: json['farmerId'] ?? '',
      buyerId: json['buyerId'] ?? '',
      buyerName: json['buyerName'] ?? '',
      buyerPhone: json['buyerPhone'] ?? '',
      buyerAddress: json['buyerAddress'] ?? '',
      items: (json['items'] as List?)
          ?.map((e) => OrderItem.fromJson(e))
          .toList() ?? [],
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
      status: json['status'] ?? '',
      paymentMethod: json['paymentMethod'] ?? '',
      paymentStatus: json['paymentStatus'] ?? '',
      orderDate: DateTime.parse(json['orderDate'] ?? DateTime.now().toIso8601String()),
      deliveryDate: json['deliveryDate'] != null 
          ? DateTime.parse(json['deliveryDate']) 
          : null,
      deliveryAddress: json['deliveryAddress'] ?? '',
      notes: json['notes'] ?? '',
      trackingNumber: json['trackingNumber'] ?? '',
      statusHistory: (json['statusHistory'] as List?)
          ?.map((e) => OrderStatus.fromJson(e))
          .toList() ?? [],
      deliveryFee: (json['deliveryFee'] ?? 0).toDouble(),
      taxAmount: (json['taxAmount'] ?? 0).toDouble(),
      couponCode: json['couponCode'] ?? '',
      discountAmount: (json['discountAmount'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'farmerId': farmerId,
      'buyerId': buyerId,
      'buyerName': buyerName,
      'buyerPhone': buyerPhone,
      'buyerAddress': buyerAddress,
      'items': items.map((e) => e.toJson()).toList(),
      'totalAmount': totalAmount,
      'status': status,
      'paymentMethod': paymentMethod,
      'paymentStatus': paymentStatus,
      'orderDate': orderDate.toIso8601String(),
      'deliveryDate': deliveryDate?.toIso8601String(),
      'deliveryAddress': deliveryAddress,
      'notes': notes,
      'trackingNumber': trackingNumber,
      'statusHistory': statusHistory.map((e) => e.toJson()).toList(),
      'deliveryFee': deliveryFee,
      'taxAmount': taxAmount,
      'couponCode': couponCode,
      'discountAmount': discountAmount,
    };
  }
}

class OrderItem {
  final String id;
  final String productId;
  final String productName;
  final String productImage;
  final double price;
  final int quantity;
  final String unit;
  final double totalPrice;

  OrderItem({
    required this.id,
    required this.productId,
    required this.productName,
    required this.productImage,
    required this.price,
    required this.quantity,
    required this.unit,
    required this.totalPrice,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'] ?? '',
      productId: json['productId'] ?? '',
      productName: json['productName'] ?? '',
      productImage: json['productImage'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      quantity: json['quantity'] ?? 0,
      unit: json['unit'] ?? '',
      totalPrice: (json['totalPrice'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'productName': productName,
      'productImage': productImage,
      'price': price,
      'quantity': quantity,
      'unit': unit,
      'totalPrice': totalPrice,
    };
  }
}

class OrderStatus {
  final String status;
  final String description;
  final DateTime timestamp;
  final String? location;

  OrderStatus({
    required this.status,
    required this.description,
    required this.timestamp,
    this.location,
  });

  factory OrderStatus.fromJson(Map<String, dynamic> json) {
    return OrderStatus(
      status: json['status'] ?? '',
      description: json['description'] ?? '',
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
      location: json['location'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'description': description,
      'timestamp': timestamp.toIso8601String(),
      'location': location,
    };
  }
}
