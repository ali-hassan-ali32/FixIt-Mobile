import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/app_colors.dart';

// ══════════════════════════════════════════════════════════════
// AppEmptyState
// Generic empty/no-results state used across all list screens.
//
// Usage:
//   AppEmptyState(
//     icon: Icons.search_off_rounded,
//     title: 'لا توجد نتائج',
//     subtitle: 'جرب كلمات بحث أخرى',
//   )
//   AppEmptyState(
//     icon: Icons.notifications_off_outlined,
//     title: 'لا توجد إشعارات',
//     subtitle: 'ستظهر إشعاراتك هنا',
//     actionLabel: 'تصفح الخدمات',
//     onAction: () {},
//     color: AppColors.accent[60], // teal for handyman
//   )
// ══════════════════════════════════════════════════════════════
class AppEmptyState extends StatelessWidget {
  final IconData      icon;
  final String        title;
  final String        subtitle;
  final String?       actionLabel;
  final VoidCallback? onAction;
  /// Pass AppColors.accent[60] for handyman (teal).
  /// Defaults to AppColors.primary[60] (customer orange).
  final Color?        color;

  const AppEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onAction,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme   = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final resolvedColor = color ?? AppColors.primary[60]!;

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 60.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon bubble
            Container(
              width: 88.w,
              height: 88.h,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    resolvedColor.withOpacity(0.10),
                    resolvedColor.withOpacity(0.06),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 38.sp,
                color: resolvedColor,
              ),
            ),
            SizedBox(height: 20.h),

            Text(
              title,
              style: textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w800),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8.h),

            Text(
              subtitle,
              style: textTheme.bodyMedium
                  ?.copyWith(color: colorScheme.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),

            if (actionLabel != null && onAction != null) ...[
              SizedBox(height: 24.h),
              TextButton(
                onPressed: onAction,
                style: TextButton.styleFrom(
                  foregroundColor: resolvedColor,
                  padding: EdgeInsets.symmetric(
                      horizontal: 24.w, vertical: 12.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    side: BorderSide(
                        color: resolvedColor.withOpacity(0.4)),
                  ),
                ),
                child: Text(
                  actionLabel!,
                  style: GoogleFonts.cairo(
                      fontSize: 14.sp, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}