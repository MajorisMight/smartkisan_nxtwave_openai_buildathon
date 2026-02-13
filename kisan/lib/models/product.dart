class Product {
  final String id;
  final String farmerId;
  final String name;
  final String description;
  final String category;
  final double price;
  final String unit;
  final double stockQuantity;
  final bool isOrganic;
  final List<String> imageUrls;
  final String location;
  // Optional: Add farmer details if you join tables
  final String? farmerName; 

  Product({
    required this.id,
    required this.farmerId,
    required this.name,
    required this.description,
    required this.category,
    required this.price,
    required this.unit,
    required this.stockQuantity,
    required this.isOrganic,
    required this.imageUrls,
    required this.location,
    this.farmerName,
  });

  factory Product.fromMap(Map<String, dynamic> map) {
    final farmerData = map['farmers'] as Map<String, dynamic>?;
    
    return Product(
      id: map['id']?.toString() ?? '',
      farmerId: map['farmer_id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      description: map['description'] ?? '',
      category: map['category']?.toString() ?? 'General',
      price: (map['price'] as num?)?.toDouble() ?? 0,
      unit: map['unit']?.toString() ?? 'unit',
      stockQuantity: (map['stock_quantity'] as num?)?.toDouble() ?? 0,
      isOrganic: map['is_organic'] ?? false,
      imageUrls: List<String>.from(map['image_urls'] ?? []),
      location: map['location'] ?? 'Unknown',
      farmerName: farmerData?['name']?.toString(), // Fetch name via join
    );
  }
}
