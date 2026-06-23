import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/l10n/translation/app_localizations.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/utils/widgets/app_main_background.dart';
import '../../../../core/utils/widgets/animations/animated_confirm_dialog.dart';
import '../../../../core/utils/widgets/animations/app_motion.dart';
import '../../../../core/utils/widgets/app_empty_states.dart';
import '../../../../core/utils/widgets/cards/app_handyman_request_card.dart';

// ══════════════════════════════════════════════════════════════
//  HANDYMAN HOME VIEW  —  Rebuilt Edition
// ══════════════════════════════════════════════════════════════
//  Features:
//  ✓ Adaptive: mobile (scroll) / tablet (side panel, 44/56 split)
//  ✓ RTL-aware (AR / EN) — uses Directionality.of()
//  ✓ Full Light + Dark theme via AppColors
//  ✓ 5-section stagger entry (FadeTransition + SlideTransition)
//  ✓ Bell shake animation (2 s delay, then periodic)
//  ✓ Animated availability toggle with pop-scale + pulsing dot
//  ✓ Next-job hero card with glassmorphism + gradient text
//  ✓ Quick-actions strip (4 shortcuts)
//  ✓ Weekly earnings mini-bar-chart (CustomPaint, animated reveal)
//  ✓ Rating stat card with radial ring (CustomPainter)
//  ✓ Decorative header SVG circles
//
//  REUSABLE WIDGETS — move to lib/core/utils/widgets/:
//   • _HomeStatCard         → app_stat_card.dart
//   • _HomePulsingDot       → app_pulsing_dot.dart
//   • _HomeAnimatedSwitch   → app_animated_switch.dart
//   • _HomeQuickActionBtn   → app_quick_action_btn.dart
//   • _HomeWeeklyChart      → app_weekly_chart.dart
//   • _HomeGlassCard        → app_glass_card.dart
// ══════════════════════════════════════════════════════════════

// ─────────────────────────────────────────────────────────────
// Local mock model  (replace with BLoC / Riverpod state)
// ─────────────────────────────────────────────────────────────
class _Request {
  final String id, title, date, time, area, rate;
  final String customerName, customerSub, description;
  final List<Color> avatarColors;
  const _Request({
    required this.id,
    required this.title,
    required this.date,
    required this.time,
    required this.area,
    required this.rate,
    required this.customerName,
    required this.customerSub,
    required this.description,
    required this.avatarColors,
  });
}

const _kRequests = [
  _Request(
    id: 'REQ-00124',
    title: 'Plumbing — General Maintenance',
    date: '12/02/2026',
    time: '10:00 AM',
    area: 'Nasr City',
    rate: '150 EGP/hr',
    customerName: 'Ahmed Mahmoud',
    customerSub: 'New customer',
    description: 'Kitchen faucet leak that needs urgent repair...',
    avatarColors: [Color(0xFF667eea), Color(0xFF764ba2)],
  ),
  _Request(
    id: 'REQ-00125',
    title: 'Plumbing — Installation',
    date: '12/02/2026',
    time: '2:00 PM',
    area: 'Maadi',
    rate: '150 EGP/hr',
    customerName: 'Sara Ahmed',
    customerSub: 'Regular • 3 previous orders',
    description: 'Install a new water heater in the bathroom...',
    avatarColors: [Color(0xFFe74c3c), Color(0xFFc0392b)],
  ),
  _Request(
    id: 'REQ-00126',
    title: 'Electrical — Wiring Fix',
    date: '13/02/2026',
    time: '11:00 AM',
    area: 'Heliopolis',
    rate: '200 EGP/hr',
    customerName: 'Khaled Ibrahim',
    customerSub: 'New customer',
    description: 'Short circuit in the living room panel...',
    avatarColors: [Color(0xFF11998e), Color(0xFF38ef7d)],
  ),
];

// Weekly earnings data (Sun–Sat)
const _kWeeklyData = [420.0, 680.0, 310.0, 890.0, 560.0, 1200.0, 750.0];
const _kWeekDays = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

// ─────────────────────────────────────────────────────────────
// Root widget — layout router
// ─────────────────────────────────────────────────────────────
class HandymanHomeView extends StatelessWidget {
  const HandymanHomeView({super.key});

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (_, c) =>
        c.maxWidth >= 600 ? const _TabletBody() : const _MobileBody(),
  );
}

