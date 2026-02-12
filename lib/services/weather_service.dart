import '../models/weather.dart';
import '../utils/dummy_data.dart';

class WeatherService {
  // Get current weather
  static Future<WeatherData> getCurrentWeather(String location) async {
    // Simulate API call delay
    await Future.delayed(Duration(seconds: 2));
    
    // Return dummy weather data
    return DummyData.getDummyWeatherData();
  }

  // Get weather forecast
  static Future<List<WeatherData>> getWeatherForecast(String location, int days) async {
    // Simulate API call delay
    await Future.delayed(Duration(seconds: 2));
    
    // Generate dummy forecast data
    List<WeatherData> forecast = [];
    for (int i = 1; i <= days; i++) {
      forecast.add(
        WeatherData(
          location: location,
          temperature: 25.0 + i.toDouble(),
          humidity: 70.0 + i.toDouble(),
          windSpeed: 8.0 + i.toDouble(),
          windDirection: 'N',
          pressure: 1013.0,
          visibility: 10.0,
          condition: i % 3 == 0 ? 'Cloudy' : 'Sunny',
          description: i % 3 == 0 ? 'Cloudy sky' : 'Clear sky',
          icon: i % 3 == 0 ? '04d' : '01d',
          timestamp: DateTime.now().add(Duration(days: i)),
          forecast: [],
          alerts: WeatherAlerts(
            warnings: [],
            advisories: [],
            riskLevel: 'Low',
          ),
          soilConditions: SoilConditions(
            moisture: 20.0,
            temperature: 25.0,
            condition: 'Good',
            recommendation: 'Maintain moisture',
          ),
          cropRecommendations: CropRecommendations(
            suitableCrops: ['Wheat', 'Rice'],
            plantingTips: ['Plant early morning'],
            irrigationAdvice: 'Irrigate weekly',
            pestControl: 'Monitor for pests',
          ),
        ),
      );
    }
    return forecast;
  }

  // Get agricultural recommendations based on weather
  static Future<List<String>> getAgriculturalRecommendations(WeatherData weather) async {
    // Simulate API call delay
    await Future.delayed(Duration(seconds: 1));
    
    List<String> recommendations = [];
    
    if (weather.temperature > 30) {
      recommendations.add('High temperature detected. Ensure adequate irrigation for crops.');
    } else if (weather.temperature < 15) {
      recommendations.add('Low temperature detected. Protect sensitive crops from frost.');
    }
    
    if (weather.humidity > 80) {
      recommendations.add('High humidity detected. Monitor for fungal diseases.');
    }
    
    if (weather.windSpeed > 15) {
      recommendations.add('Strong winds detected. Secure greenhouse structures and protect young plants.');
    }
    
    if (weather.condition.toLowerCase().contains('rain')) {
      recommendations.add('Rain expected. Avoid pesticide application and prepare for drainage.');
    }
    
    // Default recommendations
    if (recommendations.isEmpty) {
      recommendations.add('Weather conditions are favorable for farming activities.');
      recommendations.add('Continue regular crop monitoring and maintenance.');
    }
    
    return recommendations;
  }

  // Get weather alerts
  static Future<List<String>> getWeatherAlerts(String location) async {
    // Simulate API call delay
    await Future.delayed(Duration(seconds: 1));
    
    List<String> alerts = [];
    
    // Simulate some alerts based on current conditions
    final weather = DummyData.getDummyWeatherData();
    
    if (weather.temperature > 35) {
      alerts.add('Heat wave warning: Temperatures above 35°C expected.');
    }
    
    if (weather.windSpeed > 20) {
      alerts.add('Strong wind warning: Winds above 20 km/h expected.');
    }
    
    if (weather.humidity > 90) {
      alerts.add('High humidity alert: Risk of fungal diseases increased.');
    }
    
    return alerts;
  }

  // Get historical weather data
  static Future<List<WeatherData>> getHistoricalWeather(String location, DateTime startDate, DateTime endDate) async {
    // Simulate API call delay
    await Future.delayed(Duration(seconds: 2));
    
    List<WeatherData> historicalData = [];
    int days = endDate.difference(startDate).inDays;
    
    for (int i = 0; i < days; i++) {
      historicalData.add(
        WeatherData(
          location: location,
          temperature: 20.0 + (i % 10).toDouble(),
          humidity: 60.0 + (i % 20).toDouble(),
          windSpeed: 5.0 + (i % 15).toDouble(),
          windDirection: 'N',
          pressure: 1013.0,
          visibility: 10.0,
          condition: i % 2 == 0 ? 'Sunny' : 'Cloudy',
          description: i % 2 == 0 ? 'Clear sky' : 'Cloudy sky',
          icon: i % 2 == 0 ? '01d' : '04d',
          timestamp: startDate.add(Duration(days: i)),
          forecast: [],
          alerts: WeatherAlerts(
            warnings: [],
            advisories: [],
            riskLevel: 'Low',
          ),
          soilConditions: SoilConditions(
            moisture: 20.0,
            temperature: 25.0,
            condition: 'Good',
            recommendation: 'Maintain moisture',
          ),
          cropRecommendations: CropRecommendations(
            suitableCrops: ['Wheat', 'Rice'],
            plantingTips: ['Plant early morning'],
            irrigationAdvice: 'Irrigate weekly',
            pestControl: 'Monitor for pests',
          ),
        ),
      );
    }
    
    return historicalData;
  }
}
