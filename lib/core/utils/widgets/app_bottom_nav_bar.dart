import 'dart:ui';

import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_sizes.dart';
import 'animations/app_motion.dart';

class AppNavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const AppNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}

class AppBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final void Function(int) onTap;
  final List<AppNavItem> items;
  final Color? activeColor;

  const AppBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
    this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = activeColor ?? AppColors.primary[60]!;

    return SafeArea(
      top: false,
      minimum: EdgeInsets.fromLTRB(16.w, 0, 16.w, 12.h),
      child: ClipRRect(
        borderRadius: BorderRadius.all(AppRadius.xl),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: (isDark ? AppColors.darkSurface : Colors.white).withOpacity(isDark ? 0.88 : 0.92),
              borderRadius: BorderRadius.all(AppRadius.xl),
              border: Border.all(color: color.withOpacity(0.1)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.28 : 0.1),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              children: List.generate(items.length, (i) {
                final isActive = i == currentIndex;
                return Expanded(
                  child: _NavItem(
                    item: items[i],
                    isActive: isActive,
                    onTap: () => onTap(i),
                    activeColor: color,
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
  final AppNavItem item;
  final bool isActive;
  final VoidCallback onTap;
  final Color activeColor;

  const _NavItem({
    required this.item,
    required this.isActive,
    required this.onTap,
    required this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final borderRadius = BorderRadius.all(AppRadius.md);

    return AppTapScale(
      onTap: onTap,
      borderRadius: borderRadius,
      pressedScale: 0.985,
      semanticLabel: item.label,
      child: AnimatedContainer(
        duration: AppMotionDurations.medium,
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 6.w),
        decoration: BoxDecoration(
          gradient: isActive
              ? LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    activeColor.withOpacity(0.16),
                    activeColor.withOpacity(0.08),
                  ],
                )
              : null,
          borderRadius: borderRadius,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: AppMotionDurations.medium,
              curve: Curves.easeOutCubic,
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: isActive ? activeColor.withOpacity(0.12) : Colors.transparent,
                borderRadius: BorderRadius.circular(999),
              ),
              child: PageTransitionSwitcher(
                duration: AppMotionDurations.medium,
                reverse: !isActive,
                transitionBuilder: (child, animation, secondaryAnimation) {
                  return SharedAxisTransition(
                    animation: animation,
                    secondaryAnimation: secondaryAnimation,
                    transitionType: SharedAxisTransitionType.scaled,
                    fillColor: Colors.transparent,
                    child: child,
                  );
                },
                child: Icon(
                  isActive ? item.activeIcon : item.icon,
                  key: ValueKey('${item.label}-$isActive'),
                  size: 22.sp,
                  color: isActive ? activeColor : colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            SizedBox(height: 3.h),
            AnimatedDefaultTextStyle(
              duration: AppMotionDurations.medium,
              curve: Curves.easeOutCubic,
              style: (textTheme.labelSmall ?? const TextStyle()).copyWith(
                color: isActive ? activeColor : colorScheme.onSurfaceVariant,
                fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
              ),
              child: Text(
                item.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
