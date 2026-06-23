import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import 'arabic_pattern_overlay.dart';

// ══════════════════════════════════════════════════════════════
// AppAuthBackground
// Full-screen gradient background + optional Arabic pattern
//
// Usage:
//   AppAuthBackground(child: ...)
//   AppAuthBackground(showPattern: false, child: ...)
// ══════════════════════════════════════════════════════════════
class AppAuthBackground extends StatelessWidget {
  final Widget child;
  final bool showPattern;

  const AppAuthBackground({
    super.key,
    required this.child,
    this.showPattern = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final decoration = BoxDecoration(
      gradient: isDark
          ? const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        stops: [0.0, 0.5, 1.0],
        colors: [
          AppColors.darkBgPrimary,
          AppColors.darkBgSecondary,
          AppColors.darkBgTertiary,
        ],
      )
          : const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        stops: [0.0, 0.5, 1.0],
        colors: [
          Color(0xFFFFF5F0),
          Color(0xFFFFFFFF),
          Color(0xFFF0F9FF),
        ],
      ),
    );

    return SizedBox.expand(
      child: DecoratedBox(
        decoration: decoration,
        child: showPattern
            ? Stack(
          fit: StackFit.expand,
          children: [
            const ArabicPatternOverlay(),
            child,
          ],
        )
            : child,
      ),
    );
  }
}