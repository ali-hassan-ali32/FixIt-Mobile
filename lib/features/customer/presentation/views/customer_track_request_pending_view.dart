import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/l10n/translation/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/utils/widgets/app_main_background.dart';
import '../../../../core/utils/widgets/animations/animated_confirm_dialog.dart';
import '../../../../core/utils/widgets/app_detail_row.dart';
import '../../../../core/utils/widgets/app_page_header.dart';
import '../../../../core/utils/widgets/app_request_timeline.dart';

// ══════════════════════════════════════════════════════════════
// CustomerTrackRequestPendingView — layout router
// ══════════════════════════════════════════════════════════════
class CustomerTrackRequestPendingView extends StatelessWidget {
  final String requestId;
  const CustomerTrackRequestPendingView({super.key, required this.requestId});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, c) => c.maxWidth >= 600
          ? _PendingTabletBody(requestId: requestId)
          : _PendingMobileBody(requestId: requestId),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// Shared base
// ══════════════════════════════════════════════════════════════
abstract class _PendingBase<T extends StatefulWidget> extends State<T>
    with TickerProviderStateMixin {
  String get requestId;
  Color get accent => AppColors.primary[60]!;

  late final AnimationController entryCtrl;
  late final List<Animation<double>> entryFade;
  late final List<Animation<Offset>> entrySlide;
  static const _n = 4;

  @override
  void initState() {
    super.initState();
    entryCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    entryFade = List.generate(_n, (i) {
      final s = (i * 0.18).clamp(0.0, 1.0);
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: entryCtrl,
          curve: Interval(s, (s + 0.45).clamp(0.0, 1.0), curve: Curves.easeOut),
        ),
      );
    });
    entrySlide = List.generate(_n, (i) {
      final s = (i * 0.18).clamp(0.0, 1.0);
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

  void onCancel(AppLocalizations l10n) {
    showAnimatedConfirmDialog(
      context: context,
      isDark: Theme.of(context).brightness == Brightness.dark,
      icon: Icons.cancel_outlined,
      title: l10n.trackCancelTitle,
      message: l10n.trackCancelConfirm,
      cancelLabel: l10n.trackCancelKeep,
      confirmLabel: l10n.trackCancelConfirmBtn,
      isDanger: true,
      onConfirm: () {
        Navigator.of(context).pop();
        Navigator.of(context).pop();
      },
    );
  }

  List<Widget> buildContent(
    BuildContext context,
    bool isDark,
    AppLocalizations l10n,
  ) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    final steps = [
      AppTimelineStep(
        title: l10n.trackStepCreated,
        time: '٢٠٢٦/٠٢/١٣ - ٨:٣٠ ص',
        description: l10n.trackStepCreatedDesc,
        status: TimelineStepStatus.completed,
      ),
      AppTimelineStep(
        title: l10n.trackStepPending,
        time: l10n.trackStepPendingTime,
        description: l10n.trackStepPendingDesc,
        status: TimelineStepStatus.active,
      ),
      AppTimelineStep(
        title: l10n.trackStepAssigned,
        time: l10n.trackStepWaiting,
        status: TimelineStepStatus.pending,
      ),
      AppTimelineStep(
        title: l10n.trackStepCompleted,
        time: l10n.trackStepWaiting,
        status: TimelineStepStatus.pending,
      ),
    ];

    return [
      ea(
        0,
        Text(
          l10n.trackStatusTitle,
          style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
        ),
      ),
      SizedBox(height: 16.h),
      ea(0, AppRequestTimeline(steps: steps, isDark: isDark)),
      SizedBox(height: 24.h),

      ea(
        1,
        AppDetailCard(
          isDark: isDark,
          title: l10n.trackServiceDetailsTitle,
          rows: [
            AppDetailRow(label: l10n.trackServiceType, value: 'دهانات'),
            AppDetailRow(label: l10n.trackLocation, value: 'القاهرة - الزمالك'),
            AppDetailRow(
              label: l10n.trackPreferredTime,
              value: '٢٠٢٦/٠٢/١٣ - ٩:٠٠ ص',
            ),
            AppDetailRow(
              label: l10n.trackExpectedPrice,
              value: '200 ${l10n.searchCurrency}',
              valueColor: AppColors.secondary[60],
              showDivider: false,
            ),
          ],
        ),
      ),
      SizedBox(height: 16.h),

      ea(
        2,
        _PendingStatusCard(
          isDark: isDark,
          textTheme: textTheme,
          colorScheme: colorScheme,
          l10n: l10n,
        ),
      ),
      SizedBox(height: 24.h),

      ea(
        3,
        _OutlineBtn(
          label: l10n.trackCancelBtn,
          color: AppColors.danger,
          onTap: () => onCancel(l10n),
        ),
      ),
    ];
  }
}

