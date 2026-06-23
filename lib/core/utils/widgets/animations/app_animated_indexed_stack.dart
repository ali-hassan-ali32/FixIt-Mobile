import 'package:flutter/material.dart';

import 'app_motion.dart';

class AppAnimatedIndexedStack extends StatefulWidget {
  final int index;
  final List<Widget> children;
  final Duration duration;
  final Curve curve;
  final Offset initialOffset;
  final double initialScale;

  const AppAnimatedIndexedStack({
    super.key,
    required this.index,
    required this.children,
    this.duration = AppMotionDurations.medium,
    this.curve = Curves.easeOutCubic,
    this.initialOffset = const Offset(0, 0.03),
    this.initialScale = 0.985,
  });

  @override
  State<AppAnimatedIndexedStack> createState() => _AppAnimatedIndexedStackState();
}

class _AppAnimatedIndexedStackState extends State<AppAnimatedIndexedStack>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _fades;
  late List<Animation<Offset>> _slides;
  late List<Animation<double>> _scales;

  @override
  void initState() {
    super.initState();
    _createAnimations();
  }

  @override
  void didUpdateWidget(covariant AppAnimatedIndexedStack oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.children.length != widget.children.length) {
      _disposeControllers();
      _createAnimations();
      return;
    }

    if (oldWidget.index != widget.index && widget.index >= 0 && widget.index < _controllers.length) {
      _controllers[oldWidget.index].reverse();
      _controllers[widget.index]
        ..value = 0
        ..forward();
    }
  }

  void _createAnimations() {
    _controllers = List.generate(widget.children.length, (i) {
      return AnimationController(
        vsync: this,
        duration: widget.duration,
        reverseDuration: Duration(milliseconds: (widget.duration.inMilliseconds * 0.8).round()),
        value: i == widget.index ? 1 : 0,
      );
    });

    _fades = _controllers
        .map((controller) => CurvedAnimation(parent: controller, curve: widget.curve))
        .toList();

    _slides = _controllers
        .map(
          (controller) => Tween<Offset>(begin: widget.initialOffset, end: Offset.zero).animate(
            CurvedAnimation(parent: controller, curve: widget.curve),
          ),
        )
        .toList();

    _scales = _controllers
        .map(
          (controller) => Tween<double>(begin: widget.initialScale, end: 1).animate(
            CurvedAnimation(parent: controller, curve: widget.curve),
          ),
        )
        .toList();
  }

  void _disposeControllers() {
    for (final controller in _controllers) {
      controller.dispose();
    }
  }

  @override
  void dispose() {
    _disposeControllers();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: List.generate(widget.children.length, (i) {
        return AnimatedBuilder(
          animation: _controllers[i],
          builder: (context, _) {
            final visible = i == widget.index || _controllers[i].value > 0;
            if (!visible) {
              return const SizedBox.shrink();
            }

            return IgnorePointer(
              ignoring: i != widget.index,
              child: TickerMode(
                enabled: i == widget.index || _controllers[i].isAnimating,
                child: FadeTransition(
                  opacity: _fades[i],
                  child: SlideTransition(
                    position: _slides[i],
                    child: ScaleTransition(
                      scale: _scales[i],
                      child: KeyedSubtree(
                        key: ValueKey('animated-stack-$i'),
                        child: widget.children[i],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
