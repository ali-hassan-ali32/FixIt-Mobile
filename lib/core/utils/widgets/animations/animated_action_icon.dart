import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AnimatedActionIcon extends StatefulWidget {
  final IconData icon;
  final Color primaryColor;
  final Color secondaryColor;

  const AnimatedActionIcon({
    super.key,
    required this.icon,
    required this.primaryColor,
    required this.secondaryColor,
  });

  @override
  State<AnimatedActionIcon> createState() => _AnimatedActionIconState();
}

class _AnimatedActionIconState extends State<AnimatedActionIcon>
    with TickerProviderStateMixin {

  late final AnimationController _entryController;
  late final AnimationController _floatController;
  late final AnimationController _glowController;

  late final Animation<double> _entryScale;
  late final Animation<double> _entryOpacity;
  late final Animation<double> _floatY;
  late final Animation<double> _glowRadius;

  @override
  void initState() {
    super.initState();

    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _entryScale = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _entryController, curve: Curves.elasticOut),
    );

    _entryOpacity = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _entryController, curve: Curves.easeOut),
    );

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _floatY = Tween(begin: -6.0, end: 6.0).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _glowRadius = Tween(begin: 12.0, end: 28.0).animate(
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: Listenable.merge([
        _entryController,
        _floatController,
        _glowController,
      ]),
      builder: (_, __) {
        return FadeTransition(
          opacity: _entryOpacity,
          child: Transform.scale(
            scale: _entryScale.value,
            child: Transform.translate(
              offset: Offset(0, _floatY.value),
              child: Stack(
                alignment: Alignment.center,
                children: [

                  /// Glow ring
                  Container(
                    width: 110.w,
                    height: 110.h,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: widget.primaryColor.withOpacity(0.25),
                          blurRadius: _glowRadius.value,
                          spreadRadius: _glowRadius.value * 0.3,
                        ),
                      ],
                    ),
                  ),

                  /// Outer circle
                  Container(
                    width: 110.w,
                    height: 110.h,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isDark
                          ? widget.primaryColor.withOpacity(0.1)
                          : widget.primaryColor.withOpacity(0.08),
                    ),
                  ),

                  /// Inner gradient circle
                  Container(
                    width: 80.w,
                    height: 80.h,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          widget.primaryColor,
                          widget.secondaryColor,
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: widget.primaryColor.withOpacity(0.35),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Icon(
                      widget.icon,
                      size: 36.sp,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}