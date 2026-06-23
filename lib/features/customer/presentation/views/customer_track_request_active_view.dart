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
import '../../../../core/utils/widgets/cards/app_handyman_contact_card.dart';

// ══════════════════════════════════════════════════════════════
// CustomerTrackRequestActiveView — layout router
// ══════════════════════════════════════════════════════════════
class CustomerTrackRequestActiveView extends StatelessWidget {
  final String requestId;
  const CustomerTrackRequestActiveView({super.key, required this.requestId});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, c) => c.maxWidth >= 600
          ? _ActiveTabletBody(requestId: requestId)
          : _ActiveMobileBody(requestId: requestId),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// Shared base
// ══════════════════════════════════════════════════════════════
abstract class _ActiveBase<T extends StatefulWidget> extends State<T>
    with TickerProviderStateMixin {
  String get requestId;
  Color get accent => AppColors.primary[60]!;

  late final AnimationController entryCtrl;
  late final List<Animation<double>> entryFade;
  late final List<Animation<Offset>> entrySlide;
  static const _n = 5;

  @override
  void initState() {
    super.initState();
    entryCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 750),
    );
    entryFade = List.generate(_n, (i) {
      final s = (i * 0.15).clamp(0.0, 1.0);
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: entryCtrl,
          curve: Interval(s, (s + 0.45).clamp(0.0, 1.0), curve: Curves.easeOut),
        ),
      );
    });
    entrySlide = List.generate(_n, (i) {
      final s = (i * 0.15).clamp(0.0, 1.0);
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

  void onReport(AppLocalizations l10n) {
    showAnimatedConfirmDialog(
      context: context,
      isDark: Theme.of(context).brightness == Brightness.dark,
      icon: Icons.flag_outlined,
      title: l10n.trackReportTitle,
      message: l10n.trackReportMessage,
      cancelLabel: l10n.trackCancelKeep,
      confirmLabel: l10n.trackReportConfirmBtn,
      isDanger: false,
      confirmColor: AppColors.info,
      onConfirm: () => Navigator.of(context).pop(),
    );
  }

  List<Widget> buildContent(
    BuildContext context,
    bool isDark,
    AppLocalizations l10n,
  ) {
    final textTheme = Theme.of(context).textTheme;

    final steps = [
      AppTimelineStep(
        title: l10n.trackStepCreated,
        time: '٢٠٢٦/٠٢/١٠ - ٣:٣٠ م',
        description: l10n.trackStepCreatedDesc,
        status: TimelineStepStatus.completed,
      ),
      AppTimelineStep(
        title: l10n.trackStepAccepted,
        time: '٢٠٢٦/٠٢/١٠ - ٤:١٥ م',
        description: l10n.trackStepAcceptedDesc,
        status: TimelineStepStatus.completed,
      ),
      AppTimelineStep(
        title: l10n.trackStepInProgress,
        time: '٢٠٢٦/٠٢/١١ - ٢:٠٠ م',
        description: l10n.trackStepInProgressDesc,
        status: TimelineStepStatus.active,
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
            AppDetailRow(label: l10n.trackServiceType, value: 'سباكة'),
            AppDetailRow(
              label: l10n.trackLocation,
              value: 'القاهرة - مدينة نصر',
            ),
            AppDetailRow(
              label: l10n.trackPreferredTime,
              value: '٢٠٢٦/٠٢/١١ - ٢:٠٠ م',
            ),
            AppDetailRow(
              label: l10n.trackExpectedPrice,
              value: '150 ${l10n.searchCurrency}',
              valueColor: AppColors.primary[60],
              showDivider: false,
            ),
          ],
        ),
      ),
      SizedBox(height: 16.h),

      ea(
        2,
        AppHandymanContactCard(
          isDark: isDark,
          name: 'محمد علي',
          specialty: 'فني سباكة محترف',
          rating: 4.9,
          phone: '+201234567890',
          requestId: requestId,
          avatarColors: [AppColors.primary[60]!, AppColors.secondary[60]!],
          titleLabel: l10n.trackHandymanTitle,
          callLabel: l10n.trackCallBtn,
          whatsappLabel: l10n.trackWhatsappBtn,
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
      SizedBox(height: 12.h),

      ea(
        4,
        _OutlineBtn(
          label: l10n.trackReportBtn,
          color: AppColors.info,
          onTap: () => onReport(l10n),
        ),
      ),
    ];
  }
}

// ══════════════════════════════════════════════════════════════
// Mobile
// ══════════════════════════════════════════════════════════════
class _ActiveMobileBody extends StatefulWidget {
  final String requestId;
  const _ActiveMobileBody({required this.requestId});

  @override
  State<_ActiveMobileBody> createState() => _ActiveMobileBodyState();
}

class _ActiveMobileBodyState extends _ActiveBase<_ActiveMobileBody> {
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
// Tablet
// ══════════════════════════════════════════════════════════════
class _ActiveTabletBody extends StatefulWidget {
  final String requestId;
  const _ActiveTabletBody({required this.requestId});

  @override
  State<_ActiveTabletBody> createState() => _ActiveTabletBodyState();
}

class _ActiveTabletBodyState extends _ActiveBase<_ActiveTabletBody> {
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
// _OutlineBtn — scale press + haptic
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
