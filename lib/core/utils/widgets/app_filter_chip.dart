import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/app_colors.dart';

// ══════════════════════════════════════════════════════════════
// AppFilterChip
// Animated gradient filter chip used in list/filter rows.
//
// Usage (customer — orange default):
//   AppFilterChip(
//     label: 'الكل',
//     isActive: _filter == null,
//     onTap: () => setState(() => _filter = null),
//     isDark: isDark,
//   )
//
// Usage (handyman — teal):
//   AppFilterChip(
//     label: 'الكل',
//     isActive: _filter == null,
//     onTap: () => setState(() => _filter = null),
//     isDark: isDark,
//     activeColor: AppColors.accent[60],
//   )
// ══════════════════════════════════════════════════════════════
class AppFilterChip extends StatefulWidget {
  final String       label;
  final bool         isActive;
  final VoidCallback onTap;
  final bool         isDark;
  /// Active color — drives gradient, border, shadow, and text.
  /// Defaults to AppColors.primary[60] (customer orange).
  final Color?       activeColor;
  /// Second gradient color. Defaults to AppColors.secondary[60].
  /// Pass same value as activeColor for a solid chip.
  final Color?       activeColorEnd;

  const AppFilterChip({
    super.key,
    required this.label,
    required this.isActive,
    required this.onTap,
    required this.isDark,
    this.activeColor,
    this.activeColorEnd,
  });

  @override
  State<AppFilterChip> createState() => _AppFilterChipState();
}

class _AppFilterChipState extends State<AppFilterChip>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double>   _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 150));
    _scale = Tween<double>(begin: 1.0, end: 0.93)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorStart = widget.activeColor    ?? AppColors.primary[60]!;
    final colorEnd   = widget.activeColorEnd ?? AppColors.secondary[60]!;

    return GestureDetector(
      onTapDown:   (_) => _ctrl.forward(),
      onTapUp:     (_) {
        _ctrl.reverse();
        widget.onTap();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: AnimatedBuilder(
        animation: _scale,
        builder: (_, child) =>
            Transform.scale(scale: _scale.value, child: child),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          decoration: BoxDecoration(
            gradient: widget.isActive
                ? LinearGradient(colors: [colorStart, colorEnd])
                : null,
            color: widget.isActive
                ? null
                : widget.isDark
                ? AppColors.darkSurface
                : Colors.white,
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(
              color: widget.isActive
                  ? Colors.transparent
                  : colorStart.withOpacity(0.15),
              width: 1.5,
            ),
            boxShadow: widget.isActive
                ? [
              BoxShadow(
                color: colorStart.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ]
                : [],
          ),
          child: Center(
            child: Text(
              widget.label,
              style: GoogleFonts.cairo(
                fontSize: 12.5.sp,
                fontWeight: FontWeight.w700,
                color: widget.isActive
                    ? Colors.white
                    : widget.isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}