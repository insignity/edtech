import 'dart:ui';

import 'package:auto_route/auto_route.dart';
import 'package:edtech/core/router/app_router.dart';
import 'package:edtech/core/theme/app_themes.dart';
import 'package:edtech/features/recording/models/retelling_result.dart';
import 'package:edtech/features/recording/models/speaking_attempt.dart';
import 'package:edtech/features/recording/ui/widgets/score_band_colors.dart';
import 'package:edtech/features/speaking_history/models/speaking_history.dart';
import 'package:edtech/shared/extensions/extensions.dart';
import 'package:flutter/material.dart';

/// One lesson in the history list, collapsed to its headline result and
/// expandable into the individual attempts behind it.
class HistoryLessonCard extends StatefulWidget {
  final SpeakingHistoryLesson lesson;

  const HistoryLessonCard(this.lesson, {super.key});

  @override
  State<HistoryLessonCard> createState() => _HistoryLessonCardState();
}

class _HistoryLessonCardState extends State<HistoryLessonCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final lesson = widget.lesson;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            onTap: lesson.attempts.isEmpty
                ? null
                : () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          lesson.title,
                          style: context.text.titleLarge,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 12),
                      _ScoreBadge(score: lesson.latestScore),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      if (lesson.level != null && lesson.level!.isNotEmpty)
                        _Chip(text: _levelLabel(lesson.level!)),
                      _Chip(
                        text:
                            '${lesson.attempts.length} '
                            '${lesson.attempts.length == 1 ? 'attempt' : 'attempts'}',
                      ),
                      if (lesson.latestAttemptAt != null)
                        Text(
                          formatHistoryDate(lesson.latestAttemptAt!),
                          style: context.text.labelMedium! + AppColors.gray,
                        ),
                    ],
                  ),
                  if (lesson.attempts.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          _expanded ? 'Hide attempts' : 'Show attempts',
                          style: context.text.labelMedium! + AppColors.primary,
                        ),
                        Icon(
                          _expanded
                              ? Icons.keyboard_arrow_up_rounded
                              : Icons.keyboard_arrow_down_rounded,
                          size: 20,
                          color: AppColors.primary,
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 180),
            crossFadeState: _expanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            firstChild: const SizedBox(width: double.infinity),
            secondChild: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var index = 0; index < lesson.attempts.length; index++)
                  _AttemptRow(
                    attempt: lesson.attempts[index],
                    lessonId: lesson.id,
                    lessonTitle: lesson.title,
                    delta: _deltaAt(lesson.attempts, index),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Score change between the attempt at [index] and the graded one before it.
///
/// The list runs newest first, so "before" means further down it. Null when
/// either side has no score — there is then nothing honest to show.
int? _deltaAt(List<SpeakingAttemptSummary> attempts, int index) {
  final current = attempts[index].overallScore;
  if (current == null) return null;

  for (var next = index + 1; next < attempts.length; next++) {
    final previous = attempts[next].overallScore;
    if (previous != null) return current - previous;
  }
  return null;
}

class _AttemptRow extends StatelessWidget {
  final SpeakingAttemptSummary attempt;
  final String lessonId;
  final String lessonTitle;
  final int? delta;

  const _AttemptRow({
    required this.attempt,
    required this.lessonId,
    required this.lessonTitle,
    required this.delta,
  });

  @override
  Widget build(BuildContext context) {
    final graded = attempt.overallScore != null;

    return InkWell(
      // Only a graded attempt has a breakdown to open.
      onTap: graded
          ? () => context.router.push(
              AttemptDetailsRoute(
                attemptId: attempt.id,
                lessonId: lessonId,
                lessonTitle: lessonTitle,
                attemptNumber: attempt.attemptNumber,
                delta: delta,
              ),
            )
          : null,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 34,
              child: Text(
                '#${attempt.attemptNumber}',
                style: context.text.labelMedium! + AppColors.gray,
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (graded)
                    Text(
                      [
                        formatAttemptDuration(attempt.durationSeconds),
                        if (attempt.wordsPerMinute != null)
                          '${attempt.wordsPerMinute!.round()} wpm',
                      ].join(' · '),
                      style: context.text.bodyMedium,
                    )
                  else
                    Text(
                      _statusLabel(attempt.status),
                      style: context.text.bodyMedium! + AppColors.gray,
                    ),
                  if (attempt.createdAt != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      formatHistoryDateTime(attempt.createdAt!),
                      style: context.text.labelMedium! + AppColors.grayMuted,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 12),
            if (graded) ...[
              Text(
                '${attempt.overallScore}',
                style:
                    context.text.titleLarge!
                        .weight(FontWeight.w700)
                        .copyWith(
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ) +
                    bandColor(ScoreBand.of(attempt.overallScore!)),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.grayMuted,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// The headline number: the latest graded result for the lesson.
class _ScoreBadge extends StatelessWidget {
  final int? score;

  const _ScoreBadge({required this.score});

  @override
  Widget build(BuildContext context) {
    if (score == null) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.grayLight,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          '—',
          style: context.text.titleLarge! + AppColors.grayMuted,
        ),
      );
    }

    final band = ScoreBand.of(score!);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: bandBackground(band),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '$score',
        style:
            context.text.titleLarge!
                .weight(FontWeight.w700)
                .copyWith(fontFeatures: const [FontFeature.tabularFigures()]) +
            bandColor(band),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String text;

  const _Chip({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: context.text.labelMedium! + AppColors.primaryDeep,
      ),
    );
  }
}

String _statusLabel(SpeakingAttemptStatus status) => switch (status) {
  SpeakingAttemptStatus.failed => 'Processing failed',
  SpeakingAttemptStatus.completed => 'No score',
  _ => 'Still processing…',
};

/// `upper-intermediate` reads better as `Upper intermediate`.
String _levelLabel(String level) {
  final spaced = level.replaceAll('-', ' ').replaceAll('_', ' ');
  if (spaced.isEmpty) return spaced;
  return spaced[0].toUpperCase() + spaced.substring(1);
}

String formatAttemptDuration(double? seconds) {
  if (seconds == null) return '—';
  final total = seconds.round();
  return '${total ~/ 60}:${(total % 60).toString().padLeft(2, '0')}';
}

/// `2 Aug 2026`, dropping the year while it is the current one.
///
/// Written out by hand: `intl` is not a dependency and one date format does not
/// justify adding it.
String formatHistoryDate(DateTime utc) {
  final date = utc.toLocal();
  final now = DateTime.now();
  final label = '${date.day} ${_months[date.month - 1]}';
  return date.year == now.year ? label : '$label ${date.year}';
}

String formatHistoryDateTime(DateTime utc) {
  final date = utc.toLocal();
  final time =
      '${date.hour.toString().padLeft(2, '0')}:'
      '${date.minute.toString().padLeft(2, '0')}';
  return '${formatHistoryDate(utc)}, $time';
}

const List<String> _months = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];
