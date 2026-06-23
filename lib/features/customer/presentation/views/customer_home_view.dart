import 'package:fix_it/core/router/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/l10n/translation/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/utils/functions/remeber_me.dart';
import '../../../../core/utils/widgets/app_main_background.dart';
import '../../../../core/utils/widgets/animations/animated_confirm_dialog.dart';
import '../../../../core/utils/widgets/app_category_chip.dart';
import '../../../../core/utils/widgets/app_snack_bar.dart';
import '../../../../core/utils/widgets/cards/app_handyman_card.dart';
import '../../../../core/utils/widgets/app_profile_popup.dart';
import '../../../../core/utils/widgets/app_search_bar.dart';
import '../../../lookups/presentation/cubit/lookup_cubit.dart';
import '../../../lookups/presentation/cubit/lookup_state.dart';
import '../../data/models/requests/create_service_request.dart';
import '../../domain/entities/customer_statistics_entity.dart';
import '../cubit/customer_cubit.dart';
import '../cubit/customer_state.dart';

// ── Mock Data ─────────────────────────────────────────────────
final _kHandymen = [
  HandymanModel(
    id: '1',
    name: 'محمد علي',
    specialty: 'فني سباكة محترف',
    rating: 4.9,
    reviewCount: 127,
    hourlyRate: 150,
    avatarGradient: [AppColors.primary[60]!, AppColors.secondary[60]!],
  ),
  HandymanModel(
    id: '2',
    name: 'أحمد حسن',
    specialty: 'كهربائي خبير',
    rating: 4.8,
    reviewCount: 98,
    hourlyRate: 120,
    avatarGradient: [AppColors.accent[60]!, AppColors.accent[70]!],
  ),
  HandymanModel(
    id: '3',
    name: 'كريم سامي',
    specialty: 'فني تكييفات',
    rating: 4.7,
    reviewCount: 84,
    hourlyRate: 200,
    avatarGradient: [AppColors.secondary[50]!, AppColors.primary[60]!],
  ),
];

// ══════════════════════════════════════════════════════════════
// CustomerHomeView — layout router
// ══════════════════════════════════════════════════════════════
class CustomerHomeView extends StatelessWidget {
  const CustomerHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, c) => c.maxWidth >= 600
          ? const CustomerHomeTabletBody()
          : const CustomerHomeMobileBody(),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// Shared base — all state, animations, logic
