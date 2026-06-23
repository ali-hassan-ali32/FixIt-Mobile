import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../config/constants/enums/app_enums.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_sizes.dart';


class AppStepNavigation extends StatelessWidget {
  final VoidCallback onNext;
  final VoidCallback? onPrevious;
  final String nextLabel;
  final String? previousLabel;
  final bool isLoading;
  final AppUserType userType;

  const AppStepNavigation({
    super.key,
    required this.onNext,
    required this.nextLabel,
    this.onPrevious,
    this.previousLabel,
    this.isLoading = false,
    this.userType = AppUserType.customer,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme   = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    // ── Dynamic Colors ───────────────────────────────
    final isHandyman = userType == AppUserType.handyman;

    final mainColor = isHandyman
        ? AppColors.accent[60]!
        : AppColors.primary[60]!;

    final secondaryColor = isHandyman
        ? AppColors.accent[70]!
        : AppColors.secondary[60]!;

    return Row(
      children: [
        // ── Previous Button ─────────────────────────
        if (onPrevious != null) ...[
          Expanded(
            flex: 1,
            child: _PreviousButton(
              label: previousLabel ?? '',
              onTap: onPrevious!,
              textTheme: textTheme,
              colorScheme: colorScheme,
            ),
          ),
          SizedBox(width: 12.w),
        ],

        // ── Next / Submit Button ─────────────────────
        Expanded(
          flex: 2,
          child: _NextButton(
            label: nextLabel,
            onTap: onNext,
            isLoading: isLoading,
            mainColor: mainColor,
            secondaryColor: secondaryColor,
          ),
        ),
      ],
    );
  }
}

// ── Previous Button ─────────────────────────────────────────
class _PreviousButton extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  final TextTheme textTheme;
  final ColorScheme colorScheme;

  const _PreviousButton({
    required this.label,
    required this.onTap,
    required this.textTheme,
    required this.colorScheme,
  });

  @override
  State<_PreviousButton> createState() => _PreviousButtonState();
}

class _PreviousButtonState extends State<_PreviousButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _isPressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          height: 52.h,
          decoration: BoxDecoration(
            color: widget.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.all(AppRadius.lg),
          ),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.arrow_forward_rounded, // RTL aware
                  size: 18.sp,
                  color: widget.colorScheme.onSurface,
                ),
                SizedBox(width: 6.w),
                Text(
                  widget.label,
                  style: widget.textTheme.labelLarge?.copyWith(
                    color: widget.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Next Button ─────────────────────────────────────────────
class _NextButton extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  final bool isLoading;
  final Color mainColor;
  final Color secondaryColor;

  const _NextButton({
    required this.label,
    required this.onTap,
    required this.isLoading,
    required this.mainColor,
    required this.secondaryColor,
  });

  @override
  State<_NextButton> createState() => _NextButtonState();
}

class _NextButtonState extends State<_NextButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.isLoading ? null : widget.onTap,
      child: AnimatedScale(
        scale: _isPressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          height: 52.h,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [widget.mainColor, widget.secondaryColor],
            ),
            borderRadius: BorderRadius.all(AppRadius.lg),
            boxShadow: [
              BoxShadow(
                color: widget.mainColor.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: widget.isLoading
                ? SizedBox(
              width: 24.w,
              height: 24.h,
              child: const CircularProgressIndicator(
                strokeWidth: 2.5,
                color: Colors.white,
              ),
            )
                : Text(
              widget.label,
              style: Theme.of(context)
                  .textTheme
                  .labelLarge
                  ?.copyWith(color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}