import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../../core/l10n/translation/app_localizations.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_sizes.dart';
import '../../../../../core/utils/widgets/app_main_background.dart';
import '../../../../../core/utils/widgets/app_page_header.dart';

// ══════════════════════════════════════════════════════════════
// SharedContactUsView — layout router
// Shared between customer and handyman.
//
// Customer:  accentColor: AppColors.primary[60]
// Handyman:  accentColor: AppColors.accent[60]
// ══════════════════════════════════════════════════════════════
class SharedContactUsView extends StatelessWidget {
  final Color accentColor;

  const SharedContactUsView({
    super.key,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, constraints) => constraints.maxWidth >= 600
          ? _ContactTabletBody(accentColor: accentColor)
          : _ContactMobileBody(accentColor: accentColor),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// Shared base class
// ══════════════════════════════════════════════════════════════
abstract class _ContactBase<T extends StatefulWidget> extends State<T>
    with TickerProviderStateMixin {

  Color get accentColor;

  late final AnimationController entryCtrl;
  late final List<Animation<double>> entryFade;
  late final List<Animation<Offset>> entrySlide;

  static const int _sectionCount = 5;

  @override
  void initState() {
    super.initState();

    entryCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    entryFade = List.generate(_sectionCount, (i) {
      final start = i * 0.13;
      return Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
        parent: entryCtrl,
        curve: Interval(
          start.clamp(0.0, 1.0),
          (start + 0.40).clamp(0.0, 1.0),
          curve: Curves.easeOut,
        ),
      ));
    });

    entrySlide = List.generate(_sectionCount, (i) {
      final start = i * 0.13;
      return Tween<Offset>(begin: const Offset(0, 0.14), end: Offset.zero)
          .animate(CurvedAnimation(
        parent: entryCtrl,
        curve: Interval(
          start.clamp(0.0, 1.0),
          (start + 0.50).clamp(0.0, 1.0),
          curve: Curves.easeOutCubic,
        ),
      ));
    });

    entryCtrl.forward();
  }

  @override
  void dispose() {
    entryCtrl.dispose();
    super.dispose();
  }

  Widget animatedSection(int i, Widget child) {
    final idx = i.clamp(0, _sectionCount - 1);
    return FadeTransition(
      opacity: entryFade[idx],
      child: SlideTransition(position: entrySlide[idx], child: child),
    );
  }

  // ── Launch actions (renamed to avoid conflict with url_launcher) ───────────
  Future<void> openUrl(String url) async {
    HapticFeedback.selectionClick();
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  // ── Build header ──────────────────────────────────────────
  Widget buildHeader(bool isDark, AppLocalizations l10n) {
    return AppPageHeader(
      isDark: isDark,
      title: l10n.contactTitle,
      accentColor: accentColor,
    );
  }

  // ── Build contact items ───────────────────────────────────
  List<Widget> buildContactItems(bool isDark, AppLocalizations l10n) {
    return [
      _ContactItem(
        icon: Icons.phone_rounded,
        label: l10n.contactPhone,
        value: '+20 123 456 7890',
        accent: accentColor,
        isDark: isDark,
        onTap: () => openUrl('tel:+201234567890'),
      ),
      _ContactItem(
        icon: Icons.email_outlined,
        label: l10n.contactEmail,
        value: 'support@fixit.com',
        accent: accentColor,
        isDark: isDark,
        onTap: () => openUrl('mailto:support@fixit.com'),
      ),
      _ContactItem(
        icon: Icons.chat_rounded,
        label: l10n.trackWhatsappBtn,
        value: '+20 100 000 0000',
        accent: accentColor,
        isDark: isDark,
        onTap: () => openUrl('https://wa.me/201000000000'),
      ),
    ];
  }
}

// ══════════════════════════════════════════════════════════════
// Mobile Body
// ══════════════════════════════════════════════════════════════
class _ContactMobileBody extends StatefulWidget {
  final Color accentColor;
  const _ContactMobileBody({required this.accentColor});

