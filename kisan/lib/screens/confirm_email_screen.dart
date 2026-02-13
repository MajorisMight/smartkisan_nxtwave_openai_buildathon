import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kisan/providers/auth_repository.dart';
import 'package:kisan/providers/auth_provider.dart'; // Import for pendingEmailConfirmationProvider
import 'package:supabase_flutter/supabase_flutter.dart';

class ConfirmEmailScreen extends ConsumerStatefulWidget {
  const ConfirmEmailScreen({super.key});

  @override
  ConsumerState<ConfirmEmailScreen> createState() => _ConfirmEmailScreenState();
}

class _ConfirmEmailScreenState extends ConsumerState<ConfirmEmailScreen> {
  late StreamSubscription<AuthState> _authSubscription;

  @override
  void initState() {
    super.initState();
    _listenToAuthChanges();
  }

  void _listenToAuthChanges() {
    final authRepo = ref.read(authRepositoryProvider);
    _authSubscription = authRepo.authStateChanges.listen((AuthState data) {
      final user = data.session?.user;
      
      print('=== AUTH STATE CHANGE IN CONFIRM EMAIL ===');
      print('Event: ${data.event}');
      print('User: ${user?.email}');
      print('Email confirmed: ${user?.emailConfirmedAt}');
      print('Session exists: ${data.session != null}');
      print('==========================================');

      // If user's email gets confirmed, clear pending state
      if (user != null && user.emailConfirmedAt != null) {
        print('Email confirmed! Clearing pending state...');
        ref.read(pendingEmailConfirmationProvider.notifier).state = null;
        // GoRouter should automatically redirect based on redirect logic
      }
    });
  }

  @override
  void dispose() {
    _authSubscription.cancel();
    super.dispose();
  }

  Future<void> _resendConfirmation() async {
    final pendingEmail = ref.read(pendingEmailConfirmationProvider);
    if (pendingEmail == null) return;

    try {
      await Supabase.instance.client.auth.resend(
        type: OtpType.signup,
        email: pendingEmail,
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Confirmation email resent!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final pendingEmail = ref.watch(pendingEmailConfirmationProvider);
    final user = ref.watch(authRepositoryProvider).currentUser;
    
    // Get the email to display
    final emailToShow = pendingEmail ?? user?.email ?? 'your email';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirm Email'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Clear pending confirmation and go back to login
            ref.read(pendingEmailConfirmationProvider.notifier).state = null;
            context.go('/login');
          },
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.email, size: 80.w, color: Colors.blue),
            SizedBox(height: 24.h),
            Text(
              'Check Your Email',
              style: GoogleFonts.poppins(
                fontSize: 24.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              'We\'ve sent a confirmation link to:',
              style: GoogleFonts.poppins(fontSize: 16.sp),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8.h),
            Text(
              emailToShow,
              style: GoogleFonts.poppins(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: Colors.blue,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            Text(
              'Click the link in the email to confirm your account and continue.',
              style: GoogleFonts.poppins(fontSize: 14.sp),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 32.h),
            
            // Resend button
            ElevatedButton.icon(
              onPressed: _resendConfirmation,
              icon: const Icon(Icons.refresh),
              label: const Text('Resend Email'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),
            
            SizedBox(height: 16.h),
            // Add this button below your "Resend Email" button
            ElevatedButton(
              onPressed: () {
                // Clear pending state and let user proceed to login
                ref.read(pendingEmailConfirmationProvider.notifier).state = null;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please sign in with your confirmed email')),
                );
                context.go('/login');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child: const Text('I confirmed my email - Continue to Login'),
            ),
            
            // Back to login button
            // TextButton(
            //   onPressed: () {
            //     ref.read(pendingEmailConfirmationProvider.notifier).state = null;
            //     context.go('/login');
            //   },
            //   child: const Text('Back to Login'),
            // ),
            
            SizedBox(height: 32.h),
            
            // Debug info (remove in production)
            // Container(
            //   padding: const EdgeInsets.all(12),
            //   decoration: BoxDecoration(
            //     color: Colors.grey[100],
            //     borderRadius: BorderRadius.circular(8),
            //   ),
            //   child: Column(
            //     children: [
            //       Text('Debug Info:', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
            //       Text('Pending Email: $pendingEmail'),
            //       Text('Current User: ${user?.email ?? 'null'}'),
            //       Text('Email Confirmed: ${user?.emailConfirmedAt?.toString() ?? 'null'}'),
            //     ],
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}