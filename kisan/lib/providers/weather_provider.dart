import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kisan/utils/consistent_data_service.dart';
import '../models/weather.dart'; // Your existing WeatherData model
import 'profile_provider.dart'; // To get the user's location

// A FutureProvider to fetch the weather data.
final weatherProvider = FutureProvider<WeatherData>((ref) async {
  // Get the user's profile to find their location
  final profile = await ref.watch(farmerProfileProvider.future);
  final location = profile['district'] ?? 'Jaipur'; // Use district as location

  // In the future, you would replace this with a real API call:
  // final weatherApi = ref.read(weatherApiServiceProvider);
  // return weatherApi.fetchWeatherFor(location);

  // For now, we use the demo service and simulate a network delay.
  await Future.delayed(const Duration(seconds: 1));
  return ConsistentDataService.getWeatherData(location: location.toString());
});
