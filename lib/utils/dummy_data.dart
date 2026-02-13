import '../models/farmer.dart';
import '../models/product.dart';
import '../models/weather.dart';
import '../models/community_post.dart';
import '../models/order.dart';
import '../models/notification.dart';
import '../models/crop.dart';
import '../models/scheme.dart';
import '../models/disease.dart';
import '../services/demo_data_service.dart';

class DummyData {
  // Dummy Farmers
  static List<Farmer> getDummyFarmers() {
    return [
      Farmer(
        id: '1',
        name: 'Rajesh Kumar',
        email: 'rajesh@example.com',
        phone: '+91 9876543210',
        profileImage: 'assets/images/farmer.jpg',
        farmName: 'Green Valley Farm',
        farmLocation: 'Punjab, India',
        farmSize: 25.5,
        crops: ['Wheat', 'Rice', 'Cotton'],
        experience: '15 years',
        bio: 'Experienced farmer with expertise in organic farming and sustainable agriculture practices.',
        isVerified: true,
        joinDate: DateTime.now().subtract(Duration(days: 365)),
        rating: 4.8,
        totalReviews: 156,
        certifications: ['Organic Certification', 'ISO 9001'],
        preferredLanguage: 'Hindi',
        notificationsEnabled: true,
      ),
      Farmer(
        id: '2',
        name: 'Priya Sharma',
        email: 'priya@example.com',
        phone: '+91 9876543211',
        profileImage: 'assets/images/farmer.jpg',
        farmName: 'Sunrise Organic Farm',
        farmLocation: 'Maharashtra, India',
        farmSize: 18.0,
        crops: ['Tomato', 'Onion', 'Chilli'],
        experience: '8 years',
        bio: 'Passionate about organic farming and helping fellow farmers adopt sustainable practices.',
        isVerified: true,
        joinDate: DateTime.now().subtract(Duration(days: 200)),
        rating: 4.6,
        totalReviews: 89,
        certifications: ['Organic Certification'],
        preferredLanguage: 'Marathi',
        notificationsEnabled: true,
      ),
      Farmer(
        id: '3',
        name: 'Amit Singh',
        email: 'amit@example.com',
        phone: '+91 9876543212',
        profileImage: 'assets/images/farmer.jpg',
        farmName: 'Golden Harvest Farm',
        farmLocation: 'Haryana, India',
        farmSize: 32.0,
        crops: ['Sugarcane', 'Wheat', 'Mustard'],
        experience: '20 years',
        bio: 'Traditional farmer with modern techniques, specializing in cash crops.',
        isVerified: true,
        joinDate: DateTime.now().subtract(Duration(days: 500)),
        rating: 4.9,
        totalReviews: 234,
        certifications: ['ISO 9001', 'Good Agricultural Practices'],
        preferredLanguage: 'Hindi',
        notificationsEnabled: true,
      ),
    ];
  }

  // Dummy Products
  static List<Product> getDummyProducts() {
    return [
      Product(
        id: '1',
        name: 'Fresh Organic Tomatoes',
        description: 'Naturally grown organic tomatoes, rich in vitamins and minerals.',
        category: 'Vegetables',
        subCategory: 'Tomatoes',
        price: 45.0,
        unit: 'kg',
        imageUrl: 'assets/images/farmer.jpg',
        farmerId: '2',
        farmerName: 'Priya Sharma',
        farmerLocation: 'Maharashtra, India',
        isOrganic: true,
        isAvailable: true,
        stockQuantity: 150,
        rating: 4.7,
        reviewCount: 23,
        harvestDate: DateTime.now().subtract(Duration(days: 2)),
        expiryDate: DateTime.now().add(Duration(days: 5)),
        images: ['assets/images/farmer.jpg'],
        specifications: {'weight': '500g', 'color': 'Red', 'variety': 'Cherry'},
        origin: 'Maharashtra',
        isVerified: true,
        createdAt: DateTime.now().subtract(Duration(days: 2)),
        updatedAt: DateTime.now(),
      ),
      Product(
        id: '2',
        name: 'Premium Basmati Rice',
        description: 'High-quality basmati rice, perfect for daily consumption.',
        category: 'Grains',
        subCategory: 'Rice',
        price: 120.0,
        unit: 'kg',
        imageUrl: 'assets/images/farmer.jpg',
        farmerId: '1',
        farmerName: 'Rajesh Kumar',
        farmerLocation: 'Punjab, India',
        isOrganic: false,
        isAvailable: true,
        stockQuantity: 500,
        rating: 4.8,
        reviewCount: 45,
        harvestDate: DateTime.now().subtract(Duration(days: 30)),
        expiryDate: DateTime.now().add(Duration(days: 365)),
        images: ['assets/images/farmer.jpg'],
        specifications: {'type': 'Basmati', 'grade': 'Premium', 'grain_length': 'Long'},
        origin: 'Punjab',
        isVerified: true,
        createdAt: DateTime.now().subtract(Duration(days: 30)),
        updatedAt: DateTime.now(),
      ),
      Product(
        id: '3',
        name: 'Fresh Red Onions',
        description: 'Freshly harvested red onions, perfect for cooking.',
        category: 'Vegetables',
        subCategory: 'Onions',
        price: 35.0,
        unit: 'kg',
        imageUrl: 'assets/images/farmer.jpg',
        farmerId: '2',
        farmerName: 'Priya Sharma',
        farmerLocation: 'Maharashtra, India',
        isOrganic: true,
        isAvailable: true,
        stockQuantity: 200,
        rating: 4.5,
        reviewCount: 18,
        harvestDate: DateTime.now().subtract(Duration(days: 5)),
        expiryDate: DateTime.now().add(Duration(days: 15)),
        images: ['assets/images/farmer.jpg'],
        specifications: {'size': 'Medium', 'color': 'Red', 'variety': 'Local'},
        origin: 'Maharashtra',
        isVerified: true,
        createdAt: DateTime.now().subtract(Duration(days: 5)),
        updatedAt: DateTime.now(),
      ),
    ];
  }

