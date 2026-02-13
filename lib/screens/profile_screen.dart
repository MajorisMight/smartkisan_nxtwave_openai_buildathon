import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

import '../constants/app_colors.dart';
import '../services/demo_data_service.dart';
import '../services/session_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _selectedIndex = 4;
  int _selectedTab = 0; // 0: Profile, 1: Farm Details, 2: Settings

  @override
  Widget build(BuildContext context) {
    final farmer = DemoDataService.getDemoFarmer();
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(farmer),
              _buildTabBar(),
              Expanded(child: _buildTabContent(farmer)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(farmer) {
    return Container(
      padding: EdgeInsets.all(20.w),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Profile',
                style: GoogleFonts.poppins(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Row(
                children: [
                  Container(
                    width: 40.w,
                    height: 40.w,
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.edit,
                      color: AppColors.white,
                      size: 20.sp,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Container(
                    width: 40.w,
                    height: 40.w,
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.settings,
                      color: AppColors.white,
                      size: 20.sp,
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          SizedBox(height: 20.h),
          
          // Profile Card
          Container(
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
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 50.r,
                      backgroundImage: AssetImage('assets/images/farmer.jpg'),
                    ),
                    if (farmer.isVerified)
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
                  farmer.name,
                  style: GoogleFonts.poppins(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                
                Text(
                  farmer.farmName,
                  style: GoogleFonts.poppins(
                    fontSize: 16.sp,
                    color: AppColors.textSecondary,
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
                    Text(
                      farmer.farmLocation,
                      style: GoogleFonts.poppins(
                        fontSize: 14.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                
                SizedBox(height: 16.h),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatItem('Rating', '${farmer.rating}', FontAwesomeIcons.star),
                    _buildStatItem('Experience', farmer.experience, FontAwesomeIcons.clock),
                    _buildStatItem('Farm Size', '${farmer.farmSize} acres', FontAwesomeIcons.map),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primaryGreen, size: 20.sp),
        SizedBox(height: 8.h),
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

  Widget _buildTabBar() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w),
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
      child: Row(
        children: [
          Expanded(
            child: _buildTabButton('Profile', 0),
          ),
          Expanded(
            child: _buildTabButton('Farm Details', 1),
          ),
          Expanded(
            child: _buildTabButton('Settings', 2),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(String title, int index) {
    final isSelected = _selectedTab == index;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTab = index;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryGreen : Colors.transparent,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: isSelected ? AppColors.white : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent(farmer) {
    switch (_selectedTab) {
      case 0:
        return _buildProfileTab(farmer);
      case 1:
        return _buildFarmDetailsTab(farmer);
      case 2:
        return _buildSettingsTab();
      default:
        return _buildProfileTab(farmer);
    }
  }

  Widget _buildProfileTab(farmer) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20.w),
      child: Column(
        children: [
          _buildInfoCard(
            'Personal Information',
            [
              _buildInfoRow('Email', farmer.email),
              _buildInfoRow('Phone', farmer.phone),
              _buildInfoRow('Experience', farmer.experience),
              _buildInfoRow('Language', farmer.preferredLanguage),
            ],
          ),
          
          SizedBox(height: 16.h),
          
          _buildInfoCard(
            'Bio',
            [
              Padding(
                padding: EdgeInsets.all(16.w),
                child: Text(
                  farmer.bio,
                  style: GoogleFonts.poppins(
                    fontSize: 14.sp,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          
          SizedBox(height: 16.h),
          
          _buildInfoCard(
            'Certifications',
            farmer.certifications.map<Widget>((cert) => Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              child: Row(
                children: [
                  Icon(
                    Icons.verified,
                    color: AppColors.primaryGreen,
                    size: 16.sp,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    cert,
                    style: GoogleFonts.poppins(
                      fontSize: 14.sp,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            )).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFarmDetailsTab(farmer) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20.w),
      child: Column(
        children: [
          _buildInfoCard(
            'Farm Information',
            [
              _buildInfoRow('Farm Name', farmer.farmName),
              _buildInfoRow('Location', farmer.farmLocation),
              _buildInfoRow('Size', '${farmer.farmSize} acres'),
              _buildInfoRow('Join Date', _formatDate(farmer.joinDate)),
            ],
          ),
          
          SizedBox(height: 16.h),
          
          _buildInfoCard(
            'Crops Grown',
            farmer.crops.map<Widget>((crop) => Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              child: Row(
                children: [
                  Icon(
                    FontAwesomeIcons.seedling,
                    color: AppColors.success,
                    size: 16.sp,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    crop,
                    style: GoogleFonts.poppins(
                      fontSize: 14.sp,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            )).toList(),
          ),
          
          SizedBox(height: 16.h),
          
          _buildInfoCard(
            'Farm Statistics',
            [
              _buildStatRow('Total Sales', '₹45,230', AppColors.success),
              _buildStatRow('Active Orders', '12', AppColors.info),
              _buildStatRow('Products Listed', '8', AppColors.warning),
              _buildStatRow('Customer Rating', '${farmer.rating}/5.0', AppColors.primaryGreen),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20.w),
      child: Column(
        children: [
          _buildSettingsCard(
            'Account',
            [
              _buildSettingsItem(
                'Edit Profile',
                Icons.person_outline,
                () {},
              ),
              _buildSettingsItem(
                'Change Password',
                Icons.lock_outline,
                () {},
              ),
              _buildSettingsItem(
                'Privacy Settings',
                Icons.privacy_tip_outlined,
                () {},
              ),
            ],
          ),
          
          SizedBox(height: 16.h),
          
          _buildSettingsCard(
            'Notifications',
            [
              _buildSettingsItem(
                'Push Notifications',
                Icons.notifications_outlined,
                () {},
                trailing: Switch(
                  value: true,
                  onChanged: (value) {},
                  activeThumbColor: AppColors.primaryGreen,
                ),
              ),
              _buildSettingsItem(
                'Email Notifications',
                Icons.email_outlined,
                () {},
                trailing: Switch(
                  value: true,
                  onChanged: (value) {},
                  activeThumbColor: AppColors.primaryGreen,
                ),
              ),
            ],
          ),
          
          SizedBox(height: 16.h),
          
          _buildSettingsCard(
            'Support',
            [
              _buildSettingsItem(
                'Help Center',
                Icons.help_outline,
                () {},
              ),
              _buildSettingsItem(
                'Contact Support',
                Icons.support_agent,
                () {},
              ),
              _buildSettingsItem(
                'About App',
                Icons.info_outline,
                () {},
              ),
            ],
          ),
          
          SizedBox(height: 16.h),
          
          _buildSettingsCard(
            'Account Actions',
            [
              _buildSettingsItem(
                'Logout',
                Icons.logout,
                () {
                  _showLogoutDialog();
                },
                textColor: AppColors.error,
              ),
              _buildSettingsItem(
                'Delete Account',
                Icons.delete_outline,
                () {
                  _showDeleteAccountDialog();
                },
                textColor: AppColors.error,
              ),
            ],
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
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value, Color color) {
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
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsCard(String title, List<Widget> children) {
    return Container(
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

  Widget _buildSettingsItem(String title, IconData icon, VoidCallback onTap, {Widget? trailing, Color? textColor}) {
    return ListTile(
      leading: Icon(icon, color: textColor ?? AppColors.textSecondary),
      title: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 14.sp,
          color: textColor ?? AppColors.textPrimary,
        ),
      ),
      trailing: trailing ?? Icon(Icons.arrow_forward_ios, size: 16.sp, color: AppColors.textSecondary),
      onTap: onTap,
    );
  }

  Widget _buildBottomNavigationBar() {
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
      child: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
          switch (index) {
            case 0:
              context.go('/home');
              break;
            case 1:
              context.go('/marketplace');
              break;
            case 2:
              context.go('/weather');
              break;
            case 3:
              context.go('/community');
              break;
            case 4:
              context.go('/profile');
              break;
          }
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.white,
        selectedItemColor: AppColors.primaryGreen,
        unselectedItemColor: AppColors.textSecondary,
        selectedLabelStyle: GoogleFonts.poppins(fontSize: 12.sp),
        unselectedLabelStyle: GoogleFonts.poppins(fontSize: 12.sp),
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.store_outlined),
            activeIcon: Icon(Icons.store),
            label: 'Marketplace',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.wb_sunny_outlined),
            activeIcon: Icon(Icons.wb_sunny),
            label: 'Weather',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_outline),
            activeIcon: Icon(Icons.people),
            label: 'Community',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Logout'),
        content: Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await SessionService.setLoggedIn(false);
              if (!mounted) return;
              context.go('/otp');
            },
            child: Text('Logout'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Account'),
        content: Text('Are you sure you want to delete your account? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Delete account logic
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
