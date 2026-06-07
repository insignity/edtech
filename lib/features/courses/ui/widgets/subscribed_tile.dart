import 'package:flutter/material.dart';

import '../../../../core/theme/app_themes.dart';
import '../../../../shared/extensions/extensions.dart';

class SubscribedTile extends StatelessWidget {
  const SubscribedTile({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: .symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.primary.withAlpha(100), width: 3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        "Subscribed",
        textAlign: TextAlign.center,
        style: context.text.bodyLarge?.copyWith(
          color: AppColors.primary.withAlpha(150),
        ),
      ),
    );
    ;
  }
}
