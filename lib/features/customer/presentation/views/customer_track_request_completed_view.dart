import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/l10n/translation/app_localizations.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/utils/widgets/app_main_background.dart';
import '../../../../core/utils/widgets/app_detail_row.dart';
import '../../../../core/utils/widgets/app_page_header.dart';
import '../../../../core/utils/widgets/app_rating_star.dart';
import '../../../../core/utils/widgets/app_request_timeline.dart';
import '../../data/models/requests/review_request.dart';
import '../../domain/entities/customer_request_details_entity.dart';
import '../cubit/customer_cubit.dart';
import '../cubit/customer_state.dart';

// ══════════════════════════════════════════════════════════════
// CustomerTrackRequestCompletedView — layout router
// ══════════════════════════════════════════════════════════════
class CustomerTrackRequestCompletedView extends StatelessWidget {
  final String requestId;
  const CustomerTrackRequestCompletedView({super.key, required this.requestId});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, c) => c.maxWidth >= 600
          ? _CompletedTabletBody(requestId: requestId)
          : _CompletedMobileBody(requestId: requestId),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// Shared base
// ══════════════════════════════════════════════════════════════
abstract class _CompletedBase<T extends StatefulWidget> extends State<T>
    with TickerProviderStateMixin {
  String get requestId;
  Color get accent => AppColors.primary[60]!;

  CustomerRequestDetailsEntity? _details;
  bool _hasRated = false;

  late final AnimationController entryCtrl;
  late final List<Animation<double>> entryFade;
  late final List<Animation<Offset>> entrySlide;
  static const _n = 5;

  late final AnimationController bannerCtrl;
  late final Animation<double> bannerScale;
  late final Animation<double> bannerFade;

  @override
  void initState() {
    super.initState();
    entryCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 750));
    entryFade = List.generate(_n, (i) {
      final s = (i * 0.15).clamp(0.0, 1.0);
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: entryCtrl, curve: Interval(s, (s + 0.45).clamp(0.0, 1.0), curve: Curves.easeOut)),
      );
    });
    entrySlide = List.generate(_n, (i) {
      final s = (i * 0.15).clamp(0.0, 1.0);
      return Tween<Offset>(begin: const Offset(0, 0.14), end: Offset.zero).animate(
        CurvedAnimation(parent: entryCtrl, curve: Interval(s, (s + 0.50).clamp(0.0, 1.0), curve: Curves.easeOutCubic)),
      );
    });
    bannerCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    bannerScale = Tween<double>(begin: 0.7, end: 1.0).animate(CurvedAnimation(parent: bannerCtrl, curve: Curves.easeOutBack));
    bannerFade = CurvedAnimation(parent: bannerCtrl, curve: Curves.easeOut);

    entryCtrl.forward();
    Future.delayed(const Duration(milliseconds: 200), () { if (mounted) bannerCtrl.forward(); });
  }

  @override
  void dispose() { entryCtrl.dispose(); bannerCtrl.dispose(); super.dispose(); }

  Widget ea(int i, Widget child) {
    final idx = i.clamp(0, _n - 1);
    return FadeTransition(opacity: entryFade[idx], child: SlideTransition(position: entrySlide[idx], child: child));
  }

  String _fmt(DateTime dt) => DateFormat('yyyy/MM/dd – HH:mm').format(dt);

  List<Widget> buildContent(
    BuildContext ctx,
    bool isDark,
    AppLocalizations l10n,
    CustomerRequestDetailsEntity d,
  ) {
    final textTheme = Theme.of(ctx).textTheme;
    final colorScheme = Theme.of(ctx).colorScheme;

    final steps = [
      AppTimelineStep(title: l10n.trackStepCreated, time: _fmt(d.createdAt), description: l10n.trackStepCreatedDesc, status: TimelineStepStatus.completed),
      AppTimelineStep(title: l10n.trackStepAccepted, time: _fmt(d.scheduledAt), description: l10n.trackStepAcceptedDesc, status: TimelineStepStatus.completed),
      AppTimelineStep(title: l10n.trackStepInProgress, time: _fmt(d.scheduledAt), description: l10n.trackStepDoneDesc, status: TimelineStepStatus.completed),
      AppTimelineStep(title: l10n.trackStepCompleted, time: _fmt(d.scheduledAt), description: l10n.trackStepCompletedDesc, status: TimelineStepStatus.completed),
    ];

    return [
      FadeTransition(
        opacity: bannerFade,
        child: ScaleTransition(
          scale: bannerScale,
          child: _CompletionBanner(isDark: isDark, textTheme: textTheme, colorScheme: colorScheme, l10n: l10n),
        ),
      ),
      SizedBox(height: 24.h),

      ea(0, Text(l10n.trackStatusTitle, style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800))),
      SizedBox(height: 16.h),
      ea(0, AppRequestTimeline(steps: steps, isDark: isDark)),
      SizedBox(height: 24.h),

      ea(
        1,
        AppDetailCard(
          isDark: isDark,
          title: l10n.trackServiceDetailsTitle,
          rows: [
            AppDetailRow(label: l10n.trackServiceType, value: d.title),
            AppDetailRow(label: l10n.trackLocation, value: d.address),
            AppDetailRow(label: l10n.trackCompletionDate, value: _fmt(d.scheduledAt)),
            AppDetailRow(
              label: l10n.trackFinalPrice,
              value: d.description,
              valueColor: AppColors.accent[60],
              showDivider: false,
            ),
          ],
        ),
      ),
      SizedBox(height: 16.h),

      if (d.handymanName != null)
        ea(2, _HandymanCard(isDark: isDark, textTheme: textTheme, colorScheme: colorScheme, l10n: l10n, name: d.handymanName!)),
      SizedBox(height: 16.h),

      // Reviews nav card — uses handymanId if available, falls back to requestId
      // ea(
      //   3,
      //   _ReviewsNavCard(
      //     isDark: isDark,
      //     textTheme: textTheme,
      //     accent: accent,
      //     onTap: () => Navigator.of(context).pushNamed(
      //       AppRoutes.customerViewHandymanReviews,
      //       arguments: d.handymanId ?? requestId,
      //     ),
      //   ),
      // ),
      // SizedBox(height: 16.h),

      // Rating + comment card
      ea(
        4,
        _RatingCommentCard(
          isDark: isDark,
          textTheme: textTheme,
          colorScheme: colorScheme,
          l10n: l10n,
          hasRated: _hasRated,
          onSubmit: (rating, comment) {
            ctx.read<CustomerCubit>().addReview(
              requestId,
              ReviewRequest(rating: rating, comment: comment),
            );
            setState(() => _hasRated = true);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    Icon(Icons.star_rounded, color: AppColors.star, size: 20.sp),
                    SizedBox(width: 8.w),
                    Text('${l10n.ratingThanks} $rating ${l10n.ratingStars}', style: GoogleFonts.cairo(fontWeight: FontWeight.w600)),
                  ],
                ),
                backgroundColor: AppColors.accent[60],
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
              ),
            );
          },
        ),
      ),
    ];
  }
}

