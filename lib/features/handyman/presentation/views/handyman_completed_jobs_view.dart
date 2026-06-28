import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/l10n/translation/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/utils/widgets/app_main_background.dart';
import '../../../../core/utils/widgets/app_empty_states.dart';
import '../../../../core/utils/widgets/app_page_header.dart';
import '../../domain/entities/handyman_job_details_entity.dart';
import '../../domain/entities/handyman_job_summary_entity.dart';
import '../../domain/entities/handyman_statistics_entity.dart';
import '../cubit/handyman_cubit.dart';
import '../cubit/handyman_state.dart';

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

  // ── Real data ─────────────────────────────────────────────
  List<HandymanJobSummaryEntity> jobs = [];
  HandymanStatisticsEntity? statistics;
  bool isLoading = true;

  // ── Master stagger (header + stats) ──────────────────────
  late final AnimationController masterCtrl;

  late final Animation<double> headerFade;
  late final Animation<Offset> headerSlide;

  late final List<Animation<double>> statScale;
  late final List<Animation<double>> statFade;

  // Count-up for total earnings → driven by a placeholder (0→stats.completedJobs)
  late final AnimationController countCtrl;
  late       Animation<double>    countAnim;   // re-assigned when stats arrive

  // Count-up for jobs completed
  late final AnimationController jobCountCtrl;
  late       Animation<double>    jobCountAnim;

  // Arc ring for avg rating
  late final AnimationController arcCtrl;
  late       Animation<double>    arcAnim;

  // Whether the animated stats have been started with real data
  bool _statsAnimStarted = false;

  @override
  void initState() {
    super.initState();

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
          curve:
              Interval(s, (s + 0.22).clamp(0.0, 1.0), curve: Curves.easeOut),
        ),
      );
    });

    // Placeholder count-up controllers — targets updated when stats arrive
    countCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    countAnim = Tween<double>(begin: 0.0, end: 0.0)
        .animate(CurvedAnimation(parent: countCtrl, curve: Curves.easeOutCubic));

    jobCountCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    jobCountAnim = Tween<double>(begin: 0.0, end: 0.0).animate(
      CurvedAnimation(parent: jobCountCtrl, curve: Curves.easeOutCubic),
    );

    arcCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );
    arcAnim = Tween<double>(begin: 0.0, end: 0.0)
        .animate(CurvedAnimation(parent: arcCtrl, curve: Curves.easeOutCubic));

    masterCtrl.forward();
  }

  /// Called once when real statistics arrive — re-wires all count-up animations
  void _startStatsAnimations(HandymanStatisticsEntity stats) {
    if (_statsAnimStarted) return;
    _statsAnimStarted = true;

    jobCountAnim = Tween<double>(
      begin: 0.0,
      end: stats.completedJobs.toDouble(),
    ).animate(
      CurvedAnimation(parent: jobCountCtrl, curve: Curves.easeOutCubic),
    );

    arcAnim = Tween<double>(
      begin: 0.0,
      end: (stats.averageRating / 5.0).clamp(0.0, 1.0),
    ).animate(CurvedAnimation(parent: arcCtrl, curve: Curves.easeOutCubic));

    // total reviews as a "score" proxy (no earnings field in entity)
    countAnim = Tween<double>(
      begin: 0.0,
      end: stats.totalReviews.toDouble(),
    ).animate(CurvedAnimation(parent: countCtrl, curve: Curves.easeOutCubic));

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
    final rating = statistics?.averageRating ?? 0.0;

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
                            rating.toStringAsFixed(1),
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
                      textAlign: TextAlign.center,
                      style: GoogleFonts.cairo(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withOpacity(0.85),
                      ),
                    ),
                    SizedBox(height: 12.h),

                    // Reviews count
                    AnimatedBuilder(
                      animation: countAnim,
                      builder: (_, __) {
                        final isAr = Directionality.of(context) == TextDirection.RTL;
                        final label = isAr ? 'مراجعة' : 'review(s)';
                        return Text(
                          '${countAnim.value.toInt()} $label',
                          style: GoogleFonts.cairo(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        );
                      },
                    ),
                    Text(
                      l10n.reviewsTitle,
                      textAlign: TextAlign.center,
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
    final completedStr = statistics != null
        ? '${statistics!.completedJobs}'
        : '—';
    final ratingStr = statistics != null
        ? statistics!.averageRating.toStringAsFixed(1)
        : '—';
    final reviewsStr = statistics != null
        ? '${statistics!.totalReviews}'
        : '—';

    final stats = [
      (completedStr, l10n.completedJobsTotal,    Icons.work_history_rounded),
      (ratingStr,    l10n.completedJobsAvgRating, Icons.star_rounded),
      (reviewsStr,   l10n.completedJobsTotalEarned, Icons.reviews_outlined),
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
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.xxs ),
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

  // ── Job card builder ────────────────────────────────────────
  Widget buildCard(
    HandymanJobSummaryEntity job,
    bool isDark,
    int index,
    AppLocalizations l10n,
  ) {
    return _JobCard(
      job: job,
      isDark: isDark,
      accent: teal,
      index: index,
      completedLabel: l10n.completedJobsBadge,
      onTap: () => _openDetails(job.id),
    );
  }

  void _openDetails(String id) {
    context.read<HandymanCubit>().getJobDetails(id);
  }

  void _showDetailsSheet(HandymanJobDetailsEntity details) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _JobDetailsSheet(
        job: details,
        accent: teal,
        isDark: isDark,
        l10n: l10n,
      ),
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

    return BlocListener<HandymanCubit, HandymanState>(
      listener: _handleState,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: AppMainBackground(
          child: isLoading
              ? Center(child: CircularProgressIndicator(color: teal))
              : CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: AppPageHeader(
                        isDark: isDark,
                        accentColor: teal,
                        title: l10n.completedJobsTitle,
                      ),
                    ),

                    SliverToBoxAdapter(
                        child: buildStatsHeader(context, isDark, l10n)),
                    SliverToBoxAdapter(child: buildStatRow(isDark, l10n)),

                    jobs.isEmpty
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
                                  child: buildCard(jobs[i], isDark, i, l10n),
                                ),
                                childCount: jobs.length,
                              ),
                            ),
                          ),
                  ],
                ),
        ),
      ),
    );
  }

  void _handleState(BuildContext ctx, HandymanState state) {
    state.whenOrNull(
      jobsLoaded: (allJobs) {
        setState(() {
          jobs = allJobs
              .where((j) => j.status.toLowerCase() == 'completed')
              .toList();
          isLoading = false;
        });
      },
      statisticsLoaded: (stats) {
        setState(() => statistics = stats);
        _startStatsAnimations(stats);
      },
      jobDetailsLoaded: (details) => _showDetailsSheet(details),
      error: (msg) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
          content: Text(msg, style: const TextStyle(color: Colors.white)),
          backgroundColor: AppColors.danger,
        ));
      },
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

    return BlocListener<HandymanCubit, HandymanState>(
      listener: _handleState,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: AppMainBackground(
          child: isLoading
              ? Center(child: CircularProgressIndicator(color: teal))
              : Column(
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
                                bottom:
                                    MediaQuery.of(context).padding.bottom + 32.h,
                              ),
                              child: Column(
                                children: [
                                  buildStatsHeader(context, isDark, l10n),
                                  buildStatRow(isDark, l10n),
                                ],
                              ),
                            ),
                          ),

                          VerticalDivider(
                              width: 1, color: teal.withOpacity(0.10)),

                          // ── Right: cards ──────────────────────────────
                          Expanded(
                            child: jobs.isEmpty
                                ? Center(
                                    child: AppEmptyState(
                                      icon: Icons.work_off_outlined,
                                      title: l10n.completedJobsEmptyTitle,
                                      subtitle:
                                          l10n.completedJobsEmptySubtitle,
                                      color: teal,
                                    ),
                                  )
                                : ListView.builder(
                                    padding: EdgeInsets.fromLTRB(
                                      AppSpacing.xl.w,
                                      AppSpacing.lg.h,
                                      AppSpacing.xl.w,
                                      MediaQuery.of(context).padding.bottom +
                                          32.h,
                                    ),
                                    itemCount: jobs.length,
                                    itemBuilder: (_, i) => Padding(
                                      padding: EdgeInsets.only(bottom: 18.h),
                                      child: buildCard(jobs[i], isDark, i, l10n),
                                    ),
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

  void _handleState(BuildContext ctx, HandymanState state) {
    state.whenOrNull(
      jobsLoaded: (allJobs) {
        setState(() {
          jobs = allJobs
              .where((j) => j.status.toLowerCase() == 'completed')
              .toList();
          isLoading = false;
        });
      },
      statisticsLoaded: (stats) {
        setState(() => statistics = stats);
        _startStatsAnimations(stats);
      },
      jobDetailsLoaded: (details) => _showDetailsSheet(details),
      error: (msg) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
          content: Text(msg, style: const TextStyle(color: Colors.white)),
          backgroundColor: AppColors.danger,
        ));
      },
    );
  }
}

