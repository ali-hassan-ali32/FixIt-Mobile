import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/l10n/translation/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/utils/widgets/app_main_background.dart';
import '../../../../core/utils/widgets/app_empty_states.dart';
import '../../../../core/utils/widgets/app_page_header.dart';
import '../../../../core/utils/widgets/app_rating_star.dart';
import '../../../../core/utils/widgets/cards/app_rating_summary_card.dart';

// ── Model ─────────────────────────────────────────────────────
class ReviewItemModel {
  final String customerName;
  final double rating;
  final String text;
  final String date;
  final String jobTag;
  final List<Color> avatarColors;

  const ReviewItemModel({
    required this.customerName,
    required this.rating,
    required this.text,
    required this.date,
    required this.jobTag,
    required this.avatarColors,
  });
}

final _kReviews = [
  ReviewItemModel(
    customerName: 'أحمد محمود',
    rating: 5,
    text:
        'عمل ممتاز وسريع، المشكلة تم حلها بشكل نهائي. الفني محترف جداً وملتزم بالمواعيد.',
    date: 'منذ يومين',
    jobTag: 'سباكة - صيانة عامة',
    avatarColors: [const Color(0xFF667eea), const Color(0xFF764ba2)],
  ),
  ReviewItemModel(
    customerName: 'سارة أحمد',
    rating: 5,
    text: 'محترف وملتزم بالمواعيد. تم تركيب السخان بشكل ممتاز ونظيف.',
    date: 'منذ 3 أيام',
    jobTag: 'سباكة - تركيب سخان',
    avatarColors: [const Color(0xFFe74c3c), const Color(0xFFc0392b)],
  ),
  ReviewItemModel(
    customerName: 'محمد عبدالله',
    rating: 4,
    text: 'ممتاز! وجد التسريب بسرعة وأصلحه. الخدمة جيدة جداً.',
    date: 'منذ أسبوع',
    jobTag: 'سباكة - كشف تسريب',
    avatarColors: [const Color(0xFF9b59b6), const Color(0xFF8e44ad)],
  ),
];

// ══════════════════════════════════════════════════════════════
// CustomerViewHandymanReviewsView — layout router
// ══════════════════════════════════════════════════════════════
class CustomerViewHandymanReviewsView extends StatelessWidget {
  final String handymanId;
  const CustomerViewHandymanReviewsView({super.key, required this.handymanId});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, c) => c.maxWidth >= 600
          ? _ReviewsTabletBody(handymanId: handymanId)
          : _ReviewsMobileBody(handymanId: handymanId),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// Shared base
