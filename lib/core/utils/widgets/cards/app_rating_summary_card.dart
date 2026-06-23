import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_colors.dart';

// ══════════════════════════════════════════════════════════════
// AppRatingSummaryCard
// Shows overall rating number + stars + 5→1 breakdown bars.
// Used in: handyman reviews view, (future) any rating summary.
//
// Usage:
//   AppRatingSummaryCard(
//     isDark: isDark,
//     overallRating: 4.9,
//     totalCount: 128,
//     totalLabel: l10n.reviewsTotalLabel,   // 'تقييم'
//     breakdown: {5: 115, 4: 8, 3: 3, 2: 2, 1: 1},
//   )
// ══════════════════════════════════════════════════════════════
class AppRatingSummaryCard extends StatefulWidget {
  final bool              isDark;
  final double            overallRating;
  final int               totalCount;
  final String            totalLabel;
  final Map<int, int>     breakdown; // {5: count, 4: count, ...}
  /// Pass AppColors.accent[60] for handyman (teal).
  /// Defaults to AppColors.primary[60] (customer orange).
  final Color?            accentColor;

  const AppRatingSummaryCard({
    super.key,
    required this.isDark,
    required this.overallRating,
    required this.totalCount,
    required this.totalLabel,
    required this.breakdown,
    this.accentColor,
  });

  @override
  State<AppRatingSummaryCard> createState() => _AppRatingSummaryCardState();
}

