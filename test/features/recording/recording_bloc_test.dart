import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:edtech/features/recording/data/recording_repository.dart';
import 'package:edtech/features/recording/data/services/audio_player_service.dart';
import 'package:edtech/features/recording/data/services/audio_recorder_service.dart';
import 'package:edtech/features/recording/models/analysis_step.dart';
import 'package:edtech/features/recording/models/analysis_update.dart';
import 'package:edtech/features/recording/models/retelling_result.dart';
import 'package:edtech/features/recording/ui/bloc/recording_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockRecorder extends Mock implements AudioRecorderService {}

class MockPlayer extends Mock implements AudioPlayerService {}

class MockRepository extends Mock implements RecordingRepository {}

const _result = RetellingResult(
  score: 91,
  delta: 4,
  fluency: 88,
  grammar: 93,
  vocabulary: 91,
  wpm: 142,
  feedback: 'Great flow.',
  transcript: 'Yesterday I go to a hotel.',
  corrections: [Correction(wrong: 'I go', right: 'I went')],
);

/// A complete backend run: every stage, then the score.
final _fullRun = <AnalysisUpdate>[
  ...AnalysisStep.values.map(AnalysisStepDone.new),
  const AnalysisResultReady(_result),
];

void main() {
  late MockRecorder recorder;
  late MockPlayer player;
  late MockRepository repository;

  const path = '/tmp/retelling.m4a';
  const duration = Duration(seconds: 12);

  setUpAll(() => registerFallbackValue(Duration.zero));

  setUp(() {
    recorder = MockRecorder();
    player = MockPlayer();
    repository = MockRepository();

    when(() => recorder.hasPermission()).thenAnswer((_) async => true);
    when(() => recorder.start()).thenAnswer((_) async => path);
    when(() => recorder.stop()).thenAnswer((_) async => path);
    when(() => recorder.levels).thenAnswer((_) => const Stream<double>.empty());
    when(() => recorder.deleteFile(any())).thenAnswer((_) async {});
    when(() => recorder.dispose()).thenAnswer((_) async {});

    when(() => player.load(any())).thenAnswer((_) async => duration);
    when(() => player.play()).thenAnswer((_) async {});
    when(() => player.pause()).thenAnswer((_) async {});
    when(() => player.seek(any())).thenAnswer((_) async {});
    when(() => player.position).thenAnswer((_) => const Stream<Duration>.empty());
    when(() => player.completions).thenAnswer((_) => const Stream<void>.empty());
    when(() => player.dispose()).thenAnswer((_) async {});
  });

  RecordingBloc build() => RecordingBloc(
    recorder: recorder,
    player: player,
    repository: repository,
  );

  group('permission', () {
    blocTest<RecordingBloc, RecordingState>(
      'stops at the denied state without touching the microphone',
      build: () {
        when(() => recorder.hasPermission()).thenAnswer((_) async => false);
        return build();
      },
      act: (bloc) => bloc.add(RecordingRequested()),
      expect: () => [isA<RecordingPermissionDenied>()],
      verify: (_) => verifyNever(() => recorder.start()),
    );
  });

  group('capture', () {
    blocTest<RecordingBloc, RecordingState>(
      'starts capture on request',
      build: build,
      act: (bloc) => bloc.add(RecordingRequested()),
      expect: () => [
        isA<RecordingInProgress>()
            .having((s) => s.elapsed, 'elapsed', Duration.zero)
            .having((s) => s.levels, 'levels', isEmpty),
      ],
      verify: (_) => verify(() => recorder.start()).called(1),
    );

    blocTest<RecordingBloc, RecordingState>(
      'moves to review with the recorded file and its duration',
      build: build,
      act: (bloc) async {
        bloc.add(RecordingRequested());
        await Future<void>.delayed(Duration.zero);
        bloc.add(RecordingStopRequested());
      },
      skip: 1,
      expect: () => [
        isA<RecordingReview>()
            .having((s) => s.path, 'path', path)
            .having((s) => s.duration, 'duration', duration)
            .having((s) => s.isPlaying, 'isPlaying', isFalse),
      ],
    );

    blocTest<RecordingBloc, RecordingState>(
      'falls back to idle when the recorder yields no file',
      build: () {
        when(() => recorder.stop()).thenAnswer((_) async => null);
        return build();
      },
      act: (bloc) async {
        bloc.add(RecordingRequested());
        await Future<void>.delayed(Duration.zero);
        bloc.add(RecordingStopRequested());
      },
      skip: 1,
      expect: () => [isA<RecordingIdle>()],
    );

    // The level window is what the 28-bar waveform renders.
    test('keeps the level window to one bar per slot', () {
      final long = List<double>.filled(RecordingBloc.waveformBars + 10, 0.5);
      final trimmed = long.fold<List<double>>(
        [],
        (acc, level) => acc.length < RecordingBloc.waveformBars
            ? [...acc, level]
            : [...acc.sublist(1), level],
      );

      expect(trimmed, hasLength(RecordingBloc.waveformBars));
    });
  });

  group('playback', () {
    blocTest<RecordingBloc, RecordingState>(
      'toggles play and pause',
      build: build,
      act: (bloc) async {
        bloc.add(RecordingRequested());
        await Future<void>.delayed(Duration.zero);
        bloc.add(RecordingStopRequested());
        await Future<void>.delayed(Duration.zero);
        bloc.add(RecordingPlaybackToggled());
        await Future<void>.delayed(Duration.zero);
        bloc.add(RecordingPlaybackToggled());
      },
      skip: 2,
      expect: () => [
        isA<RecordingReview>().having((s) => s.isPlaying, 'isPlaying', isTrue),
        isA<RecordingReview>().having((s) => s.isPlaying, 'isPlaying', isFalse),
      ],
      verify: (_) {
        verify(() => player.play()).called(1);
        verify(() => player.pause()).called(greaterThanOrEqualTo(1));
      },
    );

    blocTest<RecordingBloc, RecordingState>(
      'rewinds before replaying a finished take',
      build: build,
      act: (bloc) async {
        bloc.add(RecordingRequested());
        await Future<void>.delayed(Duration.zero);
        bloc.add(RecordingStopRequested());
        await Future<void>.delayed(Duration.zero);
        bloc.add(RecordingPositionChanged(duration));
        await Future<void>.delayed(Duration.zero);
        bloc.add(RecordingPlaybackToggled());
      },
      verify: (_) => verify(() => player.seek(Duration.zero)).called(1),
    );
  });

  group('re-record', () {
    blocTest<RecordingBloc, RecordingState>(
      'drops the take and starts a fresh one',
      build: build,
      act: (bloc) async {
        bloc.add(RecordingRequested());
        await Future<void>.delayed(Duration.zero);
        bloc.add(RecordingStopRequested());
        await Future<void>.delayed(Duration.zero);
        bloc.add(RecordingDiscarded());
      },
      skip: 2,
      expect: () => [isA<RecordingIdle>(), isA<RecordingInProgress>()],
      verify: (_) {
        verify(() => recorder.deleteFile(path)).called(1);
        verify(() => recorder.start()).called(2);
      },
    );
  });

  group('analysis', () {
    Future<void> recordThenSubmit(RecordingBloc bloc) async {
      bloc.add(RecordingRequested());
      await Future<void>.delayed(Duration.zero);
      bloc.add(RecordingStopRequested());
      await Future<void>.delayed(Duration.zero);
      bloc.add(RecordingSubmitted('lesson-1'));
    }

    blocTest<RecordingBloc, RecordingState>(
      'walks the checklist and succeeds when every step lands',
      build: () {
        when(
          () => repository.analyze(
            lessonId: any(named: 'lessonId'),
            filePath: any(named: 'filePath'),
          ),
        ).thenAnswer((_) => Stream.fromIterable(_fullRun));
        return build();
      },
      act: recordThenSubmit,
      skip: 2,
      expect: () => [
        isA<RecordingAnalyzing>().having((s) => s.completed, 'completed', isEmpty),
        isA<RecordingAnalyzing>().having((s) => s.progress, 'progress', 0.25),
        isA<RecordingAnalyzing>().having((s) => s.progress, 'progress', 0.5),
        isA<RecordingAnalyzing>().having((s) => s.progress, 'progress', 0.75),
        isA<RecordingAnalyzing>().having((s) => s.progress, 'progress', 1.0),
        isA<RecordingAnalyzing>().having((s) => s.result, 'result', _result),
        isA<RecordingAnalyzed>().having((s) => s.result.score, 'score', 91),
      ],
    );

    // Every stage confirmed but no score is still a failure — there would be
    // nothing to show on the results screen.
    blocTest<RecordingBloc, RecordingState>(
      'fails when the stream ends without a score',
      build: () {
        when(
          () => repository.analyze(
            lessonId: any(named: 'lessonId'),
            filePath: any(named: 'filePath'),
          ),
        ).thenAnswer(
          (_) => Stream.fromIterable(
            AnalysisStep.values.map(AnalysisStepDone.new),
          ),
        );
        return build();
      },
      act: recordThenSubmit,
      skip: 7,
      expect: () => [isA<RecordingFailed>()],
    );

    blocTest<RecordingBloc, RecordingState>(
      'keeps the file when analysis errors out',
      build: () {
        when(
          () => repository.analyze(
            lessonId: any(named: 'lessonId'),
            filePath: any(named: 'filePath'),
          ),
        ).thenAnswer((_) => Stream.error(Exception('offline')));
        return build();
      },
      act: recordThenSubmit,
      skip: 3,
      expect: () => [
        isA<RecordingFailed>().having((s) => s.path, 'path', path),
      ],
      verify: (_) => verifyNever(() => recorder.deleteFile(any())),
    );

    // A stream that ends early is a failure, not a pass.
    blocTest<RecordingBloc, RecordingState>(
      'treats a short-circuited stream as a failure',
      build: () {
        when(
          () => repository.analyze(
            lessonId: any(named: 'lessonId'),
            filePath: any(named: 'filePath'),
          ),
        ).thenAnswer(
          (_) => Stream.fromIterable([
            const AnalysisStepDone(AnalysisStep.uploaded),
          ]),
        );
        return build();
      },
      act: recordThenSubmit,
      skip: 4,
      expect: () => [isA<RecordingFailed>()],
    );

    blocTest<RecordingBloc, RecordingState>(
      'retries straight from the failed state',
      build: () {
        var attempt = 0;
        when(
          () => repository.analyze(
            lessonId: any(named: 'lessonId'),
            filePath: any(named: 'filePath'),
          ),
        ).thenAnswer((_) {
          attempt++;
          return attempt == 1
              ? Stream.error(Exception('offline'))
              : Stream.fromIterable(_fullRun);
        });
        return build();
      },
      act: (bloc) async {
        await recordThenSubmit(bloc);
        await Future<void>.delayed(Duration.zero);
        bloc.add(RecordingSubmitted('lesson-1'));
      },
      verify: (bloc) => expect(bloc.state, isA<RecordingAnalyzed>()),
    );
  });
}