// ══════════════════════════════════════════════════════════════
// Mobile
// ══════════════════════════════════════════════════════════════
class _PendingMobileBody extends StatefulWidget {
  final String requestId;
  const _PendingMobileBody({required this.requestId});

  @override
  State<_PendingMobileBody> createState() => _PendingMobileBodyState();
}

class _PendingMobileBodyState extends _PendingBase<_PendingMobileBody> {
  @override
  String get requestId => widget.requestId;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppMainBackground(
        child: Column(
          children: [
            AppPageHeader(
              isDark: isDark,
              accentColor: accent,
              title: l10n.trackTitle,
              subtitle: '#$requestId',
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.xl.w,
                  AppSpacing.xl.h,
                  AppSpacing.xl.w,
                  MediaQuery.of(context).padding.bottom + 32.h,
                ),
                children: buildContent(context, isDark, l10n),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// Tablet — centered constrained
// ══════════════════════════════════════════════════════════════
class _PendingTabletBody extends StatefulWidget {
  final String requestId;
  const _PendingTabletBody({required this.requestId});

  @override
  State<_PendingTabletBody> createState() => _PendingTabletBodyState();
}

class _PendingTabletBodyState extends _PendingBase<_PendingTabletBody> {
  @override
  String get requestId => widget.requestId;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppMainBackground(
        child: Column(
          children: [
            AppPageHeader(
              isDark: isDark,
              accentColor: accent,
              title: l10n.trackTitle,
              subtitle: '#$requestId',
            ),
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: ListView(
                    padding: EdgeInsets.fromLTRB(
                      AppSpacing.xl.w,
                      AppSpacing.xl.h,
                      AppSpacing.xl.w,
                      32.h,
                    ),
                    children: buildContent(context, isDark, l10n),
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
// _PendingStatusCard — spinning clock + pulse glow
// ══════════════════════════════════════════════════════════════
class _PendingStatusCard extends StatefulWidget {
  final bool isDark;
  final TextTheme textTheme;
  final ColorScheme colorScheme;
  final AppLocalizations l10n;

  const _PendingStatusCard({
    required this.isDark,
    required this.textTheme,
    required this.colorScheme,
    required this.l10n,
  });

  @override
  State<_PendingStatusCard> createState() => _PendingStatusCardState();
}

class _PendingStatusCardState extends State<_PendingStatusCard>
    with TickerProviderStateMixin {
  late final AnimationController _spinCtrl;
  late final AnimationController _glowCtrl;
  late final Animation<double> _glow;

  @override
  void initState() {
    super.initState();
    _spinCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _glow = Tween<double>(
      begin: 0.15,
      end: 0.40,
    ).animate(CurvedAnimation(parent: _glowCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _spinCtrl.dispose();
    _glowCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: widget.isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.secondary[60]!.withOpacity(0.20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(widget.isDark ? 0.15 : 0.05),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Spinning icon + glow
          AnimatedBuilder(
            animation: Listenable.merge([_spinCtrl, _glowCtrl]),
            builder: (_, __) => Stack(
              alignment: Alignment.center,
              children: [
                // Pulsing glow ring
                Container(
                  width: 100.w,
                  height: 100.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.secondary[60]!.withOpacity(
                          _glow.value,
                        ),
                        blurRadius: 24,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                ),
                // Soft background circle
                Container(
                  width: 90.w,
                  height: 90.w,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.secondary[60]!.withOpacity(0.15),
                        AppColors.secondary[60]!.withOpacity(0.05),
                      ],
                    ),
                    shape: BoxShape.circle,
                  ),
                ),
                // Spinning icon
                RotationTransition(
                  turns: _spinCtrl,
                  child: Icon(
                    Icons.sync_rounded,
                    size: 42.sp,
                    color: AppColors.secondary[60],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 18.h),

          Text(
            widget.l10n.trackPendingTitle,
            style: widget.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8.h),
          Text(
            widget.l10n.trackPendingDesc,
            style: widget.textTheme.bodyMedium?.copyWith(
              color: widget.colorScheme.onSurfaceVariant,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// _OutlineBtn — shared bordered action button (used in all 3 views)
// ══════════════════════════════════════════════════════════════
class _OutlineBtn extends StatefulWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _OutlineBtn({
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  State<_OutlineBtn> createState() => _OutlineBtnState();
}

class _OutlineBtnState extends State<_OutlineBtn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 110),
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
          height: 52.h,
          decoration: BoxDecoration(
            color: widget.color.withOpacity(0.06),
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(color: widget.color.withOpacity(0.35), width: 2),
          ),
          child: Center(
            child: Text(
              widget.label,
              style: GoogleFonts.cairo(
                fontSize: 15.sp,
                fontWeight: FontWeight.w700,
                color: widget.color,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
