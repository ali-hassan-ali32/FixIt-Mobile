import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/l10n/translation/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/utils/widgets/app_main_background.dart';
import '../../../../core/utils/widgets/app_filter_chip.dart';
import '../../../../core/utils/widgets/app_notif_tile.dart';
import '../../../../core/utils/widgets/buttons/app_back_button.dart';

// ── Mock data ─────────────────────────────────────────────────
List<NotifModel> _buildHandymanMock(AppLocalizations l10n) => [
  NotifModel(
    id: '1',
    title: l10n.notifHandymanNewRequestTitle,
    body: l10n.notifHandymanNewRequestBody,
    time: l10n.notifTime5Min,
    type: NotifType.booking,
    icon: Icons.check_circle_rounded,
    iconColor: const Color(0xFF4ECDC4),
    isRead: false,
  ),
  NotifModel(
    id: '2',
    title: l10n.notifHandymanReminderTitle,
    body: l10n.notifHandymanReminderBody,
    time: l10n.notifTime10Min,
    type: NotifType.payment,
    icon: Icons.notifications_rounded,
    iconColor: const Color(0xFFFF6B35),
    isRead: false,
  ),
  NotifModel(
    id: '3',
    title: l10n.notifHandymanRatingTitle,
    body: l10n.notifHandymanRatingBody,
    time: l10n.notifTime2Hours,
    type: NotifType.booking,
    icon: Icons.star_rounded,
    iconColor: const Color(0xFFF7931E),
  ),
  NotifModel(
    id: '4',
    title: l10n.notifHandymanPaymentTitle,
    body: l10n.notifHandymanPaymentBody,
    time: l10n.notifTime3Hours,
    type: NotifType.payment,
    icon: Icons.account_balance_wallet_rounded,
    iconColor: const Color(0xFF4ECDC4),
  ),
  NotifModel(
    id: '5',
    title: l10n.notifHandymanCancelTitle,
    body: l10n.notifHandymanCancelBody,
    time: l10n.notifTime4Hours,
    type: NotifType.booking,
    icon: Icons.cancel_rounded,
    iconColor: AppColors.danger,
  ),
  NotifModel(
    id: '6',
    title: l10n.notifHandymanLevelUpTitle,
    body: l10n.notifHandymanLevelUpBody,
    time: l10n.notifTimeYesterday,
    type: NotifType.system,
    icon: Icons.emoji_events_rounded,
    iconColor: const Color(0xFF9B59B6),
  ),
  NotifModel(
    id: '7',
    title: l10n.notifHandymanWelcomeTitle,
    body: l10n.notifHandymanWelcomeBody,
    time: l10n.notifTime3Days,
    type: NotifType.system,
    icon: Icons.verified_rounded,
    iconColor: AppColors.info,
  ),
];

// ══════════════════════════════════════════════════════════════
// HandymanNotificationsView — layout router
// ══════════════════════════════════════════════════════════════
class HandymanNotificationsView extends StatelessWidget {
  const HandymanNotificationsView({super.key});

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (_, c) => c.maxWidth >= 600
        ? const _HandymanNotificationsTabletBody()
        : const _HandymanNotificationsMobileBody(),
  );
}

