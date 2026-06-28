import 'package:fix_it/core/utils/widgets/app_main_background.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../config/di/di.dart';
import '../../../../core/l10n/translation/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/utils/widgets/app_empty_states.dart';
import '../../../../core/utils/widgets/app_filter_chip.dart';
import '../../../../core/utils/widgets/app_notif_tile.dart';
import '../../../../core/utils/widgets/app_page_header.dart';
import '../../domain/entities/notification_entity.dart';
import '../cubit/notification_cubit.dart';
import '../cubit/notification_state.dart';

// ── Helper: entity → display model ────────────────────────────
NotifModel _toModel(NotificationEntity e) {
  final type = NotifType.fromInt(e.type);
  return NotifModel(
    id:        e.id,
    title:     e.title,
    body:      e.message,
    time:      DateFormat('dd/MM/yyyy HH:mm').format(e.createdAt),
    type:      type,
    icon:      _iconFor(type),
    iconColor: _colorFor(type),
    isRead:    e.isRead,
  );
}

IconData _iconFor(NotifType t) {
  switch (t) {
    case NotifType.general:         return Icons.notifications_rounded;
    case NotifType.welcome:         return Icons.waving_hand_rounded;
    case NotifType.requestCreated:  return Icons.description_rounded;
    case NotifType.requestAccepted: return Icons.check_circle_rounded;
    case NotifType.requestRejected: return Icons.cancel_rounded;
    case NotifType.jobStarted:      return Icons.directions_run_rounded;
    case NotifType.jobCompleted:    return Icons.task_alt_rounded;
    case NotifType.reviewAdded:     return Icons.star_rounded;
  }
}

Color _colorFor(NotifType t) {
  switch (t) {
    case NotifType.general:         return AppColors.info;
    case NotifType.welcome:         return AppColors.info;
    case NotifType.requestCreated:  return const Color(0xFF9B59B6);
    case NotifType.requestAccepted: return AppColors.accent[60]!;
    case NotifType.requestRejected: return AppColors.danger;
    case NotifType.jobStarted:      return AppColors.primary[60]!;
    case NotifType.jobCompleted:    return AppColors.accent[60]!;
    case NotifType.reviewAdded:     return AppColors.secondary[60]!;
  }
}

// Filter category
enum _FilterCat { all, jobs, reviews, system }

