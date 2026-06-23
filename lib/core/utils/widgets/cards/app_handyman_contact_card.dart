import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../theme/app_colors.dart';

// ══════════════════════════════════════════════════════════════
// AppHandymanContactCard
// Shows assigned handyman info + call/whatsapp contact buttons.
// Used in: active + in-progress request tracking views.
//
// Usage:
//   AppHandymanContactCard(
//     isDark: isDark,
//     name: 'محمد علي',
//     specialty: 'فني سباكة محترف',
//     rating: 4.9,
//     phone: '+201234567890',
//     requestId: 'REQ-00123',
//     avatarColors: [AppColors.primary[60]!, AppColors.secondary[60]!],
//     callLabel: l10n.trackCallBtn,
//     whatsappLabel: l10n.trackWhatsappBtn,
//     titleLabel: l10n.trackHandymanTitle,
//   )
// ══════════════════════════════════════════════════════════════
class AppHandymanContactCard extends StatelessWidget {
  final bool         isDark;
  final String       name;
  final String       specialty;
  final double       rating;
  final String       phone;
  final String       requestId;
  final List<Color>  avatarColors;
  final String       titleLabel;
  final String       callLabel;
  final String       whatsappLabel;

  const AppHandymanContactCard({
    super.key,
    required this.isDark,
    required this.name,
    required this.specialty,
    required this.rating,
    required this.phone,
    required this.requestId,
    required this.avatarColors,
    required this.titleLabel,
    required this.callLabel,
    required this.whatsappLabel,
  });

  Future<void> _call() async {
    HapticFeedback.mediumImpact();
    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  Future<void> _whatsapp() async {
    HapticFeedback.mediumImpact();
    final msg = Uri.encodeComponent(
        'مرحباً، أنا العميل من تطبيق FixIt - طلب رقم $requestId');
    final uri = Uri.parse('https://wa.me/${phone.replaceAll('+', '')}?text=$msg');
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
        border: Border.all(
            color: AppColors.primary[60]!.withOpacity(0.08)),
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
          // ── Title ───────────────────────────────────────
          Text(titleLabel,
              style: textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w800)),
          SizedBox(height: 16.h),

          // ── Handyman row ─────────────────────────────────
          Row(
            children: [
              // Avatar
              Container(
                width: 64.w,
                height: 64.h,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: avatarColors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14.r),
                ),
                child: Icon(Icons.person_rounded,
                    size: 32.sp, color: Colors.white),
              ),
              SizedBox(width: 14.w),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name,
                        style: textTheme.titleSmall
                            ?.copyWith(fontWeight: FontWeight.w700)),
                    SizedBox(height: 3.h),
                    Text(specialty,
                        style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant)),
                    SizedBox(height: 6.h),
                    _RatingRow(rating: rating),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),

          // ── Contact buttons ──────────────────────────────
          Row(
            children: [
              // Call
              Expanded(
                child: _ContactButton(
                  icon: Icons.phone_rounded,
                  label: callLabel,
                  isPrimary: true,
                  onTap: _call,
                ),
              ),
              SizedBox(width: 12.w),

              // WhatsApp
              Expanded(
                child: _ContactButton(
                  icon: Icons.chat_rounded,
                  label: whatsappLabel,
                  isPrimary: false,
                  onTap: _whatsapp,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Rating row ─────────────────────────────────────────────
class _RatingRow extends StatelessWidget {
  final double rating;

  const _RatingRow({required this.rating});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ...List.generate(
          5,
              (i) => Icon(
            i < rating.floor()
                ? Icons.star_rounded
                : (i < rating ? Icons.star_half_rounded : Icons.star_outline_rounded),
            size: 14.sp,
            color: AppColors.star,
          ),
        ),
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

// ── Contact button ──────────────────────────────────────────
class _ContactButton extends StatefulWidget {
  final IconData     icon;
  final String       label;
  final bool         isPrimary;
  final VoidCallback onTap;

  const _ContactButton({
    required this.icon,
    required this.label,
    required this.isPrimary,
    required this.onTap,
  });

  @override
  State<_ContactButton> createState() => _ContactButtonState();
}

class _ContactButtonState extends State<_ContactButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final color = widget.isPrimary
        ? AppColors.primary[60]!
        : const Color(0xFF25D366); // WhatsApp green

    return GestureDetector(
      onTapDown: (_) {
        setState(() => _pressed = true);
        HapticFeedback.selectionClick();
      },
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          height: 46.h,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(widget.icon, size: 18.sp, color: Colors.white),
              SizedBox(width: 6.w),
              Text(
                widget.label,
                style: GoogleFonts.cairo(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}