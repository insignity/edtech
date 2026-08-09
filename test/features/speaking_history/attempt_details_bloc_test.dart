import 'package:bloc_test/bloc_test.dart';
import 'package:edtech/features/recording/models/speaking_attempt.dart';
import 'package:edtech/features/speaking_history/data/speaking_history_repository.dart';
import 'package:edtech/features/speaking_history/ui/bloc/attempt_details_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockSpeakingHistoryRepository extends Mock
    implements SpeakingHistoryRepository {}

const _feedback = {
  'overall_score': 80,
  'meaning_score': 82,
  'compression_score': 78,
  'clarity_score': 80,
  'grammar_score': 76,
  'vocabulary_score': 84,
  'fluency_score': 79,
  'covered_key_points': <String>[],
  'missed_key_points': <String>[],
  'unnecessary_details': <String>[],
  'corrections': <Map<String, dynamic>>[],
  'short_feedback': 'Clear retelling.',
  'concise_version': '',
  'next_goal': '',
};

SpeakingAttempt _graded() => SpeakingAttempt.fromJson({
  'id': 'attempt-1',
  'lesson_id': 'lesson-1',
  'attempt_number': 3,
  'status': 'completed',
  'transcript': 'Mia scored the winning goal.',
  'metrics': {
    'duration_seconds': 59.62,
    'word_count': 103,
    'words_per_minute': 103.66,
    'filler_word_count': 2,
  },
  'feedback': _feedback,
});

SpeakingAttempt _bare(String status) => SpeakingAttempt.fromJson({
  'id': 'attempt-1',
  'lesson_id': 'lesson-1',
  'attempt_number': 3,
  'status': status,
  'error': status == 'failed'
      ? {'code': 'audio_too_short', 'message': 'The recording was too short.'}
      : null,
});

void main() {
  late MockSpeakingHistoryRepository repository;

  setUp(() {
    repository = MockSpeakingHistoryRepository();
  });

  blocTest<AttemptDetailsBloc, AttemptDetailsState>(
    'emits [Loading, Loaded] with the graded breakdown',
    build: () {
      when(() => repository.getAttempt('attempt-1'))
          .thenAnswer((_) async => _graded());
      return AttemptDetailsBloc(repository);
    },
    act: (bloc) => bloc.add(AttemptDetailsFetch('attempt-1', delta: 4)),
    expect: () => [
      isA<AttemptDetailsLoading>(),
      isA<AttemptDetailsLoaded>()
          .having((s) => s.result.score, 'score', 80)
          .having((s) => s.result.wpm, 'wpm', 104)
          .having((s) => s.result.delta, 'delta', 4)
          .having((s) => s.showDelta, 'showDelta', true)
          .having((s) => s.result.transcript, 'transcript', isNotEmpty),
    ],
  );

  blocTest<AttemptDetailsBloc, AttemptDetailsState>(
    'hides the comparison line when there is no previous attempt',
    build: () {
      when(() => repository.getAttempt('attempt-1'))
          .thenAnswer((_) async => _graded());
      return AttemptDetailsBloc(repository);
    },
    act: (bloc) => bloc.add(AttemptDetailsFetch('attempt-1')),
    skip: 1,
    expect: () => [
      isA<AttemptDetailsLoaded>().having((s) => s.showDelta, 'showDelta', false),
    ],
  );

  blocTest<AttemptDetailsBloc, AttemptDetailsState>(
    'reports the backend message for a failed attempt',
    build: () {
      when(() => repository.getAttempt('attempt-1'))
          .thenAnswer((_) async => _bare('failed'));
      return AttemptDetailsBloc(repository);
    },
    act: (bloc) => bloc.add(AttemptDetailsFetch('attempt-1')),
    skip: 1,
    expect: () => [
      isA<AttemptDetailsError>()
          .having((s) => s.error, 'error', 'The recording was too short.'),
    ],
  );

  blocTest<AttemptDetailsBloc, AttemptDetailsState>(
    'does not throw when the attempt has no feedback yet',
    build: () {
      // The list only offers graded rows, but the status can move on between
      // the list being drawn and this request.
      when(() => repository.getAttempt('attempt-1'))
          .thenAnswer((_) async => _bare('analyzing'));
      return AttemptDetailsBloc(repository);
    },
    act: (bloc) => bloc.add(AttemptDetailsFetch('attempt-1')),
    skip: 1,
    expect: () => [
      isA<AttemptDetailsError>()
          .having((s) => s.error, 'error', 'This result is not ready yet.'),
    ],
  );

  blocTest<AttemptDetailsBloc, AttemptDetailsState>(
    'emits [Loading, Error] when the request fails',
    build: () {
      when(() => repository.getAttempt(any())).thenThrow(Exception('network'));
      return AttemptDetailsBloc(repository);
    },
    act: (bloc) => bloc.add(AttemptDetailsFetch('attempt-1')),
    expect: () => [
      isA<AttemptDetailsLoading>(),
      isA<AttemptDetailsError>(),
    ],
  );
}