// ══════════════════════════════════════════════════════════════
// CustomerNotificationsView — layout router
// ══════════════════════════════════════════════════════════════
class CustomerNotificationsView extends StatelessWidget {
  const CustomerNotificationsView({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => getIt<NotificationCubit>()..getNotifications(),
    child: LayoutBuilder(
      builder: (_, c) => c.maxWidth >= 600
          ? const CustomerNotificationsTabletBody()
          : const CustomerNotificationsMobileBody(),
    ),
  );
}

// ══════════════════════════════════════════════════════════════
// Shared base
// ══════════════════════════════════════════════════════════════
abstract class _NotifsBase<T extends StatefulWidget> extends State<T>
    with TickerProviderStateMixin {
  Color get accent => AppColors.primary[60]!;

  _FilterCat activeFilter = _FilterCat.all;
  List<NotifModel> _models = [];

  late final AnimationController markAllCtrl;
  late final Animation<double> markAllScale;

  @override
  void initState() {
    super.initState();
    markAllCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 120));
    markAllScale = Tween<double>(begin: 1.0, end: 0.93)
        .animate(CurvedAnimation(parent: markAllCtrl, curve: Curves.easeOut));
  }

  @override
  void dispose() { markAllCtrl.dispose(); super.dispose(); }

  void _onLoaded(List<NotificationEntity> entities) {
    setState(() => _models = entities.map(_toModel).toList());
  }

  List<NotifModel> get filtered {
    switch (activeFilter) {
      case _FilterCat.all:     return _models;
      case _FilterCat.jobs:
        return _models.where((n) =>
        n.type == NotifType.requestCreated ||
            n.type == NotifType.requestAccepted ||
            n.type == NotifType.requestRejected ||
            n.type == NotifType.jobStarted ||
            n.type == NotifType.jobCompleted).toList();

      case _FilterCat.reviews:
        return _models
            .where((n) => n.type == NotifType.reviewAdded)
            .toList();

      case _FilterCat.system:
        return _models.where((n) =>
        n.type == NotifType.general ||
            n.type == NotifType.welcome).toList();
    }
  }

  int get unreadCount => _models.where((n) => !n.isRead).length;

  void _markAllRead(BuildContext ctx) {
    markAllCtrl.forward().then((_) => markAllCtrl.reverse());
    HapticFeedback.lightImpact();
    ctx.read<NotificationCubit>().markAllNotificationsAsRead();
  }

  void _markRead(BuildContext ctx, String id) {
    ctx.read<NotificationCubit>().markNotificationAsRead(id);
  }

  void _delete(BuildContext ctx, String id) {
    ctx.read<NotificationCubit>().deleteNotification(id);
  }

  Widget buildFilterRow(bool isDark, AppLocalizations l10n) {
    final filters = [
      (_FilterCat.all,     l10n.filterAll),
      (_FilterCat.jobs,    l10n.jobsTitle),
      (_FilterCat.reviews, l10n.reviewsTitle),
      (_FilterCat.system,  l10n.notifFilterSystem),
    ];
    return Container(
      color: Colors.transparent,
      padding: EdgeInsets.fromLTRB(AppSpacing.xl.w, 12.h, AppSpacing.xl.w, 12.h),
      child: SizedBox(
        height: 36.h,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: filters.length,
          separatorBuilder: (_, __) => SizedBox(width: 8.w),
          itemBuilder: (_, i) => AppFilterChip(
            label: filters[i].$2,
            isActive: activeFilter == filters[i].$1,
            isDark: isDark,
            onTap: () => setState(() => activeFilter = filters[i].$1),
          ),
        ),
      ),
    );
  }

  Widget buildList(BuildContext ctx, bool isDark) {
    final items = filtered;
    if (items.isEmpty) return buildEmpty();
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (_, i) => Dismissible(
        key: ValueKey(items[i].id),
        direction: DismissDirection.endToStart,
        onDismissed: (_) {
          setState(() {
            _models.removeWhere((e) => e.id == items[i].id);
          });

          _delete(ctx, items[i].id);
        },
        background: Container(
          alignment: Alignment.centerRight,
          padding: EdgeInsets.only(right: 20.w),
          color: AppColors.danger,
          child: Icon(Icons.delete_outline_rounded, color: Colors.white, size: 24.sp),
        ),
        child: AppNotifTile(
          notif: items[i],
          index: i,
          isDark: isDark,
          activeColor: accent,
          onTap: () => _markRead(ctx, items[i].id),
        ),
      ),
    );
  }

  Widget buildEmpty() {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: AppEmptyState(
        icon: Icons.notifications_off_outlined,
        title: l10n.notificationsEmptyTitle,
        subtitle: l10n.notificationsEmptySubtitle,
        color: accent,
      ),
    );
  }

  Widget buildUnreadBadge() {
    if (unreadCount == 0) return const SizedBox.shrink();
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [accent, AppColors.secondary[60]!]),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Text('$unreadCount', style: GoogleFonts.cairo(fontSize: 11.sp, fontWeight: FontWeight.w700, color: Colors.white)),
    );
  }

}

// ══════════════════════════════════════════════════════════════
// CustomerNotificationsMobileBody
// ══════════════════════════════════════════════════════════════
class CustomerNotificationsMobileBody extends StatefulWidget {
  const CustomerNotificationsMobileBody({super.key});
  @override
  State<CustomerNotificationsMobileBody> createState() => _CustomerNotificationsMobileBodyState();
}

