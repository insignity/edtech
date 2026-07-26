import 'package:auto_route/auto_route.dart';
import 'package:edtech/core/router/app_router.dart';
import 'package:edtech/core/theme/app_themes.dart';
import 'package:flutter/material.dart';

import '../../../../shared/extensions/extensions.dart';
import '../../models/retelling_result.dart';
import '../widgets/score_ring.dart';
import '../widgets/skill_bar.dart';

@RoutePage()
class ResultsPage extends StatefulWidget {
  final RetellingResult result;
  final String lessonId;
  final String lessonTitle;

  const ResultsPage({
    super.key,
    required this.result,
    required this.lessonId,
    this.lessonTitle = 'Retelling',
  });

  @override
  State<ResultsPage> createState() => _ResultsPageState();
}

class _ResultsPageState extends State<ResultsPage> {
  bool _transcriptOpen = false;

  RetellingResult get result => widget.result;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const _Header(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                children: [
                  _ScoreHeadline(result: result),
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
                    onToggle: () =>
                        setState(() => _transcriptOpen = !_transcriptOpen),
                  ),
                ],
              ),
            ),
            _Actions(lessonId: widget.lessonId, lessonTitle: widget.lessonTitle),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.grayLight)),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => context.router.maybePop(),
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
            color: AppColors.darkText,
          ),
          Text('Results', style: context.text.titleLarge),
        ],
      ),
    );
  }
}

class _ScoreHeadline extends StatelessWidget {
  final RetellingResult result;

  const _ScoreHeadline({required this.result});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ScoreRing(score: result.score, color: _bandColor(result.band)),
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
    );
  }
}

Color _bandColor(ScoreBand band) => switch (band) {
  ScoreBand.strong => AppColors.success,
  ScoreBand.fair => AppColors.warning,
  ScoreBand.weak => AppColors.error,
};

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

class _Actions extends StatelessWidget {
  final String lessonId;
  final String lessonTitle;

  const _Actions({required this.lessonId, required this.lessonTitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.grayLight)),
      ),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              // Replace so Back from a fresh take does not land on stale results.
              onPressed: () => context.router.replace(
                RecordingRoute(lessonId: lessonId, lessonTitle: lessonTitle),
              ),
              child: const Text('Try again'),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: OutlinedButton(
              onPressed: () => context.router.replaceAll([NavBarRoute()]),
              child: const Text('Next'),
            ),
          ),
        ],
      ),
    );
  }
}
