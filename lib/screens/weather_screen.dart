import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../constants/app_colors.dart';
import '../models/onboarding_profile.dart';
import '../models/weather.dart';
import '../providers/profile_provider.dart';
import '../services/weather_advisor_cache_service.dart';
import '../services/weather_advisor_service.dart';
import '../services/weather_service.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final TextEditingController _locationController = TextEditingController();
  String _activeQueryLocation = '';

  int _selectedIndex = 2;
  bool _weatherLoading = false;
  bool _aiLoading = false;
  WeatherData? _weatherData;
  List<WeatherAdvisory> _llmAdvisories = [];
  String _llmSummary = '';
  DateTime? _llmCachedAt;
  String? _llmError;
  String? _error;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final profile = Provider.of<ProfileProvider>(context).profile;
    final location = _resolveLocation(profile);
    if (_activeQueryLocation != location) {
      _activeQueryLocation = location;
      _locationController.text = location;
      if (location.isEmpty) {
        setState(() {
          _weatherLoading = false;
          _aiLoading = false;
          _weatherData = null;
          _error = null;
          _llmError = null;
          _llmSummary = '';
          _llmCachedAt = null;
          _llmAdvisories = const [];
        });
      } else {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _loadWeather(location: location);
        });
      }
    }
  }

  @override
  void dispose() {
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _loadWeather({String? location}) async {
    final query = (location ?? _locationController.text).trim();
    if (query.isEmpty) {
      debugPrint('[WeatherScreen] empty query, not loading weather');
      setState(() {
        _weatherLoading = false;
        _aiLoading = false;
        _error = null;
        _weatherData = null;
        _llmSummary = '';
        _llmCachedAt = null;
        _llmAdvisories = const [];
        _llmError = null;
      });
      return;
    }

    setState(() {
      _weatherLoading = true;
      _error = null;
      if (_activeQueryLocation != query) {
        _llmSummary = '';
        _llmAdvisories = const [];
        _llmCachedAt = null;
        _llmError = null;
      }
    });

    debugPrint('[WeatherScreen] _loadWeather start query="$query"');
    try {
      final weather = await WeatherService.getCurrentWeather(query);
      debugPrint('[WeatherScreen] current weather loaded location="${weather.location}"');
      if (!mounted) return;

      setState(() {
        _activeQueryLocation = query;
        _locationController.text = query;
        _weatherData = weather;
        _weatherLoading = false;
      });

      await _loadAiNotes(query: query, weather: weather);
      debugPrint('[WeatherScreen] _loadWeather completed query="$query"');
    } catch (e) {
      debugPrint('[WeatherScreen] weather pipeline error query="$query": $e');
      if (!mounted) return;
      setState(() {
        _weatherLoading = false;
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  Future<void> _loadAiNotes({
    required String query,
    required WeatherData weather,
    bool forceRefresh = false,
  }) async {
    setState(() {
      _aiLoading = true;
      if (forceRefresh) {
        _llmError = null;
      }
    });

    if (!forceRefresh) {
      final cached = await WeatherAdvisorCacheService.readValid(location: query);
      if (cached != null) {
        if (!mounted) return;
        setState(() {
          _llmSummary = cached.summary;
          _llmAdvisories = cached.advisories;
          _llmCachedAt = cached.cachedAt;
          _llmError = null;
          _aiLoading = false;
        });
        return;
      }
    }

    try {
      final advisoryResponse = await WeatherAdvisorService.getAdvisories(
        location: query,
        weather: weather,
      );
      debugPrint(
        '[WeatherScreen] LLM advisories loaded count=${advisoryResponse.advisories.length}',
      );
      await WeatherAdvisorCacheService.write(
        location: query,
        summary: advisoryResponse.summary,
        advisories: advisoryResponse.advisories,
      );
      if (!mounted) return;
      setState(() {
        _llmSummary = advisoryResponse.summary;
        _llmAdvisories = advisoryResponse.advisories;
        _llmCachedAt = DateTime.now();
        _llmError = null;
        _aiLoading = false;
      });
    } catch (e) {
      debugPrint('[WeatherScreen] LLM advisory error: $e');
      if (!mounted) return;
      setState(() {
        _llmError = e.toString().replaceFirst('Exception: ', '');
        _aiLoading = false;
      });
    }
  }

  Future<void> _refreshAiNotes() async {
    final weather = _weatherData;
    if (weather == null) {
      await _loadWeather();
      return;
    }
    final query = _activeQueryLocation.isEmpty
        ? _locationController.text.trim()
        : _activeQueryLocation;
    if (query.isEmpty) return;
    await _loadAiNotes(query: query, weather: weather, forceRefresh: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: () => _loadWeather(),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 24.h),
              children: [
                _buildHeader(),
                SizedBox(height: 14.h),
                _buildLocationInput(),
                SizedBox(height: 16.h),
                if (_error != null)
                  _buildErrorCard()
                else if (_weatherLoading && _weatherData == null)
                  const Center(child: CircularProgressIndicator())
                else
                  ..._buildWeatherContent(),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Weather',
          style: GoogleFonts.poppins(
            fontSize: 26.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        IconButton(
          onPressed: _weatherLoading ? null : () => _loadWeather(),
          icon: const Icon(Icons.refresh_rounded),
          color: AppColors.primaryGreen,
        ),
      ],
    );
  }

  String _resolveLocation(FarmerProfile? profile) {
    return (profile?.village ?? '').trim();
  }

  Widget _buildLocationInput() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _locationController,
            textInputAction: TextInputAction.search,
            onSubmitted: (value) => _loadWeather(location: value),
            decoration: InputDecoration(
              hintText: 'Enter city',
              hintStyle: GoogleFonts.poppins(color: AppColors.textSecondary, fontSize: 13.sp),
              filled: true,
              fillColor: AppColors.white,
              contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: const BorderSide(color: AppColors.borderLight),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: const BorderSide(color: AppColors.primaryGreen),
              ),
            ),
          ),
        ),
        SizedBox(width: 8.w),
        SizedBox(
          height: 46.h,
          child: ElevatedButton(
            onPressed: _weatherLoading ? null : () => _loadWeather(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
            ),
            child: Text(
              'Load',
              style: GoogleFonts.poppins(color: AppColors.white, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorCard() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Unable to load weather',
            style: GoogleFonts.poppins(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.error,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            _error!,
            style: GoogleFonts.poppins(fontSize: 13.sp, color: AppColors.textSecondary),
          ),
          SizedBox(height: 10.h),
          TextButton(
            onPressed: () => _loadWeather(),
            child: Text(
              'Retry',
              style: GoogleFonts.poppins(color: AppColors.primaryGreen, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildWeatherContent() {
    final weather = _weatherData;
    if (weather == null) {
      return const <Widget>[];
    }

    return [
      _buildCurrentWeatherCard(weather),
      SizedBox(height: 12.h),
      _buildMetricsGrid(weather),
      SizedBox(height: 16.h),
      if (weather.forecast.isNotEmpty) ...[
        _buildForecastCard(weather.forecast),
        SizedBox(height: 16.h),
      ],
      _buildAdvisorySection(
        title: 'AI Weather Notes',
        summary: _llmSummary,
        advisories: _llmAdvisories,
        cachedAt: _llmCachedAt,
        loading: _aiLoading,
        emptyMessage: 'No AI advisories available.',
      ),
    ];
  }

  Widget _buildCurrentWeatherCard(WeatherData weather) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  weather.location,
                  style: GoogleFonts.poppins(
                    fontSize: 13.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  '${weather.temperature.toStringAsFixed(1)}°C',
                  style: GoogleFonts.poppins(
                    fontSize: 38.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  weather.condition,
                  style: GoogleFonts.poppins(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryGreenDark,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  weather.description,
                  style: GoogleFonts.poppins(
                    fontSize: 12.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            _getWeatherIcon(weather.condition),
            size: 52.sp,
            color: AppColors.primaryGreen,
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsGrid(WeatherData weather) {
    return Row(
      children: [
        Expanded(child: _buildMetricTile('Humidity', '${weather.humidity.toStringAsFixed(0)}%', FontAwesomeIcons.droplet)),
        SizedBox(width: 8.w),
        Expanded(child: _buildMetricTile('Wind', '${weather.windSpeed.toStringAsFixed(0)} km/h', FontAwesomeIcons.wind)),
        SizedBox(width: 8.w),
        Expanded(child: _buildMetricTile('Pressure', '${weather.pressure.toStringAsFixed(0)} hPa', FontAwesomeIcons.gauge)),
      ],
    );
  }

  Widget _buildMetricTile(String label, String value, IconData icon) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 12.h),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          Icon(icon, size: 16.sp, color: AppColors.primaryGreen),
          SizedBox(height: 6.h),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 2.h),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 11.sp,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForecastCard(List<WeatherForecast> forecast) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Forecast',
            style: GoogleFonts.poppins(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8.h),
          ...forecast.take(5).map(
            (item) => Padding(
              padding: EdgeInsets.symmetric(vertical: 7.h),
              child: Row(
                children: [
                  SizedBox(
                    width: 92.w,
                    child: Text(
                      DateFormat('EEE, d MMM').format(item.date),
                      style: GoogleFonts.poppins(fontSize: 12.sp, color: AppColors.textSecondary),
                    ),
                  ),
                  Icon(_getWeatherIcon(item.condition), size: 14.sp, color: AppColors.primaryGreen),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      item.condition,
                      style: GoogleFonts.poppins(fontSize: 12.sp, color: AppColors.textPrimary),
                    ),
                  ),
                  Text(
                    '${item.maxTemp.toStringAsFixed(0)}°/${item.minTemp.toStringAsFixed(0)}°',
                    style: GoogleFonts.poppins(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdvisorySection({
    required String title,
    required String summary,
    required List<WeatherAdvisory> advisories,
    required DateTime? cachedAt,
    required bool loading,
    required String emptyMessage,
  }) {
    final freshnessText = cachedAt == null
        ? 'Not generated yet'
        : 'Last updated ${DateFormat('d MMM, h:mm a').format(cachedAt)}';

    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: _cardDecoration().copyWith(
        border: Border.all(color: AppColors.primaryGreen.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryGreenDark,
                ),
              ),
              IconButton(
                tooltip: 'Refresh AI notes',
                onPressed: loading ? null : _refreshAiNotes,
                icon: loading
                    ? SizedBox(
                        height: 18.sp,
                        width: 18.sp,
                        child: const CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.sync_rounded),
                color: AppColors.primaryGreen,
              ),
            ],
          ),
          Text(
            freshnessText,
            style: GoogleFonts.poppins(
              fontSize: 11.sp,
              color: AppColors.textSecondary,
            ),
          ),
          if (summary.isNotEmpty) ...[
            SizedBox(height: 8.h),
            Text(
              summary,
              style: GoogleFonts.poppins(
                fontSize: 12.sp,
                color: AppColors.textSecondary,
              ),
            ),
          ],
          SizedBox(height: 8.h),
          if (advisories.isEmpty && loading)
            Text(
              'Loading AI advisories...',
              style: GoogleFonts.poppins(
                fontSize: 12.sp,
                color: AppColors.textSecondary,
              ),
            )
          else if (advisories.isEmpty)
            Text(
              _llmError == null ? emptyMessage : 'AI advisories unavailable: $_llmError',
              style: GoogleFonts.poppins(
                fontSize: 12.sp,
                color: AppColors.textSecondary,
              ),
            ),
          ...advisories.map(
            (item) => Container(
              margin: EdgeInsets.only(bottom: 8.h),
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: _priorityColor(item.priority).withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(
                  color: _priorityColor(item.priority).withValues(alpha: 0.25),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${item.headline} • ${item.timeHorizon}',
                    style: GoogleFonts.poppins(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    item.advice,
                    style: GoogleFonts.poppins(
                      fontSize: 12.sp,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (item.reason.isNotEmpty) ...[
                    SizedBox(height: 4.h),
                    Text(
                      item.reason,
                      style: GoogleFonts.poppins(
                        fontSize: 11.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _priorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return AppColors.error;
      case 'low':
        return AppColors.success;
      case 'medium':
      default:
        return AppColors.warning;
    }
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(14.r),
      boxShadow: const [
        BoxShadow(
          color: AppColors.shadowLight,
          blurRadius: 8,
          offset: Offset(0, 3),
        ),
      ],
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: const BoxDecoration(
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
              _buildNavItem(Icons.home, 'Home', 0),
              _buildNavItem(Icons.store, 'Market', 1),
              _buildNavItem(Icons.wb_sunny, 'Weather', 2),
              _buildNavItem(Icons.people, 'Community', 3),
              _buildNavItem(Icons.person, 'Profile', 4),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() => _selectedIndex = index);
        switch (index) {
          case 0:
            context.go('/home');
            break;
          case 1:
            context.go('/marketplace');
            break;
          case 2:
            break;
          case 3:
            context.go('/community');
            break;
          case 4:
            context.go('/profile');
            break;
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
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getWeatherIcon(String condition) {
    final normalized = condition.toLowerCase();
    if (normalized.contains('clear') || normalized.contains('sun')) return FontAwesomeIcons.sun;
    if (normalized.contains('cloud') || normalized.contains('overcast')) return FontAwesomeIcons.cloud;
    if (normalized.contains('rain') || normalized.contains('drizzle')) return FontAwesomeIcons.cloudRain;
    if (normalized.contains('storm') || normalized.contains('thunder')) return FontAwesomeIcons.cloudBolt;
    if (normalized.contains('fog')) return FontAwesomeIcons.smog;
    if (normalized.contains('snow')) return FontAwesomeIcons.snowflake;
    return FontAwesomeIcons.cloud;
  }
}