// ══════════════════════════════════════════════════════════════
// Shared base
// ══════════════════════════════════════════════════════════════
abstract class _NotificationsBase<T extends StatefulWidget> extends State<T>
    with TickerProviderStateMixin {
  Color get teal => AppColors.accent[60]!;

  NotifType? activeFilter;
  List<NotifModel>? notifications;

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
          curve: Interval(
            s,
            (s + 0.45).clamp(0.0, 1.0),
            curve: Curves.easeOutCubic,
          ),
        ),
      );
    });

    entryCtrl.forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    notifications ??= _buildHandymanMock(AppLocalizations.of(context)!);
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

  List<NotifModel> get filtered => activeFilter == null
      ? notifications!
      : notifications!.where((n) => n.type == activeFilter).toList();

  int get unreadCount => notifications!.where((n) => !n.isRead).length;

  void markAllRead() {
    HapticFeedback.lightImpact();
    setState(() {
      for (final n in notifications!) {
        n.isRead = true;
      }
    });
  }

  void markRead(String id) {
    setState(() {
      notifications!.firstWhere((n) => n.id == id).isRead = true;
    });
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
        color: isDark
            ? AppColors.darkBgSecondary
            : Colors.white.withOpacity(0.95),
        border: Border(bottom: BorderSide(color: teal.withOpacity(0.1))),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
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
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
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
              onTap: markAllRead,
              child: _MarkAllButton(label: l10n.notifMarkAllRead, color: teal),
            ),
        ],
      ),
    );
  }

  // ── Filter row ───────────────────────────────────────────
  Widget buildFilterRow(bool isDark, AppLocalizations l10n) {
    return Container(
      color: isDark ? AppColors.darkBgSecondary : Colors.white,
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
              onTap: () => setState(() => activeFilter = null),
              isDark: isDark,
              activeColor: teal,
              activeColorEnd: teal,
            ),
            SizedBox(width: 8.w),
            AppFilterChip(
              label: l10n.notifFilterBooking,
              isActive: activeFilter == NotifType.booking,
              onTap: () => setState(() => activeFilter = NotifType.booking),
              isDark: isDark,
              activeColor: teal,
              activeColorEnd: teal,
            ),
            SizedBox(width: 8.w),
            AppFilterChip(
              label: l10n.notifFilterPayment,
              isActive: activeFilter == NotifType.payment,
              onTap: () => setState(() => activeFilter = NotifType.payment),
              isDark: isDark,
              activeColor: teal,
              activeColorEnd: teal,
            ),
            SizedBox(width: 8.w),
            AppFilterChip(
              label: l10n.notifFilterSystem,
              isActive: activeFilter == NotifType.system,
              onTap: () => setState(() => activeFilter = NotifType.system),
              isDark: isDark,
              activeColor: teal,
              activeColorEnd: teal,
            ),
          ],
        ),
      ),
    );
  }

  // ── Empty state ──────────────────────────────────────────
  Widget buildEmptyState(
    TextTheme textTheme,
    ColorScheme colorScheme,
    AppLocalizations l10n,
  ) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80.w,
            height: 80.h,
            decoration: BoxDecoration(
              color: teal.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.notifications_off_outlined,
              size: 36.sp,
              color: teal,
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            l10n.notifEmptyTitle,
            style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          SizedBox(height: 8.h),
          Text(
            l10n.notifEmptySubtitle,
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ── Notification list ────────────────────────────────────
  Widget buildNotificationList(bool isDark, List<NotifModel> filtered) {
    return ListView.builder(
      itemCount: filtered.length,
      itemBuilder: (_, i) => _AnimatedNotifTile(
        index: i,
        notif: filtered[i],
        isDark: isDark,
        activeColor: teal,
        onTap: () => markRead(filtered[i].id),
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
  State<_HandymanNotificationsMobileBody> createState() =>
      _HandymanNotificationsMobileBodyState();
}

class _HandymanNotificationsMobileBodyState
    extends _NotificationsBase<_HandymanNotificationsMobileBody> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final filtered = super.filtered;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.darkBgPrimary
          : teal.withOpacity(0.03),
      body: AppMainBackground(
        child: Column(
          children: [
            ea(0, buildHeader(context, isDark, textTheme, colorScheme, l10n)),
            ea(1, buildFilterRow(isDark, l10n)),
            Expanded(
              child: filtered.isEmpty
                  ? ea(2, buildEmptyState(textTheme, colorScheme, l10n))
                  : ea(3, buildNotificationList(isDark, filtered)),
            ),
          ],
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
  State<_HandymanNotificationsTabletBody> createState() =>
      _HandymanNotificationsTabletBodyState();
}

class _HandymanNotificationsTabletBodyState
    extends _NotificationsBase<_HandymanNotificationsTabletBody> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final filtered = super.filtered;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppMainBackground(
        child: SafeArea(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Left panel (38%) ───────────────────────────
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.38,
                child: Column(
                  children: [
                    ea(
                      0,
                      _buildTabletHeaderCard(
                        context,
                        isDark,
                        textTheme,
                        colorScheme,
                        l10n,
                      ),
                    ),
                    ea(1, buildFilterRow(isDark, l10n)),
                  ],
                ),
              ),

              VerticalDivider(width: 1, color: teal.withOpacity(0.10)),

              // ── Right panel (62%) ──────────────────────────
              Expanded(
                child: filtered.isEmpty
                    ? ea(2, buildEmptyState(textTheme, colorScheme, l10n))
                    : ea(3, buildNotificationList(isDark, filtered)),
              ),
            ],
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
        boxShadow: [
          BoxShadow(
            color: teal.withOpacity(0.25),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
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
                  style: textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              if (unreadCount > 0)
                _AnimatedBadge(count: unreadCount, color: Colors.white),
            ],
          ),
          SizedBox(height: 16.h),

          // Stats row
          Row(
            children: [
              Expanded(
                child: _StatItem(
                  value: '${notifications?.length ?? 0}',
                  label: l10n.filterAll,
                  isDark: false,
                ),
              ),
              Container(
                width: 1,
                height: 40.h,
                color: Colors.white.withOpacity(0.25),
              ),
              Expanded(
                child: _StatItem(
                  value: '$unreadCount',
                  label: 'unread' ?? 'New',
                  isDark: false,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),

          // Mark all read button
          if (unreadCount > 0)
            GestureDetector(
              onTap: markAllRead,
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
                    style: GoogleFonts.cairo(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
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

class _AnimatedBadgeState extends State<_AnimatedBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1500),
  )..repeat(reverse: true);

  late final Animation<double> _scale = Tween<double>(
    begin: 1.0,
    end: 1.1,
  ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
        decoration: BoxDecoration(
          color: widget.color,
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Text(
          '${widget.count}',
          style: GoogleFonts.cairo(
            fontSize: 11.sp,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class _MarkAllButton extends StatefulWidget {
  final String label;
  final Color color;

  const _MarkAllButton({required this.label, required this.color});

  @override
  State<_MarkAllButton> createState() => _MarkAllButtonState();
}

class _MarkAllButtonState extends State<_MarkAllButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 100),
  );
  late final Animation<double> _scale = Tween<double>(
    begin: 1.0,
    end: 0.95,
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
      },
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
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  final bool isDark;

  const _StatItem({
    required this.value,
    required this.label,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.cairo(
            fontSize: 22.sp,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          label,
          style: GoogleFonts.cairo(
            fontSize: 11.sp,
            color: Colors.white.withOpacity(0.85),
          ),
        ),
      ],
    );
  }
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

class _AnimatedNotifTileState extends State<_AnimatedNotifTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _opacity;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _opacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _slide = Tween<Offset>(
      begin: const Offset(0.15, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));

    Future.delayed(Duration(milliseconds: 100 + widget.index * 60), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(
        position: _slide,
        child: AppNotifTile(
          notif: widget.notif,
          index: widget.index,
          isDark: widget.isDark,
          activeColor: widget.activeColor,
          onTap: widget.onTap,
        ),
      ),
    );
  }
}
