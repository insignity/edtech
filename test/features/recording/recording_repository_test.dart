import 'package:edtech/features/recording/data/recording_repository.dart';
import 'package:edtech/features/recording/data/services/audio_uploader.dart';
import 'package:edtech/features/recording/data/speaking_api.dart';
import 'package:edtech/features/recording/models/analysis_step.dart';
import 'package:edtech/features/recording/models/analysis_update.dart';
import 'package:edtech/features/recording/models/speaking_attempt.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockSpeakingApi extends Mock implements SpeakingApi {}

class MockUploader extends Mock implements AudioUploader {}

const _lessonId = 'lesson-1';
const _filePath = '/tmp/retelling.m4a';

SpeakingAttempt _created(String id) => SpeakingAttempt.fromJson({
  'id': id,
  'lesson_id': _lessonId,
  'attempt_number': 2,
  'status': 'created',
  'upload': {
    'url': 'https://bucket.s3.amazonaws.com/$id?signature',
    'method': 'PUT',
    'headers': {'Content-Type': 'audio/mp4'},
    'expires_in': 900,
  },
});

SpeakingAttempt _at(String status, {Map<String, dynamic>? extra}) =>
    SpeakingAttempt.fromJson({
      'id': 'attempt-1',
      'lesson_id': _lessonId,
      'attempt_number': 2,
      'status': status,
      'transcript': 'The customer ordered coffee.',
      ...?extra,
    });

final _completed = _at(
  'completed',
  extra: {
    'metrics': {
      'duration_seconds': 40.0,
      'word_count': 90,
      'words_per_minute': 135.0,
      'filler_word_count': 1,
    },
    'feedback': {
      'overall_score': 84,
      'grammar_score': 88,
      'vocabulary_score': 82,
      'fluency_score': 78,
      'short_feedback': 'Clear retelling.',
      'corrections': <dynamic>[],
    },
  },
);

final _failed = _at(
  'failed',
  extra: {
    'error': {
      'code': 'empty_transcript',
      'message': 'The recording did not contain recognizable speech.',
    },
  },
);

/// Runs the analysis stream to completion on a fake clock, so the polling
/// delays cost the test nothing.
({List<AnalysisUpdate> updates, Object? error}) drive(
  RecordingRepository repository,
) {
  final updates = <AnalysisUpdate>[];
  Object? error;

  fakeAsync((async) {
    repository
        .analyze(lessonId: _lessonId, filePath: _filePath)
        .listen(updates.add, onError: (Object e) => error = e);
    async.elapse(const Duration(minutes: 1));
  });

  return (updates: updates, error: error);
}

List<AnalysisStep> stepsIn(List<AnalysisUpdate> updates) =>
    updates.whereType<AnalysisStepDone>().map((update) => update.step).toList();