class _AppRatingSummaryCardState extends State<AppRatingSummaryCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _barCtrl;
  late final Animation<double>   _barAnim;

  @override
  void initState() {
    super.initState();
    _barCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));
    _barAnim =
        CurvedAnimation(parent: _barCtrl, curve: Curves.easeOutCubic);
    // slight delay so bars animate after card appears
    Future.delayed(const Duration(milliseconds: 200),
            () => mounted ? _barCtrl.forward() : null);
  }

  @override
  void dispose() {
    _barCtrl.dispose();
    super.dispose();
  }

  // ── Bars column (shared) ──────────────────────────────────
  Widget _barsColumn(Color accent, Color accentSec, int maxCount,
      TextTheme textTheme, ColorScheme colorScheme) {
    return Column(
      children: List.generate(5, (i) {
        final star  = 5 - i;
        final count = widget.breakdown[star] ?? 0;
        final ratio = maxCount == 0 ? 0.0 : count / maxCount;
        return Padding(
          padding: EdgeInsets.only(bottom: i < 4 ? 7.h : 0),
          child: Row(children: [
            SizedBox(width: 22.w,
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Text('$star', style: GoogleFonts.cairo(
                      fontSize: 11.sp, fontWeight: FontWeight.w700,
                      color: textTheme.bodySmall?.color)),
                  SizedBox(width: 2.w),
                  Icon(Icons.star_rounded,
                      size: 11.sp, color: AppColors.star),
                ])),
            SizedBox(width: 6.w),
            Expanded(child: ClipRRect(
              borderRadius: BorderRadius.circular(4.r),
              child: Container(
                height: 7.h,
                color: accent.withOpacity(0.10),
                child: AnimatedBuilder(
                  animation: _barAnim,
                  builder: (_, __) => FractionallySizedBox(
                    alignment: AlignmentDirectional.centerStart,
                    widthFactor: ratio * _barAnim.value,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                            colors: [accent, accentSec]),
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                    ),
                  ),
                ),
              ),
            )),
            SizedBox(width: 6.w),
            SizedBox(width: 20.w,
                child: Text('$count', style: GoogleFonts.cairo(
                    fontSize: 10.sp, fontWeight: FontWeight.w600,
                    color: colorScheme.onSurfaceVariant),
                    textAlign: TextAlign.start)),
          ]),
        );
      }),
    );
  }

  // ── Full layout (normal width) ────────────────────────────
  Widget _buildFull(Color accent, Color accentSec, int maxCount,
      TextTheme textTheme, ColorScheme colorScheme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Column(mainAxisSize: MainAxisSize.min, children: [
          ShaderMask(
            shaderCallback: (b) => LinearGradient(
                colors: [accent, accentSec]).createShader(b),
            child: Text(widget.overallRating.toStringAsFixed(1),
                style: GoogleFonts.cairo(fontSize: 48.sp,
                    fontWeight: FontWeight.w800,
                    color: Colors.white, height: 1.0)),
          ),
          SizedBox(height: 6.h),
          Row(mainAxisSize: MainAxisSize.min,
              children: List.generate(5, (i) {
                final full = i < widget.overallRating.floor();
                final half = !full && i < widget.overallRating &&
                    widget.overallRating - i >= 0.5;
                return Icon(
                  full ? Icons.star_rounded
                      : half ? Icons.star_half_rounded
                      : Icons.star_outline_rounded,
                  size: 16.sp, color: AppColors.star,
                );
              })),
          SizedBox(height: 6.h),
          Text('${widget.totalCount} ${widget.totalLabel}',
              style: GoogleFonts.cairo(fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurfaceVariant)),
        ]),
        SizedBox(width: 20.w),
        Expanded(child: _barsColumn(
            accent, accentSec, maxCount, textTheme, colorScheme)),
      ],
    );
  }

  // ── Compact layout (narrow sidebar) ──────────────────────
  // Rating badge on top row + bars below
  Widget _buildCompact(Color accent, Color accentSec, int maxCount,
      TextTheme textTheme, ColorScheme colorScheme) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Top row: big number + stars + count
      Row(children: [
        ShaderMask(
          shaderCallback: (b) => LinearGradient(
              colors: [accent, accentSec]).createShader(b),
          child: Text(widget.overallRating.toStringAsFixed(1),
              style: GoogleFonts.cairo(fontSize: 34.sp,
                  fontWeight: FontWeight.w800,
                  color: Colors.white, height: 1.0)),
        ),
        SizedBox(width: 10.w),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisSize: MainAxisSize.min,
              children: List.generate(5, (i) {
                final full = i < widget.overallRating.floor();
                final half = !full && i < widget.overallRating &&
                    widget.overallRating - i >= 0.5;
                return Icon(
                  full ? Icons.star_rounded
                      : half ? Icons.star_half_rounded
                      : Icons.star_outline_rounded,
                  size: 13.sp, color: AppColors.star,
                );
              })),
          SizedBox(height: 3.h),
          Text('${widget.totalCount} ${widget.totalLabel}',
              style: GoogleFonts.cairo(fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurfaceVariant)),
        ]),
      ]),
      SizedBox(height: 12.h),
      // Full-width bars
      _barsColumn(accent, accentSec, maxCount, textTheme, colorScheme),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme   = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final accent      = widget.accentColor ?? AppColors.primary[60]!;
    final accentSec   = widget.accentColor != null
        ? widget.accentColor!.withOpacity(0.82)
        : AppColors.secondary[60]!;
    final maxCount    = widget.breakdown.values.isEmpty
        ? 1
        : widget.breakdown.values.reduce((a, b) => a > b ? a : b);

    return LayoutBuilder(
      builder: (_, constraints) {
        // Compact mode when card is narrower than 280px (sidebar use)
        final isCompact = constraints.maxWidth < 280;
        return Container(
          padding: EdgeInsets.all(isCompact ? 14.w : 20.w),
          decoration: BoxDecoration(
            color: widget.isDark ? AppColors.darkSurface : Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: accent.withOpacity(0.08)),
            boxShadow: [
              BoxShadow(
                color: Colors.black
                    .withOpacity(widget.isDark ? 0.15 : 0.05),
                blurRadius: 12, offset: const Offset(0, 2),
              ),
            ],
          ),
          child: isCompact
              ? _buildCompact(accent, accentSec, maxCount, textTheme,
              colorScheme)
              : _buildFull(accent, accentSec, maxCount, textTheme,
              colorScheme),
        );
      },
    );
  }
}