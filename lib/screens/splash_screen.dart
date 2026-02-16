import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';
import '../services/app_config_service.dart';
import '../services/session_service.dart';
import '../services/ai_demo_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late Animation<double> _logoAnimation;
  late Animation<double> _textAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _textController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _logoAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );

    _textAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeInOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeInOut),
    );

    _startAnimations();
  }

  void _startAnimations() async {
    await _logoController.forward();
    await Future.delayed(const Duration(milliseconds: 500));
    await _textController.forward();
    await Future.delayed(const Duration(milliseconds: 2000));

    if (mounted) {
      // Check if demo mode is enabled
      final isDemoMode = await AIDemoService.isDemoModeEnabled();
      if (isDemoMode) {
        // Skip directly to home in demo mode
        context.go('/home');
        return;
      }

      final loggedIn = await SessionService.isLoggedIn();
      final authFlowEnabled = AppConfigService.isAuthFlowEnabled();
      if (!loggedIn) {
        if (authFlowEnabled) {
          context.go('/language-select');
          return;
        }
        final onboarded = await SessionService.isOnboardingComplete();
        if (!onboarded) {
          context.go('/onboarding');
          return;
        }
        context.go('/home');
        return;
      }
      final onboarded = await SessionService.isOnboardingComplete();
      if (!onboarded) {
        context.go('/onboarding');
        return;
      }
      context.go('/home');
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo Animation
                      AnimatedBuilder(
                        animation: _logoAnimation,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _logoAnimation.value,
                            child: Container(
                              width: 120.w,
                              height: 120.w,
                              decoration: const BoxDecoration(
                                color: AppColors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.shadowMedium,
                                    blurRadius: 20,
                                    offset: Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(18.w),
                                child: Image.asset(
                                  'assets/images/AppIcon.png',
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          );
                        },
                      ),

                      SizedBox(height: 40.h),

                      // App Name Animation
                      AnimatedBuilder(
                        animation: _textAnimation,
                        builder: (context, child) {
                          return Transform.translate(
                            offset: Offset(0, 20 * (1 - _textAnimation.value)),
                            child: Opacity(
                              opacity: _fadeAnimation.value,
                              child: Column(
                                children: [
                                  Text(
                                    'GreenBird',
                                    style: GoogleFonts.poppins(
                                      fontSize: 36.sp,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.white,
                                      letterSpacing: 2.0,
                                    ),
                                  ),
                                  SizedBox(height: 8.h),
                                  Text(
                                    'Farmer Ecosystem',
                                    style: GoogleFonts.poppins(
                                      fontSize: 16.sp,
                                      color: AppColors.white.withOpacity(0.9),
                                      letterSpacing: 1.0,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),

              // Loading Indicator
              AnimatedBuilder(
                animation: _fadeAnimation,
                builder: (context, child) {
                  return Opacity(
                    opacity: _fadeAnimation.value,
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 50.h),
                      child: Column(
                        children: [
                          SizedBox(
                            width: 30.w,
                            height: 30.w,
                            child: const CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.white,
                              ),
                              strokeWidth: 2.0,
                            ),
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            'Connecting Farmers...',
                            style: GoogleFonts.poppins(
                              fontSize: 14.sp,
                              color: AppColors.white.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
