// ══════════════════════════════════════════════════════════════
// AppCategoryChip
// ══════════════════════════════════════════════════════════════
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_sizes.dart';

class AppCategoryChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  const AppCategoryChip({
    super.key,
    required this.label,
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme   = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final isDark      = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.lg.w, vertical: 12.h),
        decoration: BoxDecoration(
          gradient: isActive
              ? LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primary[60]!, AppColors.secondary[60]!],
          )
              : null,
          color: isActive
              ? null
              : isDark
              ? AppColors.darkSurface
              : Colors.white,
          borderRadius: BorderRadius.all(AppRadius.lg),
          border: Border.all(
            color: isActive
                ? Colors.transparent
                : AppColors.primary[60]!.withOpacity(0.15),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: isActive
                  ? AppColors.primary[60]!.withOpacity(0.25)
                  : Colors.black.withOpacity(0.04),
              blurRadius: isActive ? 12 : 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: 16.sp,
                color:
                isActive ? Colors.white : colorScheme.onSurfaceVariant),
            SizedBox(width: 6.w),
            Text(
              label,
              style: textTheme.bodyMedium?.copyWith(
                color: isActive ? Colors.white : colorScheme.onSurface,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}