class _CustomerNotificationsMobileBodyState
    extends _NotifsBase<CustomerNotificationsMobileBody> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n   = AppLocalizations.of(context)!;

    return BlocListener<NotificationCubit, NotificationState>(
      listener: (_, state) {
        if (state is NotificationLoaded) _onLoaded(state.notifications);
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: AppMainBackground(
          child: BlocBuilder<NotificationCubit, NotificationState>(
            buildWhen: (_, s) => s is NotificationLoading || s is NotificationLoaded || s is NotificationError,
            builder: (ctx, state) {
              if (state is NotificationLoading && _models.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state is NotificationError && _models.isEmpty) {
                return Center(child: Text(state.message));
              }
              return Column(
                children: [
                  AppPageHeader(
                    isDark: isDark,
                    title: l10n.notificationsTitle,
                    accentColor: accent,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        buildUnreadBadge(),
                        if (unreadCount > 0) ...[
                          SizedBox(width: 10.w),
                          _MarkAllButton(
                            label: l10n.notificationsMarkAll,
                            color: accent,
                            onTap: () => _markAllRead(ctx),
                          ),
                        ],
                      ],
                    ),
                  ),
                  buildFilterRow(isDark, l10n),
                  Expanded(child: buildList(ctx, isDark)),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// CustomerNotificationsTabletBody
// Left: filter panel (30%) | Right: notification list (70%)
// ══════════════════════════════════════════════════════════════
class CustomerNotificationsTabletBody extends StatefulWidget {
  const CustomerNotificationsTabletBody({super.key});
  @override
  State<CustomerNotificationsTabletBody> createState() => _CustomerNotificationsTabletBodyState();
}

class _CustomerNotificationsTabletBodyState
    extends _NotifsBase<CustomerNotificationsTabletBody> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n   = AppLocalizations.of(context)!;

    return BlocListener<NotificationCubit, NotificationState>(
      listener: (_, state) {
        if (state is NotificationLoaded) _onLoaded(state.notifications);
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: AppMainBackground(
          child: BlocBuilder<NotificationCubit, NotificationState>(
            buildWhen: (_, s) => s is NotificationLoading || s is NotificationLoaded || s is NotificationError,
            builder: (ctx, state) {
              if (state is NotificationLoading && _models.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state is NotificationError && _models.isEmpty) {
                return Center(child: Text(state.message));
              }
              return Column(
                children: [
                  AppPageHeader(
                    isDark: isDark,
                    title: l10n.notificationsTitle,
                    accentColor: accent,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        buildUnreadBadge(),
                        SizedBox(width: 10.w),
                        _MarkAllButton(
                          label: l10n.notificationsMarkAll,
                          color: accent,
                          onTap: () => _markAllRead(ctx),
                        )
                      ],
                    ),
                  ),
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.28,
                          child: _FilterPanel(
                            isDark: isDark,
                            l10n: l10n,
                            accentColor: accent,
                            activeFilter: activeFilter,
                            unreadCount: unreadCount,
                            onFilterChanged: (f) => setState(() => activeFilter = f ?? _FilterCat.all),
                          ),
                        ),
                        VerticalDivider(width: 1, color: accent.withOpacity(0.08)),
                        Expanded(child: buildList(ctx, isDark)),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// _FilterPanel — tablet left panel
// ══════════════════════════════════════════════════════════════
class _FilterPanel extends StatefulWidget {
  final bool isDark;
  final AppLocalizations l10n;
  final Color accentColor;
  final _FilterCat activeFilter;
  final int unreadCount;
  final ValueChanged<_FilterCat?> onFilterChanged;

  const _FilterPanel({
    required this.isDark,
    required this.l10n,
    required this.accentColor,
    required this.activeFilter,
    required this.unreadCount,
    required this.onFilterChanged,
  });

  @override
  State<_FilterPanel> createState() => _FilterPanelState();
}

class _FilterPanelState extends State<_FilterPanel> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final List<Animation<double>> _fadeAnims;
  late final List<Animation<Offset>> _slideAnims;
  static const _n = 5;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _fadeAnims = List.generate(_n, (i) {
      final s = (i * 0.14).clamp(0.0, 1.0);
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _ctrl, curve: Interval(s, (s + 0.45).clamp(0.0, 1.0), curve: Curves.easeOut)),
      );
    });
    _slideAnims = List.generate(_n, (i) {
      final s = (i * 0.14).clamp(0.0, 1.0);
      return Tween<Offset>(begin: const Offset(-0.2, 0), end: Offset.zero).animate(
        CurvedAnimation(parent: _ctrl, curve: Interval(s, (s + 0.45).clamp(0.0, 1.0), curve: Curves.easeOutCubic)),
      );
    });
    _ctrl.forward();
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  Widget _item(int i, Widget child) => FadeTransition(
    opacity: _fadeAnims[i],
    child: SlideTransition(position: _slideAnims[i], child: child),
  );

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final l10n = widget.l10n;

    final filters = [
      (null as _FilterCat?,              l10n.filterAll,         Icons.all_inbox_rounded),
      (_FilterCat.jobs,                  l10n.notifFilterBooking, Icons.calendar_today_rounded),
      (_FilterCat.reviews,               l10n.notifFilterPayment, Icons.star_outline_rounded),
      (_FilterCat.system,                l10n.notifFilterSystem,  Icons.info_outline_rounded),
    ];

    return Container(
      color: widget.isDark ? AppColors.darkBgSecondary.withOpacity(0.6) : Colors.white.withOpacity(0.70),
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _item(0, Text(l10n.filterAll, style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w800))),
          SizedBox(height: 16.h),
          ...filters.asMap().entries.map((e) {
            final idx    = e.key + 1;
            final filter = e.value.$1;
            final label  = e.value.$2;
            final icon   = e.value.$3;
            final isActive = widget.activeFilter == (filter ?? _FilterCat.all) && (filter == null ? widget.activeFilter == _FilterCat.all : true);

            return _item(
              idx,
              _FilterTile(
                label: label,
                icon: icon,
                isActive: filter == null ? widget.activeFilter == _FilterCat.all : widget.activeFilter == filter,
                accentColor: widget.accentColor,
                isDark: widget.isDark,
                onTap: () => widget.onFilterChanged(filter),
              ),
            );
          }),
        ],
      ),
    );
  }
}

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

class _MarkAllButton extends StatefulWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _MarkAllButton({
    super.key,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  State<_MarkAllButton> createState() => _MarkAllButtonState();
}

class _MarkAllButtonState extends State<_MarkAllButton> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 100));
  late final Animation<double> _scale = Tween<double>(begin: 1.0, end: 0.95)
      .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: widget.onTap,
    onTapDown: (_) {
      _ctrl.forward();
      HapticFeedback.selectionClick();
    },
    onTapUp: (_) => _ctrl.reverse(),
    onTapCancel: () => _ctrl.reverse(),
    child: ScaleTransition(
      scale: _scale,
      child: Text(
        widget.label,
        style: GoogleFonts.cairo(
          fontSize: 13.sp,
          fontWeight: FontWeight.w700,
          color: widget.color,
        ),
      ),
    ),
  );
}
////////////////////////////////////////////

class _FilterTileState extends State<_FilterTile> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 100));
  late final Animation<double> _scale = Tween<double>(begin: 1.0, end: 0.96)
      .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return GestureDetector(
      onTapDown: (_) { _ctrl.forward(); HapticFeedback.selectionClick(); },
      onTapUp: (_) { _ctrl.reverse(); widget.onTap(); },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: EdgeInsets.only(bottom: 8.h),
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: widget.isActive ? widget.accentColor.withOpacity(0.10) : Colors.transparent,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: widget.isActive ? widget.accentColor.withOpacity(0.30) : Colors.transparent,
            ),
          ),
          child: Row(
            children: [
              Icon(widget.icon, size: 18.sp, color: widget.isActive ? widget.accentColor : Theme.of(context).colorScheme.onSurfaceVariant),
              SizedBox(width: 10.w),
              Text(
                widget.label,
                style: textTheme.bodyMedium?.copyWith(
                  fontWeight: widget.isActive ? FontWeight.w700 : FontWeight.w500,
                  color: widget.isActive ? widget.accentColor : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
