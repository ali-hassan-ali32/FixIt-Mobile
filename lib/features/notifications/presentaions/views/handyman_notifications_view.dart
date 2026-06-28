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
import '../../../../core/utils/widgets/app_main_background.dart';
import '../../../../core/utils/widgets/app_filter_chip.dart';
import '../../../../core/utils/widgets/app_notif_tile.dart';
import '../../../../core/utils/widgets/buttons/app_back_button.dart';
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
    case NotifType.welcome:         return Icons.verified_rounded;
    case NotifType.requestCreated:  return Icons.description_rounded;
    case NotifType.requestAccepted: return Icons.check_circle_rounded;
    case NotifType.requestRejected: return Icons.cancel_rounded;
    case NotifType.jobStarted:      return Icons.play_circle_rounded;
    case NotifType.jobCompleted:    return Icons.task_alt_rounded;
    case NotifType.reviewAdded:     return Icons.star_rounded;
  }
}

Color _colorFor(NotifType t) {
  switch (t) {
    case NotifType.general:         return AppColors.info;
    case NotifType.welcome:         return AppColors.info;
    case NotifType.requestCreated:  return const Color(0xFF9B59B6);
    case NotifType.requestAccepted: return const Color(0xFF4ECDC4);
    case NotifType.requestRejected: return AppColors.danger;
    case NotifType.jobStarted:      return const Color(0xFFFF6B35);
    case NotifType.jobCompleted:    return const Color(0xFF4ECDC4);
    case NotifType.reviewAdded:     return const Color(0xFFF7931E);
  }
}

// Filter category (for chip row)
enum _FilterCat {
  all,
  jobs,
  reviews,
  system,
}
// ══════════════════════════════════════════════════════════════
// HandymanNotificationsView — layout router
// ══════════════════════════════════════════════════════════════
class HandymanNotificationsView extends StatelessWidget {
  const HandymanNotificationsView({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => getIt<NotificationCubit>()..getNotifications(),
    child: LayoutBuilder(
      builder: (_, c) => c.maxWidth >= 600
          ? const _HandymanNotificationsTabletBody()
          : const _HandymanNotificationsMobileBody(),
    ),
  );
}

// ══════════════════════════════════════════════════════════════
// Shared base
// ══════════════════════════════════════════════════════════════
abstract class _NotificationsBase<T extends StatefulWidget> extends State<T>
    with TickerProviderStateMixin {
  Color get teal => AppColors.accent[60]!;

  _FilterCat activeFilter = _FilterCat.all;
  List<NotifModel> _models = [];

  // Entry animations
  late final AnimationController entryCtrl;
  late final List<Animation<double>> entryFade;
  late final List<Animation<Offset>> entrySlide;
  static const int _n = 4;

  @override
  void initState() {
    super.initState();
    entryCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    entryFade = List.generate(_n, (i) {
      final s = (i * 0.15).clamp(0.0, 1.0);
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: entryCtrl,
          curve: Interval(s, (s + 0.40).clamp(0.0, 1.0), curve: Curves.easeOut),
        ),
      );
    });
    entrySlide = List.generate(_n, (i) {
      final s = (i * 0.15).clamp(0.0, 1.0);
      return Tween<Offset>(
        begin: const Offset(0, 0.12),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: entryCtrl,
          curve: Interval(s, (s + 0.45).clamp(0.0, 1.0), curve: Curves.easeOutCubic),
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

  List<NotifModel> get filtered {
    switch (activeFilter) {
      case _FilterCat.all:
        return _models;

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

  void _onLoaded(List<NotificationEntity> entities) {
    setState(() => _models = entities.map(_toModel).toList());
    entryCtrl.forward(from: 0);
  }

  void _markAllRead(BuildContext ctx) {
    print('Mark All Pressed');
    HapticFeedback.lightImpact();
    ctx.read<NotificationCubit>().markAllNotificationsAsRead();
  }

  void _markRead(BuildContext ctx, String id) {
    ctx.read<NotificationCubit>().markNotificationAsRead(id);
  }

  void _delete(BuildContext ctx, String id) {
    ctx.read<NotificationCubit>().deleteNotification(id);
  }

  // ── Header ───────────────────────────────────────────────
  Widget buildHeader(
    BuildContext context,
    bool isDark,
    TextTheme textTheme,
    ColorScheme colorScheme,
    AppLocalizations l10n,
  ) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.xl.w,
        MediaQuery.of(context).padding.top + AppSpacing.md.h,
        AppSpacing.xl.w,
        AppSpacing.md.h,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkBgSecondary : Colors.white.withOpacity(0.95),
        border: Border(bottom: BorderSide(color: teal.withOpacity(0.1))),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          AppBackButton(isDark: isDark, tapColor: teal),
          SizedBox(width: 14.w),
          Expanded(
            child: Row(
              children: [
                Flexible(
                  child: Text(
                    l10n.notifHandymanTitle,
                    style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                if (unreadCount > 0) ...[
                  SizedBox(width: 8.w),
                  _AnimatedBadge(count: unreadCount, color: teal),
                ],
              ],
            ),
          ),
          if (unreadCount > 0)
            GestureDetector(
              onTap: () => _markAllRead(context),
              child: _MarkAllButton(
                label: l10n.notifMarkAllRead,
                color: teal,
                onTap: () => _markAllRead(context),
              ),
            ),
        ],
      ),
    );
  }

  // ── Filter row ───────────────────────────────────────────
  Widget buildFilterRow(bool isDark, AppLocalizations l10n) {
    final filters = [
      (_FilterCat.all,     l10n.filterAll),
      (_FilterCat.jobs,    l10n.jobsTitle),
      (_FilterCat.reviews, l10n.reviewsTitle),
      (_FilterCat.system,  l10n.notifFilterSystem),
    ];
    return Container(
      color: isDark ? AppColors.darkBgSecondary : Colors.white,
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
            onTap: () => setState(() => activeFilter = filters[i].$1),
            isDark: isDark,
            activeColor: teal,
            activeColorEnd: teal,
          ),
        ),
      ),
    );
  }