// ══════════════════════════════════════════════════════════════
abstract class _ReviewsBase<T extends StatefulWidget> extends State<T>
    with TickerProviderStateMixin {
  String get handymanId;
  Color get accent => AppColors.primary[60]!;

  int? activeFilter;

  final List<ReviewItemModel> allReviews = _kReviews;
  final double overallRating = 4.9;
  final int totalCount = 128;
  final Map<int, int> breakdown = {5: 115, 4: 8, 3: 3, 2: 2, 1: 1};

  // Entry
  late final AnimationController entryCtrl;
  late final Animation<double> entryFade;

  @override
  void initState() {
    super.initState();
    entryCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    entryFade = CurvedAnimation(parent: entryCtrl, curve: Curves.easeOut);
    entryCtrl.forward();
  }

  @override
  void dispose() {
    entryCtrl.dispose();
    super.dispose();
  }

  List<ReviewItemModel> get filtered => activeFilter == null
      ? allReviews
      : allReviews.where((r) => r.rating.floor() == activeFilter).toList();

  Widget buildFilterChips(bool isDark, AppLocalizations l10n) {
    final labels = [
      l10n.filterAll,
      l10n.reviews5Stars,
      l10n.reviews4Stars,
      l10n.reviews3Stars,
      l10n.reviews2Stars,
      l10n.reviews1Star,
    ];
    final values = [null, 5, 4, 3, 2, 1];

    return SizedBox(
      height: 44.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.xl.w,
          vertical: 4.h,
        ),
        itemCount: labels.length,
        separatorBuilder: (_, __) => SizedBox(width: 8.w),
        itemBuilder: (_, i) {
          final isActive = activeFilter == values[i];
          return GestureDetector(
            onTap: () => setState(() => activeFilter = values[i]),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 6.h),
              decoration: BoxDecoration(
                gradient: isActive
                    ? LinearGradient(colors: [accent, AppColors.secondary[60]!])
                    : null,
                color: isActive
                    ? null
                    : isDark
                    ? AppColors.darkSurface
                    : Colors.white,
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(
                  color: isActive
                      ? Colors.transparent
                      : accent.withOpacity(0.20),
                  width: 1.5,
                ),
                boxShadow: isActive
                    ? [
                        BoxShadow(
                          color: accent.withOpacity(0.28),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Text(
                labels[i],
                style: GoogleFonts.cairo(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                  color: isActive
                      ? Colors.white
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// Mobile
// ══════════════════════════════════════════════════════════════
class _ReviewsMobileBody extends StatefulWidget {
  final String handymanId;
  const _ReviewsMobileBody({required this.handymanId});

  @override
  State<_ReviewsMobileBody> createState() => _ReviewsMobileBodyState();
}

class _ReviewsMobileBodyState extends _ReviewsBase<_ReviewsMobileBody> {
  @override
  String get handymanId => widget.handymanId;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    final items = filtered;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppMainBackground(
        child: Column(
          children: [
            AppPageHeader(
              isDark: isDark,
              accentColor: accent,
              title: l10n.reviewsTitle,
            ),
            Expanded(
              child: FadeTransition(
                opacity: entryFade,
                child: CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                          AppSpacing.xl.w,
                          AppSpacing.xl.h,
                          AppSpacing.xl.w,
                          AppSpacing.sm.h,
                        ),
                        child: AppRatingSummaryCard(
                          isDark: isDark,
                          overallRating: overallRating,
                          totalCount: totalCount,
                          totalLabel: l10n.reviewsTotalLabel,
                          breakdown: breakdown,
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(child: buildFilterChips(isDark, l10n)),

                    if (items.isEmpty)
                      SliverFillRemaining(
                        child: Center(
                          child: AppEmptyState(
                            icon: Icons.star_outline_rounded,
                            title: l10n.reviewsEmptyTitle,
                            subtitle: l10n.reviewsEmptySubtitle,
                            color: accent,
                          ),
                        ),
                      )
                    else
                      SliverPadding(
                        padding: EdgeInsets.fromLTRB(
                          AppSpacing.xl.w,
                          0,
                          AppSpacing.xl.w,
                          MediaQuery.of(context).padding.bottom + 32.h,
                        ),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (_, i) => _ReviewCard(
                              review: items[i],
                              index: i,
                              isDark: isDark,
                            ),
                            childCount: items.length,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// Tablet — summary + filters sidebar (30%) | cards (70%)
// ══════════════════════════════════════════════════════════════
class _ReviewsTabletBody extends StatefulWidget {
  final String handymanId;
  const _ReviewsTabletBody({required this.handymanId});

  @override
  State<_ReviewsTabletBody> createState() => _ReviewsTabletBodyState();
}

class _ReviewsTabletBodyState extends _ReviewsBase<_ReviewsTabletBody> {
  @override
  String get handymanId => widget.handymanId;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    final items = filtered;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppMainBackground(
        child: Column(
          children: [
            AppPageHeader(
              isDark: isDark,
              accentColor: accent,
              title: l10n.reviewsTitle,
            ),
            Expanded(
              child: FadeTransition(
                opacity: entryFade,
                child: Row(
                  children: [
                    // Sidebar: summary + filter (30%)
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.36,
                      height: double.infinity,
                      child: Container(
                        alignment: Alignment.center,
                        color: isDark
                            ? AppColors.darkBgSecondary.withOpacity(0.60)
                            : Colors.white.withOpacity(0.70),
                        child: SingleChildScrollView(
                          padding: EdgeInsets.all(AppSpacing.md.w),
                          child: Column(
                            children: [
                              SizedBox(
                                width: double.infinity,
                                child: AppRatingSummaryCard(
                                  isDark: isDark,
                                  overallRating: overallRating,
                                  totalCount: totalCount,
                                  totalLabel: l10n.reviewsTotalLabel,
                                  breakdown: breakdown,
                                ),
                              ),
                              SizedBox(height: 16.h),
                              // Vertical filter list
                              ...[null, 5, 4, 3, 2, 1].asMap().entries.map((e) {
                                final filter = e.value;
                                final label = [
                                  l10n.filterAll,
                                  l10n.reviews5Stars,
                                  l10n.reviews4Stars,
                                  l10n.reviews3Stars,
                                  l10n.reviews2Stars,
                                  l10n.reviews1Star,
                                ][e.key];
                                final isActive = activeFilter == filter;
                                return GestureDetector(
                                  onTap: () =>
                                      setState(() => activeFilter = filter),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    margin: EdgeInsets.only(bottom: 8.h),
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 14.w,
                                      vertical: 10.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isActive
                                          ? accent.withOpacity(0.10)
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(12.r),
                                      border: Border.all(
                                        color: isActive
                                            ? accent.withOpacity(0.30)
                                            : Colors.transparent,
                                      ),
                                    ),
                                    child: Text(
                                      label,
                                      style: GoogleFonts.cairo(
                                        fontSize: 13.sp,
                                        fontWeight: isActive
                                            ? FontWeight.w700
                                            : FontWeight.w500,
                                        color: isActive
                                            ? accent
                                            : Theme.of(
                                                context,
                                              ).colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                      ),
                    ),

                    VerticalDivider(width: 1, color: accent.withOpacity(0.08)),

                    // Cards (70%)
                    Expanded(
                      child: items.isEmpty
                          ? Center(
                              child: AppEmptyState(
                                icon: Icons.star_outline_rounded,
                                title: l10n.reviewsEmptyTitle,
                                subtitle: l10n.reviewsEmptySubtitle,
                                color: accent,
                              ),
                            )
                          : ListView.builder(
                              padding: EdgeInsets.fromLTRB(
                                AppSpacing.xl.w,
                                AppSpacing.md.h,
                                AppSpacing.xl.w,
                                32.h,
                              ),
                              itemCount: items.length,
                              itemBuilder: (_, i) => _ReviewCard(
                                review: items[i],
                                index: i,
                                isDark: isDark,
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// _ReviewCard — stagger entry + slide
// ══════════════════════════════════════════════════════════════
class _ReviewCard extends StatefulWidget {
  final ReviewItemModel review;
  final int index;
  final bool isDark;
  const _ReviewCard({
    required this.review,
    required this.index,
    required this.isDark,
  });

  @override
  State<_ReviewCard> createState() => _ReviewCardState();
}

class _ReviewCardState extends State<_ReviewCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 320 + widget.index * 60),
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: Container(
          margin: EdgeInsets.only(top: 12.h),
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: widget.isDark ? AppColors.darkSurface : Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: AppColors.primary[60]!.withOpacity(0.08)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(widget.isDark ? 0.15 : 0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44.w,
                    height: 44.w,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: widget.review.avatarColors,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Icon(
                      Icons.person_rounded,
                      size: 22.sp,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.review.customerName,
                          style: textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          widget.review.date,
                          style: GoogleFonts.cairo(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurfaceVariant.withOpacity(
                              0.70,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  AppRatingStars(
                    rating: widget.review.rating,
                    starSize: 14,
                    showValue: false,
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              Text(
                widget.review.text,
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.6,
                ),
              ),
              SizedBox(height: 10.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                decoration: BoxDecoration(
                  color: AppColors.primary[60]!.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  widget.review.jobTag,
                  style: GoogleFonts.cairo(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary[60],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
