import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/l10n/translation/app_localizations.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/utils/functions/remeber_me.dart';
import '../../../../core/utils/widgets/animations/shimmers/app_state_box_shimmer.dart';
import '../../../../core/utils/widgets/app_main_background.dart';
import '../../../../core/utils/widgets/animations/animated_confirm_dialog.dart';
import '../../../../core/utils/widgets/app_snack_bar.dart';
import '../../../../core/utils/widgets/app_stat_box.dart';
import '../../../../core/utils/widgets/buttons/app_settings_button.dart';
import '../../domain/entities/customer_statistics_entity.dart';
import '../cubit/customer_cubit.dart';
import '../cubit/customer_state.dart';

// ══════════════════════════════════════════════════════════════
// CustomerProfileView — layout router
// ══════════════════════════════════════════════════════════════
class CustomerProfileView extends StatelessWidget {
  const CustomerProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, c) => c.maxWidth >= 600
          ? const CustomerProfileTabletBody()
          : const CustomerProfileMobileBody(),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// Shared base — animations + logic
// ══════════════════════════════════════════════════════════════
abstract class _ProfileBase<T extends StatefulWidget> extends State<T>
    with TickerProviderStateMixin {
  static const Color _accent = Color(0xFFFF6B35); // AppColors.primary[60]

  late final AnimationController entryCtrl;

  // Avatar
  late final Animation<double> avatarScale;
  late final Animation<double> avatarOpacity;
  CustomerStatisticsEntity? _statistics;

  // Content stagger
  late final AnimationController staggerCtrl;
  late final List<Animation<double>> stagFade;
  late final List<Animation<Offset>> stagSlide;
  static const _n = 5;

  @override
  void initState() {
    super.initState();
    context.read<CustomerCubit>().getProfile();

    entryCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    avatarScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: entryCtrl,
        curve: const Interval(0.0, 0.55, curve: Curves.elasticOut),
      ),
    );
    avatarOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: entryCtrl,
        curve: const Interval(0.0, 0.30, curve: Curves.easeOut),
      ),
    );

    staggerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    stagFade = List.generate(_n, (i) {
      final s = (i * 0.14).clamp(0.0, 1.0);
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: staggerCtrl,
          curve: Interval(s, (s + 0.42).clamp(0.0, 1.0), curve: Curves.easeOut),
        ),
      );
    });
    stagSlide = List.generate(_n, (i) {
      final s = (i * 0.14).clamp(0.0, 1.0);
      return Tween<Offset>(
        begin: const Offset(0, 0.15),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: staggerCtrl,
          curve: Interval(
            s,
            (s + 0.48).clamp(0.0, 1.0),
            curve: Curves.easeOutCubic,
          ),
        ),
      );
    });

    entryCtrl.forward();

    context.read<CustomerCubit>().getProfile();
    context.read<CustomerCubit>().getStatistics();

    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) staggerCtrl.forward();
    });
  }

  @override
  void dispose() {
    entryCtrl.dispose();
    staggerCtrl.dispose();
    super.dispose();
  }

  Widget sa(int i, Widget child) {
    final idx = i.clamp(0, _n - 1);
    return FadeTransition(
      opacity: stagFade[idx],
      child: SlideTransition(position: stagSlide[idx], child: child),
    );
  }

  void showLogoutDialog(AppLocalizations l10n) {
    showAnimatedConfirmDialog(
      context: context,
      isDark: Theme.of(context).brightness == Brightness.dark,
      icon: Icons.logout_rounded,
      title: l10n.profileLogoutTitle,
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

  // ── Shared widgets ────────────────────────────────────────

  Widget buildAvatar() {
    return AnimatedBuilder(
      animation: entryCtrl,
      builder: (_, __) => Opacity(
        opacity: avatarOpacity.value,
        child: Transform.scale(
          scale: avatarScale.value,
          child: Stack(
            alignment: Alignment.bottomLeft,
            children: [
              Container(
                width: 96.w,
                height: 96.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.primary[60]!, AppColors.secondary[60]!],
                  ),
                  border: Border.all(color: Colors.white, width: 4),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary[60]!.withOpacity(0.30),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.person_rounded,
                  size: 46.sp,
                  color: Colors.white,
                ),
              ),
              Container(
                width: 28.w,
                height: 28.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.camera_alt_rounded,
                  size: 14.sp,
                  color: AppColors.primary[60],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildStats(bool isDark, AppLocalizations l10n,) {
    return Row(
      children: [
        Expanded(
          child: AppStatBox(
            value: _statistics?.totalRequests.toString() ?? '-',
            label: l10n.profileStatTotal,
            isDark: isDark,
            accentColor: AppColors.primary[60]!,
            delay: 0,
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: AppStatBox(
            value: _statistics?.completedRequests.toString() ?? '-',
            label: l10n.profileStatCompleted,
            isDark: isDark,
            accentColor: AppColors.primary[60]!,
            delay: 80,
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: AppStatBox(
            value: _statistics?.pendingRequests.toString() ?? '-',
            label: l10n.profileStatActive,
            isDark: isDark,
            accentColor: AppColors.primary[60]!,
            delay: 160,
          ),
        ),
      ],
    );
  }

  Widget buildMenuItems(bool isDark, AppLocalizations l10n) {
    return Column(
      children: [
        AppSettingsItem(
          icon: Icons.description_outlined,
          iconBgColor: AppColors.primary[60]!.withOpacity(0.10),
          iconColor: AppColors.primary[60]!,
          label: l10n.profileMenuRequests,
          isDark: isDark,
          onTap: () => AppSnackBar.show(context, message: l10n.comingSoon),
        ),
        SizedBox(height: 10.h),
        AppSettingsItem(
          icon: Icons.notifications_outlined,
          iconBgColor: AppColors.primary[60]!.withOpacity(0.10),
          iconColor: AppColors.primary[60]!,
          label: l10n.profileMenuNotifications,
          isDark: isDark,
          onTap: () =>
              Navigator.of(context).pushNamed(AppRoutes.customerNotifications),
        ),
        SizedBox(height: 10.h),
        AppSettingsItem(
          icon: Icons.help_outline_rounded,
          iconBgColor: AppColors.info.withOpacity(0.10),
          iconColor: AppColors.info,
          label: l10n.profileMenuHelp,
          isDark: isDark,
          onTap: () => Navigator.of(
            context,
          ).pushNamed(AppRoutes.sharedHelpSupport, arguments: false),
        ),
        SizedBox(height: 10.h),
        AppSettingsItem(
          icon: Icons.settings_outlined,
          iconBgColor: AppColors.primary[60]!.withOpacity(0.10),
          iconColor: AppColors.primary[60]!,
          label: l10n.profileMenuSettings,
          isDark: isDark,
          onTap: () =>
              Navigator.of(context).pushNamed(AppRoutes.customerSettings),
        ),
        SizedBox(height: 10.h),
        AppSettingsItem(
          icon: Icons.logout_rounded,
          iconBgColor: AppColors.danger.withOpacity(0.10),
          iconColor: AppColors.danger,
          label: l10n.profileMenuLogout,
          isDark: isDark,
          isDanger: true,
          showChevron: false,
          onTap: () => showLogoutDialog(l10n),
        ),
      ],
    );
  }
}


// ══════════════════════════════════════════════════════════════
// CustomerProfileMobileBody
// ══════════════════════════════════════════════════════════════
class CustomerProfileMobileBody extends StatefulWidget {
  const CustomerProfileMobileBody({super.key});

  @override
  State<CustomerProfileMobileBody> createState() =>
      _CustomerProfileMobileBodyState();
}

class _CustomerProfileMobileBodyState
    extends _ProfileBase<CustomerProfileMobileBody> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final cubit = context.watch<CustomerCubit>();

    return BlocListener<CustomerCubit, CustomerState>(
        listener: (context, state) {
          state.whenOrNull(
            error: (message) {
              AppSnackBar.show(
                context,
                message: message,
                type: AppSnackType.error,
              );
            },
            statisticsLoaded: (statistics) {
              setState(() {
                _statistics = statistics;
              });
            },
          );
        },
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: AppMainBackground(
            child: CustomScrollView(
              slivers: [
                // Hero header
                SliverToBoxAdapter(
                  child: _buildHeroHeader(textTheme, colorScheme, isDark, l10n),
                ),

                // Stats
                SliverToBoxAdapter(
                  child: sa(
                    0,
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                        AppSpacing.xl.w,
                        AppSpacing.lg.h,
                        AppSpacing.xl.w,
                        AppSpacing.md.h,
                      ),
                      child: buildStats(isDark, l10n),
                    ),
                  ),
                ),

                // Menu
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(
                    AppSpacing.xl.w,
                    AppSpacing.md.h,
                    AppSpacing.xl.w,
                    AppSpacing.md.h,
                  ),
                  sliver: SliverToBoxAdapter(
                    child: sa(1, buildMenuItems(isDark, l10n)),
                  ),
                ),
                // Bottom clearance for nav bar
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: MediaQuery.of(context).padding.bottom + 100.h,
                  ),
                ),
              ],
            ),
          ),
        )
    );
  }

  Widget _buildHeroHeader(
    TextTheme textTheme,
    ColorScheme colorScheme,
    bool isDark,
    AppLocalizations l10n,
  ) {
    final cubit = context.watch<CustomerCubit>();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        AppSpacing.xl.w,
        MediaQuery.of(context).padding.top + AppSpacing.xl.h,
        AppSpacing.xl.w,
        AppSpacing.xl.h,
      ),
      decoration: BoxDecoration(
        gradient: isDark
            ? LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.darkBgSecondary,
                  AppColors.darkBgPrimary.withOpacity(0.6),
                ],
              )
            : LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.white, Colors.white.withOpacity(0.4)],
              ),
      ),
      child: Column(
        children: [
          buildAvatar(),
          SizedBox(height: 16.h),
          sa(0, Text(
             cubit.profileData?.fullName ?? 'غير معروف',
             style: textTheme.headlineSmall?.copyWith(
               fontWeight: FontWeight.w800,),
          )),
          SizedBox(height: 6.h),
          sa(
            1,
            BlocBuilder<CustomerCubit, CustomerState>(
              builder: (context, state) {
                return state.maybeWhen(
                  profileLoaded: (profile) => Text(
                    profile.phone,
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  orElse: () => const SizedBox(),
                );
              },
            ),          ),
          SizedBox(height: 18.h),
          sa(
            2,
            _EditBtn(
              label: l10n.profileEditButton,
              isDark: isDark,
              onTap: () =>
                  Navigator.of(context).pushNamed(AppRoutes.customerEditProfileView),
            ),
          ),
        ],
      ),
    );
  }
}


