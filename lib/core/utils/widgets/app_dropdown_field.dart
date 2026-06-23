import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../config/constants/enums/app_enums.dart';
import '../../theme/app_colors.dart';

// ══════════════════════════════════════════════════════════════
// AppDropdownField
// Usage:
//   AppDropdownField<String>(
//     label: 'المدينة',
//     hintText: 'اختر المدينة',
//     value: _selectedCity,
//     items: ['القاهرة', 'الجيزة'],
//     onChanged: (v) => setState(() => _selectedCity = v),
//   )
// ══════════════════════════════════════════════════════════════
class AppDropdownField<T> extends StatelessWidget {
  final String label;
  final String hintText;
  final T? value;
  final List<T> items;
  final String Function(T)? itemLabel;
  final void Function(T?) onChanged;
  final String? Function(T?)? validator;
  final AppUserType userType;

  const AppDropdownField({
    super.key,
    required this.label,
    required this.hintText,
    required this.items,
    required this.onChanged,
    this.value,
    this.itemLabel,
    this.validator,
    this.userType = AppUserType.customer,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    // ── Dynamic Colors ───────────────────────────────
    final isHandyman = userType == AppUserType.handyman;

    final mainColor = isHandyman
        ? AppColors.accent[60]!
        : AppColors.primary[60]!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: textTheme.bodyMedium),
        SizedBox(height: 8.h),
        DropdownButtonFormField<T>(
          initialValue: value,
          validator: validator,
          onChanged: onChanged,
          isExpanded: true,
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: colorScheme.onSurfaceVariant,
          ),
          style: textTheme.bodyLarge?.copyWith(color: colorScheme.onSurface),
          decoration: InputDecoration(
            hintText: hintText,

            // ── Borders ───────────────────────────
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: colorScheme.outline),
            ),

            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: mainColor, width: 2),
            ),

            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: colorScheme.error),
            ),

            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: colorScheme.error, width: 2),
            ),

            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(
                color: colorScheme.outline.withOpacity(0.5),
              ),
            ),

            contentPadding: EdgeInsets.symmetric(
              horizontal: 14.w,
              vertical: 12.h,
            ),
          ),
          items: items.map((item) {
            return DropdownMenuItem<T>(
              value: item,
              child: Text(
                itemLabel != null ? itemLabel!(item) : item.toString(),
                style: textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurface,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