// ══════════════════════════════════════════════════════════════
// Mobile
// ══════════════════════════════════════════════════════════════
class _CompletedMobileBody extends StatefulWidget {
  final String requestId;
  const _CompletedMobileBody({required this.requestId});

  @override
  State<_CompletedMobileBody> createState() => _CompletedMobileBodyState();
}

class _CompletedMobileBodyState extends _CompletedBase<_CompletedMobileBody> {
  @override
  String get requestId => widget.requestId;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    return BlocConsumer<CustomerCubit, CustomerState>(
      listenWhen: (_, s) => s is CustomerRequestDetailsLoaded || s is CustomerMessage || s is CustomerError,
      listener: (_, state) {
        if (state is CustomerRequestDetailsLoaded) {
          setState(() => _details = state.request);
          entryCtrl.forward(from: 0);
          Future.delayed(const Duration(milliseconds: 200), () { if (mounted) bannerCtrl.forward(from: 0); });
        }
        if (state is CustomerError) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      buildWhen: (_, s) => s is CustomerLoading || s is CustomerRequestDetailsLoaded || s is CustomerError,
      builder: (ctx, state) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: AppMainBackground(
            child: Column(
              children: [
                AppPageHeader(isDark: isDark, accentColor: accent, title: l10n.trackTitle, subtitle: '#$requestId'),
                Expanded(
                  child: state is CustomerLoading && _details == null
                      ? const Center(child: CircularProgressIndicator())
                      : state is CustomerError && _details == null
                          ? Center(child: Text((state as CustomerError).message))
                          : _details == null
                              ? const Center(child: CircularProgressIndicator())
                              : ListView(
                                  padding: EdgeInsets.fromLTRB(AppSpacing.xl.w, AppSpacing.xl.h, AppSpacing.xl.w, MediaQuery.of(context).padding.bottom + 32.h),
                                  children: buildContent(ctx, isDark, l10n, _details!),
                                ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ══════════════════════════════════════════════════════════════
// Tablet
// ══════════════════════════════════════════════════════════════
class _CompletedTabletBody extends StatefulWidget {
  final String requestId;
  const _CompletedTabletBody({required this.requestId});

  @override
  State<_CompletedTabletBody> createState() => _CompletedTabletBodyState();
}

class _CompletedTabletBodyState extends _CompletedBase<_CompletedTabletBody> {
  @override
  String get requestId => widget.requestId;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    return BlocConsumer<CustomerCubit, CustomerState>(
      listenWhen: (_, s) => s is CustomerRequestDetailsLoaded || s is CustomerMessage || s is CustomerError,
      listener: (_, state) {
        if (state is CustomerRequestDetailsLoaded) {
          setState(() => _details = state.request);
          entryCtrl.forward(from: 0);
          Future.delayed(const Duration(milliseconds: 200), () { if (mounted) bannerCtrl.forward(from: 0); });
        }
        if (state is CustomerError) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      buildWhen: (_, s) => s is CustomerLoading || s is CustomerRequestDetailsLoaded || s is CustomerError,
      builder: (ctx, state) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: AppMainBackground(
            child: Column(
              children: [
                AppPageHeader(isDark: isDark, accentColor: accent, title: l10n.trackTitle, subtitle: '#$requestId'),
                Expanded(
                  child: state is CustomerLoading && _details == null
                      ? const Center(child: CircularProgressIndicator())
                      : state is CustomerError && _details == null
                          ? Center(child: Text((state as CustomerError).message))
                          : _details == null
                              ? const Center(child: CircularProgressIndicator())
                              : Center(
                                  child: ConstrainedBox(
                                    constraints: const BoxConstraints(maxWidth: 600),
                                    child: ListView(
                                      padding: EdgeInsets.fromLTRB(AppSpacing.xl.w, AppSpacing.xl.h, AppSpacing.xl.w, 32.h),
                                      children: buildContent(ctx, isDark, l10n, _details!),
                                    ),
                                  ),
                                ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ══════════════════════════════════════════════════════════════
// _CompletionBanner
// ══════════════════════════════════════════════════════════════
class _CompletionBanner extends StatelessWidget {
  final bool isDark;
  final TextTheme textTheme;
  final ColorScheme colorScheme;
  final AppLocalizations l10n;

  const _CompletionBanner({required this.isDark, required this.textTheme, required this.colorScheme, required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [AppColors.accent[60]!.withOpacity(0.15), AppColors.accent[60]!.withOpacity(0.05)]),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.accent[60]!.withOpacity(0.30)),
      ),
      child: Row(
        children: [
          Container(
            width: 56.w, height: 56.w,
            decoration: BoxDecoration(color: AppColors.accent[60]!.withOpacity(0.15), shape: BoxShape.circle),
            child: Icon(Icons.check_circle_rounded, size: 32.sp, color: AppColors.accent[60]),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.trackCompletedBannerTitle, style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
                SizedBox(height: 4.h),
                Text(l10n.trackCompletedBannerSubtitle, style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant, height: 1.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// _HandymanCard
// ══════════════════════════════════════════════════════════════
class _HandymanCard extends StatelessWidget {
  final bool isDark;
  final TextTheme textTheme;
  final ColorScheme colorScheme;
  final AppLocalizations l10n;
  final String name;

  const _HandymanCard({required this.isDark, required this.textTheme, required this.colorScheme, required this.l10n, required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.primary[60]!.withOpacity(0.08)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDark ? 0.15 : 0.05), blurRadius: 12, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.trackHandymanTitle, style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
          SizedBox(height: 16.h),
          Row(
            children: [
              Container(
                width: 64.w, height: 64.w,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [AppColors.accent[60]!, AppColors.accent[70]!], begin: Alignment.topLeft, end: Alignment.bottomRight),
                  borderRadius: BorderRadius.circular(14.r),
                ),
                child: Icon(Icons.person_rounded, size: 32.sp, color: Colors.white),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                    SizedBox(height: 6.h),
                    AppRatingStars(rating: 5.0, starSize: 14),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// _ReviewsNavCard — tappable card navigating to handyman reviews
// ══════════════════════════════════════════════════════════════
class _ReviewsNavCard extends StatelessWidget {
  final bool isDark;
  final TextTheme textTheme;
  final Color accent;
  final VoidCallback onTap;

  const _ReviewsNavCard({required this.isDark, required this.textTheme, required this.accent, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: accent.withOpacity(0.18)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDark ? 0.15 : 0.05), blurRadius: 10, offset: const Offset(0, 2))],
        ),
        child: Row(
          children: [
            Container(
              width: 44.w, height: 44.w,
              decoration: BoxDecoration(color: accent.withOpacity(0.10), borderRadius: BorderRadius.circular(12.r)),
              child: Icon(Icons.star_rounded, size: 22.sp, color: accent),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('مراجعات الفني', style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700)),
                  SizedBox(height: 2.h),
                  Text('اطلع على تقييمات العملاء الآخرين', style: textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, size: 22.sp, color: accent),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// _RatingCommentCard — stars + comment text field + submit
// ══════════════════════════════════════════════════════════════
class _RatingCommentCard extends StatefulWidget {
  final bool isDark;
  final TextTheme textTheme;
  final ColorScheme colorScheme;
  final AppLocalizations l10n;
  final bool hasRated;
  final void Function(int rating, String comment) onSubmit;

  const _RatingCommentCard({
    required this.isDark,
    required this.textTheme,
    required this.colorScheme,
    required this.l10n,
    required this.hasRated,
    required this.onSubmit,
  });

  @override
  State<_RatingCommentCard> createState() => _RatingCommentCardState();
}

class _RatingCommentCardState extends State<_RatingCommentCard> {
  int _selected = 0;
  int _hovered = 0;
  bool _submitted = false;
  final TextEditingController _commentCtrl = TextEditingController();
  final FocusNode _commentFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _submitted = widget.hasRated;
    if (widget.hasRated) _selected = 5;
  }

  @override
  void dispose() {
    _commentCtrl.dispose();
    _commentFocus.dispose();
    super.dispose();
  }

  String _emoji(int s) {
    switch (s) {
      case 1: return '😞';
      case 2: return '😕';
      case 3: return '😐';
      case 4: return '😊';
      case 5: return '🤩';
      default: return '⭐';
    }
  }

  void _submit() {
    if (_selected == 0) return;
    HapticFeedback.mediumImpact();
    _commentFocus.unfocus();
    setState(() => _submitted = true);
    widget.onSubmit(_selected, _commentCtrl.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = widget.l10n;
    final textTheme = widget.textTheme;
    final colorScheme = widget.colorScheme;
    final isDark = widget.isDark;
    final display = _hovered > 0 ? _hovered : _selected;

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: _submitted
              ? AppColors.accent[60]!.withOpacity(0.30)
              : AppColors.primary[60]!.withOpacity(0.08),
        ),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDark ? 0.15 : 0.05), blurRadius: 12, offset: const Offset(0, 2))],
      ),
      child: _submitted ? _buildSubmitted(textTheme) : _buildForm(textTheme, colorScheme, display, l10n, isDark),
    );
  }

  // ── Already submitted ────────────────────────────────────
  Widget _buildSubmitted(TextTheme textTheme) {
    return Column(
      children: [
        Container(
          width: 64.w, height: 64.w,
          decoration: BoxDecoration(color: AppColors.accent[60]!.withOpacity(0.10), shape: BoxShape.circle),
          child: Icon(Icons.check_circle_rounded, size: 36.sp, color: AppColors.accent[60]),
        ),
        SizedBox(height: 12.h),
        Text(
          '${_emoji(_selected)} ${widget.l10n.ratingAlreadyRated}',
          style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 10.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (i) => Icon(
            i < _selected ? Icons.star_rounded : Icons.star_outline_rounded,
            size: 28.sp,
            color: i < _selected ? AppColors.star : Colors.grey.withOpacity(0.3),
          )),
        ),
        if (_commentCtrl.text.trim().isNotEmpty) ...[
          SizedBox(height: 12.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: AppColors.accent[60]!.withOpacity(0.06),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Text(
              _commentCtrl.text.trim(),
              style: textTheme.bodySmall?.copyWith(height: 1.5, color: widget.colorScheme.onSurfaceVariant),
              textAlign: TextAlign.start,
            ),
          ),
        ],
      ],
    );
  }

  // ── Interactive form ─────────────────────────────────────
  Widget _buildForm(TextTheme textTheme, ColorScheme colorScheme, int display, AppLocalizations l10n, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Prompt
        Text(l10n.ratingPrompt, style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700), textAlign: TextAlign.center),
        SizedBox(height: 16.h),

        // Emoji
        Center(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Text(_emoji(display), key: ValueKey(display), style: TextStyle(fontSize: 32.sp)),
          ),
        ),
        SizedBox(height: 12.h),

        // Stars
        Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(5, (i) {
              final v = i + 1;
              final isOn = v <= display;
              return GestureDetector(
                onTapDown: (_) { setState(() => _hovered = v); HapticFeedback.selectionClick(); },
                onTapUp: (_) { setState(() { _selected = v; _hovered = 0; }); },
                onTapCancel: () => setState(() => _hovered = 0),
                child: AnimatedScale(
                  scale: isOn ? 1.15 : 1.0,
                  duration: const Duration(milliseconds: 150),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4.w),
                    child: Icon(
                      isOn ? Icons.star_rounded : Icons.star_outline_rounded,
                      size: 36.sp,
                      color: isOn ? AppColors.star : Colors.grey.withOpacity(0.3),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
        SizedBox(height: 20.h),

        // Comment text field
        Text(l10n.ratingCommentLabel, style: textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700, color: colorScheme.onSurfaceVariant)),
        SizedBox(height: 8.h),
        TextField(
          controller: _commentCtrl,
          focusNode: _commentFocus,
          maxLines: 3,
          minLines: 2,
          maxLength: 300,
          style: GoogleFonts.cairo(fontSize: 14.sp),
          decoration: InputDecoration(
            hintText: l10n.ratingCommentHint,
            hintStyle: GoogleFonts.cairo(fontSize: 13.sp, color: colorScheme.onSurfaceVariant.withOpacity(0.60)),
            filled: true,
            fillColor: isDark ? AppColors.darkBgSecondary : AppColors.primary[60]!.withOpacity(0.04),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: AppColors.primary[60]!.withOpacity(0.15)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: AppColors.primary[60]!.withOpacity(0.15)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: AppColors.primary[60]!, width: 1.5),
            ),
            counterStyle: GoogleFonts.cairo(fontSize: 11.sp, color: colorScheme.onSurfaceVariant.withOpacity(0.50)),
            contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
          ),
        ),
        SizedBox(height: 16.h),

        // Submit button
        _SubmitButton(
          label: l10n.ratingSubmitBtn,
          enabled: _selected > 0,
          onTap: _submit,
        ),
      ],
    );
  }
}

// ── Submit button ──────────────────────────────────────────
class _SubmitButton extends StatefulWidget {
  final String label;
  final bool enabled;
  final VoidCallback onTap;

  const _SubmitButton({required this.label, required this.enabled, required this.onTap});

  @override
  State<_SubmitButton> createState() => _SubmitButtonState();
}

class _SubmitButtonState extends State<_SubmitButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.enabled ? (_) => setState(() => _pressed = true) : null,
      onTapUp: widget.enabled ? (_) { setState(() => _pressed = false); widget.onTap(); } : null,
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: double.infinity, height: 50.h,
          decoration: BoxDecoration(
            gradient: widget.enabled ? LinearGradient(colors: [AppColors.accent[60]!, AppColors.accent[70]!]) : null,
            color: widget.enabled ? null : Colors.grey.withOpacity(0.2),
            borderRadius: BorderRadius.circular(14.r),
            boxShadow: widget.enabled ? [BoxShadow(color: AppColors.accent[60]!.withOpacity(0.35), blurRadius: 12, offset: const Offset(0, 4))] : null,
          ),
          child: Center(
            child: Text(
              widget.label,
              style: GoogleFonts.cairo(fontSize: 15.sp, fontWeight: FontWeight.w700, color: widget.enabled ? Colors.white : Colors.grey),
            ),
          ),
        ),
      ),
    );
  }
}
