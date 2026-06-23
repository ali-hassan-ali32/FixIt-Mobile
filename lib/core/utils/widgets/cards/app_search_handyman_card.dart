import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../theme/app_colors.dart';

// ══════════════════════════════════════════════════════════════
// AppSearchHandymanCard
// Handyman card used in search results & category browse lists.
// Shows: avatar, name, category, rating, status badge, stats.
//
// Usage:
//   AppSearchHandymanCard(
//     id: 'h1',
//     name: 'محمد علي',
//     category: 'كهربائي محترف',
//     rating: 4.9,
//     reviewCount: 240,
//     yearsExp: 8,
//     hourlyRate: 150,
//     isAvailable: true,
//     avatarColors: [AppColors.primary[60]!, AppColors.secondary[60]!],
//     isDark: isDark,
//     onTap: () {},
//     onBook: () {},
//     availableLabel: 'متاح',
//     busyLabel: 'مشغول',
//     expLabel: 'خبرة',
//     rateLabel: 'بالساعة',
//     currencyLabel: 'ج',
//   )
// ══════════════════════════════════════════════════════════════
class AppSearchHandymanCard extends StatefulWidget {
  final String        id;
  final String        name;
  final String        category;
  final num        rating;
  final int           reviewCount;
  final int           yearsExp;
  final int           hourlyRate;
  final bool          isAvailable;
  final List<Color>   avatarColors;
  final bool          isDark;
  final VoidCallback  onTap;
  final VoidCallback  onBook;
  final String        availableLabel;
  final String        busyLabel;
  final String        expLabel;
  final String        rateLabel;
  final String        currencyLabel;
  final String        bookLabel;

  const AppSearchHandymanCard({
    super.key,
    required this.id,
    required this.name,
    required this.category,
    required this.rating,
    required this.reviewCount,
    required this.yearsExp,
    required this.hourlyRate,
    required this.isAvailable,
    required this.avatarColors,
    required this.isDark,
    required this.onTap,
    required this.onBook,
    required this.availableLabel,
    required this.busyLabel,
    required this.expLabel,
    required this.rateLabel,
    required this.currencyLabel,
    required this.bookLabel,
  });

  @override
  State<AppSearchHandymanCard> createState() => _AppSearchHandymanCardState();
}

class _AppSearchHandymanCardState extends State<AppSearchHandymanCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final textTheme   = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTapDown: widget.isAvailable
          ? (_) => setState(() => _pressed = true)
          : null,
      onTapUp: widget.isAvailable
          ? (_) {
        setState(() => _pressed = false);
        HapticFeedback.selectionClick();
        widget.onTap();
      }
          : null,
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: widget.isAvailable ? 1.0 : 0.55,
        child: AnimatedScale(
          scale: _pressed ? 0.97 : 1.0,
          duration: const Duration(milliseconds: 120),
          child: Container(
            margin: EdgeInsets.only(bottom: 14.h),
            padding: EdgeInsets.all(18.w),
            decoration: BoxDecoration(
              color: widget.isDark ? AppColors.darkSurface : Colors.white,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: AppColors.primary[60]!.withOpacity(0.08),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(widget.isDark ? 0.2 : 0.05),
                  blurRadius: 12,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header row ─────────────────────────────
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Avatar
                    Container(
                      width: 56.w,
                      height: 56.h,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: widget.avatarColors,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                      child: Icon(Icons.person_rounded,
                          size: 28.sp, color: Colors.white),
                    ),
                    SizedBox(width: 14.w),

                    // Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.name,
                                      style: textTheme.bodyLarge?.copyWith(
                                          fontWeight: FontWeight.w700),
                                    ),
                                    SizedBox(height: 2.h),
                                    Text(
                                      widget.category,
                                      style: textTheme.bodySmall?.copyWith(
                                          color: colorScheme.onSurfaceVariant),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: 8.w),
                              // Status badge
                              _StatusBadge(
                                isAvailable: widget.isAvailable,
                                availableLabel: widget.availableLabel,
                                busyLabel: widget.busyLabel,
                              ),
                            ],
                          ),
                          SizedBox(height: 6.h),
                          // Rating
                          _RatingRow(
                            rating: widget.rating,
                            reviewCount: widget.reviewCount,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 14.h),

                // ── Stats + Book button ─────────────────────
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          _StatChip(
                            icon: Icons.work_history_rounded,
                            value: '${widget.yearsExp}',
                            label: widget.expLabel,
                            isDark: widget.isDark,
                          ),
                          SizedBox(width: 10.w),
                          _StatChip(
                            icon: Icons.payments_outlined,
                            value: '${widget.hourlyRate} ${widget.currencyLabel}',
                            label: widget.rateLabel,
                            isDark: widget.isDark,
                          ),
                        ],
                      ),
                    ),

                    // Book button (only when available)
                    if (widget.isAvailable)
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.mediumImpact();
                          widget.onBook();
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 14.w, vertical: 8.h),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.primary[60]!,
                                AppColors.secondary[60]!,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(10.r),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary[60]!
                                    .withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Text(
                            widget.bookLabel,
                            style: GoogleFonts.cairo(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── StatusBadge ───────────────────────────────────────────────
class _StatusBadge extends StatelessWidget {
  final bool   isAvailable;
  final String availableLabel;
  final String busyLabel;

  const _StatusBadge({
    required this.isAvailable,
    required this.availableLabel,
    required this.busyLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: isAvailable
            ? AppColors.accent[60]!.withOpacity(0.12)
            : AppColors.danger.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Text(
        isAvailable ? availableLabel : busyLabel,
        style: GoogleFonts.cairo(
          fontSize: 11.sp,
          fontWeight: FontWeight.w700,
          color: isAvailable ? AppColors.accent[60] : AppColors.danger,
        ),
      ),
    );
  }
}

// ── RatingRow ─────────────────────────────────────────────────
class _RatingRow extends StatelessWidget {
  final num rating;
  final int    reviewCount;

  const _RatingRow({required this.rating, required this.reviewCount});

  @override
  Widget build(BuildContext context) {
    final fullStars = rating.floor();
    final hasHalf   = (rating - fullStars) >= 0.5;

    return Row(
      children: [
        ...List.generate(5, (i) {
          IconData ico;
          if (i < fullStars) {
            ico = Icons.star_rounded;
          } else if (i == fullStars && hasHalf) {
            ico = Icons.star_half_rounded;
          } else {
            ico = Icons.star_outline_rounded;
          }
          return Icon(ico, size: 14.sp, color: AppColors.star);
        }),
        SizedBox(width: 4.w),
        Text(
          '$rating ($reviewCount)',
          style: GoogleFonts.cairo(
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

// ── StatChip ──────────────────────────────────────────────────
class _StatChip extends StatelessWidget {
  final IconData icon;
  final String   value;
  final String   label;
  final bool     isDark;

  const _StatChip({
    required this.icon,
    required this.value,
    required this.label,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14.sp, color: colorScheme.onSurfaceVariant),
        SizedBox(width: 4.w),
        Text(
          value,
          style: GoogleFonts.cairo(
            fontSize: 12.sp,
            fontWeight: FontWeight.w700,
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
        ),
        SizedBox(width: 2.w),
        Text(
          label,
          style: GoogleFonts.cairo(
            fontSize: 11.sp,
            fontWeight: FontWeight.w500,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}