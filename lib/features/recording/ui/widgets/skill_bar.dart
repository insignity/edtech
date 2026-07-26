import 'package:edtech/core/theme/app_themes.dart';
import 'package:flutter/material.dart';

import '../../../../shared/extensions/extensions.dart';

/// A labelled 0–100 meter: name on the left, value on the right, bar below.
class SkillBar extends StatelessWidget {
  final String label;
  final int value;

  const SkillBar({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: context.text.titleMedium!.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            Text(
              '$value',
              style: context.text.titleMedium!.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.darkText,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: (value / 100).clamp(0.0, 1.0),
            minHeight: 6,
            backgroundColor: AppColors.grayLight,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }
}
