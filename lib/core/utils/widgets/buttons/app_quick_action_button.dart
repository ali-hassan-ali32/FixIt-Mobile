import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../theme/app_colors.dart';

// ══════════════════════════════════════════════════════════════
// AppQuickActionButton
// Reusable circular quick-action button for dashboards.
//
// Usage:
//   AppQuickActionButton(
//     icon: Icons.folder_outlined,
//     label: 'المعرض',
//     onTap: () => Navigator.push(...),
//     accentColor: AppColors.accent[60],
//   )
// ══════════════════════════════════════════════════════════════

class AppQuickActionButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? accentColor;
  final Color? backgroundColor;

  const AppQuickActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.accentColor,
    this.backgroundColor,
  });

  @override
  State<AppQuickActionButton> createState() => _AppQuickActionButtonState();
}

class _AppQuickActionButtonState extends State<AppQuickActionButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = widget.accentColor ?? AppColors.accent[60]!;

    return GestureDetector(
      onTapDown: (_) {
        _ctrl.forward();
        HapticFeedback.selectionClick();
      },
      onTapUp: (_) {
        _ctrl.reverse();
        widget.onTap();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Circle button
            Container(
              width: 56.w,
              height: 56.h,
              decoration: BoxDecoration(
                color: widget.backgroundColor ??
                    (isDark
                        ? AppColors.darkSurface.withOpacity(0.60)
                        : accent.withOpacity(0.10)),
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDark
                      ? AppColors.darkBorder.withOpacity(0.3)
                      : accent.withOpacity(0.15),
                ),
                boxShadow: [
                  BoxShadow(
                    color: accent.withOpacity(0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                widget.icon,
                size: 24.sp,
                color: accent,
              ),
            ),
            SizedBox(height: 8.h),
            // Label
            Text(
              widget.label,
              style: GoogleFonts.cairo(
                fontSize: 11.sp,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
