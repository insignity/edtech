import 'package:edtech/features/recording/models/analysis_update.dart';

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

class RecordingRepositoryImpl implements RecordingRepository {
  @override
  Stream<AnalysisUpdate> analyze({
    required String lessonId,
    required String filePath,
  }) {
    // The retelling-analysis endpoint does not exist on the API yet. Until it
    // does, submitting lands on the screen's error state — which keeps the
    // recording on disk and offers a retry, so nothing is lost.
    return Stream.error(
      UnimplementedError(
        'Retelling analysis is not wired up: the API has no endpoint for '
        'uploading a recording yet.',
      ),
    );
  }
}
