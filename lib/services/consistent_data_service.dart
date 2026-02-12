import '../models/farmer.dart';
import '../models/crop.dart';
import '../models/field.dart';
import '../models/diary_entry.dart';
import '../models/weather.dart';
import '../models/community_post.dart';
import '../models/product.dart';
import '../models/scheme.dart';

class ConsistentDataService {
  // Centralized farmer profile - used across all screens
  static Farmer getFarmer() {
    return Farmer(
      id: 'farmer_001',
      name: 'Rajesh Kumar Singh',
      email: 'rajesh.kumar@example.com',
      phone: '+91 98765 43210',
      profileImage: 'assets/images/farmer.jpg',
      farmName: 'Green Valley Organic Farm',
      farmLocation: 'Village: Ramgarh, District: Ludhiana, Punjab',
      farmSize: 12.5,
      crops: ['Wheat', 'Rice', 'Cotton', 'Mustard'],
      experience: '15 years',
      bio: 'Progressive farmer practicing organic farming with modern techniques. Specializes in wheat and rice cultivation with focus on sustainable agriculture.',
      isVerified: true,
      joinDate: DateTime(2023, 3, 15),
      rating: 4.8,
      totalReviews: 127,
      certifications: ['Organic Certification', 'Good Agricultural Practices'],
      preferredLanguage: 'Hindi',
      notificationsEnabled: true,
    );
  }

  // Consistent crops data
  static List<Crop> getCrops() {
    return [
      Crop(
        id: 'crop_wheat_001',
        name: 'Wheat',
        sowDate: DateTime(2024, 11, 15),
        stage: 'growth',
        areaAcres: 5.0,
        actionsHistory: [
          CropAction(date: DateTime(2024, 11, 15), action: 'Sowing', notes: 'Sowed HD-2967 variety'),
          CropAction(date: DateTime(2024, 11, 20), action: 'Irrigation', notes: 'First irrigation applied'),
          CropAction(date: DateTime(2024, 12, 5), action: 'Fertilizer', notes: 'Applied urea 50kg/acre'),
          CropAction(date: DateTime(2024, 12, 15), action: 'Weeding', notes: 'Manual weeding completed'),
        ], location: 'Ludhiana, Punjab',
      ),
      Crop(
        location: 'Ludhiana, Punjab',
        id: 'crop_rice_001',
        name: 'Rice',
        sowDate: DateTime(2024, 6, 20),
        stage: 'harvest',
        areaAcres: 3.5,
        actionsHistory: [
          CropAction(date: DateTime(2024, 6, 20), action: 'Transplanting', notes: 'Basmati variety transplanted'),
          CropAction(date: DateTime(2024, 7, 10), action: 'Fertilizer', notes: 'NPK application'),
          CropAction(date: DateTime(2024, 8, 5), action: 'Pesticide', notes: 'Neem oil spray for pest control'),
          CropAction(date: DateTime(2024, 9, 15), action: 'Harvest', notes: 'Harvested 2.8 tonnes'),
        ],
      ),
      Crop(
        id: 'crop_cotton_001',
        name: 'Cotton',
        sowDate: DateTime(2024, 5, 10),
        stage: 'selling',
        areaAcres: 2.5,
        actionsHistory: [
          CropAction(date: DateTime(2024, 5, 10), action: 'Sowing', notes: 'BT Cotton variety'),
          CropAction(date: DateTime(2024, 6, 15), action: 'Thinning', notes: 'Plant spacing maintained'),
          CropAction(date: DateTime(2024, 7, 20), action: 'Fertilizer', notes: 'DAP application'),
          CropAction(date: DateTime(2024, 9, 10), action: 'Harvest', notes: 'First picking completed'),
          CropAction(date: DateTime(2024, 10, 5), action: 'Selling', notes: 'Sold 8 quintals @ ₹6,500/quintal'),
        ], location: 'Ludhiana, Punjab',
      ),
      Crop(
        id: 'crop_mustard_001',
        name: 'Mustard',
        sowDate: DateTime(2024, 10, 25),
        stage: 'fertilizer',
        areaAcres: 1.5,
        actionsHistory: [
          CropAction(date: DateTime(2024, 10, 25), action: 'Sowing', notes: 'Pusa Bold variety'),
          CropAction(date: DateTime(2024, 11, 5), action: 'Irrigation', notes: 'Light irrigation applied'),
          CropAction(date: DateTime(2024, 11, 20), action: 'Fertilizer', notes: 'Urea application pending'),
        ], location: 'Ludhiana, Punjab',
      ),
    ];
  }

