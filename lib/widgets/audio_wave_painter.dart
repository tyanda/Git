import 'package:flutter/material.dart';
import 'dart:math' as math;

class AudioWavePainter extends CustomPainter {
  final double animationValue;
  final bool isDark;

  AudioWavePainter({required this.animationValue, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final double width = size.width;
    final double height = size.height;
    final double midY = height / 2;
    final List<Color> colors = isDark
        ? [Colors.cyanAccent, Colors.blueAccent, Colors.purpleAccent]
        : [Colors.blue, Colors.lightBlue, Colors.purple];

    final Gradient gradient = LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: colors.map((c) => c.withValues(alpha: 0.8)).toList(),
    );

    final Paint paint = Paint()
      ..shader = gradient.createShader(Rect.fromLTWH(0, 0, width, height))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;

    _drawOrganicWave(canvas, paint, width, midY, 1.0, 2, 1.0);
    _drawOrganicWave(canvas, paint, width, midY, 0.7, 3, 1.5);
    _drawOrganicWave(canvas, paint, width, midY, 0.4, 1, 0.5);
  }

  void _drawOrganicWave(Canvas canvas, Paint paint, double width, double midY, double amplitudeMult, int harmonics, double speedMult) {
    final path = Path();

    for (double x = 0; x <= width; x += 2) {
      double normX = x / width;
      double envelope = math.pow(math.sin(normX * math.pi), 1.5).toDouble();
      double wave = 0.0;
      for (int i = 1; i <= harmonics; i++) {
        double phase = animationValue * 2 * math.pi * speedMult * (i % 2 == 0 ? 1 : -1);
        wave += math.sin((normX * 4 * i * math.pi) + phase) / i;
      }
      double y = midY + wave * 20 * amplitudeMult * envelope;
      if (x == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    if (amplitudeMult >= 1.0) {
      final glowPaint = Paint()
        ..color = (isDark ? Colors.blueAccent : Colors.lightBlue).withValues(alpha: 0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 10.0
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
      canvas.drawPath(path, glowPaint);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant AudioWavePainter oldDelegate) => true;
}