// ══════════════════════════════════════════════════════════════
// CustomerProfileTabletBody — centered card, proper bg, animated
// ══════════════════════════════════════════════════════════════
class CustomerProfileTabletBody extends StatefulWidget {
  const CustomerProfileTabletBody({super.key});

  @override
  State<CustomerProfileTabletBody> createState() =>
      _CustomerProfileTabletBodyState();
}

class _CustomerProfileTabletBodyState
    extends _ProfileBase<CustomerProfileTabletBody> {
  // Extra float animation for avatar on tablet
  late final AnimationController _floatCtrl;
  late final Animation<double> _floatY;

  @override
  void initState() {
    super.initState();
    _floatCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..repeat(reverse: true);
    _floatY = Tween<double>(
      begin: -6.0,
      end: 6.0,
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
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    return BlocListener<CustomerCubit, CustomerState>(
        listener: (context, state) {
          state.whenOrNull(
            error: (message) {
              AppSnackBar.show(
                context,
                message: message,
                type: AppSnackType.error,
              );
            },
            statisticsLoaded: (statistics) {
              setState(() {
                _statistics = statistics;
              });
            },
          );
        },
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: AppMainBackground(
            child: SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 580),
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.xl.w,
                      vertical: AppSpacing.xl.h,
                    ),
                    child: Column(
                      children: [
                        // ── Hero card ──────────────────────────
                        sa(0, _buildHeroCard(textTheme, colorScheme, isDark, l10n)),
                        SizedBox(height: 20.h),

                        // ── Stats row ──────────────────────────
                        sa(1, buildStats(isDark, l10n)),
                        SizedBox(height: 20.h),

                        // ── Menu items ─────────────────────────
                        sa(2, buildMenuItems(isDark, l10n)),
                        SizedBox(height: 32.h),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        )
    );
  }

  Widget _buildHeroCard(
    TextTheme textTheme,
    ColorScheme colorScheme,
    bool isDark,
    AppLocalizations l10n,
  ) {
    final cubit = context.watch<CustomerCubit>();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        vertical: 32.h,
        horizontal: AppSpacing.xl.w,
      ),
      decoration: BoxDecoration(
        gradient: isDark
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.darkSurface, AppColors.darkBgSecondary],
              )
            : LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white,
                  AppColors.primary[60]!.withOpacity(0.04),
                ],
              ),
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(
          color: AppColors.primary[60]!.withOpacity(0.12),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary[60]!.withOpacity(isDark ? 0.08 : 0.10),
            blurRadius: 30,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Floating avatar
          AnimatedBuilder(
            animation: _floatCtrl,
            builder: (_, child) => Transform.translate(
              offset: Offset(0, _floatY.value),
              child: child,
            ),
            child: buildAvatar(),
          ),
          SizedBox(height: 16.h),

          Text(
            cubit.profileData?.fullName ?? 'غير معروف',
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 6.h),
          BlocBuilder<CustomerCubit, CustomerState>(
            builder: (context, state) {
              return state.maybeWhen(
                profileLoaded: (profile) => Text(
                  profile.phone,
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                orElse: () => const SizedBox(),
              );
            },
          ),
          SizedBox(height: 20.h),

          _EditBtn(
            label: l10n.profileEditButton,
            isDark: isDark,
            onTap: () =>
                Navigator.of(context).pushNamed(AppRoutes.customerEditProfileView),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// _EditBtn — shared edit profile button with scale press
// ══════════════════════════════════════════════════════════════
class _EditBtn extends StatefulWidget {
  final String label;
  final bool isDark;
  final VoidCallback onTap;
  const _EditBtn({
    required this.label,
    required this.isDark,
    required this.onTap,
  });

  @override
  State<_EditBtn> createState() => _EditBtnState();
}

class _EditBtnState extends State<_EditBtn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 120),
  );
  late final Animation<double> _scale = Tween<double>(
    begin: 1.0,
    end: 0.95,
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
          padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 10.h),
          decoration: BoxDecoration(
            color: widget.isDark ? AppColors.darkSurface : Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: AppColors.primary[60]!.withOpacity(0.20),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            widget.label,
            style: GoogleFonts.cairo(
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.primary[60],
            ),
          ),
        ),
      ),
    );
  }
}

