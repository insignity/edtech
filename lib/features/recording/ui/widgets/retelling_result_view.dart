import 'dart:ui';

import 'package:edtech/core/theme/app_themes.dart';
import 'package:edtech/features/recording/ui/widgets/score_band_colors.dart';
import 'package:flutter/material.dart';

import '../../../../shared/extensions/extensions.dart';
import '../../models/retelling_result.dart';
import 'score_ring.dart';
import 'skill_bar.dart';

/// The graded result itself — score, skills, pace, feedback and transcript.
///
/// Shared by the screen shown straight after a recording and by the one reached
/// from history; those differ only in their header and the actions below.
class RetellingResultView extends StatefulWidget {
  final RetellingResult result;

  /// Hidden when there is nothing to compare against, so history rows for a
  /// first attempt do not claim "+0 vs last attempt".
  final bool showDelta;

  const RetellingResultView({
    super.key,
    required this.result,
    this.showDelta = true,
  });

  @override
  State<RetellingResultView> createState() => _RetellingResultViewState();
}

class _RetellingResultViewState extends State<RetellingResultView> {
  bool _transcriptOpen = false;

  RetellingResult get result => widget.result;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      children: [
        _ScoreHeadline(result: result, showDelta: widget.showDelta),
        const SizedBox(height: 22),
        SkillBar(label: 'Fluency', value: result.fluency),
        const SizedBox(height: 14),
        SkillBar(label: 'Grammar', value: result.grammar),
        const SizedBox(height: 14),
        SkillBar(label: 'Vocabulary', value: result.vocabulary),
        const SizedBox(height: 22),
        _PaceRow(wpm: result.wpm),
        const SizedBox(height: 22),
        _Feedback(text: result.feedback),
        const SizedBox(height: 22),
        _Transcript(
          result: result,
          isOpen: _transcriptOpen,
          onToggle: () => setState(() => _transcriptOpen = !_transcriptOpen),
        ),
      ],
    );
  }
}

class _ScoreHeadline extends StatelessWidget {
  final RetellingResult result;
  final bool showDelta;

  const _ScoreHeadline({required this.result, required this.showDelta});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ScoreRing(score: result.score, color: bandColor(result.band)),
        if (showDelta) ...[
          const SizedBox(height: 8),
          Text(
            result.deltaLabel,
            style: context.text.labelMedium!.copyWith(
              fontWeight: FontWeight.w700,
              color: result.improved ? AppColors.success : AppColors.error,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ],
    );
  }
}

class _PaceRow extends StatelessWidget {
  final int wpm;

  const _PaceRow({required this.wpm});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.grayLight,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Speaking pace',
            style: context.text.titleMedium!.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: '$wpm WPM ',
                  style: context.text.titleMedium!.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkText,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
                TextSpan(
                  text:
                      '(target ${RetellingResult.paceFloor}–'
                      '${RetellingResult.paceCeiling})',
                  style: context.text.labelMedium!.copyWith(
                    color: AppColors.grayMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Feedback extends StatelessWidget {
  final String text;

  const _Feedback({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'AI feedback',
            style: context.text.labelMedium!.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.primaryDeep,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            text,
            style: context.text.bodyMedium!.copyWith(
              color: AppColors.primaryDeep,
            ),
          ),
        ],
      ),
    );
  }
}

class _Transcript extends StatelessWidget {
  final RetellingResult result;
  final bool isOpen;
  final VoidCallback onToggle;

  const _Transcript({
    required this.result,
    required this.isOpen,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(height: 1),
        InkWell(
          onTap: onToggle,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 2),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Transcript with errors',
                  style: context.text.titleMedium!.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkText,
                  ),
                ),
                AnimatedRotation(
                  turns: isOpen ? 0.5 : 0,
                  duration: const Duration(milliseconds: 180),
                  child: const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: AppColors.gray,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (isOpen)
          Padding(
            padding: const EdgeInsets.fromLTRB(2, 0, 2, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  result.transcript,
                  style: context.text.bodyMedium!.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.7,
                  ),
                ),
                const SizedBox(height: 10),
                for (final correction in result.corrections)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Text.rich(
                      TextSpan(
                        style: context.text.labelMedium!.copyWith(
                          fontWeight: FontWeight.w400,
                          color: AppColors.error,
                        ),
                        children: [
                          TextSpan(text: '"${correction.wrong}" → '),
                          TextSpan(
                            text: '"${correction.right}"',
                            style: const TextStyle(color: AppColors.success),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}
