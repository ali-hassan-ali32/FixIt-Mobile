import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/l10n/translation/app_localizations.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/utils/widgets/app_main_background.dart';
import '../../../../core/utils/widgets/app_empty_states.dart';
import '../../../../core/utils/widgets/app_filter_chip.dart';

// ══════════════════════════════════════════════════════════════
// Model
// ══════════════════════════════════════════════════════════════
enum JobStatus { active, scheduled, completed }

class JobModel {
  final String id;
  final String title;
  final String date;
  final String time;
  final String location;
  final String price;
  final JobStatus status;
  final String customerName;
  final String customerType;
  final Color customerAvatarColor;
  final double rating;
  final bool isReturningCustomer;

  const JobModel({
    required this.id,
    required this.title,
    required this.date,
    required this.time,
    required this.location,
    required this.price,
    required this.status,
    required this.customerName,
    required this.customerType,
    required this.customerAvatarColor,
    this.rating = 5.0,
    this.isReturningCustomer = false,
  });
}

// ══════════════════════════════════════════════════════════════
// Mock Data
// ══════════════════════════════════════════════════════════════
List<JobModel> _buildMockJobs(AppLocalizations l10n) => [
  JobModel(
    id: 'REQ-00123',
    title: l10n.jobPlumbingMaintenance,
    date: l10n.jobToday,
    time: '٢:٠٠ م',
    location: 'مدينة نصر',
    price: '١٥٠ ج',
    status: JobStatus.active,
    customerName: 'أحمد محمود',
    customerType: l10n.newReqNewCustomer,
    customerAvatarColor: const Color(0xFF3498DB),
    rating: 4.9,
  ),
  JobModel(
    id: 'REQ-00125',
    title: l10n.jobPlumbingInstall,
    date: l10n.jobTomorrow,
    time: '١٠:٠٠ ص',
    location: 'المعادي',
    price: '١٥٠ ج',
    status: JobStatus.scheduled,
    customerName: 'سارة أحمد',
    customerType: l10n.jobRegularCustomer,
    customerAvatarColor: const Color(0xFFE74C3C),
    isReturningCustomer: true,
  ),
  JobModel(
    id: 'REQ-00126',
    title: l10n.jobPlumbingLeak,
    date: '٢٠٢٦/٠٢/١٣',
    time: '٣:٠٠ م',
    location: 'الزمالك',
    price: '١٥٠ ج',
    status: JobStatus.scheduled,
    customerName: 'محمد عبدالله',
    customerType: l10n.newReqNewCustomer,
    customerAvatarColor: const Color(0xFF9B59B6),
  ),
  JobModel(
    id: 'REQ-00128',
    title: 'صيانة سخان مياه',
    date: '٢٠٢٦/٠٢/١٤',
    time: '١١:٠٠ ص',
    location: 'مصر الجديدة',
    price: '١٨٠ ج',
    status: JobStatus.scheduled,
    customerName: 'فاطمة حسن',
    customerType: l10n.jobRegularCustomer,
    customerAvatarColor: const Color(0xFF27AE60),
    isReturningCustomer: true,
  ),
];

