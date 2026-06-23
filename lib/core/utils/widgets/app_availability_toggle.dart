import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_sizes.dart';

// ══════════════════════════════════════════════════════════════
// AppAvailabilityToggle
// Reusable availability toggle card with pulsing dot and
// custom switch, supporting dark mode out of the box.
//
// Usage:
//   AppAvailabilityToggle(
//     isAvailable: true,
//     accentColor: AppColors.accent[60]!,
//     onChanged: (v) { ... },
//   )
// ══════════════════════════════════════════════════════════════

class AppAvailabilityToggle extends StatelessWidget {
  final bool isAvailable;
  final Color accentColor;
  final ValueChanged<bool> onChanged;
  final String? availableTitle;
  final String? unavailableTitle;
  final String? availableSubtitle;
  final String? unavailableSubtitle;

  const AppAvailabilityToggle({
    super.key,
    required this.isAvailable,
    required this.accentColor,
    required this.onChanged,
    this.availableTitle,
    this.unavailableTitle,
    this.availableSubtitle,
    this.unavailableSubtitle,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: EdgeInsets.fromLTRB(
        AppSpacing.xl.w, 0, AppSpacing.xl.w, AppSpacing.lg.h,
      ),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkSurface.withOpacity(0.80)
            : Colors.white.withOpacity(0.85),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: accentColor.withOpacity(0.15)),
        boxShadow: [
          BoxShadow(
            color: accentColor.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.r),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
            child: Row(
              children: [
                _PulsingAvailabilityDot(
                  isActive: isAvailable,
                  activeColor: accentColor,
                ),
                SizedBox(width: 14.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isAvailable
                            ? (availableTitle ?? 'متاح للعمل')
                            : (unavailableTitle ?? 'غير متاح'),
                        style: GoogleFonts.cairo(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        isAvailable
                            ? (availableSubtitle ?? 'ستتلقى طلبات جديدة')
                            : (unavailableSubtitle ?? 'لن تتلقى طلبات جديدة'),
                        style: GoogleFonts.cairo(
                          fontSize: 12.sp,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                _CustomSwitch(
                  value: isAvailable,
                  activeColor: accentColor,
                  onChanged: (v) {
                    HapticFeedback.selectionClick();
                    onChanged(v);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// Internal: Pulsing availability dot
// ══════════════════════════════════════════════════════════════

class _PulsingAvailabilityDot extends StatefulWidget {
  final bool isActive;
  final Color activeColor;
  const _PulsingAvailabilityDot({
    required this.isActive,
    required this.activeColor,
  });

  @override
  State<_PulsingAvailabilityDot> createState() =>
      _PulsingAvailabilityDotState();
}

class _PulsingAvailabilityDotState extends State<_PulsingAvailabilityDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.isActive ? widget.activeColor : AppColors.danger;
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Container(
        width: 12.w,
        height: 12.h,
        decoration: BoxDecoration(
          color: color.withOpacity(_anim.value),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.35 * _anim.value),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// Internal: Custom animated switch
// ══════════════════════════════════════════════════════════════

class _CustomSwitch extends StatelessWidget {
  final bool value;
  final Color activeColor;
  final ValueChanged<bool> onChanged;

  const _CustomSwitch({
    required this.value,
    required this.activeColor,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 52.w,
        height: 30.h,
        padding: EdgeInsets.all(3.w),
        decoration: BoxDecoration(
          color: value ? activeColor : Colors.grey.shade300,
          borderRadius: BorderRadius.circular(15.r),
          boxShadow: [
            BoxShadow(
              color: value
                  ? activeColor.withOpacity(0.4)
                  : Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 24.w,
            height: 24.h,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
