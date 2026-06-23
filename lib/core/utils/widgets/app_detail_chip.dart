import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

// ══════════════════════════════════════════════════════════════
// AppDetailChip
// Small icon + label inline chip.
// Replaces _DetailChip, _Chip, _DetailItem across request/job cards.
//
// Usage:
//   AppDetailChip(icon: Icons.calendar_today_rounded,
//     label: '2026/02/12', accentColor: teal)
// ══════════════════════════════════════════════════════════════
class AppDetailChip extends StatelessWidget {
  final IconData icon;
  final String   label;
  final Color    accentColor;
  final double   iconSize;
  final double   fontSize;

  const AppDetailChip({
    super.key,
    required this.icon,
    required this.label,
    required this.accentColor,
    this.iconSize = 13,
    this.fontSize = 12,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: iconSize.sp, color: accentColor),
        SizedBox(width: 4.w),
        Flexible(
          child: Text(
            label,
            style: GoogleFonts.cairo(
              fontSize: fontSize.sp,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}