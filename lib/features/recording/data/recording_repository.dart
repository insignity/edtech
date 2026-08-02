import 'dart:async';

import 'package:edtech/features/recording/data/services/audio_uploader.dart';
import 'package:edtech/features/recording/data/speaking_api.dart';
import 'package:edtech/features/recording/models/analysis_step.dart';
import 'package:edtech/features/recording/models/analysis_update.dart';
import 'package:edtech/features/recording/models/retelling_result.dart';
import 'package:edtech/features/recording/models/speaking_attempt.dart';

abstract class RecordingRepository {
  /// Uploads [filePath] for grading, reporting each stage as it completes and
  /// finally the score itself.
  ///
  /// The stream closes once [AnalysisResultReady] has been emitted; any failure
  /// is surfaced as a stream error so the screen can offer a retry.
  Stream<AnalysisUpdate> analyze({
    required String lessonId,
    required String filePath,
  });
}

/// A failure worth putting in front of the learner as is.
class AnalysisException implements Exception {
  final String message;

  const AnalysisException(this.message);

  @override
  String toString() => message;
}

/// Drives the speaking pipeline: create an attempt, push the audio to S3,
/// confirm it, then poll until the backend has a verdict.
class RecordingRepositoryImpl implements RecordingRepository {
  final SpeakingApi api;
  final AudioUploader uploader;

  RecordingRepositoryImpl(this.api, this.uploader);

  /// Cadence from the contract: tight while the pipeline usually finishes,
  /// relaxed afterwards, and given up on after ten minutes.
  static const Duration fastInterval = Duration(seconds: 2);
  static const Duration slowInterval = Duration(seconds: 5);
  static const Duration fastWindow = Duration(seconds: 60);
  static const Duration pollTimeout = Duration(minutes: 10);

  /// A presigned URL can die between being handed out and being used; one clean
  /// retry with a fresh attempt costs the learner nothing.
  static const int _uploadTries = 2;

  /// Transient network blips during polling should not throw away a recording
  /// the backend is already grading.
  static const int _pollFailureBudget = 3;

  @override
  Stream<AnalysisUpdate> analyze({
    required String lessonId,
    required String filePath,
  }) async* {
    final created = await _createAndUpload(
      lessonId: lessonId,
      filePath: filePath,
    );

    var attempt = await _completeUpload(created.id);

    // Everything the checklist has ticked so far, so a status the poll skipped
    // over still fills in the rows below it.
    var emitted = 0;
    List<AnalysisUpdate> advanceTo(SpeakingAttemptStatus status) {
      final updates = <AnalysisUpdate>[];
      final target = _stepsDoneFor(status);
      while (emitted < target) {
        updates.add(AnalysisStepDone(AnalysisStep.values[emitted]));
        emitted++;
      }
      return updates;
    }

    for (final update in advanceTo(attempt.status)) {
      yield update;
    }

    final startedAt = DateTime.now();
    var failures = 0;

    while (!attempt.status.isTerminal) {
      final elapsed = DateTime.now().difference(startedAt);
      if (elapsed > pollTimeout) {
        throw const AnalysisException(
          'This is taking longer than usual. The result will appear in your '
          'history once it is ready.',
        );
      }

      await Future<void>.delayed(
        elapsed < fastWindow ? fastInterval : slowInterval,
      );

      try {
        attempt = await api.getAttempt(created.id);
        failures = 0;
      } catch (_) {
        if (++failures >= _pollFailureBudget) {
          throw const AnalysisException(
            'Lost connection while your recording was being graded.',
          );
        }
        continue;
      }

      for (final update in advanceTo(attempt.status)) {
        yield update;
      }
    }

    if (attempt.status == SpeakingAttemptStatus.failed) {
      throw AnalysisException(
        attempt.error?.message ??
            'The recording could not be processed. Please try again.',
      );
    }

    if (attempt.feedback == null) {
      throw const AnalysisException(
        'The analysis came back empty. Please try again.',
      );
    }

    yield AnalysisResultReady(
      RetellingResult.fromAttempt(
        attempt,
        delta: await _scoreDelta(lessonId: lessonId, attempt: attempt),
      ),
    );
  }

  Future<SpeakingAttempt> _createAndUpload({
    required String lessonId,
    required String filePath,
  }) async {
    for (var tries = 1; ; tries++) {
      final attempt = await api.createAttempt(lessonId);
      final upload = attempt.upload;
      if (upload == null) {
        throw const AnalysisException(
          'The server did not hand back an upload link. Please try again.',
        );
      }

      try {
        await uploader.upload(target: upload, filePath: filePath);
        return attempt;
      } on UploadUrlExpiredException {
        // A new attempt brings a new URL — but only go around once, or a broken
        // bucket would run the attempt counter up.
        if (tries >= _uploadTries) {
          throw const AnalysisException(
            'The upload link expired. Please try again.',
          );
        }
      } on UploadFailedException catch (e) {
        throw AnalysisException(e.message);
      }
    }
  }

  Future<SpeakingAttempt> _completeUpload(String attemptId) async {
    try {
      return await api.completeUpload(attemptId);
    } catch (_) {
      throw const AnalysisException(
        'The server could not confirm your upload. Please try again.',
      );
    }
  }

  /// The backend compares pace and fillers but not the overall score, so the
  /// "vs last attempt" line is worked out from history. A missing or
  /// unreachable previous attempt simply reads as no change.
  Future<int> _scoreDelta({
    required String lessonId,
    required SpeakingAttempt attempt,
  }) async {
    final current = attempt.feedback?.overallScore;
    if (current == null) return 0;

    try {
      final history = await api.getHistory(lessonId, pageSize: 5);
      for (final item in history) {
        if (item.attemptNumber < attempt.attemptNumber &&
            item.overallScore != null) {
          return current - item.overallScore!;
        }
      }
      return 0;
    } catch (_) {
      return 0;
    }
  }

  /// How many checklist rows a backend status has earned.
  ///
  /// The pipeline reports three working states where the design shows four rows
  /// — metrics are folded into the analysis stage.
  static int _stepsDoneFor(SpeakingAttemptStatus status) => switch (status) {
    SpeakingAttemptStatus.created => 0,
    SpeakingAttemptStatus.uploaded => 1,
    SpeakingAttemptStatus.transcribing => 1,
    SpeakingAttemptStatus.analyzing => 3,
    SpeakingAttemptStatus.completed => AnalysisStep.values.length,
    SpeakingAttemptStatus.failed => 0,
  };
}
