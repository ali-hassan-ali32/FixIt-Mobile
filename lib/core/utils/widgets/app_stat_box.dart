import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';

// ══════════════════════════════════════════════════════════════
// AppStatBox
// Animated scale-in stat card used in profile/home stat rows.
//
// Usage:
//   AppStatBox(value: '240', label: l10n.profileStatJobs,
//     isDark: isDark, accentColor: teal)
//   AppStatBox(..., delay: 80)   // staggered
// ══════════════════════════════════════════════════════════════
class AppStatBox extends StatefulWidget {
  final String  value;
  final String  label;
  final bool    isDark;
  final Color   accentColor;
  final int     delay; // ms before animating in

  const AppStatBox({
    super.key,
    required this.value,
    required this.label,
    required this.isDark,
    required this.accentColor,
    this.delay = 0,
  });

  @override
  State<AppStatBox> createState() => _AppStatBoxState();
}

class _AppStatBoxState extends State<AppStatBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 500));
  late final Animation<double> _scale = Tween<double>(begin: 0.7, end: 1.0)
      .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack));
  late final Animation<double> _fade =
  CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);

  @override
  void initState() {
    super.initState();
    Future.delayed(
        Duration(milliseconds: widget.delay),
            () { if (mounted) _ctrl.forward(); });
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return FadeTransition(
      opacity: _fade,
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 8.w),
          decoration: BoxDecoration(
            color: widget.isDark ? AppColors.darkSurface : Colors.white,
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(
                color: widget.accentColor.withOpacity(0.10)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
              ),
            ],
          ),
          child: Column(
            children: [
              Text(
                widget.value,
                style: GoogleFonts.cairo(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w800,
                  color: widget.accentColor,
                ),
              ),
              SizedBox(height: 3.h),
              Text(
                widget.label,
                style: textTheme.labelSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}