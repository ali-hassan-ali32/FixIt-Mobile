import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
// ══════════════════════════════════════════════════════════════
// AppStepHeader
// Animated step header with floating icon + glow pulse
//
// Usage:
//   AppStepHeader(
//     icon: Icons.person_outline_rounded,
//     gradient: [AppColors.primary[60]!, AppColors.secondary[60]!],
//     title: 'مرحباً بك!',
//     subtitle: 'دعنا نبدأ بمعلوماتك الأساسية',
//   )
// ══════════════════════════════════════════════════════════════
class AppStepHeader extends StatefulWidget {
  final IconData icon;
  final List<Color> gradient;
  final String title;
  final String subtitle;

  const AppStepHeader({
    super.key,
    required this.icon,
    required this.gradient,
    required this.title,
    required this.subtitle,
  });

  @override
  State<AppStepHeader> createState() => _AppStepHeaderState();
}

class _AppStepHeaderState extends State<AppStepHeader>
    with TickerProviderStateMixin {

  // ── Entry: bounce scale ───────────────────────────────────
  late final AnimationController _entryController;
  late final Animation<double> _entryScale;
  late final Animation<double> _entryOpacity;

  // ── Float: up & down ─────────────────────────────────────
  late final AnimationController _floatController;
  late final Animation<double> _floatY;

  // ── Glow pulse ────────────────────────────────────────────
  late final AnimationController _glowController;
  late final Animation<double> _glowRadius;
  late final Animation<double> _glowOpacity;

  @override
  void initState() {
    super.initState();

    // Entry
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _entryScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _entryController, curve: Curves.elasticOut),
    );
    _entryOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _entryController, curve: Curves.easeOut),
    );

    // Float
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);
    _floatY = Tween<double>(begin: -5.0, end: 5.0).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );

    // Glow
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);
    _glowRadius = Tween<double>(begin: 10.0, end: 26.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
    _glowOpacity = Tween<double>(begin: 0.15, end: 0.35).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    _entryController.forward();
  }

  @override
  void dispose() {
    _entryController.dispose();
    _floatController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme   = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final isDark      = Theme.of(context).brightness == Brightness.dark;
    final glowColor   = widget.gradient.first;

    return Column(
      children: [
        // ── Animated Icon ─────────────────────────────
        AnimatedBuilder(
          animation: Listenable.merge([
            _entryController,
            _floatController,
            _glowController,
          ]),
          builder: (context, _) => FadeTransition(
            opacity: _entryOpacity,
            child: Transform.scale(
              scale: _entryScale.value,
              child: Transform.translate(
                offset: Offset(0, _floatY.value),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // ── Glow ring ──────────────────────
                    Container(
                      width: 110.w,
                      height: 110.h,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: glowColor.withOpacity(_glowOpacity.value),
                            blurRadius: _glowRadius.value,
                            spreadRadius: _glowRadius.value * 0.25,
                          ),
                        ],
                      ),
                    ),

                    // ── Outer soft ring ────────────────
                    Container(
                      width: 110.w,
                      height: 110.h,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isDark
                            ? glowColor.withOpacity(0.1)
                            : glowColor.withOpacity(0.12),
                      ),
                    ),

                    // ── Inner gradient circle ──────────
                    Container(
                      width: 78.w,
                      height: 78.h,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: widget.gradient,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: glowColor.withOpacity(0.35),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Icon(
                        widget.icon,
                        size: 34.sp,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: 20.h),

        // ── Title ─────────────────────────────────────
        Text(
          widget.title,
          style: textTheme.displaySmall,
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 6.h),

        // ── Subtitle ──────────────────────────────────
        Text(
          widget.subtitle,
          style: textTheme.bodyLarge?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}