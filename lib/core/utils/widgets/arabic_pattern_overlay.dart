import 'package:flutter/material.dart';

class ArabicPatternOverlay extends StatelessWidget {
  const ArabicPatternOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Opacity(
        opacity: 0.03,
        child: CustomPaint(
          painter: PatternPainter(),
        ),
      ),
    );
  }
}

class PatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    const spacing = 60.0;

    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        // Dot 1 - orange
        paint.color = const Color(0x1AFF6B35);
        canvas.drawCircle(
          Offset(x + spacing * 0.2, y + spacing * 0.3),
          2,
          paint,
        );
        // Dot 2 - secondary
        paint.color = const Color(0x1AF7931E);
        canvas.drawCircle(
          Offset(x + spacing * 0.8, y + spacing * 0.7),
          2,
          paint,
        );
        // Dot 3 - teal
        paint.color = const Color(0x1A4ECDC4);
        canvas.drawCircle(
          Offset(x + spacing * 0.4, y + spacing * 0.8),
          2,
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}