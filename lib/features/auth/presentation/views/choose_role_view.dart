import 'package:fix_it/core/router/app_routes.dart';
import '../../../../config/di/di.dart';
import '../../../../config/providers/app_config_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/l10n/translation/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/utils/widgets/app_auth_background.dart';
import '../../../../core/utils/widgets/app_info.dart';
import '../../../../core/utils/widgets/app_logo_header.dart';
import '../../../../core/utils/widgets/feature_badge.dart';

// ══════════════════════════════════════════════════════════════
// ChooseRoleView — layout router
// ══════════════════════════════════════════════════════════════
class ChooseRoleView extends StatelessWidget {
  const ChooseRoleView({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, c) => c.maxWidth >= 600
          ? const ChooseRoleTabletBody()
          : const ChooseRoleMobileBody(),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// Shared base — animations + navigation, zero duplication
// ══════════════════════════════════════════════════════════════
abstract class _ChooseRoleBase<T extends StatefulWidget> extends State<T>
    with TickerProviderStateMixin {
  late final AnimationController entryCtrl;
  late final List<Animation<double>> fadeAnims;
  late final List<Animation<Offset>> slideAnims;
  static const _n = 6;

  @override
  void initState() {
    super.initState();
    entryCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    fadeAnims = List.generate(_n, (i) {
      final s = (i * 0.12).clamp(0.0, 1.0);
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: entryCtrl,
          curve: Interval(s, (s + 0.40).clamp(0.0, 1.0), curve: Curves.easeOut),
        ),
      );
    });

    slideAnims = List.generate(_n, (i) {
      final s = (i * 0.12).clamp(0.0, 1.0);
      return Tween<Offset>(
        begin: const Offset(0, 0.20),
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
    entryCtrl.dispose();
    super.dispose();
  }

  Widget a(int i, Widget child) {
    final idx = i.clamp(0, _n - 1);
    return FadeTransition(
      opacity: fadeAnims[idx],
      child: SlideTransition(position: slideAnims[idx], child: child),
    );
  }

  Future<void> goCustomer() async {
    await getIt<AppConfigProvider>().setUserType(isHandyman: false);
    if (!mounted) return;
    Navigator.of(context).pushNamed(AppRoutes.registerCustomer);
  }

  Future<void> goHandyman() async {
    await getIt<AppConfigProvider>().setUserType(isHandyman: true);
    if (!mounted) return;
    Navigator.of(context).pushNamed(AppRoutes.registerHandyman);
  }

  void goLogin() => Navigator.of(context).pushReplacementNamed(AppRoutes.login);
}

// ══════════════════════════════════════════════════════════════
// ChooseRoleMobileBody
// ══════════════════════════════════════════════════════════════
class ChooseRoleMobileBody extends StatefulWidget {
  const ChooseRoleMobileBody({super.key});

  @override
  State<ChooseRoleMobileBody> createState() => _ChooseRoleMobileBodyState();
}

class _ChooseRoleMobileBodyState extends _ChooseRoleBase<ChooseRoleMobileBody> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: AppAuthBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.xl.w,
              vertical: AppSpacing.xl.h,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 24.h),

                a(
                  0,
                  AppLogoHeader(
                    title: l10n.chooseRoleTitle,
                    subtitle: l10n.chooseRoleSubtitle,
                  ),
                ),
                SizedBox(height: 24.h),

                a(1, AppInfoBox(message: l10n.chooseRoleInfoBox)),
                SizedBox(height: 24.h),

                // Customer card
                a(
                  2,
                  _RoleCard(
                    accentColor: AppColors.primary[60]!,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.primary[60]!,
                        AppColors.secondary[60]!,
                      ],
                    ),
                    icon: Icons.person_outline_rounded,
                    title: l10n.customerRoleTitle,
                    subtitle: l10n.customerRoleSubtitle,
                    description: l10n.customerRoleDescription,
                    features: [
                      l10n.customerFeature1,
                      l10n.customerFeature2,
                      l10n.customerFeature3,
                    ],
                    onTap: goCustomer,
                    entryDelay: 400,
                  ),
                ),
                SizedBox(height: 16.h),

                // Handyman card
                a(
                  3,
                  _RoleCard(
                    accentColor: AppColors.accent[60]!,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppColors.accent[60]!, AppColors.accent[70]!],
                    ),
                    icon: Icons.build_outlined,
                    title: l10n.handymanRoleTitle,
                    subtitle: l10n.handymanRoleSubtitle,
                    description: l10n.handymanRoleDescription,
                    features: [
                      l10n.handymanFeature1,
                      l10n.handymanFeature2,
                      l10n.handymanFeature3,
                    ],
                    note: l10n.handymanReviewNote,
                    onTap: goHandyman,
                    entryDelay: 550,
                  ),
                ),
                SizedBox(height: 16.h),

                a(4, _OrDivider(l10n: l10n)),
                SizedBox(height: 12.h),

                a(5, _LoginLink(l10n: l10n, onTap: goLogin)),
                SizedBox(height: 24.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// ChooseRoleTabletBody — same as mobile, centered + constrained
// ══════════════════════════════════════════════════════════════
class ChooseRoleTabletBody extends StatefulWidget {
  const ChooseRoleTabletBody({super.key});

  @override
  State<ChooseRoleTabletBody> createState() => _ChooseRoleTabletBodyState();
}

class _ChooseRoleTabletBodyState extends _ChooseRoleBase<ChooseRoleTabletBody> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: AppAuthBackground(
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              // Centered, max 640 — same cards just wider breathing room
              constraints: const BoxConstraints(maxWidth: 640),
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.xxl.w,
                  vertical: AppSpacing.xl.h,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 32.h),

                    a(
                      0,
                      AppLogoHeader(
                        title: l10n.chooseRoleTitle,
                        subtitle: l10n.chooseRoleSubtitle,
                        logoSize: 56,
                      ),
                    ),
                    SizedBox(height: 28.h),

                    a(1, AppInfoBox(message: l10n.chooseRoleInfoBox)),
                    SizedBox(height: 28.h),

                    a(
                      2,
                      _RoleCard(
                        accentColor: AppColors.primary[60]!,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.primary[60]!,
                            AppColors.secondary[60]!,
                          ],
                        ),
                        icon: Icons.person_outline_rounded,
                        title: l10n.customerRoleTitle,
                        subtitle: l10n.customerRoleSubtitle,
                        description: l10n.customerRoleDescription,
                        features: [
                          l10n.customerFeature1,
                          l10n.customerFeature2,
                          l10n.customerFeature3,
                        ],
                        onTap: goCustomer,
                        entryDelay: 400,
                      ),
                    ),
                    SizedBox(height: 16.h),

                    a(
                      3,
                      _RoleCard(
                        accentColor: AppColors.accent[60]!,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.accent[60]!,
                            AppColors.accent[70]!,
                          ],
                        ),
                        icon: Icons.build_outlined,
                        title: l10n.handymanRoleTitle,
                        subtitle: l10n.handymanRoleSubtitle,
                        description: l10n.handymanRoleDescription,
                        features: [
                          l10n.handymanFeature1,
                          l10n.handymanFeature2,
                          l10n.handymanFeature3,
                        ],
                        note: l10n.handymanReviewNote,
                        onTap: goHandyman,
                        entryDelay: 550,
                      ),
                    ),
                    SizedBox(height: 16.h),

                    a(4, _OrDivider(l10n: l10n)),
                    SizedBox(height: 12.h),

                    a(5, _LoginLink(l10n: l10n, onTap: goLogin)),
                    SizedBox(height: 32.h),
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
// _RoleCard — animated icon float + glow + press scale
// ══════════════════════════════════════════════════════════════
class _RoleCard extends StatefulWidget {
  final LinearGradient gradient;
  final IconData icon;
  final Color accentColor;
  final String title;
  final String subtitle;
  final String description;
  final List<String> features;
  final String? note;
  final VoidCallback onTap;
  final int entryDelay;

