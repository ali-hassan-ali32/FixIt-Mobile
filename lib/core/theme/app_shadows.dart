import 'package:flutter/material.dart';

import 'app_colors.dart';

abstract class AppShadows {
  /// Small shadow
  static const List<BoxShadow> sm = [
    BoxShadow(
      color: Color(0x0F000000),
      blurRadius: 4,
      offset: Offset(0, 2),
    ),
  ];

  /// Medium shadow
  static const List<BoxShadow> md = [
    BoxShadow(
      color: Color(0x14000000),
      blurRadius: 12,
      offset: Offset(0, 4),
    ),
  ];

  /// Large shadow
  static const List<BoxShadow> lg = [
    BoxShadow(
      color: Color(0x1F000000),
      blurRadius: 24,
      offset: Offset(0, 8),
    ),
  ];

  /// Primary glow (used on main CTA buttons — customer orange)
  static const List<BoxShadow> primary = [
    BoxShadow(
      color: Color(0x4DFF6B35),
      blurRadius: 12,
      offset: Offset(0, 4),
    ),
  ];

  /// Accent glow (used on handyman teal buttons / cards)
  static List<BoxShadow> accent({Color? color, double opacity = 0.35}) {
    final c = color ?? AppColors.accent[60]!;
    return [
      BoxShadow(
        color: c.withOpacity(opacity),
        blurRadius: 12,
        offset: const Offset(0, 4),
      ),
    ];
  }

  /// Accent card elevation (for elevated cards on home / dashboard)
  static List<BoxShadow> accentCard({Color? color}) {
    final c = color ?? AppColors.accent[60]!;
    return [
      BoxShadow(
        color: c.withOpacity(0.12),
        blurRadius: 24,
        offset: const Offset(0, 8),
      ),
      BoxShadow(
        color: Colors.black.withOpacity(0.04),
        blurRadius: 10,
        offset: const Offset(0, 2),
      ),
    ];
  }

  /// Glassmorphism border glow (for backdrop-blur cards)
  static List<BoxShadow> glassmorphism({Color? color}) {
    final c = color ?? AppColors.accent[60]!;
    return [
      BoxShadow(
        color: c.withOpacity(0.08),
        blurRadius: 20,
        offset: const Offset(0, 4),
      ),
      BoxShadow(
        color: Colors.black.withOpacity(0.04),
        blurRadius: 10,
        offset: const Offset(0, 2),
      ),
    ];
  }

  /// Subtle inner glow for stat cards inside header
  static const List<BoxShadow> headerStat = [
    BoxShadow(
      color: Color(0x14FFFFFF),
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
  ];
}
