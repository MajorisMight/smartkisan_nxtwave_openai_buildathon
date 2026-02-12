import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kisan/l10n/app_localizations.dart';
import 'package:kisan/screens/ai_insights_screen.dart';
import 'package:kisan/screens/crop_list_screen.dart';
import 'package:kisan/screens/lang_select.dart';
import 'package:kisan/services/app_config_service.dart';
import 'package:kisan/services/session_service.dart';
import 'package:provider/provider.dart';
import 'providers/profile_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/marketplace_screen.dart';
import 'screens/weather_screen.dart';
import 'screens/community_screen.dart';
import 'screens/otp_screen.dart';
import 'screens/new_onboarding_screen.dart';
import 'screens/schemes_screen.dart';
import 'screens/disease_detect_screen.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await dotenv.load(fileName: '.env');
  } catch (_) {}

  if (AppConfigService.shouldResetAppDataOnStartup()) {
    await SessionService.clearAllLocalData();
  }
  runApp(const FarmerEcosystemApp());
}

class FarmerEcosystemApp extends StatefulWidget {
  const FarmerEcosystemApp({super.key});

  @override
  State<FarmerEcosystemApp> createState() => _FarmerEcosystemAppState();
  
  /// Method to change the locale from child widgets
  static void setLocale(BuildContext context, Locale newLocale) {
    _FarmerEcosystemAppState? state = context.findAncestorStateOfType<_FarmerEcosystemAppState>();
    state?.changeLocale(newLocale);
  }
}

class _FarmerEcosystemAppState extends State<FarmerEcosystemApp> {
  Locale? _locale;
  late final GoRouter _router; // keep one instance

  @override
  void initState() {
    super.initState();

    _router = GoRouter(
      routes: [
        GoRoute(path: '/', builder: (context, state) => SplashScreen()),
        GoRoute(path: '/otp', builder: (context, state) => const OtpScreen()),
        GoRoute(path: '/onboarding', builder: (context, state) => const NewOnboardingScreen()),
        GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
        GoRoute(path: '/schemes', builder: (context, state) => const SchemesScreen()),
        GoRoute(path: '/crops', builder: (context, state) => CropListScreen()),
        GoRoute(path: '/disease-detect', builder: (context, state) => const DiseaseDetectScreen(crop: null)),
        GoRoute(path: '/ai-insights', builder: (context, state) => const AIInsightsScreen()),
        GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
        GoRoute(path: '/profile', builder: (context, state) => const ProfileScreen()),
        GoRoute(path: '/marketplace', builder: (context, state) => MarketplaceScreen()),
        GoRoute(path: '/weather', builder: (context, state) => WeatherScreen()),
        GoRoute(path: '/community', builder: (context, state) => CommunityScreen()),
        GoRoute(path: '/language-select', builder: (context, state) => LanguageSelectPage()),
      ],
    );

    _loadLocale();
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      builder: (context, child) {
        return MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => ProfileProvider()..loadFromStorage()),
          ],
          child: MaterialApp.router(
            debugShowCheckedModeBanner: false,
            title: 'Farmer Ecosystem',
            theme: ThemeData(
              textTheme: GoogleFonts.poppinsTextTheme(),
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
              visualDensity: VisualDensity.adaptivePlatformDensity,
              useMaterial3: true,
            ),
            locale: _locale,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            routerConfig: _router, // ✅ reuses one router
          ),
        );
      },
    );
  }

  void changeLocale(Locale locale) {
    setState(() => _locale = locale);
  }

  void _loadLocale() async {
    final code = await SessionService.getLanguagePreference();
    if (code != null) {
      setState(() {
        _locale = Locale(code);
      });
    }
  }
}