  // ── Empty state ──────────────────────────────────────────
  Widget buildEmptyState(TextTheme textTheme, ColorScheme colorScheme, AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80.w,
            height: 80.h,
            decoration: BoxDecoration(color: teal.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(Icons.notifications_off_outlined, size: 36.sp, color: teal),
          ),
          SizedBox(height: 16.h),
          Text(l10n.notifEmptyTitle, style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
          SizedBox(height: 8.h),
          Text(l10n.notifEmptySubtitle, style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  // ── Notification list ────────────────────────────────────
  Widget buildNotificationList(BuildContext ctx, bool isDark, List<NotifModel> items) {
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
        child: _AnimatedNotifTile(
          index: i,
          notif: items[i],
          isDark: isDark,
          activeColor: teal,
          onTap: () => _markRead(ctx, items[i].id),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// Mobile Body
// ══════════════════════════════════════════════════════════════
class _HandymanNotificationsMobileBody extends StatefulWidget {
  const _HandymanNotificationsMobileBody();
  @override
  State<_HandymanNotificationsMobileBody> createState() => _HandymanNotificationsMobileBodyState();
}

class _HandymanNotificationsMobileBodyState
    extends _NotificationsBase<_HandymanNotificationsMobileBody> {
  @override
  Widget build(BuildContext context) {
    final isDark      = Theme.of(context).brightness == Brightness.dark;
    final textTheme   = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final l10n        = AppLocalizations.of(context)!;

    return BlocListener<NotificationCubit, NotificationState>(
      listener: (ctx, state) {
        if (state is NotificationLoaded) _onLoaded(state.notifications);
      },
      child: Scaffold(
        backgroundColor: isDark ? AppColors.darkBgPrimary : teal.withOpacity(0.03),
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
              final items = filtered;
              return Column(
                children: [
                  ea(0, buildHeader(context, isDark, textTheme, colorScheme, l10n)),
                  ea(1, buildFilterRow(isDark, l10n)),
                  Expanded(
                    child: items.isEmpty
                        ? ea(2, buildEmptyState(textTheme, colorScheme, l10n))
                        : ea(3, buildNotificationList(ctx, isDark, items)),
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
// Tablet Body — two-column layout
// ══════════════════════════════════════════════════════════════
class _HandymanNotificationsTabletBody extends StatefulWidget {
  const _HandymanNotificationsTabletBody();
  @override
  State<_HandymanNotificationsTabletBody> createState() => _HandymanNotificationsTabletBodyState();
}

class _HandymanNotificationsTabletBodyState
    extends _NotificationsBase<_HandymanNotificationsTabletBody> {
  @override
  Widget build(BuildContext context) {
    final isDark      = Theme.of(context).brightness == Brightness.dark;
    final textTheme   = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final l10n        = AppLocalizations.of(context)!;

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
              final items = filtered;
              return SafeArea(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Left panel (38%) ───────────────────────────
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.38,
                      child: Column(
                        children: [
                          ea(0, _buildTabletHeaderCard(context, isDark, textTheme, colorScheme, l10n)),
                          ea(1, buildFilterRow(isDark, l10n)),
                        ],
                      ),
                    ),
                    VerticalDivider(width: 1, color: teal.withOpacity(0.10)),
                    // ── Right panel (62%) ──────────────────────────
                    Expanded(
                      child: items.isEmpty
                          ? ea(2, buildEmptyState(textTheme, colorScheme, l10n))
                          : ea(3, buildNotificationList(ctx, isDark, items)),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTabletHeaderCard(
    BuildContext context,
    bool isDark,
    TextTheme textTheme,
    ColorScheme colorScheme,
    AppLocalizations l10n,
  ) {
    return Container(
      margin: EdgeInsets.all(AppSpacing.xl.w),
      padding: EdgeInsets.all(AppSpacing.xl.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [teal, AppColors.accent[70] ?? const Color(0xFF44A3A0)],
        ),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [BoxShadow(color: teal.withOpacity(0.25), blurRadius: 20, offset: const Offset(0, 6))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AppBackButton(isDark: false, tapColor: Colors.white),
              SizedBox(width: 14.w),
              Expanded(
                child: Text(
                  l10n.notifHandymanTitle,
                  style: textTheme.headlineSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.w800),
                ),
              ),
              if (unreadCount > 0) _AnimatedBadge(count: unreadCount, color: Colors.white),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(child: _StatItem(value: '${_models.length}', label: l10n.filterAll, isDark: false)),
              Container(width: 1, height: 40.h, color: Colors.white.withOpacity(0.25)),
              Expanded(child: _StatItem(value: '$unreadCount', label: 'New', isDark: false)),
            ],
          ),
          SizedBox(height: 16.h),
          if (unreadCount > 0)
            GestureDetector(
              onTap: () => _markAllRead(context),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 12.h),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Center(
                  child: Text(
                    l10n.notifMarkAllRead,
                    style: GoogleFonts.cairo(fontSize: 13.sp, fontWeight: FontWeight.w700, color: Colors.white),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// Reusable Widgets
// ══════════════════════════════════════════════════════════════

class _AnimatedBadge extends StatefulWidget {
  final int count;
  final Color color;
  const _AnimatedBadge({required this.count, required this.color});
  @override
  State<_AnimatedBadge> createState() => _AnimatedBadgeState();
}

class _AnimatedBadgeState extends State<_AnimatedBadge> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this, duration: const Duration(milliseconds: 1500),
  )..repeat(reverse: true);
  late final Animation<double> _scale = Tween<double>(begin: 1.0, end: 1.1)
      .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => ScaleTransition(
    scale: _scale,
    child: Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
      decoration: BoxDecoration(color: widget.color, borderRadius: BorderRadius.circular(10.r)),
      child: Text('${widget.count}', style: GoogleFonts.cairo(fontSize: 11.sp, fontWeight: FontWeight.w700, color: Colors.white)),
    ),
  );
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

class _StatItem extends StatelessWidget {
  final String value, label;
  final bool isDark;
  const _StatItem({required this.value, required this.label, required this.isDark});

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(value, style: GoogleFonts.cairo(fontSize: 22.sp, fontWeight: FontWeight.w800, color: Colors.white)),
      SizedBox(height: 2.h),
      Text(label, style: GoogleFonts.cairo(fontSize: 11.sp, color: Colors.white.withOpacity(0.85))),
    ],
  );
}

class _AnimatedNotifTile extends StatefulWidget {
  final int index;
  final NotifModel notif;
  final bool isDark;
  final Color activeColor;
  final VoidCallback onTap;

  const _AnimatedNotifTile({
    required this.index,
    required this.notif,
    required this.isDark,
    required this.activeColor,
    required this.onTap,
  });

  @override
  State<_AnimatedNotifTile> createState() => _AnimatedNotifTileState();
}

class _AnimatedNotifTileState extends State<_AnimatedNotifTile> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _opacity;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _opacity = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _slide = Tween<Offset>(begin: const Offset(0.15, 0), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    Future.delayed(Duration(milliseconds: 100 + widget.index * 60), () { if (mounted) _ctrl.forward(); });
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => FadeTransition(
    opacity: _opacity,
    child: SlideTransition(
      position: _slide,
      child: AppNotifTile(notif: widget.notif, index: widget.index, isDark: widget.isDark, activeColor: widget.activeColor, onTap: widget.onTap),
    ),
  );
}
