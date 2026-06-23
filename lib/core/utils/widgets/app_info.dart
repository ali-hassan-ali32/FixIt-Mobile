import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_sizes.dart';

enum AppInfoBoxType { info, warning, success, error }

class AppInfoBox extends StatelessWidget {
  final String message;
  final AppInfoBoxType type;
  final IconData? icon;

  const AppInfoBox({
    super.key,
    required this.message,
    this.type = AppInfoBoxType.info,
    this.icon,
  });

  // ── Type Config ───────────────────────────────────────────
  _InfoBoxConfig _config(bool isDark) {
    switch (type) {
      case AppInfoBoxType.info:
        return _InfoBoxConfig(
          color: AppColors.accent[60]!,
          bgColor: AppColors.accent[60]!.withOpacity(0.1),
          darkBgColor: AppColors.accent[60]!.withOpacity(0.08),
          icon: icon ?? Icons.info_outline_rounded,
        );
      case AppInfoBoxType.warning:
        return _InfoBoxConfig(
          color: AppColors.warning,
          bgColor: AppColors.warning.withOpacity(0.1),
          darkBgColor: AppColors.warning.withOpacity(0.08),
          icon: icon ?? Icons.warning_amber_rounded,
        );
      case AppInfoBoxType.success:
        return _InfoBoxConfig(
          color: AppColors.success,
          bgColor: AppColors.success.withOpacity(0.1),
          darkBgColor: AppColors.success.withOpacity(0.08),
          icon: icon ?? Icons.check_circle_outline_rounded,
        );
      case AppInfoBoxType.error:
        return _InfoBoxConfig(
          color: AppColors.danger,
          bgColor: AppColors.danger.withOpacity(0.1),
          darkBgColor: AppColors.danger.withOpacity(0.08),
          icon: icon ?? Icons.error_outline_rounded,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isDark    = Theme.of(context).brightness == Brightness.dark;
    final config    = _config(isDark);

    return Container(
      padding: EdgeInsets.all(AppSpacing.md.w),
      decoration: BoxDecoration(
        color: isDark ? config.darkBgColor : config.bgColor,
        borderRadius: BorderRadius.all(AppRadius.md),
        border: Border(
          // RTL: border على اليمين زي الـ HTML
          right: BorderSide(color: config.color, width: 4),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Icon ────────────────────────────────────
          Icon(config.icon, color: config.color, size: 18.sp),
          SizedBox(width: AppSpacing.sm.w),

          // ── Message ──────────────────────────────────
          Expanded(
            child: Text(
              message,
              style: textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoBoxConfig {
  final Color color;
  final Color bgColor;
  final Color darkBgColor;
  final IconData icon;

  const _InfoBoxConfig({
    required this.color,
    required this.bgColor,
    required this.darkBgColor,
    required this.icon,
  });
}