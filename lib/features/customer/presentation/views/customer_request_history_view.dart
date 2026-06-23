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
import '../../../../core/utils/widgets/app_detail_chip.dart';
import '../../../../core/utils/widgets/app_empty_states.dart';
import '../../../../core/utils/widgets/app_filter_chip.dart';
import '../../../../core/utils/widgets/app_rating_star.dart';
import '../../domain/entities/customer_request_summary_entity.dart';
import '../cubit/customer_cubit.dart';
import '../cubit/customer_state.dart';

// ══════════════════════════════════════════════════════════════
// Models
// ══════════════════════════════════════════════════════════════
enum RequestStatus { active, completed, pending, cancelled }

class RequestModel {
  final String id;
  final String serviceTitle;
  final RequestStatus status;
  final String date;
  final String time;
  final String location;
  // final String price;
  final String? handymanName;
  final String? handymanSpecialty;
  final List<Color>? handymanGradient;
  final bool hasRating;
  final double? rating;
  final String? cancelReason;

  const RequestModel({
    required this.id,
    required this.serviceTitle,
    required this.status,
    required this.date,
    required this.time,
    required this.location,
    // required this.price,
    this.handymanName,
    this.handymanSpecialty,
    this.handymanGradient,
    this.hasRating = false,
    this.rating,
    this.cancelReason,
  });
}

// ══════════════════════════════════════════════════════════════
// CustomerRequestHistoryView — layout router
// ══════════════════════════════════════════════════════════════
class CustomerRequestHistoryView extends StatelessWidget {
  const CustomerRequestHistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, c) => c.maxWidth >= 600
          ? const CustomerRequestHistoryTabletBody()
          : const CustomerRequestHistoryMobileBody(),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// Shared base — state, filter, navigation
