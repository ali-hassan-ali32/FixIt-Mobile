import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/l10n/translation/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/utils/widgets/app_main_background.dart';
import '../../../../core/utils/widgets/app_empty_states.dart';
import '../../../../core/utils/widgets/app_page_header.dart';

// ══════════════════════════════════════════════════════════════
// Model
// ══════════════════════════════════════════════════════════════
class _Job {
  final String id, title, date, duration, location, rate;
  final String customerName, customerSub, reviewText, earned;
  final Color avatarColor;
  final double rating;
  const _Job({
    required this.id,
    required this.title,
    required this.date,
    required this.duration,
    required this.location,
    required this.rate,
    required this.customerName,
    required this.customerSub,
    required this.avatarColor,
    required this.rating,
    required this.reviewText,
    required this.earned,
  });
}

const _kJobs = [
  _Job(
    id: 'REQ-00120',
    title: 'خدمة سباكة - صيانة عامة',
    date: '٢٠٢٦/٠٢/١٠',
    duration: 'ساعتان',
    location: 'مدينة نصر',
    rate: '١٥٠ ج/ساعة',
    customerName: 'أحمد محمود',
    customerSub: 'عميل متكرر',
    avatarColor: Color(0xFF3498DB),
    rating: 5.0,
    reviewText: 'عمل ممتاز وسريع، المشكلة تم حلها بشكل نهائي. شكراً جزيلاً!',
    earned: '٣٠٠ ج',
  ),
  _Job(
    id: 'REQ-00118',
    title: 'خدمة سباكة - تركيب سخان',
    date: '٢٠٢٦/٠٢/٠٩',
    duration: '٣ ساعات',
    location: 'المعادي',
    rate: '١٥٠ ج/ساعة',
    customerName: 'سارة أحمد',
    customerSub: 'عميلة دائمة',
    avatarColor: Color(0xFFE74C3C),
    rating: 4.0,
    reviewText: 'محترف وملتزم بالمواعيد. العمل جيد جداً.',
    earned: '٤٥٠ ج',
  ),
  _Job(
    id: 'REQ-00115',
    title: 'خدمة سباكة - كشف تسريب',
    date: '٢٠٢٦/٠٢/٠٨',
    duration: 'ساعة ونصف',
    location: 'الزمالك',
    rate: '١٥٠ ج/ساعة',
    customerName: 'محمد عبدالله',
    customerSub: 'عميل جديد',
    avatarColor: Color(0xFF9B59B6),
    rating: 5.0,
    reviewText: 'ممتاز! وجد التسريب بسرعة وأصلحه. أنصح به بشدة.',
    earned: '٢٢٥ ج',
  ),
  _Job(
    id: 'REQ-00112',
    title: 'خدمة سباكة - تركيب فلتر',
    date: '٢٠٢٦/٠٢/٠٦',
    duration: 'ساعتان',
    location: 'مصر الجديدة',
    rate: '١٥٠ ج/ساعة',
    customerName: 'فاطمة حسن',
    customerSub: 'عميلة دائمة',
    avatarColor: Color(0xFF27AE60),
    rating: 5.0,
    reviewText: 'خدمة ممتازة. الفني نظيف وسريع ومحترف جداً.',
    earned: '٣٠٠ ج',
  ),
];

// ══════════════════════════════════════════════════════════════
// Layout router
// ══════════════════════════════════════════════════════════════
class HandymanCompletedJobsView extends StatelessWidget {
  const HandymanCompletedJobsView({super.key});

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (_, c) =>
        c.maxWidth >= 600 ? const _TabletBody() : const _MobileBody(),
  );
}

