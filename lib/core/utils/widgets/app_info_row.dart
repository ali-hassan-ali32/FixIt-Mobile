import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// ══════════════════════════════════════════════════════════════
// AppInfoRow
// Icon bubble + label/value row used in profile info cards.
// Replaces _InfoRow in handyman_profile + customer_view_handyman.
//
// Usage:
//   AppInfoRow(icon: Icons.location_on_outlined,
//     label: l10n.profileWorkArea, value: 'مدينة نصر - المعادي',
//     accentColor: teal, isDark: isDark, isLast: false)
// ══════════════════════════════════════════════════════════════
class AppInfoRow extends StatelessWidget {
  final IconData icon;
  final String   label;
  final String   value;
  final Color    accentColor;
  final bool     isDark;
  final bool     isLast;

  const AppInfoRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.accentColor,
    required this.isDark,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme   = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      decoration: isLast
          ? null
          : BoxDecoration(
        border: Border(
          bottom: BorderSide(
              color: accentColor.withOpacity(0.10)),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.10),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(icon, size: 18.sp, color: accentColor),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: textTheme.labelSmall
                        ?.copyWith(color: colorScheme.onSurfaceVariant)),
                SizedBox(height: 2.h),
                Text(value,
                    style: textTheme.bodyMedium
                        ?.copyWith(fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}