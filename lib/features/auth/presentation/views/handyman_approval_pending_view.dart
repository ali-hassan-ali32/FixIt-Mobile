import 'package:fix_it/core/router/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/l10n/translation/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/utils/widgets/app_auth_background.dart';

// ══════════════════════════════════════════════════════════════
// HandymanApprovalPendingView — layout router
// ══════════════════════════════════════════════════════════════
class HandymanApprovalPendingView extends StatelessWidget {
  const HandymanApprovalPendingView({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, c) => c.maxWidth >= 600
          ? const ApprovalTabletBody()
          : const ApprovalMobileBody(),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// Shared base — all animations + logic
// ══════════════════════════════════════════════════════════════
abstract class _ApprovalBase<T extends StatefulWidget> extends State<T>
    with TickerProviderStateMixin {

  // Clock icon entry
  late final AnimationController entryCtrl;
  late final Animation<double>   entryScale;
  late final Animation<double>   entryOpacity;

  // Ripple pulse
  late final AnimationController rippleCtrl;
  late final Animation<double>   rippleScale;
  late final Animation<double>   rippleOpacity;

  // Checklist stagger
  late final AnimationController listCtrl;
  late final List<Animation<double>> itemFades;
  late final List<Animation<Offset>>  itemSlides;

  // Button entry
  late final AnimationController btnCtrl;
  late final Animation<double>   btnFade;
  late final Animation<Offset>   btnSlide;

  static const _items = 3;

  @override
  void initState() {
    super.initState();

    entryCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    entryScale = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: entryCtrl, curve: Curves.elasticOut));
    entryOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: entryCtrl,
            curve: const Interval(0.0, 0.5, curve: Curves.easeOut)));

    rippleCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2000))
      ..repeat();
    rippleScale = Tween<double>(begin: 1.0, end: 1.6).animate(
        CurvedAnimation(parent: rippleCtrl, curve: Curves.easeOut));
    rippleOpacity = Tween<double>(begin: 0.5, end: 0.0).animate(
        CurvedAnimation(parent: rippleCtrl, curve: Curves.easeOut));

    listCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));
    itemFades = List.generate(_items, (i) {
      final s = 0.2 + i * 0.25;
      final e = (s + 0.35).clamp(0.0, 1.0);
      return Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(parent: listCtrl,
              curve: Interval(s, e, curve: Curves.easeOut)));
    });
    itemSlides = List.generate(_items, (i) {
      final s = 0.2 + i * 0.25;
      final e = (s + 0.35).clamp(0.0, 1.0);
      return Tween<Offset>(begin: const Offset(0.1, 0.0), end: Offset.zero)
          .animate(CurvedAnimation(parent: listCtrl,
          curve: Interval(s, e, curve: Curves.easeOut)));
    });

    btnCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    btnFade = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: btnCtrl, curve: Curves.easeOut));
    btnSlide = Tween<Offset>(begin: const Offset(0.0, 0.3), end: Offset.zero)
        .animate(CurvedAnimation(parent: btnCtrl, curve: Curves.easeOut));

    // Sequence
    entryCtrl.forward().then((_) =>
        listCtrl.forward().then((_) => btnCtrl.forward()));
  }

  @override
  void dispose() {
    entryCtrl.dispose();
    rippleCtrl.dispose();
    listCtrl.dispose();
    btnCtrl.dispose();
    super.dispose();
  }

  // ── Shared widgets ────────────────────────────────────────
  Widget buildStatusIcon() {
    return AnimatedBuilder(
      animation: Listenable.merge([entryCtrl, rippleCtrl]),
      builder: (_, __) => FadeTransition(
        opacity: entryOpacity,
        child: Transform.scale(
          scale: entryScale.value,
          child: SizedBox(
            width: 110.w, height: 110.w,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Ripple ring
                Transform.scale(
                  scale: rippleScale.value,
                  child: Opacity(
                    opacity: rippleOpacity.value,
                    child: Container(
                      width: 90.w, height: 90.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: AppColors.accent[60]!, width: 2),
                      ),
                    ),
                  ),
                ),
                // Soft ring
                Container(
                  width: 90.w, height: 90.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.accent[60]!.withOpacity(0.12),
                  ),
                ),
                // Inner circle
                Container(
                  width: 64.w, height: 64.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppColors.accent[60]!, AppColors.accent[70]!],
                    ),
                    boxShadow: [BoxShadow(
                        color: AppColors.accent[60]!.withOpacity(0.35),
                        blurRadius: 16, offset: const Offset(0, 6))],
                  ),
                  child: Icon(Icons.access_time_rounded,
                      color: Colors.white, size: 30.sp),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildChecklist(BuildContext context, AppLocalizations l10n) {
    final textTheme   = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final isDark      = Theme.of(context).brightness == Brightness.dark;

    final items = [
      _Item(label: l10n.approvalCheckPersonalData, isDone: true),
      _Item(label: l10n.approvalCheckDocuments,    isDone: true),
      _Item(label: l10n.approvalCheckReview,       isDone: false),
    ];

    return Container(
      padding: EdgeInsets.all(AppSpacing.xl.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : colorScheme.surface,
        borderRadius: BorderRadius.all(AppRadius.lg),
        boxShadow: [BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.20 : 0.05),
            blurRadius: 20, offset: const Offset(0, 4))],
        border: Border.all(color: colorScheme.outline.withOpacity(0.5)),
      ),
      child: Column(
        children: List.generate(items.length, (i) =>
            FadeTransition(
              opacity: itemFades[i],
              child: SlideTransition(
                position: itemSlides[i],
                child: Column(children: [
                  _CheckRow(
                      item: items[i],
                      textTheme: textTheme,
                      colorScheme: colorScheme),
                  if (i < items.length - 1)
                    Divider(height: AppSpacing.xl.h,
                        color: colorScheme.outlineVariant),
                ]),
              ),
            ),
        ),
      ),
    );
  }

  Widget buildButton(BuildContext context, AppLocalizations l10n) {
    return FadeTransition(
      opacity: btnFade,
      child: SlideTransition(
        position: btnSlide,
        child: _OutlineButton(
          label: l10n.approvalBackToLogin,
          accentColor: AppColors.accent[60]!,
          onTap: () => Navigator.of(context)
              .pushReplacementNamed(AppRoutes.login),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// ApprovalMobileBody
// ══════════════════════════════════════════════════════════════
class ApprovalMobileBody extends StatefulWidget {
  const ApprovalMobileBody({super.key});

  @override
  State<ApprovalMobileBody> createState() => _ApprovalMobileBodyState();
}

class _ApprovalMobileBodyState extends _ApprovalBase<ApprovalMobileBody> {
  @override
  Widget build(BuildContext context) {
    final l10n        = AppLocalizations.of(context)!;
    final textTheme   = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: AppAuthBackground(
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.xl.w, vertical: AppSpacing.xl.h),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                buildStatusIcon(),
                SizedBox(height: 28.h),
                FadeTransition(opacity: entryOpacity,
                    child: Text(l10n.approvalPendingTitle,
                        style: textTheme.displayMedium,
                        textAlign: TextAlign.center)),
                SizedBox(height: 12.h),
                FadeTransition(opacity: entryOpacity,
                    child: Text(l10n.approvalPendingSubtitle,
                        style: textTheme.bodyLarge?.copyWith(
                            color: colorScheme.onSurfaceVariant, height: 1.6),
                        textAlign: TextAlign.center)),
                SizedBox(height: 32.h),
                buildChecklist(context, l10n),
                const Spacer(),
                buildButton(context, l10n),
                SizedBox(height: 16.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// ApprovalTabletBody — centered card on gradient bg
// ══════════════════════════════════════════════════════════════
class ApprovalTabletBody extends StatefulWidget {
  const ApprovalTabletBody({super.key});

  @override
  State<ApprovalTabletBody> createState() => _ApprovalTabletBodyState();
}

class _ApprovalTabletBodyState extends _ApprovalBase<ApprovalTabletBody> {
  @override
  Widget build(BuildContext context) {
    final l10n        = AppLocalizations.of(context)!;
    final textTheme   = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final isDark      = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: AppAuthBackground(
        child: SizedBox.expand(
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(AppSpacing.xl.w),
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 560),
                  padding: EdgeInsets.all(40.w),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.darkSurface.withOpacity(0.95)
                        : Colors.white.withOpacity(0.92),
                    borderRadius: BorderRadius.circular(28.r),
                    boxShadow: [BoxShadow(
                        color: AppColors.accent[60]!.withOpacity(0.12),
                        blurRadius: 40, offset: const Offset(0, 12))],
                    border: Border.all(
                        color: AppColors.accent[60]!.withOpacity(0.10)),
                  ),
                  child: Column(
                    children: [
                      buildStatusIcon(),
                      SizedBox(height: 28.h),
                      FadeTransition(opacity: entryOpacity,
                          child: Text(l10n.approvalPendingTitle,
                              style: textTheme.displayMedium,
                              textAlign: TextAlign.center)),
                      SizedBox(height: 12.h),
                      FadeTransition(opacity: entryOpacity,
                          child: Text(l10n.approvalPendingSubtitle,
                              style: textTheme.bodyLarge?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                  height: 1.6),
                              textAlign: TextAlign.center)),
                      SizedBox(height: 32.h),
                      buildChecklist(context, l10n),
                      SizedBox(height: 32.h),
                      buildButton(context, l10n),
                    ],
                  ),
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
// Private helpers
// ══════════════════════════════════════════════════════════════
class _Item {
  final String label;
  final bool   isDone;
  const _Item({required this.label, required this.isDone});
}

class _CheckRow extends StatelessWidget {
  final _Item       item;
  final TextTheme   textTheme;
  final ColorScheme colorScheme;

  const _CheckRow({
    required this.item, required this.textTheme, required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    final color = item.isDone
        ? AppColors.accent[60]!
        : AppColors.secondary[60]!;
    return Row(children: [
      Container(
        width: 32.w, height: 32.w,
        decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withOpacity(0.15)),
        child: Icon(
            item.isDone ? Icons.check_rounded : Icons.add_rounded,
            color: color, size: 18.sp),
      ),
      SizedBox(width: 14.w),
      Expanded(child: Text(item.label,
          style: textTheme.bodyLarge
              ?.copyWith(fontWeight: FontWeight.w600))),
    ]);
  }
}

class _OutlineButton extends StatefulWidget {
  final String       label;
  final Color        accentColor;
  final VoidCallback onTap;

  const _OutlineButton({
    required this.label, required this.accentColor, required this.onTap});

  @override
  State<_OutlineButton> createState() => _OutlineButtonState();
}

class _OutlineButtonState extends State<_OutlineButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 120));
  late final Animation<double> _scale = Tween<double>(begin: 1.0, end: 0.97)
      .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final textTheme   = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTapDown: (_) { _ctrl.forward(); HapticFeedback.selectionClick(); },
      onTapUp:   (_) { _ctrl.reverse(); widget.onTap(); },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          width: double.infinity,
          height: 54.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(AppRadius.lg),
            border: Border.all(color: widget.accentColor, width: 2),
            boxShadow: [BoxShadow(
                color: widget.accentColor.withOpacity(0.18),
                blurRadius: 12, offset: const Offset(0, 4))],
          ),
          child: Center(
            child: Text(widget.label,
                style: GoogleFonts.cairo(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w700,
                  color: widget.accentColor,
                )),
          ),
        ),
      ),
    );
  }
}