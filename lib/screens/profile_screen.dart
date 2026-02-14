import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../constants/app_colors.dart';
import '../l10n/app_localizations.dart';
import '../main.dart';
import '../providers/profile_provider.dart';
import '../services/session_service.dart';
import '../app_extensions.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  Future<void> _logout() async {
    await Supabase.instance.client.auth.signOut();
    if (!mounted) return;
    context.go('/login');
  }

  Future<void> _handleSettingsAction(String action) async {
    final currentEmail = ref.read(farmerBasicProfileProvider).valueOrNull?.email ?? '';
    switch (action) {
      case 'change_password':
        await _showChangePasswordSheet();
        break;
      case 'forgot_password':
        await _sendResetPassword(currentEmail);
        break;
      case 'logout':
        await _logout();
        break;
      case 'delete':
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Delete account will be available soon.')),
        );
        break;
    }
  }

  Future<void> _setAppLanguage(String languageCode) async {
    await SessionService.saveLanguagePreference(languageCode);
    if (!mounted) return;
    FarmerEcosystemApp.setLocale(context, Locale(languageCode));
  }

  @override
  Widget build(BuildContext context) {
    
    final profileAsync = ref.watch(farmerBasicProfileProvider);
    final uploadState = ref.watch(profilePhotoUploadProvider);
    final profileUpdateState = ref.watch(profileUpdateProvider);
    final isUploading = uploadState.isLoading;
    final isUpdatingProfile = profileUpdateState.isLoading;

    ref.listen<AsyncValue<void>>(profilePhotoUploadProvider, (previous, next) {
      if (!mounted) return;
      next.whenOrNull(
        error: (error, _) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error.toString().replaceFirst('Exception: ', ''))),
          );
        },
      );
    });
    ref.listen<AsyncValue<void>>(profileUpdateProvider, (previous, next) {
      if (!mounted) return;
      if (previous?.isLoading == true && next.hasValue) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
      }
      next.whenOrNull(
        error: (error, _) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error.toString().replaceFirst('Exception: ', ''))),
          );
        },
      );
    });

    return Container(
      decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
      child: SafeArea(
        child: profileAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => _buildErrorState(ref, error),
          data: (profile) => Column(
            children: [
              _buildHeader(profile, isUploading, isUpdatingProfile),
              Expanded(child: _buildProfileContent(profile, isUpdatingProfile)),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showAvatarOptions() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: Text(context.l10n.imgPickCamera),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: Text(context.l10n.imgPickGallery),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
            ],
          ),
        );
      },
    );

    if (source == null) return;

    try {
      final uploadedUrl =
          await ref.read(profilePhotoUploadProvider.notifier).pickAndUpload(source);
      if (!mounted) return;
      if (uploadedUrl != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.imgPreviewUnavailable)),
        );
      }
    } catch (_) {
      // Error feedback is shown from ref.listen.
    }
  }

  Widget _buildErrorState(WidgetRef ref, Object error) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              context.l10n.lblLoading,
              style: GoogleFonts.poppins(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.error,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              error.toString(),
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 13.sp,
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: 12.h),
            ElevatedButton(
              onPressed: () => ref.invalidate(farmerBasicProfileProvider),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                foregroundColor: AppColors.white,
              ),
              child: Text(context.l10n.btnRetry),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showEditProfileSheet(FarmerBasicProfile profile) async {
    final nameController = TextEditingController(text: profile.name);
    final villageController = TextEditingController(text: profile.village);
    final districtController = TextEditingController(text: profile.district);
    final stateController = TextEditingController(text: profile.state);
    final formKey = GlobalKey<FormState>();

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20.w,
            right: 20.w,
            top: 16.h,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20.h,
          ),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.profileTitle,
                  style: GoogleFonts.poppins(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 14.h),
                _buildEditField(nameController, context.l10n.profileLabelName),
                SizedBox(height: 10.h),
                _buildEditField(villageController, context.l10n.profileLabelVillage),
                SizedBox(height: 10.h),
                _buildEditField(districtController, context.l10n.profileLabelDistrict),
                SizedBox(height: 10.h),
                _buildEditField(stateController, context.l10n.profileLabelState),
                SizedBox(height: 16.h),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (!(formKey.currentState?.validate() ?? false)) return;
                      try {
                        await ref.read(profileUpdateProvider.notifier).updateBasicInfo(
                              name: nameController.text,
                              village: villageController.text,
                              district: districtController.text,
                              farmState: stateController.text,
                            );
                        if (!mounted) return;
                        Navigator.of(context).pop();
                      } catch (_) {}
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                      foregroundColor: AppColors.white,
                    ),
                    child: Text(context.l10n.btnSave),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEditField(
    TextEditingController controller,
    String label, {
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: (value) {
        final text = value?.trim() ?? '';
        if (text.isEmpty) return '$label is required';
        if (label == 'Email' && !text.contains('@')) return 'Enter a valid email';
        return null;
      },
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r)),
      ),
    );
  }

  Future<void> _showChangePasswordSheet() async {
    final currentController = TextEditingController();
    final passController = TextEditingController();
    final confirmController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20.w,
            right: 20.w,
            top: 16.h,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20.h,
          ),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.settingsChangePass,
                  style: GoogleFonts.poppins(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 14.h),
                TextFormField(
                  controller: currentController,
                  obscureText: true,
                  validator: (value) {
                    if ((value ?? '').trim().isEmpty) {
                      return context.l10n.formCurrentPass;
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: context.l10n.formCurrentPass,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r)),
                  ),
                ),
                SizedBox(height: 10.h),
                TextFormField(
                  controller: passController,
                  obscureText: true,
                  validator: (value) {
                    if ((value ?? '').trim().length < 6) {
                      return context.l10n.formErrorPassLength;

                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: context.l10n.formNewPass,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r)),
                  ),
                ),
                SizedBox(height: 10.h),
                TextFormField(
                  controller: confirmController,
                  obscureText: true,
                  validator: (value) {
                    if ((value ?? '') != passController.text) {
                      return context.l10n.formErrorPassMatch;
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: context.l10n.formConfirmPass,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r)),
                  ),
                ),
                SizedBox(height: 16.h),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (!(formKey.currentState?.validate() ?? false)) return;
                      try {
                        await ref
                            .read(profileUpdateProvider.notifier)
                            .changePassword(
                              currentPassword: currentController.text.trim(),
                              newPassword: passController.text.trim(),
                            );
                        if (!mounted) return;
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(context.l10n.formMsgPassSuccess)),
                        );
                      } catch (e) {
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              e.toString().replaceFirst('Exception: ', ''),
                            ),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                      foregroundColor: AppColors.white,
                    ),
                    child: Text(context.l10n.formBtnUpdatePass),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _sendResetPassword(String email) async {
    if (email.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.profileErrorLoad)),
      );
      return;
    }
    try {
      await ref.read(profileUpdateProvider.notifier).sendPasswordReset(email);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.formMsgPassResetSent)),
      );
    } catch (_) {}
  }

  Widget _buildHeader(
    FarmerBasicProfile profile,
    bool isUploading,
    bool isUpdatingProfile,
  ) {
    return Container(
      padding: EdgeInsets.all(20.w),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                context.l10n.profileTitle,
                style: GoogleFonts.poppins(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Row(
                children: [
                  GestureDetector(
                    onTap: isUpdatingProfile ? null : () => _showEditProfileSheet(profile),
                    child: _iconCircle(Icons.edit),
                  ),
                  SizedBox(width: 12.w),
                  _buildSettingsMenuButton(),
                ],
              ),
            ],
          ),
          SizedBox(height: 20.h),
          Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: const [
                BoxShadow(
                  color: AppColors.shadowLight,
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                Stack(
                  children: [
                    _buildAvatar(
                      photoUrl: profile.photoUrl,
                      isUploading: isUploading,
                      onTap: isUploading ? null : _showAvatarOptions,
                    ),
                    if ((profile.photoUrl ?? '').trim().isNotEmpty)
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 24.w,
                          height: 24.w,
                          decoration: BoxDecoration(
                            color: AppColors.primaryGreen,
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.white, width: 2),
                          ),
                          child: Icon(
                            Icons.verified,
                            color: AppColors.white,
                            size: 14.sp,
                          ),
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 16.h),
                Text(
                  profile.name.isEmpty ? 'Farmer' : profile.name,
                  style: GoogleFonts.poppins(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 8.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.location_on,
                      color: AppColors.textSecondary,
                      size: 16.sp,
                    ),
                    SizedBox(width: 4.w),
                    Flexible(
                      child: Text(
                        profile.location,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 14.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatItem(
                      context.l10n.profileLabelDistrict,
                      profile.district.isEmpty ? '-' : profile.district,
                      FontAwesomeIcons.mapLocationDot,
                    ),
                    _buildStatItem(
                      context.l10n.profileLabelState,
                      profile.state.isEmpty ? '-' : profile.state,
                      FontAwesomeIcons.locationDot,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _iconCircle(IconData icon) {
    return Container(
      width: 40.w,
      height: 40.w,
      decoration: const BoxDecoration(
        color: AppColors.primaryGreen,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: AppColors.white, size: 20.sp),
    );
  }

  Widget _buildSettingsMenuButton() {
    return PopupMenuButton<String>(
      onSelected: _handleSettingsAction,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
      elevation: 8,
      itemBuilder: (context) => [
        PopupMenuItem<String>(
          value: 'change_password',
          child: _buildSettingsItem(
            icon: Icons.lock_reset,
            title: context.l10n.settingsChangePass,
            subtitle: context.l10n.settingsChangePassDesc,
            color: AppColors.primaryGreen,
          ),
        ),
        PopupMenuItem<String>(
          value: 'forgot_password',
          child: _buildSettingsItem(
            icon: Icons.mail_outline,
            title: context.l10n.settingsForgotPass,
            subtitle: context.l10n.settingsForgotPassDesc,
            color: AppColors.info,
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem<String>(
          value: 'logout',
          child: _buildSettingsItem(
            icon: Icons.logout,
            title: context.l10n.settingsLogout,
            subtitle: context.l10n.settingsLogoutDesc,
            color: AppColors.error,
          ),
        ),
        PopupMenuItem<String>(
          value: 'delete',
          enabled: false,
          child: _buildSettingsItem(
            icon: Icons.delete_outline,
            title: context.l10n.settingsDelete,
            subtitle: context.l10n.settingsDelete,
            color: AppColors.error,
          ),
        ),
      ],
      child: _iconCircle(Icons.settings),
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          width: 34.w,
          height: 34.w,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(icon, color: color, size: 18.sp),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                subtitle,
                style: GoogleFonts.poppins(
                  fontSize: 11.sp,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primaryGreen, size: 18.sp),
        SizedBox(height: 8.h),
        SizedBox(
          width: 120.w,
          child: Text(
            value,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
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

  Widget _buildProfileContent(FarmerBasicProfile profile, bool isUpdatingProfile) {
    final l10n = AppLocalizations.of(context)!;
    final activeCode = Localizations.localeOf(context).languageCode;
    return SingleChildScrollView(
      padding: EdgeInsets.all(20.w),
      child: Column(
        children: [
          _buildInfoCard(
            l10n.languageTooltip,
            [
              Padding(
                padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 14.h),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildLanguageButton(
                        label: l10n.languageEnglish,
                        selected: activeCode == 'en',
                        onTap: () => _setAppLanguage('en'),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: _buildLanguageButton(
                        label: l10n.languageHindi,
                        selected: activeCode == 'hi',
                        onTap: () => _setAppLanguage('hi'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          _buildInfoCard(
            context.l10n.profileTabPersonal,
            [
              _buildInfoRow(
                context.l10n.profileLabelName,
                profile.name.isEmpty ? 'Not provided' : profile.name,
              ),
              _buildInfoRow(
                context.l10n.profileLabelVillage,
                profile.village.isEmpty ? 'Not provided' : profile.village,
              ),
              _buildInfoRow(
                context.l10n.profileLabelDistrict,
                profile.district.isEmpty ? 'Not provided' : profile.district,
              ),
              _buildInfoRow(context.l10n.profileLabelState, profile.state.isEmpty ? 'Not provided' : profile.state),
              _buildInfoRow(context.l10n.profileLabelEmail, profile.email.isEmpty ? 'Not provided' : profile.email),
              _buildInfoRow(context.l10n.profileLabelLanguage, profile.languagePreference),
            ],
          ),
          SizedBox(height: 16.h),
          // _buildInfoCard(
          //   'Address',
          //   [
          //     Padding(
          //       padding: EdgeInsets.all(16.w),
          //       child: Text(
          //         profile.location,
          //         style: GoogleFonts.poppins(
          //           fontSize: 14.sp,
          //           color: AppColors.textPrimary,
          //         ),
          //       ),
          //     ),
          //   ],
          // ),
        ],
      ),
    );
  }

  Widget _buildLanguageButton({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10.r),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 12.w),
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryGreen : AppColors.white,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(
            color: selected ? AppColors.primaryGreen : AppColors.borderLight,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              selected ? Icons.check_circle : Icons.circle_outlined,
              size: 16.sp,
              color: selected ? AppColors.white : AppColors.textSecondary,
            ),
            SizedBox(width: 8.w),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: selected ? AppColors.white : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar({
    required String? photoUrl,
    required bool isUploading,
    required VoidCallback? onTap,
  }) {
    final validPhotoUrl =
        (photoUrl != null && photoUrl.trim().isNotEmpty) ? photoUrl : null;
    final showCameraBadge = validPhotoUrl == null || isUploading;
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          Container(
            width: 100.w,
            height: 100.w,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.greyLight,
            ),
            clipBehavior: Clip.antiAlias,
            child: validPhotoUrl != null
                ? Image.network(
                    validPhotoUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Icon(
                      Icons.person,
                      size: 48.sp,
                      color: AppColors.textSecondary,
                    ),
                  )
                : Icon(
                    Icons.person,
                    size: 48.sp,
                    color: AppColors.textSecondary,
                  ),
          ),
          if (showCameraBadge)
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: 30.w,
                height: 30.w,
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.white, width: 2),
                ),
                child: isUploading
                    ? Padding(
                        padding: EdgeInsets.all(7.w),
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.white,
                        ),
                      )
                    : Icon(
                        Icons.camera_alt,
                        size: 14.sp,
                        color: AppColors.white,
                      ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: const [
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
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 14.sp,
              color: AppColors.textSecondary,
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: GoogleFonts.poppins(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