  // Consistent fields data
  static List<Field> getFields() {
    return [
      Field(id: 'field_001', name: 'North Field', areaValue: 5.0, areaUnit: 'acre'),
      Field(id: 'field_002', name: 'South Field', areaValue: 3.5, areaUnit: 'acre'),
      Field(id: 'field_003', name: 'East Field', areaValue: 2.5, areaUnit: 'acre'),
      Field(id: 'field_004', name: 'West Field', areaValue: 1.5, areaUnit: 'acre'),
    ];
  }

  // Consistent diary entries
  static List<DiaryEntry> getDiaryEntries() {
    return [
      DiaryEntry(
        id: 'entry_001',
        fieldId: 'field_001',
        activityType: 'fertilizer',
        productName: 'Urea',
        quantity: 50,
        unit: 'kg',
        cost: 1500,
        date: DateTime(2024, 12, 5),
        notes: 'Applied urea to wheat crop. Weather was clear, good for application.',
        synced: true,
        photos: ['assets/images/fertilizer.jpg'],
      ),
      DiaryEntry(
        id: 'entry_002',
        fieldId: 'field_002',
        activityType: 'harvest',
        productName: 'Rice',
        quantity: 2.8,
        unit: 'tonnes',
        cost: 0,
        date: DateTime(2024, 9, 15),
        notes: 'Harvested basmati rice. Yield was good this season.',
        synced: true,
        photos: ['assets/images/wheat.jpg'],
      ),
      DiaryEntry(
        id: 'entry_003',
        fieldId: 'field_003',
        activityType: 'selling',
        productName: 'Cotton',
        quantity: 8,
        unit: 'quintals',
        cost: -52000,
        date: DateTime(2024, 10, 5),
        notes: 'Sold cotton to local trader. Price was ₹6,500 per quintal.',
        synced: true,
        photos: ['assets/images/cotton.jpg'],
      ),
      DiaryEntry(
        id: 'entry_004',
        fieldId: 'field_004',
        activityType: 'irrigation',
        productName: '',
        quantity: 3,
        unit: 'hours',
        cost: 300,
        date: DateTime(2024, 11, 5),
        notes: 'Irrigated mustard field. Used diesel pump.',
        synced: true,
        photos: [],
      ),
      DiaryEntry(
        id: 'entry_005',
        fieldId: 'field_001',
        activityType: 'pesticide',
        productName: 'Neem Oil',
        quantity: 2,
        unit: 'litres',
        cost: 800,
        date: DateTime(2024, 11, 25),
        notes: 'Applied neem oil spray for pest control. Organic method.',
        synced: true,
        photos: ['assets/images/fertilizer.jpg'],
      ),
      DiaryEntry(
        id: 'entry_006',
        fieldId: 'field_002',
        activityType: 'sowing',
        productName: 'Rice Seeds',
        quantity: 25,
        unit: 'kg',
        cost: 1200,
        date: DateTime(2024, 6, 20),
        notes: 'Transplanted basmati rice seedlings. Used traditional method.',
        synced: true,
        photos: ['assets/images/wheat.jpg'],
      ),
    ];
  }

  // Consistent weather data
  static WeatherData getWeatherData() {
    return WeatherData(
      location: 'Ludhiana, Punjab',
      temperature: 18.5,
      humidity: 72.0,
      windSpeed: 8.0,
      windDirection: 'NW',
      pressure: 1015.2,
      visibility: 12.0,
      condition: 'Partly Cloudy',
      description: 'Cool morning with light winds, good for farming activities',
      icon: 'partly-cloudy',
      timestamp: DateTime.now(),
      forecast: [
        WeatherForecast(
          date: DateTime.now().add(Duration(days: 1)),
          maxTemp: 22.0,
          minTemp: 12.0,
          condition: 'Sunny',
          description: 'Clear skies, ideal for field work',
          icon: 'sunny',
          precipitation: 0.0,
          humidity: 65.0,
          windSpeed: 6.0,
        ),
        WeatherForecast(
          date: DateTime.now().add(Duration(days: 2)),
          maxTemp: 20.0,
          minTemp: 10.0,
          condition: 'Foggy',
          description: 'Dense fog expected in morning, good for wheat',
          icon: 'foggy',
          precipitation: 0.0,
          humidity: 85.0,
          windSpeed: 3.0,
        ),
        WeatherForecast(
          date: DateTime.now().add(Duration(days: 3)),
          maxTemp: 25.0,
          minTemp: 15.0,
          condition: 'Partly Cloudy',
          description: 'Mild weather, suitable for irrigation',
          icon: 'partly-cloudy',
          precipitation: 0.0,
          humidity: 70.0,
          windSpeed: 7.0,
        ),
      ],
      alerts: WeatherAlerts(
        warnings: ['Fog alert for tomorrow morning'],
        advisories: ['Good time for fertilizer application', 'Irrigation recommended in next 2 days'],
        riskLevel: 'Low',
      ),
      soilConditions: SoilConditions(
        moisture: 65.0,
        temperature: 16.0,
        condition: 'Good',
        recommendation: 'Soil moisture is optimal for wheat growth',
      ),
      cropRecommendations: CropRecommendations(
        suitableCrops: ['Wheat', 'Mustard', 'Potato'],
        plantingTips: ['Plant wheat in rows for better yield', 'Apply organic manure before sowing'],
        irrigationAdvice: 'Water wheat fields every 10-12 days',
        pestControl: 'Monitor for aphids in wheat, use neem oil if needed',
      ),
    );
  }