// ══════════════════════════════════════════════════════════════
// _JobDetailsSheet — shown when tapping a completed job card
// ══════════════════════════════════════════════════════════════
class _JobDetailsSheet extends StatefulWidget {
  final HandymanJobDetailsEntity job;
  final Color accent;
  final bool isDark;
  final AppLocalizations l10n;
  const _JobDetailsSheet({
    required this.job,
    required this.accent,
    required this.isDark,
    required this.l10n,
  });

  @override
  State<_JobDetailsSheet> createState() => _JobDetailsSheetState();
}

class _JobDetailsSheetState extends State<_JobDetailsSheet>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 380),
  )..forward();
  late final Animation<double> _fade = CurvedAnimation(
    parent: _ctrl,
    curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
  );
  late final Animation<double> _slide = Tween<double>(begin: 40.0, end: 0.0)
      .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final j = widget.job;
    final ac = widget.accent;
    final isDark = widget.isDark;
    final l10n = widget.l10n;
    final bottom = MediaQuery.of(context).padding.bottom;
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final sheetBg = isDark ? AppColors.darkSurface : Colors.white;

    final dateStr = DateFormat('dd/MM/yyyy').format(j.scheduledDate);
    final timeStr = DateFormat('hh:mm a').format(j.scheduledDate);
    final durationStr = j.estimatedDurationInMinutes >= 60
        ? '${j.estimatedDurationInMinutes ~/ 60}h ${j.estimatedDurationInMinutes % 60}m'
        : '${j.estimatedDurationInMinutes}m';

    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, child) => Opacity(
        opacity: _fade.value,
        child: Transform.translate(offset: Offset(0, _slide.value), child: child),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: sheetBg,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
          boxShadow: [
            BoxShadow(
              color: ac.withOpacity(0.12),
              blurRadius: 32,
              offset: const Offset(0, -6),
            ),
          ],
        ),
        padding: EdgeInsets.only(bottom: bottom),
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 20.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: ac.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),
              ),
              SizedBox(height: 18.h),

              // Status badge + ID row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Text(
                  //   '#${j.id}',
                  //   style: GoogleFonts.cairo(
                  //     fontSize: 12.sp,
                  //     fontWeight: FontWeight.w600,
                  //     color: cs.onSurfaceVariant,
                  //   ),
                  // ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
                    decoration: BoxDecoration(
                      color: ac.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_circle_rounded,
                            size: 13.sp, color: ac),
                        SizedBox(width: 4.w),
                        Text(
                          l10n.completedJobsBadge,
                          style: GoogleFonts.cairo(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w700,
                            color: ac,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 14.h),

              // Title
              Align(
                alignment: AlignmentGeometry.center,
                child: Text(
                  j.title,
                  style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                ),
              ),
              SizedBox(height: 6.h),

              // Category
              Align(
                alignment: AlignmentGeometry.center,
                child: Text(
                  j.category,
                  style: GoogleFonts.cairo(
                    fontSize: 13.sp,
                    color: ac,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              SizedBox(height: 16.h),

              // Divider
              Divider(color: ac.withOpacity(0.10)),
              SizedBox(height: 14.h),

              // Info chips grid
              Wrap(
                spacing: 16.w,
                runSpacing: 10.h,
                children: [
                  _DetailChip(
                      icon: Icons.calendar_today_rounded,
                      label: dateStr,
                      accent: ac),
                  _DetailChip(
                      icon: Icons.access_time_rounded,
                      label: timeStr,
                      accent: ac),
                  _DetailChip(
                      icon: Icons.timer_outlined,
                      label: durationStr,
                      accent: ac),
                  _DetailChip(
                      icon: Icons.location_on_outlined,
                      label: j.location,
                      accent: ac),
                ],
              ),
              SizedBox(height: 16.h),

              // Customer row
              Container(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.darkBgPrimary
                      : const Color(0xFFF5F7FA),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 42.w,
                      height: 42.w,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [ac, ac.withOpacity(0.70)],
                        ),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Center(
                        child: Text(
                          j.customerName.isNotEmpty
                              ? j.customerName[0].toUpperCase()
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
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          j.customerName,
                          style: tt.bodyMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        Text(
                          Directionality.of(context) == TextDirection.RTL
                              ? 'عميل'
                              : 'Customer',
                          style: tt.bodySmall
                              ?.copyWith(color: cs.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.h),

              // Description
              if (j.description.isNotEmpty) ...[
                Text(
                  'Description',
                  style:
                      tt.bodySmall?.copyWith(fontWeight: FontWeight.w700),
                ),
                SizedBox(height: 8.h),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(14.w),
                  decoration: BoxDecoration(
                    color: ac.withOpacity(0.04),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: ac.withOpacity(0.10)),
                  ),
                  child: Text(
                    j.description,
                    style: tt.bodySmall?.copyWith(
                      color: cs.onSurfaceVariant,
                      height: 1.6,
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
              ],

              // Images gallery (if any)
              if (j.images.isNotEmpty) ...[
                Text(
                  l10n.portfolioPickImage,
                  style: tt.bodySmall?.copyWith(fontWeight: FontWeight.w700),
                ),
                SizedBox(height: 10.h),
                SizedBox(
                  height: 90.h,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: j.images.length,
                    separatorBuilder: (_, __) => SizedBox(width: 10.w),
                    itemBuilder: (_, i) => ClipRRect(
                      borderRadius: BorderRadius.circular(12.r),
                      child: Image.network(
                        j.images[i],
                        width: 120.w,
                        height: 90.h,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 120.w,
                          height: 90.h,
                          decoration: BoxDecoration(
                            color: ac.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Icon(Icons.image_outlined,
                              color: ac, size: 28.sp),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
              ],

              // Close button
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: double.infinity,
                  height: 50.h,
                  decoration: BoxDecoration(
                    color: ac.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  child: Center(
                    child: Text(
                      l10n.cancel,
                      style: GoogleFonts.cairo(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w700,
                        color: ac,
                      ),
                    ),
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

// ══════════════════════════════════════════════════════════════
// _DetailChip
// ══════════════════════════════════════════════════════════════
class _DetailChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color accent;
  const _DetailChip({required this.icon, required this.label, required this.accent});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13.sp, color: accent),
        SizedBox(width: 4.w),
        Text(
          label,
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

// ══════════════════════════════════════════════════════════════
// _JobCard
// ══════════════════════════════════════════════════════════════
class _JobCard extends StatefulWidget {
  final HandymanJobSummaryEntity job;
  final bool isDark;
  final Color accent;
  final int index;
  final String completedLabel;
  final VoidCallback onTap;

  const _JobCard({
    required this.job,
    required this.isDark,
    required this.accent,
    required this.index,
    required this.completedLabel,
    required this.onTap,
  });

  @override
  State<_JobCard> createState() => _JobCardState();
}

class _JobCardState extends State<_JobCard> with TickerProviderStateMixin {
  // Card entry
  late final AnimationController _entryCtrl;
  late final Animation<double> _entryScale;
  late final Animation<double> _entryFade;
  late final Animation<Offset> _entrySlide;

  // Shimmer on the accent stripe
  late final AnimationController _shimmerCtrl;
  late final Animation<double> _shimmerPos;

  bool _pressed = false;

  @override
  void initState() {
    super.initState();

    _entryCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
    );
    _entryScale = Tween<double>(begin: 0.82, end: 1.0).animate(
        CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOutBack));
    _entryFade = CurvedAnimation(
        parent: _entryCtrl,
        curve: const Interval(0.0, 0.55, curve: Curves.easeOut));
    _entrySlide = Tween<Offset>(
      begin: const Offset(0, 0.18),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOutCubic));

    Future.delayed(Duration(milliseconds: widget.index * 90), () {
      if (mounted) _entryCtrl.forward();
    });

    _shimmerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat();
    _shimmerPos = Tween<double>(begin: -1.0, end: 2.0)
        .animate(CurvedAnimation(parent: _shimmerCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _entryCtrl.dispose();
    _shimmerCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final j = widget.job;
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final ac = widget.accent;
    final dateStr =
        DateFormat('dd/MM/yyyy').format(j.scheduledDate);
    final timeStr = DateFormat('hh:mm a').format(j.scheduledDate);

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
            onTapUp: (_) {
              setState(() => _pressed = false);
              widget.onTap();
            },
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
                      color: Colors.black.withOpacity(widget.isDark ? 0.20 : 0.07),
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
                            colors: [ac, ac.withOpacity(0.5)]),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20.r),
                          topRight: Radius.circular(20.r),
                        ),
                      ),
                    ),

                    Padding(
                      padding: EdgeInsets.all(18.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // ID + badge
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              // Text(
                              //   '#${j.id}',
                              //   style: GoogleFonts.cairo(
                              //     fontSize: 11.sp,
                              //     fontWeight: FontWeight.w600,
                              //     color: cs.onSurfaceVariant,
                              //   ),
                              // ),
                              _CompletedBadge(
                                label: widget.completedLabel,
                                accent: ac,
                              ),
                            ],
                          ),
                          SizedBox(height: 8.h),

                          // Title
                          Align(
                            alignment: AlignmentGeometry.center,
                            child: Text(
                              j.title,
                              style: tt.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w800),
                            ),
                          ),
                          SizedBox(height: 4.h),

                          // Category
                          Align(
                            alignment: AlignmentGeometry.center,
                            child: Text(
                              j.category,
                              style: GoogleFonts.cairo(
                                fontSize: 12.sp,
                                color: ac,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          SizedBox(height: 12.h),

                          // Detail chips
                          Wrap(
                            spacing: 14.w,
                            runSpacing: 6.h,
                            children: [
                              _Chip(Icons.calendar_today_rounded, dateStr, ac),
                              _Chip(Icons.access_time_rounded, timeStr, ac),
                              _Chip(Icons.location_on_outlined, j.location, ac),
                              // _Chip(Icons.timer_outlined, j.estimatedDuration, ac),
                            ],
                          ),
                          SizedBox(height: 14.h),

                          // Customer row
                          _CustomerRow(
                            customerName: j.customerName,
                            isDark: widget.isDark,
                            accent: ac,
                          ),
                          SizedBox(height: 12.h),

                          // Tap-for-details badge (shimmer)
                          _ShimmerEarnings(
                            label: '← ${_tapLabel(context)}',
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

  String _tapLabel(BuildContext ctx) {
    final isAr = Directionality.of(ctx) == TextDirection.RTL;
    return isAr ? 'اضغط لعرض التفاصيل' : 'Tap for details';
  }
}

// ══════════════════════════════════════════════════════════════
// _ShimmerEarnings
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
// _CompletedBadge
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
  late final Animation<double> _scale = Tween<double>(begin: 0.0, end: 1.0)
      .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack));
  late final Animation<double> _fade = CurvedAnimation(
    parent: _ctrl,
    curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
  );

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 350),
        () { if (mounted) _ctrl.forward(); });
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
              Icon(Icons.check_circle_rounded,
                  size: 13.sp, color: widget.accent),
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
  final String customerName;
  final bool isDark;
  final Color accent;
  const _CustomerRow({
    required this.customerName,
    required this.isDark,
    required this.accent,
  });

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
                colors: [accent, accent.withOpacity(0.70)],
              ),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Center(
              child: Text(
                customerName.isNotEmpty ? customerName[0].toUpperCase() : '?',
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
              Text(customerName,
                  style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w700)),
              Text(
                'Customer',
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
// _ArcPainter
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
