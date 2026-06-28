import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../config/di/di.dart';
import '../../../../config/providers/app_config_provider.dart';
import '../../../../core/l10n/translation/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/utils/functions/remeber_me.dart';
import '../../../../core/utils/widgets/app_main_background.dart';
import '../../../../core/utils/widgets/animations/animated_confirm_dialog.dart';
import '../../../../core/utils/widgets/app_page_header.dart';
import '../../../../core/utils/widgets/app_snack_bar.dart';
import '../../../../core/utils/widgets/buttons/app_settings_button.dart';

// ══════════════════════════════════════════════════════════════
// CustomerSettingsView — layout router
// ══════════════════════════════════════════════════════════════
class CustomerSettingsView extends StatelessWidget {
  const CustomerSettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, c) => c.maxWidth >= 600
          ? const CustomerSettingsTabletBody()
          : const CustomerSettingsMobileBody(),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// Shared base
// ══════════════════════════════════════════════════════════════
abstract class _SettingsBase<T extends StatefulWidget> extends State<T>
    with TickerProviderStateMixin {
  Color get accent => AppColors.primary[60]!;
  bool notificationsEnabled = true;

  late final AnimationController entryCtrl;
  late final List<Animation<double>> entryFade;
  late final List<Animation<Offset>> entrySlide;
  bool rememberMeEnabled = false;
  static const _n = 5;

  @override
  void initState() {
    super.initState();
    entryCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 750),
    );
    entryFade = List.generate(_n, (i) {
      final s = (i * 0.14).clamp(0.0, 1.0);
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: entryCtrl,
          curve: Interval(s, (s + 0.45).clamp(0.0, 1.0), curve: Curves.easeOut),
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
            (s + 0.50).clamp(0.0, 1.0),
            curve: Curves.easeOutCubic,
          ),
        ),
      );
    });
    entryCtrl.forward();

    Future.microtask(() async {
      rememberMeEnabled = await getRememberMe();

      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
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

  void onDeleteAccount(AppLocalizations l10n) {
    showAnimatedConfirmDialog(
      context: context,
      isDark: Theme.of(context).brightness == Brightness.dark,
      icon: Icons.delete_outline_rounded,
      title: l10n.settingsDeleteTitle,
      message: l10n.settingsDeleteConfirm,
      cancelLabel: l10n.settingsDeleteCancel,
      confirmLabel: l10n.settingsDeleteConfirmBtn,
      isDanger: true,
      onConfirm: () {},
    );
  }

  Widget buildSections(bool isDark, AppLocalizations l10n) {
    final config = getIt<AppConfigProvider>();
    final isAr = config.isAr();
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        // ── Preferences ──────────────────────────────────
        ea(
          1,
          AppSettingsSection(
            title: l10n.settingsSectionApp,
            isDark: isDark,
            children: [
              // Notifications toggle
              AppSettingsItem(
                icon: Icons.notifications_outlined,
                iconBgColor: const Color(0xFFFFF7ED),
                iconColor: const Color(0xFFEA580C),
                label: l10n.settingsNotifications,
                isDark: isDark,
                showChevron: false,
                trailing: _AnimatedSwitch(
                  value: notificationsEnabled,
                  activeColor: accent,
                  onChanged: (v) {
                    HapticFeedback.selectionClick();
                    setState(() => notificationsEnabled = v);
                  },
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 4.h),

        ea(
          2,
            AppSettingsItem(
              icon: Icons.lock_clock_outlined,
              iconBgColor: const Color(0xFFEFF6FF),
              iconColor: const Color(0xFF2563EB),
              label: 'تذكرني',
              subtitle: 'ابقيني متصلا',
              isDark: isDark,
              showChevron: false,
              trailing: _AnimatedSwitch(
                value: rememberMeEnabled,
                activeColor: accent,
                onChanged: (v) async {

                  HapticFeedback.selectionClick();

                  await setRememberMe(v);

                  setState(() {
                    rememberMeEnabled = v;
                  });

                  AppSnackBar.show(
                    context,
                    message: v
                        ? 'Remember Me Enabled'
                        : 'Remember Me Disabled',
                  );
                },
              ),
            ),
        ),
        SizedBox(height: 4.h),

        // ── Appearance ───────────────────────────────────
        ea(
          3,
          AppSettingsSection(
            title: l10n.settingsSectionAppearance,
            isDark: isDark,
            children: [
              // Dark / Light mode
              AppSettingsItem(
                icon: isDarkMode
                    ? Icons.dark_mode_rounded
                    : Icons.light_mode_rounded,
                iconBgColor: isDarkMode
                    ? const Color(0xFF1E293B)
                    : const Color(0xFFFFFBEB),
                iconColor: isDarkMode
                    ? const Color(0xFF94A3B8)
                    : const Color(0xFFF59E0B),
                label: isDarkMode
                    ? l10n.settingsDarkMode
                    : l10n.settingsLightMode,
                isDark: isDark,
                showChevron: false,
                trailing: _AnimatedSwitch(
                  value: isDarkMode,
                  activeColor: const Color(0xFF6366F1),
                  onChanged: (v) {
                    HapticFeedback.selectionClick();
                    config.changeTheme(currentTheme: v ? 'dark' : 'light');
                  },
                ),
              ),

              // Language toggle
              AppSettingsItem(
                icon: Icons.language_rounded,
                iconBgColor: const Color(0xFFEFF6FF),
                iconColor: const Color(0xFF3B82F6),
                label: isAr ? l10n.settingsLanguageAr : l10n.settingsLanguageEn,
                subtitle: isAr ? 'العربية' : 'English',
                isDark: isDark,
                showChevron: false,
                trailing: _LangToggle(
                  isAr: isAr,
                  accent: accent,
                  onToggle: () {
                    HapticFeedback.selectionClick();
                    config.changeLocale(currentLocale: isAr ? 'en' : 'ar');
                  },
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 4.h),

        // ── Legal ─────────────────────────────────────────
        ea(
          4,
          AppSettingsSection(
            title: l10n.settingsSectionLegal,
            isDark: isDark,
            children: [
              AppSettingsItem(
                icon: Icons.shield_outlined,
                iconBgColor: const Color(0xFFFAF5FF),
                iconColor: const Color(0xFF9333EA),
                label: l10n.settingsPrivacyPolicy,
                isDark: isDark,
                onTap: () =>
                    AppSnackBar.show(context, message: l10n.comingSoon),
              ),
              AppSettingsItem(
                icon: Icons.article_outlined,
                iconBgColor: const Color(0xFFFFF1F2),
                iconColor: const Color(0xFFE11D48),
                label: l10n.settingsTerms,
                isDark: isDark,
                onTap: () =>
                    AppSnackBar.show(context, message: l10n.comingSoon),
              ),
            ],
          ),
        ),
        SizedBox(height: 20.h),

        // ── Danger ────────────────────────────────────────
        // ea(
        //   5,
        //   AppSettingsDangerButton(
        //     label: l10n.settingsDeleteAccount,
        //     icon: Icons.delete_outline_rounded,
        //     onTap: () => onDeleteAccount(l10n),
        //   ),
        // ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════
// CustomerSettingsMobileBody
// ══════════════════════════════════════════════════════════════
class CustomerSettingsMobileBody extends StatefulWidget {
  const CustomerSettingsMobileBody({super.key});

  @override
  State<CustomerSettingsMobileBody> createState() =>
      _CustomerSettingsMobileBodyState();
}

class _CustomerSettingsMobileBodyState
    extends _SettingsBase<CustomerSettingsMobileBody> {
  @override
  Widget build(BuildContext context) {
    // Rebuild when provider changes (theme/lang)
    return ChangeNotifierProvider.value(
      value: getIt<AppConfigProvider>(),
      child: Consumer<AppConfigProvider>(
        builder: (context, _, __) {
          final isDark = Theme.of(context).brightness == Brightness.dark;
          final l10n = AppLocalizations.of(context)!;
          return Scaffold(
            backgroundColor: Colors.transparent,
            body: AppMainBackground(
              child: Column(
                children: [
                  AppPageHeader(
                    isDark: isDark,
                    title: l10n.settingsTitle,
                    accentColor: accent,
                  ),
                  Expanded(
                    child: ListView(
                      padding: EdgeInsets.fromLTRB(
                        AppSpacing.xl.w,
                        AppSpacing.xl.h,
                        AppSpacing.xl.w,
                        MediaQuery.of(context).padding.bottom + 32.h,
                      ),
                      children: [buildSections(isDark, l10n)],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// CustomerSettingsTabletBody
// ══════════════════════════════════════════════════════════════
class CustomerSettingsTabletBody extends StatefulWidget {
  const CustomerSettingsTabletBody({super.key});

  @override
  State<CustomerSettingsTabletBody> createState() =>
      _CustomerSettingsTabletBodyState();
}

class _CustomerSettingsTabletBodyState
    extends _SettingsBase<CustomerSettingsTabletBody> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: getIt<AppConfigProvider>(),
      child: Consumer<AppConfigProvider>(
        builder: (context, _, __) {
          final isDark = Theme.of(context).brightness == Brightness.dark;
          final l10n = AppLocalizations.of(context)!;
          return Scaffold(
            backgroundColor: Colors.transparent,
            body: AppMainBackground(
              child: Column(
                children: [
                  AppPageHeader(
                    isDark: isDark,
                    title: l10n.settingsTitle,
                    accentColor: accent,
                  ),
                  Expanded(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 580),
                        child: ListView(
                          padding: EdgeInsets.fromLTRB(
                            AppSpacing.xl.w,
                            AppSpacing.xl.h,
                            AppSpacing.xl.w,
                            MediaQuery.of(context).padding.bottom + 32.h,
                          ),
                          children: [buildSections(isDark, l10n)],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// _AnimatedSwitch — scale pop on toggle
// ══════════════════════════════════════════════════════════════
class _AnimatedSwitch extends StatefulWidget {
  final bool value;
  final Color activeColor;
  final ValueChanged<bool> onChanged;

  const _AnimatedSwitch({
    required this.value,
    required this.activeColor,
    required this.onChanged,
  });

  @override
  State<_AnimatedSwitch> createState() => _AnimatedSwitchState();
}

class _AnimatedSwitchState extends State<_AnimatedSwitch>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 150),
  );
  late final Animation<double> _scale = Tween<double>(
    begin: 1.0,
    end: 1.15,
  ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: Switch(
        value: widget.value,
        onChanged: (v) {
          _ctrl.forward().then((_) => _ctrl.reverse());
          widget.onChanged(v);
        },
        activeThumbColor: widget.activeColor,
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// _LangToggle — animated AR/EN pill toggle
// ══════════════════════════════════════════════════════════════
class _LangToggle extends StatefulWidget {
  final bool isAr;
  final Color accent;
  final VoidCallback onToggle;

  const _LangToggle({
    required this.isAr,
    required this.accent,
    required this.onToggle,
  });

  @override
  State<_LangToggle> createState() => _LangToggleState();
}

class _LangToggleState extends State<_LangToggle>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 120),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTapDown: (_) {
        _ctrl.forward();
        HapticFeedback.selectionClick();
      },
      onTapUp: (_) {
        _ctrl.reverse();
        widget.onToggle();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.darkSurface
                : AppColors.primary[60]!.withOpacity(0.06),
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(
              color: widget.accent.withOpacity(0.20),
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: ['AR', 'EN'].map((lang) {
              final isActive = (lang == 'AR') == widget.isAr;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutBack,
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: isActive ? widget.accent : Colors.transparent,
                  borderRadius: BorderRadius.circular(16.r),
                  boxShadow: isActive
                      ? [
                          BoxShadow(
                            color: widget.accent.withOpacity(0.30),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : [],
                ),
                child: Text(
                  lang,
                  style: GoogleFonts.cairo(
                    fontSize: 12.sp,
                    fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                    color: isActive
                        ? Colors.white
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
