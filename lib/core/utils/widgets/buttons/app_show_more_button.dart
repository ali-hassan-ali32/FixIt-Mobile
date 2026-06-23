import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

// ══════════════════════════════════════════════════════════════
// AppShowMoreButton
// Tinted "show all" button used below preview sections.
// Replaces _ShowMoreBtn in handyman_profile + customer_view_handyman.
//
// Usage:
//   AppShowMoreButton(label: l10n.profileShowAllReviews,
//     accentColor: teal, onTap: () { ... })
// ══════════════════════════════════════════════════════════════
class AppShowMoreButton extends StatefulWidget {
  final String       label;
  final Color        accentColor;
  final VoidCallback onTap;

  const AppShowMoreButton({
    super.key,
    required this.label,
    required this.accentColor,
    required this.onTap,
  });

  @override
  State<AppShowMoreButton> createState() => _AppShowMoreButtonState();
}

class _AppShowMoreButtonState extends State<AppShowMoreButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 120));
  late final Animation<double> _scale = Tween<double>(begin: 1.0, end: 0.96)
      .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        _ctrl.forward();
        HapticFeedback.selectionClick();
      },
      onTapUp:     (_) { _ctrl.reverse(); widget.onTap(); },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 13.h),
          decoration: BoxDecoration(
            color: widget.accentColor.withOpacity(0.10),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(widget.label,
                  style: GoogleFonts.cairo(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: widget.accentColor,
                  )),
              SizedBox(width: 6.w),
              Icon(Icons.arrow_back_ios_rounded,
                  size: 13.sp, color: widget.accentColor),
            ],
          ),
        ),
      ),
    );
  }
}