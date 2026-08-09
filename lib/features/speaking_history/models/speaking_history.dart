import 'package:edtech/core/utils/types.dart';
import 'package:edtech/features/recording/models/speaking_attempt.dart';

/// One lesson the learner has spoken on, with every attempt they made at it.
class SpeakingHistoryLesson {
  final String id;
  final String title;
  final String? level;
  final DateTime? latestAttemptAt;

  /// Newest first, as the backend returns them.
  final List<SpeakingAttemptSummary> attempts;

  const SpeakingHistoryLesson({
    required this.id,
    required this.title,
    required this.level,
    required this.latestAttemptAt,
    required this.attempts,
  });

  factory SpeakingHistoryLesson.fromJson(Json json) => SpeakingHistoryLesson(
    id: json['id'] as String,
    title: json['title'] as String? ?? '',
    level: json['level'] as String?,
    latestAttemptAt: DateTime.tryParse(
      json['latest_attempt_at'] as String? ?? '',
    ),
    attempts: (json['attempts'] as List<dynamic>? ?? [])
        .map((item) => SpeakingAttemptSummary.fromJson(item as Json))
        .toList(),
  );

  /// The best score across graded attempts, or null while none has finished.
  int? get bestScore {
    int? best;
    for (final attempt in attempts) {
      final score = attempt.overallScore;
      if (score != null && (best == null || score > best)) best = score;
    }
    return best;
  }

  /// Score of the most recent graded attempt — the list is newest first, so the
  /// first one carrying a score is the latest verdict.
  int? get latestScore {
    for (final attempt in attempts) {
      if (attempt.overallScore != null) return attempt.overallScore;
    }
    return null;
  }

  /// How much the latest graded attempt moved against the one before it.
  /// Null unless there are two graded attempts to compare.
  int? get scoreDelta {
    final graded = attempts
        .where((attempt) => attempt.overallScore != null)
        .toList();
    if (graded.length < 2) return null;
    return graded[0].overallScore! - graded[1].overallScore!;
  }
}

/// One page of [SpeakingHistoryLesson]s from `/me/speaking-history/`.
class SpeakingHistoryModel {
  final int count;
  final String? next;
  final String? previous;
  final List<SpeakingHistoryLesson> lessons;

  const SpeakingHistoryModel({
    required this.count,
    required this.lessons,
    this.next,
    this.previous,
  });

  factory SpeakingHistoryModel.fromJson(Json json) => SpeakingHistoryModel(
    count: json['count'] as int? ?? 0,
    next: json['next'] as String?,
    previous: json['previous'] as String?,
    lessons: (json['results'] as List<dynamic>? ?? [])
        .map((item) => SpeakingHistoryLesson.fromJson(item as Json))
        .toList(),
  );

  bool get hasMore => next != null;
}
