class WeatherData {
  final String location;
  final double temperature;
  final double humidity;
  final double windSpeed;
  final String windDirection;
  final double pressure;
  final double visibility;
  final String condition;
  final String description;
  final String icon;
  final DateTime timestamp;
  final List<WeatherForecast> forecast;
  final WeatherAlerts alerts;
  final SoilConditions soilConditions;
  final CropRecommendations cropRecommendations;

  WeatherData({
    required this.location,
    required this.temperature,
    required this.humidity,
    required this.windSpeed,
    required this.windDirection,
    required this.pressure,
    required this.visibility,
    required this.condition,
    required this.description,
    required this.icon,
    required this.timestamp,
    required this.forecast,
    required this.alerts,
    required this.soilConditions,
    required this.cropRecommendations,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    return WeatherData(
      location: json['location'] ?? '',
      temperature: (json['temperature'] ?? 0).toDouble(),
      humidity: (json['humidity'] ?? 0).toDouble(),
      windSpeed: (json['windSpeed'] ?? 0).toDouble(),
      windDirection: json['windDirection'] ?? '',
      pressure: (json['pressure'] ?? 0).toDouble(),
      visibility: (json['visibility'] ?? 0).toDouble(),
      condition: json['condition'] ?? '',
      description: json['description'] ?? '',
      icon: json['icon'] ?? '',
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
      forecast: (json['forecast'] as List?)
          ?.map((e) => WeatherForecast.fromJson(e))
          .toList() ?? [],
      alerts: WeatherAlerts.fromJson(json['alerts'] ?? {}),
      soilConditions: SoilConditions.fromJson(json['soilConditions'] ?? {}),
      cropRecommendations: CropRecommendations.fromJson(json['cropRecommendations'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'location': location,
      'temperature': temperature,
      'humidity': humidity,
      'windSpeed': windSpeed,
      'windDirection': windDirection,
      'pressure': pressure,
      'visibility': visibility,
      'condition': condition,
      'description': description,
      'icon': icon,
      'timestamp': timestamp.toIso8601String(),
      'forecast': forecast.map((e) => e.toJson()).toList(),
      'alerts': alerts.toJson(),
      'soilConditions': soilConditions.toJson(),
      'cropRecommendations': cropRecommendations.toJson(),
    };
  }
}

class WeatherForecast {
  final DateTime date;
  final double maxTemp;
  final double minTemp;
  final String condition;
  final String description;
  final String icon;
  final double precipitation;
  final double humidity;
  final double windSpeed;

  WeatherForecast({
    required this.date,
    required this.maxTemp,
    required this.minTemp,
    required this.condition,
    required this.description,
    required this.icon,
    required this.precipitation,
    required this.humidity,
    required this.windSpeed,
  });

  factory WeatherForecast.fromJson(Map<String, dynamic> json) {
    return WeatherForecast(
      date: DateTime.parse(json['date'] ?? DateTime.now().toIso8601String()),
      maxTemp: (json['maxTemp'] ?? 0).toDouble(),
      minTemp: (json['minTemp'] ?? 0).toDouble(),
      condition: json['condition'] ?? '',
      description: json['description'] ?? '',
      icon: json['icon'] ?? '',
      precipitation: (json['precipitation'] ?? 0).toDouble(),
      humidity: (json['humidity'] ?? 0).toDouble(),
      windSpeed: (json['windSpeed'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'maxTemp': maxTemp,
      'minTemp': minTemp,
      'condition': condition,
      'description': description,
      'icon': icon,
      'precipitation': precipitation,
      'humidity': humidity,
      'windSpeed': windSpeed,
    };
  }
}

class WeatherAlerts {
  final List<String> warnings;
  final List<String> advisories;
  final String riskLevel;

  WeatherAlerts({
    required this.warnings,
    required this.advisories,
    required this.riskLevel,
  });

  factory WeatherAlerts.fromJson(Map<String, dynamic> json) {
    return WeatherAlerts(
      warnings: List<String>.from(json['warnings'] ?? []),
      advisories: List<String>.from(json['advisories'] ?? []),
      riskLevel: json['riskLevel'] ?? 'Low',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'warnings': warnings,
      'advisories': advisories,
      'riskLevel': riskLevel,
    };
  }
}

class SoilConditions {
  final double moisture;
  final double temperature;
  final String condition;
  final String recommendation;

  SoilConditions({
    required this.moisture,
    required this.temperature,
    required this.condition,
    required this.recommendation,
  });

  factory SoilConditions.fromJson(Map<String, dynamic> json) {
    return SoilConditions(
      moisture: (json['moisture'] ?? 0).toDouble(),
      temperature: (json['temperature'] ?? 0).toDouble(),
      condition: json['condition'] ?? '',
      recommendation: json['recommendation'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'moisture': moisture,
      'temperature': temperature,
      'condition': condition,
      'recommendation': recommendation,
    };
  }
}

class CropRecommendations {
  final List<String> suitableCrops;
  final List<String> plantingTips;
  final String irrigationAdvice;
  final String pestControl;

  CropRecommendations({
    required this.suitableCrops,
    required this.plantingTips,
    required this.irrigationAdvice,
    required this.pestControl,
  });

  factory CropRecommendations.fromJson(Map<String, dynamic> json) {
    return CropRecommendations(
      suitableCrops: List<String>.from(json['suitableCrops'] ?? []),
      plantingTips: List<String>.from(json['plantingTips'] ?? []),
      irrigationAdvice: json['irrigationAdvice'] ?? '',
      pestControl: json['pestControl'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'suitableCrops': suitableCrops,
      'plantingTips': plantingTips,
      'irrigationAdvice': irrigationAdvice,
      'pestControl': pestControl,
    };
  }
}