  // Dummy Weather Data
  static WeatherData getDummyWeatherData() {
    return WeatherData(
      location: 'Delhi, India',
      temperature: 28.5,
      humidity: 65.0,
      windSpeed: 12.0,
      windDirection: 'NW',
      pressure: 1013.25,
      visibility: 10.0,
      condition: 'Partly Cloudy',
      description: 'Partly cloudy with light winds',
      icon: 'partly-cloudy',
      timestamp: DateTime.now(),
      forecast: [
        WeatherForecast(
          date: DateTime.now().add(Duration(days: 1)),
          maxTemp: 32.0,
          minTemp: 22.0,
          condition: 'Sunny',
          description: 'Clear skies with bright sunshine',
          icon: 'sunny',
          precipitation: 0.0,
          humidity: 55.0,
          windSpeed: 8.0,
        ),
        WeatherForecast(
          date: DateTime.now().add(Duration(days: 2)),
          maxTemp: 30.0,
          minTemp: 20.0,
          condition: 'Rainy',
          description: 'Light rain expected in the afternoon',
          icon: 'rainy',
          precipitation: 5.0,
          humidity: 75.0,
          windSpeed: 15.0,
        ),
      ],
      alerts: WeatherAlerts(
        warnings: ['High humidity may affect crop growth'],
        advisories: ['Water your crops early morning'],
        riskLevel: 'Medium',
      ),
      soilConditions: SoilConditions(
        moisture: 60.0,
        temperature: 25.0,
        condition: 'Good',
        recommendation: 'Soil moisture is optimal for planting',
      ),
      cropRecommendations: CropRecommendations(
        suitableCrops: ['Tomato', 'Cucumber', 'Spinach'],
        plantingTips: ['Plant in well-drained soil', 'Water regularly'],
        irrigationAdvice: 'Water every 2-3 days',
        pestControl: 'Use organic pesticides',
      ),
    );
  }

  // Dummy Community Posts
  static List<CommunityPost> getDummyCommunityPosts() {
    return [
      CommunityPost(
        id: '1',
        farmerId: '1',
        farmerName: 'Rajesh Kumar',
        farmerImage: 'assets/images/farmer.jpg',
        title: 'Best Practices for Organic Farming',
        content: 'Sharing some tips that have helped me improve my organic farming yield over the years...',
        category: 'Farming Tips',
        images: ['assets/images/farmer.jpg'],
        tags: ['organic', 'farming', 'tips'],
        likes: 45,
        comments: 12,
        shares: 8,
        isLiked: false,
        createdAt: DateTime.now().subtract(Duration(hours: 2)),
        updatedAt: DateTime.now().subtract(Duration(hours: 2)),
        commentsList: [
          Comment(
            id: '1',
            postId: '1',
            farmerId: '2',
            farmerName: 'Priya Sharma',
            farmerImage: 'assets/images/farmer.jpg',
            content: 'Great tips! Thanks for sharing.',
            createdAt: DateTime.now().subtract(Duration(hours: 1)),
            likes: 3,
            isLiked: false,
            replies: [],
          ),
        ],
        location: 'Punjab, India',
        isVerified: true,
      ),
      CommunityPost(
        id: '2',
        farmerId: '2',
        farmerName: 'Priya Sharma',
        farmerImage: 'assets/images/farmer.jpg',
        title: 'Market Price Update - Tomatoes',
        content: 'Current market price for tomatoes in Maharashtra is ₹45/kg. Good time to sell!',
        category: 'Market Updates',
        images: [],
        tags: ['market', 'price', 'tomatoes'],
        likes: 23,
        comments: 5,
        shares: 3,
        isLiked: true,
        createdAt: DateTime.now().subtract(Duration(hours: 4)),
        updatedAt: DateTime.now().subtract(Duration(hours: 4)),
        commentsList: [],
        location: 'Maharashtra, India',
        isVerified: true,
      ),
    ];
  }

