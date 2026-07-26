import 'package:edtech/core/theme/app_themes.dart';
import 'package:flutter/material.dart';

/// The 28-bar level meter from the design.
///
/// Fewer samples than bars — the first moments of a take — are padded on the
/// left so the wave grows in from the trailing edge instead of jumping.
class WaveformBars extends StatelessWidget {
  final List<double> levels;
  final Color color;
  final int barCount;

  const WaveformBars({
    super.key,
    required this.levels,
    this.color = AppColors.primaryMuted,
    this.barCount = 28,
  });

  static const double _minHeight = 8;
  static const double _maxHeight = 34;

  @override
  Widget build(BuildContext context) {
    final padded = List<double>.filled(barCount, 0.0)
      ..setRange(
        barCount - levels.length.clamp(0, barCount),
        barCount,
        levels.length > barCount
            ? levels.sublist(levels.length - barCount)
            : levels,
      );

    return SizedBox(
      height: 40,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          for (final level in padded)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 1.5),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 140),
                width: 3,
                height: _minHeight + (_maxHeight - _minHeight) * level,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