// ══════════════════════════════════════════════════════════════
// HandymanJobsView — layout router
// ══════════════════════════════════════════════════════════════
class HandymanJobsView extends StatelessWidget {
  const HandymanJobsView({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, constraints) => constraints.maxWidth >= 600
          ? const HandymanJobsTabletBody()
          : const HandymanJobsMobileBody(),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// Shared base — all state, animations, logic
// ══════════════════════════════════════════════════════════════
abstract class _JobsBase<T extends StatefulWidget> extends State<T>
    with TickerProviderStateMixin {
  JobStatus? _filter;
  List<JobModel>? _jobs;

  // Entry stagger animations
  late final AnimationController entryCtrl;
  late final List<Animation<double>> entryFade;
  late final List<Animation<Offset>> entrySlide;
  static const _n = 6;

  // Filter chip scale animation
  late final AnimationController filterCtrl;
  late final Animation<double> filterScale;

  // Stats counter animation
  late final AnimationController statsCtrl;
  late final Animation<double> statsFade;

  Color get teal => AppColors.accent[60]!;

  List<JobModel> get filteredJobs {
    if (_filter == null) return _jobs!;
    return _jobs!.where((j) => j.status == _filter).toList();
  }

  @override
  void initState() {
    super.initState();

    // Entry stagger
    entryCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 950),
    );
    entryFade = List.generate(_n, (i) {
      final s = (i * 0.12).clamp(0.0, 1.0);
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: entryCtrl,
          curve: Interval(s, (s + 0.38).clamp(0.0, 1.0), curve: Curves.easeOut),
        ),
      );
    });
    entrySlide = List.generate(_n, (i) {
      final s = (i * 0.12).clamp(0.0, 1.0);
      return Tween<Offset>(
        begin: const Offset(0, 0.16),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: entryCtrl,
          curve: Interval(
            s,
            (s + 0.45).clamp(0.0, 1.0),
            curve: Curves.easeOutCubic,
          ),
        ),
      );
    });

    // Filter pop
    filterCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    );
    filterScale = Tween<double>(
      begin: 1.0,
      end: 1.04,
    ).animate(CurvedAnimation(parent: filterCtrl, curve: Curves.easeOutBack));

    // Stats fade
    statsCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    statsFade = CurvedAnimation(parent: statsCtrl, curve: Curves.easeOut);

    entryCtrl.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) statsCtrl.forward();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _jobs ??= _buildMockJobs(AppLocalizations.of(context)!);
  }

  @override
  void dispose() {
    entryCtrl.dispose();
    filterCtrl.dispose();
    statsCtrl.dispose();
    super.dispose();
  }

  void _onFilterTap(JobStatus? status) {
    HapticFeedback.selectionClick();
    filterCtrl.forward(from: 0);
    setState(() => _filter = status);
  }

  void _onHistoryTap() {
    HapticFeedback.lightImpact();
    Navigator.of(context).pushNamed(AppRoutes.handymanCompletedJobs);
  }

  Widget ea(int i, Widget child) {
    final idx = i.clamp(0, _n - 1);
    return FadeTransition(
      opacity: entryFade[idx],
      child: SlideTransition(position: entrySlide[idx], child: child),
    );
  }

  // ── Shared section builders ───────────────────────────────

  Widget buildHeader(BuildContext context, AppLocalizations l10n) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final top = MediaQuery.of(context).padding.top;

    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.xl.w,
        top + AppSpacing.md.h,
        AppSpacing.xl.w,
        AppSpacing.lg.h,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        border: Border(bottom: BorderSide(color: teal.withOpacity(0.08))),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title row with stats
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.jobsTitle,
                      style: textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      '${_jobs?.length ?? 0} ${l10n.requestNewSectionTitle}',
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              // Quick stats
              FadeTransition(
                opacity: statsFade,
                child: _QuickStatBadge(
                  count:
                      _jobs
                          ?.where((j) => j.status == JobStatus.active)
                          .length ??
                      0,
                  label: l10n.jobStatusActive,
                  color: const Color(0xFFFF6B35),
                  isDark: isDark,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),

          // Filter chips
          _buildFilterChips(l10n, isDark),
        ],
      ),
    );
  }

  Widget _buildFilterChips(AppLocalizations l10n, bool isDark) {
    return SizedBox(
      height: 40.h,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          AppFilterChip(
            label: l10n.filterAll,
            isActive: _filter == null,
            onTap: () => _onFilterTap(null),
            isDark: isDark,
            activeColor: teal,
            activeColorEnd: teal,
          ),
          SizedBox(width: 10.w),
          AppFilterChip(
            label: l10n.jobFilterActive,
            isActive: _filter == JobStatus.active,
            onTap: () => _onFilterTap(JobStatus.active),
            isDark: isDark,
            activeColor: const Color(0xFFFF6B35),
            activeColorEnd: const Color(0xFFFF6B35),
          ),
          SizedBox(width: 10.w),
          AppFilterChip(
            label: l10n.jobFilterScheduled,
            isActive: _filter == JobStatus.scheduled,
            onTap: () => _onFilterTap(JobStatus.scheduled),
            isDark: isDark,
            activeColor: teal,
            activeColorEnd: teal,
          ),
          SizedBox(width: 10.w),
          AppFilterChip(
            label: l10n.jobFilterHistory,
            isActive: false,
            onTap: _onHistoryTap,
            isDark: isDark,
            activeColor: teal,
            activeColorEnd: teal,
          ),
        ],
      ),
    );
  }

  Widget buildJobCard(BuildContext context, JobModel job) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return _JobCard(
      job: job,
      isDark: isDark,
      teal: teal,
      onTap: () {
        if (job.status == JobStatus.active) {
          Navigator.of(
            context,
          ).pushNamed(AppRoutes.handymanViewActiveJob, arguments: job.id);
        } else {
          Navigator.of(
            context,
          ).pushNamed(AppRoutes.handymanViewNewRequest, arguments: job.id);
        }
      },
    );
  }

  Widget buildEmptyState(AppLocalizations l10n) {
    return AppEmptyState(
      icon: Icons.work_off_outlined,
      title: l10n.jobsEmptyTitle,
      subtitle: l10n.jobsEmptySubtitle,
      color: teal,
    );
  }
}

