import 'dart:convert';

import 'package:edtech/core/utils/types.dart';

/// Where an attempt is in the backend pipeline.
enum SpeakingAttemptStatus {
  created,
  uploaded,
  transcribing,
  analyzing,
  completed,
  failed;

  static SpeakingAttemptStatus parse(String? value) =>
      SpeakingAttemptStatus.values.firstWhere(
        (status) => status.name == value,
        // An unknown status is still in flight as far as the client cares —
        // polling keeps going instead of blowing up on a new backend state.
        orElse: () => SpeakingAttemptStatus.created,
      );

  bool get isTerminal =>
      this == SpeakingAttemptStatus.completed ||
      this == SpeakingAttemptStatus.failed;
}

/// The temporary S3 target handed back when an attempt is created.
///
/// Short-lived and sensitive: never log or persist [url].
/// Where the recording goes and what S3 demands alongside it.
///
/// The bucket takes a browser-style multipart POST: every entry of [fields] is
/// part of the signed policy and must be sent back verbatim, ahead of the file
/// itself. Content-Type lives in [fields] too — it is a form field here, not a
/// request header.
class AttemptUpload {
  final String url;
  final String method;

  /// Signed policy fields, sent unchanged and before the binary.
  final Map<String, String> fields;

  /// Form field the audio is attached under.
  final String fileField;

  /// Ceiling the policy enforces; exceeding it earns a 400 from S3, so the
  /// upload is stopped before it starts.
  final int maxSizeBytes;

  final int expiresIn;

  const AttemptUpload({
    required this.url,
    required this.method,
    required this.fields,
    required this.fileField,
    required this.maxSizeBytes,
    required this.expiresIn,
  });

  static const int defaultMaxSizeBytes = 20 * 1024 * 1024;

  factory AttemptUpload.fromJson(Json json) => AttemptUpload(
    url: json['url'] as String,
    method: json['method'] as String? ?? 'POST',
    fields:
        (json['fields'] as Map?)?.map(
          (key, value) => MapEntry(key.toString(), value.toString()),
        ) ??
        const {},
    fileField: json['file_field'] as String? ?? 'file',
    maxSizeBytes: json['max_size_bytes'] as int? ?? defaultMaxSizeBytes,
    expiresIn: json['expires_in'] as int? ?? 900,
  );
}

class AttemptMetrics {
  final double durationSeconds;
  final int wordCount;
  final double wordsPerMinute;
  final int fillerWordCount;

  const AttemptMetrics({
    required this.durationSeconds,
    required this.wordCount,
    required this.wordsPerMinute,
    required this.fillerWordCount,
  });

  factory AttemptMetrics.fromJson(Json json) => AttemptMetrics(
    durationSeconds: _toDouble(json['duration_seconds']),
    wordCount: _toInt(json['word_count']),
    wordsPerMinute: _toDouble(json['words_per_minute']),
    fillerWordCount: _toInt(json['filler_word_count']),
  );
}

/// Deltas against the previous attempt. Null on the first processed attempt.
class AttemptComparison {
  final int? previousAttemptNumber;
  final double durationDeltaSeconds;
  final double wordsPerMinuteDelta;
  final int fillerWordCountDelta;

  const AttemptComparison({
    required this.previousAttemptNumber,
    required this.durationDeltaSeconds,
    required this.wordsPerMinuteDelta,
    required this.fillerWordCountDelta,
  });

  factory AttemptComparison.fromJson(Json json) => AttemptComparison(
    previousAttemptNumber: json['previous_attempt_number'] as int?,
    durationDeltaSeconds: _toDouble(json['duration_delta_seconds']),
    wordsPerMinuteDelta: _toDouble(json['words_per_minute_delta']),
    fillerWordCountDelta: _toInt(json['filler_word_count_delta']),
  );
}

class AttemptCorrection {
  final String original;
  final String corrected;
  final String explanation;

  const AttemptCorrection({
    required this.original,
    required this.corrected,
    required this.explanation,
  });

  factory AttemptCorrection.fromJson(Json json) => AttemptCorrection(
    original: json['original'] as String? ?? '',
    corrected: json['corrected'] as String? ?? '',
    explanation: json['explanation'] as String? ?? '',
  );
}

/// The graded result. Carries more than the results screen shows today — key
/// points, the concise version and the next goal are parsed so the screen can
/// grow into them without another trip back to the contract.
class AttemptFeedback {
  final int overallScore;
  final int meaningScore;
  final int compressionScore;
  final int clarityScore;
  final int grammarScore;
  final int vocabularyScore;
  final int fluencyScore;
  final List<String> coveredKeyPoints;
  final List<String> missedKeyPoints;
  final List<String> unnecessaryDetails;
  final List<AttemptCorrection> corrections;
  final String shortFeedback;
  final String conciseVersion;
  final String nextGoal;

  const AttemptFeedback({
    required this.overallScore,
    required this.meaningScore,
    required this.compressionScore,
    required this.clarityScore,
    required this.grammarScore,
    required this.vocabularyScore,
    required this.fluencyScore,
    required this.coveredKeyPoints,
    required this.missedKeyPoints,
    required this.unnecessaryDetails,
    required this.corrections,
    required this.shortFeedback,
    required this.conciseVersion,
    required this.nextGoal,
  });