  // Consistent community posts
  static List<CommunityPost> getCommunityPosts() {
    return [
      CommunityPost(
        id: 'post_001',
        farmerId: 'farmer_001',
        farmerName: 'Rajesh Kumar Singh',
        farmerImage: 'assets/images/farmer.jpg',
        title: 'Wheat Harvest Tips for Punjab Farmers',
        content: 'Sharing my experience with wheat cultivation this season. The HD-2967 variety has given excellent results. Key tips: 1) Apply urea in split doses 2) Monitor for aphids regularly 3) Harvest at 14% moisture content. Anyone else growing wheat this season?',
        category: 'Farming Tips',
        images: ['assets/images/wheat.jpg'],
        tags: ['wheat', 'harvest', 'punjab', 'tips'],
        likes: 67,
        comments: 23,
        shares: 12,
        isLiked: true,
        createdAt: DateTime.now().subtract(Duration(hours: 3)),
        updatedAt: DateTime.now().subtract(Duration(hours: 3)),
        commentsList: [
          Comment(
            id: 'comment_001',
            postId: 'post_001',
            farmerId: 'farmer_002',
            farmerName: 'Amit Singh',
            farmerImage: 'assets/images/farmer.jpg',
            content: 'Great tips Rajesh! I also used HD-2967 this year. Yield was 45 quintals per acre.',
            createdAt: DateTime.now().subtract(Duration(hours: 2)),
            likes: 8,
            isLiked: false,
            replies: [],
          ),
        ],
        location: 'Ludhiana, Punjab',
        isVerified: true,
      ),
      CommunityPost(
        id: 'post_002',
        farmerId: 'farmer_001',
        farmerName: 'Rajesh Kumar Singh',
        farmerImage: 'assets/images/farmer.jpg',
        title: 'Cotton Selling Price Update',
        content: 'Sold my cotton today at ₹6,500 per quintal. Market is stable. Good time to sell if you have stock. Contact me if you need buyer details.',
        category: 'Market Updates',
        images: ['assets/images/cotton.jpg'],
        tags: ['cotton', 'price', 'market', 'selling'],
        likes: 34,
        comments: 8,
        shares: 15,
        isLiked: false,
        createdAt: DateTime.now().subtract(Duration(hours: 8)),
        updatedAt: DateTime.now().subtract(Duration(hours: 8)),
        commentsList: [],
        location: 'Ludhiana, Punjab',
        isVerified: true,
      ),
    ];
  }

