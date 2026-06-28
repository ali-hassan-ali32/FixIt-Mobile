import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/l10n/translation/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/utils/widgets/app_main_background.dart';
import '../../../../core/utils/widgets/app_empty_states.dart';
import '../../../../core/utils/widgets/cards/app_rating_summary_card.dart';
import '../../../../core/utils/widgets/buttons/app_back_button.dart';
import '../../domain/entities/handyman_review_entity.dart';
import '../cubit/handyman_cubit.dart';
import '../cubit/handyman_state.dart';


// ══════════════════════════════════════════════════════════════
// HandymanOwnReviewsView — layout router
// ══════════════════════════════════════════════════════════════
class HandymanOwnReviewsView extends StatelessWidget {
  const HandymanOwnReviewsView({super.key});

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (_, c) => c.maxWidth >= 600
        ? const _HandymanReviewsTabletBody()
        : const _HandymanReviewsMobileBody(),
  );
}

// ══════════════════════════════════════════════════════════════
// Shared base
// ══════════════════════════════════════════════════════════════
abstract class _ReviewsBase<T extends StatefulWidget> extends State<T>
    with TickerProviderStateMixin {
  Color get teal => AppColors.accent[60]!;
  int filterStars = 0; // 0 = all

  List<HandymanReviewEntity> reviews = [];

  late final AnimationController masterCtrl;
  late final List<Animation<double>> fadeAnims;
  late final List<Animation<Offset>> slideAnims;

  static const int sectionCount = 6;

  List<HandymanReviewEntity> get filtered => filterStars == 0
      ? reviews
      : reviews.where((r) => r.rating == filterStars).toList();

  @override
  void initState() {
    super.initState();

    context.read<HandymanCubit>().getReviews();

    masterCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 850),
    )..forward();

    fadeAnims = List.generate(sectionCount, (i) {
      final start = i * 0.14;
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: masterCtrl,
          curve: Interval(
            start.clamp(0.0, 1.0),
            (start + 0.4).clamp(0.0, 1.0),
            curve: Curves.easeOut,
          ),
        ),
      );
    });

    slideAnims = List.generate(sectionCount, (i) {
      final start = i * 0.14;
      return Tween<Offset>(
        begin: const Offset(0, 0.14),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: masterCtrl,
          curve: Interval(
            start.clamp(0.0, 1.0),
            (start + 0.45).clamp(0.0, 1.0),
            curve: Curves.easeOutCubic,
          ),
        ),
      );
    });
  }

  @override
  void dispose() {
    masterCtrl.dispose();
    super.dispose();
  }

  Widget animated(int i, Widget child) => FadeTransition(
    opacity: fadeAnims[i.clamp(0, sectionCount - 1)],
    child: SlideTransition(
      position: slideAnims[i.clamp(0, sectionCount - 1)],
      child: child,
    ),
  );

  // ── Header ───────────────────────────────────────────────
  Widget buildHeader(
    bool isDark,
    AppLocalizations l10n,
    Color accent,
    TextTheme textTheme,
    BuildContext context,
  ) {
    final top = MediaQuery.of(context).padding.top;
    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg.w,
        top + AppSpacing.md.h,
        AppSpacing.lg.w,
        AppSpacing.md.h,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white.withOpacity(0.95),
        border: Border(bottom: BorderSide(color: accent.withOpacity(0.10))),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          AppBackButton(isDark: isDark, tapColor: accent),
          SizedBox(width: 14.w),
          Text(
            l10n.reviewsTitle,
            style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }

  // ── Rating summary ───────────────────────────────────────
  Widget buildRatingSummary(bool isDark, AppLocalizations l10n) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.xl.w,
        AppSpacing.lg.h,
        AppSpacing.xl.w,
        0,
      ),
      child: AppRatingSummaryCard(
        isDark: isDark,
        overallRating: averageRating,
        totalCount: reviews.length,
        accentColor: teal,
        totalLabel: l10n.reviewsTotalLabel,
        breakdown: breakdown,
      )
    );
  }

  // ── Filter chips ─────────────────────────────────────────

  double get averageRating {
    if (reviews.isEmpty) return 0;

    final total = reviews.fold<double>(
      0, (sum, review) => sum + review.rating.toDouble(),
    );

    return total / reviews.length;
  }

  Map<int, int> get breakdown {
    return {
      5: reviews.where((r) => r.rating == 5).length,
      4: reviews.where((r) => r.rating == 4).length,
      3: reviews.where((r) => r.rating == 3).length,
      2: reviews.where((r) => r.rating == 2).length,
      1: reviews.where((r) => r.rating == 1).length,
    };
  }

  Widget buildFilterChips(bool isDark, AppLocalizations l10n) {
    final filters = [
      (0, l10n.notifFilterAll),
      (5, l10n.reviews5Stars),
      (4, l10n.reviews4Stars),
      (3, l10n.reviews3Stars),
      (2, l10n.reviews2Stars),
      (1, l10n.reviews1Star),
    ];

    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.lg.h),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl.w),
        child: Row(
          children: filters.map((f) {
            final isActive = filterStars == f.$1;
            return Padding(
              padding: EdgeInsets.only(left: 8.w),
              child: _FilterChip(
                label: f.$2,
                isActive: isActive,
                accent: teal,
                isDark: isDark,
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() => filterStars = f.$1);
                },
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  // ── Review card ──────────────────────────────────────────
  Widget buildReviewCard(HandymanReviewEntity  review, bool isDark, Color accent) {
    return _ReviewCard(review: review, isDark: isDark, accent: accent);
  }

  // ── Empty state ──────────────────────────────────────────
  Widget buildEmptyState(AppLocalizations l10n, Color accent) {
    return AppEmptyState(
      color: accent,
      icon: Icons.star_border_rounded,
      title: l10n.reviewsEmptyTitle,
      subtitle: l10n.reviewsEmptySubtitle,
    );
  }
}

// ══════════════════════════════════════════════════════════════
// Mobile Body
// ══════════════════════════════════════════════════════════════
class _HandymanReviewsMobileBody extends StatefulWidget {
  const _HandymanReviewsMobileBody();
  @override
  State<_HandymanReviewsMobileBody> createState() =>
      _HandymanReviewsMobileBodyState();
}

class _HandymanReviewsMobileBodyState
    extends _ReviewsBase<_HandymanReviewsMobileBody> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;

    return BlocBuilder<HandymanCubit, HandymanState>(
        builder: (context, state) {
          if (state is HandymanReviewsLoaded) {
            reviews = state.reviews;
          }

          final filtered = super.filtered;


          if (state is HandymanLoading) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          if (state is HandymanError) {
            return Scaffold(
              body: Center(
                child: Text(state.message),
              ),
            );
          }

          return Scaffold(
            backgroundColor: isDark
                ? AppColors.darkBgPrimary
                : const Color(0xFFF0F7F8),
            body: AppMainBackground(
              child: CustomScrollView(
                slivers: [
                  // ── Header ──────────────────────────────────────
                  SliverToBoxAdapter(
                    child: animated(
                      0,
                      buildHeader(isDark, l10n, teal, textTheme, context),
                    ),
                  ),

                  // ── Rating summary ───────────────────────────────
                  SliverToBoxAdapter(
                    child: animated(1, buildRatingSummary(isDark, l10n)),
                  ),

                  // ── Filter chips ─────────────────────────────────
                  SliverToBoxAdapter(
                    child: animated(2, buildFilterChips(isDark, l10n)),
                  ),

                  // ── Reviews list or empty ────────────────────────
                  filtered.isEmpty
                      ? SliverToBoxAdapter(
                    child: animated(3, buildEmptyState(l10n, teal)),
                  )
                      : SliverPadding(
                    padding: EdgeInsets.fromLTRB(
                      AppSpacing.xl.w,
                      0,
                      AppSpacing.xl.w,
                      40.h,
                    ),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                            (ctx, i) =>
                            animated(
                              (i + 3).clamp(0, _ReviewsBase.sectionCount - 1),
                              Padding(
                                padding: EdgeInsets.only(bottom: 14.h),
                                child: buildReviewCard(
                                    filtered[i], isDark, teal),
                              ),
                            ),
                        childCount: filtered.length,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
    );
  }
}

// ══════════════════════════════════════════════════════════════
// Tablet Body — two-column layout
// ══════════════════════════════════════════════════════════════
class _HandymanReviewsTabletBody extends StatefulWidget {
  const _HandymanReviewsTabletBody();
  @override
  State<_HandymanReviewsTabletBody> createState() =>
      _HandymanReviewsTabletBodyState();
}

class _HandymanReviewsTabletBodyState
    extends _ReviewsBase<_HandymanReviewsTabletBody> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;



    return BlocBuilder<HandymanCubit, HandymanState>(
      builder: (context, state) {

        state.whenOrNull(
          reviewsLoaded: (data) {
            reviews = data;
          },
        );

        if (state is HandymanLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        final filtered = super.filtered;


        return Scaffold(
          backgroundColor: Colors.transparent,
          body: AppMainBackground(
        child: SafeArea(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Left panel (38%) ───────────────────────────
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.38,
                child: CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: animated(
                        0,
                        _buildTabletHeaderCard(context, isDark, l10n),
                      ),
                    ),
                    SliverToBoxAdapter(child: SizedBox(height: 32.h)),
                  ],
                ),
              ),

              VerticalDivider(width: 1, color: teal.withOpacity(0.10)),

              // ── Right panel (62%) ──────────────────────────
              Expanded(
                child: CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: animated(1, buildFilterChips(isDark, l10n)),
                    ),
                    filtered.isEmpty
                        ? SliverToBoxAdapter(
                            child: animated(2, buildEmptyState(l10n, teal)),
                          )
                        : SliverPadding(
                            padding: EdgeInsets.fromLTRB(
                              AppSpacing.xl.w,
                              0,
                              AppSpacing.xl.w,
                              40.h,
                            ),
                            sliver: SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (ctx, i) => animated(
                                  (i + 2).clamp(
                                    0,
                                    _ReviewsBase.sectionCount - 1,
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(bottom: 14.h),
                                    child: buildReviewCard(
                                      filtered[i],
                                      isDark,
                                      teal,
                                    ),
                                  ),
                                ),
                                childCount: filtered.length,
                              ),
                            ),
                          ),
                  ],
                ),
              ),
            ],
          ),
        ),
      )
        );
      }
    );
  }

  Widget _buildTabletHeaderCard(
    BuildContext context,
    bool isDark,
    AppLocalizations l10n,
  ) {
    return Container(
      margin: EdgeInsets.all(AppSpacing.xl.w),
      padding: EdgeInsets.all(AppSpacing.xl.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [teal, AppColors.accent[70] ?? const Color(0xFF44A3A0)],
        ),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: teal.withOpacity(0.25),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AppBackButton(isDark: false, tapColor: Colors.white),
              SizedBox(width: 14.w),
              Expanded(
                child: Text(
                  l10n.reviewsTitle,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),

          // Big rating
          Center(
            child: Column(
              children: [
                Text(
                  averageRating.toStringAsFixed(1),
                  style: GoogleFonts.cairo(
                    fontSize: 48.sp,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4.h),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(
                    5,
                    (i) => Icon(
                      Icons.star_rounded,
                      size: 24.sp,
                      color: Colors.white,
                    ),
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  '235 ${l10n.reviewsTotalLabel}',
                  style: GoogleFonts.cairo(
                    fontSize: 14.sp,
                    color: Colors.white.withOpacity(0.85),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 24.h),

          // Breakdown bars
          ...[5, 4, 3, 2, 1].map(
                (stars) => _RatingBar(
              stars: stars,
              count: breakdown[stars] ?? 0,
              total: reviews.isEmpty ? 1 : reviews.length,
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// Reusable Widgets
// ══════════════════════════════════════════════════════════════

class _RatingBar extends StatelessWidget {
  final int stars;
  final int count;
  final int total;

  const _RatingBar({
    required this.stars,
    required this.count,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = count / total;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        children: [
          Text(
            '$stars',
            style: GoogleFonts.cairo(fontSize: 12.sp, color: Colors.white),
          ),
          SizedBox(width: 4.w),
          Icon(Icons.star_rounded, size: 14.sp, color: Colors.white),
          SizedBox(width: 8.w),
          Expanded(
            child: LayoutBuilder(
              builder: (_, c) {
                return Stack(
                  children: [
                    Container(
                      height: 6.h,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(3.r),
                      ),
                    ),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 600),
                      width: c.maxWidth * percentage,
                      height: 6.h,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(3.r),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          SizedBox(width: 8.w),
          SizedBox(
            width: 30.w,
            child: Text(
              '$count',
              style: GoogleFonts.cairo(fontSize: 11.sp, color: Colors.white),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatefulWidget {
  final String label;
  final bool isActive;
  final Color accent;
  final bool isDark;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isActive,
    required this.accent,
    required this.isDark,
    required this.onTap,
  });

  @override
  State<_FilterChip> createState() => _FilterChipState();
}

class _FilterChipState extends State<_FilterChip>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 100),
  );
  late final Animation<double> _scale = Tween<double>(
    begin: 1.0,
    end: 0.93,
  ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        widget.onTap();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 9.h),
          decoration: BoxDecoration(
            gradient: widget.isActive
                ? LinearGradient(
                    colors: [widget.accent, widget.accent.withOpacity(0.82)],
                  )
                : null,
            color: widget.isActive
                ? null
                : (widget.isDark ? AppColors.darkSurface : Colors.white),
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(
              color: widget.isActive
                  ? Colors.transparent
                  : widget.accent.withOpacity(0.20),
              width: 1.5,
            ),
            boxShadow: widget.isActive
                ? [
                    BoxShadow(
                      color: widget.accent.withOpacity(0.25),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : [],
          ),
          child: Text(
            widget.label,
            style: GoogleFonts.cairo(
              fontSize: 13.sp,
              fontWeight: FontWeight.w700,
              color: widget.isActive
                  ? Colors.white
                  : (widget.isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.textSecondary),
            ),
          ),
        ),
      ),
    );
  }
}

class _ReviewCard extends StatefulWidget {
  final HandymanReviewEntity review;
  final bool isDark;
  final Color accent;

  const _ReviewCard({
    required this.review,
    required this.isDark,
    required this.accent,
  });

  @override
  State<_ReviewCard> createState() => _ReviewCardState();
}

class _ReviewCardState extends State<_ReviewCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pressCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 100),
  );
  late final Animation<double> _scale = Tween<double>(
    begin: 1.0,
    end: 0.985,
  ).animate(CurvedAnimation(parent: _pressCtrl, curve: Curves.easeOut));

  @override
  void dispose() {
    _pressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final r = widget.review;
    final accent = widget.accent;

    final cardBg = widget.isDark ? AppColors.darkSurface : Colors.white;

    return GestureDetector(
      onTapDown: (_) => _pressCtrl.forward(),
      onTapUp: (_) => _pressCtrl.reverse(),
      onTapCancel: () => _pressCtrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          padding: EdgeInsets.all(18.w),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: widget.isDark
                  ? AppColors.darkBorder
                  : accent.withOpacity(0.08),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(widget.isDark ? 0.20 : 0.05),
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
                children: [
                  // Avatar
                  Container(
                    width: 44.w,
                    height: 44.w,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.accent[60]!,
                          AppColors.accent[60]!,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Center(
                      child: Text(
                        r.customerName.isNotEmpty
                            ? r.customerName.substring(0, 1).toUpperCase()
                            : '?',
                        style: GoogleFonts.cairo(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  // Name + date
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          r.customerName,
                          style: textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          '${r.createdAt.day}/${r.createdAt.month}/${r.createdAt.year}',                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),

              // ── Stars ──────────────────────────────────
              Row(
                children: List.generate(
                  5,
                  (i) => Padding(
                    padding: EdgeInsets.only(left: 2.w),
                    child: Icon(
                      i < r.rating
                          ? Icons.star_rounded
                          : Icons.star_outline_rounded,
                      size: 18.sp,
                      color: i < r.rating
                          ? AppColors.star
                          : colorScheme.onSurfaceVariant.withOpacity(0.3),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10.h),

              // ── Text ───────────────────────────────────
              Text(
                r.comment,
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.6,
                ),
              ),
              SizedBox(height: 12.h),

              // ── Footer ─────────────────────────────────
              // Container(
              //   padding: EdgeInsets.only(top: 12.h),
              //   decoration: BoxDecoration(
              //     border: Border(
              //       top: BorderSide(color: accent.withOpacity(0.08)),
              //     ),
              //   ),
              //   child: Container(
              //     padding: EdgeInsets.symmetric(
              //       horizontal: 12.w,
              //       vertical: 5.h,
              //     ),
              //     decoration: BoxDecoration(
              //       color: accent.withOpacity(0.09),
              //       borderRadius: BorderRadius.circular(10.r),
              //     ),
              //     child: Text(
              //       'r.jobTag',
              //       style: GoogleFonts.cairo(
              //         fontSize: 12.sp,
              //         fontWeight: FontWeight.w700,
              //         color: accent,
              //       ),
              //     ),
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