  // Dummy Orders
  static List<Order> getDummyOrders() {
    return [
      Order(
        id: '1',
        farmerId: '2',
        buyerId: 'buyer1',
        buyerName: 'John Doe',
        buyerPhone: '+91 9876543213',
        buyerAddress: '123 Main Street, Mumbai',
        items: [
          OrderItem(
            id: '1',
            productId: '1',
            productName: 'Fresh Organic Tomatoes',
            productImage: 'assets/images/farmer.jpg',
            price: 45.0,
            quantity: 2,
            unit: 'kg',
            totalPrice: 90.0,
          ),
        ],
        totalAmount: 90.0,
        status: 'confirmed',
        paymentMethod: 'online_payment',
        paymentStatus: 'paid',
        orderDate: DateTime.now().subtract(Duration(hours: 2)),
        deliveryDate: DateTime.now().add(Duration(days: 1)),
        deliveryAddress: '123 Main Street, Mumbai',
        notes: 'Please deliver in the morning',
        trackingNumber: 'TRK123456789',
        statusHistory: [
          OrderStatus(
            status: 'pending',
            description: 'Order placed',
            timestamp: DateTime.now().subtract(Duration(hours: 2)),
          ),
          OrderStatus(
            status: 'confirmed',
            description: 'Order confirmed by farmer',
            timestamp: DateTime.now().subtract(Duration(hours: 1)),
          ),
        ],
        deliveryFee: 0.0,
        taxAmount: 0.0,
        couponCode: '',
        discountAmount: 0.0,
      ),
    ];
  }

  // Dummy Notifications
  static List<AppNotification> getDummyNotifications() {
    return [
      AppNotification(
        id: '1',
        title: 'New Order Received',
        message: 'You have received a new order for Fresh Organic Tomatoes',
        type: 'order',
        category: 'newOrder',
        isRead: false,
        createdAt: DateTime.now().subtract(Duration(minutes: 30)),
        data: {'orderId': '1', 'productName': 'Fresh Organic Tomatoes'},
        actionUrl: '/orders/1',
        farmerId: '2',
      ),
      AppNotification(
        id: '2',
        title: 'Weather Alert',
        message: 'Heavy rain expected tomorrow. Protect your crops.',
        type: 'weather',
        category: 'weatherAlert',
        isRead: true,
        createdAt: DateTime.now().subtract(Duration(hours: 1)),
        data: {'alertType': 'rain', 'severity': 'high'},
        farmerId: '1',
      ),
      AppNotification(
        id: '3',
        title: 'New Comment',
        message: 'Priya Sharma commented on your post',
        type: 'community',
        category: 'newComment',
        isRead: false,
        createdAt: DateTime.now().subtract(Duration(minutes: 15)),
        data: {'postId': '1', 'commenterName': 'Priya Sharma'},
        actionUrl: '/community/1',
        farmerId: '1',
      ),
    ];
  }
}

// Additional mock data for new features
extension DummyDataNew on DummyData {
  static List<Crop> getDummyCrops() {
    return DemoDataService.getDemoCrops();
  }

  static List<Scheme> getDummySchemes() {
    return DemoDataService.getPersonalizedSchemes();
  }

  static DiseaseDetectionResult getDummyDiseaseResult() {
    return DiseaseDetectionResult(
      diseaseName: 'Leaf Blight',
      confidence: 0.86,
      remedies: [
        Remedy(
          type: 'organic',
          name: 'Neem Oil Spray',
          instruction: 'Mix 5 ml/L water and spray in evening, repeat after 7 days',
          marketplaceQuery: 'Neem Oil',
        ),
        Remedy(
          type: 'chemical',
          name: 'Mancozeb 75% WP',
          instruction: '2 g/L spray, follow label safety instructions',
          marketplaceQuery: 'Mancozeb',
        ),
      ],
    );
  }
}
