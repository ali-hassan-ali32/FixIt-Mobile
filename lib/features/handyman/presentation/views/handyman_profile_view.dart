import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../config/di/di.dart';
import '../../../../core/l10n/translation/app_localizations.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/utils/functions/logout.dart';
import '../../../../core/utils/functions/remeber_me.dart';
import '../../../../core/utils/widgets/app_main_background.dart';
import '../../../../core/utils/widgets/animations/animated_confirm_dialog.dart';
import '../cubit/handyman_cubit.dart';
import '../cubit/handyman_state.dart';

// ══════════════════════════════════════════════════════════════
// HandymanProfileView — layout router
// ══════════════════════════════════════════════════════════════
class HandymanProfileView extends StatelessWidget {
  const HandymanProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<HandymanCubit>()
        ..getProfile()
        ..getStatistics(),
      child: LayoutBuilder(
        builder: (_, c) => c.maxWidth >= 600
            ? const _HandymanProfileTabletBody()
            : const _HandymanProfileMobileBody(),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// Shared base
// ══════════════════════════════════════════════════════════════
abstract class _ProfileBase<T extends StatefulWidget> extends State<T>
    with TickerProviderStateMixin {
  Color get teal => AppColors.accent[60]!;
  Color get tealDark => AppColors.accent[70]!;

  // ── Master animation controller ────────────────────────────
  late final AnimationController masterCtrl;

  // Hero animations
  late final Animation<double> avatarScale;
  late final Animation<double> avatarOpacity;
  late final Animation<Offset> nameSlide;
  late final Animation<double> nameOpacity;
  late final Animation<Offset> badgeSlide;
  late final Animation<double> badgeOpacity;

  // Stats (4 cards)
  late final List<Animation<double>> statOpacity;
  late final List<Animation<Offset>> statSlide;

  // Sections (7 blocks below stats)
  late final List<Animation<double>> secOpacity;
  late final List<Animation<Offset>> secSlide;

  @override
  void initState() {
    super.initState();
    // Profile & statistics are already triggered by BlocProvider.create
    // in HandymanProfileView — no need to call them again here.

    masterCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );

    final ease = CurveTween(curve: Curves.easeOutCubic);

    // Avatar: 0–300ms
    avatarScale = Tween<double>(begin: 0.55, end: 1.0).animate(
      CurvedAnimation(
        parent: masterCtrl,
        curve: const Interval(0.0, 0.22, curve: Curves.elasticOut),
      ),
    );
    avatarOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: masterCtrl,
        curve: const Interval(0.0, 0.18, curve: Curves.easeOut),
      ),
    );