  @override
  State<_ContactMobileBody> createState() => _ContactMobileBodyState();
}

class _ContactMobileBodyState extends _ContactBase<_ContactMobileBody> {
  @override
  Color get accentColor => widget.accentColor;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    final contactItems = buildContactItems(isDark, l10n);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppMainBackground(
        child: Column(
          children: [
            animatedSection(0, buildHeader(isDark, l10n)),
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.all(AppSpacing.xl.w),
                itemCount: contactItems.length,
                itemBuilder: (ctx, i) => animatedSection(
                  i + 1,
                  Padding(
                    padding: EdgeInsets.only(bottom: 12.h),
                    child: contactItems[i],
                  ),
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
// Tablet Body
// ══════════════════════════════════════════════════════════════
class _ContactTabletBody extends StatefulWidget {
  final Color accentColor;
  const _ContactTabletBody({required this.accentColor});

  @override
  State<_ContactTabletBody> createState() => _ContactTabletBodyState();
}

class _ContactTabletBodyState extends _ContactBase<_ContactTabletBody> {
  @override
  Color get accentColor => widget.accentColor;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;
    final contactItems = buildContactItems(isDark, l10n);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppMainBackground(
        child: Column(
          children: [
            animatedSection(0, buildHeader(isDark, l10n)),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(AppSpacing.xl.w),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 900),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Left column - Contact items
                        Expanded(
                          flex: 55,
                          child: Column(
                            children: [
                              // Info header card
                              animatedSection(
                                1,
                                _ContactHeaderCard(
                                  accent: accentColor,
                                  isDark: isDark,
                                  textTheme: textTheme,
                                  l10n: l10n,
                                ),
                              ),
                              SizedBox(height: 20.h),

                              // Contact items
                              ...contactItems.asMap().entries.map((entry) {
                                return animatedSection(
                                  entry.key + 2,
                                  Padding(
                                    padding: EdgeInsets.only(bottom: 12.h),
                                    child: entry.value,
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                        SizedBox(width: 24.w),

                        // Right column - Working hours + social
                        Expanded(
                          flex: 45,
                          child: Column(
                            children: [
                              SizedBox(height: 80.h), // Offset for header card

                              // Working hours card
                              animatedSection(
                                2,
                                _WorkingHoursCard(
                                  accent: accentColor,
                                  isDark: isDark,
                                  textTheme: textTheme,
                                  l10n: l10n,
                                ),
                              ),
                              SizedBox(height: 16.h),

                              // Social media card
                              animatedSection(
                                3,
                                _SocialCard(
                                  accent: accentColor,
                                  isDark: isDark,
                                  textTheme: textTheme,
                                  l10n: l10n,
                                  onLaunch: openUrl,
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
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// _ContactItem
// ══════════════════════════════════════════════════════════════
class _ContactItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color accent;
  final bool isDark;
  final VoidCallback onTap;

  const _ContactItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.accent,
    required this.isDark,
    required this.onTap,
  });

  @override
  State<_ContactItem> createState() => _ContactItemState();
}

class _ContactItemState extends State<_ContactItem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 100),
  );
  late final Animation<double> _scale = Tween<double>(begin: 1.0, end: 0.97)
      .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        widget.onTap();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          padding: EdgeInsets.all(18.w),
          decoration: BoxDecoration(
            color: widget.isDark ? AppColors.darkSurface : Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: widget.accent.withOpacity(0.10)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(widget.isDark ? 0.15 : 0.05),
                blurRadius: 12,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Icon bubble
              Container(
                width: 48.w,
                height: 48.w,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [widget.accent.withOpacity(0.15), widget.accent.withOpacity(0.08)],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(widget.icon, size: 22.sp, color: widget.accent),
              ),
              SizedBox(width: 16.w),

              // Text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.label,
                      style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      widget.value,
                      style: GoogleFonts.cairo(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),

              // Arrow
              Container(
                width: 32.w,
                height: 32.w,
                decoration: BoxDecoration(
                  color: widget.accent.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 12.sp,
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
// _ContactHeaderCard — tablet header card
// ══════════════════════════════════════════════════════════════
class _ContactHeaderCard extends StatelessWidget {
  final Color accent;
  final bool isDark;
  final TextTheme textTheme;
  final AppLocalizations l10n;

  const _ContactHeaderCard({
    required this.accent,
    required this.isDark,
    required this.textTheme,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: Row(
        children: [
          Container(
            width: 56.w,
            height: 56.w,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.20),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.headset_mic_rounded, size: 28.sp, color: Colors.white),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.contactHeaderTitle,
                  style: GoogleFonts.cairo(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  l10n.contactHeaderSubtitle,
                  style: GoogleFonts.cairo(
                    fontSize: 13.sp,
                    color: Colors.white.withOpacity(0.85),
                    fontWeight: FontWeight.w500,
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

// ══════════════════════════════════════════════════════════════
// _WorkingHoursCard — tablet right panel
// ══════════════════════════════════════════════════════════════
class _WorkingHoursCard extends StatelessWidget {
  final Color accent;
  final bool isDark;
  final TextTheme textTheme;
  final AppLocalizations l10n;

  const _WorkingHoursCard({
    required this.accent,
    required this.isDark,
    required this.textTheme,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: accent.withOpacity(0.10)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.15 : 0.05),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40.w,
                height: 40.w,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [accent.withOpacity(0.15), accent.withOpacity(0.08)],
                  ),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(Icons.schedule_rounded, color: accent, size: 20.sp),
              ),
              SizedBox(width: 12.w),
              Text(
                l10n.contactWorkingHours,
                style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
              ),
            ],
          ),
          SizedBox(height: 16.h),

          _HoursRow(
            day: l10n.contactSaturdayThursday,
            hours: '8:00 AM - 8:00 PM',
            colorScheme: colorScheme,
          ),
          SizedBox(height: 10.h),
          _HoursRow(
            day: l10n.contactFriday,
            hours: l10n.contactClosed,
            colorScheme: colorScheme,
            isClosed: true,
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// _HoursRow
// ══════════════════════════════════════════════════════════════
class _HoursRow extends StatelessWidget {
  final String day;
  final String hours;
  final ColorScheme colorScheme;
  final bool isClosed;

  const _HoursRow({
    required this.day,
    required this.hours,
    required this.colorScheme,
    this.isClosed = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          day,
          style: GoogleFonts.cairo(
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: isClosed
                ? AppColors.danger.withOpacity(0.08)
                : AppColors.success.withOpacity(0.08),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Text(
            hours,
            style: GoogleFonts.cairo(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: isClosed ? AppColors.danger : AppColors.success,
            ),
          ),
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════
// _SocialCard — tablet right panel
// ══════════════════════════════════════════════════════════════
class _SocialCard extends StatelessWidget {
  final Color accent;
  final bool isDark;
  final TextTheme textTheme;
  final AppLocalizations l10n;
  final Future<void> Function(String) onLaunch;

  const _SocialCard({
    required this.accent,
    required this.isDark,
    required this.textTheme,
    required this.l10n,
    required this.onLaunch,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: accent.withOpacity(0.10)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.15 : 0.05),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40.w,
                height: 40.w,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [accent.withOpacity(0.15), accent.withOpacity(0.08)],
                  ),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(Icons.share_rounded, color: accent, size: 20.sp),
              ),
              SizedBox(width: 12.w),
              Text(
                l10n.contactFollowUs,
                style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
              ),
            ],
          ),
          SizedBox(height: 16.h),

          Row(
            children: [
              _SocialBtn(
                icon: Icons.facebook_rounded,
                color: const Color(0xFF1877F2),
                onTap: () => onLaunch('https://facebook.com/fixit'),
              ),
              SizedBox(width: 12.w),
              _SocialBtn(
                icon: Icons.camera_alt_rounded,
                color: const Color(0xFFE4405F),
                onTap: () => onLaunch('https://instagram.com/fixit'),
              ),
              SizedBox(width: 12.w),
              _SocialBtn(
                icon: Icons.alternate_email_rounded,
                color: const Color(0xFF1DA1F2),
                onTap: () => onLaunch('https://twitter.com/fixit'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// _SocialBtn
// ══════════════════════════════════════════════════════════════
class _SocialBtn extends StatefulWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _SocialBtn({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  State<_SocialBtn> createState() => _SocialBtnState();
}

class _SocialBtnState extends State<_SocialBtn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 100),
  );
  late final Animation<double> _scale = Tween<double>(begin: 1.0, end: 0.92)
      .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        widget.onTap();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          width: 48.w,
          height: 48.w,
          decoration: BoxDecoration(
            color: widget.color.withOpacity(0.10),
            shape: BoxShape.circle,
          ),
          child: Icon(widget.icon, size: 22.sp, color: widget.color),
        ),
      ),
    );
  }
}
