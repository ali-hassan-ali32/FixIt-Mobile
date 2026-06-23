import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../animations/app_motion.dart';

class AppGradientButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final Gradient? gradient;
  final Color? color;
  final Color? shadowColor;
  final Color textColor;
  final bool isLoading;
  final double height;
  final double fontSize;
  final Widget? leadingIcon;

  const AppGradientButton({
    super.key,
    required this.label,
    required this.onTap,
    this.gradient,
    this.color,
    this.shadowColor,
    this.textColor = Colors.white,
    this.isLoading = false,
    this.height = 52,
    this.fontSize = 15,
    this.leadingIcon,
  });

  @override
  Widget build(BuildContext context) {
    final disabled = isLoading || onTap == null;
    final borderRadius = BorderRadius.circular(14.r);

    return Opacity(
      opacity: disabled && !isLoading ? 0.58 : 1,
      child: AppTapScale(
        onTap: disabled ? null : onTap,
        borderRadius: borderRadius,
        child: AnimatedContainer(
          duration: AppMotionDurations.medium,
          curve: Curves.easeOutCubic,
          width: double.infinity,
          height: height.h,
          decoration: BoxDecoration(
            gradient: gradient,
            color: color,
            borderRadius: borderRadius,
            boxShadow: shadowColor != null
                ? [
                    BoxShadow(
                      color: shadowColor!,
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : const [],
          ),
          child: Center(
            child: PageTransitionSwitcher(
              duration: AppMotionDurations.medium,
              transitionBuilder: (child, animation, secondaryAnimation) {
                return FadeScaleTransition(animation: animation, child: child);
              },
              child: isLoading
                  ? SizedBox(
                      key: const ValueKey('loading'),
                      width: 24.w,
                      height: 24.w,
                      child: CircularProgressIndicator(
                        color: textColor,
                        strokeWidth: 2.5,
                      ),
                    )
                  : Row(
                      key: const ValueKey('content'),
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (leadingIcon != null) ...[
                          leadingIcon!,
                          SizedBox(width: 8.w),
                        ],
                        Flexible(
                          child: Text(
                            label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.cairo(
                              fontSize: fontSize.sp,
                              fontWeight: FontWeight.w700,
                              color: textColor,
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
