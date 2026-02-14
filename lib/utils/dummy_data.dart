import '../models/weather.dart';

class DummyData {
  
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

}