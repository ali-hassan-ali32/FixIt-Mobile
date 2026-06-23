import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../theme/app_colors.dart';

// ══════════════════════════════════════════════════════════════
// AppCustomerContactCard
// Shows customer info + call/message buttons.
// Used by handyman on active/new job views.
//
// Usage:
//   AppCustomerContactCard(
//     isDark: isDark,
//     name: 'أحمد محمود',
//     statusLabel: l10n.customerNew,   // 'عميل جديد'
//     rating: 5.0,
//     phone: '+201234567890',
//     requestId: 'REQ-00124',
//     accentColor: AppColors.accent[60]!,
//     titleLabel: l10n.jobCustomerInfo,
//     callLabel: l10n.trackCallBtn,
//     messageLabel: l10n.trackWhatsappBtn,
//   )
// ══════════════════════════════════════════════════════════════
class AppCustomerContactCard extends StatelessWidget {
  final bool        isDark;
  final String      name;
  final String      statusLabel;
  final double      rating;
  final String      phone;
  final String      requestId;
  final Color       accentColor;
  final String      titleLabel;
  final String      callLabel;
  final String      messageLabel;

  const AppCustomerContactCard({
    super.key,
    required this.isDark,
    required this.name,
    required this.statusLabel,
    required this.rating,
    required this.phone,
    required this.requestId,
    required this.accentColor,
    required this.titleLabel,
    required this.callLabel,
    required this.messageLabel,
  });

  Future<void> _call() async {
    HapticFeedback.mediumImpact();
    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  Future<void> _message() async {
    HapticFeedback.mediumImpact();
    final msg = Uri.encodeComponent(
        'مرحباً، أنا الفني من تطبيق FixIt - طلب رقم $requestId');
    final uri = Uri.parse(
        'https://wa.me/${phone.replaceAll('+', '')}?text=$msg');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme   = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: accentColor.withOpacity(0.10)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.15 : 0.05),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(titleLabel,
              style: textTheme.titleSmall
                  ?.copyWith(fontWeight: FontWeight.w800)),
          SizedBox(height: 16.h),

          // Customer row
          Row(
            children: [
              // Avatar
              Container(
                width: 56.w,
                height: 56.w,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF3498DB),
                      const Color(0xFF2980B9),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14.r),
                ),
                child: Center(
                  child: Text(
                    name.isNotEmpty ? name.substring(0, 1) : '؟',
                    style: GoogleFonts.cairo(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 14.w),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name,
                        style: textTheme.titleSmall
                            ?.copyWith(fontWeight: FontWeight.w800)),
                    SizedBox(height: 3.h),
                    Text(statusLabel,
                        style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant)),
                    SizedBox(height: 5.h),
                    _RatingRow(rating: rating, accent: accentColor),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),

          // Buttons
          Row(
            children: [
              Expanded(
                child: _ContactBtn(
                  icon: Icons.phone_rounded,
                  label: callLabel,
                  color: accentColor,
                  onTap: _call,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _ContactBtn(
                  icon: Icons.chat_rounded,
                  label: messageLabel,
                  color: accentColor.withOpacity(0.12),
                  textColor: accentColor,
                  onTap: _message,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// _RatingRow
// ══════════════════════════════════════════════════════════════
class _RatingRow extends StatelessWidget {
  final double rating;
  final Color  accent;
  const _RatingRow({required this.rating, required this.accent});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ...List.generate(5, (i) => Icon(
          i < rating.floor()
              ? Icons.star_rounded
              : i < rating
              ? Icons.star_half_rounded
              : Icons.star_outline_rounded,
          size: 14.sp,
          color: AppColors.star,
        )),
        SizedBox(width: 4.w),
        Text(
          rating.toStringAsFixed(1),
          style: GoogleFonts.cairo(
            fontSize: 12.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.star,
          ),
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════
// _ContactBtn
// ══════════════════════════════════════════════════════════════
class _ContactBtn extends StatefulWidget {
  final IconData     icon;
  final String       label;
  final Color        color;
  final Color?       textColor;
  final VoidCallback onTap;

  const _ContactBtn({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.textColor,
  });

  @override
  State<_ContactBtn> createState() => _ContactBtnState();
}

class _ContactBtnState extends State<_ContactBtn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 100));
  late final Animation<double> _scale = Tween<double>(begin: 1.0, end: 0.95)
      .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final isSolid = widget.textColor == null;
    final fgColor = widget.textColor ?? Colors.white;

    return GestureDetector(
      onTapDown:   (_) { _ctrl.forward(); HapticFeedback.selectionClick(); },
      onTapUp:     (_) { _ctrl.reverse(); widget.onTap(); },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          height: 46.h,
          decoration: BoxDecoration(
            color: widget.color,
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: isSolid
                ? [BoxShadow(
                color: widget.color.withOpacity(0.30),
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