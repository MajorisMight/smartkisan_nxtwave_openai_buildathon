import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kisan/providers/auth_provider.dart';
import 'package:kisan/providers/auth_repository.dart'; // Assuming you have this from previous setup
import '../constants/app_colors.dart';


class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  // The UI now starts in "Log In" mode by default.
  bool _isSignUp = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) return;

    final notifier = ref.read(authProvider.notifier);
    if (_isSignUp) {
      await notifier.signUp(email, password, context);

      // **CHANGE**: After sign up, switch UI to login mode.
      // The banner will appear automatically via the state provider.
      if (mounted) {
        setState(() {
          _isSignUp = false;
        });
      }
    } else {
      await notifier.signIn(email, password);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(authProvider, (_, state) {
      if (state.hasError && !state.isLoading) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(state.error.toString())),
        );
      }
    });

    final authState = ref.watch(authProvider);
    // **CHANGE**: Watch the provider to decide if the banner should be shown.
    final pendingEmail = ref.watch(pendingEmailConfirmationProvider);
    final currentUser = ref.watch(authRepositoryProvider).currentUser;

    // The banner is shown if our provider has a pending email,
    // or if there's a logged-in user whose email is not confirmed.
    final hasUnconfirmedEmail =
        currentUser != null && currentUser.emailConfirmedAt == null;
    final showEmailPending = pendingEmail != null || hasUnconfirmedEmail;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(24.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 40.h),
                _buildHeader(),

                // **CHANGE**: Added the confirmation banner here.
                if (showEmailPending) ...[
                  SizedBox(height: 24.h),
                  Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: Colors.orange[100],
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(color: Colors.orange[300]!),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Icon(Icons.email,
                                color: Colors.orange[800], size: 20.w),
                            SizedBox(width: 12.w),
                            Text(
                              'Confirm Your Email',
                              style: GoogleFonts.poppins(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange[800],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          'A confirmation link has been sent to ${pendingEmail ?? currentUser?.email}. Please click the link to verify your account, then log in to continue.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                              fontSize: 13.sp, color: Colors.orange[700]),
                        ),
                      ],
                    ),
                  ),
                ],

                SizedBox(height: 32.h),
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                      labelText: 'Email',
                      prefixIcon:
                          Icon(Icons.email, color: AppColors.primaryGreen),
                      hintStyle: GoogleFonts.poppins(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary)),
                ),
                SizedBox(height: 16.h),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon:
                          Icon(Icons.lock, color: AppColors.primaryGreen),
                      hintStyle: GoogleFonts.poppins(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary)),
                ),
                SizedBox(height: 24.h),
                SizedBox(
                  height: 52.h,
                  child: ElevatedButton(
                    onPressed: authState.isLoading ? null : _submit,
                    child: authState.isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(_isSignUp ? 'Sign Up' : 'Log In',
                            style: GoogleFonts.poppins(fontSize: 16.sp)),
                  ),
                ),
                SizedBox(height: 12.h),
                TextButton(
                  onPressed: () => setState(() => _isSignUp = !_isSignUp),
                  child: Text(_isSignUp
                      ? 'Already have an account? Log In'
                      : 'Don\'t have an account? Sign Up'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Icon(Icons.person, size: 80.w, color: AppColors.primaryGreen),
        SizedBox(height: 16.h),
        Text(_isSignUp ? 'Create Account' : 'Welcome Back',
            style: GoogleFonts.poppins(
                fontSize: 24.sp, fontWeight: FontWeight.w700)),
        SizedBox(height: 6.h),
        Text(_isSignUp ? 'Join the community' : 'Log in to continue',
            style: GoogleFonts.poppins(
                fontSize: 14.sp, color: AppColors.textSecondary)),
      ],
    );
  }
}