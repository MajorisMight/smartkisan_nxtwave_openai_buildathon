import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kisan/constants/app_colors.dart';
import 'package:kisan/providers/fab_provider.dart';
import 'package:kisan/providers/profile_provider.dart';
import '../app_extensions.dart';


class ScaffoldWithNavBar extends ConsumerWidget {
  final Widget child;
  const ScaffoldWithNavBar({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
     // Get the current route path
    final String location = GoRouterState.of(context).uri.toString();
    
    // Get the map of all FAB configurations
    final fabConfigs = ref.watch(fabProvider);
    
    // Find the configuration for the current route, if it exists
    final currentFabConfig = fabConfigs[location];

    // Get the currently selected index to pass to the helper widgets
    final currentIndex = _calculateSelectedIndex(context);

    // Update the provider if the index has changed (e.g., from a deep link)
    // This ensures the provider state is always in sync with the route
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (ref.read(bottomNavIndexProvider) != currentIndex) {
        ref.read(bottomNavIndexProvider.notifier).state = currentIndex;
      }
    });

    return Scaffold(
      body: child,
      floatingActionButton: currentFabConfig != null
          ? FloatingActionButton(
              onPressed: () => currentFabConfig.onPressed(context),
              backgroundColor: currentFabConfig.backgroundColor,
              child: currentFabConfig.child,
            )
          : null, // If no config exists, show no FAB
      // Replace the BottomNavigationBar with your custom widget
      bottomNavigationBar: Container(
        padding: EdgeInsets.symmetric(vertical: 8.h),
        decoration: BoxDecoration(
          color: AppColors.white,
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowLight,
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // Build each nav item using your custom widget
              _buildNavItem(context, ref, Icons.home_outlined, context.l10n.navHome, 0, currentIndex),
              _buildNavItem(context, ref, Icons.store_outlined, context.l10n.navMarketplace, 1, currentIndex),
              _buildNavItem(context, ref, Icons.wb_sunny_outlined, context.l10n.navWeather, 2, currentIndex),
              _buildNavItem(context, ref, Icons.people_outline, context.l10n.navCommunity, 3, currentIndex),
              _buildNavItem(context, ref, Icons.person_outline, context.l10n.navProfile, 4, currentIndex),
            ],
          ),
        ),
      ),
    );
  }

  // Helper function to sync the current route with the nav bar index
  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/home')) return 0;
    if (location.startsWith('/marketplace')) return 1;
    if (location.startsWith('/weather')) return 2;
    if (location.startsWith('/community')) return 3;
    if (location.startsWith('/profile')) return 4;
    return 0;
  }
}


// --- YOUR CUSTOM NAV ITEM WIDGET (NOW A TOP-LEVEL FUNCTION) ---

Widget _buildNavItem(
  BuildContext context,
  WidgetRef ref,
  IconData icon,
  String label,
  int index,
  int currentIndex, // Receive the current index
) {
  final isSelected = (currentIndex == index);

  return GestureDetector(
    onTap: () {
      // Update the provider's state with the new index
      ref.read(bottomNavIndexProvider.notifier).state = index;
      
      // Navigate to the corresponding screen
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