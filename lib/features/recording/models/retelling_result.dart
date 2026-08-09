import 'package:edtech/features/recording/models/speaking_attempt.dart';

/// How a score reads at a glance. The palette assigns one colour per band.
enum ScoreBand {
  strong,
  fair,
  weak;

  static ScoreBand of(int score) => switch (score) {
    >= 90 => ScoreBand.strong,
    >= 70 => ScoreBand.fair,
    _ => ScoreBand.weak,
  };
}

class Correction {
  final String wrong;
  final String right;

  /// Why the correction was made. Empty when the backend does not say.
  final String explanation;

  const Correction({
    required this.wrong,
    required this.right,
    this.explanation = '',
  });

  factory Correction.fromJson(Map<String, dynamic> json) => Correction(
    wrong: json['wrong'] as String,
    right: json['right'] as String,
    explanation: json['explanation'] as String? ?? '',
  );
}

class RetellingResult {
  final int score;

  /// Change against the previous attempt; negative means a step back.
  final int delta;

  final int fluency;
  final int grammar;
  final int vocabulary;

  /// Words per minute. The design calls 120–150 the comfortable range.
  final int wpm;

  final String feedback;
  final String transcript;
  final List<Correction> corrections;

  const RetellingResult({
    required this.score,
    required this.delta,
    required this.fluency,
    required this.grammar,
    required this.vocabulary,
    required this.wpm,
    required this.feedback,
    required this.transcript,
    this.corrections = const [],
  });

  static const int paceFloor = 120;
  static const int paceCeiling = 150;

  ScoreBand get band => ScoreBand.of(score);

  bool get improved => delta >= 0;

  String get deltaLabel => '${improved ? '+' : ''}$delta vs last attempt';

  /// Folds a graded attempt into what the results screen renders.
  ///
  /// [delta] is worked out separately: the pipeline compares pace and fillers
  /// against the previous attempt but not the overall score.
  factory RetellingResult.fromAttempt(
    SpeakingAttempt attempt, {
    int delta = 0,
  }) {
    final feedback = attempt.feedback!;
    return RetellingResult(
      score: feedback.overallScore,
      delta: delta,
      fluency: feedback.fluencyScore,
      grammar: feedback.grammarScore,
      vocabulary: feedback.vocabularyScore,
      wpm: attempt.metrics?.wordsPerMinute.round() ?? 0,
      feedback: feedback.shortFeedback,
      transcript: attempt.transcript,
      corrections: feedback.corrections
          .map(
            (item) => Correction(
              wrong: item.original,
              right: item.corrected,
              explanation: item.explanation,
            ),
          )
          .toList(),
    );
  }

  factory RetellingResult.fromJson(Map<String, dynamic> json) =>
      RetellingResult(
        score: json['score'] as int,
        delta: json['delta'] as int? ?? 0,
        fluency: json['fluency'] as int,
        grammar: json['grammar'] as int,
        vocabulary: json['vocabulary'] as int,
        wpm: json['wpm'] as int,
        feedback: json['feedback'] as String? ?? '',
        transcript: json['transcript'] as String? ?? '',
        corrections: (json['corrections'] as List<dynamic>? ?? [])
            .map((item) => Correction.fromJson(item as Map<String, dynamic>))
            .toList(),
      );
}
