import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BouncingDot extends StatelessWidget {
  final AnimationController controller;
  final double delayFraction;
  final Gradient gradient;

  const BouncingDot({
    super.key,
    required this.controller,
    required this.delayFraction,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        // Bounce keyframes: 0%,80%,100% → scale 0 | 40% → scale 1
        double t = (controller.value + delayFraction) % 1.0;
        double scale;
        double opacity;

        if (t < 0.4) {
          // 0% → 40%: scale 0 → 1
          scale = t / 0.4;
          opacity = 0.4 + (0.6 * (t / 0.4));
        } else if (t < 0.8) {
          // 40% → 80%: scale 1 → 0
          scale = 1.0 - ((t - 0.4) / 0.4);
          opacity = 1.0 - (0.6 * ((t - 0.4) / 0.4));
        } else {
          // 80% → 100%: scale 0
          scale = 0.0;
          opacity = 0.4;
        }

        return Opacity(
          opacity: opacity,
          child: Transform.scale(
            scale: scale,
            child: Container(
              width: 12.w,
              height: 12.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: gradient,
              ),
            ),
          ),
        );
      },
    );
  }
}