// ─────────────────────────────────────────────────────────────
// Shared state base
// ─────────────────────────────────────────────────────────────
abstract class _HomeBase<T extends StatefulWidget> extends State<T>
    with TickerProviderStateMixin {
  Color get teal => AppColors.accent[60]!;
  Color get tealLight => AppColors.accent[30]!;
  Color get tealDark => AppColors.accent[80]!;

  bool isAvailable = true;
  final requests = _kRequests;

  // 5-section stagger
  late final AnimationController _entryCtrl;
  static const _kN = 5;
  late final List<Animation<double>> _fade;
  late final List<Animation<Offset>> _slide;

  // Bell shake
  late final AnimationController _bellCtrl;
  late final Animation<double> _bellShake;

  // Toggle scale-pop
  late final AnimationController _toggleCtrl;
  late final Animation<double> _toggleScale;

  // Chart bar-reveal
  late final AnimationController _chartCtrl;
  late final Animation<double> _chartReveal;

  @override
  void initState() {
    super.initState();

    // ── Entry stagger (700 ms) ─────────────────────────────
    _entryCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fade = List.generate(_kN, (i) {
      final s = (i * 0.13).clamp(0.0, 1.0);
      return Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
          parent: _entryCtrl,
          curve: Interval(s, (s + 0.45).clamp(0, 1), curve: Curves.easeOut),
        ),
      );
    });
    _slide = List.generate(_kN, (i) {
      final s = (i * 0.13).clamp(0.0, 1.0);
      return Tween<Offset>(
        begin: const Offset(0, 0.12),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: _entryCtrl,
          curve: Interval(
            s,
            (s + 0.50).clamp(0, 1),
            curve: Curves.easeOutCubic,
          ),
        ),
      );
    });
    _entryCtrl.forward();

    // ── Bell shake ─────────────────────────────────────────
    _bellCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    _bellShake = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 0.10), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 0.10, end: -0.08), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -0.08, end: 0.06), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 0.06, end: -0.03), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -0.03, end: 0.00), weight: 1),
    ]).animate(CurvedAnimation(parent: _bellCtrl, curve: Curves.easeInOut));
    Future.delayed(const Duration(seconds: 2), _ringBell);

    // ── Toggle pop ─────────────────────────────────────────
    _toggleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
    _toggleScale = Tween<double>(
      begin: 1.0,
      end: 1.06,
    ).animate(CurvedAnimation(parent: _toggleCtrl, curve: Curves.easeOutBack));

    // ── Chart reveal ───────────────────────────────────────
    _chartCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _chartReveal = CurvedAnimation(
      parent: _chartCtrl,
      curve: Curves.easeOutCubic,
    );
    Future.delayed(const Duration(milliseconds: 450), () {
      if (mounted) _chartCtrl.forward();
    });
  }

  @override
  void dispose() {
    _entryCtrl.dispose();
    _bellCtrl.dispose();
    _toggleCtrl.dispose();
    _chartCtrl.dispose();
    super.dispose();
  }

  void _ringBell() {
    if (!mounted) return;
    _bellCtrl.forward(from: 0).then((_) => _bellCtrl.reverse());
  }

  /// Wrap widget in stagger fade+slide
  Widget sa(int i, Widget child) {
    final idx = i.clamp(0, _kN - 1);
    return FadeTransition(
      opacity: _fade[idx],
      child: SlideTransition(position: _slide[idx], child: child),
    );
  }

  void _onAccept(BuildContext ctx, AppLocalizations l10n, String id) {
    showAnimatedConfirmDialog(
      context: ctx,
      isDark: Theme.of(ctx).brightness == Brightness.dark,
      icon: Icons.check_circle_outline_rounded,
      title: l10n.requestAcceptTitle,
      message: l10n.requestAcceptMessage,
      cancelLabel: l10n.trackCancelKeep,
      confirmLabel: l10n.requestAcceptConfirmBtn,
      isDanger: false,
      confirmColor: teal,
      onConfirm: () =>
          Navigator.of(ctx).pushNamed(AppRoutes.handymanActiveJobs),
    );
  }

  // ══════════════════════════════════════════════════════
  // S0 — HEADER
  // ══════════════════════════════════════════════════════
  Widget buildHeader(BuildContext ctx, AppLocalizations l10n) {
    final isAr = Directionality.of(ctx) == TextDirection.rtl;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [teal, AppColors.accent[70]!, tealDark],
          stops: const [0, 0.55, 1],
        ),
        boxShadow: [
          BoxShadow(
            color: teal.withOpacity(0.35),
            blurRadius: 28,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Decorative bg circles
          Positioned(
            top: -30,
            right: isAr ? null : -20,
            left: isAr ? -20 : null,
            child: Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.06),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: isAr ? null : 40,
            right: isAr ? 40 : null,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.04),
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.xl.w,
                AppSpacing.md.h,
                AppSpacing.xl.w,
                AppSpacing.xl.h,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile + bell
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _HeaderProfile(
                        greeting: l10n.handymanGreeting,
                        name: isAr ? 'محمد' : 'Mohammed',
                        onTap: () => Navigator.of(
                          ctx,
                        ).pushNamed(AppRoutes.handymanProfile),
                      ),
                      _HeaderBell(
                        bellShake: _bellShake,
                        badge: '3',
                        onTap: () {
                          HapticFeedback.lightImpact();
                          Navigator.of(
                            ctx,
                          ).pushNamed(AppRoutes.handymanNotifications);
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: AppSpacing.lg.h),

                  // Bento stat cards
                  Row(
                    children: [
                      Expanded(
                        child: _HomeStatCard(
                          value: isAr ? '١٢٠٠ ج' : '1,200 EGP',
                          label: l10n.handymanStatEarnings,
                          icon: Icons.account_balance_wallet_rounded,
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: _HomeStatCard(
                          value: isAr ? '٢٤' : '24',
                          label: l10n.handymanStatCompleted,
                          icon: Icons.check_circle_outline_rounded,
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: _RatingStatCard(
                          rating: 4.9,
                          label: l10n.handymanStatRating,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════
  // S1 — AVAILABILITY TOGGLE
  // ══════════════════════════════════════════════════════
  Widget buildToggle(BuildContext ctx, AppLocalizations l10n) {
    final isDark = Theme.of(ctx).brightness == Brightness.dark;

    return ScaleTransition(
      scale: _toggleScale,
      child: _HomeGlassCard(
        margin: EdgeInsets.fromLTRB(
          AppSpacing.xl.w,
          0,
          AppSpacing.xl.w,
          AppSpacing.sm.h,
        ),
        isDark: isDark,
        child: Row(
          children: [
            _HomePulsingDot(isActive: isAvailable),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isAvailable
                        ? l10n.handymanAvailableTitle
                        : l10n.handymanUnavailableTitle,
                    style: GoogleFonts.cairo(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    isAvailable
                        ? l10n.handymanAvailableSubtitle
                        : l10n.handymanUnavailableSubtitle,
                    style: GoogleFonts.cairo(
                      fontSize: 11.sp,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            _HomeAnimatedSwitch(
              value: isAvailable,
              activeColor: teal,
              onChanged: (v) {
                HapticFeedback.selectionClick();
                _toggleCtrl.forward(from: 0).then((_) => _toggleCtrl.reverse());
                setState(() => isAvailable = v);
              },
            ),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════
  // S2 — HERO CARD (next job)
  // ══════════════════════════════════════════════════════
  Widget buildHeroCard(BuildContext ctx, AppLocalizations l10n) {
    final isDark = Theme.of(ctx).brightness == Brightness.dark;
    final isAr = Directionality.of(ctx) == TextDirection.rtl;

    return _HomeGlassCard(
      margin: EdgeInsets.fromLTRB(
        AppSpacing.xl.w,
        0,
        AppSpacing.xl.w,
        AppSpacing.md.h,
      ),
      isDark: isDark,
      borderColor: teal.withOpacity(0.22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Badge
          _GradientBadge(
            label: l10n.handymanNextJobLabel,
            icon: Icons.bolt_rounded,
            colors: [teal, tealLight],
          ),
          SizedBox(height: 14.h),

          // Gradient text title
          ShaderMask(
            shaderCallback: (b) =>
                LinearGradient(colors: [teal, tealDark]).createShader(b),
            child: Text(
              isAr
                  ? '١٠:٠٠ ص — سباكة / صيانة عامة'
                  : '10:00 AM — Plumbing / Maintenance',
              style: GoogleFonts.cairo(
                fontSize: 18.sp,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(height: 10.h),

          // Location + status badge
          Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                size: 15.sp,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.textSecondary,
              ),
              SizedBox(width: 5.w),
              Expanded(
                child: Text(
                  isAr ? 'أحمد محمود — مدينة نصر' : 'Ahmed Mahmoud — Nasr City',
                  style: GoogleFonts.cairo(
                    fontSize: 13.sp,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.textSecondary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkActiveBg : AppColors.activeBg,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  isAr ? 'جارية' : 'Active',
                  style: GoogleFonts.cairo(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? AppColors.darkActiveText
                        : AppColors.activeText,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: AppTapScale(
                  onTap: () =>
                      Navigator.of(ctx).pushNamed(AppRoutes.handymanActiveJobs),
                  child: _GradientButton(
                    label: l10n.handymanHeroNavigate,
                    icon: Icons.navigation_rounded,
                    colors: [teal, AppColors.accent[70]!],
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: AppTapScale(
                  onTap: () => Navigator.of(ctx).pushNamed(
                    AppRoutes.handymanViewNewRequest,
                    arguments: 'REQ-00124',
                  ),
                  child: _OutlineButton(
                    label: l10n.handymanHeroDetails,
                    icon: Icons.info_outline_rounded,
                    color: teal,
                    isDark: isDark,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════
  // S3 — QUICK ACTIONS STRIP
  // ══════════════════════════════════════════════════════
  Widget buildQuickActions(BuildContext ctx, AppLocalizations l10n) {
    final isDark = Theme.of(ctx).brightness == Brightness.dark;
    final isAr = Directionality.of(ctx) == TextDirection.rtl;

    final actions = [
      (
        Icons.work_history_rounded,
        isAr ? 'الوظائف' : 'My Jobs',
        AppRoutes.handymanActiveJobs,
      ),
      (
        Icons.photo_library_rounded,
        isAr ? 'بورتفوليو' : 'Portfolio',
        AppRoutes.handymanManagePortfolio,
      ),
      (
        Icons.star_rate_rounded,
        isAr ? 'مراجعاتي' : 'Reviews',
        AppRoutes.handymanOwnReviews,
      ),
      (
        Icons.task_alt_rounded,
        isAr ? 'مكتملة' : 'Completed',
        AppRoutes.handymanCompletedJobs,
      ),
    ];

    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.xl.w,
        0,
        AppSpacing.xl.w,
        AppSpacing.md.h,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: actions
            .map(
              (a) => _HomeQuickActionBtn(
                icon: a.$1,
                label: a.$2,
                isDark: isDark,
                teal: teal,
                onTap: () => Navigator.of(ctx).pushNamed(a.$3),
              ),
            )
            .toList(),
      ),
    );
  }

  // ══════════════════════════════════════════════════════
  // S4 — WEEKLY CHART
  // ══════════════════════════════════════════════════════
  Widget buildWeeklyChart(BuildContext ctx, AppLocalizations l10n) {
    final isDark = Theme.of(ctx).brightness == Brightness.dark;
    final isAr = Directionality.of(ctx) == TextDirection.rtl;

    return _HomeGlassCard(
      margin: EdgeInsets.fromLTRB(
        AppSpacing.xl.w,
        0,
        AppSpacing.xl.w,
        AppSpacing.lg.h,
      ),
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isAr ? 'أرباح الأسبوع' : 'Weekly Earnings',
                style: GoogleFonts.cairo(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w700,
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.textPrimary,
                ),
              ),
              Text(
                isAr ? '٤٨١٠ ج' : '4,810 EGP',
                style: GoogleFonts.cairo(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w800,
                  color: teal,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          SizedBox(
            height: 92.h,
            child: AnimatedBuilder(
              animation: _chartReveal,
              builder: (_, __) => _HomeWeeklyChart(
                data: _kWeeklyData,
                days: _kWeekDays,
                teal: teal,
                isDark: isDark,
                progress: _chartReveal.value,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Section title bar ──────────────────────────────────
  Widget buildSectionTitle(BuildContext ctx, AppLocalizations l10n) {
    final isAr = Directionality.of(ctx) == TextDirection.rtl;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.xl.w,
        0,
        AppSpacing.xl.w,
        AppSpacing.md.h,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            l10n.requestNewSectionTitle,
            style: GoogleFonts.cairo(
              fontSize: 17.sp,
              fontWeight: FontWeight.w800,
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: teal.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Text(
              isAr ? '${requests.length} طلبات' : '${requests.length} requests',
              style: GoogleFonts.cairo(
                fontSize: 11.sp,
                fontWeight: FontWeight.w600,
                color: teal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Request card delegate ──────────────────────────────
  Widget buildRequestCard(
    BuildContext ctx,
    AppLocalizations l10n,
    _Request r,
    bool isDark,
  ) {
    return AppHandymanRequestCard(
      requestId: r.id,
      title: r.title,
      date: r.date,
      time: r.time,
      area: r.area,
      rate: r.rate,
      customerName: r.customerName,
      customerSub: r.customerSub,
      description: r.description,
      avatarColors: r.avatarColors,
      isDark: isDark,
      newLabel: l10n.requestNewLabel,
      acceptLabel: l10n.requestAcceptBtn,
      detailsLabel: l10n.requestDetailsBtn,
      onAccept: () => _onAccept(ctx, l10n, r.id),
      onDetails: () => Navigator.of(
        ctx,
      ).pushNamed(AppRoutes.handymanViewNewRequest, arguments: r.id),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// MOBILE — vertical scroll
// ══════════════════════════════════════════════════════════════
class _MobileBody extends StatefulWidget {
  const _MobileBody();
  @override
  State<_MobileBody> createState() => _MobileBodyState();
}

class _MobileBodyState extends _HomeBase<_MobileBody> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppMainBackground(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: buildHeader(context, l10n)),

            SliverToBoxAdapter(
              child: Transform.translate(
                offset: Offset(0, -20.h),
                child: sa(0, buildToggle(context, l10n)),
              ),
            ),

            SliverToBoxAdapter(child: sa(1, buildHeroCard(context, l10n))),
            SliverToBoxAdapter(child: sa(2, buildQuickActions(context, l10n))),
            SliverToBoxAdapter(child: sa(3, buildWeeklyChart(context, l10n))),
            SliverToBoxAdapter(child: sa(4, buildSectionTitle(context, l10n))),

            if (requests.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: AppEmptyState(
                    icon: Icons.inbox_outlined,
                    title: l10n.requestEmptyTitle,
                    subtitle: l10n.requestEmptySubtitle,
                    color: teal,
                  ),
                ),
              )
            else
              SliverPadding(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.xl.w,
                  0,
                  AppSpacing.xl.w,
                  MediaQuery.of(context).padding.bottom + 100.h,
                ),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, i) => sa(
                      4,
                      Padding(
                        padding: EdgeInsets.only(bottom: 14.h),
                        child: buildRequestCard(
                          context,
                          l10n,
                          requests[i],
                          isDark,
                        ),
                      ),
                    ),
                    childCount: requests.length,
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
// TABLET — left panel 44% | right list 56%
// ══════════════════════════════════════════════════════════════
class _TabletBody extends StatefulWidget {
  const _TabletBody();
  @override
  State<_TabletBody> createState() => _TabletBodyState();
}

class _TabletBodyState extends _HomeBase<_TabletBody> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppMainBackground(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Left panel ────────────────────────────────
            SizedBox(
              width: width * 0.44,
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(child: buildHeader(context, l10n)),
                  SliverToBoxAdapter(
                    child: Transform.translate(
                      offset: Offset(0, -20.h),
                      child: sa(0, buildToggle(context, l10n)),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: sa(1, buildHeroCard(context, l10n)),
                  ),
                  SliverToBoxAdapter(
                    child: sa(2, buildQuickActions(context, l10n)),
                  ),
                  SliverToBoxAdapter(
                    child: sa(3, buildWeeklyChart(context, l10n)),
                  ),
                  SliverToBoxAdapter(child: SizedBox(height: 32.h)),
                ],
              ),
            ),

            VerticalDivider(
              width: 1,
              color: teal.withOpacity(0.10),
              thickness: 1,
            ),

            // ── Right: requests ───────────────────────────
            Expanded(
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: sa(
                      4,
                      Padding(
                        padding: EdgeInsets.fromLTRB(
                          AppSpacing.xl.w,
                          AppSpacing.xxl.h,
                          AppSpacing.xl.w,
                          AppSpacing.md.h,
                        ),
                        child: buildSectionTitle(context, l10n),
                      ),
                    ),
                  ),

                  if (requests.isEmpty)
                    SliverFillRemaining(
                      child: Center(
                        child: AppEmptyState(
                          icon: Icons.inbox_outlined,
                          title: l10n.requestEmptyTitle,
                          subtitle: l10n.requestEmptySubtitle,
                          color: teal,
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
                          (_, i) => sa(
                            4,
                            Padding(
                              padding: EdgeInsets.only(bottom: 14.h),
                              child: buildRequestCard(
                                context,
                                l10n,
                                requests[i],
                                isDark,
                              ),
                            ),
                          ),
                          childCount: requests.length,
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
//  REUSABLE WIDGETS
// ══════════════════════════════════════════════════════════════

// ─────────────────────────────────────────────────────────────
// _HeaderProfile  (header-only; can extract to shared)
// ─────────────────────────────────────────────────────────────
class _HeaderProfile extends StatelessWidget {
  final String greeting, name;
  final VoidCallback onTap;
  const _HeaderProfile({
    required this.greeting,
    required this.name,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => AppTapScale(
    onTap: onTap,
    child: Row(
      children: [
        Container(
          width: 48.w,
          height: 48.h,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.22),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withOpacity(0.6), width: 2),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 10),
            ],
          ),
          child: Icon(Icons.person_rounded, size: 24.sp, color: Colors.white),
        ),
        SizedBox(width: 12.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$greeting،',
              style: GoogleFonts.cairo(
                fontSize: 12.sp,
                color: Colors.white.withOpacity(0.88),
              ),
            ),
            Text(
              name,
              style: GoogleFonts.cairo(
                fontSize: 18.sp,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

// ─────────────────────────────────────────────────────────────
// _HeaderBell  (header-only)
// ─────────────────────────────────────────────────────────────
class _HeaderBell extends StatelessWidget {
  final Animation<double> bellShake;
  final String badge;
  final VoidCallback onTap;
  const _HeaderBell({
    required this.bellShake,
    required this.badge,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => AppTapScale(
    onTap: onTap,
    child: AnimatedBuilder(
      animation: bellShake,
      builder: (_, child) =>
          Transform.rotate(angle: bellShake.value, child: child),
      child: Stack(
        children: [
          Container(
            width: 48.w,
            height: 48.h,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.10),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Icon(
              Icons.notifications_outlined,
              size: 22.sp,
              color: Colors.white,
            ),
          ),
          Positioned(
            top: 6.h,
            right: 6.w,
            child: Container(
              width: 18.w,
              height: 18.h,
              decoration: BoxDecoration(
                color: const Color(0xFFff4757),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFff4757).withOpacity(0.45),
                    blurRadius: 6,
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  badge,
                  style: GoogleFonts.cairo(
                    fontSize: 9.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

// ─────────────────────────────────────────────────────────────
// _HomeStatCard  → lib/core/utils/widgets/app_stat_card.dart
// ─────────────────────────────────────────────────────────────
class _HomeStatCard extends StatelessWidget {
  final String value, label;
  final IconData icon;
  const _HomeStatCard({
    required this.value,
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.symmetric(vertical: 13.h, horizontal: 8.w),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.14),
      borderRadius: BorderRadius.circular(14.r),
      border: Border.all(color: Colors.white.withOpacity(0.22)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.08),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Column(
      children: [
        Icon(icon, size: 20.sp, color: Colors.white.withOpacity(0.9)),
        SizedBox(height: 6.h),
        Text(
          value,
          style: GoogleFonts.cairo(
            fontSize: 16.sp,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          label,
          style: GoogleFonts.cairo(
            fontSize: 9.5.sp,
            fontWeight: FontWeight.w600,
            color: Colors.white.withOpacity(0.85),
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    ),
  );
}

// ─────────────────────────────────────────────────────────────
// _RatingStatCard — radial ring  (can go in app_stat_card.dart)
// ─────────────────────────────────────────────────────────────
class _RatingStatCard extends StatelessWidget {
  final double rating;
  final String label;
  const _RatingStatCard({required this.rating, required this.label});

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.symmetric(vertical: 13.h, horizontal: 8.w),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.14),
      borderRadius: BorderRadius.circular(14.r),
      border: Border.all(color: Colors.white.withOpacity(0.22)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.08),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Column(
      children: [
        SizedBox(
          width: 34.w,
          height: 34.h,
          child: CustomPaint(
            painter: _RingPainter(
              progress: rating / 5.0,
              color: Colors.white,
              bg: Colors.white.withOpacity(0.25),
            ),
            child: Center(
              child: Icon(Icons.star_rounded, size: 14.sp, color: Colors.white),
            ),
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          '$rating',
          style: GoogleFonts.cairo(
            fontSize: 16.sp,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.cairo(
            fontSize: 9.5.sp,
            fontWeight: FontWeight.w600,
            color: Colors.white.withOpacity(0.85),
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    ),
  );
}

class _RingPainter extends CustomPainter {
  final double progress;
  final Color color, bg;
  const _RingPainter({
    required this.progress,
    required this.color,
    required this.bg,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final r = size.width / 2;
    final c = Offset(r, r);
    const stroke = 3.0;
    canvas.drawCircle(
      c,
      r - stroke / 2,
      Paint()
        ..color = bg
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke,
    );
    canvas.drawArc(
      Rect.fromCircle(center: c, radius: r - stroke / 2),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.progress != progress;
}

// ─────────────────────────────────────────────────────────────
// _HomeGlassCard  → lib/core/utils/widgets/app_glass_card.dart
// ─────────────────────────────────────────────────────────────
class _HomeGlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? margin;
  final bool isDark;
  final Color? borderColor;
  const _HomeGlassCard({
    required this.child,
    required this.isDark,
    this.margin,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) => Container(
    margin: margin,
    decoration: BoxDecoration(
      color: isDark
          ? AppColors.darkSurface.withOpacity(0.82)
          : Colors.white.withOpacity(0.88),
      borderRadius: BorderRadius.circular(18.r),
      border: Border.all(
        color:
            borderColor ??
            (isDark
                ? AppColors.darkBorder.withOpacity(0.40)
                : Colors.grey.shade200),
      ),
      boxShadow: [
        BoxShadow(
          color: isDark
              ? Colors.black.withOpacity(0.22)
              : Colors.black.withOpacity(0.06),
          blurRadius: 20,
          offset: const Offset(0, 6),
        ),
      ],
    ),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(18.r),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Padding(padding: EdgeInsets.all(18.w), child: child),
      ),
    ),
  );
}

// ─────────────────────────────────────────────────────────────
// _HomePulsingDot  → lib/core/utils/widgets/app_pulsing_dot.dart
// ─────────────────────────────────────────────────────────────
class _HomePulsingDot extends StatefulWidget {
  final bool isActive;
  const _HomePulsingDot({required this.isActive});
  @override
  State<_HomePulsingDot> createState() => _HomePulsingDotState();
}

class _HomePulsingDotState extends State<_HomePulsingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double> _a;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(seconds: 2))
      ..repeat(reverse: true);
    _a = Tween<double>(
      begin: 0.45,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _c, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.isActive ? AppColors.accent[60]! : AppColors.danger;
    return AnimatedBuilder(
      animation: _a,
      builder: (_, __) => Container(
        width: 13.w,
        height: 13.h,
        decoration: BoxDecoration(
          color: color.withOpacity(_a.value),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.38 * _a.value),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// _HomeAnimatedSwitch  → lib/core/utils/widgets/app_animated_switch.dart
// ─────────────────────────────────────────────────────────────
class _HomeAnimatedSwitch extends StatelessWidget {
  final bool value;
  final Color activeColor;
  final ValueChanged<bool> onChanged;
  const _HomeAnimatedSwitch({
    required this.value,
    required this.activeColor,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: () => onChanged(!value),
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      width: 54.w,
      height: 30.h,
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: value ? activeColor : Colors.grey.shade300,
        borderRadius: BorderRadius.circular(15.r),
        boxShadow: [
          BoxShadow(
            color: value
                ? activeColor.withOpacity(0.42)
                : Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: AnimatedAlign(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeInOut,
        alignment: value ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          width: 24.w,
          height: 24.h,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.14),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

// ─────────────────────────────────────────────────────────────
// _HomeQuickActionBtn  → lib/core/utils/widgets/app_quick_action_btn.dart
// ─────────────────────────────────────────────────────────────
class _HomeQuickActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDark;
  final Color teal;
  final VoidCallback onTap;
  const _HomeQuickActionBtn({
    required this.icon,
    required this.label,
    required this.isDark,
    required this.teal,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => AppTapScale(
    onTap: onTap,
    child: Column(
      children: [
        Container(
          width: 54.w,
          height: 54.h,
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.darkSurface.withOpacity(0.85)
                : Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: teal.withOpacity(0.18)),
            boxShadow: [
              BoxShadow(
                color: teal.withOpacity(0.10),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(icon, size: 24.sp, color: teal),
        ),
        SizedBox(height: 7.h),
        Text(
          label,
          style: GoogleFonts.cairo(
            fontSize: 10.sp,
            fontWeight: FontWeight.w600,
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    ),
  );
}

// ─────────────────────────────────────────────────────────────
// _HomeWeeklyChart  → lib/core/utils/widgets/app_weekly_chart.dart
// ─────────────────────────────────────────────────────────────
class _HomeWeeklyChart extends StatelessWidget {
  final List<double> data;
  final List<String> days;
  final Color teal;
  final bool isDark;
  final double progress; // 0..1
  const _HomeWeeklyChart({
    required this.data,
    required this.days,
    required this.teal,
    required this.isDark,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final maxVal = data.reduce(math.max);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(data.length, (i) {
        final ratio = data[i] / maxVal;
        final isToday = i == 5; // Friday
        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 50),
              width: 28.w,
              height: (ratio * progress * 68).h,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: isToday
                      ? [teal, AppColors.accent[40]!]
                      : [teal.withOpacity(0.28), teal.withOpacity(0.12)],
                ),
                borderRadius: BorderRadius.vertical(top: Radius.circular(6.r)),
                boxShadow: isToday
                    ? [
                        BoxShadow(
                          color: teal.withOpacity(0.35),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : [],
              ),
            ),
            SizedBox(height: 5.h),
            Text(
              days[i],
              style: GoogleFonts.cairo(
                fontSize: 10.sp,
                fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
                color: isToday
                    ? teal
                    : (isDark
                          ? AppColors.darkTextTertiary
                          : AppColors.textTertiary),
              ),
            ),
          ],
        );
      }),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// _GradientBadge  (shared inline helper)
// ─────────────────────────────────────────────────────────────
class _GradientBadge extends StatelessWidget {
  final String label;
  final IconData icon;
  final List<Color> colors;
  const _GradientBadge({
    required this.label,
    required this.icon,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
    decoration: BoxDecoration(
      gradient: LinearGradient(colors: colors),
      borderRadius: BorderRadius.circular(20.r),
      boxShadow: [
        BoxShadow(color: colors.first.withOpacity(0.30), blurRadius: 8),
      ],
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13.sp, color: Colors.white),
        SizedBox(width: 4.w),
        Text(
          label,
          style: GoogleFonts.cairo(
            fontSize: 11.sp,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            letterSpacing: 0.2,
          ),
        ),
      ],
    ),
  );
}

// ─────────────────────────────────────────────────────────────
// _GradientButton  (hero card button)
// ─────────────────────────────────────────────────────────────
class _GradientButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final List<Color> colors;
  const _GradientButton({
    required this.label,
    required this.icon,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.symmetric(vertical: 13.h),
    decoration: BoxDecoration(
      gradient: LinearGradient(colors: colors),
      borderRadius: BorderRadius.circular(13.r),
      boxShadow: [
        BoxShadow(
          color: colors.first.withOpacity(0.38),
          blurRadius: 14,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 16.sp, color: Colors.white),
        SizedBox(width: 6.w),
        Flexible(
          child: Text(
            label,
            style: GoogleFonts.cairo(
              fontSize: 13.sp,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    ),
  );
}

// ─────────────────────────────────────────────────────────────
// _OutlineButton  (hero card secondary button)
// ─────────────────────────────────────────────────────────────
class _OutlineButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool isDark;
  const _OutlineButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.symmetric(vertical: 13.h),
    decoration: BoxDecoration(
      color: isDark
          ? AppColors.darkSurface.withOpacity(0.55)
          : Colors.grey.shade50,
      borderRadius: BorderRadius.circular(13.r),
      border: Border.all(
        color: isDark
            ? AppColors.darkBorder.withOpacity(0.50)
            : Colors.grey.shade200,
      ),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 16.sp, color: color),
        SizedBox(width: 6.w),
        Flexible(
          child: Text(
            label,
            style: GoogleFonts.cairo(
              fontSize: 13.sp,
              fontWeight: FontWeight.w700,
              color: color,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    ),
  );
}
