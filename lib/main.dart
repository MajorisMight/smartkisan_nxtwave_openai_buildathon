import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kisan/Widgets/scaffoldWithNavBar.dart';
import 'package:kisan/l10n/app_localizations.dart';
import 'package:kisan/providers/auth_provider.dart';
import 'package:kisan/providers/auth_repository.dart';
import 'package:kisan/providers/profile_provider.dart';
// import 'package:kisan/screens/ai_insights_screen.dart';
import 'package:kisan/screens/confirm_email_screen.dart';
import 'package:kisan/screens/crop_list_screen.dart';
import 'package:kisan/screens/crop_suggestion_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart' as provider;
import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/marketplace_screen.dart';
import 'screens/weather_screen.dart';
import 'screens/community_screen.dart';
import 'screens/lang_select.dart';
import 'screens/login_screen.dart';
import 'screens/new_onboarding_screen.dart';
import 'screens/schemes_screen.dart';
import 'screens/disease_detect_screen.dart';
import 'services/app_config_service.dart';
import 'services/session_service.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: '.env');
  } catch (_) {}

  if (AppConfigService.shouldResetAppDataOnStartup()) {
    await SessionService.clearAllLocalData();
  }

  final supabaseUrl = dotenv.env['SUPABASE_URL'];
  final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'];
  if (supabaseUrl == null ||
      supabaseUrl.isEmpty ||
      supabaseAnonKey == null ||
      supabaseAnonKey.isEmpty) {
    throw StateError('Missing SUPABASE_URL or SUPABASE_ANON_KEY in .env');
  }

  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);

  runApp(
    ProviderScope(
      child: provider.ChangeNotifierProvider(
        create: (_) => ProfileProvider()..loadProfile(),
        child: const FarmerEcosystemApp(),
      ),
    ),
  );
}

// Helper for easy access to the Supabase client
final supabase = Supabase.instance.client;

class FarmerEcosystemApp extends ConsumerStatefulWidget {
  const FarmerEcosystemApp({super.key});

  static void setLocale(BuildContext context, Locale locale) {
    final state = context.findAncestorStateOfType<_FarmerEcosystemAppState>();
    state?.setLocale(locale);
  }

  @override
  ConsumerState<FarmerEcosystemApp> createState() => _FarmerEcosystemAppState();
}

class _FarmerEcosystemAppState extends ConsumerState<FarmerEcosystemApp> {
  Locale? _locale;
  late final GoRouter _router;

  void setLocale(Locale locale) {
    if (!mounted) return;
    setState(() {
      _locale = locale;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadSavedLocale();
    final authRepository = ref.read(authRepositoryProvider);
    _router = GoRouter(
      initialLocation: '/',
      refreshListenable: GoRouterRefreshStream(authRepository.authStateChanges),
      redirect: (BuildContext context, GoRouterState state) async {
        if (!AppConfigService.isAuthFlowEnabled()) {
          return null;
        }

        final user = authRepository.currentUser;
        final currentLoc = state.uri.toString();
        final pendingEmail = ref.read(pendingEmailConfirmationProvider);

        final isAuthRoute =
            currentLoc == '/login' ||
            currentLoc == '/confirm-email' ||
            currentLoc == '/language-select';
        final isSplash = currentLoc == '/';

        print('=== REDIRECT DEBUG ===');
        print('Current location: $currentLoc');
        print('User exists: ${user != null}');
        print('User email: ${user?.email}');
        print('Email confirmed at: ${user?.emailConfirmedAt}');
        print('Pending email confirmation: $pendingEmail');
        print('Is auth route: $isAuthRoute');
        print('====================');

        if (user == null) {
          print(
            'No user and no pending confirmation - redirecting to login or staying on current auth page',
          );
          return isSplash || isAuthRoute ? null : '/login';
        }

        if (user.emailConfirmedAt == null) {
          print(
            'User exists but email not confirmed - staying on current page',
          );
          return null;
        }

        ref.invalidate(onboardingCompleteProvider);
        final isOnboarded = await ref.read(onboardingCompleteProvider.future);
        if (!isOnboarded) {
          print(
            'Email confirmed but onboarding not complete - redirecting to onboarding',
          );
          if (currentLoc == '/onboarding') {
            return null;
          }
          return '/onboarding';
        }

        if (isAuthRoute || currentLoc == '/onboarding' || isSplash) {
          print('User fully authenticated - redirecting to home');
          return '/home';
        }

        print('No redirect needed');
        return null;
      },
      routes: [
        GoRoute(path: '/', builder: (context, state) => SplashScreen()),
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        // OTP flow is disabled; keep login-based auth active.
        // GoRoute(path: '/otp', builder: (context, state) => const OtpScreen()),
        GoRoute(
          path: '/language-select',
          builder: (context, state) => const LanguageSelectPage(),
        ),
        GoRoute(
          path: '/onboarding',
          builder: (context, state) => const NewOnboardingScreen(),
        ),
        ShellRoute(
          builder: (context, state, child) {
            return ScaffoldWithNavBar(child: child);
          },
          routes: [
            GoRoute(
              path: '/home',
              builder: (context, state) => const HomeScreen(),
            ),
            GoRoute(
              path: '/marketplace',
              builder: (context, state) => const MarketplaceScreen(),
            ),
            GoRoute(
              path: '/weather',
              builder: (context, state) => const WeatherScreen(),
            ),
            GoRoute(
              path: '/community',
              builder: (context, state) => const CommunityScreen(),
            ),
            GoRoute(
              path: '/profile',
              builder: (context, state) => const ProfileScreen(),
            ),
          ],
        ),
        GoRoute(
          path: '/schemes',
          builder: (context, state) => const SchemesScreen(),
        ),
        GoRoute(
          path: "/confirm-email",
          builder: (context, state) => const ConfirmEmailScreen(),
        ),
        GoRoute(path: '/crops', builder: (context, state) => CropListScreen()),
        GoRoute(
          path: '/crop-suggestions',
          builder: (context, state) => const CropSuggestionScreen(),
        ),
        GoRoute(
          path: '/disease-detect',
          builder: (context, state) => const DiseaseDetectScreen(),
        ),
      ],
    );
  }

  Future<void> _loadSavedLocale() async {
    final savedCode = await SessionService.getLanguagePreference();
    if (!mounted || savedCode == null || savedCode.trim().isEmpty) return;
    if (savedCode != 'en' && savedCode != 'hi') return;
    setState(() {
      _locale = Locale(savedCode);
    });
  }


  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      builder: (context, child) {
        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          title: 'Farmer Ecosystem',
          locale: _locale,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          theme: ThemeData(
            textTheme: GoogleFonts.poppinsTextTheme(),
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
            useMaterial3: true,
          ),
          routerConfig: _router,
        );
      },
    );
  }
}

// Helper class to make GoRouter listen to a stream
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    stream.asBroadcastStream().listen((_) => notifyListeners());
  }
}
