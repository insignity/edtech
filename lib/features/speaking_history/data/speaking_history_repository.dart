import 'package:edtech/features/recording/data/speaking_api.dart';
import 'package:edtech/features/recording/data/services/speaking_attempt_store.dart';
import 'package:edtech/features/recording/models/speaking_attempt.dart';
import 'package:edtech/features/speaking_history/models/speaking_history.dart';

abstract class SpeakingHistoryRepository {
  /// One page of the learner's attempts, grouped by lesson.
  Future<SpeakingHistoryModel> getHistory({int page, int pageSize});

  /// The full graded attempt behind a history row.
  Future<SpeakingAttempt> getAttempt(String attemptId);
}

class SpeakingHistoryRepositoryImpl implements SpeakingHistoryRepository {
  final SpeakingApi api;
  final SpeakingAttemptStore store;

  SpeakingHistoryRepositoryImpl(this.api, this.store);

  @override
  Future<SpeakingHistoryModel> getHistory({int page = 1, int pageSize = 20}) =>
      api.getSpeakingHistory(page: page, pageSize: pageSize);

  @override
  Future<SpeakingAttempt> getAttempt(String attemptId) async {
    // A finished attempt is immutable, so the second look at it is free.
    final cached = store.get(attemptId);
    if (cached != null) return cached;

    final attempt = await api.getAttempt(attemptId);
    store.put(attempt);
    return attempt;
  }
}
