import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/app_colors.dart';

// ══════════════════════════════════════════════════════════════
// AppDetailRow
// Label/value row with optional divider.
// Used in: service details cards, request track screens.
//
// Usage:
//   AppDetailRow(label: 'نوع الخدمة', value: 'سباكة')
//   AppDetailRow(label: 'السعر', value: '200 ج', valueColor: AppColors.secondary[60])
//   AppDetailRow(label: 'الحالة', value: 'قيد الانتظار', showDivider: false)
// ══════════════════════════════════════════════════════════════
class AppDetailRow extends StatelessWidget {
  final String  label;
  final String  value;
  final Color?  valueColor;
  final bool    showDivider;
  final Widget? trailing; // optional custom trailing widget

  const AppDetailRow({
    super.key,
    required this.label,
    required this.value,
    this.valueColor,
    this.showDivider = true,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme   = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 12.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(
                flex: 2,
                child: Text(
                  label,
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Flexible(
                flex: 3,
                child: trailing ??
                    Text(
                      value,
                      style: GoogleFonts.cairo(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: valueColor ?? textTheme.bodyMedium?.color,
                      ),
                      textAlign: TextAlign.end,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
              ),
            ],
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            thickness: 1,
            color: AppColors.primary[60]!.withOpacity(0.06),
          ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════
// AppDetailCard
// Card wrapper that holds a title + list of AppDetailRows.
//
// Usage:
//   AppDetailCard(
//     isDark: isDark,
//     title: 'تفاصيل الخدمة',
//     rows: [
//       AppDetailRow(label: 'نوع الخدمة', value: 'سباكة'),
//       AppDetailRow(label: 'الموقع', value: 'القاهرة - الزمالك'),
//       AppDetailRow(label: 'السعر', value: '200 ج',
//           valueColor: AppColors.secondary[60], showDivider: false),
//     ],
//   )
// ══════════════════════════════════════════════════════════════
class AppDetailCard extends StatelessWidget {
  final bool          isDark;
  final String        title;
  final List<Widget>  rows;

  const AppDetailCard({
    super.key,
    required this.isDark,
    required this.title,
    required this.rows,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
            color: AppColors.primary[60]!.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.15 : 0.05),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w800),
          ),
          SizedBox(height: 4.h),
          ...rows,
        ],
      ),
    );
  }
}