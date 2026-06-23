import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../theme/app_colors.dart';

// ══════════════════════════════════════════════════════════════
// AppStarRatingCard
// Interactive star rating card with prompt + submit button.
// Used in: completed request view, (future) rate handyman flow.
//
// Usage:
//   AppStarRatingCard(
//     isDark: isDark,
//     prompt: l10n.ratingPrompt,
//     submitLabel: l10n.ratingSubmitBtn,
//     onSubmit: (rating) { /* call API */ },
//   )
// ══════════════════════════════════════════════════════════════
class AppStarRatingCard extends StatefulWidget {
  final bool          isDark;
  final String        prompt;
  final String        submitLabel;
  final String?       alreadyRatedLabel; // shown if hasRated=true
  final bool          hasRated;
  final double?       existingRating;
  final ValueChanged<int> onSubmit;

  const AppStarRatingCard({
    super.key,
    required this.isDark,
    required this.prompt,
    required this.submitLabel,
    required this.onSubmit,
    this.alreadyRatedLabel,
    this.hasRated = false,
    this.existingRating,
  });

  @override
  State<AppStarRatingCard> createState() => _AppStarRatingCardState();
}

class _AppStarRatingCardState extends State<AppStarRatingCard> {
  int _selected  = 0;
  int _hovered   = 0;
  bool _submitted = false;

  @override
  void initState() {
    super.initState();
    if (widget.hasRated && widget.existingRating != null) {
      _selected  = widget.existingRating!.round();
      _submitted = true;
    }
  }

  void _submit() {
    if (_selected == 0) return;
    HapticFeedback.mediumImpact();
    setState(() => _submitted = true);
    widget.onSubmit(_selected);
  }

  String _ratingLabel(int stars) {
    switch (stars) {
      case 1: return '😞';
      case 2: return '😕';
      case 3: return '😐';
      case 4: return '😊';
      case 5: return '🤩';
      default: return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme   = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final display     = _hovered > 0 ? _hovered : _selected;

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: widget.isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: _submitted
              ? AppColors.accent[60]!.withOpacity(0.3)
              : AppColors.primary[60]!.withOpacity(0.08),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black
                .withOpacity(widget.isDark ? 0.15 : 0.05),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: _submitted ? _buildSubmitted(textTheme) : _buildRating(textTheme, colorScheme, display),
    );
  }

  // ── Already rated / just submitted ───────────────────────
  Widget _buildSubmitted(TextTheme textTheme) {
    return Column(
      children: [
        Container(
          width: 64.w,
          height: 64.h,
          decoration: BoxDecoration(
            color: AppColors.accent[60]!.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.check_circle_rounded,
              size: 36.sp, color: AppColors.accent[60]),
        ),
        SizedBox(height: 12.h),
        Text(
          widget.alreadyRatedLabel ?? '${_ratingLabel(_selected)} شكراً لتقييمك!',
          style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 10.h),
        // Show selected stars read-only
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            5,
                (i) => Icon(
              i < _selected ? Icons.star_rounded : Icons.star_outline_rounded,
              size: 28.sp,
              color: i < _selected ? AppColors.star : Colors.grey.withOpacity(0.3),
            ),
          ),
        ),
      ],
    );
  }

  // ── Interactive rating ────────────────────────────────────
  Widget _buildRating(TextTheme textTheme, ColorScheme colorScheme, int display) {
    return Column(
      children: [
        // Prompt
        Text(
          widget.prompt,
          style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 16.h),

        // Emoji indicator
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: Text(
            display > 0 ? _ratingLabel(display) : '⭐',
            key: ValueKey(display),
            style: TextStyle(fontSize: 32.sp),
          ),
        ),
        SizedBox(height: 12.h),

        // Stars row
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (i) {
            final starVal = i + 1;
            final isOn    = starVal <= display;
            return GestureDetector(
              onTapDown: (_) {
                setState(() => _hovered = starVal);
                HapticFeedback.selectionClick();
              },
              onTapUp: (_) {
                setState(() {
                  _selected = starVal;
                  _hovered  = 0;
                });
              },
              onTapCancel: () => setState(() => _hovered = 0),
              child: AnimatedScale(
                scale: isOn ? 1.15 : 1.0,
                duration: const Duration(milliseconds: 150),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  child: Icon(
                    isOn ? Icons.star_rounded : Icons.star_outline_rounded,
                    size: 36.sp,
                    color: isOn ? AppColors.star : Colors.grey.withOpacity(0.3),
                  ),
                ),
              ),
            );
          }),
        ),
        SizedBox(height: 20.h),

        // Submit button
        _SubmitButton(
          label: widget.submitLabel,
          enabled: _selected > 0,
          onTap: _submit,
        ),
      ],
    );
  }
}

// ── Submit button ──────────────────────────────────────────
class _SubmitButton extends StatefulWidget {
  final String       label;
  final bool         enabled;
  final VoidCallback onTap;

  const _SubmitButton({
    required this.label,
    required this.enabled,
    required this.onTap,
  });

  @override
  State<_SubmitButton> createState() => _SubmitButtonState();
}

class _SubmitButtonState extends State<_SubmitButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.enabled
          ? (_) => setState(() => _pressed = true)
          : null,
      onTapUp: widget.enabled
          ? (_) {
        setState(() => _pressed = false);
        widget.onTap();
      }
          : null,
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: double.infinity,
          height: 50.h,
          decoration: BoxDecoration(
            gradient: widget.enabled
                ? LinearGradient(colors: [
              AppColors.accent[60]!,
              AppColors.accent[70]!,
            ])
                : null,
            color: widget.enabled ? null : Colors.grey.withOpacity(0.2),
            borderRadius: BorderRadius.circular(14.r),
            boxShadow: widget.enabled
                ? [
              BoxShadow(
                color: AppColors.accent[60]!.withOpacity(0.35),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ]
                : null,
          ),
          child: Center(
            child: Text(
              widget.label,
              style: GoogleFonts.cairo(
                fontSize: 15.sp,
                fontWeight: FontWeight.w700,
                color: widget.enabled ? Colors.white : Colors.grey,
              ),
            ),
          ),
        ),
      ),
    );
  }
}