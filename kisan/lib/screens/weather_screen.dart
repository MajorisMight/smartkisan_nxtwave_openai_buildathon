import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kisan/providers/profile_provider.dart';
import 'package:kisan/providers/weather_provider.dart';
import '../constants/app_colors.dart';
import '../models/weather.dart';

class WeatherScreen extends ConsumerWidget {
  const WeatherScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the weatherProvider to get the data and handle async states
    final weatherAsync = ref.watch(weatherProvider);

    return Container(
        decoration: BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: weatherAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text('Error: $err')),
            data: (weatherData) {
              // Once data is loaded, build the main content
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(weatherData.location, ref),
                    _buildCurrentWeather(weatherData),
                    _buildWeatherForecast(weatherData),
                    _buildWeatherAlerts(weatherData),
                    _buildSoilConditions(weatherData),
                    _buildCropRecommendations(weatherData),
                    SizedBox(height: 20.h),
                  ],
                ),
              );
            },
          ),
        ),
      );
    
  }
}
  Widget _buildHeader(String location, WidgetRef ref) {
    return Container(
      padding: EdgeInsets.all(20.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Weather',
                style: GoogleFonts.poppins(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                location,
                style: GoogleFonts.poppins(
                  fontSize: 16.sp,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          IconButton(
            icon: Icon(Icons.refresh, color: AppColors.primaryGreen),
            onPressed:() =>  ref.invalidate(weatherProvider),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentWeather(WeatherData weatherData) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${weatherData.temperature.toStringAsFixed(1)}°C',
                      style: GoogleFonts.poppins(
                        fontSize: 48.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      weatherData.condition,
                      style: GoogleFonts.poppins(
                        fontSize: 18.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      weatherData.description,
                      style: GoogleFonts.poppins(
                        fontSize: 14.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                _getWeatherIcon(weatherData.condition),
                size: 80.sp,
                color: AppColors.primaryGreen,
              ),
            ],
          ),
          SizedBox(height: 20.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildWeatherDetail('Humidity', '${weatherData.humidity.toStringAsFixed(0)}%', FontAwesomeIcons.droplet),
              _buildWeatherDetail('Wind', '${weatherData.windSpeed.toStringAsFixed(0)} km/h', FontAwesomeIcons.wind),
              _buildWeatherDetail('Pressure', '${weatherData.pressure.toStringAsFixed(0)} hPa', FontAwesomeIcons.gauge),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherDetail(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primaryGreen, size: 20.sp),
        SizedBox(height: 4.h),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12.sp,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildWeatherForecast(WeatherData weatherData) {
    if (weatherData.forecast.isEmpty) return SizedBox.shrink();

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '3-Day Forecast',
            style: GoogleFonts.poppins(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 12.h),
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadowLight,
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: weatherData.forecast.map((forecast) => _buildForecastItem(forecast)).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForecastItem(WeatherForecast forecast) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _formatDate(forecast.date),
                style: GoogleFonts.poppins(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                forecast.condition,
                style: GoogleFonts.poppins(
                  fontSize: 14.sp,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Icon(
                _getWeatherIcon(forecast.condition),
                color: AppColors.primaryGreen,
                size: 24.sp,
              ),
              SizedBox(width: 12.w),
              Text(
                '${forecast.maxTemp.toStringAsFixed(0)}°/${forecast.minTemp.toStringAsFixed(0)}°',
                style: GoogleFonts.poppins(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherAlerts(WeatherData weatherData) {
    if (weatherData.alerts.warnings.isEmpty) return SizedBox.shrink();

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Weather Alerts',
            style: GoogleFonts.poppins(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 12.h),
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: AppColors.warning),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.warning, color: AppColors.warning, size: 20.sp),
                    SizedBox(width: 8.w),
                    Text(
                      'Risk Level: ${weatherData.alerts.riskLevel}',
                      style: GoogleFonts.poppins(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.warning,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                ...weatherData.alerts.warnings.map((warning) => Padding(
                  padding: EdgeInsets.only(bottom: 4.h),
                  child: Text(
                    '• $warning',
                    style: GoogleFonts.poppins(
                      fontSize: 14.sp,
                      color: AppColors.textPrimary,
                    ),
                  ),
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSoilConditions(WeatherData weatherData) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Soil Conditions',
            style: GoogleFonts.poppins(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 12.h),
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadowLight,
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildSoilDetail('Moisture', '${weatherData.soilConditions.moisture.toStringAsFixed(0)}%', FontAwesomeIcons.droplet),
                    _buildSoilDetail('Temperature', '${weatherData.soilConditions.temperature.toStringAsFixed(0)}°C', FontAwesomeIcons.temperatureHalf),
                  ],
                ),
                SizedBox(height: 12.h),
                Text(
                  weatherData.soilConditions.recommendation,
                  style: GoogleFonts.poppins(
                    fontSize: 14.sp,
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSoilDetail(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primaryGreen, size: 20.sp),
        SizedBox(height: 4.h),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12.sp,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildCropRecommendations(WeatherData weatherData) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Crop Recommendations',
            style: GoogleFonts.poppins(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 12.h),
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadowLight,
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Suitable Crops:',
                  style: GoogleFonts.poppins(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 8.h),
                Wrap(
                  spacing: 8.w,
                  children: weatherData.cropRecommendations.suitableCrops.map((crop) => Chip(
                    label: Text(crop),
                    backgroundColor: AppColors.primaryGreen.withValues(alpha: 0.1),
                    labelStyle: GoogleFonts.poppins(color: AppColors.primaryGreen),
                  )).toList(),
                ),
                SizedBox(height: 12.h),
                Text(
                  'Irrigation Advice:',
                  style: GoogleFonts.poppins(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  weatherData.cropRecommendations.irrigationAdvice,
                  style: GoogleFonts.poppins(
                    fontSize: 14.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 10,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(context, ref, Icons.home, 'Home', 0),
              _buildNavItem(context, ref, Icons.store, 'Market', 1),
              _buildNavItem(context, ref, Icons.wb_sunny, 'Weather', 2),
              _buildNavItem(context, ref, Icons.people, 'Community', 3),
              _buildNavItem(context, ref, Icons.person, 'Profile', 4),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, WidgetRef ref, IconData icon, String label, int index) {
     // 1. Get the currently selected index from the provider.
    final currentIndex = ref.watch(bottomNavIndexProvider);
    
    // 2. Determine if THIS item is the selected one.
    final isSelected = (currentIndex == index);

    return GestureDetector(
      onTap: () {
        // 3. Update the provider's state with the new index.
      ref.read(bottomNavIndexProvider.notifier).state = index;
        // 4. Navigate to the corresponding screen.
        switch (index) {
        case 0: context.go('/home'); break;
        case 1: context.go('/marketplace'); break;
        case 2: context.go('/weather'); break;
        case 3: context.go('/community'); break;
        case 4: context.go('/profile'); break;
      }
    },
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: isSelected ? AppColors.primaryGreen : AppColors.textSecondary,
          size: 24.sp,
        ),
        SizedBox(height: 4.h),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12.sp,
            color: isSelected ? AppColors.primaryGreen : AppColors.textSecondary,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    ),
  );
}

  IconData _getWeatherIcon(String condition) {
    switch (condition.toLowerCase()) {
      case 'sunny':
      case 'clear':
        return FontAwesomeIcons.sun;
      case 'cloudy':
      case 'partly cloudy':
        return FontAwesomeIcons.cloud;
      case 'rainy':
      case 'rain':
        return FontAwesomeIcons.cloudRain;
      case 'foggy':
      case 'fog':
        return FontAwesomeIcons.smog;
      default:
        return FontAwesomeIcons.cloud;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now).inDays;
    
    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Tomorrow';
    } else {
      return '${date.day}/${date.month}';
    }
  }
