import 'package:edtech/core/theme/app_themes.dart';
import 'package:flutter/material.dart';

/// The tinted mic disc with a halo pulsing outward, as in the design.
class MicPulse extends StatefulWidget {
  const MicPulse({super.key});

  @override
  State<MicPulse> createState() => _MicPulseState();
}

class _MicPulseState extends State<MicPulse>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  )..repeat();

  static const double _size = 168;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _size + 44,
      height: _size + 44,
      child: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            AnimatedBuilder(
              animation: _controller,
              builder: (_, _) {
                final t = Curves.easeOut.transform(_controller.value);
                return Container(
                  width: _size + 44 * t,
                  height: _size + 44 * t,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary.withValues(alpha: 0.25 * (1 - t)),
                  ),
                );
              },
            ),
            Container(
              width: _size,
              height: _size,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryLight,
              ),
              child: const Icon(
                Icons.mic_rounded,
                size: 62,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
