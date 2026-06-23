import 'package:fix_it/core/utils/widgets/app_main_background.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/l10n/translation/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/utils/widgets/app_empty_states.dart';
import '../../../../core/utils/widgets/app_filter_chip.dart';
import '../../../../core/utils/widgets/app_notif_tile.dart';
import '../../../../core/utils/widgets/app_page_header.dart';

// ── Mock data ─────────────────────────────────────────────────
List<NotifModel> _buildMockNotifications(AppLocalizations l10n) => [
  NotifModel(
    id: '1',
    title: l10n.notifRequestAcceptedTitle,
    body: l10n.notifRequestAcceptedBody,
    time: l10n.notifTime5Min,
    type: NotifType.booking,
    icon: Icons.check_circle_rounded,
    iconColor: AppColors.accent[60]!,
    isRead: false,
  ),
  NotifModel(
    id: '2',
    title: l10n.notifTechOnWayTitle,
    body: l10n.notifTechOnWayBody,
    time: l10n.notifTime10Min,
    type: NotifType.payment,
    icon: Icons.directions_run_rounded,
    iconColor: AppColors.primary[60]!,
    isRead: false,
  ),
  NotifModel(
    id: '3',
    title: l10n.notifRateUsTitle,
    body: l10n.notifRateUsBody,
    time: l10n.notifTime2Hours,
    type: NotifType.booking,
    icon: Icons.star_rounded,
    iconColor: AppColors.secondary[60]!,
  ),
  NotifModel(
    id: '4',
    title: l10n.notifCompletedTitle,
    body: l10n.notifCompletedBody,
    time: l10n.notifTime3Hours,
    type: NotifType.booking,
    icon: Icons.task_alt_rounded,
    iconColor: AppColors.accent[60]!,
  ),
  NotifModel(
    id: '5',
    title: l10n.notifCancelledTitle,
    body: l10n.notifCancelledBody,
    time: l10n.notifTime4Hours,
    type: NotifType.booking,
    icon: Icons.cancel_rounded,
    iconColor: AppColors.danger,
  ),
  NotifModel(
    id: '6',
    title: l10n.notifNewRequestTitle,
    body: l10n.notifNewRequestBody,
    time: l10n.notifTimeYesterday,
    type: NotifType.booking,
    icon: Icons.description_rounded,
    iconColor: const Color(0xFF9B59B6),
  ),
  NotifModel(
    id: '7',
    title: l10n.notifWelcomeTitle,
    body: l10n.notifWelcomeBody,
    time: l10n.notifTime3Days,
    type: NotifType.system,
    icon: Icons.waving_hand_rounded,
    iconColor: AppColors.info,
  ),
];

