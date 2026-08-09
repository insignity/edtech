import 'package:edtech/features/recording/data/speaking_api.dart';
import 'package:edtech/features/recording/data/services/speaking_attempt_store.dart';
import 'package:edtech/features/recording/models/speaking_attempt.dart';
import 'package:edtech/features/speaking_history/data/speaking_history_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockSpeakingApi extends Mock implements SpeakingApi {}

SpeakingAttempt _attempt(SpeakingAttemptStatus status) => SpeakingAttempt(
  id: 'attempt-1',
  lessonId: 'lesson-1',
  attemptNumber: 2,
  status: status,
);

void main() {
  late MockSpeakingApi api;
  late SpeakingAttemptStore store;
  late SpeakingHistoryRepositoryImpl repository;

  setUp(() {
    api = MockSpeakingApi();
    store = SpeakingAttemptStore();
    repository = SpeakingHistoryRepositoryImpl(api, store);
  });

  group('getAttempt', () {
    test('serves a second look at a graded attempt from memory', () async {
      when(() => api.getAttempt('attempt-1')).thenAnswer(
        (_) async => _attempt(SpeakingAttemptStatus.completed),
      );

      await repository.getAttempt('attempt-1');
      final second = await repository.getAttempt('attempt-1');

      expect(second.id, 'attempt-1');
      verify(() => api.getAttempt('attempt-1')).called(1);
    });

    test('asks again while the attempt is still being graded', () async {
      when(() => api.getAttempt('attempt-1')).thenAnswer(
        (_) async => _attempt(SpeakingAttemptStatus.analyzing),
      );

      await repository.getAttempt('attempt-1');
      await repository.getAttempt('attempt-1');

      verify(() => api.getAttempt('attempt-1')).called(2);
    });

    test('lets a failure through instead of caching it', () async {
      when(() => api.getAttempt('attempt-1')).thenThrow(Exception('network'));

      await expectLater(
        repository.getAttempt('attempt-1'),
        throwsA(isA<Exception>()),
      );
      expect(store.get('attempt-1'), isNull);
    });
  });
}
