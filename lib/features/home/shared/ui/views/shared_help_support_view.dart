import 'package:fix_it/core/utils/widgets/app_main_background.dart';
import 'package:fix_it/core/utils/widgets/buttons/app_settings_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../../core/l10n/translation/app_localizations.dart';
import '../../../../../core/router/app_routes.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_sizes.dart';
import '../../../../../core/utils/widgets/app_page_header.dart';

// ══════════════════════════════════════════════════════════════
// SharedHelpSupportView
// Shared between customer and handyman.
// Pass accentColor to tint the page accordingly.
//
// Customer:  accentColor: AppColors.primary[60]
// Handyman:  accentColor: AppColors.accent[60]
// ══════════════════════════════════════════════════════════════
class SharedHelpSupportView extends StatefulWidget {
  final Color accentColor;

  const SharedHelpSupportView({
    super.key,
    required this.accentColor,
  });

  @override
  State<SharedHelpSupportView> createState() =>
      _SharedHelpSupportViewState();
}

class _SharedHelpSupportViewState extends State<SharedHelpSupportView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _master;
  late final List<Animation<double>> _fadeAnims;
  late final List<Animation<Offset>>  _slideAnims;

  static const int _sectionCount = 7;

  bool get _isHandyman => widget.accentColor == AppColors.accent[60];

  @override
  void initState() {
    super.initState();
    _master = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();

    _fadeAnims = List.generate(_sectionCount, (i) {
      final start = i * 0.11;
      return Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
        parent: _master,
        curve: Interval(start.clamp(0.0, 1.0),
            (start + 0.40).clamp(0.0, 1.0), curve: Curves.easeOut),
      ));
    });

    _slideAnims = List.generate(_sectionCount, (i) {
      final start = i * 0.11;
      return Tween<Offset>(begin: const Offset(0, 0.14), end: Offset.zero)
          .animate(CurvedAnimation(
        parent: _master,
        curve: Interval(start.clamp(0.0, 1.0),
            (start + 0.45).clamp(0.0, 1.0), curve: Curves.easeOutCubic),
      ));
    });
  }

  @override
  void dispose() {
    _master.dispose();
    super.dispose();
  }

  Widget _animated(int i, Widget child) => FadeTransition(
    opacity: _fadeAnims[i.clamp(0, _sectionCount - 1)],
    child: SlideTransition(
        position: _slideAnims[i.clamp(0, _sectionCount - 1)],
        child: child),
  );

  // ── Contact actions ───────────────────────────────────────
  Future<void> _call() async {
    HapticFeedback.mediumImpact();
    final uri = Uri(scheme: 'tel', path: '+201234567890');
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  Future<void> _whatsapp() async {
    HapticFeedback.mediumImpact();
    final uri = Uri.parse('https://wa.me/201234567890');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark    = Theme.of(context).brightness == Brightness.dark;
    final l10n      = AppLocalizations.of(context)!;
    final accent    = widget.accentColor;

    return Scaffold(
      body: AppMainBackground(
        child: CustomScrollView(
          slivers: [
            // ── Header ──────────────────────────────────────
            SliverToBoxAdapter(
              child: _animated(0,
                AppPageHeader(
                  isDark: isDark,
                  title: l10n.helpTitle,
                  accentColor: accent,
                ),
              ),
            ),

            // ── Contact card ─────────────────────────────────
            SliverToBoxAdapter(
              child: _animated(1,
                Padding(
                  padding: EdgeInsets.fromLTRB(
                      AppSpacing.xl.w, AppSpacing.lg.h,
                      AppSpacing.xl.w, 0),
                  child: _ContactCard(
                    isDark: isDark,
                    accent: accent,
                    title: l10n.helpContactTitle,
                    subtitle: l10n.helpContactSubtitle,
                    callLabel: l10n.trackCallBtn,
                    whatsappLabel: l10n.trackWhatsappBtn,
                    onCall: _call,
                    onWhatsapp: _whatsapp,
                  ),
                ),
              ),
            ),

            // ── FAQ section ───────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                    AppSpacing.xl.w, AppSpacing.xl.h,
                    AppSpacing.xl.w, 0),
                child: _animated(2,
                  AppSettingsSection(
                    title: l10n.helpFaqTitle,
                    isDark: isDark,
                    children: [
                      _animated(3,
                        AppSettingsItem(
                          icon: Icons.help_outline_rounded,
                          iconBgColor: accent.withOpacity(0.12),
                          iconColor: accent,
                          label: l10n.helpFaqBookingTitle,
                          subtitle: l10n.helpFaqBookingDesc,
                          isDark: isDark,
                          onTap: () => Navigator.of(context).pushNamed(
                              AppRoutes.sharedFaqBooking, arguments: _isHandyman),
                        ),
                      ),
                      _animated(4,
                        AppSettingsItem(
                          icon: Icons.payments_outlined,
                          iconBgColor: AppColors.accent[60]!.withOpacity(0.12),
                          iconColor: AppColors.accent[60]!,
                          label: l10n.helpFaqPaymentTitle,
                          subtitle: l10n.helpFaqPaymentDesc,
                          isDark: isDark,
                          onTap: () => Navigator.of(context).pushNamed(
                              AppRoutes.sharedFaqPayment, arguments: _isHandyman),
                        ),
                      ),
                      _animated(5,
                        AppSettingsItem(
                          icon: Icons.cancel_outlined,
                          iconBgColor: AppColors.warning.withOpacity(0.12),
                          iconColor: AppColors.warning,
                          label: l10n.helpFaqCancelTitle,
                          subtitle: l10n.helpFaqCancelDesc,
                          isDark: isDark,
                          onTap: () => Navigator.of(context).pushNamed(
                              AppRoutes.sharedFaqCancellation, arguments: _isHandyman),
                        ),
                      ),
                      _animated(6,
                        AppSettingsItem(
                          icon: Icons.verified_outlined,
                          iconBgColor: const Color(0xFF9B59B6).withOpacity(0.12),
                          iconColor: const Color(0xFF9B59B6),
                          label: l10n.helpFaqQualityTitle,
                          subtitle: l10n.helpFaqQualityDesc,
                          isDark: isDark,
                          onTap: () => Navigator.of(context).pushNamed(
                              AppRoutes.sharedFaqQuality, arguments: _isHandyman),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            SliverToBoxAdapter(child: SizedBox(height: 40.h)),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// _ContactCard — gradient hero card with call + whatsapp
// ══════════════════════════════════════════════════════════════
class _ContactCard extends StatefulWidget {
  final bool         isDark;
  final Color        accent;
  final String       title;
  final String       subtitle;
  final String       callLabel;
  final String       whatsappLabel;
  final VoidCallback onCall;
  final VoidCallback onWhatsapp;

  const _ContactCard({
    required this.isDark,
    required this.accent,
    required this.title,
    required this.subtitle,
    required this.callLabel,
    required this.whatsappLabel,
    required this.onCall,
    required this.onWhatsapp,
  });

  @override
  State<_ContactCard> createState() => _ContactCardState();
}

class _ContactCardState extends State<_ContactCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 600))
    ..forward();
  late final Animation<double> _scale = Tween<double>(begin: 0.92, end: 1.0)
      .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack));
  late final Animation<double> _fade = CurvedAnimation(
      parent: _ctrl, curve: Curves.easeOut);

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final accent = widget.accent;

    return FadeTransition(
      opacity: _fade,
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [accent, accent.withOpacity(0.78)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20.r),
            boxShadow: [
              BoxShadow(
                color: accent.withOpacity(0.35),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 48.w, height: 48.w,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.20),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.support_agent_rounded,
                        size: 26.sp, color: Colors.white),
                  ),
                  SizedBox(width: 14.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.title,
                            style: GoogleFonts.cairo(
                              fontSize: 17.sp,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            )),
                        Text(widget.subtitle,
                            style: GoogleFonts.cairo(
                              fontSize: 13.sp,
                              color: Colors.white.withOpacity(0.85),
                              fontWeight: FontWeight.w500,
                            )),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 18.h),
              Row(
                children: [
                  Expanded(
                    child: _ContactBtn(
                      icon: Icons.phone_rounded,
                      label: widget.callLabel,
                      onTap: widget.onCall,
                      accent: accent,
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: _ContactBtn(
                      icon: Icons.chat_rounded,
                      label: widget.whatsappLabel,
                      onTap: widget.onWhatsapp,
                      accent: accent,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// _ContactBtn
// ══════════════════════════════════════════════════════════════
class _ContactBtn extends StatefulWidget {
  final IconData     icon;
  final String       label;
  final Color        accent;
  final VoidCallback onTap;

  const _ContactBtn({
    required this.icon, required this.label,
    required this.accent, required this.onTap,
  });

  @override
  State<_ContactBtn> createState() => _ContactBtnState();
}

class _ContactBtnState extends State<_ContactBtn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 100));
  late final Animation<double> _scale = Tween<double>(begin: 1.0, end: 0.95)
      .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown:   (_) { _ctrl.forward(); HapticFeedback.selectionClick(); },
      onTapUp:     (_) { _ctrl.reverse(); widget.onTap(); },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: [BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 8, offset: const Offset(0, 2))],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(widget.icon, size: 18.sp, color: widget.accent),
              SizedBox(width: 6.w),
              Text(widget.label,
                  style: GoogleFonts.cairo(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: widget.accent,
                  )),
            ],
          ),
        ),
      ),
    );
  }
}