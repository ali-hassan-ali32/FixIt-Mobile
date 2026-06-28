import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_sizes.dart';

// ══════════════════════════════════════════════════════════════
// Shared notification model + type
// Used by CustomerNotificationsView & HandymanNotificationsView
// ══════════════════════════════════════════════════════════════

/// Maps to the server's numeric `type` field:
/// 1=General, 2=Welcome, 3=RequestCreated, 4=RequestAccepted,
/// 5=RequestRejected, 6=JobStarted, 7=JobCompleted, 8=ReviewAdded
enum NotifType {
  general,        // 1
  welcome,        // 2
  requestCreated, // 3
  requestAccepted,// 4
  requestRejected,// 5
  jobStarted,     // 6
  jobCompleted,   // 7
  reviewAdded;    // 8

  static NotifType fromInt(int value) {
    switch (value) {
      case 1:  return NotifType.general;
      case 2:  return NotifType.welcome;
      case 3:  return NotifType.requestCreated;
      case 4:  return NotifType.requestAccepted;
      case 5:  return NotifType.requestRejected;
      case 6:  return NotifType.jobStarted;
      case 7:  return NotifType.jobCompleted;
      case 8:  return NotifType.reviewAdded;
      default: return NotifType.general;
    }
  }

  bool get isBookingRelated => const {
    NotifType.requestCreated,
    NotifType.requestAccepted,
    NotifType.requestRejected,
    NotifType.jobStarted,
    NotifType.jobCompleted,
  }.contains(this);

  bool get isSystemRelated => const {
    NotifType.general,
    NotifType.welcome,
  }.contains(this);

  bool get isReviewRelated => this == NotifType.reviewAdded;
}

class NotifModel {
  final String    id;
  final String    title;
  final String    body;
  final String    time;
  final NotifType type;
  final IconData  icon;
  final Color     iconColor;
  bool            isRead;

  NotifModel({
    required this.id,
    required this.title,
    required this.body,
    required this.time,
    required this.type,
    required this.icon,
    required this.iconColor,
    this.isRead = false,
  });
}

// ══════════════════════════════════════════════════════════════
// AppNotifTile
// Shared animated notification tile.
//
// Usage:
//   AppNotifTile(
//     notif:       myNotif,
//     index:       i,
//     isDark:      isDark,
//     activeColor: AppColors.accent[60]!,   // teal for handyman
//     onTap:       () => _markRead(id),
//   )
// activeColor defaults to AppColors.primary[60] (customer orange)
// ══════════════════════════════════════════════════════════════
class AppNotifTile extends StatefulWidget {
  final NotifModel   notif;
  final int          index;
  final bool         isDark;
  final Color?       activeColor;
  final VoidCallback onTap;

  const AppNotifTile({
    super.key,
    required this.notif,
    required this.index,
    required this.isDark,
    required this.onTap,
    this.activeColor,
  });

  @override
  State<AppNotifTile> createState() => _AppNotifTileState();
}

class _AppNotifTileState extends State<AppNotifTile>
    with SingleTickerProviderStateMixin {
  bool _pressed = false;

  late final AnimationController _entryCtrl;
  late final Animation<double>   _entryOpacity;
  late final Animation<Offset>   _entrySlide;

  @override
  void initState() {
    super.initState();
    _entryCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _entryOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOut),
    );
    _entrySlide = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOutCubic),
    );
    Future.delayed(Duration(milliseconds: widget.index * 55), () {
      if (mounted) _entryCtrl.forward();
    });
  }

  @override
  void dispose() {
    _entryCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final n           = widget.notif;
    final textTheme   = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final color       = widget.activeColor ?? AppColors.primary[60]!;

    return FadeTransition(
      opacity: _entryOpacity,
      child: SlideTransition(
        position: _entrySlide,
        child: GestureDetector(
          onTapDown: (_) => setState(() => _pressed = true),
          onTapUp: (_) {
            setState(() => _pressed = false);
            widget.onTap();
          },
          onTapCancel: () => setState(() => _pressed = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.xl.w,
              vertical: 14.h,
            ),
            decoration: BoxDecoration(
              color: _pressed
                  ? color.withOpacity(0.04)
                  : !n.isRead
                  ? color.withOpacity(widget.isDark ? 0.06 : 0.03)
                  : Colors.transparent,
              border: Border(
                bottom: BorderSide(
                  color: color.withOpacity(0.06),
                ),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon box
                Container(
                  width: 44.w,
                  height: 44.h,
                  decoration: BoxDecoration(
                    color: n.iconColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(n.icon, size: 22.sp, color: n.iconColor),
                ),
                SizedBox(width: 14.w),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        n.title,
                        style: textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: n.isRead
                              ? null
                              : widget.isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 5.h),
                      Text(
                        n.body,
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          height: 1.5,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 5.h),
                      Text(
                        n.time,
                        style: GoogleFonts.cairo(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurfaceVariant.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),

                // Unread dot
                if (!n.isRead) ...[
                  SizedBox(width: 8.w),
                  Padding(
                    padding: EdgeInsets.only(top: 6.h),
                    child: Container(
                      width: 8.w,
                      height: 8.h,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [color, color.withOpacity(0.6)],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: color.withOpacity(0.4),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}