import 'package:edtech/features/recording/data/fake_recording_repository.dart';
import 'package:fake_async/fake_async.dart';
import 'package:edtech/features/recording/models/analysis_step.dart';
import 'package:edtech/features/recording/models/analysis_update.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Instant stages — the point here is the sequence, not the pacing.
  const instant = FakeRecordingRepository(
    stepDurations: {
      AnalysisStep.uploaded: Duration.zero,
      AnalysisStep.transcription: Duration.zero,
      AnalysisStep.metrics: Duration.zero,
      AnalysisStep.analysis: Duration.zero,
    },
  );

  Stream<AnalysisUpdate> run(FakeRecordingRepository repository) =>
      repository.analyze(lessonId: 'lesson-1', filePath: '/tmp/take.m4a');

  Matcher stepDone(AnalysisStep step) =>
      isA<AnalysisStepDone>().having((u) => u.step, 'step', step);

  test('walks every stage in order, then hands back the score', () {
    expect(
      run(instant),
      emitsInOrder([
        ...AnalysisStep.values.map(stepDone),
        isA<AnalysisResultReady>().having(
          (u) => u.result.score,
          'score',
          FakeRecordingRepository.sampleResult.score,
        ),
        emitsDone,
      ]),
    );
  });

  test('stops at the stage it is told to fail on', () {
    const failing = FakeRecordingRepository(
      stepDurations: {},
      failAt: AnalysisStep.metrics,
    );

    expect(
      run(failing),
      emitsInOrder([
        stepDone(AnalysisStep.uploaded),
        stepDone(AnalysisStep.transcription),
        emitsError(isA<Exception>()),
      ]),
    );
  });

  test('paces the stages it is given', () {
    const slow = FakeRecordingRepository(
      stepDurations: {AnalysisStep.uploaded: Duration(milliseconds: 60)},
    );

    fakeAsync((async) {
      AnalysisUpdate? first;
      run(slow).first.then((update) => first = update);

      async.elapse(const Duration(milliseconds: 30));
      expect(first, isNull, reason: 'stage should not land early');

      async.elapse(const Duration(milliseconds: 40));
      expect(first, stepDone(AnalysisStep.uploaded));
    });
  });
}