void main() {
  late MockSpeakingApi api;
  late MockUploader uploader;
  late RecordingRepositoryImpl repository;

  setUpAll(
    () => registerFallbackValue(
      const AttemptUpload(
        url: 'https://example.com',
        method: 'PUT',
        headers: {},
        expiresIn: 900,
      ),
    ),
  );

  setUp(() {
    api = MockSpeakingApi();
    uploader = MockUploader();
    repository = RecordingRepositoryImpl(api, uploader);

    when(
      () => api.createAttempt(any()),
    ).thenAnswer((_) async => _created('attempt-1'));
    when(
      () => uploader.upload(
        target: any(named: 'target'),
        filePath: any(named: 'filePath'),
      ),
    ).thenAnswer((_) async {});
    when(
      () => api.completeUpload(any()),
    ).thenAnswer((_) async => _at('uploaded'));
    when(
      () => api.getHistory(
        any(),
        page: any(named: 'page'),
        pageSize: any(named: 'pageSize'),
      ),
    ).thenAnswer((_) async => const <SpeakingAttemptSummary>[]);
  });

  /// Hands back one attempt per poll, in order.
  void pollsThrough(List<SpeakingAttempt> attempts) {
    final queue = [...attempts];
    when(() => api.getAttempt(any())).thenAnswer(
      (_) async => queue.length == 1 ? queue.first : queue.removeAt(0),
    );
  }

  test('walks the pipeline and hands back the score', () {
    pollsThrough([_at('transcribing'), _at('analyzing'), _completed]);

    final run = drive(repository);

    expect(run.error, isNull);
    expect(stepsIn(run.updates), AnalysisStep.values);
    expect(run.updates.last, isA<AnalysisResultReady>());
    expect((run.updates.last as AnalysisResultReady).result.score, 84);
    expect((run.updates.last as AnalysisResultReady).result.wpm, 135);

    verify(() => api.createAttempt(_lessonId)).called(1);
    verify(() => api.completeUpload('attempt-1')).called(1);
  });

  test('fills in every checklist row when the poll skips statuses', () {
    // The pipeline can finish between two polls; the checklist still has to
    // reach the end, or the bloc reads a success as a failure.
    pollsThrough([_completed]);

    final run = drive(repository);

    expect(run.error, isNull);
    expect(stepsIn(run.updates), AnalysisStep.values);
  });

  test('surfaces the backend message when processing fails', () {
    pollsThrough([_at('transcribing'), _failed]);

    final run = drive(repository);

    expect(run.error, isA<AnalysisException>());
    expect(
      (run.error as AnalysisException).message,
      'The recording did not contain recognizable speech.',
    );
    expect(run.updates.whereType<AnalysisResultReady>(), isEmpty);
  });

  test('works out the delta against the previous attempt', () {
    pollsThrough([_completed]);
    when(
      () => api.getHistory(
        any(),
        page: any(named: 'page'),
        pageSize: any(named: 'pageSize'),
      ),
    ).thenAnswer(
      (_) async => [
        SpeakingAttemptSummary.fromJson({
          'id': 'attempt-1',
          'lesson_id': _lessonId,
          'attempt_number': 2,
          'status': 'completed',
          'overall_score': 84,
        }),
        SpeakingAttemptSummary.fromJson({
          'id': 'attempt-0',
          'lesson_id': _lessonId,
          'attempt_number': 1,
          'status': 'completed',
          'overall_score': 80,
        }),
      ],
    );

    final run = drive(repository);

    expect((run.updates.last as AnalysisResultReady).result.delta, 4);
  });

  test('reads no change when history is out of reach', () {
    pollsThrough([_completed]);
    when(
      () => api.getHistory(
        any(),
        page: any(named: 'page'),
        pageSize: any(named: 'pageSize'),
      ),
    ).thenThrow(Exception('offline'));

    final run = drive(repository);

    expect(run.error, isNull);
    expect((run.updates.last as AnalysisResultReady).result.delta, 0);
  });

  test('starts a fresh attempt when the presigned URL has expired', () {
    var uploads = 0;
    when(() => api.createAttempt(any())).thenAnswer(
      (_) async => _created(uploads == 0 ? 'attempt-1' : 'attempt-2'),
    );
    when(
      () => uploader.upload(
        target: any(named: 'target'),
        filePath: any(named: 'filePath'),
      ),
    ).thenAnswer((_) async {
      if (uploads++ == 0) throw const UploadUrlExpiredException();
    });
    pollsThrough([_completed]);

    final run = drive(repository);

    expect(run.error, isNull);
    verify(() => api.createAttempt(_lessonId)).called(2);
    verify(() => api.completeUpload('attempt-2')).called(1);
  });

  test('gives up after a second expired URL', () {
    when(
      () => uploader.upload(
        target: any(named: 'target'),
        filePath: any(named: 'filePath'),
      ),
    ).thenThrow(const UploadUrlExpiredException());

    final run = drive(repository);

    expect(run.error, isA<AnalysisException>());
    verify(() => api.createAttempt(_lessonId)).called(2);
    verifyNever(() => api.completeUpload(any()));
  });

  test('rides out a transient polling error', () {
    var polls = 0;
    when(() => api.getAttempt(any())).thenAnswer((_) async {
      if (polls++ == 0) throw Exception('connection reset');
      return _completed;
    });

    final run = drive(repository);

    expect(run.error, isNull);
    expect(run.updates.last, isA<AnalysisResultReady>());
  });

  test('stops after the connection stays down', () {
    when(() => api.getAttempt(any())).thenThrow(Exception('offline'));

    final run = drive(repository);

    expect(run.error, isA<AnalysisException>());
    expect(
      (run.error as AnalysisException).message,
      contains('Lost connection'),
    );
  });
}
