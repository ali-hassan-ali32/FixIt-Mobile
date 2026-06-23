import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../theme/app_colors.dart';
import '../animations/app_motion.dart';

// ══════════════════════════════════════════════════════════════
// AppSettingsSection
// A titled group of settings rows.
//
// Usage:
//   AppSettingsSection(
//     title: 'الحساب',
//     isDark: isDark,
//     children: [
//       AppSettingsItem(...),
//       AppSettingsItem(...),
//     ],
//   )
// ══════════════════════════════════════════════════════════════
class AppSettingsSection extends StatelessWidget {
  final String       title;
  final bool         isDark;
  final List<Widget> children;

  const AppSettingsSection({
    super.key,
    required this.title,
    required this.isDark,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: 12.h, right: 4.w, left: 4.w),
            child: Text(
              title,
              style: GoogleFonts.cairo(
                fontSize: 13.sp,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// AppSettingsItem
// A single tappable settings row with icon, label, and
// optional trailing widget (chevron, switch, badge, etc.)
//
// Usage — navigate arrow:
//   AppSettingsItem(
//     icon: Icons.lock_outline_rounded,
//     iconBgColor: Color(0xFFE0F2FE),
//     iconColor: Color(0xFF0284C7),
//     label: 'تغيير كلمة المرور',
//     isDark: isDark,
//     onTap: () {},
//   )
//
// Usage — toggle switch:
//   AppSettingsItem(
//     icon: Icons.notifications_outlined,
//     iconBgColor: Color(0xFFFFF7ED),
//     iconColor: Color(0xFFEA580C),
//     label: 'الإشعارات',
//     isDark: isDark,
//     trailing: Switch(value: _notif, onChanged: (v) => setState(()=> _notif=v)),
//   )
//
// Usage — value label:
//   AppSettingsItem(
//     icon: Icons.language_outlined,
//     iconBgColor: ...,
//     iconColor: ...,
//     label: 'اللغة',
//     isDark: isDark,
//     trailingLabel: 'العربية',
//     onTap: () {},
//   )
// ══════════════════════════════════════════════════════════════
class AppSettingsItem extends StatefulWidget {
  final IconData   icon;
  final Color      iconBgColor;
  final Color      iconColor;
  final String     label;
  final String?    subtitle;      // optional description line below label
  final bool       isDark;
  final VoidCallback? onTap;
  final Widget?    trailing;
  final String?    trailingLabel;
  final bool       showChevron;
  final bool       isDanger;

  const AppSettingsItem({
    super.key,
    required this.icon,
    required this.iconBgColor,
    required this.iconColor,
    required this.label,
    required this.isDark,
    this.subtitle,
    this.onTap,
    this.trailing,
    this.trailingLabel,
    this.showChevron = true,
    this.isDanger = false,
  });

  @override
  State<AppSettingsItem> createState() => _AppSettingsItemState();
}

class _AppSettingsItemState extends State<AppSettingsItem> {
  @override
  Widget build(BuildContext context) {
    final textTheme   = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    final hasTrailing = widget.trailing != null;
    final hasLabel    = widget.trailingLabel != null;
    final showArrow   = widget.showChevron &&
        widget.onTap != null &&
        !hasTrailing &&
        !hasLabel;

    return AppTapScale(
      onTap: widget.onTap,
      borderRadius: BorderRadius.circular(14.r),
      pressedScale: 0.97,
      child: AnimatedScale(
        scale: 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          margin: EdgeInsets.only(bottom: 10.h),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          decoration: BoxDecoration(
            color: widget.isDark ? AppColors.darkSurface : Colors.white,
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(
              color: widget.isDanger
                  ? AppColors.danger.withOpacity(0.15)
                  : AppColors.primary[60]!.withOpacity(0.06),
            ),
            boxShadow: [
              BoxShadow(
                color:
                Colors.black.withOpacity(widget.isDark ? 0.15 : 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // ── Icon bubble ───────────────────────────
              Container(
                width: 36.w,
                height: 36.h,
                decoration: BoxDecoration(
                  color: widget.isDark
                      ? widget.iconColor.withOpacity(0.15)
                      : widget.iconBgColor,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(widget.icon,
                    size: 18.sp, color: widget.iconColor),
              ),
              SizedBox(width: 12.w),

              // ── Label ─────────────────────────────────
              Expanded(
                child: widget.subtitle != null
                    ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.label,
                      style: textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: widget.isDanger ? AppColors.danger : null,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      widget.subtitle!,
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                )
                    : Text(
                  widget.label,
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: widget.isDanger ? AppColors.danger : null,
                  ),
                ),
              ),

              // ── Trailing ──────────────────────────────
              if (hasTrailing) widget.trailing!,

              if (hasLabel) ...[
                Text(
                  widget.trailingLabel!,
                  style: GoogleFonts.cairo(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                SizedBox(width: 6.w),
                Icon(Icons.arrow_back_ios_new_rounded,
                    size: 14.sp,
                    color: colorScheme.onSurfaceVariant),
              ],

              if (showArrow)
                Icon(Icons.arrow_back_ios_new_rounded,
                    size: 14.sp,
                    color: colorScheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// AppSettingsDangerButton
// Full-width danger action button (e.g. delete account).
//
// Usage:
//   AppSettingsDangerButton(
//     label: 'حذف الحساب',
//     onTap: () {},
//   )
// ══════════════════════════════════════════════════════════════
class AppSettingsDangerButton extends StatefulWidget {
  final String       label;
  final IconData?    icon;
  final VoidCallback onTap;

  const AppSettingsDangerButton({
    super.key,
    required this.label,
    required this.onTap,
    this.icon,
  });

  @override
  State<AppSettingsDangerButton> createState() =>
      _AppSettingsDangerButtonState();
}

class _AppSettingsDangerButtonState extends State<AppSettingsDangerButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() => _pressed = true);
        HapticFeedback.mediumImpact();
      },
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 14.h),
          decoration: BoxDecoration(
            color: AppColors.danger.withOpacity(0.08),
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(
                color: AppColors.danger.withOpacity(0.2)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.icon != null) ...[
                Icon(widget.icon, size: 18.sp, color: AppColors.danger),
                SizedBox(width: 8.w),
              ],
              Text(
                widget.label,
                style: GoogleFonts.cairo(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.danger,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}