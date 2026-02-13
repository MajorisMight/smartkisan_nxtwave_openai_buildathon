import 'package:flutter/material.dart';
// ...existing code...
import '../constants/app_colors.dart';

class CustomTabBarView extends StatelessWidget {
  final List<Widget> children;
  final int currentIndex;
  final PageController? controller;

  const CustomTabBarView({
    super.key,
    required this.children,
    required this.currentIndex,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.white,
      child: PageView(
        controller: controller,
        children: children,
      ),
    );
  }
}