// ══════════════════════════════════════════════════════════════
// CustomerNotificationsView — layout router
// ══════════════════════════════════════════════════════════════
class CustomerNotificationsView extends StatelessWidget {
  const CustomerNotificationsView({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, c) => c.maxWidth >= 600
          ? const CustomerNotificationsTabletBody()
          : const CustomerNotificationsMobileBody(),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// Shared base — state + logic, zero duplication
// ══════════════════════════════════════════════════════════════
abstract class _NotifsBase<T extends StatefulWidget> extends State<T>
    with TickerProviderStateMixin {
  // accent = orange (customer)
  Color get accent => AppColors.primary[60]!;

  NotifType? activeFilter;
  List<NotifModel>? notifications;

  // Mark-all button pop animation
  late final AnimationController markAllCtrl;
  late final Animation<double> markAllScale;

  @override
  void initState() {
    super.initState();
    markAllCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    markAllScale = Tween<double>(
      begin: 1.0,
      end: 0.93,
    ).animate(CurvedAnimation(parent: markAllCtrl, curve: Curves.easeOut));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    notifications ??= _buildMockNotifications(AppLocalizations.of(context)!);
  }

  @override
  void dispose() {
    markAllCtrl.dispose();
    super.dispose();
  }

  List<NotifModel> get filtered => activeFilter == null
      ? notifications!
      : notifications!.where((n) => n.type == activeFilter).toList();

  int get unreadCount => notifications!.where((n) => !n.isRead).length;

  void markAllRead() {
    markAllCtrl.forward().then((_) => markAllCtrl.reverse());
    HapticFeedback.lightImpact();
    setState(() {
      for (final n in notifications!) {
        n.isRead = true;
      }
    });
  }

  void markRead(String id) {
    setState(() => notifications!.firstWhere((n) => n.id == id).isRead = true);
  }

  // ── Shared widgets ────────────────────────────────────────
  Widget buildFilterRow(bool isDark, AppLocalizations l10n) {
    return Container(
      color: Colors.transparent,
      padding: EdgeInsets.fromLTRB(
        AppSpacing.xl.w,
        12.h,
        AppSpacing.xl.w,
        12.h,
      ),
      child: SizedBox(
        height: 36.h,
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
              label: l10n.notifFilterBooking,
              isActive: activeFilter == NotifType.booking,
              isDark: isDark,
              onTap: () => setState(() => activeFilter = NotifType.booking),
            ),
            SizedBox(width: 8.w),
            AppFilterChip(
              label: l10n.notifFilterPayment,
              isActive: activeFilter == NotifType.payment,
              isDark: isDark,
              onTap: () => setState(() => activeFilter = NotifType.payment),
            ),
            SizedBox(width: 8.w),
            AppFilterChip(
              label: l10n.notifFilterSystem,
              isActive: activeFilter == NotifType.system,
              isDark: isDark,
              onTap: () => setState(() => activeFilter = NotifType.system),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildList(bool isDark) {
    final items = filtered;
    if (items.isEmpty) return buildEmpty();
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (_, i) => AppNotifTile(
        notif: items[i],
        index: i,
        isDark: isDark,
        activeColor: accent,
        onTap: () => markRead(items[i].id),
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
      child: Text(
        '$unreadCount',
        style: GoogleFonts.cairo(
          fontSize: 11.sp,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget buildMarkAllBtn(AppLocalizations l10n) {
    if (unreadCount == 0) return const SizedBox.shrink();
    return GestureDetector(
      onTapDown: (_) {
        markAllCtrl.forward();
        HapticFeedback.selectionClick();
      },
      onTapUp: (_) {
        markAllCtrl.reverse();
        markAllRead();
      },
      onTapCancel: () => markAllCtrl.reverse(),
      child: ScaleTransition(
        scale: markAllScale,
        child: Text(
          AppLocalizations.of(context)!.notificationsMarkAll,
          style: GoogleFonts.cairo(
            fontSize: 13.sp,
            fontWeight: FontWeight.w700,
            color: accent,
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// CustomerNotificationsMobileBody
// ══════════════════════════════════════════════════════════════
class CustomerNotificationsMobileBody extends StatefulWidget {
  const CustomerNotificationsMobileBody({super.key});

  @override
  State<CustomerNotificationsMobileBody> createState() =>
      _CustomerNotificationsMobileBodyState();
}

class _CustomerNotificationsMobileBodyState
    extends _NotifsBase<CustomerNotificationsMobileBody> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppMainBackground(
        child: Column(
          children: [
            // Header using AppPageHeader + trailing unread badge + mark-all
            AppPageHeader(
              isDark: isDark,
              title: l10n.notificationsTitle,
              accentColor: accent,
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  buildUnreadBadge(),
                  SizedBox(width: 10.w),
                  buildMarkAllBtn(l10n),
                ],
              ),
            ),
            buildFilterRow(isDark, l10n),
            Expanded(child: buildList(isDark)),
          ],
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
  State<CustomerNotificationsTabletBody> createState() =>
      _CustomerNotificationsTabletBodyState();
}

class _CustomerNotificationsTabletBodyState
    extends _NotifsBase<CustomerNotificationsTabletBody> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppMainBackground(
        child: Column(
          children: [
            // Full-width header
            AppPageHeader(
              isDark: isDark,
              title: l10n.notificationsTitle,
              accentColor: accent,
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  buildUnreadBadge(),
                  SizedBox(width: 10.w),
                  buildMarkAllBtn(l10n),
                ],
              ),
            ),

            // Two-column content
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Left: filter panel (28%) ─────────────
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.28,
                    child: _FilterPanel(
                      isDark: isDark,
                      l10n: l10n,
                      accentColor: accent,
                      activeFilter: activeFilter,
                      unreadCount: unreadCount,
                      onFilterChanged: (f) => setState(() => activeFilter = f),
                    ),
                  ),

                  VerticalDivider(width: 1, color: accent.withOpacity(0.08)),

                  // ── Right: list (72%) ────────────────────
                  Expanded(child: buildList(isDark)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// _FilterPanel — tablet left panel with animated filter buttons
// ══════════════════════════════════════════════════════════════
class _FilterPanel extends StatefulWidget {
  final bool isDark;
  final AppLocalizations l10n;
  final Color accentColor;
  final NotifType? activeFilter;
  final int unreadCount;
  final ValueChanged<NotifType?> onFilterChanged;

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

class _FilterPanelState extends State<_FilterPanel>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final List<Animation<double>> _fadeAnims;
  late final List<Animation<Offset>> _slideAnims;
  static const _n = 5;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnims = List.generate(_n, (i) {
      final s = (i * 0.14).clamp(0.0, 1.0);
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _ctrl,
          curve: Interval(s, (s + 0.45).clamp(0.0, 1.0), curve: Curves.easeOut),
        ),
      );
    });
    _slideAnims = List.generate(_n, (i) {
      final s = (i * 0.14).clamp(0.0, 1.0);
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

  Widget _item(int i, Widget child) => FadeTransition(
    opacity: _fadeAnims[i],
    child: SlideTransition(position: _slideAnims[i], child: child),
  );

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = widget.l10n;

    return Container(
      color: widget.isDark
          ? AppColors.darkBgSecondary.withOpacity(0.6)
          : Colors.white.withOpacity(0.70),
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _item(
            0,
            Text(
              l10n.filterAll,
              style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
          ),
          SizedBox(height: 16.h),

          // Filter options as vertical list
          ...[
            (null, l10n.filterAll, Icons.all_inbox_rounded),
            (
              NotifType.booking,
              l10n.notifFilterBooking,
              Icons.calendar_today_rounded,
            ),
            (NotifType.payment, l10n.notifFilterPayment, Icons.payment_rounded),
            (
              NotifType.system,
              l10n.notifFilterSystem,
              Icons.info_outline_rounded,
            ),
          ].asMap().entries.map((e) {
            final idx = e.key + 1;
            final filter = e.value.$1;
            final label = e.value.$2;
            final icon = e.value.$3;
            final isActive = widget.activeFilter == filter;

            return _item(
              idx,
              _FilterTile(
                label: label,
                icon: icon,
                isActive: isActive,
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
