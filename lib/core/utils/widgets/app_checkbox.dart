import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../config/constants/enums/app_enums.dart';
import '../../theme/app_colors.dart';

// ══════════════════════════════════════════════════════════════
// AppCheckbox
// Reusable checkbox with dynamic theming
//
// Usage:
//   AppCheckbox(
//     label: 'تذكرني',
//     value: _rememberMe,
//     onChanged: (v) => setState(() => _rememberMe = v),
//     userType: AppUserType.handyman, // optional
//   )
// ══════════════════════════════════════════════════════════════
class AppCheckbox extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  final AppUserType userType;

  const AppCheckbox({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.userType = AppUserType.customer,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // ── Dynamic Colors ───────────────────────────────────────
    final isHandyman = userType == AppUserType.handyman;
    final mainColor = isHandyman
        ? AppColors.accent[60]!
        : AppColors.primary[60]!;

    // ── Icon Color: White in dark mode, mainColor in light mode
    final checkColor = isDark ? Colors.white : mainColor;

    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: GestureDetector(
        onTap: () => onChanged(!value),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 24.w,
              height: 24.h,
              child: Checkbox(
                value: value,
                onChanged: (v) => onChanged(v ?? false),
                activeColor: mainColor,
                checkColor: checkColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4.r),
                ),
                side: BorderSide(
                  color: value
                      ? mainColor
                      : colorScheme.outline,
                  width: value ? 2 : 1.5,
                ),
              ),
            ),
            SizedBox(width: 8.w),
            Text(
              label,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
