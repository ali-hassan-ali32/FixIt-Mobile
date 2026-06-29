import 'package:flutter/material.dart';
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
import '../../../../core/utils/widgets/app_request_timeline.dart';
import '../../../../core/utils/widgets/buttons/app_gradient_button.dart';
import '../../domain/entities/customer_request_details_entity.dart';
import '../cubit/customer_cubit.dart';
import '../cubit/customer_state.dart';

// ══════════════════════════════════════════════════════════════
// CustomerTrackRequestCancelledView — layout router
// ══════════════════════════════════════════════════════════════
class CustomerTrackRequestCancelledView extends StatelessWidget {
  final String requestId;
  final String? cancelReason;

  const CustomerTrackRequestCancelledView({
    super.key,
    required this.requestId,
    this.cancelReason,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, c) => c.maxWidth >= 600
          ? _CancelledTabletBody(requestId: requestId, cancelReason: cancelReason)
          : _CancelledMobileBody(requestId: requestId, cancelReason: cancelReason),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// Shared base
// ══════════════════════════════════════════════════════════════
abstract class _CancelledBase<T extends StatefulWidget> extends State<T>
    with TickerProviderStateMixin {
  String get requestId;
  String? get cancelReason;
  Color get accent => AppColors.primary[60]!;

  CustomerRequestDetailsEntity? _details;

  late final AnimationController entryCtrl;
  late final List<Animation<double>> entryFade;
  late final List<Animation<Offset>> entrySlide;
  static const _n = 4;

  late final AnimationController cardCtrl;
  late final Animation<double> cardScale;
  late final Animation<double> cardFade;

  @override
  void initState() {
    super.initState();
    entryCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    entryFade = List.generate(_n, (i) {
      final s = (i * 0.18).clamp(0.0, 1.0);
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: entryCtrl, curve: Interval(s, (s + 0.45).clamp(0.0, 1.0), curve: Curves.easeOut)),
      );
    });
    entrySlide = List.generate(_n, (i) {
      final s = (i * 0.18).clamp(0.0, 1.0);
      return Tween<Offset>(begin: const Offset(0, 0.14), end: Offset.zero).animate(
        CurvedAnimation(parent: entryCtrl, curve: Interval(s, (s + 0.50).clamp(0.0, 1.0), curve: Curves.easeOutCubic)),
      );
    });
    cardCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    cardScale = Tween<double>(begin: 0.75, end: 1.0).animate(CurvedAnimation(parent: cardCtrl, curve: Curves.easeOutBack));
    cardFade = CurvedAnimation(parent: cardCtrl, curve: Curves.easeOut);

    entryCtrl.forward();
    Future.delayed(const Duration(milliseconds: 300), () { if (mounted) cardCtrl.forward(); });
  }

  @override
  void dispose() { entryCtrl.dispose(); cardCtrl.dispose(); super.dispose(); }

  Widget ea(int i, Widget child) {
    final idx = i.clamp(0, _n - 1);
    return FadeTransition(opacity: entryFade[idx], child: SlideTransition(position: entrySlide[idx], child: child));
  }

  String _fmt(DateTime dt) => DateFormat('yyyy/MM/dd – HH:mm').format(dt);

  List<Widget> buildContent(BuildContext ctx, bool isDark, AppLocalizations l10n, CustomerRequestDetailsEntity d,) {
    final textTheme = Theme.of(ctx).textTheme;
    final colorScheme = Theme.of(ctx).colorScheme;
    final reason = cancelReason?.isNotEmpty == true
        ? cancelReason!
        : (d.description.isNotEmpty
        ? d.description
        : l10n.trackCancelledByCustomer);

    final steps = [
      AppTimelineStep(
        title: l10n.trackStepCreated,
        time: _fmt(d.createdAt),
        description: l10n.trackStepCreatedDesc,
        status: TimelineStepStatus.completed,
      ),
      AppTimelineStep(
        title: l10n.trackStepCancelled,
        time: _fmt(d.scheduledAt),
        description: l10n.trackStepCancelledDesc,
        status: TimelineStepStatus.cancelled,
      ),
    ];

    return [
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
            AppDetailRow(label: l10n.trackRequestedTime, value: _fmt(d.scheduledAt)),
            AppDetailRow(
              label: l10n.trackRequestStatus,
              value: l10n.statusCancelled,
              valueColor: AppColors.danger,
              showDivider: false,
            ),
          ],
        ),
      ),
      SizedBox(height: 16.h),

      FadeTransition(
        opacity: cardFade,
        child: ScaleTransition(
          scale: cardScale,
          child: _CancelledCard(
            isDark: isDark,
            textTheme: textTheme,
            colorScheme: colorScheme,
            l10n: l10n,
            reason: reason,
          ),
        ),
      ),
      SizedBox(height: 28.h),

      ea(
        3,
        AppGradientButton(
          label: l10n.trackRebookBtn,
          onTap: () => Navigator.of(context).pushNamed(
            AppRoutes.customerBookService,
            arguments: d.id,
          ),
          gradient: LinearGradient(colors: [AppColors.primary[60]!, AppColors.secondary[60]!]),
          shadowColor: AppColors.primary[60]!.withOpacity(0.30),
          height: 54,
          leadingIcon: Icon(Icons.refresh_rounded, size: 20.sp, color: Colors.white),
        ),
      ),
    ];
  }
}

