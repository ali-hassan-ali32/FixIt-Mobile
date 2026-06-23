import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../config/constants/enums/app_enums.dart';
import '../../../../core/theme/app_colors.dart';

// ══════════════════════════════════════════════════════════════
// AppTermsCheckbox
// Reusable terms & conditions checkbox with dynamic theming
//
// Usage:
//   AppTermsCheckbox(
//     isChecked: _agreeToTerms,
//     onChanged: (v) => setState(() => _agreeToTerms = v),
//     termsText: 'أوافق على',
//     linkText: 'الشروط والأحكام',
//     onLinkTap: () => _openTerms(),
//     userType: AppUserType.handyman, // optional
//   )
// ══════════════════════════════════════════════════════════════
class AppTermsCheckbox extends StatelessWidget {
  final bool isChecked;
  final ValueChanged<bool> onChanged;
  final String termsText;
  final String linkText;
  final VoidCallback onLinkTap;
  final AppUserType userType;

  const AppTermsCheckbox({
    super.key,
    required this.isChecked,
    required this.onChanged,
    required this.termsText,
    required this.linkText,
    required this.onLinkTap,
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

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // ── Checkbox ────────────────────────────────────────
        SizedBox(
          width: 24.w,
          height: 24.h,
          child: Checkbox(
            value: isChecked,
            onChanged: (v) => onChanged(v ?? false),
            activeColor: mainColor,
            checkColor: checkColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4.r),
            ),
            side: BorderSide(
              color: isChecked
                  ? mainColor
                  : colorScheme.outline,
              width: 2,
            ),
          ),
        ),
        SizedBox(width: 8.w),

        // ── Terms Text ──────────────────────────────────────
        Flexible(
          child: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                termsText,
                style: textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurface,
                ),
              ),
              SizedBox(width: 4.w),
              GestureDetector(
                onTap: onLinkTap,
                child: Text(
                  linkText,
                  style: textTheme.bodyLarge?.copyWith(
                    color: mainColor,
                    fontWeight: FontWeight.w700,
                    decoration: TextDecoration.underline,
                    decorationColor: mainColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
