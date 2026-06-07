import 'package:flutter/material.dart';

import '../../../../core/theme/app_themes.dart';
import '../../../../shared/extensions/extensions.dart';

class SubscribedTile extends StatelessWidget {
  const SubscribedTile({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.successLight,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_circle_rounded, size: 14, color: AppColors.success),
          const SizedBox(width: 4),
          Text(
            'Enrolled',
            style: context.text.labelMedium! + AppColors.success,
          ),
        ],
      ),
    );
  }
}
