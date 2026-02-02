import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/audio_provider.dart';
import 'dart:math' as math;

class AudioVisualizer extends StatefulWidget {
  final bool isDark;
  final double screenHeight;

  const AudioVisualizer({
    super.key,
    required this.isDark,
    required this.screenHeight,
  });

  @override
  State<AudioVisualizer> createState() => _AudioVisualizerState();
}

class _AudioVisualizerState extends State<AudioVisualizer> with TickerProviderStateMixin {
  late AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(vsync: this, duration: const Duration(milliseconds: 2000))..repeat();
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.screenHeight * 0.1,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Consumer<AudioProvider>(
        builder: (context, audioProvider, child) {
          if (audioProvider.isPlaying) {
            return AnimatedBuilder(
              animation: _waveController,
              builder: (context, child) => CustomPaint(
                painter: AudioWavePainter(
                  animationValue: _waveController.value,
                  isDark: widget.isDark,
                ),
              ),
            );
          } else {
            return Center(
              child: Container(
                height: 2,
                width: 100,
                decoration: BoxDecoration(
                  color: widget.isDark ? Colors.white10 : Colors.blueGrey.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
            );
          }
        },
      ),
    );
  }
}

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