  // Consistent marketplace products
  static List<Product> getMarketplaceProducts() {
    return [
      Product(
        id: 'prod_001',
        name: 'Urea Fertilizer - Premium Grade',
        description: 'High-quality urea fertilizer suitable for wheat and rice crops. Increases yield by 20-25%.',
        category: 'Fertilizers',
        subCategory: 'Nitrogen',
        price: 30.0,
        unit: 'kg',
        imageUrl: 'assets/images/fertilizer.jpg',
        farmerId: 'supplier_001',
        farmerName: 'Agro Supply Co.',
        farmerLocation: 'Ludhiana, Punjab',
        isOrganic: false,
        isAvailable: true,
        stockQuantity: 500,
        rating: 4.7,
        reviewCount: 156,
        harvestDate: DateTime.now().subtract(Duration(days: 5)),
        expiryDate: DateTime.now().add(Duration(days: 365)),
        images: ['assets/images/fertilizer.jpg'],
        specifications: {'grade': 'Premium', 'nitrogen_content': '46%', 'moisture': '<1%'},
        origin: 'Punjab',
        isVerified: true,
        createdAt: DateTime.now().subtract(Duration(days: 5)),
        updatedAt: DateTime.now(),
      ),
      Product(
        id: 'prod_002',
        name: 'Neem Oil - Organic Pest Control',
        description: 'Pure neem oil for organic pest control. Safe for wheat, rice, and cotton crops.',
        category: 'Pesticides',
        subCategory: 'Organic',
        price: 450.0,
        unit: 'litre',
        imageUrl: 'assets/images/fertilizer.jpg',
        farmerId: 'supplier_002',
        farmerName: 'Organic Solutions',
        farmerLocation: 'Amritsar, Punjab',
        isOrganic: true,
        isAvailable: true,
        stockQuantity: 100,
        rating: 4.8,
        reviewCount: 89,
        harvestDate: DateTime.now().subtract(Duration(days: 10)),
        expiryDate: DateTime.now().add(Duration(days: 730)),
        images: ['assets/images/fertilizer.jpg'],
        specifications: {'purity': '100%', 'azadirachtin': '3000 ppm', 'organic_certified': 'Yes'},
        origin: 'Punjab',
        isVerified: true,
        createdAt: DateTime.now().subtract(Duration(days: 10)),
        updatedAt: DateTime.now(),
      ),
      Product(
        id: 'prod_003',
        name: 'Wheat Seeds - HD 2967 Variety',
        description: 'High-yielding wheat seeds, disease-resistant variety. Perfect for Punjab climate.',
        category: 'Seeds',
        subCategory: 'Wheat',
        price: 45.0,
        unit: 'kg',
        imageUrl: 'assets/images/wheat.jpg',
        farmerId: 'supplier_003',
        farmerName: 'Seed Corporation',
        farmerLocation: 'Chandigarh, Punjab',
        isOrganic: false,
        isAvailable: true,
        stockQuantity: 200,
        rating: 4.9,
        reviewCount: 234,
        harvestDate: DateTime.now().subtract(Duration(days: 15)),
        expiryDate: DateTime.now().add(Duration(days: 180)),
        images: ['assets/images/wheat.jpg'],
        specifications: {'variety': 'HD 2967', 'germination': '95%', 'purity': '99%'},
        origin: 'Punjab',
        isVerified: true,
        createdAt: DateTime.now().subtract(Duration(days: 15)),
        updatedAt: DateTime.now(),
      ),
    ];
  }

  // Consistent government schemes
  static List<Scheme> getGovernmentSchemes() {
    return [
      Scheme(
        id: 'scheme_001',
        title: 'PM-Kisan Samman Nidhi',
        category: 'subsidy',
        state: 'Punjab',
        description: 'Direct income support of ₹6,000 per year to all farmer families. You are eligible based on your wheat and rice cultivation.',
        eligibilityTags: ['wheat_farmer', 'rice_farmer', 'punjab_farmer'],
        steps: [
          'Register on PM-Kisan portal with Aadhaar',
          'Link bank account for direct transfer',
          'Receive ₹2,000 every 4 months',
        ],
      ),
      Scheme(
        id: 'scheme_002',
        title: 'Punjab State Subsidy for Drip Irrigation',
        category: 'subsidy',
        state: 'Punjab',
        description: '50% subsidy on drip irrigation setup for cotton and rice fields. Perfect for your cotton cultivation.',
        eligibilityTags: ['cotton_farmer', 'punjab_farmer', 'small_farmer'],
        steps: [
          'Get quotation from approved vendor',
          'Submit application with land records',
          'Installation and inspection',
          'Receive 50% subsidy amount',
        ],
      ),
      Scheme(
        id: 'scheme_003',
        title: 'Fasal Bima Yojana - Wheat & Rice',
        category: 'insurance',
        state: 'Punjab',
        description: 'Crop insurance for your wheat and rice crops. Premium subsidy available.',
        eligibilityTags: ['wheat_farmer', 'rice_farmer', 'crop_insurance'],
        steps: [
          'Contact local agriculture office',
          'Provide sowing and land details',
          'Pay subsidized premium',
          'Get policy certificate',
        ],
      ),
      Scheme(
        id: 'scheme_004',
        title: 'Organic Farming Certification Support',
        category: 'subsidy',
        state: 'Punjab',
        description: 'Financial support for organic certification. Based on your organic farming practices.',
        eligibilityTags: ['organic_farmer', 'certification', 'punjab_farmer'],
        steps: [
          'Apply for organic certification',
          'Submit farm inspection report',
          'Receive certification',
          'Get 75% subsidy on certification cost',
        ],
      ),
      Scheme(
        id: 'scheme_005',
        title: 'Kisan Credit Card - Enhanced Limit',
        category: 'loan',
        state: 'Punjab',
        description: 'Enhanced credit limit for your diversified farming (wheat, rice, cotton, mustard).',
        eligibilityTags: ['multi_crop_farmer', 'credit_card', 'punjab_farmer'],
        steps: [
          'Visit nearest bank branch',
          'Submit crop details and land records',
          'Get enhanced credit limit approved',
          'Use card for farming expenses',
        ],
      ),
    ];
  }
}