// ══════════════════════════════════════════════════════════════
abstract class _HomeBase<T extends StatefulWidget> extends State<T>
    with TickerProviderStateMixin {
  int activeCategoryIndex = 0;
  final searchCtrl = TextEditingController();

  // Bell ring
  late final AnimationController bellCtrl;
  late final Animation<double> bellRotation;

  // Page entry stagger
  late final AnimationController entryCtrl;
  late final List<Animation<double>> entryFade;
  late final List<Animation<Offset>> entrySlide;
  static const _n = 5;

  @override
  void initState() {
    super.initState();

    bellCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    bellRotation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 0.25), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 0.25, end: -0.20), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -0.20, end: 0.15), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 0.15, end: -0.10), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -0.10, end: 0.0), weight: 1),
    ]).animate(CurvedAnimation(parent: bellCtrl, curve: Curves.easeInOut));

    entryCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    entryFade = List.generate(_n, (i) {
      final s = (i * 0.14).clamp(0.0, 1.0);
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: entryCtrl,
          curve: Interval(s, (s + 0.42).clamp(0.0, 1.0), curve: Curves.easeOut),
        ),
      );
    });
    entrySlide = List.generate(_n, (i) {
      final s = (i * 0.14).clamp(0.0, 1.0);
      return Tween<Offset>(
        begin: const Offset(0, 0.14),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: entryCtrl,
          curve: Interval(
            s,
            (s + 0.48).clamp(0.0, 1.0),
            curve: Curves.easeOutCubic,
          ),
        ),
      );
    });

    entryCtrl.forward();
  }

  @override
  void dispose() {
    bellCtrl.dispose();
    searchCtrl.dispose();
    entryCtrl.dispose();
    super.dispose();
  }

  Widget ea(int i, Widget child) {
    final idx = i.clamp(0, _n - 1);
    return FadeTransition(
      opacity: entryFade[idx],
      child: SlideTransition(position: entrySlide[idx], child: child),
    );
  }

  void onNotificationTap() {
    bellCtrl.forward(from: 0);
    HapticFeedback.selectionClick();
    Navigator.of(context).pushNamed(AppRoutes.customerNotifications);
  }

  void onLogout(AppLocalizations l10n) {
    showAnimatedConfirmDialog(
      context: context,
      isDark: Theme.of(context).brightness == Brightness.dark,
      icon: Icons.logout_rounded,
      title: l10n.profileMenuLogout,
      message: l10n.logoutConfirmMessage,
      cancelLabel: l10n.cancel,
      confirmLabel: l10n.profileMenuLogout,
      isDanger: true,
      onConfirm: () async {
        await clearRememberMe();
        if (!mounted) return;
        Navigator.of(context).pushReplacementNamed(AppRoutes.login);
      },
    );
  }

  List<(String, IconData)> categories(AppLocalizations l10n) => [
    (l10n.homeCategoryAll, Icons.grid_view_rounded),
    ('كهرباء', Icons.bolt_rounded),
    ('سباكة', Icons.water_drop_outlined),
    ('دهانات', Icons.format_paint_outlined),
    ('نجارة', Icons.handyman_outlined),
    ('تكييفات', Icons.ac_unit_rounded),
  ];

  // ── Shared section builders ───────────────────────────────

  Widget buildHeader(BuildContext context, AppLocalizations l10n) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cubit = context.read<CustomerCubit>();


    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.xl.w,
        MediaQuery.of(context).padding.top + AppSpacing.md.h,
        AppSpacing.xl.w,
        AppSpacing.xl.h,
      ),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkBgSecondary.withOpacity(0.95)
            : Colors.white.withOpacity(0.95),
        border: Border(
          bottom: BorderSide(color: AppColors.primary[60]!.withOpacity(0.10)),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    BlocBuilder<CustomerCubit, CustomerState>(
                      builder: (context, state) {

                        final name = cubit.profileData?.fullName ?? 'Customer';

                        return Text(
                          '${l10n.homeGreeting} $name 👋',
                          style: textTheme.displaySmall?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      l10n.homeSubtitle,
                      style: textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 12.w),

              // Notification button
              _IconBtn(
                onTap: onNotificationTap,
                badge: '٣',
                isDark: isDark,
                child: AnimatedBuilder(
                  animation: bellRotation,
                  builder: (_, child) =>
                      Transform.rotate(angle: bellRotation.value, child: child),
                  child: Icon(
                    Icons.notifications_outlined,
                    color: AppColors.primary[60],
                    size: 22.sp,
                  ),
                ),
              ),
              SizedBox(width: 10.w),

              // Profile button
              _IconBtn(
                isDark: isDark,
                onTap: () => AppProfilePopup.show(
                  context: context,
                  name: cubit.profileData?.fullName ?? '',
                  email: cubit.profileData?.email ?? '',

                  actions: AppProfilePopup.customerActions(
                    context,
                    profile: l10n.profileMenuProfile,
                    edit: l10n.profileMenuEdit,
                    settings: l10n.profileMenuSettings,
                    help: l10n.profileMenuHelp,
                    logout: l10n.profileMenuLogout,
                    onLogout: () => onLogout(l10n),
                  ),
                ),
                child: Icon(
                  Icons.person_outline_rounded,
                  color: AppColors.primary[60],
                  size: 22.sp,
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          AppSearchBar(
            hintText: l10n.homeSearchHint,
            controller: searchCtrl,
            onSubmitted: (q) {
              if (q.trim().isEmpty) return;
              Navigator.of(context).pushNamed(
                AppRoutes.customerSearchResults,
                arguments: {'query': q.trim()},
              );
            },
          ),
        ],
      ),
    );
  }

  Widget buildBanner(BuildContext context, AppLocalizations l10n) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      margin: EdgeInsets.all(AppSpacing.xl.w),
      padding: EdgeInsets.all(AppSpacing.xl.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary[60]!.withOpacity(0.08),
            AppColors.secondary[60]!.withOpacity(0.08),
          ],
        ),
        borderRadius: BorderRadius.all(AppRadius.lg),
        border: Border.all(
          color: AppColors.primary[60]!.withOpacity(0.15),
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.homeBannerTitle,
                  style: textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  l10n.homeBannerSubtitle,
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 12.w),
          Container(
            width: 56.w,
            height: 56.w,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary[60]!, AppColors.secondary[60]!],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary[60]!.withOpacity(0.30),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(Icons.bolt_rounded, color: Colors.white, size: 28.sp),
          ),
        ],
      ),
    );
  }

  Widget buildCategories(BuildContext context, AppLocalizations l10n,) {
    return BlocBuilder<LookupCubit, LookupState>(
      builder: (context, state) {

        if (state is! LookupLoaded) {
          return const SizedBox.shrink();
        }

        final categories = state.categories;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.xl.w,
                0,
                AppSpacing.xl.w,
                AppSpacing.md.h,
              ),
              child: Text(
                l10n.homeCategories,
                style: Theme.of(context)
                    .textTheme
                    .displaySmall
                    ?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),

            SizedBox(
              height: 52.h,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.xl.w,
                ),
                itemCount: categories.length,
                separatorBuilder: (_, __) =>
                    SizedBox(width: 12.w),
                itemBuilder: (_, i) {

                  final category =
                  categories[i];

                  return AppCategoryChip(
                    label: category.name,
                    icon: Icons.home_repair_service,
                    isActive:
                    activeCategoryIndex == i,
                    onTap: () {

                      setState(() {
                        activeCategoryIndex = i;
                      });

                      Navigator.of(context)
                          .pushNamed(
                        AppRoutes
                            .customerSearchResults,
                        arguments: {
                          'categoryId':
                          category.id,
                        },
                      );
                    },
                  );
                },
              ),
            ),

            SizedBox(height: AppSpacing.xl.h),
          ],
        );
      },
    );
  }

  Widget buildSectionHeader(BuildContext context, AppLocalizations l10n) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.xl.w,
        0,
        AppSpacing.xl.w,
        AppSpacing.md.h,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 32.h),
              Text(
                l10n.homeTopHandymen,
                style: textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                l10n.homeTopHandymenSubtitle,
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          GestureDetector(
            onTap: () {},
            child: Text(
              l10n.homeViewAll,
              style: textTheme.bodyLarge?.copyWith(
                color: AppColors.primary[60],
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildHandymanCard(BuildContext context, AppLocalizations l10n, HandymanModel h,) {
    return AppHandymanCard(
      handyman: h,
      bookLabel: l10n.homeBookNow,
      hourlyRateLabel: l10n.homeHourlyRate,
      reviewsLabel: l10n.homeReviews,
      onTap: () => Navigator.of(
        context,
      ).pushNamed(AppRoutes.customerViewHandyman, arguments: h.id),
      onBook: () =>
          Navigator.of(context).pushNamed(AppRoutes.customerBookService),
    );}
}

// ══════════════════════════════════════════════════════════════
// CustomerHomeMobileBody
// ══════════════════════════════════════════════════════════════
class CustomerHomeMobileBody extends StatefulWidget {
  const CustomerHomeMobileBody({super.key});

  @override
  State<CustomerHomeMobileBody> createState() => _CustomerHomeMobileBodyState();
}

class _CustomerHomeMobileBodyState extends _HomeBase<CustomerHomeMobileBody> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocConsumer<CustomerCubit, CustomerState>(
      listener: (context, state) {

        state.whenOrNull(
          profileLoaded: (profile) {
            debugPrint(
              'PROFILE => ${profile.fullName}',
            );
          },

          message: (message) {
            debugPrint(
              'MESSAGE => $message',
            );
            AppSnackBar.show(
              context,
              message: message,
            );
          },


          error: (message) {
            debugPrint(
              'ERROR => $message',
            );

            AppSnackBar.show(
              context,
              message: message,
              type: AppSnackType.error,
            );
          },

        );
      },
      builder: (_, __) => Scaffold(
        backgroundColor: Colors.transparent,
        body: AppMainBackground(
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: ea(0, buildHeader(context, l10n))),
              SliverToBoxAdapter(child: ea(1, buildBanner(context, l10n))),
              SliverToBoxAdapter(child: ea(2, buildCategories(context, l10n))),
              SliverToBoxAdapter(child: ea(3, buildSectionHeader(context, l10n))),
              SliverPadding(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.xl.w,
                  vertical: 4.h,
                ),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (_, i) => ea(
                      4,
                      Padding(
                        padding: EdgeInsets.only(bottom: 16.h),
                        child: buildHandymanCard(context, l10n, _kHandymen[i]),
                      ),
                    ),
                    childCount: _kHandymen.length,
                  ),
                ),
              ),
              SliverToBoxAdapter(child: SizedBox(height: 100.h)),
            ],
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// CustomerHomeTabletBody
// Left: sticky header + categories (40%) | Right: handyman grid (60%)
// ══════════════════════════════════════════════════════════════
class CustomerHomeTabletBody extends StatefulWidget {
  const CustomerHomeTabletBody({super.key});

  @override
  State<CustomerHomeTabletBody> createState() => _CustomerHomeTabletBodyState();
}

class _CustomerHomeTabletBodyState extends _HomeBase<CustomerHomeTabletBody> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cubit = context.watch<CustomerCubit>();


    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppMainBackground(
        child: Column(
          children: [
            // Full-width header at top
            ea(0, buildHeader(context, l10n)),

            // Below header: two columns
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Left: banner + categories (38%) ─────
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.38,
                    child: SingleChildScrollView(
                      padding: EdgeInsets.only(bottom: 32.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ea(1, buildBanner(context, l10n)),
                          ea(2, buildCategories(context, l10n)),

                          // Quick stats card
                          ea(3, BlocBuilder<CustomerCubit, CustomerState>(
                            builder: (context, state) {
                              if (cubit.statisticsData == null) {
                                return const CircularProgressIndicator();
                              }

                              return _StatsCard(
                                statistics: cubit.statisticsData!,
                                isDark: isDark,
                                l10n: l10n,
                              );
                            },
                          ),),
                        ],
                      ),
                    ),
                  ),

                  // Divider
                  VerticalDivider(
                    width: 1,
                    color: AppColors.primary[60]!.withOpacity(0.08),
                  ),

                  // ── Right: handymen list (62%) ───────────
                  Expanded(
                    child: CustomScrollView(
                      slivers: [
                        SliverToBoxAdapter(
                          child: ea(3, buildSectionHeader(context, l10n)),
                        ),
                        SliverPadding(
                          padding: EdgeInsets.symmetric(
                            horizontal: AppSpacing.xl.w,
                            vertical: 4.h,
                          ),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (_, i) => ea(
                                4,
                                Padding(
                                  padding: EdgeInsets.only(bottom: 16.h),
                                  child: buildHandymanCard(
                                    context,
                                    l10n,
                                    _kHandymen[i],
                                  ),
                                ),
                              ),
                              childCount: _kHandymen.length,
                            ),
                          ),
                        ),
                        SliverToBoxAdapter(child: SizedBox(height: 100.h)),
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
}

// ══════════════════════════════════════════════════════════════
// _StatsCard — tablet-only quick stats strip
// ══════════════════════════════════════════════════════════════
class _StatsCard extends StatefulWidget {
  final bool isDark;
  final AppLocalizations l10n;
  final CustomerStatisticsEntity statistics;
  const _StatsCard({required this.isDark, required this.l10n, required this.statistics});

  @override
  State<_StatsCard> createState() => _StatsCardState();
}

class _StatsCardState extends State<_StatsCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
  );
  late final Animation<double> _fade = CurvedAnimation(
    parent: _ctrl,
    curve: Curves.easeOut,
  );
  late final Animation<Offset> _slide = Tween<Offset>(
    begin: const Offset(0, 0.2),
    end: Offset.zero,
  ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 500), () {
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
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: Container(
          margin: EdgeInsets.symmetric(
            horizontal: AppSpacing.xl.w,
            vertical: 4.h,
          ),
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.primary[60]!, AppColors.secondary[60]!],
            ),
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary[60]!.withOpacity(0.25),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'إحصائياتك',
                style: GoogleFonts.cairo(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.white.withOpacity(0.88),
                ),
              ),
              SizedBox(height: 14.h),
              Row(
                children: [
                  _StatItem(
                    value: widget.statistics.totalRequests.toString(),
                    label: 'طلبات',
                    isDark: false,
                  ),
                  _Vdivider(),
                  _StatItem(
                    value: widget.statistics.completedRequests.toString(),
                    label: 'مكتملة',
                    isDark: false,
                  ),
                  _Vdivider(),
                  _StatItem(
                    value: widget.statistics.pendingRequests.toString(),
                    label: 'معلقة',
                    isDark: false,
                  ),
                ],
              ),            ],
          ),
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  final bool isDark;
  const _StatItem({
    required this.value,
    required this.label,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: GoogleFonts.cairo(
              fontSize: 20.sp,
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
          ),
        ],
      ),
    );
  }
}