    // Name: 150–450ms
    nameSlide = Tween<Offset>(begin: const Offset(0, 0.4), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: masterCtrl,
            curve: const Interval(0.10, 0.32, curve: Curves.easeOutCubic),
          ),
        );
    nameOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: masterCtrl,
        curve: const Interval(0.10, 0.28, curve: Curves.easeOut),
      ),
    );

    // Badge: 250–550ms
    badgeSlide = Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: masterCtrl,
            curve: const Interval(0.18, 0.40, curve: Curves.easeOutCubic),
          ),
        );
    badgeOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: masterCtrl,
        curve: const Interval(0.18, 0.36, curve: Curves.easeOut),
      ),
    );

    // Stats cards: staggered 400–900ms (4 × 60ms gap)
    statOpacity = List.generate(4, (i) {
      final start = 0.26 + i * 0.06;
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: masterCtrl,
          curve: Interval(start, start + 0.14, curve: Curves.easeOut),
        ),
      );
    });
    statSlide = List.generate(4, (i) {
      final start = 0.26 + i * 0.06;
      return Tween<Offset>(
        begin: const Offset(0, 0.35),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: masterCtrl,
          curve: Interval(start, start + 0.18, curve: Curves.easeOutCubic),
        ),
      );
    });

    // Sections: staggered starting 0.52, 7 blocks × 0.06 gap
    secOpacity = List.generate(7, (i) {
      final start = 0.50 + i * 0.055;
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: masterCtrl,
          curve: Interval(
            start,
            (start + 0.14).clamp(0.0, 1.0),
            curve: Curves.easeOut,
          ),
        ),
      );
    });
    secSlide = List.generate(7, (i) {
      final start = 0.50 + i * 0.055;
      return Tween<Offset>(
        begin: const Offset(0, 0.25),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: masterCtrl,
          curve: Interval(
            start,
            (start + 0.18).clamp(0.0, 1.0),
            curve: Curves.easeOutCubic,
          ),
        ),
      );
    });

    masterCtrl.forward();
  }

  @override
  void dispose() {
    masterCtrl.dispose();
    super.dispose();
  }

  Widget animatedSection(int secIndex, Widget child) => FadeTransition(
    opacity: secOpacity[secIndex],
    child: SlideTransition(position: secSlide[secIndex], child: child),
  );

  // ── Modern Hero header with Glassmorphism ─────────────────────
  Widget buildHeroHeader(
    BuildContext context,
    bool isDark,
    AppLocalizations l10n,
    TextTheme textTheme,
  ) {
    final top = MediaQuery.of(context).padding.top;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [teal, tealDark, teal.withValues(alpha: 0.8)],
          stops: const [0.0, 0.5, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: teal.withValues(alpha: 0.4),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: teal.withValues(alpha: 0.2),
            blurRadius: 60,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: Stack(
        alignment: AlignmentGeometry.center,
        children: [
          // Background pattern
          Positioned.fill(
            child: Opacity(
              opacity: 0.05,
              child: CustomPaint(painter: _PatternPainter()),
            ),
          ),
          // Main content
          Padding(
            padding: EdgeInsets.fromLTRB(24.w, top + 32.h, 24.w, 28.h),
            child: Column(
              children: [
                // Avatar with modern glow
                ScaleTransition(
                  scale: avatarScale,
                  child: FadeTransition(
                    opacity: avatarOpacity,
                    child: _ModernAvatar(),
                  ),
                ),
                SizedBox(height: 14.h),

                // Name with gradient text effect
                FadeTransition(
                  opacity: nameOpacity,
                  child: SlideTransition(
                    position: nameSlide,
                    child: Column(
                      children: [
                        ShaderMask(
                          shaderCallback: (bounds) => LinearGradient(
                            colors: [
                              Colors.white,
                              Colors.white.withValues(alpha: 0.9),
                            ],
                          ).createShader(bounds),
                          child: Builder(
                            builder: (context) {
                              return Text(
                                cubit.handymanProfileData?.fullName ?? '-',
                                style: textTheme.headlineSmall?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.5,
                                ),
                              );
                            }
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 4.h,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          child: Builder(
                            builder: (context) {
                              return Text(
                                cubit.handymanProfileData?.email ?? '-',
                                style: GoogleFonts.cairo(
                                  fontSize: 13.sp,
                                  color: Colors.white.withValues(alpha: 0.95),
                                  fontWeight: FontWeight.w600,
                                ),
                              );
                            }
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 16.h),

                // Badge + edit button
                FadeTransition(
                  opacity: badgeOpacity,
                  child: SlideTransition(
                    position: badgeSlide,
                    child: Column(
                      children: [
                        // Modern verified badge with glow
                        _ModernVerifiedBadge(l10n: l10n),
                        SizedBox(height: 16.h),
                        _ModernPressableEditBtn(
                          label: l10n.profileEditBtn,
                          onTap: () => Navigator.of(context).pushNamed(
                            AppRoutes.handymanEditProfileView,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Stats row with modern cards ────────────────────────────
  Widget buildStatsRow(bool isDark, AppLocalizations l10n, TextTheme textTheme, ColorScheme colorScheme,) {
    final stats = cubit.statisticsData;
    final profile = cubit.handymanProfileData;

    final statItems = [
      (
        value: stats != null ? '${stats.completedJobs}' : '-',
        label: l10n.profileStatJobs,
        icon: Icons.work_history_rounded,
      ),
      (
        value: stats != null ? stats.averageRating.toStringAsFixed(1) : '-',
        label: l10n.profileStatRating,
        icon: Icons.star_rounded,
      ),
      (
        value: profile != null ? '${profile.yearsOfExperience}' : '-',
        label: l10n.profileStatYears,
        icon: Icons.calendar_today_rounded,
      ),
      (
        value: profile != null
            ? '${profile.basePrice.toStringAsFixed(0)} EGP'
            : '-',
        label: l10n.profileStatRate,
        icon: Icons.attach_money_rounded,
      ),
    ];

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 12.w,
        vertical: AppSpacing.xl,
      ),
      child: Row(
        children: List.generate(statItems.length, (i) {
          final s = statItems[i];
          final isLast = i == statItems.length - 1;
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: isLast ? 0 : 10.w),
              child: FadeTransition(
                opacity: statOpacity[i],
                child: SlideTransition(
                  position: statSlide[i],
                  child: _ModernStatCard(
                    value: s.value,
                    label: s.label,
                    icon: s.icon,
                    teal: teal,
                    isDark: isDark,
                    textTheme: textTheme,
                    colorScheme: colorScheme,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  // ── Activity card with glassmorphism ────────────────────────
  Widget buildActivityCard(
    bool isDark,
    AppLocalizations l10n,
    TextTheme textTheme,
    ColorScheme colorScheme,
  ) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.xl.w,
        0,
        AppSpacing.xl.w,
        AppSpacing.xl.h,
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24.r),
          boxShadow: [
            BoxShadow(
              color: teal.withValues(alpha: 0.15),
              blurRadius: 30,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24.r),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.darkSurface.withValues(alpha: 0.9)
                    : Colors.white.withValues(alpha: 0.95),
                borderRadius: BorderRadius.circular(24.r),
                border: Border.all(
                  color: teal.withValues(alpha: 0.15),
                  width: 1.5,
                ),
              ),
              child: Column(
                children: [
                  // Top gradient accent bar
                  Container(
                    height: 6.h,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          teal,
                          teal.withValues(alpha: 0.6),
                          teal.withValues(alpha: 0.2),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 18.w,
                      vertical: 14.h,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 36.w,
                          height: 36.h,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                teal.withValues(alpha: 0.2),
                                teal.withValues(alpha: 0.1),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Icon(
                            Icons.show_chart_rounded,
                            size: 20.sp,
                            color: teal,
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Text(
                          l10n.profileActivityTitle,
                          style: textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10.w,
                            vertical: 4.h,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                teal.withValues(alpha: 0.15),
                                teal.withValues(alpha: 0.08),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          child: Text(
                            l10n.profileActivityBadge,
                            style: GoogleFonts.cairo(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w700,
                              color: teal,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(height: 1, color: teal.withValues(alpha: 0.08)),
                  Padding(
                    padding: EdgeInsets.all(20.w),
                    child: Row(
                      children: [
                        Expanded(
                          child: _ModernCircularStat(
                            value: '٩٨٪',
                            label: l10n.profileStatCompletion,
                            sublabel: l10n.profileStatExcellent,
                            targetProgress: 0.98,
                            color: teal,
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 90.h,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                teal.withValues(alpha: 0.0),
                                teal.withValues(alpha: 0.15),
                                teal.withValues(alpha: 0.0),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          child: _ModernCircularStat(
                            value: '١٥',
                            label: l10n.profileStatSuccessJobs,
                            sublabel: l10n.profileStatMoreThanJan,
                            targetProgress: 0.6,
                            color: const Color(0xFFF7931E),
                          ),
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
    );
  }

  // ── About with modern card ──────────────────────────────────
  Widget buildAbout(
    bool isDark,
    AppLocalizations l10n,
    TextTheme textTheme,
    ColorScheme colorScheme,
  ) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.xl.w,
        0,
        AppSpacing.xl.w,
        AppSpacing.xl.h,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 28.w,
                height: 28.h,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      teal.withValues(alpha: 0.2),
                      teal.withValues(alpha: 0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  Icons.info_outline_rounded,
                  size: 16.sp,
                  color: teal,
                ),
              ),
              SizedBox(width: 10.w),
              Text(
                l10n.phoneNumber,
                style: textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(18.w),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [
                        AppColors.darkSurface,
                        AppColors.darkSurface.withValues(alpha: 0.8),
                      ]
                    : [Colors.white, Colors.white.withValues(alpha: 0.9)],
              ),
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(
                color: teal.withValues(alpha: 0.1),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: teal.withValues(alpha: 0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Text(
              cubit.handymanProfileData?.phoneNumber ?? 'غير معرف',
              style: textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.7,
              ),
              textAlign: TextAlign.left,
            ),
          ),
        ],
      ),
    );
  }

  // ── Portfolio feed with modern design ──────────────────────
  Widget buildPortfolio(
    bool isDark,
    AppLocalizations l10n,
    TextTheme textTheme,
    ColorScheme colorScheme,
  ) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.xl.w,
        0,
        AppSpacing.xl.w,
        AppSpacing.xl.h,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 28.w,
                height: 28.h,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      teal.withValues(alpha: 0.2),
                      teal.withValues(alpha: 0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  Icons.photo_library_outlined,
                  size: 16.sp,
                  color: teal,
                ),
              ),
              SizedBox(width: 10.w),
              Text(
                l10n.profilePortfolioTitle,
                style: textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24.r),
              boxShadow: [
                BoxShadow(
                  color: teal.withValues(alpha: 0.1),
                  blurRadius: 25,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24.r),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.darkSurface.withValues(alpha: 0.9)
                        : Colors.white.withValues(alpha: 0.95),
                    borderRadius: BorderRadius.circular(24.r),
                    border: Border.all(
                      color: teal.withValues(alpha: 0.12),
                      width: 1.5,
                    ),
                  ),
                  clipBehavior: Clip.hardEdge,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 18.w,
                          vertical: 14.h,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: isDark
                                ? [
                                    AppColors.darkBgSecondary,
                                    AppColors.darkBgSecondary.withValues(
                                      alpha: 0.8,
                                    ),
                                  ]
                                : [
                                    const Color(0xFFF8F9FA),
                                    const Color(0xFFF0F2F5),
                                  ],
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    l10n.profileFeedCategory,
                                    style: textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  SizedBox(height: 2.h),
                                  Text(
                                    l10n.profileFeedDate,
                                    style: textTheme.labelSmall?.copyWith(
                                      color: colorScheme.onSurfaceVariant
                                          .withValues(alpha: 0.7),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.all(8.w),
                              decoration: BoxDecoration(
                                color: teal.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                              child: Icon(
                                Icons.arrow_forward_rounded,
                                size: 16.sp,
                                color: teal,
                              ),
                            ),
                          ],
                        ),
                      ),
                      AspectRatio(
                        aspectRatio: 16 / 10,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: isDark
                                  ? [
                                      AppColors.darkBgSecondary,
                                      teal.withValues(alpha: 0.1),
                                    ]
                                  : [
                                      const Color(0xFFF8F9FA),
                                      teal.withValues(alpha: 0.05),
                                    ],
                            ),
                          ),
                          child: Icon(
                            Icons.image_outlined,
                            size: 56.sp,
                            color: teal.withValues(alpha: 0.2),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(16.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.profileFeedTitle,
                              style: textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            SizedBox(height: 6.h),
                            Text(
                              l10n.profileFeedText,
                              style: textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                                height: 1.5,
                              ),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
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
          SizedBox(height: 12.h),
          _ModernShowMoreBtn(
            label: l10n.profileShowAllPosts,
            teal: teal,
            onTap: () {},
          ),
        ],
      ),
    );
  }

  // ── Contact info ─────────────────────────────────────────
  Widget buildContactInfo(
    bool isDark,
    AppLocalizations l10n,
    TextTheme textTheme,
    ColorScheme colorScheme,
  ) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.xl.w,
        0,
        AppSpacing.xl.w,
        AppSpacing.xl.h,
      ),
      child: _ModernInfoCard(
        isDark: isDark,
        teal: teal,
        icon: Icons.location_on_outlined,
        title: l10n.profileContactTitle,
        textTheme: textTheme,
        colorScheme: colorScheme,
        rows: [
          _InfoRow(
            icon: Icons.location_on_outlined,
            label: l10n.profileWorkArea,
            value: l10n.profileWorkAreaValue,
            teal: teal,
            isDark: isDark,
            textTheme: textTheme,
            colorScheme: colorScheme,
            isLast: false,
          ),
          _InfoRow(
            icon: Icons.access_time_rounded,
            label: l10n.profileWorkHours,
            value: l10n.profileWorkHoursValue,
            teal: teal,
            isDark: isDark,
            textTheme: textTheme,
            colorScheme: colorScheme,
            isLast: true,
          ),
        ],
      ),
    );
  }

  // ── Reviews with modern cards ──────────────────────────────
  Widget buildReviews(
    BuildContext context,
    bool isDark,
    AppLocalizations l10n,
    TextTheme textTheme,
    ColorScheme colorScheme,
  ) {
    final reviews = [
      (
        name: 'أحمد محمود',
        text: l10n.profileReview1,
        date: l10n.profileReview1Date,
      ),
      (
        name: 'فاطمة حسن',
        text: l10n.profileReview2,
        date: l10n.profileReview2Date,
      ),
      (
        name: 'خالد إبراهيم',
        text: l10n.profileReview3,
        date: l10n.profileReview3Date,
      ),
    ];

    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.xl.w,
        0,
        AppSpacing.xl.w,
        AppSpacing.xl.h,
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24.r),
          boxShadow: [
            BoxShadow(
              color: teal.withValues(alpha: 0.1),
              blurRadius: 25,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24.r),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Container(
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.darkSurface.withValues(alpha: 0.9)
                    : Colors.white.withValues(alpha: 0.95),
                borderRadius: BorderRadius.circular(24.r),
                border: Border.all(
                  color: teal.withValues(alpha: 0.12),
                  width: 1.5,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 32.w,
                        height: 32.h,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFFF7931E).withValues(alpha: 0.2),
                              const Color(0xFFF7931E).withValues(alpha: 0.1),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Icon(
                          Icons.star_rounded,
                          size: 18.sp,
                          color: const Color(0xFFF7931E),
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Text(
                        l10n.profileReviewsTitle,
                        style: textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF7931E).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.star_rounded,
                              size: 14.sp,
                              color: const Color(0xFFF7931E),
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              '4.9',
                              style: GoogleFonts.cairo(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFFF7931E),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  ...reviews.asMap().entries.map(
                    (e) => _ModernReviewItem(
                      index: e.key,
                      name: e.value.name,
                      text: e.value.text,
                      date: e.value.date,
                      teal: teal,
                      textTheme: textTheme,
                      colorScheme: colorScheme,
                      isLast: e.key == reviews.length - 1,
                    ),
                  ),
                  SizedBox(height: 14.h),
                  _ModernShowMoreBtn(
                    label: l10n.profileShowAllReviews,
                    teal: teal,
                    onTap: () {
                      Navigator.of(
                        context,
                      ).pushNamed(AppRoutes.handymanOwnReviews);
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Menu list with modern buttons ──────────────────────────
  Widget buildMenuList(
    BuildContext context,
    bool isDark,
    AppLocalizations l10n,
    TextTheme textTheme,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl.w),
      child: Column(
        children: [
          _ModernSettingsItem(
            icon: Icons.check_circle_outline_rounded,
            iconBgColor: teal.withValues(alpha: 0.12),
            iconColor: teal,
            label: l10n.profileMenuCompleted,
            isDark: isDark,
            onTap: () => Navigator.of(
              context,
            ).pushNamed(AppRoutes.handymanCompletedJobs),
          ),
          _ModernSettingsItem(
            icon: Icons.star_outline_rounded,
            iconBgColor: const Color(0xFFF7931E).withValues(alpha: 0.12),
            iconColor: const Color(0xFFF7931E),
            label: l10n.profileMenuReviews,
            isDark: isDark,
            onTap: () =>
                Navigator.of(context).pushNamed(AppRoutes.handymanOwnReviews),
          ),
          _ModernSettingsItem(
            icon: Icons.photo_library_outlined,
            iconBgColor: AppColors.info.withValues(alpha: 0.12),
            iconColor: AppColors.info,
            label: l10n.profileMenuPortfolio,
            isDark: isDark,
            onTap: () => Navigator.of(
              context,
            ).pushNamed(AppRoutes.handymanManagePortfolio),
          ),
          _ModernSettingsItem(
            icon: Icons.settings_outlined,
            iconBgColor: AppColors.neutral[70]!.withValues(alpha: 0.3),
            iconColor: AppColors.neutral[50]!,
            label: l10n.profileMenuSettings,
            isDark: isDark,
            onTap: () =>
                Navigator.of(context).pushNamed(AppRoutes.handymanSettings),
          ),
          _ModernSettingsItem(
            icon: Icons.help_outline_rounded,
            iconBgColor: AppColors.info.withValues(alpha: 0.12),
            iconColor: AppColors.info,
            label: l10n.helpTitle,
            isDark: isDark,
            onTap: () => Navigator.of(
              context,
            ).pushNamed(AppRoutes.sharedHelpSupport, arguments: true),
          ),
          _ModernSettingsItem(
            icon: Icons.logout_rounded,
            iconBgColor: AppColors.danger.withValues(alpha: 0.10),
            iconColor: AppColors.danger,
            label: l10n.profileMenuLogout,
            isDark: isDark,
            isDanger: true,
            showChevron: false,
            onTap: () {
              HapticFeedback.lightImpact();
              showAnimatedConfirmDialog(
                context: context,
                isDark: isDark,
                icon: Icons.logout_rounded,
                title: l10n.profileMenuLogout,
                message: l10n.logoutConfirmMessage,
                cancelLabel: l10n.cancel,
                confirmLabel: l10n.profileMenuLogout,
                isDanger: true,
                onConfirm: () async {
                  await logout();
                  if (!mounted) return;

                  Navigator.of(context).pushNamedAndRemoveUntil(
                    AppRoutes.login, (route) => false,
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  HandymanCubit get cubit => context.watch<HandymanCubit>();
}

// ══════════════════════════════════════════════════════════════
// Mobile Body
// ══════════════════════════════════════════════════════════════
class _HandymanProfileMobileBody extends StatefulWidget {
  const _HandymanProfileMobileBody();
  @override
  State<_HandymanProfileMobileBody> createState() =>
      _HandymanProfileMobileBodyState();
}

class _HandymanProfileMobileBodyState
    extends _ProfileBase<_HandymanProfileMobileBody> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return BlocListener<HandymanCubit, HandymanState>(
        listener: (context, state) {
          state.whenOrNull(
            statisticsLoaded: (_) => setState(() {}),
            profileLoaded: (_) => setState(() {}),
            error: (message) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(message)),
              );
            },
          );
        },
        child: Scaffold(
          backgroundColor: isDark
          ? AppColors.darkBgPrimary
          : const Color(0xFFF0F7F8),
          body: AppMainBackground(
            child: SafeArea(
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                child: buildHeroHeader(context, isDark, l10n, textTheme),
              ),
                  SliverToBoxAdapter(
                    child: buildStatsRow(isDark, l10n, textTheme, colorScheme),
                  ),
              //     SliverToBoxAdapter(
              //   child: animatedSection(
              //     0,
              //     buildActivityCard(isDark, l10n, textTheme, colorScheme),
              //   ),
              // ),
                  SliverToBoxAdapter(
                child: animatedSection(
                  1,
                  buildAbout(isDark, l10n, textTheme, colorScheme),
                ),
              ),
                  // SliverToBoxAdapter(
                  //   child: animatedSection(
                  //     2,
                  //     buildPortfolio(isDark, l10n, textTheme, colorScheme),
                  //   ),
                  // ),
                  // SliverToBoxAdapter(
                  //   child: animatedSection(
                  //     3,
                  //     buildContactInfo(isDark, l10n, textTheme, colorScheme),
                  //   ),
                  // ),
                  // SliverToBoxAdapter(
                  //   child: animatedSection(
                  //     4,
                  //     buildReviews(context, isDark, l10n, textTheme, colorScheme),
                  //   ),
                  // ),
                  SliverToBoxAdapter(
                    child: animatedSection(
                      5,
                      buildMenuList(context, isDark, l10n, textTheme),
                    ),
                  ),
                  SliverToBoxAdapter(child: SizedBox(height: 128.h)),
            ],
          ),
        ),
      ),
    ));
  }
}

// ══════════════════════════════════════════════════════════════
// Tablet Body — two-column layout
// ══════════════════════════════════════════════════════════════
class _HandymanProfileTabletBody extends StatefulWidget {
  const _HandymanProfileTabletBody();
  @override
  State<_HandymanProfileTabletBody> createState() =>
      _HandymanProfileTabletBodyState();
}

class _HandymanProfileTabletBodyState
    extends _ProfileBase<_HandymanProfileTabletBody> {
  // Extra float animation for avatar on tablet
  late final AnimationController floatCtrl;
  late final Animation<double> floatY;

  @override
  void initState() {
    super.initState();
    floatCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..repeat(reverse: true);
    floatY = Tween<double>(
      begin: -6.0,
      end: 6.0,
    ).animate(CurvedAnimation(parent: floatCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    floatCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return BlocListener<HandymanCubit, HandymanState>(
      listener: (context, state) {
        state.whenOrNull(
          statisticsLoaded: (_) => setState(() {}),
          profileLoaded: (_) => setState(() {}),
          error: (message) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(message)),
            );
          },);
        },
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: AppMainBackground(
            child: SafeArea(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Left panel (38%)
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.38,
                    child: CustomScrollView(
                      physics: const BouncingScrollPhysics(),
                      slivers: [
                        SliverToBoxAdapter(
                          child: _buildTabletHeroCard(
                            context,
                            isDark,
                            l10n,
                            textTheme,
                            colorScheme,
                          ),
                        ),
                        SliverToBoxAdapter(
                          child: animatedSection(
                            0,
                            buildActivityCard(isDark, l10n, textTheme, colorScheme),
                          ),
                        ),
                        SliverToBoxAdapter(
                          child: animatedSection(
                            1,
                            buildContactInfo(isDark, l10n, textTheme, colorScheme),
                          ),
                        ),
                        SliverToBoxAdapter(child: SizedBox(height: 100.h)),
                      ],
                    ),
                  ),

                  VerticalDivider(width: 1, color: teal.withValues(alpha: 0.10)),

                  // ── Right panel (62%)
                  Expanded(
                    child: CustomScrollView(
                      physics: const BouncingScrollPhysics(),
                      slivers: [
                        SliverToBoxAdapter(
                          child: animatedSection(
                            2,
                            buildAbout(isDark, l10n, textTheme, colorScheme),
                          ),
                        ),
                        SliverToBoxAdapter(
                          child: animatedSection(
                            3,
                            buildPortfolio(isDark, l10n, textTheme, colorScheme),
                          ),
                        ),
                        SliverToBoxAdapter(
                          child: animatedSection(
                            4,
                            buildReviews(
                              context,
                              isDark,
                              l10n,
                              textTheme,
                              colorScheme,
                            ),
                          ),
                        ),
                        SliverToBoxAdapter(
                          child: animatedSection(
                            5,
                            buildMenuList(context, isDark, l10n, textTheme),
                          ),
                        ),
                        SliverToBoxAdapter(child: SizedBox(height: 100.h)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
    );
  }

  Widget _buildTabletHeroCard(
    BuildContext context,
    bool isDark,
    AppLocalizations l10n,
    TextTheme textTheme,
    ColorScheme colorScheme,
  ) {
    return Container(
      margin: EdgeInsets.all(AppSpacing.xl.w),
      padding: EdgeInsets.all(AppSpacing.xl.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [teal, tealDark, teal.withValues(alpha: 0.8)],
        ),
        borderRadius: BorderRadius.circular(28.r),
        boxShadow: [
          BoxShadow(
            color: teal.withValues(alpha: 0.35),
            blurRadius: 30,
            offset: const Offset(0, 12),
          ),
          BoxShadow(
            color: teal.withValues(alpha: 0.2),
            blurRadius: 60,
            offset: const Offset(0, 24),
          ),
        ],
      ),
      child: Column(
        children: [
          // Floating avatar with glow
          AnimatedBuilder(
            animation: floatCtrl,
            builder: (_, child) => Transform.translate(
              offset: Offset(0, floatY.value),
              child: child,
            ),
            child: ScaleTransition(
              scale: avatarScale,
              child: FadeTransition(
                opacity: avatarOpacity,
                child: _ModernAvatar(size: 90.w),
              ),
            ),
          ),
          SizedBox(height: 16.h),

          FadeTransition(
            opacity: nameOpacity,
            child: SlideTransition(
              position: nameSlide,
              child: ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  colors: [Colors.white, Colors.white.withValues(alpha: 0.9)],
                ).createShader(bounds),
                child: Builder(
                  builder: (context) {
                    return Text(
                      cubit.handymanProfileData?.fullName ?? '-',
                      style: textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                      ),
                    );
                  }
                ),
              ),
            ),
          ),
          SizedBox(height: 6.h),
          FadeTransition(
            opacity: nameOpacity,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Text(
                cubit.handymanProfileData?.email ?? '-',
                style: GoogleFonts.cairo(
                  fontSize: 13.sp,
                  color: Colors.white.withValues(alpha: 0.95),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          SizedBox(height: 16.h),

          FadeTransition(
            opacity: badgeOpacity,
            child: SlideTransition(
              position: badgeSlide,
              child: _ModernVerifiedBadge(l10n: l10n, small: true),
            ),
          ),
          SizedBox(height: 20.h),

          buildStatsRow(isDark, l10n, textTheme, colorScheme),

          _ModernPressableEditBtn(
            label: l10n.profileEditBtn,
            onTap: () => Navigator.of(
              context,
            ).pushNamed(AppRoutes.handymanEditProfileView),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// Background Pattern Painter
// ══════════════════════════════════════════════════════════════
class _PatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final spacing = 40.0;
    for (var i = 0.0; i < size.width + size.height; i += spacing) {
      canvas.drawLine(Offset(i, 0), Offset(0, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ══════════════════════════════════════════════════════════════
// Modern Reusable Widgets
// ══════════════════════════════════════════════════════════════

class _ModernAvatar extends StatelessWidget {
  final double size;
  const _ModernAvatar({this.size = 100});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            Colors.white.withValues(alpha: 0.35),
            Colors.white.withValues(alpha: 0.15),
          ],
        ),
        border: Border.all(color: Colors.white, width: 4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.3),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Container(
        margin: EdgeInsets.all(size * 0.12),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: 0.2),
        ),
        child: Icon(
          Icons.person_rounded,
          size: size * 0.5,
          color: Colors.white,
        ),
      ),
    );
  }
}

class _ModernVerifiedBadge extends StatelessWidget {
  final AppLocalizations l10n;
  final bool small;
  const _ModernVerifiedBadge({required this.l10n, this.small = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: small ? 12.w : 16.w,
        vertical: small ? 5.h : 7.h,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(small ? 16.r : 20.r),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.2),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.3),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.verified_rounded,
              size: small ? 12.sp : 15.sp,
              color: Colors.white,
            ),
          ),
          SizedBox(width: small ? 4.w : 6.w),
          Text(
            l10n.profileVerified,
            style: GoogleFonts.cairo(
              fontSize: small ? 10.sp : 12.sp,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _ModernStatCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color teal;
  final bool isDark;
  final TextTheme textTheme;
  final ColorScheme colorScheme;

  const _ModernStatCard({
    required this.value,
    required this.label,
    required this.icon,
    required this.teal,
    required this.isDark,
    required this.textTheme,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 8.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  AppColors.darkSurface,
                  AppColors.darkSurface.withValues(alpha: 0.8),
                ]
              : [Colors.white, Colors.white.withValues(alpha: 0.9)],
        ),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: teal.withValues(alpha: 0.1), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: teal.withValues(alpha: 0.08),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 32.w,
            height: 32.h,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  teal.withValues(alpha: 0.2),
                  teal.withValues(alpha: 0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(icon, size: 16.sp, color: teal),
          ),
          SizedBox(height: 8.h),
          Text(
            value,
            style: GoogleFonts.cairo(
              fontSize: 18.sp,
              fontWeight: FontWeight.w900,
              color: teal,
            ),
          ),
          SizedBox(height: 3.h),
          Text(
            label,
            style: textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _ModernPressableEditBtn extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  const _ModernPressableEditBtn({required this.label, required this.onTap});

  @override
  State<_ModernPressableEditBtn> createState() =>
      _ModernPressableEditBtnState();
}

class _ModernPressableEditBtnState extends State<_ModernPressableEditBtn>
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
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(color: Colors.white, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.white.withValues(alpha: 0.15),
                blurRadius: 8,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.edit_rounded, size: 16.sp, color: Colors.white),
              SizedBox(width: 8.w),
              Text(
                widget.label,
                style: GoogleFonts.cairo(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ModernCircularStat extends StatefulWidget {
  final String value;
  final String label;
  final String sublabel;
  final double targetProgress;
  final Color color;

  const _ModernCircularStat({
    required this.value,
    required this.label,
    required this.sublabel,
    required this.targetProgress,
    required this.color,
  });

  @override
  State<_ModernCircularStat> createState() => _ModernCircularStatState();
}

class _ModernCircularStatState extends State<_ModernCircularStat>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _progress;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _progress = Tween<double>(
      begin: 0.0,
      end: widget.targetProgress,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    Future.delayed(const Duration(milliseconds: 600), () {
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
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        AnimatedBuilder(
          animation: _progress,
          builder: (_, __) => SizedBox(
            width: 70.w,
            height: 70.h,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Background glow
                Container(
                  width: 70.w,
                  height: 70.h,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: widget.color.withValues(alpha: 0.2),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
                CustomPaint(
                  size: Size(60.w, 60.h),
                  painter: _CirclePainter(
                    progress: _progress.value,
                    color: widget.color,
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.value,
                      style: GoogleFonts.cairo(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Icon(
                      widget.targetProgress >= 0.9
                          ? Icons.emoji_events_rounded
                          : Icons.trending_up_rounded,
                      size: 12.sp,
                      color: widget.color,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 10.h),
        Text(
          widget.label,
          style: textTheme.labelSmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w700,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 2.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
          decoration: BoxDecoration(
            color: widget.color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Text(
            widget.sublabel,
            style: textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: widget.color,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}

class _CirclePainter extends CustomPainter {
  final double progress;
  final Color color;
  const _CirclePainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2, cy = size.height / 2;
    final r = (size.width - 8) / 2;

    // Gradient paint
    final bg = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.black.withValues(alpha: 0.08),
          Colors.black.withValues(alpha: 0.03),
        ],
      ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: r))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;

    final fg = Paint()
      ..shader = SweepGradient(
        startAngle: -math.pi / 2,
        endAngle: 2 * math.pi,
        colors: [color.withValues(alpha: 0.3), color],
        transform: const GradientRotation(-math.pi / 2),
      ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: r))
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
  bool shouldRepaint(_CirclePainter old) => old.progress != progress;
}

class _ModernReviewItem extends StatefulWidget {
  final int index;
  final String name;
  final String text;
  final String date;
  final Color teal;
  final TextTheme textTheme;
  final ColorScheme colorScheme;
  final bool isLast;

  const _ModernReviewItem({
    required this.index,
    required this.name,
    required this.text,
    required this.date,
    required this.teal,
    required this.textTheme,
    required this.colorScheme,
    required this.isLast,
  });

  @override
  State<_ModernReviewItem> createState() => _ModernReviewItemState();
}

class _ModernReviewItemState extends State<_ModernReviewItem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _opacity;
  late final Animation<Offset> _slide;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _opacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _scale = Tween<double>(
      begin: 0.95,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack));
    Future.delayed(Duration(milliseconds: 500 + widget.index * 120), () {
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
      opacity: _opacity,
      child: SlideTransition(
        position: _slide,
        child: ScaleTransition(
          scale: _scale,
          child: Container(
            margin: EdgeInsets.only(bottom: widget.isLast ? 0 : 12.h),
            padding: EdgeInsets.all(14.w),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  widget.teal.withValues(alpha: 0.06),
                  widget.teal.withValues(alpha: 0.02),
                ],
              ),
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: widget.teal.withValues(alpha: 0.08),
                width: 1.5,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 32.w,
                          height: 32.h,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                widget.teal.withValues(alpha: 0.2),
                                widget.teal.withValues(alpha: 0.1),
                              ],
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              widget.name[0],
                              style: GoogleFonts.cairo(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w800,
                                color: widget.teal,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.name,
                              style: widget.textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              widget.date,
                              style: widget.textTheme.labelSmall?.copyWith(
                                color: widget.colorScheme.onSurfaceVariant
                                    .withValues(alpha: 0.6),
                                fontSize: 10.sp,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Row(
                      children: List.generate(
                        5,
                        (i) => Icon(
                          Icons.star_rounded,
                          size: 14.sp,
                          color: i < 4
                              ? const Color(0xFFF7931E)
                              : const Color(0xFFF7931E).withValues(alpha: 0.3),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10.h),
                Text(
                  widget.text,
                  style: widget.textTheme.labelSmall?.copyWith(
                    color: widget.colorScheme.onSurfaceVariant,
                    height: 1.5,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ModernShowMoreBtn extends StatefulWidget {
  final String label;
  final Color teal;
  final VoidCallback onTap;

  const _ModernShowMoreBtn({
    required this.label,
    required this.teal,
    required this.onTap,
  });

  @override
  State<_ModernShowMoreBtn> createState() => _ModernShowMoreBtnState();
}

class _ModernShowMoreBtnState extends State<_ModernShowMoreBtn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 100),
  );
  late final Animation<double> _scale = Tween<double>(
    begin: 1.0,
    end: 0.96,
  ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));

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
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 14.h),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                widget.teal.withValues(alpha: 0.08),
                widget.teal.withValues(alpha: 0.04),
              ],
            ),
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(
              color: widget.teal.withValues(alpha: 0.2),
              width: 1.5,
            ),
          ),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.label,
                  style: GoogleFonts.cairo(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: widget.teal,
                  ),
                ),
                SizedBox(width: 8.w),
                Icon(
                  Icons.arrow_forward_rounded,
                  size: 16.sp,
                  color: widget.teal,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ModernInfoCard extends StatelessWidget {
  final bool isDark;
  final Color teal;
  final IconData icon;
  final String title;
  final TextTheme textTheme;
  final ColorScheme colorScheme;
  final List<_InfoRow> rows;

  const _ModernInfoCard({
    required this.isDark,
    required this.teal,
    required this.icon,
    required this.title,
    required this.textTheme,
    required this.colorScheme,
    required this.rows,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: teal.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20.r),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.darkSurface.withValues(alpha: 0.9)
                  : Colors.white.withValues(alpha: 0.95),
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(
                color: teal.withValues(alpha: 0.1),
                width: 1.5,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Row(
                    children: [
                      Container(
                        width: 32.w,
                        height: 32.h,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              teal.withValues(alpha: 0.2),
                              teal.withValues(alpha: 0.1),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Icon(icon, size: 18.sp, color: teal),
                      ),
                      SizedBox(width: 12.w),
                      Text(
                        title,
                        style: textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(height: 1, color: teal.withValues(alpha: 0.08)),
                Padding(
                  padding: EdgeInsets.all(12.w),
                  child: Column(children: rows),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color teal;
  final bool isDark;
  final TextTheme textTheme;
  final ColorScheme colorScheme;
  final bool isLast;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.teal,
    required this.isDark,
    required this.textTheme,
    required this.colorScheme,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 12.h),
      decoration: isLast
          ? null
          : BoxDecoration(
              border: Border(
                bottom: BorderSide(color: teal.withValues(alpha: 0.06)),
              ),
            ),
      child: Row(
        children: [
          Container(
            width: 36.w,
            height: 36.h,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  teal.withValues(alpha: 0.15),
                  teal.withValues(alpha: 0.08),
                ],
              ),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(icon, size: 18.sp, color: teal),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  value,
                  style: textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ModernSettingsItem extends StatefulWidget {
  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;
  final String label;
  final bool isDark;
  final VoidCallback onTap;
  final bool isDanger;
  final bool showChevron;

  const _ModernSettingsItem({
    required this.icon,
    required this.iconBgColor,
    required this.iconColor,
    required this.label,
    required this.isDark,
    required this.onTap,
    this.isDanger = false,
    this.showChevron = true,
  });

  @override
  State<_ModernSettingsItem> createState() => _ModernSettingsItemState();
}

class _ModernSettingsItemState extends State<_ModernSettingsItem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 80),
    );
    _scale = Tween<double>(
      begin: 1.0,
      end: 0.98,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _opacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: GestureDetector(
        onTapDown: (_) {
          _ctrl.forward();
        },
        onTapUp: (_) {
          _ctrl.reverse();
        },
        onTapCancel: () => _ctrl.reverse(),
        onTap: () {
          HapticFeedback.selectionClick();
          widget.onTap();
        },
        child: AnimatedBuilder(
          animation: _ctrl,
          builder: (_, child) => Transform.scale(
            scale: _scale.value,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
              decoration: BoxDecoration(
                color: Color.lerp(
                  widget.isDark ? AppColors.darkSurface : Colors.white,
                  widget.isDanger
                      ? AppColors.danger.withValues(alpha: 0.05)
                      : AppColors.accent.withValues(alpha: 0.05),
                  _ctrl.value,
                ),
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(
                  color: Color.lerp(
                    widget.isDark
                        ? Colors.white.withValues(alpha: 0.05)
                        : Colors.black.withValues(alpha: 0.05),
                    widget.isDanger
                        ? AppColors.danger.withValues(alpha: 0.2)
                        : AppColors.accent.withValues(alpha: 0.15),
                    _ctrl.value,
                  )!,
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: widget.isDanger
                        ? AppColors.danger.withValues(alpha: 0.05)
                        : AppColors.accent.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 40.w,
                    height: 40.h,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          widget.iconBgColor,
                          widget.iconBgColor.withValues(alpha: 0.5),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Icon(
                      widget.icon,
                      size: 20.sp,
                      color: widget.iconColor,
                    ),
                  ),
                  SizedBox(width: 14.w),
                  Expanded(
                    child: Text(
                      widget.label,
                      style: GoogleFonts.cairo(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: widget.isDanger
                            ? AppColors.danger
                            : Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                  if (widget.showChevron)
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 16.sp,
                      color: widget.isDanger
                          ? AppColors.danger.withValues(alpha: 0.7)
                          : Theme.of(context).colorScheme.onSurfaceVariant
                                .withValues(alpha: 0.5),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
