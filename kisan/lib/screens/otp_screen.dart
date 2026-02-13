import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:kisan/l10n/app_localizations.dart';
import '../constants/app_colors.dart';
import '../services/session_service.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  bool _otpSent = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    if (_phoneController.text.length < 10) return;
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _otpSent = true;
      _isLoading = false;
    });
  }

  Future<void> _verifyOtp() async {
    if (_otpController.text.length < 4) return;
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 800));
    await SessionService.setLoggedIn(true);
    setState(() => _isLoading = false);
    if (!mounted) return;
    final onboarded = await SessionService.isOnboardingComplete();
    if (onboarded) {
      context.go('/home');
    } else {
      context.go('/onboarding');
    }
  }

  @override
  Widget build(BuildContext context) {

    final l10n  = AppLocalizations.of(context)!;

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
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 80.w,
                        height: 80.w,
                        decoration: BoxDecoration(
                          color: AppColors.primaryGreen,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.shadowLight,
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Icon(Icons.phone_iphone, color: AppColors.white, size: 40.sp),
                      ),
                      SizedBox(height: 16.h),
                      Text(l10n.phoneNo, style: GoogleFonts.poppins(fontSize: 24.sp, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                      SizedBox(height: 6.h),
                      Text(l10n.verStatement, style: GoogleFonts.poppins(fontSize: 14.sp, color: AppColors.textSecondary)),
                    ],
                  ),
                ),
                SizedBox(height: 32.h),
                TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: l10n.phoneNo,
                    hintText: '+91 9876543210',
                    prefixIcon: Icon(Icons.phone, color: AppColors.primaryGreen),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                    filled: true,
                    fillColor: AppColors.white,
                  ),
                ),
                SizedBox(height: 16.h),
                if (_otpSent)
                  TextField(
                    controller: _otpController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'OTP',
                      hintText: '1234',
                      prefixIcon: Icon(Icons.lock, color: AppColors.primaryGreen),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                      filled: true,
                      fillColor: AppColors.white,
                    ),
                  ),
                SizedBox(height: 24.h),
                SizedBox(
                  height: 52.h,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : (_otpSent ? _verifyOtp : _sendOtp),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                      foregroundColor: AppColors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                    ),
                    child: _isLoading
                        ? SizedBox(width: 20.w, height: 20.w, child: const CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : Text(_otpSent ? l10n.verifyBtn : l10n.sendbtn, style: GoogleFonts.poppins(fontSize: 16.sp, fontWeight: FontWeight.w600)),
                  ),
                ),
                if (_otpSent) ...[
                  SizedBox(height: 12.h),
                  TextButton(
                    onPressed: _isLoading ? null : _sendOtp,
                    child: Text(l10n.resendBtn, style: GoogleFonts.poppins(color: AppColors.primaryGreen, fontWeight: FontWeight.w600)),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}


