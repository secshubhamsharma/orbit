import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';

class OrbitBottomNav extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const OrbitBottomNav({super.key, required this.navigationShell});

  static const _tabs = [
    _TabItem(icon: Icons.home_rounded, label: 'Home'),
    _TabItem(icon: Icons.menu_book_rounded, label: 'Library'),
    _TabItem(icon: Icons.search_rounded, label: 'Search'),
    _TabItem(icon: Icons.bar_chart_rounded, label: 'Progress'),
    _TabItem(icon: Icons.person_rounded, label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final current = navigationShell.currentIndex;

    return Scaffold(
      backgroundColor: AppColors.kBackground,
      body: navigationShell,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.kSurface : AppColors.kSurfaceLight,
          border: Border(
            top: BorderSide(
              color: isDark ? AppColors.kBorder : AppColors.kBorderLight,
              width: 1,
            ),
          ),
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 60,
            child: Row(
              children: List.generate(_tabs.length, (i) {
                final tab = _tabs[i];
                final isActive = current == i;
                return Expanded(
                  child: _NavItem(
                    icon: tab.icon,
                    label: tab.label,
                    isActive: isActive,
                    onTap: () => navigationShell.goBranch(
                      i,
                      initialLocation: i == current,
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = isActive
        ? AppColors.kPrimary
        : (isDark ? AppColors.kTextDisabled : AppColors.kTextDisabledLight);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: isActive
                  ? BoxDecoration(
                      color: AppColors.kPrimary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    )
                  : null,
              child: Icon(icon, size: 22, color: color),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: AppTextStyles.labelSmall.copyWith(
                color: color,
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TabItem {
  final IconData icon;
  final String label;
  const _TabItem({required this.icon, required this.label});
}
