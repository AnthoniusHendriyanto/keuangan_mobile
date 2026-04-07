import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';
import 'dashboard_screen.dart';
import 'receipts_screen.dart';
import 'statistics_screen.dart';
import 'profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  static const List<Widget> _screens = [
    DashboardScreen(),
    ReceiptsScreen(),
    StatisticsScreen(),
    ProfileScreen(),
  ];

  static const _navItems = [
    _NavItem(icon: Icons.dashboard_rounded, label: 'Dashboard'),
    _NavItem(icon: Icons.receipt_long_rounded, label: 'Billing'),
    _NavItem(icon: Icons.bar_chart_rounded, label: 'Insights'),
    _NavItem(icon: Icons.person_rounded, label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Screens  
          IndexedStack(
            index: _currentIndex,
            children: _screens,
          ),

          // Glassmorphic Bottom Nav Bar
          Positioned(
            bottom: 24,
            left: 20,
            right: 20,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                child: Container(
                  height: 72,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerHighest.withOpacity(0.85),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: AppColors.outlineVariant.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(_navItems.length, (i) {
                      return _NavButton(
                        item: _navItems[i],
                        isActive: _currentIndex == i,
                        onTap: () => setState(() => _currentIndex = i),
                      );
                    }),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem({required this.icon, required this.label});
}

class _NavButton extends StatelessWidget {
  final _NavItem item;
  final bool isActive;
  final VoidCallback onTap;
  const _NavButton({required this.item, required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary.withOpacity(0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(100),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              item.icon,
              color: isActive ? AppColors.primary : AppColors.onSurfaceVariant,
              size: 24,
            ),
            const SizedBox(height: 2),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 250),
              style: TextStyle(
                color: isActive ? AppColors.primary : AppColors.onSurfaceVariant,
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
              ),
              child: Text(item.label),
            ),
          ],
        ),
      ),
    );
  }
}
