class Product {
  final String id;
  final String name;
  final String description;
  final String category;
  final String subCategory;
  final double price;
  final String unit; // kg, lb, piece, etc.
  final String imageUrl;
  final String farmerId;
  final String farmerName;
  final String farmerLocation;
  final bool isOrganic;
  final bool isAvailable;
  final int stockQuantity;
  final double rating;
  final int reviewCount;
  final DateTime harvestDate;
  final DateTime expiryDate;
  final List<String> images;
  final Map<String, dynamic> specifications;
  final String origin;
  final bool isVerified;
  final DateTime createdAt;
  final DateTime updatedAt;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.subCategory,
    required this.price,
    required this.unit,
    required this.imageUrl,
    required this.farmerId,
    required this.farmerName,
    required this.farmerLocation,
    required this.isOrganic,
    required this.isAvailable,
    required this.stockQuantity,
    required this.rating,
    required this.reviewCount,
    required this.harvestDate,
    required this.expiryDate,
    required this.images,
    required this.specifications,
    required this.origin,
    required this.isVerified,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? '',
      subCategory: json['subCategory'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      unit: json['unit'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      farmerId: json['farmerId'] ?? '',
      farmerName: json['farmerName'] ?? '',
      farmerLocation: json['farmerLocation'] ?? '',
      isOrganic: json['isOrganic'] ?? false,
      isAvailable: json['isAvailable'] ?? true,
      stockQuantity: json['stockQuantity'] ?? 0,
      rating: (json['rating'] ?? 0).toDouble(),
      reviewCount: json['reviewCount'] ?? 0,
      harvestDate: DateTime.parse(json['harvestDate'] ?? DateTime.now().toIso8601String()),
      expiryDate: DateTime.parse(json['expiryDate'] ?? DateTime.now().add(Duration(days: 30)).toIso8601String()),
      images: List<String>.from(json['images'] ?? []),
      specifications: Map<String, dynamic>.from(json['specifications'] ?? {}),
      origin: json['origin'] ?? '',
      isVerified: json['isVerified'] ?? false,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'subCategory': subCategory,
      'price': price,
      'unit': unit,
      'imageUrl': imageUrl,
      'farmerId': farmerId,
      'farmerName': farmerName,
      'farmerLocation': farmerLocation,
      'isOrganic': isOrganic,
      'isAvailable': isAvailable,
      'stockQuantity': stockQuantity,
      'rating': rating,
      'reviewCount': reviewCount,
      'harvestDate': harvestDate.toIso8601String(),
      'expiryDate': expiryDate.toIso8601String(),
      'images': images,
      'specifications': specifications,
      'origin': origin,
      'isVerified': isVerified,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
