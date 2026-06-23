import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_sizes.dart';
import 'buttons/app_back_button.dart';

// ══════════════════════════════════════════════════════════════
// AppPageHeader
// Frosted-glass misty top bar used across all pages.
// Replaces every manual header Container in the app.
//
// Usage (basic):
//   AppPageHeader(isDark: isDark, title: l10n.someTitle)
//
// Usage (with subtitle):
//   AppPageHeader(
//     isDark: isDark,
//     title: l10n.jobDetailsTitle,
//     subtitle: '#REQ-00124',
//   )
//
// Usage (with trailing action):
//   AppPageHeader(
//     isDark: isDark,
//     title: l10n.portfolioTitle,
//     trailing: IconButton(icon: Icon(Icons.add), onPressed: () {}),
//   )
//
// Usage (no back button):
//   AppPageHeader(isDark: isDark, title: l10n.title, showBack: false)
// ══════════════════════════════════════════════════════════════
class AppPageHeader extends StatelessWidget {
  final bool isDark;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final bool showBack;

  /// Accent color for the bottom border tint.
  /// Defaults to AppColors.primary[60] (orange).
  final Color? accentColor;

  const AppPageHeader({
    super.key,
    required this.isDark,
    required this.title,
    this.subtitle,
    this.trailing,
    this.showBack = true,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final top = MediaQuery.of(context).padding.top;
    final accent = accentColor ?? AppColors.primary[60]!;

    // Frosted glass base color — subtle accent tint
    final baseColor = isDark
        ? Color.alphaBlend(
            accent.withOpacity(0.06),
            AppColors.darkSurface,
          ).withOpacity(0.88)
        : Color.alphaBlend(
            accent.withOpacity(0.04),
            Colors.white,
          ).withOpacity(0.82);

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.lg.w,
            top + AppSpacing.md.h,
            AppSpacing.lg.w,
            AppSpacing.md.h,
          ),
          decoration: BoxDecoration(
            color: baseColor,
            border: Border(
              bottom: BorderSide(color: accent.withOpacity(0.30), width: 1.0),
            ),
            boxShadow: [
              BoxShadow(
                color: accent.withOpacity(isDark ? 0.12 : 0.08),
                blurRadius: 16,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              if (showBack) ...[
                AppBackButton(isDark: isDark, tapColor: accent),
                SizedBox(width: 14.w),
              ],
              Expanded(
                child: subtitle != null
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            title,
                            style: textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            subtitle!,
                            style: textTheme.bodySmall?.copyWith(
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      )
                    : Text(
                        title,
                        style: textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
              ),
              ?trailing,
            ],
          ),
        ),
      ),
    );
  }
}
