import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../config/constants/enums/app_enums.dart';
import '../../theme/app_colors.dart';



class AppLogoHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final double logoSize;
  final AppUserType userType;

  const AppLogoHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.logoSize = 48,
    this.userType = AppUserType.customer,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    // ── Dynamic Colors ───────────────────────────────
    final isHandyman = userType == AppUserType.handyman;

    final mainColor = isHandyman
        ? AppColors.accent[60]!
        : AppColors.primary[60]!;

    final secondaryColor = isHandyman
        ? AppColors.accent[70]!
        : AppColors.secondary[60]!;

    return Column(
      children: [
        // ── Gradient Logo ──────────────────────────────
        ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [mainColor, secondaryColor],
          ).createShader(bounds),
          blendMode: BlendMode.srcIn,
          child: Text(
            'FixIt',
            style: GoogleFonts.cairo(
              fontSize: logoSize.sp,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -1,
            ),
          ),
        ),

        SizedBox(height: 16.h),

        // ── Title ──────────────────────────────────────
        Text(
          title,
          style: textTheme.displayLarge,
          textAlign: TextAlign.center,
        ),

        SizedBox(height: 8.h),

        // ── Subtitle ───────────────────────────────────
        Text(
          subtitle,
          style: textTheme.bodyLarge,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}