// Mobile
class _CancelledMobileBody extends StatefulWidget {
  final String requestId;
  final String? cancelReason;
  const _CancelledMobileBody({required this.requestId, this.cancelReason});

  @override
  State<_CancelledMobileBody> createState() => _CancelledMobileBodyState();
}

class _CancelledMobileBodyState extends _CancelledBase<_CancelledMobileBody> {
  @override
  String get requestId => widget.requestId;
  @override
  String? get cancelReason => widget.cancelReason;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    return BlocConsumer<CustomerCubit, CustomerState>(
      listenWhen: (_, s) => s is CustomerRequestDetailsLoaded || s is CustomerError,
      listener: (_, state) {
        if (state is CustomerRequestDetailsLoaded) {
          setState(() => _details = state.request);
          entryCtrl.forward(from: 0);
          Future.delayed(const Duration(milliseconds: 300), () { if (mounted) cardCtrl.forward(from: 0); });
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
                          ? Center(child: Text(state.message))
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

// Tablet
class _CancelledTabletBody extends StatefulWidget {
  final String requestId;
  final String? cancelReason;
  const _CancelledTabletBody({required this.requestId, this.cancelReason});

  @override
  State<_CancelledTabletBody> createState() => _CancelledTabletBodyState();
}

class _CancelledTabletBodyState extends _CancelledBase<_CancelledTabletBody> {
  @override
  String get requestId => widget.requestId;
  @override
  String? get cancelReason => widget.cancelReason;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    return BlocConsumer<CustomerCubit, CustomerState>(
      listenWhen: (_, s) => s is CustomerRequestDetailsLoaded || s is CustomerError,
      listener: (_, state) {
        if (state is CustomerRequestDetailsLoaded) {
          setState(() => _details = state.request);
          entryCtrl.forward(from: 0);
          Future.delayed(const Duration(milliseconds: 300), () { if (mounted) cardCtrl.forward(from: 0); });
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
                          ? Center(child: Text(state.message))
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
// _CancelledCard
// ══════════════════════════════════════════════════════════════
class _CancelledCard extends StatelessWidget {
  final bool isDark;
  final TextTheme textTheme;
  final ColorScheme colorScheme;
  final AppLocalizations l10n;
  final String reason;

  const _CancelledCard({required this.isDark, required this.textTheme, required this.colorScheme, required this.l10n, required this.reason});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.danger.withOpacity(0.15)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDark ? 0.15 : 0.05), blurRadius: 12, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: [
          Container(
            width: 72.w, height: 72.w,
            decoration: BoxDecoration(
              color: AppColors.danger.withOpacity(0.10),
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.danger.withOpacity(0.20), width: 2),
            ),
            child: Icon(Icons.cancel_outlined, size: 34.sp, color: AppColors.danger),
          ),
          SizedBox(height: 14.h),
          Text(l10n.trackCancelledTitle, style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800, color: AppColors.danger), textAlign: TextAlign.center),
          SizedBox(height: 8.h),
          Text(l10n.trackCancelledBody, style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant, height: 1.6), textAlign: TextAlign.center),
          SizedBox(height: 16.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
            decoration: BoxDecoration(color: AppColors.danger.withOpacity(0.08), borderRadius: BorderRadius.circular(12.r)),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.info_outline_rounded, size: 16.sp, color: AppColors.danger),
                SizedBox(width: 8.w),
                Flexible(
                  child: Text(
                    '${l10n.trackCancelledReason}: $reason',
                    style: GoogleFonts.cairo(fontSize: 13.sp, fontWeight: FontWeight.w600, color: AppColors.danger),
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