// ══════════════════════════════════════════════════════════════
abstract class _HistoryBase<T extends StatefulWidget> extends State<T>
    with TickerProviderStateMixin {
  Color get accent => AppColors.primary[60]!;

  RequestStatus? activeFilter;

  // Page entry stagger
  late final AnimationController entryCtrl;
  late final List<Animation<double>> entryFade;
  late final List<Animation<Offset>> entrySlide;
  static const _n = 3;

  @override
  void initState() {
    super.initState();
    entryCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    entryFade = List.generate(_n, (i) {
      final s = (i * 0.20).clamp(0.0, 1.0);
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: entryCtrl,
          curve: Interval(s, (s + 0.50).clamp(0.0, 1.0), curve: Curves.easeOut),
        ),
      );
    });
    entrySlide = List.generate(_n, (i) {
      final s = (i * 0.20).clamp(0.0, 1.0);
      return Tween<Offset>(
        begin: const Offset(0, 0.12),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: entryCtrl,
          curve: Interval(
            s,
            (s + 0.55).clamp(0.0, 1.0),
            curve: Curves.easeOutCubic,
          ),
        ),
      );
    });
    entryCtrl.forward();

    context.read<CustomerCubit>().getRequests();
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

  // List<RequestModel> get filtered => activeFilter == null
  //     ? _kRequests
  //     : _kRequests.where((r) => r.status == activeFilter).toList();

  RequestStatus _mapStatus(String status,) {
    switch (
    status.toLowerCase()
    ) {

      case 'pending':
        return RequestStatus.pending;

      case 'completed':
        return RequestStatus.completed;

      case 'cancelled':
        return RequestStatus.cancelled;

      case 'active':
      case 'accepted':
      case 'inprogress':
        return RequestStatus.active;

      default:
        return RequestStatus.pending;
    }
  }

  List<RequestModel> mapRequests(List<CustomerRequestSummaryEntity> requests,) {
    return requests.map((r) {
      return RequestModel(
        id: r.id,
        serviceTitle: r.title,
        status: _mapStatus(r.status),
        date: DateFormat(
          'dd/MM/yyyy',
        ).format(r.scheduledAt),
        time: DateFormat(
          'hh:mm a',
        ).format(r.scheduledAt),
        location: r.location,
        handymanName: r.handymanName,
      );
    }).toList();
  }

  void navigateToTrack(RequestModel r) {
    final routes = {
      RequestStatus.pending: AppRoutes.customerTrackRequestPending,
      RequestStatus.active: AppRoutes.customerTrackRequestActive,
      RequestStatus.completed: AppRoutes.customerTrackRequestCompleted,
      RequestStatus.cancelled: AppRoutes.customerTrackRequestCancelled,
    };
    Navigator.of(context).pushNamed(routes[r.status]!, arguments: r.id);
  }

  Widget buildFilterRow(bool isDark, AppLocalizations l10n) {
    return SizedBox(
      height: 38.h,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          AppFilterChip(
            label: l10n.filterAll,
            isActive: activeFilter == null,
            isDark: isDark,
            onTap: () => setState(() => activeFilter = null),
          ),
          SizedBox(width: 8.w),
          AppFilterChip(
            label: l10n.filterPending,
            isActive: activeFilter == RequestStatus.pending,
            isDark: isDark,
            onTap: () => setState(() => activeFilter = RequestStatus.pending),
          ),
          SizedBox(width: 8.w),
          AppFilterChip(
            label: l10n.filterActive,
            isActive: activeFilter == RequestStatus.active,
            isDark: isDark,
            onTap: () => setState(() => activeFilter = RequestStatus.active),
          ),
          SizedBox(width: 8.w),
          AppFilterChip(
            label: l10n.filterCompleted,
            isActive: activeFilter == RequestStatus.completed,
            isDark: isDark,
            onTap: () => setState(() => activeFilter = RequestStatus.completed),
          ),
          SizedBox(width: 8.w),
          AppFilterChip(
            label: l10n.filterCancelled,
            isActive: activeFilter == RequestStatus.cancelled,
            isDark: isDark,
            onTap: () => setState(() => activeFilter = RequestStatus.cancelled),
          ),
        ],
      ),
    );
  }

  Widget buildCard(RequestModel r, int i, bool isDark, AppLocalizations l10n) {
    return _RequestCard(
      request: r,
      index: i,
      isDark: isDark,
      l10n: l10n,
      onTap: () => navigateToTrack(r),
    );
  }

  Widget buildEmpty(AppLocalizations l10n) => AppEmptyState(
    icon: Icons.description_outlined,
    title: l10n.requestHistoryEmptyTitle,
    subtitle: l10n.requestHistoryEmptySubtitle,
    color: accent,
  );
}

// ══════════════════════════════════════════════════════════════
// CustomerRequestHistoryMobileBody
// ══════════════════════════════════════════════════════════════
class CustomerRequestHistoryMobileBody extends StatefulWidget {
  const CustomerRequestHistoryMobileBody({super.key});

  @override
  State<CustomerRequestHistoryMobileBody> createState() =>
      _CustomerRequestHistoryMobileBodyState();
}

