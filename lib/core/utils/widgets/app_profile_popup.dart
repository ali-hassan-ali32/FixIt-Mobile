import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../router/app_routes.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_sizes.dart';

// ══════════════════════════════════════════════════════════════
// Model
// ══════════════════════════════════════════════════════════════
class AppProfileMenuAction {
  final IconData icon;
  final String label;
  final Color? iconColor;
  final Color? labelColor;
  final VoidCallback onTap;

  const AppProfileMenuAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.iconColor,
    this.labelColor,
  });
}

// ══════════════════════════════════════════════════════════════
// AppProfilePopup
// ══════════════════════════════════════════════════════════════
class AppProfilePopup extends StatelessWidget {
  final String name;
  final String email;
  final List<AppProfileMenuAction> actions;
  final VoidCallback onClose;

  const AppProfilePopup({
    super.key,
    required this.name,
    required this.email,
    required this.actions,
    required this.onClose,
  });

  // ── Default customer actions ──────────────────────────────
  static List<AppProfileMenuAction> customerActions(
    BuildContext context, {
    required String profile,
    required String edit,
    required String settings,
    required String help,
    required String logout,
    required VoidCallback onLogout,
  }) => [
    AppProfileMenuAction(
      icon: Icons.person_outline_rounded,
      label: profile,
      onTap: () {
        Navigator.pop(context);
        // Profile tab is already in shell — just pop
      },
    ),
    AppProfileMenuAction(
      icon: Icons.edit_outlined,
      label: edit,
      onTap: () {
        Navigator.pop(context);
        Navigator.of(
          context,
        ).pushNamed(AppRoutes.customerEditProfileView, arguments: false);
      },
    ),
    AppProfileMenuAction(
      icon: Icons.settings_outlined,
      label: settings,
      onTap: () {
        Navigator.pop(context);
        Navigator.of(context).pushNamed(AppRoutes.customerSettings);
      },
    ),
    AppProfileMenuAction(
      icon: Icons.help_outline_rounded,
      label: help,
      onTap: () {
        Navigator.pop(context);
        Navigator.of(
          context,
        ).pushNamed(AppRoutes.sharedHelpSupport, arguments: false);
      },
    ),
    AppProfileMenuAction(
      icon: Icons.logout_rounded,
      label: logout,
      iconColor: const Color(0xFFE53935),
      labelColor: const Color(0xFFE53935),
      onTap: () {
        Navigator.pop(context);
        onLogout();
      },
    ),
  ];

  // ── Default handyman actions ──────────────────────────────
  static List<AppProfileMenuAction> handymanActions(
    BuildContext context, {
    required String profile,
    required String edit,
    required String settings,
    required String help,
    required String logout,
    required VoidCallback onLogout,
  }) => [
    AppProfileMenuAction(
      icon: Icons.person_outline_rounded,
      label: profile,
      onTap: () {
        Navigator.pop(context);
      },
    ),
    AppProfileMenuAction(
      icon: Icons.edit_outlined,
      label: edit,
      onTap: () {
        Navigator.pop(context);
        Navigator.of(
          context,
        ).pushNamed(AppRoutes.customerEditProfileView, arguments: true);
      },
    ),
    AppProfileMenuAction(
      icon: Icons.settings_outlined,
      label: settings,
      onTap: () {
        Navigator.pop(context);
        Navigator.of(context).pushNamed(AppRoutes.handymanSettings);
      },
    ),
    AppProfileMenuAction(
      icon: Icons.help_outline_rounded,
      label: help,
      onTap: () {
        Navigator.pop(context);
        Navigator.of(
          context,
        ).pushNamed(AppRoutes.sharedHelpSupport, arguments: true);
      },
    ),
    AppProfileMenuAction(
      icon: Icons.logout_rounded,
      label: logout,
      iconColor: const Color(0xFFE53935),
      labelColor: const Color(0xFFE53935),
      onTap: () {
        Navigator.pop(context);
        onLogout();
      },
    ),
  ];

