import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../config/constants/enums/app_enums.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_sizes.dart';

// ══════════════════════════════════════════════════════════════
// AppFileUploader
// Dashed upload box with selected state.
//
// Pure UI component — all state is owned by the parent screen.
//
// Usage:
//   AppFileUploader(
//     label: 'الرقم القومي',
//     hint: 'اضغط لرفع صورة الرقم القومي',
//     icon: Icons.badge_outlined,
//     isSelected: _nationalIdSelected,
//     selectedFileName: _nationalIdFile?.path.split('/').last,
//     onTap: _pickNationalId,
//     validator: (isSelected) => isSelected ? null : 'يرجى رفع الصورة',
//     userType: AppUserType.handyman, // optional, defaults to customer
//   )
// ══════════════════════════════════════════════════════════════
class AppFileUploader extends StatefulWidget {
  final String label;
  final String hint;
  final IconData icon;
  final bool isSelected;
  final String? selectedFileName;
  final VoidCallback onTap;
  final String? Function(bool)? validator;
  final AppUserType userType;

  const AppFileUploader({
    super.key,
    required this.label,
    required this.hint,
    required this.icon,
    required this.onTap,
    this.isSelected = false,
    this.selectedFileName,
    this.validator,
    this.userType = AppUserType.customer,
  });

  @override
  State<AppFileUploader> createState() => _AppFileUploaderState();
}

class _AppFileUploaderState extends State<AppFileUploader> {
  bool _isPressed = false;

  // FIX 1 ─────────────────────────────────────────────────────
  // A GlobalKey lets us reach into the FormField's state from
  // outside the builder closure, so we can call didChange() and
  // validate() imperatively whenever the parent updates isSelected.
  final _formFieldKey = GlobalKey<FormFieldState<bool>>();

  // ── Dynamic Colors ─────────────────────────────────────────
  bool get isHandyman => widget.userType == AppUserType.handyman;

  Color get mainColor =>
      isHandyman ? AppColors.accent[60]! : AppColors.primary[60]!;

  // FIX 2 ─────────────────────────────────────────────────────
  // FormField reads initialValue only once (in initState).
  // When the parent calls setState after the async image pick,
  // widget.isSelected updates but the FormField's internal
  // state.value stays stale — causing the validator to keep
  // reporting "not selected" even though a file was chosen.
  //
  // didUpdateWidget fires synchronously on every parent rebuild,
  // so we use it to push the new value into the FormField and
  // immediately re-validate, clearing the error banner.
  //
  // addPostFrameCallback avoids triggering a setState on a
  // sibling widget during the current build phase.
  @override
  void didUpdateWidget(AppFileUploader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isSelected != widget.isSelected) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        // Keep FormField's internal value in sync with the parent.
        _formFieldKey.currentState?.didChange(widget.isSelected);
        // If a file was just picked, clear the error immediately
        // so the user isn't shown a stale validation message.
        if (widget.isSelected) {
          _formFieldKey.currentState?.validate();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return FormField<bool>(
      // FIX 1 (continued) — wire up the key.
      key: _formFieldKey,
      initialValue: widget.isSelected,

      // FIX 3 ─────────────────────────────────────────────────
      // Original code: `(_) => widget.validator!(state.value ?? false)`
      //
      // Two problems:
      //   a) `state` (the builder parameter) is a sibling closure,
      //      not in lexical scope here — this does not refer to the
      //      FormFieldState at all.
      //   b) Even if it did, state.value is the FormField's internal
      //      bool, which lags behind widget.isSelected after an async
      //      pick until didChange() is called.
      //
      // Fix: use widget.isSelected directly. It is always the current
      // source of truth (set by the parent's setState after picking).
      validator: widget.validator != null
          ? (_) => widget.validator!(widget.isSelected)
          : null,

      builder: (state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.label, style: textTheme.bodyMedium),
            SizedBox(height: 8.h),
            GestureDetector(
              onTapDown: (_) => setState(() => _isPressed = true),
              onTapUp: (_) => setState(() => _isPressed = false),
              onTapCancel: () => setState(() => _isPressed = false),

              // FIX 4 ───────────────────────────────────────────
              // Original code used Future.delayed(300ms, () => state.didChange(true)).
              //
              // Race conditions this caused:
              //   • If the user cancels the picker, FormField still
              //     flips to true (false positive).
              //   • If picking takes >300 ms, the delay fires while
              //     widget.isSelected is still false — causing an
              //     inconsistency between FormField state and parent state.
              //   • When didUpdateWidget also fires, there are two
              //     competing didChange() calls.
              //
              // Fix: pass onTap straight through. The parent's async
              // handler calls setState only on a successful pick, which
              // triggers didUpdateWidget, which syncs FormField cleanly.
              onTap: widget.onTap,

              child: AnimatedScale(
                scale: _isPressed ? 0.97 : 1.0,
                duration: const Duration(milliseconds: 100),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: EdgeInsets.all(AppSpacing.xl.w),
                  decoration: BoxDecoration(
                    color: widget.isSelected
                        ? mainColor.withOpacity(0.05)
                        : colorScheme.surface,
                    borderRadius: BorderRadius.all(AppRadius.md),
                    border: Border.all(
                      color: state.hasError
                          ? colorScheme.error
                          : widget.isSelected
                          ? mainColor
                          : colorScheme.outline,
                      width: widget.isSelected ? 2 : 1.5,
                      style: widget.isSelected
                          ? BorderStyle.solid
                          : BorderStyle.none,
                    ),
                  ),
                  child: _buildDashedBorder(
                    context,
                    colorScheme,
                    textTheme,
                    state.hasError,
                  ),
                ),
              ),
            ),

            // ── Error ─────────────────────────────────────────
            if (state.hasError) ...[
              SizedBox(height: 6.h),
              Text(
                state.errorText!,
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.error,
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildDashedBorder(
      BuildContext context,
      ColorScheme colorScheme,
      TextTheme textTheme,
      bool hasError,
      ) {
    return CustomPaint(
      painter: _DashedBorderPainter(
        color: hasError
            ? colorScheme.error
            : widget.isSelected
            ? mainColor
            : colorScheme.outline,
        borderRadius: AppRadius.md.x,
      ),
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.md.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Icon ──────────────────────────────────────────
            widget.isSelected
                ? Icon(
              Icons.check_circle,
              size: 48.sp,
              color: mainColor,
            )
                : Container(
              width: 56.w,
              height: 56.h,
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                shape: BoxShape.circle,
              ),
              child: Icon(
                widget.icon,
                size: 28.sp,
              ),
            ),

            SizedBox(height: 12.h),

            // ── Text ──────────────────────────────────────────
            Text(
              widget.isSelected && widget.selectedFileName != null
                  ? widget.selectedFileName!
                  : widget.hint,
              style: textTheme.bodyLarge?.copyWith(
                color: widget.isSelected
                    ? mainColor
                    : colorScheme.onSurfaceVariant,
                fontWeight:
                widget.isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Dashed Border Painter ─────────────────────────────────────
class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final double borderRadius;

  _DashedBorderPainter({required this.color, required this.borderRadius});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    const dashWidth = 6.0;
    const dashSpace = 4.0;
    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        Radius.circular(borderRadius),
      ));

    final pathMetrics = path.computeMetrics();
    for (final metric in pathMetrics) {
      double distance = 0;
      while (distance < metric.length) {
        canvas.drawPath(
          metric.extractPath(distance, distance + dashWidth),
          paint,
        );
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedBorderPainter old) =>
      old.color != color || old.borderRadius != borderRadius;
}