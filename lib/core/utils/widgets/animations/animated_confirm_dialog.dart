import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_colors.dart';

// ══════════════════════════════════════════════════════════════
// AnimatedConfirmDialog
// Reusable scale+fade animated confirmation dialog.
// Supports danger (red) and normal (primary) styles.
//
// Usage — danger:
//   showAnimatedConfirmDialog(
//     context: context,
//     isDark: isDark,
//     icon: Icons.cancel_outlined,
//     title: l10n.trackCancelTitle,
//     message: l10n.trackCancelConfirm,
//     cancelLabel: l10n.trackCancelKeep,
//     confirmLabel: l10n.trackCancelConfirmBtn,
//     isDanger: true,
//     onConfirm: () { /* action */ },
//   );
//
// Usage — normal:
//   showAnimatedConfirmDialog(
//     context: context,
//     isDark: isDark,
//     icon: Icons.logout_rounded,
//     title: 'تسجيل الخروج',
//     message: 'هل أنت متأكد؟',
//     cancelLabel: 'إلغاء',
//     confirmLabel: 'خروج',
//     onConfirm: () { /* action */ },
//   );
// ══════════════════════════════════════════════════════════════

Future<void> showAnimatedConfirmDialog({
  required BuildContext  context,
  required bool          isDark,
  required IconData      icon,
  required String        title,
  required String        message,
  required String        cancelLabel,
  required String        confirmLabel,
  required VoidCallback  onConfirm,
  bool                   isDanger = true,
  Color?                 confirmColor,  // override confirm button color
}) {
  return showDialog(
    context: context,
    barrierColor: Colors.black.withOpacity(0.5),
    builder: (_) => AnimatedConfirmDialog(
      isDark: isDark,
      icon: icon,
      title: title,
      message: message,
      cancelLabel: cancelLabel,
      confirmLabel: confirmLabel,
      onConfirm: onConfirm,
      isDanger: isDanger,
      confirmColor: confirmColor,
    ),
  );
}

class AnimatedConfirmDialog extends StatefulWidget {
  final bool          isDark;
  final IconData      icon;
  final String        title;
  final String        message;
  final String        cancelLabel;
  final String        confirmLabel;
  final VoidCallback  onConfirm;
  final bool          isDanger;
  final Color?        confirmColor;

  const AnimatedConfirmDialog({
    super.key,
    required this.isDark,
    required this.icon,
    required this.title,
    required this.message,
    required this.cancelLabel,
    required this.confirmLabel,
    required this.onConfirm,
    this.isDanger = true,
    this.confirmColor,
  });

  @override
  State<AnimatedConfirmDialog> createState() => _AnimatedConfirmDialogState();
}

class _AnimatedConfirmDialogState extends State<AnimatedConfirmDialog>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double>   _scale;
  late final Animation<double>   _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 350));
    _scale = Tween<double>(begin: 0.75, end: 1.0).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Color get _confirmColor =>
      widget.confirmColor ??
          (widget.isDanger ? AppColors.danger : AppColors.primary[60]!);

  @override
  Widget build(BuildContext context) {
    final textTheme   = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return FadeTransition(
      opacity: _fade,
      child: ScaleTransition(
        scale: _scale,
        child: Dialog(
          backgroundColor:
          widget.isDark ? AppColors.darkBgSecondary : Colors.white,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24.r)),
          child: Padding(
            padding: EdgeInsets.all(24.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Icon bubble ───────────────────────────
                Container(
                  width: 72.w,
                  height: 72.h,
                  decoration: BoxDecoration(
                    color: _confirmColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: _confirmColor.withOpacity(0.2), width: 2),
                  ),
                  child: Icon(widget.icon,
                      size: 34.sp, color: _confirmColor),
                ),
                SizedBox(height: 20.h),

                // ── Title ─────────────────────────────────
                Text(
                  widget.title,
                  style: textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w800),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 10.h),

                // ── Message ───────────────────────────────
                Text(
                  widget.message,
                  style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant, height: 1.6),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 28.h),

                // ── Buttons ───────────────────────────────
                Row(
                  children: [
                    // Cancel
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          height: 48.h,
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(14.r),
                          ),
                          child: Center(
                            child: Text(
                              widget.cancelLabel,
                              style: GoogleFonts.cairo(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w700,
                                color: colorScheme.onSurface,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),

                    // Confirm
                    Expanded(
                      child: GestureDetector(
                        onTap: widget.onConfirm,
                        child: Container(
                          height: 48.h,
                          decoration: BoxDecoration(
                            color: _confirmColor,
                            borderRadius: BorderRadius.circular(14.r),
                            boxShadow: [
                              BoxShadow(
                                color: _confirmColor.withOpacity(0.35),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              widget.confirmLabel,
                              style: GoogleFonts.cairo(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}