  const _RoleCard({
    required this.gradient,
    required this.icon,
    required this.accentColor,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.features,
    required this.onTap,
    this.note,
    this.entryDelay = 0,
  });

  @override
  State<_RoleCard> createState() => _RoleCardState();
}

class _RoleCardState extends State<_RoleCard> with TickerProviderStateMixin {
  // Entry pop
  late final AnimationController _entryCtrl;
  late final Animation<double> _entryScale;
  late final Animation<double> _entryOpacity;

  // Icon float
  late final AnimationController _floatCtrl;
  late final Animation<double> _floatY;

  // Icon glow pulse
  late final AnimationController _glowCtrl;
  late final Animation<double> _glowOpacity;

  // Press
  late final AnimationController _pressCtrl;
  late final Animation<double> _pressScale;

  final bool _isHovered = false;

  @override
  void initState() {
    super.initState();

    _entryCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _entryScale = Tween<double>(
      begin: 0.85,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOutBack));
    _entryOpacity = CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOut);

    _floatCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);
    _floatY = Tween<double>(
      begin: -4.0,
      end: 4.0,
    ).animate(CurvedAnimation(parent: _floatCtrl, curve: Curves.easeInOut));

    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);
    _glowOpacity = Tween<double>(
      begin: 0.20,
      end: 0.45,
    ).animate(CurvedAnimation(parent: _glowCtrl, curve: Curves.easeInOut));

    _pressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _pressScale = Tween<double>(
      begin: 1.0,
      end: 0.97,
    ).animate(CurvedAnimation(parent: _pressCtrl, curve: Curves.easeOut));

    Future.delayed(Duration(milliseconds: widget.entryDelay), () {
      if (mounted) _entryCtrl.forward();
    });
  }

  @override
  void dispose() {
    _entryCtrl.dispose();
    _floatCtrl.dispose();
    _glowCtrl.dispose();
    _pressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return FadeTransition(
      opacity: _entryOpacity,
      child: ScaleTransition(
        scale: _entryScale,
        child: GestureDetector(
          onTapDown: (_) {
            _pressCtrl.forward();
            HapticFeedback.selectionClick();
          },
          onTapUp: (_) {
            _pressCtrl.reverse();
            widget.onTap();
          },
          onTapCancel: () => _pressCtrl.reverse(),
          child: ScaleTransition(
            scale: _pressScale,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: EdgeInsets.all(AppSpacing.xl.w),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : colorScheme.surface,
                borderRadius: BorderRadius.all(AppRadius.lg),
                border: Border.all(
                  color: _isHovered
                      ? widget.accentColor
                      : widget.accentColor.withOpacity(0.20),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: widget.accentColor.withOpacity(0.10),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Header: floating icon + title ────
                  Row(
                    children: [
                      // Floating icon with glow
                      AnimatedBuilder(
                        animation: Listenable.merge([_floatCtrl, _glowCtrl]),
                        builder: (_, __) => Transform.translate(
                          offset: Offset(0, _floatY.value),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Glow ring
                              Container(
                                width: 72.w,
                                height: 72.w,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: widget.accentColor.withOpacity(
                                        _glowOpacity.value,
                                      ),
                                      blurRadius: 20,
                                      spreadRadius: 4,
                                    ),
                                  ],
                                ),
                              ),
                              // Icon circle
                              Container(
                                width: 60.w,
                                height: 60.w,
                                decoration: BoxDecoration(
                                  gradient: widget.gradient,
                                  borderRadius: BorderRadius.all(AppRadius.md),
                                  boxShadow: [
                                    BoxShadow(
                                      color: widget.accentColor.withOpacity(
                                        0.35,
                                      ),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  widget.icon,
                                  color: Colors.white,
                                  size: 28.sp,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(width: 16.w),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(widget.title, style: textTheme.displaySmall),
                            SizedBox(height: 4.h),
                            Text(
                              widget.subtitle,
                              style: textTheme.bodyLarge?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 16.sp,
                        color: widget.accentColor.withOpacity(0.60),
                      ),
                    ],
                  ),
                  SizedBox(height: 14.h),

                  // ── Description ──────────────────────
                  Text(
                    widget.description,
                    style: textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      height: 1.6,
                    ),
                  ),
                  SizedBox(height: 12.h),

                  // ── Feature badges ───────────────────
                  Wrap(
                    spacing: 8.w,
                    runSpacing: 8.h,
                    children: widget.features
                        .map((f) => FeatureBadge(label: f))
                        .toList(),
                  ),

                  // ── Note ─────────────────────────────
                  if (widget.note != null) ...[
                    SizedBox(height: 12.h),
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          size: 14.sp,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        SizedBox(width: 6.w),
                        Expanded(
                          child: Text(
                            widget.note!,
                            style: textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// _OrDivider — shared
// ══════════════════════════════════════════════════════════════
class _OrDivider extends StatelessWidget {
  final AppLocalizations l10n;
  const _OrDivider({required this.l10n});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Row(
      children: [
        Expanded(child: Divider(color: colorScheme.outline)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm.w),
          child: Text(
            l10n.orDivider,
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Expanded(child: Divider(color: colorScheme.outline)),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════
// _LoginLink — shared
// ══════════════════════════════════════════════════════════════
class _LoginLink extends StatefulWidget {
  final AppLocalizations l10n;
  final VoidCallback onTap;
  const _LoginLink({required this.l10n, required this.onTap});

  @override
  State<_LoginLink> createState() => _LoginLinkState();
}

class _LoginLinkState extends State<_LoginLink>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 150),
  );
  late final Animation<double> _scale = Tween<double>(
    begin: 1.0,
    end: 0.94,
  ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          widget.l10n.alreadyHaveAccount,
          style: textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w400),
        ),
        SizedBox(width: 4.w),
        GestureDetector(
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
            child: Text(
              widget.l10n.signInLink,
              style: GoogleFonts.cairo(
                fontSize: 13.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.primary[60],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