  // ── Show ──────────────────────────────────────────────────
  static void show({
    required BuildContext context,
    required String name,
    required String email,
    required List<AppProfileMenuAction> actions,
  }) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 260),
      pageBuilder: (_, __, ___) => const SizedBox.shrink(),
      transitionBuilder: (ctx, anim, _, __) {
        return FadeTransition(
          opacity: anim,
          child: Stack(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(ctx),
                child: Container(color: Colors.transparent),
              ),
              Positioned(
                top: 80.h,
                left: 16.w,
                right: 16.w,
                child: SlideTransition(
                  position:
                      Tween<Offset>(
                        begin: const Offset(0, -0.12),
                        end: Offset.zero,
                      ).animate(
                        CurvedAnimation(
                          parent: anim,
                          curve: Curves.easeOutCubic,
                        ),
                      ),
                  child: ScaleTransition(
                    scale: Tween<double>(begin: 0.94, end: 1.0).animate(
                      CurvedAnimation(parent: anim, curve: Curves.easeOutBack),
                    ),
                    alignment: Alignment.topCenter,
                    child: AppProfilePopup(
                      name: name,
                      email: email,
                      actions: actions,
                      onClose: () => Navigator.pop(ctx),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          borderRadius: BorderRadius.all(AppRadius.lg),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 32,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Header ──────────────────────────────────
            _Header(
              name: name,
              email: email,
              onClose: onClose,
              textTheme: textTheme,
              colorScheme: colorScheme,
            ),

            // ── Menu Items ───────────────────────────────
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8.h),
              child: Column(
                children: actions.asMap().entries.map((e) {
                  final isLast = e.key == actions.length - 1;
                  return Column(
                    children: [
                      if (isLast)
                        Divider(
                          color: AppColors.primary[60]!.withOpacity(0.1),
                          height: 1,
                        ),
                      _MenuItem(
                        action: e.value,
                        textTheme: textTheme,
                        colorScheme: colorScheme,
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// _Header — animated avatar + user info
// ══════════════════════════════════════════════════════════════
class _Header extends StatefulWidget {
  final String name;
  final String email;
  final VoidCallback onClose;
  final TextTheme textTheme;
  final ColorScheme colorScheme;

  const _Header({
    required this.name,
    required this.email,
    required this.onClose,
    required this.textTheme,
    required this.colorScheme,
  });

  @override
  State<_Header> createState() => _HeaderState();
}

class _HeaderState extends State<_Header> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 400),
  );
  late final Animation<double> _avatarScale = Tween<double>(
    begin: 0.0,
    end: 1.0,
  ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut));
  late final Animation<double> _fade = CurvedAnimation(
    parent: _ctrl,
    curve: const Interval(0.2, 1.0, curve: Curves.easeOut),
  );

  @override
  void initState() {
    super.initState();
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.xl.w),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.primary[60]!.withOpacity(0.10)),
        ),
      ),
      child: Row(
        children: [
          ScaleTransition(
            scale: _avatarScale,
            child: Container(
              width: 52.w,
              height: 52.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.primary[60]!, AppColors.secondary[60]!],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary[60]!.withOpacity(0.30),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                Icons.person_outline_rounded,
                color: Colors.white,
                size: 26.sp,
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: FadeTransition(
              opacity: _fade,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.name,
                    style: widget.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    widget.email,
                    style: widget.textTheme.bodySmall?.copyWith(
                      color: widget.colorScheme.onSurfaceVariant,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
          GestureDetector(
            onTap: widget.onClose,
            child: Container(
              width: 30.w,
              height: 30.w,
              decoration: BoxDecoration(
                color: widget.colorScheme.surfaceContainerHighest,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.close_rounded,
                size: 16.sp,
                color: widget.colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// _MenuItem — scale press + haptic
// ══════════════════════════════════════════════════════════════
class _MenuItem extends StatefulWidget {
  final AppProfileMenuAction action;
  final TextTheme textTheme;
  final ColorScheme colorScheme;

  const _MenuItem({
    required this.action,
    required this.textTheme,
    required this.colorScheme,
  });

  @override
  State<_MenuItem> createState() => _MenuItemState();
}

class _MenuItemState extends State<_MenuItem>
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
    return GestureDetector(
      onTapDown: (_) {
        _ctrl.forward();
        HapticFeedback.selectionClick();
      },
      onTapUp: (_) {
        _ctrl.reverse();
        widget.action.onTap();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.xl.w,
            vertical: 14.h,
          ),
          child: Row(
            children: [
              Container(
                width: 36.w,
                height: 36.w,
                decoration: BoxDecoration(
                  color: (widget.action.iconColor ?? AppColors.primary[60]!)
                      .withOpacity(0.10),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(
                  widget.action.icon,
                  size: 18.sp,
                  color: widget.action.iconColor ?? AppColors.primary[60],
                ),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Text(
                  widget.action.label,
                  style: widget.textTheme.bodyLarge?.copyWith(
                    color:
                        widget.action.labelColor ??
                        widget.colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_back_ios_rounded,
                size: 14.sp,
                color: widget.action.iconColor != null
                    ? widget.action.iconColor!.withOpacity(0.50)
                    : widget.colorScheme.onSurfaceVariant.withOpacity(0.35),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
