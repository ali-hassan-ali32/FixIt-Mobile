import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

class AppMainBackground extends StatelessWidget {
  final Widget child;

  const AppMainBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = theme.colorScheme.primary;
    final tertiary = theme.colorScheme.tertiary;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: isDark
            ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: [0, 0.45, 1],
                colors: [
                  AppColors.darkBgPrimary,
                  AppColors.darkBgSecondary,
                  AppColors.darkBgTertiary,
                ],
              )
            : const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: [0, 0.45, 1],
                colors: [
                  Color(0xFFFFF7F2),
                  Color(0xFFFFFFFF),
                  Color(0xFFF4FAFF),
                ],
              ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          IgnorePointer(
            child: Stack(
              children: [
                _BackgroundGlow(
                  alignment: Alignment.topRight,
                  color: primary.withOpacity(isDark ? 0.16 : 0.10),
                  size: 220,
                ),
                _BackgroundGlow(
                  alignment: Alignment.bottomLeft,
                  color: tertiary.withOpacity(isDark ? 0.10 : 0.08),
                  size: 260,
                ),
                _BackgroundGlow(
                  alignment: Alignment.centerRight,
                  color: primary.withOpacity(isDark ? 0.08 : 0.05),
                  size: 180,
                  offset: const Offset(48, 0),
                ),
              ],
            ),
          ),
          child,
        ],
      ),
    );
  }
}

class _BackgroundGlow extends StatelessWidget {
  final Alignment alignment;
  final Color color;
  final double size;
  final Offset offset;

  const _BackgroundGlow({
    required this.alignment,
    required this.color,
    required this.size,
    this.offset = Offset.zero,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: Transform.translate(
        offset: offset,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                color,
                color.withOpacity(0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
