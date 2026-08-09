import 'package:edtech/features/recording/data/speaking_api.dart';
import 'package:edtech/features/speaking_history/models/speaking_history.dart';

abstract class SpeakingHistoryRepository {
  /// One page of the learner's attempts, grouped by lesson.
  Future<SpeakingHistoryModel> getHistory({int page, int pageSize});
}

class SpeakingHistoryRepositoryImpl implements SpeakingHistoryRepository {
  final SpeakingApi api;

  SpeakingHistoryRepositoryImpl(this.api);

  @override
  Future<SpeakingHistoryModel> getHistory({int page = 1, int pageSize = 20}) =>
      api.getSpeakingHistory(page: page, pageSize: pageSize);
}
