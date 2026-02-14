import '../models/crop.dart';
import '../models/crop_action.dart';

class DemoFarmer {
  final String name;
  final bool isVerified;
  final String farmName;
  final String farmLocation;
  final double rating;
  final String experience;
  final double farmSize;
  final String email;
  final String phone;
  final String preferredLanguage;
  final String bio;
  final List<String> certifications;
  final List<String> crops;
  final DateTime joinDate;

  DemoFarmer({
    required this.name,
    required this.isVerified,
    required this.farmName,
    required this.farmLocation,
    required this.rating,
    required this.experience,
    required this.farmSize,
    required this.email,
    required this.phone,
    required this.preferredLanguage,
    required this.bio,
    required this.certifications,
    required this.crops,
    required this.joinDate,
  });
}

class CommunityPost {
  final String farmerName;
  final bool isVerified;
  final String location;
  final DateTime createdAt;
  final String category;
  final String title;
  final String content;
  final List<String> tags;
  final List<String> images;
  int likes;
  final int comments;
  final int shares;
  bool isLiked;

  CommunityPost({
    required this.farmerName,
    required this.isVerified,
    required this.location,
    required this.createdAt,
    required this.category,
    required this.title,
    required this.content,
    required this.tags,
    required this.images,
    required this.likes,
    required this.comments,
    required this.shares,
    this.isLiked = false,
  });
}

class MarketplaceProduct {
  final String name;
  final String category;
  final bool isOrganic;
  final String description;
  final String farmerName;
  final String farmerLocation;
  final double rating;
  final int reviewCount;
  final double price;
  final String unit;
  final int stockQuantity;

  MarketplaceProduct({
    required this.name,
    required this.category,
    required this.isOrganic,
    required this.description,
    required this.farmerName,
    required this.farmerLocation,
    required this.rating,
    required this.reviewCount,
    required this.price,
    required this.unit,
    required this.stockQuantity,
  });
}

class DemoDataService {
  static DemoFarmer getDemoFarmer() {
    return DemoFarmer(
      name: 'Ravi Kumar',
      isVerified: true,
      farmName: 'Ujjwal Greens',
      farmLocation: 'Ludhiana, Punjab',
      rating: 4.7,
      experience: '8 years',
      farmSize: 12.5,
      email: 'ravi.kisan@example.com',
      phone: '+91 98765 43210',
      preferredLanguage: 'Hindi',
      bio: 'Progressive farmer focused on wheat, mustard, and soil-health-first practices.',
      certifications: ['Organic Input Training', 'PM-KISAN Registered'],
      crops: ['Wheat', 'Mustard', 'Paddy'],
      joinDate: DateTime(2021, 7, 14),
    );
  }

  static List<Crop> getDemoCrops() {
    return [
      Crop(
        id: '1',
        name: 'Wheat',
        type: 'HD-2967',
        sowDate: DateTime.now().subtract(const Duration(days: 38)),
        stage: 'growth',
        areaAcres: 4.0,
        location: 'Ludhiana',
        actionsHistory: [
          CropAction(
            id: 1,
            farmCropId: 1,
            action: 'Irrigated',
            notes: 'Canal water',
            date: DateTime.now().subtract(const Duration(days: 6)),
          ),
        ],
      ),
      Crop(
        id: '2',
        name: 'Mustard',
        type: 'Pusa Bold',
        sowDate: DateTime.now().subtract(const Duration(days: 52)),
        stage: 'fertilizer',
        areaAcres: 2.6,
        location: 'Moga',
      ),
    ];
  }

  static List<CommunityPost> getFarmerCommunityPosts() {
    return [
      CommunityPost(
        farmerName: 'Ravi Kumar',
        isVerified: true,
        location: 'Ludhiana',
        createdAt: DateTime.now().subtract(const Duration(hours: 4)),
        category: 'Farming Tips',
        title: 'Split nitrogen improved tillering this season',
        content: 'Applied first split at day 20 and second at day 35; crop stands look stronger.',
        tags: ['Wheat', 'Nutrition', 'Yield'],
        images: const [],
        likes: 24,
        comments: 8,
        shares: 3,
      ),
      CommunityPost(
        farmerName: 'Meena Devi',
        isVerified: false,
        location: 'Bathinda',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        category: 'Market Updates',
        title: 'Current mandi trend for mustard',
        content: 'Prices moved up this week; holding stock for 2-3 more days may help.',
        tags: ['Market', 'Mustard'],
        images: const [],
        likes: 15,
        comments: 4,
        shares: 2,
      ),
    ];
  }

  static List<MarketplaceProduct> getRelevantProducts() {
    return [
      MarketplaceProduct(
        name: 'NPK 19:19:19',
        category: 'Fertilizers',
        isOrganic: false,
        description: 'Balanced water-soluble fertilizer for foliar application.',
        farmerName: 'Agri Inputs Center',
        farmerLocation: 'Ludhiana',
        rating: 4.4,
        reviewCount: 118,
        price: 980,
        unit: 'bag',
        stockQuantity: 22,
      ),
      MarketplaceProduct(
        name: 'Neem Cake Granules',
        category: 'Organic',
        isOrganic: true,
        description: 'Organic soil amendment supporting root health.',
        farmerName: 'Green Earth Organics',
        farmerLocation: 'Moga',
        rating: 4.6,
        reviewCount: 73,
        price: 620,
        unit: 'bag',
        stockQuantity: 16,
      ),
    ];
  }
}
