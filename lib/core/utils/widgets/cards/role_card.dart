import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_shadows.dart';
import '../../../theme/app_sizes.dart';
import '../feature_badge.dart';

class RoleCard extends StatefulWidget {
  final LinearGradient gradient;
  final IconData icon;
  final String title;
  final String subtitle;
  final String description;
  final List<String> features;
  final String? note;
  final VoidCallback onTap;

  const RoleCard({super.key,
    required this.gradient,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.features,
    required this.onTap,
    this.note,
  });

  @override
  State<RoleCard> createState() => _RoleCardState();
}

class _RoleCardState extends State<RoleCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final textTheme   = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

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
          padding: EdgeInsets.all(AppSpacing.xl.w),
          decoration: BoxDecoration(
            color: _isPressed
                ? AppColors.primary[60]!.withOpacity(0.05)
                : colorScheme.surface,
            borderRadius: BorderRadius.all(AppRadius.lg),
            border: Border.all(
              color: _isPressed
                  ? AppColors.primary[60]!
                  : colorScheme.outline,
              width: 2,
            ),
            boxShadow: _isPressed ? AppShadows.md : AppShadows.sm,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header Row ────────────────────────────
              Row(
                children: [
                  // Icon
                  Container(
                    width: 56.w,
                    height: 56.h,
                    decoration: BoxDecoration(
                      gradient: widget.gradient,
                      borderRadius: BorderRadius.all(AppRadius.md),
                    ),
                    child: Icon(
                      widget.icon,
                      color: Colors.white,
                      size: 28.sp,
                    ),
                  ),
                  SizedBox(width: 16.w),

                  // Title + Subtitle
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: textTheme.displaySmall,
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          widget.subtitle,
                          style: textTheme.bodyLarge?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Arrow (RTL aware)
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16.sp,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
              SizedBox(height: 12.h),

              // ── Description ───────────────────────────
              Text(
                widget.description,
                style: textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.6,
                ),
              ),
              SizedBox(height: 12.h),

              // ── Feature Badges ────────────────────────
              Wrap(
                spacing: 8.w,
                runSpacing: 8.h,
                children: widget.features
                    .map((f) => FeatureBadge(label: f))
                    .toList(),
              ),

              // ── Note (handyman only) ──────────────────
              if (widget.note != null) ...[
                SizedBox(height: 12.h),
                Text(
                  widget.note!,
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}