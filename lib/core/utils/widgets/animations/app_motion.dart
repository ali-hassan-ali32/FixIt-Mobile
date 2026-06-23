import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

abstract final class AppMotionDurations {
  static const Duration micro = Duration(milliseconds: 110);
  static const Duration short = Duration(milliseconds: 180);
  static const Duration medium = Duration(milliseconds: 280);
  static const Duration long = Duration(milliseconds: 420);
}

class AppTapScale extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;
  final double pressedScale;
  final bool enableHaptics;
  final Duration duration;
  final Curve curve;
  final String? semanticLabel;

  const AppTapScale({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.borderRadius,
    this.padding,
    this.pressedScale = 0.97,
    this.enableHaptics = true,
    this.duration = AppMotionDurations.micro,
    this.curve = Curves.easeOutCubic,
    this.semanticLabel,
  });

  @override
  State<AppTapScale> createState() => _AppTapScaleState();
}

class _AppTapScaleState extends State<AppTapScale> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed == value || !mounted) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final isEnabled = widget.onTap != null || widget.onLongPress != null;

    Widget child = Padding(
      padding: widget.padding ?? EdgeInsets.zero,
      child: widget.child,
    );

    child = AnimatedScale(
      scale: _pressed && isEnabled ? widget.pressedScale : 1,
      duration: widget.duration,
      curve: widget.curve,
      child: child,
    );

    if (!isEnabled) {
      return Semantics(
        label: widget.semanticLabel,
        child: child,
      );
    }

    return Semantics(
      button: true,
      label: widget.semanticLabel,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: widget.borderRadius,
          splashFactory: InkSparkle.splashFactory,
          onTap: widget.onTap,
          onLongPress: widget.onLongPress,
          onTapDown: (_) {
            _setPressed(true);
            if (widget.enableHaptics) {
              HapticFeedback.selectionClick();
            }
          },
          onTapUp: (_) => _setPressed(false),
          onTapCancel: () => _setPressed(false),
          child: child,
        ),
      ),
    );
  }
}

class AppSharedAxisSwitcher extends StatelessWidget {
  final Widget child;
  final Object? transitionKey;
  final SharedAxisTransitionType transitionType;
  final Duration duration;
  final bool reverse;
  final bool fillColor;

  const AppSharedAxisSwitcher({
    super.key,
    required this.child,
    this.transitionKey,
    this.transitionType = SharedAxisTransitionType.scaled,
    this.duration = AppMotionDurations.medium,
    this.reverse = false,
    this.fillColor = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = fillColor ? Theme.of(context).colorScheme.surface : Colors.transparent;

    return PageTransitionSwitcher(
      duration: duration,
      reverse: reverse,
      transitionBuilder: (widgetChild, animation, secondaryAnimation) {
        return SharedAxisTransition(
          animation: animation,
          secondaryAnimation: secondaryAnimation,
          transitionType: transitionType,
          fillColor: color,
          child: widgetChild,
        );
      },
      child: KeyedSubtree(
        key: ValueKey<Object?>(transitionKey ?? child.key ?? child.runtimeType),
        child: child,
      ),
    );
  }
}
