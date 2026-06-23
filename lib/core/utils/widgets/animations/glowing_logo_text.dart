import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class GlowingLogoText extends StatelessWidget {
  final double glowIntensity;

  const GlowingLogoText({super.key, required this.glowIntensity});

  @override
  Widget build(BuildContext context) {
    // blurRadius يتغير مع الـ glow animation زي الـ CSS
    final double blurRadius = 16 + (glowIntensity * 20);
    final double glowOpacity = glowIntensity;

    const double glowPadding = 40.0;

    return Padding(
      padding: const EdgeInsets.all(glowPadding),
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // ── Layer 1: Glow ورا الـ text ────────────────
          Positioned(
            top: -glowPadding,
            bottom: -glowPadding,
            left: -glowPadding,
            right: -glowPadding,
            child: Center(
              child: Text(
                'FixIt',
                style: GoogleFonts.cairo(
                  fontSize: 100.sp,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -2,
                  height: 1.0,
                  foreground: Paint()
                    ..color = Color.fromRGBO(255, 107, 53, glowOpacity)
                    ..maskFilter =
                    MaskFilter.blur(BlurStyle.normal, blurRadius),
                ),
              ),
            ),
          ),

          // ── Layer 2: Gradient Text فوق الـ glow ───────
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              stops: [0.0, 0.5, 1.0],
              colors: [
                Color(0xFFFF6B35),
                Color(0xFFF7931E),
                Color(0xFF4ECDC4),
              ],
            ).createShader(bounds),
            blendMode: BlendMode.srcIn,
            child: Text(
              'FixIt',
              style: GoogleFonts.cairo(
                fontSize: 100.sp,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: -2,
                height: 1.0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
