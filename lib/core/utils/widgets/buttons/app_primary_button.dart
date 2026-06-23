import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_shadows.dart';
import '../animations/app_motion.dart';

class AppPrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isLoading;
  final bool enabled;

  const AppPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isActive = enabled && !isLoading;
    final borderRadius = BorderRadius.all(AppRadius.lg);

    return Opacity(
      opacity: isActive ? 1 : 0.58,
      child: AppTapScale(
        onTap: isActive ? onPressed : null,
        borderRadius: borderRadius,
        child: AnimatedContainer(
          duration: AppMotionDurations.medium,
          curve: Curves.easeOutCubic,
          width: double.infinity,
          height: 52.h,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isActive
                  ? [
                      AppColors.primary[60]!,
                      AppColors.secondary[60]!,
                    ]
                  : [
                      AppColors.primary[40]!,
                      AppColors.secondary[40]!,
                    ],
            ),
            borderRadius: borderRadius,
            boxShadow: isActive ? AppShadows.primary : const [],
          ),
          child: Center(
            child: PageTransitionSwitcher(
              duration: AppMotionDurations.medium,
              transitionBuilder: (child, animation, secondaryAnimation) {
                return FadeScaleTransition(
                  animation: animation,
                  child: child,
                );
              },
              child: isLoading
                  ? SizedBox(
                      key: const ValueKey('loading'),
                      width: 22.w,
                      height: 22.h,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      label,
                      key: const ValueKey('label'),
                      style: textTheme.labelLarge,
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
