import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_shadows.dart';
import '../../../theme/app_sizes.dart';
// ══════════════════════════════════════════════════════════════
// Handyman Model
// ══════════════════════════════════════════════════════════════
class HandymanModel {
  final String id;
  final String name;
  final String specialty;
  final double rating;
  final int reviewCount;
  final double hourlyRate;
  final List<Color> avatarGradient;

  const HandymanModel({
    required this.id,
    required this.name,
    required this.specialty,
    required this.rating,
    required this.reviewCount,
    required this.hourlyRate,
    required this.avatarGradient,
  });
}

// ══════════════════════════════════════════════════════════════
// AppHandymanCard
// ══════════════════════════════════════════════════════════════
class AppHandymanCard extends StatefulWidget {
  final HandymanModel handyman;
  final VoidCallback onTap;
  final VoidCallback onBook;
  final String bookLabel;
  final String hourlyRateLabel;
  final String reviewsLabel;

  const AppHandymanCard({
    super.key,
    required this.handyman,
    required this.onTap,
    required this.onBook,
    required this.bookLabel,
    required this.hourlyRateLabel,
    required this.reviewsLabel,
  });

  @override
  State<AppHandymanCard> createState() => _AppHandymanCardState();
}

class _AppHandymanCardState extends State<AppHandymanCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final textTheme   = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final isDark      = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTapDown:   (_) => setState(() => _isPressed = true),
      onTapUp:     (_) => setState(() => _isPressed = false),
      onTapCancel: ()  => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _isPressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.all(AppSpacing.md.w),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : Colors.white,
            borderRadius: BorderRadius.all(AppRadius.lg),
            border: Border.all(color: AppColors.primary[60]!.withOpacity(0.08)),
            boxShadow: _isPressed ? AppShadows.sm : AppShadows.md,
          ),
          child: Column(
            children: [
              Row(
                children: [
                  // ── Avatar ──────────────────────────────
                  Container(
                    width: 60.w,
                    height: 60.h,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: widget.handyman.avatarGradient,
                      ),
                      borderRadius: BorderRadius.all(AppRadius.md),
                    ),
                    child: Icon(Icons.person_outline_rounded,
                        color: Colors.white, size: 28.sp),
                  ),
                  SizedBox(width: 12.w),

                  // ── Info ────────────────────────────────
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.handyman.name,
                            style: textTheme.bodyLarge
                                ?.copyWith(fontWeight: FontWeight.w700)),
                        SizedBox(height: 3.h),
                        Text(widget.handyman.specialty,
                            style: textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant)),
                        SizedBox(height: 6.h),
                        Row(
                          children: [
                            Icon(Icons.star_rounded,
                                color: AppColors.secondary[60], size: 16.sp),
                            SizedBox(width: 4.w),
                            Text(
                              widget.handyman.rating.toStringAsFixed(1),
                              style: textTheme.bodySmall
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              '(${widget.handyman.reviewCount} ${widget.reviewsLabel})',
                              style: textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              Divider(color: colorScheme.outlineVariant, height: 1),
              SizedBox(height: 12.h),

              // ── Bottom Row ─────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text:
                          '${widget.handyman.hourlyRate.toStringAsFixed(0)} ',
                          style: textTheme.bodyLarge?.copyWith(
                            color: AppColors.primary[60],
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        TextSpan(
                          text: widget.hourlyRateLabel,
                          style: textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                  _BookButton(
                      label: widget.bookLabel,
                      onTap: widget.onBook,
                      textTheme: textTheme),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Book Button ───────────────────────────────────────────────
class _BookButton extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  final TextTheme textTheme;

  const _BookButton(
      {required this.label, required this.onTap, required this.textTheme});

  @override
  State<_BookButton> createState() => _BookButtonState();
}

class _BookButtonState extends State<_BookButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown:   (_) => setState(() => _isPressed = true),
      onTapUp:     (_) => setState(() => _isPressed = false),
      onTapCancel: ()  => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _isPressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.lg.w, vertical: AppSpacing.xs.h),
          decoration: BoxDecoration(
            gradient: LinearGradient(
                colors: [AppColors.primary[60]!, AppColors.secondary[60]!]),
            borderRadius: BorderRadius.all(AppRadius.md),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary[60]!.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Text(widget.label,
              style: widget.textTheme.labelMedium
                  ?.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
        ),
      ),
    );
  }
}