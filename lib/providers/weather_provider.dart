import 'package:flutter/material.dart';
import '../models/weather.dart';
import '../services/weather_service.dart';

class WeatherProvider with ChangeNotifier {
  WeatherData? _currentWeather;
  List<WeatherData> _forecast = [];
  List<String> _recommendations = [];
  List<String> _alerts = [];
  bool _isLoading = false;
  String? _error;
  String _location = 'Green Valley';

  // Getters
  WeatherData? get currentWeather => _currentWeather;
  List<WeatherData> get forecast => _forecast;
  List<String> get recommendations => _recommendations;
  List<String> get alerts => _alerts;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get location => _location;

  // Load current weather
  Future<void> loadCurrentWeather() async {
    _setLoading(true);
    _clearError();
    
    try {
      _currentWeather = await WeatherService.getCurrentWeather(_location);
      notifyListeners();
    } catch (e) {
      _setError('Failed to load weather: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Load weather forecast
  Future<void> loadForecast(int days) async {
    _setLoading(true);
    _clearError();
    
    try {
      _forecast = await WeatherService.getWeatherForecast(_location, days);
      notifyListeners();
    } catch (e) {
      _setError('Failed to load forecast: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Load agricultural recommendations
  Future<void> loadRecommendations() async {
    if (_currentWeather == null) return;
    
    _setLoading(true);
    _clearError();
    
    try {
      _recommendations = await WeatherService.getAgriculturalRecommendations(_currentWeather!);
      notifyListeners();
    } catch (e) {
      _setError('Failed to load recommendations: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Load weather alerts
  Future<void> loadAlerts() async {
    _setLoading(true);
    _clearError();
    
    try {
      _alerts = await WeatherService.getWeatherAlerts(_location);
      notifyListeners();
    } catch (e) {
      _setError('Failed to load alerts: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Load all weather data
  Future<void> loadAllWeatherData() async {
    _setLoading(true);
    _clearError();
    
    try {
      await Future.wait([
        loadCurrentWeather(),
        loadForecast(7),
        loadAlerts(),
      ]);
      
      // Load recommendations after current weather is loaded
      if (_currentWeather != null) {
        await loadRecommendations();
      }
    } catch (e) {
      _setError('Failed to load weather data: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Update location
  Future<void> updateLocation(String newLocation) async {
    _location = newLocation;
    await loadAllWeatherData();
  }

  // Get historical weather data
  Future<List<WeatherData>> getHistoricalWeather(DateTime startDate, DateTime endDate) async {
    try {
      return await WeatherService.getHistoricalWeather(_location, startDate, endDate);
    } catch (e) {
      _setError('Failed to load historical weather: $e');
      return [];
    }
  }

  // Refresh weather data
  Future<void> refresh() async {
    await loadAllWeatherData();
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  void clearError() {
    _clearError();
  }
}
