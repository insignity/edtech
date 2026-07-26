import 'dart:math' as math;

import 'package:edtech/core/theme/app_themes.dart';
import 'package:flutter/material.dart';

import '../../../../shared/extensions/extensions.dart';

/// The big score dial: a track, an arc filled to the score, and the number.
class ScoreRing extends StatelessWidget {
  final int score;
  final Color color;
  final double size;

  const ScoreRing({
    super.key,
    required this.score,
    required this.color,
    this.size = 160,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _RingPainter(
          progress: (score / 100).clamp(0.0, 1.0),
          color: color,
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$score',
                style: context.text.displaySmall!.copyWith(
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              Text('/ 100', style: context.text.labelMedium),
            ],
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final Color color;

  const _RingPainter({required this.progress, required this.color});

  static const double _stroke = 12;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final center = rect.center;
    final radius = (size.shortestSide - _stroke) / 2;

    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = _stroke
      ..color = AppColors.grayLight;
    canvas.drawCircle(center, radius, track);

    if (progress <= 0) return;

    final arc = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = _stroke
      ..strokeCap = StrokeCap.round
      ..color = color;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2, // start at twelve o'clock
      2 * math.pi * progress,
      false,
      arc,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.progress != progress || old.color != color;
}