// ══════════════════════════════════════════════════════════════
// HandymanJobsMobileBody
// ══════════════════════════════════════════════════════════════
class HandymanJobsMobileBody extends StatefulWidget {
  const HandymanJobsMobileBody({super.key});

  @override
  State<HandymanJobsMobileBody> createState() => _HandymanJobsMobileBodyState();
}

class _HandymanJobsMobileBodyState extends _JobsBase<HandymanJobsMobileBody> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    final jobs = filteredJobs;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppMainBackground(
        child: CustomScrollView(
          slivers: [
            // Header
            SliverToBoxAdapter(child: ea(0, buildHeader(context, l10n))),

            // Jobs list or empty
            jobs.isEmpty
                ? SliverFillRemaining(child: ea(1, buildEmptyState(l10n)))
                : SliverPadding(
                    padding: EdgeInsets.fromLTRB(
                      AppSpacing.xl.w,
                      AppSpacing.lg.h,
                      AppSpacing.xl.w,
                      MediaQuery.of(context).padding.bottom + 100.h,
                    ),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (_, i) => ea(
                          (i % 4) + 1,
                          Padding(
                            padding: EdgeInsets.only(bottom: 16.h),
                            child: buildJobCard(context, jobs[i]),
                          ),
                        ),
                        childCount: jobs.length,
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
// HandymanJobsTabletBody
// Left panel (40%): header + stats | Right panel (60%): jobs list
// ══════════════════════════════════════════════════════════════
class HandymanJobsTabletBody extends StatefulWidget {
  const HandymanJobsTabletBody({super.key});

  @override
  State<HandymanJobsTabletBody> createState() => _HandymanJobsTabletBodyState();
}

class _HandymanJobsTabletBodyState extends _JobsBase<HandymanJobsTabletBody> {
  // Additional tablet-only animations
  late final AnimationController _floatCtrl;
  late final Animation<double> _floatY;

  @override
  void initState() {
    super.initState();
    _floatCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat(reverse: true);
    _floatY = Tween<double>(
      begin: -4.0,
      end: 4.0,
    ).animate(CurvedAnimation(parent: _floatCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _floatCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    final jobs = filteredJobs;
    final bottom = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppMainBackground(
        child: Column(
          children: [
            // Header at top
            ea(0, buildHeader(context, l10n)),

            // Two-column layout
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Left panel: stats & summary (38%) ─────
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.38,
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(AppSpacing.xl.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Stats summary card
                          ea(1, _buildStatsCard(isDark, l10n)),

                          SizedBox(height: 20.h),

                          // Today's schedule
                          ea(2, _buildSchedulePreview(isDark, l10n, jobs)),
                        ],
                      ),
                    ),
                  ),

                  // Divider
                  VerticalDivider(width: 1, color: teal.withOpacity(0.08)),

                  // ── Right panel: jobs list (62%) ───────────
                  Expanded(
                    child: jobs.isEmpty
                        ? ea(3, buildEmptyState(l10n))
                        : CustomScrollView(
                            slivers: [
                              SliverPadding(
                                padding: EdgeInsets.fromLTRB(
                                  AppSpacing.xl.w,
                                  AppSpacing.lg.h,
                                  AppSpacing.xl.w,
                                  bottom + 32.h,
                                ),
                                sliver: SliverList(
                                  delegate: SliverChildBuilderDelegate(
                                    (_, i) => ea(
                                      (i % 3) + 3,
                                      Padding(
                                        padding: EdgeInsets.only(bottom: 16.h),
                                        child: buildJobCard(context, jobs[i]),
                                      ),
                                    ),
                                    childCount: jobs.length,
                                  ),
                                ),
                              ),
                            ],
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

  Widget _buildStatsCard(bool isDark, AppLocalizations l10n) {
    final activeCount =
        _jobs?.where((j) => j.status == JobStatus.active).length ?? 0;
    final scheduledCount =
        _jobs?.where((j) => j.status == JobStatus.scheduled).length ?? 0;

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [teal, AppColors.accent[70] ?? teal],
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
              Icon(Icons.analytics_rounded, size: 18.sp, color: Colors.white70),
              SizedBox(width: 8.w),
              Text(
                'نظرة عامة',
                style: GoogleFonts.cairo(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.white.withOpacity(0.85),
                ),
              ),
            ],
          ),
          SizedBox(height: 18.h),
          Row(
            children: [
              Expanded(
                child: _StatItem(
                  value: '$activeCount',
                  label: l10n.jobStatusActive,
                  icon: Icons.access_time_rounded,
                ),
              ),
              Container(width: 1, height: 50.h, color: Colors.white24),
              Expanded(
                child: _StatItem(
                  value: '$scheduledCount',
                  label: l10n.jobStatusScheduled,
                  icon: Icons.calendar_today_rounded,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSchedulePreview(
    bool isDark,
    AppLocalizations l10n,
    List<JobModel> jobs,
  ) {
    final todayJobs = jobs.where((j) => j.date == l10n.jobToday).toList();

    return Container(
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: teal.withOpacity(0.10)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.today_rounded, size: 18.sp, color: teal),
              SizedBox(width: 8.w),
              Text(
                'جدول اليوم',
                style: GoogleFonts.cairo(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              AnimatedBuilder(
                animation: _floatCtrl,
                builder: (_, child) => Transform.translate(
                  offset: Offset(0, _floatY.value),
                  child: child,
                ),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 4.h,
                  ),
                  decoration: BoxDecoration(
                    color: teal.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    '${todayJobs.length} ${l10n.handymanAboutTitle}'.replaceAll(
                      'مهامي',
                      'مهمة',
                    ),
                    style: GoogleFonts.cairo(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w700,
                      color: teal,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          if (todayJobs.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 20.h),
              child: Center(
                child: Text(
                  'لا توجد مهام لليوم',
                  style: GoogleFonts.cairo(
                    fontSize: 13.sp,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.textSecondary,
                  ),
                ),
              ),
            )
          else
            ...todayJobs
                .take(3)
                .map(
                  (job) => _ScheduleItem(
                    job: job,
                    teal: teal,
                    isLast: job == todayJobs.take(3).last,
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

// ── Quick stat badge for header ───────────────────────────────
class _QuickStatBadge extends StatefulWidget {
  final int count;
  final String label;
  final Color color;
  final bool isDark;

  const _QuickStatBadge({
    required this.count,
    required this.label,
    required this.color,
    required this.isDark,
  });

  @override
  State<_QuickStatBadge> createState() => _QuickStatBadgeState();
}

class _QuickStatBadgeState extends State<_QuickStatBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scale = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut));
    Future.delayed(const Duration(milliseconds: 400), () {
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
    return ScaleTransition(
      scale: _scale,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: widget.color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: widget.color.withOpacity(0.25)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${widget.count}',
              style: GoogleFonts.cairo(
                fontSize: 18.sp,
                fontWeight: FontWeight.w800,
                color: widget.color,
              ),
            ),
            SizedBox(width: 6.w),
            Text(
              widget.label,
              style: GoogleFonts.cairo(
                fontSize: 11.sp,
                fontWeight: FontWeight.w600,
                color: widget.color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Stat item for tablet stats card ───────────────────────────
class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;

  const _StatItem({
    required this.value,
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 20.sp, color: Colors.white70),
        SizedBox(height: 8.h),
        Text(
          value,
          style: GoogleFonts.cairo(
            fontSize: 24.sp,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          label,
          style: GoogleFonts.cairo(
            fontSize: 11.sp,
            color: Colors.white.withOpacity(0.80),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

// ── Schedule item for tablet preview ──────────────────────────
class _ScheduleItem extends StatefulWidget {
  final JobModel job;
  final Color teal;
  final bool isLast;

  const _ScheduleItem({
    required this.job,
    required this.teal,
    required this.isLast,
  });

  @override
  State<_ScheduleItem> createState() => _ScheduleItemState();
}

class _ScheduleItemState extends State<_ScheduleItem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scale = Tween<double>(
      begin: 1.0,
      end: 0.97,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        Navigator.of(
          context,
        ).pushNamed(AppRoutes.handymanViewActiveJob, arguments: widget.job.id);
      },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          margin: EdgeInsets.only(bottom: widget.isLast ? 0 : 10.h),
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: widget.teal.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: widget.teal.withOpacity(0.10)),
          ),
          child: Row(
            children: [
              Container(
                width: 36.w,
                height: 36.w,
                decoration: BoxDecoration(
                  color: widget.job.customerAvatarColor,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(
                  Icons.person_rounded,
                  size: 18.sp,
                  color: Colors.white,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.job.title,
                      style: textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      '${widget.job.time} • ${widget.job.location}',
                      style: textTheme.labelSmall?.copyWith(color: widget.teal),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_left_rounded, size: 18.sp, color: widget.teal),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Job card with animations ──────────────────────────────────
class _JobCard extends StatefulWidget {
  final JobModel job;
  final bool isDark;
  final Color teal;
  final VoidCallback onTap;

  const _JobCard({
    required this.job,
    required this.isDark,
    required this.teal,
    required this.onTap,
  });

  @override
  State<_JobCard> createState() => _JobCardState();
}

class _JobCardState extends State<_JobCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pressCtrl;
  late final Animation<double> _pressScale;

  @override
  void initState() {
    super.initState();
    _pressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _pressScale = Tween<double>(
      begin: 1.0,
      end: 0.97,
    ).animate(CurvedAnimation(parent: _pressCtrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _pressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final isActive = widget.job.status == JobStatus.active;
    final cardBg = widget.isDark ? AppColors.darkSurface : Colors.white;

    return GestureDetector(
      onTapDown: (_) => _pressCtrl.forward(),
      onTapUp: (_) {
        _pressCtrl.reverse();
        HapticFeedback.lightImpact();
        widget.onTap();
      },
      onTapCancel: () => _pressCtrl.reverse(),
      child: ScaleTransition(
        scale: _pressScale,
        child: Container(
          padding: EdgeInsets.all(18.w),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(18.r),
            border: Border.all(color: widget.teal.withOpacity(0.10)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(widget.isDark ? 0.20 : 0.06),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header row ──────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '#${widget.job.id}',
                    style: GoogleFonts.cairo(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  _StatusBadge(status: widget.job.status, teal: widget.teal),
                ],
              ),
              SizedBox(height: 12.h),

              // ── Title ────────────────────────────────────────
              Text(
                widget.job.title,
                style: textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: 14.h),

              // ── Detail chips ─────────────────────────────────
              Wrap(
                spacing: 12.w,
                runSpacing: 8.h,
                children: [
                  _DetailChip(
                    icon: Icons.calendar_today_rounded,
                    label: widget.job.date,
                    teal: widget.teal,
                  ),
                  _DetailChip(
                    icon: Icons.access_time_rounded,
                    label: widget.job.time,
                    teal: widget.teal,
                  ),
                  _DetailChip(
                    icon: Icons.location_on_outlined,
                    label: widget.job.location,
                    teal: widget.teal,
                  ),
                  _DetailChip(
                    icon: Icons.payments_outlined,
                    label: widget.job.price,
                    teal: widget.teal,
                  ),
                ],
              ),
              SizedBox(height: 14.h),

              // ── Customer row ─────────────────────────────────
              _CustomerRow(
                job: widget.job,
                isDark: widget.isDark,
                teal: widget.teal,
              ),
              SizedBox(height: 14.h),

              // ── Action buttons ───────────────────────────────
              _ActionButtons(
                job: widget.job,
                teal: widget.teal,
                onTap: widget.onTap,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Status badge ──────────────────────────────────────────────
class _StatusBadge extends StatelessWidget {
  final JobStatus status;
  final Color teal;

  const _StatusBadge({required this.status, required this.teal});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isActive = status == JobStatus.active;
    final color = isActive ? const Color(0xFFFF6B35) : teal;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isActive ? Icons.access_time_rounded : Icons.calendar_month_rounded,
            size: 13.sp,
            color: color,
          ),
          SizedBox(width: 5.w),
          Text(
            isActive ? l10n.jobStatusActive : l10n.jobStatusScheduled,
            style: GoogleFonts.cairo(
              fontSize: 11.sp,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Detail chip ───────────────────────────────────────────────
class _DetailChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color teal;

  const _DetailChip({
    required this.icon,
    required this.label,
    required this.teal,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14.sp, color: teal),
        SizedBox(width: 5.w),
        Text(
          label,
          style: GoogleFonts.cairo(
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

// ── Customer row ──────────────────────────────────────────────
class _CustomerRow extends StatelessWidget {
  final JobModel job;
  final bool isDark;
  final Color teal;

  const _CustomerRow({
    required this.job,
    required this.isDark,
    required this.teal,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: teal.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 44.w,
            height: 44.w,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  job.customerAvatarColor,
                  job.customerAvatarColor.withOpacity(0.7),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(Icons.person_rounded, size: 22.sp, color: Colors.white),
          ),
          SizedBox(width: 12.w),

          // Name + type
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  job.customerName,
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 2.h),
                Row(
                  children: [
                    if (job.isReturningCustomer) ...[
                      Icon(
                        Icons.star_rounded,
                        size: 12.sp,
                        color: AppColors.star,
                      ),
                      SizedBox(width: 3.w),
                    ],
                    Text(
                      job.customerType,
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Call button
          _CallButton(teal: teal),
        ],
      ),
    );
  }
}

// ── Call button with animation ─────────────────────────────────
class _CallButton extends StatefulWidget {
  final Color teal;

  const _CallButton({required this.teal});

  @override
  State<_CallButton> createState() => _CallButtonState();
}

class _CallButtonState extends State<_CallButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scale = Tween<double>(
      begin: 1.0,
      end: 0.92,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        _ctrl.forward();
        HapticFeedback.lightImpact();
      },
      onTapUp: (_) => _ctrl.reverse(),
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          padding: EdgeInsets.all(10.w),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [widget.teal, AppColors.accent[70] ?? widget.teal],
            ),
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: [
              BoxShadow(
                color: widget.teal.withOpacity(0.25),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Icon(Icons.phone_rounded, size: 18.sp, color: Colors.white),
        ),
      ),
    );
  }
}

// ── Action buttons ─────────────────────────────────────────────
class _ActionButtons extends StatelessWidget {
  final JobModel job;
  final Color teal;
  final VoidCallback onTap;

  const _ActionButtons({
    required this.job,
    required this.teal,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isActive = job.status == JobStatus.active;

    if (isActive) {
      return Row(
        children: [
          Expanded(
            child: _ActionButton(
              label: l10n.jobCompleteBtn,
              isPrimary: true,
              teal: teal,
              onTap: () => Navigator.of(
                context,
              ).pushNamed(AppRoutes.handymanUpdateJobStatus, arguments: job.id),
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: _ActionButton(
              label: l10n.jobDetailsBtn,
              isPrimary: false,
              teal: teal,
              onTap: onTap,
            ),
          ),
        ],
      );
    }

    return _ActionButton(
      label: l10n.jobViewDetailsBtn,
      isPrimary: false,
      teal: teal,
      fullWidth: true,
      onTap: onTap,
    );
  }
}

// ── Action button with press animation ─────────────────────────
class _ActionButton extends StatefulWidget {
  final String label;
  final bool isPrimary;
  final Color teal;
  final bool fullWidth;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.isPrimary,
    required this.teal,
    required this.onTap,
    this.fullWidth = false,
  });

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scale = Tween<double>(
      begin: 1.0,
      end: 0.96,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accent = AppColors.accent[70] ?? widget.teal;

    return GestureDetector(
      onTapDown: (_) {
        _ctrl.forward();
        HapticFeedback.selectionClick();
      },
      onTapUp: (_) {
        _ctrl.reverse();
        widget.onTap();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          width: widget.fullWidth ? double.infinity : null,
          padding: EdgeInsets.symmetric(vertical: 12.h),
          decoration: BoxDecoration(
            gradient: widget.isPrimary
                ? LinearGradient(colors: [widget.teal, accent])
                : null,
            color: widget.isPrimary ? null : widget.teal.withOpacity(0.10),
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: widget.isPrimary
                ? [
                    BoxShadow(
                      color: widget.teal.withOpacity(0.25),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              widget.label,
              style: GoogleFonts.cairo(
                fontSize: 13.sp,
                fontWeight: FontWeight.w700,
                color: widget.isPrimary ? Colors.white : widget.teal,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
