import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_sizes.dart';
import '../animations/app_motion.dart';

class AppSectionCard extends StatelessWidget {
  final Widget child;
  final bool isDark;
  final EdgeInsetsGeometry? padding;

  const AppSectionCard({
    super.key,
    required this.child,
    required this.isDark,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: AppMotionDurations.medium,
      curve: Curves.easeOutCubic,
      width: double.infinity,
      padding: padding ?? EdgeInsets.all(AppSpacing.lg.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.primary[60]!.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.18 : 0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

class AppSectionCardTitle extends StatelessWidget {
  final IconData icon;
  final String label;

  const AppSectionCardTitle({
    super.key,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20.sp, color: AppColors.primary[60]),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(
            label,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w800),
          ),
        ),
      ],
    );
  }
}

class AppActionButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback onTap;
  final bool isSecondary;
  final double? height;

  const AppActionButton({
    super.key,
    required this.label,
    required this.onTap,
    this.icon,
    this.isSecondary = false,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(14.r);

    return AppTapScale(
      onTap: onTap,
      borderRadius: borderRadius,
      child: Container(
        height: height ?? 50.h,
        decoration: BoxDecoration(
          gradient: isSecondary
              ? null
              : LinearGradient(colors: [
                  AppColors.primary[60]!,
                  AppColors.secondary[60]!,
                ]),
          color: isSecondary ? AppColors.primary[60]!.withOpacity(0.1) : null,
          borderRadius: borderRadius,
          boxShadow: isSecondary
              ? const []
              : [
                  BoxShadow(
                    color: AppColors.primary[60]!.withOpacity(0.25),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 18.sp,
                color: isSecondary ? AppColors.primary[60] : Colors.white,
              ),
              SizedBox(width: 6.w),
            ],
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.cairo(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: isSecondary ? AppColors.primary[60] : Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
