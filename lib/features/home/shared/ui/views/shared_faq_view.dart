import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../core/l10n/translation/app_localizations.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_sizes.dart';
import '../../../../../core/utils/widgets/app_main_background.dart';
import '../../../../../core/utils/widgets/app_page_header.dart';

// ══════════════════════════════════════════════════════════════
// FaqStep model
// ══════════════════════════════════════════════════════════════
class FaqStep {
  final String title;
  final String description;
  const FaqStep({required this.title, required this.description});
}

// ══════════════════════════════════════════════════════════════
// SharedFaqView — layout router
// Reusable FAQ/article page. Pass title + steps.
//
// Usage:
//   SharedFaqView(
//     title: l10n.helpFaqBookingTitle,
//     accentColor: AppColors.primary[60]!,
//     steps: [
//       FaqStep(title: '١. اختر الخدمة', description: '...'),
//       ...
//     ],
//   )
// ══════════════════════════════════════════════════════════════
class SharedFaqView extends StatelessWidget {
  final String title;
  final List<FaqStep> steps;
  final Color accentColor;

  const SharedFaqView({
    super.key,
    required this.title,
    required this.steps,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, constraints) => constraints.maxWidth >= 600
          ? _FaqTabletBody(title: title, steps: steps, accentColor: accentColor)
          : _FaqMobileBody(title: title, steps: steps, accentColor: accentColor),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// Shared base class
// ══════════════════════════════════════════════════════════════
abstract class _FaqBase<T extends StatefulWidget> extends State<T>
    with TickerProviderStateMixin {

  String get title;
  List<FaqStep> get steps;
  Color get accentColor;

  late final AnimationController entryCtrl;
  late final List<Animation<double>> entryFade;
  late final List<Animation<Offset>> entrySlide;

  int get _itemCount => steps.length + 1;

  @override
  void initState() {
    super.initState();

    entryCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    final count = _itemCount;
    entryFade = List.generate(count, (i) {
      final start = i * 0.12;
      return Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
        parent: entryCtrl,
        curve: Interval(
          start.clamp(0.0, 1.0),
          (start + 0.40).clamp(0.0, 1.0),
          curve: Curves.easeOut,
        ),
      ));
    });

    entrySlide = List.generate(count, (i) {
      final start = i * 0.12;
      return Tween<Offset>(begin: const Offset(0, 0.14), end: Offset.zero)
          .animate(CurvedAnimation(
        parent: entryCtrl,
        curve: Interval(
          start.clamp(0.0, 1.0),
          (start + 0.45).clamp(0.0, 1.0),
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
    final idx = i.clamp(0, entryFade.length - 1);
    return FadeTransition(
      opacity: entryFade[idx],
      child: SlideTransition(position: entrySlide[idx], child: child),
    );
  }

  // ── Build header ──────────────────────────────────────────
  Widget buildHeader(bool isDark) {
    return AppPageHeader(
      isDark: isDark,
      title: title,
      accentColor: accentColor,
    );
  }

  // ── Build step card ───────────────────────────────────────
  Widget buildStepCard(int index, bool isDark) {
    return _StepCard(
      step: steps[index],
      index: index,
      accent: accentColor,
      isDark: isDark,
      isLast: index == steps.length - 1,
    );
  }
}

// ══════════════════════════════════════════════════════════════
// Mobile Body
// ══════════════════════════════════════════════════════════════
class _FaqMobileBody extends StatefulWidget {
  final String title;
  final List<FaqStep> steps;
  final Color accentColor;

  const _FaqMobileBody({
    required this.title,
    required this.steps,
    required this.accentColor,
  });

  @override
  State<_FaqMobileBody> createState() => _FaqMobileBodyState();
}

class _FaqMobileBodyState extends _FaqBase<_FaqMobileBody> {
  @override
  String get title => widget.title;
  @override
  List<FaqStep> get steps => widget.steps;
  @override
  Color get accentColor => widget.accentColor;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppMainBackground(
        child: Column(
          children: [
            animatedSection(0, buildHeader(isDark)),
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.all(AppSpacing.xl.w),
                itemCount: steps.length,
                itemBuilder: (ctx, i) => animatedSection(
                  i + 1,
                  Padding(
                    padding: EdgeInsets.only(bottom: 16.h),
                    child: buildStepCard(i, isDark),
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
class _FaqTabletBody extends StatefulWidget {
  final String title;
  final List<FaqStep> steps;
  final Color accentColor;

  const _FaqTabletBody({
    required this.title,
    required this.steps,
    required this.accentColor,
  });

  @override
  State<_FaqTabletBody> createState() => _FaqTabletBodyState();
}

class _FaqTabletBodyState extends _FaqBase<_FaqTabletBody> {
  @override
  String get title => widget.title;
  @override
  List<FaqStep> get steps => widget.steps;
  @override
  Color get accentColor => widget.accentColor;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;

    // Split steps into two columns for tablet
    final leftSteps = steps.asMap().entries
        .where((e) => e.key.isEven)
        .map((e) => MapEntry(e.key, e.value))
        .toList();
    final rightSteps = steps.asMap().entries
        .where((e) => e.key.isOdd)
        .map((e) => MapEntry(e.key, e.value))
        .toList();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppMainBackground(
        child: Column(
          children: [
            animatedSection(0, buildHeader(isDark)),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(AppSpacing.xl.w),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 900),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Left column - Steps
                        Expanded(
                          flex: 55,
                          child: Column(
                            children: [
                              // Info header for tablet
                              animatedSection(
                                1,
                                _FaqHeaderCard(
                                  accent: accentColor,
                                  isDark: isDark,
                                  textTheme: textTheme,
                                  l10n: l10n,
                                  stepCount: steps.length,
                                ),
                              ),
                              SizedBox(height: 20.h),

                              // Left column steps
                              ...leftSteps.asMap().entries.map((entry) {
                                final originalIndex = entry.value.key;
                                return animatedSection(
                                  originalIndex + 1,
                                  Padding(
                                    padding: EdgeInsets.only(bottom: 16.h),
                                    child: buildStepCard(originalIndex, isDark),
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                        SizedBox(width: 24.w),

                        // Right column - More steps
                        Expanded(
                          flex: 45,
                          child: Column(
                            children: [
                              SizedBox(height: 80.h), // Offset for header card
                              ...rightSteps.asMap().entries.map((entry) {
                                final originalIndex = entry.value.key;
                                return animatedSection(
                                  originalIndex + 1,
                                  Padding(
                                    padding: EdgeInsets.only(bottom: 16.h),
                                    child: buildStepCard(originalIndex, isDark),
                                  ),
                                );
                              }),
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
// _StepCard
// ══════════════════════════════════════════════════════════════
class _StepCard extends StatefulWidget {
  final FaqStep step;
  final int index;
  final Color accent;
  final bool isDark;
  final bool isLast;

  const _StepCard({
    required this.step,
    required this.index,
    required this.accent,
    required this.isDark,
    required this.isLast,
  });

  @override
  State<_StepCard> createState() => _StepCardState();
}

class _StepCardState extends State<_StepCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 300),
  );
  late final Animation<double> _scale = Tween<double>(begin: 1.0, end: 0.98)
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
      onTapUp: (_) => _ctrl.reverse(),
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Step number + connector line
              Column(
                children: [
                  Container(
                    width: 36.w,
                    height: 36.w,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [widget.accent, widget.accent.withOpacity(0.78)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: widget.accent.withOpacity(0.30),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        '${widget.index + 1}',
                        style: GoogleFonts.cairo(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  if (!widget.isLast)
                    Expanded(
                      child: Container(
                        width: 2.w,
                        margin: EdgeInsets.symmetric(vertical: 6.h),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              widget.accent.withOpacity(0.40),
                              widget.accent.withOpacity(0.05),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          borderRadius: BorderRadius.circular(2.r),
                        ),
                      ),
                    ),
                ],
              ),
              SizedBox(width: 14.w),

              // Content card
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(bottom: widget.isLast ? 0 : 4.h),
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: widget.isDark ? AppColors.darkSurface : Colors.white,
                    borderRadius: BorderRadius.circular(14.r),
                    border: Border.all(color: widget.accent.withOpacity(0.10)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(widget.isDark ? 0.15 : 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.step.title,
                        style: textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: widget.accent,
                        ),
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        widget.step.description,
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          height: 1.65,
                        ),
                      ),
                    ],
                  ),
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
// _FaqHeaderCard — tablet header card
// ══════════════════════════════════════════════════════════════
class _FaqHeaderCard extends StatelessWidget {
  final Color accent;
  final bool isDark;
  final TextTheme textTheme;
  final AppLocalizations l10n;
  final int stepCount;

  const _FaqHeaderCard({
    required this.accent,
    required this.isDark,
    required this.textTheme,
    required this.l10n,
    required this.stepCount,
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
            child: Icon(
              Icons.help_outline_rounded,
              size: 28.sp,
              color: Colors.white,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.helpFaqStepsTitle,
                  style: GoogleFonts.cairo(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  l10n.helpFaqStepsSubtitle(stepCount),
                  style: GoogleFonts.cairo(
                    fontSize: 13.sp,
                    color: Colors.white.withOpacity(0.85),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.25),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Text(
              '$stepCount ${l10n.helpFaqStepsCount}',
              style: GoogleFonts.cairo(
                fontSize: 12.sp,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