class _Vdivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      Container(width: 1, height: 36.h, color: Colors.white.withOpacity(0.25));
}

// ══════════════════════════════════════════════════════════════
// _IconBtn — icon button with optional badge
// ══════════════════════════════════════════════════════════════
class _IconBtn extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  final bool isDark;
  final String? badge;

  const _IconBtn({
    required this.child,
    required this.onTap,
    required this.isDark,
    this.badge,
  });

  @override
  State<_IconBtn> createState() => _IconBtnState();
}

class _IconBtnState extends State<_IconBtn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 110),
  );
  late final Animation<double> _scale = Tween<double>(
    begin: 1.0,
    end: 0.92,
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
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 46.w,
              height: 46.w,
              decoration: BoxDecoration(
                color: widget.isDark ? AppColors.darkSurface : Colors.white,
                borderRadius: BorderRadius.all(AppRadius.md),
                border: Border.all(
                  color: AppColors.primary[60]!.withOpacity(0.10),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(child: widget.child),
            ),
            if (widget.badge != null)
              Positioned(
                top: -4,
                left: -4,
                child: _NotifBadge(label: widget.badge!),
              ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// _NotifBadge — pulsing notification count
// ══════════════════════════════════════════════════════════════
class _NotifBadge extends StatefulWidget {
  final String label;
  const _NotifBadge({required this.label});

  @override
  State<_NotifBadge> createState() => _NotifBadgeState();
}

class _NotifBadgeState extends State<_NotifBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2000),
  )..repeat(reverse: true);
  late final Animation<double> _scale = Tween<double>(
    begin: 1.0,
    end: 1.15,
  ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));

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
        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primary[60]!, AppColors.secondary[60]!],
          ),
          borderRadius: BorderRadius.all(AppRadius.pill),
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary[60]!.withOpacity(0.40),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          widget.label,
          style: TextStyle(
            color: Colors.white,
            fontSize: 10.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