class _CustomerRequestHistoryMobileBodyState extends _HistoryBase<CustomerRequestHistoryMobileBody> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    return BlocBuilder<CustomerCubit, CustomerState>(
      builder: (context, state) {
        List<RequestModel> items = [];

        if (state is CustomerRequestsLoaded) {
          items = mapRequests(state.requests);

          if (activeFilter != null) {
            items = items.where((r) => r.status == activeFilter).toList();
          }
        }

        if (state is CustomerLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (state is CustomerError) {
          return Center(
            child: Text(state.message),
          );
        }

        return Scaffold(
          backgroundColor: Colors.transparent,
          body: AppMainBackground(
            child: CustomScrollView(
              slivers: [
                // Header
                SliverToBoxAdapter(
                  child: ea(
                    0,
                    _Header(
                      isDark: isDark,
                      l10n: l10n,
                      accent: accent,
                      filterRow: buildFilterRow(isDark, l10n),
                    ),
                  ),
                ),

                // List or empty
                if (items.isEmpty)
                  SliverFillRemaining(child: Center(child: buildEmpty(l10n)))
                else
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(
                      AppSpacing.xl.w,
                      AppSpacing.lg.h,
                      AppSpacing.xl.w,
                      0,
                    ),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                            (_, i) => buildCard(items[i], i, isDark, l10n),
                        childCount: items.length,
                      ),
                    ),
                  ),

                SliverToBoxAdapter(
                  child: SizedBox(
                    height: MediaQuery.of(context).padding.bottom + 100.h,
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
// CustomerRequestHistoryTabletBody — filter sidebar + list
// ══════════════════════════════════════════════════════════════
class CustomerRequestHistoryTabletBody extends StatefulWidget {
  const CustomerRequestHistoryTabletBody({super.key});

  @override
  State<CustomerRequestHistoryTabletBody> createState() =>
      _CustomerRequestHistoryTabletBodyState();
}

class _CustomerRequestHistoryTabletBodyState
    extends _HistoryBase<CustomerRequestHistoryTabletBody> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    return BlocBuilder<CustomerCubit, CustomerState>(
      builder: (context, state) {
        List<RequestModel> items = [];

        if (state is CustomerRequestsLoaded) {
          items = mapRequests(state.requests);

          if (activeFilter != null) {
            items = items.where((r) => r.status == activeFilter).toList();
          }
        }

        if (state is CustomerLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (state is CustomerError) {
          return Center(
            child: Text(state.message),
          );
        }

        return Scaffold(
          backgroundColor: Colors.transparent,
          body: AppMainBackground(
            child: Column(
              children: [
                // Full-width header
                ea(
                  0,
                  _Header(
                    isDark: isDark,
                    l10n: l10n,
                    accent: accent,
                    filterRow: buildFilterRow(isDark, l10n),
                  ),
                ),

                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Left: vertical filter panel (26%)
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.26,
                        child: _SideFilterPanel(
                          isDark: isDark,
                          l10n: l10n,
                          accentColor: accent,
                          activeFilter: activeFilter,
                          onChanged: (f) => setState(() => activeFilter = f),
                        ),
                      ),

                      VerticalDivider(width: 1, color: accent.withOpacity(0.08)),

                      // Right: cards
                      Expanded(
                        child: items.isEmpty
                            ? Center(child: buildEmpty(l10n))
                            : ListView.builder(
                          padding: EdgeInsets.fromLTRB(
                            AppSpacing.xl.w,
                            AppSpacing.lg.h,
                            AppSpacing.xl.w,
                            MediaQuery.of(context).padding.bottom + 100.h,
                          ),
                          itemCount: items.length,
                          itemBuilder: (_, i) =>
                              buildCard(items[i], i, isDark, l10n),
                        ),
                      ),
                    ],
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
// _Header
// ══════════════════════════════════════════════════════════════
class _Header extends StatelessWidget {
  final bool isDark;
  final AppLocalizations l10n;
  final Color accent;
  final Widget filterRow;

  const _Header({
    required this.isDark,
    required this.l10n,
    required this.accent,
    required this.filterRow,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.xl.w,
        MediaQuery.of(context).padding.top + AppSpacing.md.h,
        AppSpacing.xl.w,
        AppSpacing.lg.h,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkBgSecondary : Colors.white,
        border: Border(bottom: BorderSide(color: accent.withOpacity(0.08))),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.requestHistoryTitle,
            style: textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 14.h),
          filterRow,
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// _SideFilterPanel — tablet left panel
// ══════════════════════════════════════════════════════════════
class _SideFilterPanel extends StatefulWidget {
  final bool isDark;
  final AppLocalizations l10n;
  final Color accentColor;
  final RequestStatus? activeFilter;
  final ValueChanged<RequestStatus?> onChanged;

  const _SideFilterPanel({
    required this.isDark,
    required this.l10n,
    required this.accentColor,
    required this.activeFilter,
    required this.onChanged,
  });

  @override
  State<_SideFilterPanel> createState() => _SideFilterPanelState();
}

class _SideFilterPanelState extends State<_SideFilterPanel>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final List<Animation<double>> _fades;
  late final List<Animation<Offset>> _slides;
  static const _n = 6;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fades = List.generate(_n, (i) {
      final s = (i * 0.12).clamp(0.0, 1.0);
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _ctrl,
          curve: Interval(s, (s + 0.45).clamp(0.0, 1.0), curve: Curves.easeOut),
        ),
      );
    });
    _slides = List.generate(_n, (i) {
      final s = (i * 0.12).clamp(0.0, 1.0);
      return Tween<Offset>(
        begin: const Offset(-0.2, 0),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: _ctrl,
          curve: Interval(
            s,
            (s + 0.45).clamp(0.0, 1.0),
            curve: Curves.easeOutCubic,
          ),
        ),
      );
    });
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Widget _a(int i, Widget child) => FadeTransition(
    opacity: _fades[i.clamp(0, _n - 1)],
    child: SlideTransition(position: _slides[i.clamp(0, _n - 1)], child: child),
  );

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final l10n = widget.l10n;

    final filters = [
      (null, l10n.filterAll, Icons.all_inbox_rounded),
      (RequestStatus.pending, l10n.filterPending, Icons.schedule_rounded),
      (
        RequestStatus.active,
        l10n.filterActive,
        Icons.radio_button_checked_rounded,
      ),
      (
        RequestStatus.completed,
        l10n.filterCompleted,
        Icons.check_circle_rounded,
      ),
      (RequestStatus.cancelled, l10n.filterCancelled, Icons.cancel_rounded),
    ];

    return Container(
      color: widget.isDark
          ? AppColors.darkBgSecondary.withOpacity(0.60)
          : Colors.white.withOpacity(0.70),
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _a(
            0,
            Text(
              l10n.filterAll,
              style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
          ),
          SizedBox(height: 16.h),
          ...filters.asMap().entries.map((e) {
            final i = e.key + 1;
            final filter = e.value.$1;
            final label = e.value.$2;
            final icon = e.value.$3;
            final isActive = widget.activeFilter == filter;
            return _a(
              i,
              _FilterTile(
                label: label,
                icon: icon,
                isActive: isActive,
                accentColor: widget.accentColor,
                isDark: widget.isDark,
                onTap: () => widget.onChanged(filter),
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ── Filter tile ───────────────────────────────────────────────
class _FilterTile extends StatefulWidget {
  final String label;
  final IconData icon;
  final bool isActive;
  final Color accentColor;
  final bool isDark;
  final VoidCallback onTap;

  const _FilterTile({
    required this.label,
    required this.icon,
    required this.isActive,
    required this.accentColor,
    required this.isDark,
    required this.onTap,
  });

  @override
  State<_FilterTile> createState() => _FilterTileState();
}

class _FilterTileState extends State<_FilterTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 100),
  );
  late final Animation<double> _scale = Tween<double>(
    begin: 1.0,
    end: 0.96,
  ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
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
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: EdgeInsets.only(bottom: 8.h),
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: widget.isActive
                ? widget.accentColor.withOpacity(0.10)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: widget.isActive
                  ? widget.accentColor.withOpacity(0.30)
                  : Colors.transparent,
            ),
          ),
          child: Row(
            children: [
              Icon(
                widget.icon,
                size: 18.sp,
                color: widget.isActive
                    ? widget.accentColor
                    : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              SizedBox(width: 10.w),
              Text(
                widget.label,
                style: textTheme.bodyMedium?.copyWith(
                  fontWeight: widget.isActive
                      ? FontWeight.w700
                      : FontWeight.w500,
                  color: widget.isActive
                      ? widget.accentColor
                      : Theme.of(context).colorScheme.onSurfaceVariant,
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
// _RequestCard — stagger entry + press scale
// ══════════════════════════════════════════════════════════════
class _RequestCard extends StatefulWidget {
  final RequestModel request;
  final int index;
  final bool isDark;
  final AppLocalizations l10n;
  final VoidCallback onTap;

  const _RequestCard({
    required this.request,
    required this.index,
    required this.isDark,
    required this.l10n,
    required this.onTap,
  });

  @override
  State<_RequestCard> createState() => _RequestCardState();
}

class _RequestCardState extends State<_RequestCard> with TickerProviderStateMixin {
  // Entry: slide up + fade
  late final AnimationController _entryCtrl;
  late final Animation<double> _entryFade;
  late final Animation<Offset> _entrySlide;

  // Press scale
  late final AnimationController _pressCtrl;
  late final Animation<double> _pressScale;

  @override
  void initState() {
    super.initState();
    _entryCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _entryFade = CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOut);
    _entrySlide = Tween<Offset>(
      begin: const Offset(0, 0.18),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOutCubic));

    _pressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 110),
    );
    _pressScale = Tween<double>(
      begin: 1.0,
      end: 0.98,
    ).animate(CurvedAnimation(parent: _pressCtrl, curve: Curves.easeOut));

    Future.delayed(Duration(milliseconds: widget.index * 80), () {
      if (mounted) _entryCtrl.forward();
    });
  }

  @override
  void dispose() {
    _entryCtrl.dispose();
    _pressCtrl.dispose();
    super.dispose();
  }

  _StatusCfg get _cfg {
    switch (widget.request.status) {
      case RequestStatus.active:
        return _StatusCfg(
          label: widget.l10n.statusActive,
          icon: Icons.radio_button_checked_rounded,
          color: AppColors.primary[60]!,
        );
      case RequestStatus.completed:
        return _StatusCfg(
          label: widget.l10n.statusCompleted,
          icon: Icons.check_circle_rounded,
          color: AppColors.accent[60]!,
        );
      case RequestStatus.pending:
        return _StatusCfg(
          label: widget.l10n.statusPending,
          icon: Icons.schedule_rounded,
          color: AppColors.secondary[60]!,
        );
      case RequestStatus.cancelled:
        return _StatusCfg(
          label: widget.l10n.statusCancelled,
          icon: Icons.cancel_rounded,
          color: AppColors.danger,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final r = widget.request;
    final cfg = _cfg;

    return FadeTransition(
      opacity: _entryFade,
      child: SlideTransition(
        position: _entrySlide,
        child: GestureDetector(
          onTapDown: (_) {
            _pressCtrl.forward();
            HapticFeedback.selectionClick();
          },
          onTapUp: (_) {
            _pressCtrl.reverse();
            widget.onTap();
          },
          onTapCancel: () => _pressCtrl.reverse(),
          child: ScaleTransition(
            scale: _pressScale,
            child: Container(
              margin: EdgeInsets.only(bottom: 14.h),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : Colors.white,
                borderRadius: BorderRadius.circular(18.r),
                border: Border.all(
                  color: cfg.color.withOpacity(0.15),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: cfg.color.withOpacity(0.08),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top accent strip matching status color
                  Container(
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: cfg.color,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(18.r),
                        topRight: Radius.circular(18.r),
                      ),
                    ),
                  ),

                  Padding(
                    padding: EdgeInsets.all(AppSpacing.lg.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ID + status badge
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '#${r.id}',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            _StatusBadge(cfg: cfg),
                          ],
                        ),
                        SizedBox(height: 10.h),

                        // Title
                        Text(
                          r.serviceTitle,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        SizedBox(height: 12.h),

                        // Details grid — uses AppDetailChip
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                children: [
                                  AppDetailChip(
                                    icon: Icons.calendar_today_rounded,
                                    label: r.date,
                                    accentColor: cfg.color,
                                  ),
                                  SizedBox(height: 8.h),
                                  AppDetailChip(
                                    icon: Icons.location_on_rounded,
                                    label: r.location,
                                    accentColor: cfg.color,
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Expanded(
                              child: Column(
                                children: [
                                  AppDetailChip(
                                    icon: Icons.access_time_rounded,
                                    label: r.time,
                                    accentColor: cfg.color,
                                  ),
                                  SizedBox(height: 8.h),
                                  AppDetailChip(
                                    icon: Icons.payments_outlined,
                                    label: 'N/A',
                                    accentColor: cfg.color,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  Divider(height: 1, color: cfg.color.withOpacity(0.10)),

                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg.w,
                      vertical: 12.h,
                    ),
                    child: _buildBottom(r, cfg, context),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottom(RequestModel r, _StatusCfg cfg, BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    if (r.status == RequestStatus.cancelled) {
      return Row(
        children: [
          Icon(Icons.cancel_outlined, size: 16.sp, color: AppColors.danger),
          SizedBox(width: 6.w),
          Expanded(
            child: Text(
              r.cancelReason ?? widget.l10n.statusCancelled,
              style: GoogleFonts.cairo(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.danger,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      );
    }

    return Row(
      children: [
        // Avatar
        Container(
          width: 40.w,
          height: 40.w,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors:
                  r.handymanGradient ??
                  [AppColors.primary[40]!, AppColors.secondary[40]!],
            ),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Icon(Icons.person_rounded, size: 20.sp, color: Colors.white),
        ),
        SizedBox(width: 10.w),

        // Name + specialty
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                r.handymanName ?? '',
                style: textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                r.handymanSpecialty ?? '',
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),

        // Rating (completed) or action button
        if (r.status == RequestStatus.completed && r.hasRating) ...[
          AppRatingStars(
            rating: r.rating ?? 5.0,
            starSize: 14,
            showValue: false,
          ),
          SizedBox(width: 8.w),
        ],
        _ActionBtn(
          label: r.status == RequestStatus.completed
              ? widget.l10n.requestRateAction
              : widget.l10n.requestTrackAction,
          gradient: r.status == RequestStatus.completed
              ? [AppColors.accent[60]!, AppColors.accent[70]!]
              : [AppColors.primary[60]!, AppColors.secondary[60]!],
          glowColor: r.status == RequestStatus.completed
              ? AppColors.accent[60]!
              : AppColors.primary[60]!,
          onTap: widget.onTap,
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════
// _StatusBadge
// ══════════════════════════════════════════════════════════════
class _StatusBadge extends StatelessWidget {
  final _StatusCfg cfg;
  const _StatusBadge({required this.cfg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: cfg.color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(cfg.icon, size: 12.sp, color: cfg.color),
          SizedBox(width: 4.w),
          Text(
            cfg.label,
            style: GoogleFonts.cairo(
              fontSize: 11.sp,
              fontWeight: FontWeight.w700,
              color: cfg.color,
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// _ActionBtn — scale press gradient button
// ══════════════════════════════════════════════════════════════
class _ActionBtn extends StatefulWidget {
  final String label;
  final List<Color> gradient;
  final Color glowColor;
  final VoidCallback onTap;

  const _ActionBtn({
    required this.label,
    required this.gradient,
    required this.glowColor,
    required this.onTap,
  });

  @override
  State<_ActionBtn> createState() => _ActionBtnState();
}

class _ActionBtnState extends State<_ActionBtn>
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
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 7.h),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: widget.gradient),
            borderRadius: BorderRadius.circular(10.r),
            boxShadow: [
              BoxShadow(
                color: widget.glowColor.withOpacity(0.28),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            widget.label,
            style: GoogleFonts.cairo(
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusCfg {
  final String label;
  final IconData icon;
  final Color color;
  const _StatusCfg({
    required this.label,
    required this.icon,
    required this.color,
  });
}
