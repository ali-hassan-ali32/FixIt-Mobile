import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

// ══════════════════════════════════════════════════════════════
// AppContactButton
// Solid or tinted contact button (call/whatsapp/message).
// Replaces _ContactBtn in customer_contact_card,
// handyman_contact_card, shared_help_support_view.
//
// Usage — solid (call):
//   AppContactButton(icon: Icons.phone_rounded,
//     label: l10n.trackCallBtn, accentColor: teal, onTap: _call)
//
// Usage — tinted (message):
//   AppContactButton(icon: Icons.chat_rounded,
//     label: l10n.trackWhatsappBtn, accentColor: teal,
//     isSolid: false, onTap: _msg)
// ══════════════════════════════════════════════════════════════
class AppContactButton extends StatefulWidget {
  final IconData     icon;
  final String       label;
  final Color        accentColor;
  final bool         isSolid;
  final VoidCallback onTap;

  const AppContactButton({
    super.key,
    required this.icon,
    required this.label,
    required this.accentColor,
    required this.onTap,
    this.isSolid = true,
  });

  @override
  State<AppContactButton> createState() => _AppContactButtonState();
}

class _AppContactButtonState extends State<AppContactButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 100));
  late final Animation<double> _scale = Tween<double>(begin: 1.0, end: 0.95)
      .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final bgColor  = widget.isSolid
        ? widget.accentColor
        : widget.accentColor.withOpacity(0.12);
    final fgColor  = widget.isSolid ? Colors.white : widget.accentColor;

    return GestureDetector(
      onTapDown:   (_) { _ctrl.forward(); HapticFeedback.selectionClick(); },
      onTapUp:     (_) { _ctrl.reverse(); widget.onTap(); },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          height: 46.h,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: widget.isSolid
                ? [BoxShadow(
                color: widget.accentColor.withOpacity(0.28),
                blurRadius: 10,
                offset: const Offset(0, 3))]
                : [],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(widget.icon, size: 18.sp, color: fgColor),
              SizedBox(width: 6.w),
              Text(widget.label,
                  style: GoogleFonts.cairo(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: fgColor,
                  )),
            ],
          ),
        ),
      ),
    );
  }
}