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
import '../../../../core/utils/widgets/app_detail_row.dart';
import '../../../../core/utils/widgets/app_page_header.dart';
import '../../../../core/utils/widgets/cards/app_customer_contact_card.dart';
import '../../../../core/utils/widgets/cards/app_section_card.dart';

// ══════════════════════════════════════════════════════════════
// HandymanViewActiveJobView — layout router
// ══════════════════════════════════════════════════════════════
class HandymanViewActiveJobView extends StatelessWidget {
  final String requestId;

  const HandymanViewActiveJobView({super.key, this.requestId = 'REQ-00124'});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, constraints) => constraints.maxWidth >= 600
          ? _ActiveJobTabletBody(requestId: requestId)
          : _ActiveJobMobileBody(requestId: requestId),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// Shared base class
// ══════════════════════════════════════════════════════════════
abstract class _ActiveJobBase<T extends StatefulWidget> extends State<T>
    with TickerProviderStateMixin {
  String get requestId;
  Color get accent => AppColors.accent[60]!;

  late final AnimationController entryCtrl;
  late final List<Animation<double>> entryFade;
  late final List<Animation<Offset>> entrySlide;

  static const int _sectionCount = 6;

  @override
  void initState() {
    super.initState();
    entryCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 850),
    );

    entryFade = List.generate(_sectionCount, (i) {
      final start = i * 0.12;
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: entryCtrl,
          curve: Interval(
            start.clamp(0.0, 1.0),
            (start + 0.40).clamp(0.0, 1.0),
            curve: Curves.easeOut,
          ),
        ),
      );
    });

    entrySlide = List.generate(_sectionCount, (i) {
      final start = i * 0.12;
      return Tween<Offset>(
        begin: const Offset(0, 0.14),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: entryCtrl,
          curve: Interval(
            start.clamp(0.0, 1.0),
            (start + 0.45).clamp(0.0, 1.0),
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

  Widget animatedSection(int i, Widget child) {
    final idx = i.clamp(0, _sectionCount - 1);
    return FadeTransition(
      opacity: entryFade[idx],
      child: SlideTransition(position: entrySlide[idx], child: child),
    );
  }

  // ── Actions ──────────────────────────────────────────────
  void completeJob(bool isDark, AppLocalizations l10n) {
    showAnimatedConfirmDialog(
      context: context,
      isDark: isDark,
      icon: Icons.check_circle_outline_rounded,
      title: l10n.jobCompleteTitle,
      message: l10n.jobCompleteConfirm,
      cancelLabel: l10n.cancel,
      confirmLabel: l10n.jobCompleteBtn,
      isDanger: false,
      confirmColor: accent,
      onConfirm: () {
        HapticFeedback.mediumImpact();
        Navigator.pop(context);
        Navigator.of(
          context,
        ).pushNamed(AppRoutes.handymanUpdateJobStatus, arguments: requestId);
      },
    );
  }

  void reportIssue(bool isDark, AppLocalizations l10n) {
    showAnimatedConfirmDialog(
      context: context,
      isDark: isDark,
      icon: Icons.flag_outlined,
      title: l10n.trackReportTitle,
      message: l10n.trackReportMessage,
      cancelLabel: l10n.cancel,
      confirmLabel: l10n.trackReportConfirmBtn,
      isDanger: true,
      onConfirm: () => HapticFeedback.mediumImpact(),
    );
  }

  // ── Shared content builder ─────────────────────────────────
  List<Widget> buildContentSections(
    BuildContext context,
    bool isDark,
    AppLocalizations l10n,
    TextTheme textTheme,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return [
      // Customer info card
      animatedSection(
        1,
        AppCustomerContactCard(
          isDark: isDark,
          name: 'أحمد محمود',
          statusLabel: l10n.customerNew,
          rating: 5.0,
          phone: '+201234567890',
          requestId: requestId,
          accentColor: accent,
          titleLabel: l10n.jobCustomerInfo,
          callLabel: l10n.trackCallBtn,
          messageLabel: l10n.trackWhatsappBtn,
        ),
      ),
      SizedBox(height: 16.h),

      // Service details
      animatedSection(
        2,
        AppSectionCard(
          isDark: isDark,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SectionTitle(
                icon: Icons.miscellaneous_services_rounded,
                label: l10n.trackServiceDetailsTitle,
                accent: accent,
              ),
              SizedBox(height: 14.h),
              AppDetailRow(
                label: l10n.trackServiceType,
                value: 'سباكة - صيانة عامة',
              ),
              AppDetailRow(
                label: l10n.bookingDateLabel,
                value: '2026/02/12 - 10:00 ص',
              ),
              AppDetailRow(
                label: l10n.trackLocation,
                value: 'القاهرة - مدينة نصر',
              ),
              AppDetailRow(
                label: l10n.bookingAddressLabel,
                value: '23 شارع النصر، العمارة 5، الشقة 12',
              ),
              AppDetailRow(
                label: l10n.jobPrice,
                value: '150 ج/ساعة',
                valueColor: accent,
                showDivider: false,
              ),
            ],
          ),
        ),
      ),
      SizedBox(height: 16.h),

      // Description box
      animatedSection(
        3,
        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: accent.withOpacity(0.06),
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(color: accent.withOpacity(0.15)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.description_outlined, size: 18.sp, color: accent),
                  SizedBox(width: 8.w),
                  Text(
                    l10n.bookingDescLabel,
                    style: textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10.h),
              Text(
                'تسريب في حنفية المطبخ ويحتاج إلى إصلاح عاجل. الماء يتسرب بشكل مستمر ويسبب إهدار كبير. أرجو الحضور في أقرب وقت ممكن.',
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),
      ),
      SizedBox(height: 16.h),

      // Images section
      animatedSection(
        4,
        _ImagesSection(accent: accent, textTheme: textTheme, l10n: l10n),
      ),
    ];
  }

  // ── Action buttons ────────────────────────────────────────
  List<Widget> buildActionButtons(bool isDark, AppLocalizations l10n) {
    return [
      animatedSection(
        5,
        _ActionButton(
          label: l10n.jobCompleteBtn,
          gradient: LinearGradient(colors: [accent, accent.withOpacity(0.82)]),
          shadowColor: accent.withOpacity(0.30),
          textColor: Colors.white,
          onTap: () => completeJob(isDark, l10n),
        ),
      ),
      SizedBox(height: 10.h),
      animatedSection(
        5,
        _ActionButton(
          label: l10n.trackReportBtn,
          color: AppColors.danger.withOpacity(0.10),
          textColor: AppColors.danger,
          onTap: () => reportIssue(isDark, l10n),
        ),
      ),
    ];
  }
}

// ══════════════════════════════════════════════════════════════
// Mobile Body
// ══════════════════════════════════════════════════════════════
class _ActiveJobMobileBody extends StatefulWidget {
  final String requestId;
  const _ActiveJobMobileBody({required this.requestId});

  @override
  State<_ActiveJobMobileBody> createState() => _ActiveJobMobileBodyState();
}

class _ActiveJobMobileBodyState extends _ActiveJobBase<_ActiveJobMobileBody> {
  @override
  String get requestId => widget.requestId;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppMainBackground(
        child: Column(
          children: [
            // Header
            animatedSection(
              0,
              AppPageHeader(
                isDark: isDark,
                title: l10n.jobDetailsTitle,
                subtitle: '#$requestId',
                accentColor: Colors.lightGreenAccent,
              ),
            ),

            // Scrollable content
            Expanded(
              child: ListView(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.xl.w,
                  AppSpacing.lg.h,
                  AppSpacing.xl.w,
                  160.h,
                ),
                children: buildContentSections(
                  context,
                  isDark,
                  l10n,
                  textTheme,
                ),
              ),
            ),
          ],
        ),
      ),

      // Bottom action bar
      bottomSheet: _AnimatedBottomBar(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: buildActionButtons(isDark, l10n),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// Tablet Body
// ══════════════════════════════════════════════════════════════
class _ActiveJobTabletBody extends StatefulWidget {
  final String requestId;
  const _ActiveJobTabletBody({required this.requestId});

  @override
  State<_ActiveJobTabletBody> createState() => _ActiveJobTabletBodyState();
}

class _ActiveJobTabletBodyState extends _ActiveJobBase<_ActiveJobTabletBody> {
  @override
  String get requestId => widget.requestId;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppMainBackground(
        child: Column(
          children: [
            // Header
            animatedSection(
              0,
              AppPageHeader(
                isDark: isDark,
                title: l10n.jobDetailsTitle,
                subtitle: '#$requestId',
                accentColor: Colors.lightGreenAccent,
              ),
            ),

            // Two-column layout
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.xl.w,
                  vertical: AppSpacing.lg.h,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 900),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Left column - Job details
                        Expanded(
                          flex: 58,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: buildContentSections(
                              context,
                              isDark,
                              l10n,
                              textTheme,
                            ),
                          ),
                        ),
                        SizedBox(width: 24.w),

                        // Right column - Quick actions card
                        Expanded(
                          flex: 42,
                          child: animatedSection(
                            2,
                            _QuickActionsCard(
                              isDark: isDark,
                              l10n: l10n,
                              accent: accent,
                              onComplete: () => completeJob(isDark, l10n),
                              onReport: () => reportIssue(isDark, l10n),
                            ),
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
// _SectionTitle
// ══════════════════════════════════════════════════════════════
class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color accent;

  const _SectionTitle({
    required this.icon,
    required this.label,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18.sp, color: accent),
        SizedBox(width: 8.w),
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════
// _ImagesSection
// ══════════════════════════════════════════════════════════════
class _ImagesSection extends StatelessWidget {
  final Color accent;
  final TextTheme textTheme;
  final AppLocalizations l10n;

  const _ImagesSection({
    required this.accent,
    required this.textTheme,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final mockColors = [
      [accent, accent.withOpacity(0.7)],
      [const Color(0xFF3498DB), const Color(0xFF2980B9)],
      [AppColors.accent[70]!, AppColors.accent[80]!],
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.photo_library_outlined, size: 18.sp, color: accent),
            SizedBox(width: 8.w),
            Text(
              l10n.bookingImagesTitle,
              style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        Row(
          children: List.generate(
            3,
            (i) => Expanded(
              child: Padding(
                padding: EdgeInsets.only(left: i < 2 ? 8.w : 0),
                child: _ImageThumbnail(colors: mockColors[i]),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════
// _ImageThumbnail — tappable image placeholder
// ══════════════════════════════════════════════════════════════
class _ImageThumbnail extends StatefulWidget {
  final List<Color> colors;
  const _ImageThumbnail({required this.colors});

  @override
  State<_ImageThumbnail> createState() => _ImageThumbnailState();
}

class _ImageThumbnailState extends State<_ImageThumbnail>
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
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) => _ctrl.reverse(),
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: AspectRatio(
          aspectRatio: 1,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: widget.colors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              Icons.image_outlined,
              size: 28.sp,
              color: Colors.white.withOpacity(0.6),
            ),
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// _ActionButton — gradient or solid button with press animation
// ══════════════════════════════════════════════════════════════
class _ActionButton extends StatefulWidget {
  final String label;
  final Gradient? gradient;
  final Color? color;
  final Color? shadowColor;
  final Color textColor;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.textColor,
    required this.onTap,
    this.gradient,
    this.color,
    this.shadowColor,
  });

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 120),
  );
  late final Animation<double> _scale = Tween<double>(
    begin: 1.0,
    end: 0.97,
  ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));

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
          width: double.infinity,
          height: 52.h,
          decoration: BoxDecoration(
            gradient: widget.gradient,
            color: widget.color,
            borderRadius: BorderRadius.circular(14.r),
            boxShadow: widget.shadowColor != null
                ? [
                    BoxShadow(
                      color: widget.shadowColor!,
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
          ),
          child: Center(
            child: Text(
              widget.label,
              style: GoogleFonts.cairo(
                fontSize: 15.sp,
                fontWeight: FontWeight.w700,
                color: widget.textColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// _QuickActionsCard — tablet right panel card
// ══════════════════════════════════════════════════════════════
class _QuickActionsCard extends StatelessWidget {
  final bool isDark;
  final AppLocalizations l10n;
  final Color accent;
  final VoidCallback onComplete;
  final VoidCallback onReport;

  const _QuickActionsCard({
    required this.isDark,
    required this.l10n,
    required this.accent,
    required this.onComplete,
    required this.onReport,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.08)
              : Colors.grey.withOpacity(0.12),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.25 : 0.08),
            blurRadius: 24,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 44.w,
                height: 44.w,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      accent.withOpacity(0.15),
                      accent.withOpacity(0.08),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(Icons.flash_on_rounded, color: accent, size: 22.sp),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.quickActionsTitle,
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      l10n.quickActionsSubtitle,
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 24.h),

          // Complete job button
          _TabletActionBtn(
            icon: Icons.check_circle_outline_rounded,
            label: l10n.jobCompleteBtn,
            description: l10n.jobCompleteDesc,
            gradient: LinearGradient(
              colors: [accent, accent.withOpacity(0.82)],
            ),
            onTap: onComplete,
          ),
          SizedBox(height: 12.h),

          // Report issue button
          _TabletActionBtn(
            icon: Icons.flag_outlined,
            label: l10n.trackReportBtn,
            description: l10n.trackReportDesc,
            color: AppColors.danger.withOpacity(0.08),
            borderColor: AppColors.danger.withOpacity(0.2),
            iconColor: AppColors.danger,
            onTap: onReport,
          ),
          SizedBox(height: 20.h),

          // Tips card
          Container(
            padding: EdgeInsets.all(14.w),
            decoration: BoxDecoration(
              color: accent.withOpacity(0.05),
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(color: accent.withOpacity(0.12)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.lightbulb_outline_rounded,
                  size: 20.sp,
                  color: accent,
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Text(
                    l10n.jobCompleteTip,
                    style: GoogleFonts.cairo(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                      color: colorScheme.onSurfaceVariant,
                      height: 1.5,
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
}

// ══════════════════════════════════════════════════════════════
// _TabletActionBtn
// ══════════════════════════════════════════════════════════════
class _TabletActionBtn extends StatefulWidget {
  final IconData icon;
  final String label;
  final String description;
  final Gradient? gradient;
  final Color? color;
  final Color? borderColor;
  final Color? iconColor;
  final VoidCallback onTap;

  const _TabletActionBtn({
    required this.icon,
    required this.label,
    required this.description,
    required this.onTap,
    this.gradient,
    this.color,
    this.borderColor,
    this.iconColor,
  });

  @override
  State<_TabletActionBtn> createState() => _TabletActionBtnState();
}

class _TabletActionBtnState extends State<_TabletActionBtn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 120),
  );
  late final Animation<double> _scale = Tween<double>(
    begin: 1.0,
    end: 0.97,
  ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final hasGradient = widget.gradient != null;

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
          padding: EdgeInsets.all(14.w),
          decoration: BoxDecoration(
            gradient: widget.gradient,
            color: widget.color,
            borderRadius: BorderRadius.circular(16.r),
            border: widget.borderColor != null
                ? Border.all(color: widget.borderColor!, width: 1.5)
                : null,
            boxShadow: hasGradient
                ? [
                    BoxShadow(
                      color: (widget.gradient?.colors.first ?? Colors.teal)
                          .withOpacity(0.25),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
          ),
          child: Row(
            children: [
              Container(
                width: 40.w,
                height: 40.w,
                decoration: BoxDecoration(
                  color: hasGradient
                      ? Colors.white.withOpacity(0.15)
                      : (widget.iconColor ?? Colors.teal).withOpacity(0.10),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  widget.icon,
                  size: 20.sp,
                  color: hasGradient
                      ? Colors.white
                      : (widget.iconColor ?? Colors.teal),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.label,
                      style: textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: hasGradient
                            ? Colors.white
                            : (widget.iconColor ?? Colors.teal),
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      widget.description,
                      style: GoogleFonts.cairo(
                        fontSize: 11.sp,
                        color: hasGradient
                            ? Colors.white.withOpacity(0.8)
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14.sp,
                color: hasGradient
                    ? Colors.white.withOpacity(0.7)
                    : (widget.iconColor ?? Colors.teal).withOpacity(0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// _AnimatedBottomBar — animated bottom sheet container
// ══════════════════════════════════════════════════════════════
class _AnimatedBottomBar extends StatefulWidget {
  final Widget child;
  const _AnimatedBottomBar({required this.child});

  @override
  State<_AnimatedBottomBar> createState() => _AnimatedBottomBarState();
}

class _AnimatedBottomBarState extends State<_AnimatedBottomBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 350),
  );
  late final Animation<double> _fade = CurvedAnimation(
    parent: _ctrl,
    curve: Curves.easeOut,
  );
  late final Animation<Offset> _slide = Tween<Offset>(
    begin: const Offset(0, 0.3),
    end: Offset.zero,
  ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));

  @override
  void initState() {
    super.initState();
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottom = MediaQuery.of(context).padding.bottom;

    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: Container(
          padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, bottom + 16.h),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 20,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: widget.child,
        ),
      ),
    );
  }
}