// ══════════════════════════════════════════════════════════════
// Shared base
// ══════════════════════════════════════════════════════════════
abstract class _Base<T extends StatefulWidget> extends State<T>
    with TickerProviderStateMixin {
  Color get teal => AppColors.accent[60]!;

  // ── Master stagger (header + stats) ──────────────────────
  late final AnimationController masterCtrl;

  // Header: teal card slides down
  late final Animation<double> headerFade;
  late final Animation<Offset> headerSlide;

  // Stats: each box pops in with easeOutBack
  late final List<Animation<double>> statScale;
  late final List<Animation<double>> statFade;

  // Earnings total: count-up from 0 → 975 (mock total)
  late final AnimationController countCtrl;
  late final Animation<double> countAnim;

  // Arc ring for avg rating (0 → 4.9/5.0)
  late final AnimationController arcCtrl;
  late final Animation<double> arcAnim;

  // Jobs completed count-up
  late final AnimationController jobCountCtrl;
  late final Animation<double> jobCountAnim;

  @override
  void initState() {
    super.initState();

    // ── Master: header + stat stagger ──────────────────────
    masterCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    headerFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: masterCtrl,
        curve: const Interval(0.0, 0.35, curve: Curves.easeOut),
      ),
    );
    headerSlide = Tween<Offset>(begin: const Offset(0, -0.20), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: masterCtrl,
            curve: const Interval(0.0, 0.40, curve: Curves.easeOutCubic),
          ),
        );

    statScale = List.generate(3, (i) {
      final s = 0.22 + i * 0.12;
      return Tween<double>(begin: 0.55, end: 1.0).animate(
        CurvedAnimation(
          parent: masterCtrl,
          curve: Interval(
            s,
            (s + 0.30).clamp(0.0, 1.0),
            curve: Curves.easeOutBack,
          ),
        ),
      );
    });
    statFade = List.generate(3, (i) {
      final s = 0.22 + i * 0.12;
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: masterCtrl,
          curve: Interval(s, (s + 0.22).clamp(0.0, 1.0), curve: Curves.easeOut),
        ),
      );
    });

    // ── Count-up animations (start after 300 ms) ───────────
    countCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    countAnim = Tween<double>(
      begin: 0.0,
      end: 975.0,
    ).animate(CurvedAnimation(parent: countCtrl, curve: Curves.easeOutCubic));

    jobCountCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    jobCountAnim = Tween<double>(begin: 0.0, end: 240.0).animate(
      CurvedAnimation(parent: jobCountCtrl, curve: Curves.easeOutCubic),
    );

    // ── Arc: avg rating draws 0 → 4.9/5 of circle ─────────
    arcCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );
    arcAnim = Tween<double>(
      begin: 0.0,
      end: 4.9 / 5.0,
    ).animate(CurvedAnimation(parent: arcCtrl, curve: Curves.easeOutCubic));

    // Start all
    masterCtrl.forward();
    Future.delayed(const Duration(milliseconds: 320), () {
      if (mounted) {
        countCtrl.forward();
        jobCountCtrl.forward();
      }
    });
    Future.delayed(const Duration(milliseconds: 280), () {
      if (mounted) arcCtrl.forward();
    });
  }

  @override
  void dispose() {
    masterCtrl.dispose();
    countCtrl.dispose();
    jobCountCtrl.dispose();
    arcCtrl.dispose();
    super.dispose();
  }

  // ── Teal hero stats header ─────────────────────────────────
  Widget buildStatsHeader(
    BuildContext context,
    bool isDark,
    AppLocalizations l10n,
  ) {
    return FadeTransition(
      opacity: headerFade,
      child: SlideTransition(
        position: headerSlide,
        child: Container(
          margin: EdgeInsets.fromLTRB(
            AppSpacing.xl.w,
            AppSpacing.lg.h,
            AppSpacing.xl.w,
            0,
          ),
          padding: EdgeInsets.all(22.w),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [teal, AppColors.accent[70] ?? const Color(0xFF44A3A0)],
            ),
            borderRadius: BorderRadius.circular(24.r),
            boxShadow: [
              BoxShadow(
                color: teal.withOpacity(0.30),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ── Arc ring (avg rating) ────────────────────
              AnimatedBuilder(
                animation: arcAnim,
                builder: (_, __) => SizedBox(
                  width: 78.w,
                  height: 78.w,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CustomPaint(
                        size: Size(78.w, 78.w),
                        painter: _ArcPainter(
                          progress: arcAnim.value,
                          trackColor: Colors.white.withOpacity(0.2),
                          arcColor: Colors.white,
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '4.9',
                            style: GoogleFonts.cairo(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          Icon(
                            Icons.star_rounded,
                            size: 14.sp,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 8.w),

              // ── Count-up numbers ─────────────────────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Jobs count
                    AnimatedBuilder(
                      animation: jobCountAnim,
                      builder: (_, __) => Text(
                        jobCountAnim.value.toInt().toString(),
                        style: GoogleFonts.cairo(
                          fontSize: 32.sp,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          height: 1.0,
                        ),
                      ),
                    ),
                    Text(
                      l10n.completedJobsTotal,
                      textAlign: TextAlign.center, // ADDED
                      style: GoogleFonts.cairo(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withOpacity(0.85),
                      ),
                    ),
                    SizedBox(height: 12.h),

                    // Earnings count
                    AnimatedBuilder(
                      animation: countAnim,
                      builder: (_, __) => Text(
                        '${countAnim.value.toInt()} ج',
                        style: GoogleFonts.cairo(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Text(
                      l10n.completedJobsTotalEarned,
                      textAlign: TextAlign.center, // ADDED
                      style: GoogleFonts.cairo(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withOpacity(0.80),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Three stat pop-in boxes ─────────────────────────────────
  Widget buildStatRow(bool isDark, AppLocalizations l10n) {
    final stats = [
      ('240', l10n.completedJobsTotal, Icons.work_history_rounded),
      ('4.9', l10n.completedJobsAvgRating, Icons.star_rounded),
      ('36K', l10n.completedJobsTotalEarned, Icons.payments_outlined),
    ];

    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.xl.w,
        AppSpacing.lg.h,
        AppSpacing.xl.w,
        AppSpacing.lg.h,
      ),
      child: Row(
        children: List.generate(3, (i) {
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: i > 0 ? 10.w : 0),
              child: FadeTransition(
                opacity: statFade[i],
                child: ScaleTransition(
                  scale: statScale[i],
                  child: _StatBox(
                    value: stats[i].$1,
                    label: stats[i].$2,
                    icon: stats[i].$3,
                    isDark: isDark,
                    accent: teal,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget buildCard(_Job j, bool isDark, int index, AppLocalizations l10n) {
    return _JobCard(
      job: j,
      isDark: isDark,
      accent: teal,
      index: index,
      paidLabel: l10n.completedJobPaid,
      completedLabel: l10n.completedJobsBadge,
    );
  }
}

// ══════════════════════════════════════════════════════════════
// Mobile Body
// ══════════════════════════════════════════════════════════════
class _MobileBody extends StatefulWidget {
  const _MobileBody();
  @override
  State<_MobileBody> createState() => _MobileBodyState();
}

class _MobileBodyState extends _Base<_MobileBody> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppMainBackground(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: AppPageHeader(
                isDark: isDark,
                accentColor: teal,
                title: l10n.completedJobsTitle,
              ),
            ),

            SliverToBoxAdapter(child: buildStatsHeader(context, isDark, l10n)),
            SliverToBoxAdapter(child: buildStatRow(isDark, l10n)),

            _kJobs.isEmpty
                ? SliverFillRemaining(
                    child: Center(
                      child: AppEmptyState(
                        icon: Icons.work_off_outlined,
                        title: l10n.completedJobsEmptyTitle,
                        subtitle: l10n.completedJobsEmptySubtitle,
                        color: teal,
                      ),
                    ),
                  )
                : SliverPadding(
                    padding: EdgeInsets.fromLTRB(
                      AppSpacing.xl.w,
                      0,
                      AppSpacing.xl.w,
                      MediaQuery.of(context).padding.bottom + 100.h,
                    ),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (_, i) => Padding(
                          padding: EdgeInsets.only(bottom: 18.h),
                          child: buildCard(_kJobs[i], isDark, i, l10n),
                        ),
                        childCount: _kJobs.length,
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
// Tablet Body — left teal panel (40%) | right card list (60%)
// ══════════════════════════════════════════════════════════════
class _TabletBody extends StatefulWidget {
  const _TabletBody();
  @override
  State<_TabletBody> createState() => _TabletBodyState();
}

class _TabletBodyState extends _Base<_TabletBody> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppMainBackground(
        child: Column(
          children: [
            AppPageHeader(
              isDark: isDark,
              accentColor: teal,
              title: l10n.completedJobsTitle,
            ),

            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Left: hero stats ──────────────────────────
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.40,
                    child: SingleChildScrollView(
                      padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).padding.bottom + 32.h,
                      ),
                      child: Column(
                        children: [
                          buildStatsHeader(context, isDark, l10n),
                          buildStatRow(isDark, l10n),
                        ],
                      ),
                    ),
                  ),

                  VerticalDivider(width: 1, color: teal.withOpacity(0.10)),

                  // ── Right: cards ──────────────────────────────
                  Expanded(
                    child: _kJobs.isEmpty
                        ? Center(
                            child: AppEmptyState(
                              icon: Icons.work_off_outlined,
                              title: l10n.completedJobsEmptyTitle,
                              subtitle: l10n.completedJobsEmptySubtitle,
                              color: teal,
                            ),
                          )
                        : ListView.builder(
                            padding: EdgeInsets.fromLTRB(
                              AppSpacing.xl.w,
                              AppSpacing.lg.h,
                              AppSpacing.xl.w,
                              MediaQuery.of(context).padding.bottom + 32.h,
                            ),
                            itemCount: _kJobs.length,
                            itemBuilder: (_, i) => Padding(
                              padding: EdgeInsets.only(bottom: 18.h),
                              child: buildCard(_kJobs[i], isDark, i, l10n),
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// _JobCard — entry: elasticScale + slide; inner: sequential
//            star pop-in, shimmer sweep on earnings badge
// ══════════════════════════════════════════════════════════════
class _JobCard extends StatefulWidget {
  final _Job job;
  final bool isDark;
  final Color accent;
  final int index;
  final String paidLabel, completedLabel;
  const _JobCard({
    required this.job,
    required this.isDark,
    required this.accent,
    required this.index,
    required this.paidLabel,
    required this.completedLabel,
  });
  @override
  State<_JobCard> createState() => _JobCardState();
}

class _JobCardState extends State<_JobCard> with TickerProviderStateMixin {
  // Card entry: elastic scale + fade + slide
  late final AnimationController _entryCtrl;
  late final Animation<double> _entryScale;
  late final Animation<double> _entryFade;
  late final Animation<Offset> _entrySlide;

  // Star sequential pop-in (5 stars × 60 ms gap)
  late final AnimationController _starsCtrl;
  late final List<Animation<double>> _starScale;

  // Shimmer sweep on earnings badge
  late final AnimationController _shimmerCtrl;
  late final Animation<double> _shimmerPos;

  // Press feedback
  bool _pressed = false;

  @override
  void initState() {
    super.initState();

    // Entry
    _entryCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
    );
    _entryScale = Tween<double>(
      begin: 0.82,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOutBack));
    _entryFade = CurvedAnimation(
      parent: _entryCtrl,
      curve: const Interval(0.0, 0.55, curve: Curves.easeOut),
    );
    _entrySlide = Tween<Offset>(
      begin: const Offset(0, 0.18),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOutCubic));

    Future.delayed(Duration(milliseconds: widget.index * 90), () {
      if (mounted) _entryCtrl.forward();
    });

    // Stars
    _starsCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    );
    final count = widget.job.rating.ceil().clamp(1, 5);
    _starScale = List.generate(5, (i) {
      final s = (i * 0.14).clamp(0.0, 1.0);
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _starsCtrl,
          curve: Interval(
            s,
            (s + 0.35).clamp(0.0, 1.0),
            curve: Curves.easeOutBack,
          ),
        ),
      );
    });
    Future.delayed(Duration(milliseconds: widget.index * 90 + 420), () {
      if (mounted) _starsCtrl.forward();
    });

    // Shimmer (repeats)
    _shimmerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat();
    _shimmerPos = Tween<double>(
      begin: -1.0,
      end: 2.0,
    ).animate(CurvedAnimation(parent: _shimmerCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _entryCtrl.dispose();
    _starsCtrl.dispose();
    _shimmerCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final j = widget.job;
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final ac = widget.accent;

    return FadeTransition(
      opacity: _entryFade,
      child: SlideTransition(
        position: _entrySlide,
        child: ScaleTransition(
          scale: _entryScale,
          child: GestureDetector(
            onTapDown: (_) {
              setState(() => _pressed = true);
              HapticFeedback.selectionClick();
            },
            onTapUp: (_) => setState(() => _pressed = false),
            onTapCancel: () => setState(() => _pressed = false),
            child: AnimatedScale(
              scale: _pressed ? 0.975 : 1.0,
              duration: const Duration(milliseconds: 110),
              child: Container(
                decoration: BoxDecoration(
                  color: widget.isDark ? AppColors.darkSurface : Colors.white,
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(color: ac.withOpacity(0.10)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(
                        widget.isDark ? 0.20 : 0.07,
                      ),
                      blurRadius: 18,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Top accent stripe ──────────────────
                    Container(
                      height: 4.h,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [ac, ac.withOpacity(0.5)],
                        ),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20.r),
                          topRight: Radius.circular(20.r),
                        ),
                      ),
                    ),

                    Padding(
                      padding: EdgeInsets.all(18.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ── ID + badge ─────────────────────
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '#${j.id}',
                                style: GoogleFonts.cairo(
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.w600,
                                  color: cs.onSurfaceVariant,
                                ),
                              ),
                              _CompletedBadge(
                                label: widget.completedLabel,
                                accent: ac,
                              ),
                            ],
                          ),
                          SizedBox(height: 8.h),

                          // ── Title ──────────────────────────
                          Text(
                            j.title,
                            style: tt.titleSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          SizedBox(height: 12.h),

                          // ── Detail chips ───────────────────
                          Wrap(
                            spacing: 14.w,
                            runSpacing: 6.h,
                            children: [
                              _Chip(Icons.calendar_today_rounded, j.date, ac),
                              _Chip(Icons.access_time_rounded, j.duration, ac),
                              _Chip(Icons.location_on_outlined, j.location, ac),
                              _Chip(Icons.payments_outlined, j.rate, ac),
                            ],
                          ),
                          SizedBox(height: 14.h),

                          // ── Customer row ───────────────────
                          _CustomerRow(job: j, isDark: widget.isDark),
                          SizedBox(height: 12.h),

                          // ── Review box ─────────────────────
                          Container(
                            padding: EdgeInsets.all(14.w),
                            decoration: BoxDecoration(
                              color: ac.withOpacity(0.06),
                              borderRadius: BorderRadius.circular(14.r),
                              border: Border.all(color: ac.withOpacity(0.12)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Animated stars
                                Row(
                                  children: [
                                    ...List.generate(
                                      5,
                                      (i) => ScaleTransition(
                                        scale: _starScale[i],
                                        child: Padding(
                                          padding: EdgeInsets.only(left: 2.w),
                                          child: Icon(
                                            i < j.rating.floor()
                                                ? Icons.star_rounded
                                                : i < j.rating
                                                ? Icons.star_half_rounded
                                                : Icons.star_outline_rounded,
                                            size: 17.sp,
                                            color: i < j.rating
                                                ? AppColors.star
                                                : cs.onSurfaceVariant
                                                      .withOpacity(0.25),
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 8.w),
                                    Text(
                                      j.rating.toStringAsFixed(1),
                                      style: GoogleFonts.cairo(
                                        fontSize: 13.sp,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 8.h),
                                Text(
                                  j.reviewText,
                                  style: tt.bodySmall?.copyWith(
                                    color: cs.onSurfaceVariant,
                                    height: 1.55,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 14.h),

                          // ── Earnings badge w/ shimmer ──────
                          _ShimmerEarnings(
                            label: '${widget.paidLabel}: ${j.earned}',
                            accent: ac,
                            shimmerPos: _shimmerPos,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// _ShimmerEarnings — gradient badge with a sweeping white sheen
// ══════════════════════════════════════════════════════════════
class _ShimmerEarnings extends StatelessWidget {
  final String label;
  final Color accent;
  final Animation<double> shimmerPos;
  const _ShimmerEarnings({
    required this.label,
    required this.accent,
    required this.shimmerPos,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: shimmerPos,
      builder: (_, __) {
        return Container(
          width: double.infinity,
          height: 46.h,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [accent, AppColors.accent[70] ?? accent],
            ),
            borderRadius: BorderRadius.circular(14.r),
            boxShadow: [
              BoxShadow(
                color: accent.withOpacity(0.28),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14.r),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Shimmer stripe
                Positioned.fill(
                  child: FractionalTranslation(
                    translation: Offset(shimmerPos.value, 0),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.white.withOpacity(0.0),
                            Colors.white.withOpacity(0.22),
                            Colors.white.withOpacity(0.0),
                          ],
                          stops: const [0.25, 0.50, 0.75],
                        ),
                      ),
                    ),
                  ),
                ),
                Text(
                  label,
                  style: GoogleFonts.cairo(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ══════════════════════════════════════════════════════════════
// _CompletedBadge — checkmark that draws with a scale-in
// ══════════════════════════════════════════════════════════════
class _CompletedBadge extends StatefulWidget {
  final String label;
  final Color accent;
  const _CompletedBadge({required this.label, required this.accent});
  @override
  State<_CompletedBadge> createState() => _CompletedBadgeState();
}

class _CompletedBadgeState extends State<_CompletedBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 450),
  );
  late final Animation<double> _scale = Tween<double>(
    begin: 0.0,
    end: 1.0,
  ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack));
  late final Animation<double> _fade = CurvedAnimation(
    parent: _ctrl,
    curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
  );

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 350), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
          decoration: BoxDecoration(
            color: widget.accent.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.check_circle_rounded,
                size: 13.sp,
                color: widget.accent,
              ),
              SizedBox(width: 4.w),
              Text(
                widget.label,
                style: GoogleFonts.cairo(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w700,
                  color: widget.accent,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// _CustomerRow
// ══════════════════════════════════════════════════════════════
class _CustomerRow extends StatelessWidget {
  final _Job job;
  final bool isDark;
  const _CustomerRow({required this.job, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 11.h),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkBgPrimary : const Color(0xFFF5F7FA),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [job.avatarColor, job.avatarColor.withOpacity(0.70)],
              ),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Center(
              child: Text(
                job.customerName.substring(0, 1),
                style: GoogleFonts.cairo(
                  fontSize: 17.sp,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                job.customerName,
                style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              Text(
                job.customerSub,
                style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// _StatBox
// ══════════════════════════════════════════════════════════════
class _StatBox extends StatelessWidget {
  final String value, label;
  final IconData icon;
  final bool isDark;
  final Color accent;
  const _StatBox({
    required this.value,
    required this.label,
    required this.icon,
    required this.isDark,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Container(
      padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 8.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: accent.withOpacity(0.10)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 32.w,
            height: 32.w,
            decoration: BoxDecoration(
              color: accent.withOpacity(0.10),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(icon, size: 16.sp, color: accent),
          ),
          SizedBox(height: 8.h),
          Text(
            value,
            style: GoogleFonts.cairo(
              fontSize: 18.sp,
              fontWeight: FontWeight.w800,
              color: accent,
            ),
          ),
          SizedBox(height: 3.h),
          Text(
            label,
            style: tt.bodySmall?.copyWith(fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// _Chip
// ══════════════════════════════════════════════════════════════
class _Chip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color accent;
  const _Chip(this.icon, this.label, this.accent);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12.sp, color: accent),
        SizedBox(width: 4.w),
        Text(
          label,
          style: GoogleFonts.cairo(
            fontSize: 11.sp,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════
// _ArcPainter — draws a circular progress arc
// ══════════════════════════════════════════════════════════════
class _ArcPainter extends CustomPainter {
  final double progress;
  final Color trackColor, arcColor;
  const _ArcPainter({
    required this.progress,
    required this.trackColor,
    required this.arcColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2, cy = size.height / 2;
    final r = (size.width - 10) / 2;
    final bg = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;
    final fg = Paint()
      ..color = arcColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(Offset(cx, cy), r, bg);
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: r),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      fg,
    );
  }

  @override
  bool shouldRepaint(_ArcPainter o) => o.progress != progress;
}
