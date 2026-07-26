import 'package:edtech/core/theme/app_themes.dart';
import 'package:edtech/features/recording/models/analysis_step.dart';
import 'package:flutter/material.dart';

import '../../../../shared/extensions/extensions.dart';

/// One row per analysis stage: done, in flight, or still waiting.
class AnalysisChecklist extends StatelessWidget {
  final List<AnalysisStep> completed;

  const AnalysisChecklist({super.key, required this.completed});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final step in AnalysisStep.values)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 7),
            child: Row(
              children: [
                _Marker(status: _statusOf(step)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    step.label,
                    style: context.text.titleMedium!.copyWith(
                      color: _statusOf(step) == _Status.pending
                          ? AppColors.grayMuted
                          : AppColors.darkText,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  _Status _statusOf(AnalysisStep step) {
    if (completed.contains(step)) return _Status.done;
    // The first step we have not confirmed is the one being worked on.
    final next = AnalysisStep.values.firstWhere(
      (candidate) => !completed.contains(candidate),
      orElse: () => AnalysisStep.values.last,
    );
    return step == next ? _Status.active : _Status.pending;
  }
}

enum _Status { done, active, pending }

class _Marker extends StatelessWidget {
  final _Status status;

  const _Marker({required this.status});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 20,
      height: 20,
      child: switch (status) {
        _Status.done => const DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.success,
          ),
          child: Icon(Icons.check_rounded, size: 13, color: AppColors.white),
        ),
        _Status.active => const CircularProgressIndicator(
          strokeWidth: 2.5,
          color: AppColors.primary,
          backgroundColor: AppColors.primaryLight,
        ),
        _Status.pending => DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.border, width: 2),
          ),
        ),
      },
    );
  }
}
