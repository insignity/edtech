import 'package:edtech/features/recording/data/recording_repository.dart';
import 'package:edtech/features/recording/models/analysis_step.dart';
import 'package:edtech/features/recording/models/analysis_update.dart';
import 'package:edtech/features/recording/models/retelling_result.dart';

/// Stand-in for the analysis backend until the API has an endpoint for it.
///
/// Walks the same [AnalysisStep] sequence the real thing will, pausing between
/// stages so the checklist and progress bar behave as they do in the design,
/// then hands back a fixed score. Swap this out in the service locator once
/// the endpoint lands.
class FakeRecordingRepository implements RecordingRepository {
  /// How long each stage appears to take.
  final Map<AnalysisStep, Duration> stepDurations;

  /// Stage to fail at instead of completing — for exercising the error screen.
  final AnalysisStep? failAt;

  /// Score handed back when grading finishes.
  final RetellingResult result;

  const FakeRecordingRepository({
    this.stepDurations = const {
      AnalysisStep.uploaded: Duration(milliseconds: 900),
      AnalysisStep.transcription: Duration(milliseconds: 1600),
      AnalysisStep.metrics: Duration(milliseconds: 1100),
      AnalysisStep.analysis: Duration(milliseconds: 1800),
    },
    this.failAt,
    this.result = sampleResult,
  });

  static const RetellingResult sampleResult = RetellingResult(
    score: 91,
    delta: 4,
    fluency: 88,
    grammar: 93,
    vocabulary: 91,
    wpm: 142,
    feedback:
        'Great flow and natural pacing. Watch out for article usage '
        "('a' vs 'the') and try varying how you open each sentence.",
    transcript:
        'Yesterday I go to a hotel near downtown to ask about direction. '
        'I asked the receptionist how can I get to a train station and she '
        'explain me very clear.',
    corrections: [
      Correction(wrong: 'I go', right: 'I went'),
      Correction(wrong: 'a hotel', right: 'the hotel'),
      Correction(wrong: 'a train station', right: 'the train station'),
    ],
  );

  @override
  Stream<AnalysisUpdate> analyze({
    required String lessonId,
    required String filePath,
  }) async* {
    for (final step in AnalysisStep.values) {
      await Future<void>.delayed(
        stepDurations[step] ?? const Duration(milliseconds: 1000),
      );

      if (step == failAt) {
        throw Exception('Analysis failed at ${step.label} (simulated)');
      }
      yield AnalysisStepDone(step);
    }

    yield AnalysisResultReady(result);
  }
}
