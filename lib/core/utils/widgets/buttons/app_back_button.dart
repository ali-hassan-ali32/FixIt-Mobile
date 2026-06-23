import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../theme/app_colors.dart';

// ══════════════════════════════════════════════════════════════
// AppBackButton
// Animated circular back button — auto-pops on tap.
// Supports custom tap color.
//
// Usage:
//   AppBackButton(isDark: isDark)
//   AppBackButton(isDark: isDark, tapColor: AppColors.secondary[60])
//   AppBackButton(isDark: isDark, onTap: () {})
// ══════════════════════════════════════════════════════════════
class AppBackButton extends StatefulWidget {
  final bool isDark;
  final VoidCallback? onTap;
  final Color? tapColor;

  const AppBackButton({
    super.key,
    required this.isDark,
    this.onTap,
    this.tapColor,
  });

  @override
  State<AppBackButton> createState() => _AppBackButtonState();
}

class _AppBackButtonState extends State<AppBackButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final Color activeColor = widget.tapColor ?? AppColors.primary[60]!;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);

        if (widget.onTap != null) {
          widget.onTap!();
        } else {
          Navigator.of(context).pop();
        }
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.88 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 38.w,
          height: 38.h,
          decoration: BoxDecoration(
            color: _pressed
                ? activeColor.withOpacity(0.1)
                : widget.isDark
                ? AppColors.darkSurface
                : activeColor.withOpacity(0.06),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.arrow_back_rounded,
            size: 20.sp,
            color: _pressed
                ? activeColor
                : widget.isDark
                ? AppColors.darkTextPrimary
                : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}