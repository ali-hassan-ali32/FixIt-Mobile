import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../config/constants/enums/app_enums.dart';
import '../../theme/app_colors.dart';

// ══════════════════════════════════════════════════════════════
// AppStepProgressBar
// Animated step progress indicator with dynamic theming
// RTL Support: Progress fills from right to left
//
// Usage:
//   AppStepProgressBar(
//     currentStep: 2,
//     steps: ['الخطوة 1', 'الخطوة 2', 'الخطوة 3'],
//     userType: AppUserType.handyman, // optional
//   )
// ══════════════════════════════════════════════════════════════
class AppStepProgressBar extends StatelessWidget {
  final int currentStep;
  final List<String> steps;
  final AppUserType userType;

  const AppStepProgressBar({
    super.key,
    required this.currentStep,
    required this.steps,
    this.userType = AppUserType.customer,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // ── Validation ───────────────────────────────────────────
    if (steps.isEmpty) return const SizedBox.shrink();

    // ── Dynamic Colors ───────────────────────────────────────
    final isHandyman = userType == AppUserType.handyman;
    final mainColor = isHandyman
        ? AppColors.accent[60]!
        : AppColors.primary[60]!;
    final secondaryColor = isHandyman
        ? AppColors.accent[40]!
        : AppColors.secondary[60]!;

    // ── Check icon color for dark mode ───────────────────────
    final checkColor = isDark ? Colors.white : Colors.white;

    return Column(
      children: [
        // ── Progress Line & Circles ───────────────────────────
        SizedBox(
          height: 40.h,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final totalWidth = constraints.maxWidth;
              final stepWidth = totalWidth / (steps.length - 1);

              return Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  // ── Background Line ──────────────────────────
                  Positioned(
                    left: 20.w,
                    right: 20.w,
                    child: Container(
                      height: 3.h,
                      decoration: BoxDecoration(
                        color: colorScheme.outline,
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                    ),
                  ),

                  // ── Progress Fill (RTL: starts from right) ─────
                  Positioned(
                    right: 20.w, // RTL: anchor from right
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeInOut,
                      width: _calculateProgressWidth(stepWidth),
                      height: 3.h,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          // RTL: gradient direction reversed
                          begin: Alignment.centerRight,
                          end: Alignment.centerLeft,
                          colors: [mainColor, secondaryColor],
                        ),
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                    ),
                  ),

                  // ── Step Circles ─────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(steps.length, (i) {
                      final stepNumber = i + 1;
                      final isCompleted = stepNumber < currentStep;
                      final isActive = stepNumber == currentStep;

                      return _StepCircle(
                        stepNumber: stepNumber,
                        isCompleted: isCompleted,
                        isActive: isActive,
                        mainColor: mainColor,
                        secondaryColor: secondaryColor,
                        checkColor: checkColor,
                      );
                    }),
                  ),
                ],
              );
            },
          ),
        ),

        SizedBox(height: 12.h),

        // ── Step Labels (RTL padding) ───────────────────────────
        Row(
          children: List.generate(steps.length, (i) {
            final stepNumber = i + 1;
            final isActive = stepNumber == currentStep;
            final isCompleted = stepNumber < currentStep;

            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  // RTL: swap left/right for padding
                  right: i == 0 ? 0 : 4.w,
                  left: i == steps.length - 1 ? 0 : 4.w,
                ),
                child: Text(
                  steps[i],
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodySmall?.copyWith(
                    color: isActive || isCompleted
                        ? mainColor
                        : colorScheme.onSurfaceVariant,
                    fontWeight: isActive
                        ? FontWeight.w600
                        : FontWeight.w400,
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  /// Calculate progress line width based on current step
  double _calculateProgressWidth(double stepWidth) {
    if (currentStep <= 1) return 0;
    return (currentStep - 1) * stepWidth;
  }
}

// ══════════════════════════════════════════════════════════════
// _StepCircle
// ══════════════════════════════════════════════════════════════
class _StepCircle extends StatelessWidget {
  final int stepNumber;
  final bool isCompleted;
  final bool isActive;
  final Color mainColor;
  final Color secondaryColor;
  final Color checkColor;

  const _StepCircle({
    required this.stepNumber,
    required this.isCompleted,
    required this.isActive,
    required this.mainColor,
    required this.secondaryColor,
    required this.checkColor,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Transform.scale(
          scale: isActive ? 1.0 + (0.05 * value) : 1.0,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,

              // Gradient for active/completed states
              gradient: isActive
                  ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [mainColor, secondaryColor],
              )
                  : isCompleted
                  ? LinearGradient(
                colors: [mainColor, secondaryColor],
              )
                  : null,

              // Inactive background color
              color: !isActive && !isCompleted
                  ? colorScheme.surface
                  : null,

              border: Border.all(
                color: isActive || isCompleted
                    ? Colors.transparent
                    : colorScheme.outline,
                width: 2,
              ),

              // Shadow for active state
              boxShadow: isActive
                  ? [
                BoxShadow(
                  color: mainColor.withOpacity(0.35),
                  blurRadius: 12,
                  offset: const Offset(0, 3),
                ),
              ]
                  : null,
            ),
            child: Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                switchInCurve: Curves.easeIn,
                switchOutCurve: Curves.easeOut,
                child: isCompleted
                    ? Icon(
                  Icons.check_rounded,
                  key: const ValueKey('check'),
                  color: checkColor,
                  size: 20.sp,
                )
                    : Text(
                  '$stepNumber',
                  key: ValueKey('num_$stepNumber'),
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: isActive
                        ? Colors.white
                        : colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
