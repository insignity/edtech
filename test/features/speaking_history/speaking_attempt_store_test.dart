import 'package:edtech/features/recording/data/services/speaking_attempt_store.dart';
import 'package:edtech/features/recording/models/speaking_attempt.dart';
import 'package:flutter_test/flutter_test.dart';

SpeakingAttempt _attempt(String id, SpeakingAttemptStatus status) =>
    SpeakingAttempt(
      id: id,
      lessonId: 'lesson-1',
      attemptNumber: 1,
      status: status,
    );

void main() {
  late SpeakingAttemptStore store;

  setUp(() {
    store = SpeakingAttemptStore();
  });

  test('keeps a completed attempt', () {
    store.put(_attempt('a1', SpeakingAttemptStatus.completed));

    expect(store.get('a1')?.id, 'a1');
  });

  test('keeps a failed attempt — it will not change either', () {
    store.put(_attempt('a1', SpeakingAttemptStatus.failed));

    expect(store.get('a1'), isNotNull);
  });

  test('refuses attempts still in the pipeline', () {
    // Caching these would freeze the poll the recording screen runs while it
    // waits for the status to move on.
    for (final status in [
      SpeakingAttemptStatus.created,
      SpeakingAttemptStatus.uploaded,
      SpeakingAttemptStatus.transcribing,
      SpeakingAttemptStatus.analyzing,
    ]) {
      store.put(_attempt('a-${status.name}', status));
      expect(store.get('a-${status.name}'), isNull, reason: status.name);
    }
  });

  test('returns null for an attempt it has never seen', () {
    expect(store.get('missing'), isNull);
  });

  test('clear drops everything', () {
    store.put(_attempt('a1', SpeakingAttemptStatus.completed));
    store.put(_attempt('a2', SpeakingAttemptStatus.completed));

    store.clear();

    expect(store.get('a1'), isNull);
    expect(store.get('a2'), isNull);
  });
}
