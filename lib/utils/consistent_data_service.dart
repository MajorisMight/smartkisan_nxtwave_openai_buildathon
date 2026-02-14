import '../models/community_post.dart';
import '../models/product.dart';
import '../models/weather.dart';

class ConsistentDataService {
  static WeatherData getWeatherData({String location = 'Ludhiana, Punjab'}) {
    return WeatherData(
      location: location,
      temperature: 18.5,
      humidity: 72.0,
      windSpeed: 8.0,
      windDirection: 'NW',
      pressure: 1015.2,
      visibility: 12.0,
      condition: 'Partly Cloudy',
      description:
          'Cool morning with light winds, good for farming activities',
      icon: 'partly-cloudy',
      timestamp: DateTime.now(),
      forecast: [
        WeatherForecast(
          date: DateTime.now().add(const Duration(days: 1)),
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
          date: DateTime.now().add(const Duration(days: 2)),
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
          date: DateTime.now().add(const Duration(days: 3)),
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
        advisories: [
          'Good time for fertilizer application',
          'Irrigation recommended in next 2 days',
        ],
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
        plantingTips: [
          'Plant wheat in rows for better yield',
          'Apply organic manure before sowing',
        ],
        irrigationAdvice: 'Water wheat fields every 10-12 days',
        pestControl: 'Monitor for aphids in wheat, use neem oil if needed',
      ),
    );
  }

  static List<CommunityPost> getCommunityPosts() {
    return [
      CommunityPost(
        id: 'post_001',
        farmerId: 'farmer_001',
        farmerName: 'Rajesh Kumar Singh',
        farmerImageUrl: null,
        title: 'Wheat Harvest Tips for Punjab Farmers',
        content:
            'Sharing my experience with wheat cultivation this season. The HD-2967 variety has given excellent results.',
        category: 'Farming Tips',
        images: const ['assets/images/wheat.jpg'],
        tags: const ['wheat', 'harvest', 'punjab', 'tips'],
        likesCount: 67,
        commentsCount: 23,
        isLiked: true,
        createdAt: DateTime.now().subtract(const Duration(hours: 3)),
        location: 'Ludhiana, Punjab',
      ),
      CommunityPost(
        id: 'post_002',
        farmerId: 'farmer_001',
        farmerName: 'Rajesh Kumar Singh',
        farmerImageUrl: null,
        title: 'Cotton Selling Price Update',
        content:
            'Sold my cotton today at Rs 6,500 per quintal. Market is stable.',
        category: 'Market Updates',
        images: const ['assets/images/cotton.jpg'],
        tags: const ['cotton', 'price', 'market', 'selling'],
        likesCount: 34,
        commentsCount: 8,
        isLiked: false,
        createdAt: DateTime.now().subtract(const Duration(hours: 8)),
        location: 'Ludhiana, Punjab',
      ),
    ];
  }

}