  factory AttemptFeedback.fromJson(Json json) => AttemptFeedback(
    overallScore: _toInt(json['overall_score']),
    meaningScore: _toInt(json['meaning_score']),
    compressionScore: _toInt(json['compression_score']),
    clarityScore: _toInt(json['clarity_score']),
    grammarScore: _toInt(json['grammar_score']),
    vocabularyScore: _toInt(json['vocabulary_score']),
    fluencyScore: _toInt(json['fluency_score']),
    coveredKeyPoints: _toStringList(json['covered_key_points']),
    missedKeyPoints: _toStringList(json['missed_key_points']),
    unnecessaryDetails: _toStringList(json['unnecessary_details']),
    corrections: (json['corrections'] as List<dynamic>? ?? [])
        .map((item) => AttemptCorrection.fromJson(asJson(item) ?? {}))
        .toList(),
    shortFeedback: json['short_feedback'] as String? ?? '',
    conciseVersion: json['concise_version'] as String? ?? '',
    nextGoal: json['next_goal'] as String? ?? '',
  );
}

/// The safe, user-facing failure the backend reports. Show [message] as is.
class AttemptError {
  final String code;
  final String message;

  const AttemptError({required this.code, required this.message});

  factory AttemptError.fromJson(Json json) => AttemptError(
    code: json['code'] as String? ?? 'unknown',
    message: json['message'] as String? ?? 'Processing failed.',
  );
}

class SpeakingAttempt {
  final String id;
  final String? lessonId;
  final int attemptNumber;
  final SpeakingAttemptStatus status;
  final String transcript;
  final AttemptMetrics? metrics;
  final AttemptComparison? comparison;
  final AttemptFeedback? feedback;
  final AttemptError? error;

  /// Only present on the create response.
  final AttemptUpload? upload;

  const SpeakingAttempt({
    required this.id,
    required this.lessonId,
    required this.attemptNumber,
    required this.status,
    this.transcript = '',
    this.metrics,
    this.comparison,
    this.feedback,
    this.error,
    this.upload,
  });

  factory SpeakingAttempt.fromJson(Json json) => SpeakingAttempt(
    id: json['id'] as String,
    lessonId: json['lesson_id'] as String?,
    attemptNumber: _toInt(json['attempt_number']),
    status: SpeakingAttemptStatus.parse(json['status'] as String?),
    transcript: json['transcript'] as String? ?? '',
    metrics: _parse(json['metrics'], AttemptMetrics.fromJson),
    comparison: _parse(json['comparison'], AttemptComparison.fromJson),
    feedback: _parse(json['feedback'], AttemptFeedback.fromJson),
    error: _parse(json['error'], AttemptError.fromJson),
    upload: _parse(json['upload'], AttemptUpload.fromJson),
  );
}

/// One row of the attempt history. Everything but the identity is null while an
/// attempt is still processing.
class SpeakingAttemptSummary {
  final String id;
  final String? lessonId;
  final int attemptNumber;
  final SpeakingAttemptStatus status;
  final double? durationSeconds;
  final double? wordsPerMinute;
  final int? overallScore;
  final DateTime? createdAt;
  final DateTime? completedAt;

  const SpeakingAttemptSummary({
    required this.id,
    required this.lessonId,
    required this.attemptNumber,
    required this.status,
    this.durationSeconds,
    this.wordsPerMinute,
    this.overallScore,
    this.createdAt,
    this.completedAt,
  });

  factory SpeakingAttemptSummary.fromJson(Json json) => SpeakingAttemptSummary(
    id: json['id'] as String,
    lessonId: json['lesson_id'] as String?,
    attemptNumber: _toInt(json['attempt_number']),
    status: SpeakingAttemptStatus.parse(json['status'] as String?),
    durationSeconds: _toNullableDouble(json['duration_seconds']),
    wordsPerMinute: _toNullableDouble(json['words_per_minute']),
    overallScore: json['overall_score'] as int?,
    createdAt: DateTime.tryParse(json['created_at'] as String? ?? ''),
    completedAt: DateTime.tryParse(json['completed_at'] as String? ?? ''),
  );
}

/// Swagger types the nested result objects as plain strings, while the written
/// contract shows objects. Accept either rather than guess which one ships.
Json? asJson(Object? value) {
  if (value is Map) return Map<String, dynamic>.from(value);
  if (value is String && value.trim().isNotEmpty) {
    try {
      final decoded = jsonDecode(value);
      if (decoded is Map) return Map<String, dynamic>.from(decoded);
    } on FormatException {
      return null;
    }
  }
  return null;
}

T? _parse<T>(Object? value, T Function(Json) build) {
  final json = asJson(value);
  return json == null ? null : build(json);
}

int _toInt(Object? value) => switch (value) {
  int() => value,
  num() => value.round(),
  String() => int.tryParse(value) ?? 0,
  _ => 0,
};

double _toDouble(Object? value) => _toNullableDouble(value) ?? 0;

double? _toNullableDouble(Object? value) => switch (value) {
  num() => value.toDouble(),
  String() => double.tryParse(value),
  _ => null,
};

List<String> _toStringList(Object? value) =>
    (value as List<dynamic>? ?? []).map((item) => item.toString()).toList();
