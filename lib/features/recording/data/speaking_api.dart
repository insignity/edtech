import 'package:edtech/core/api/api_client.dart';
import 'package:edtech/core/utils/error_handler.dart';
import 'package:edtech/core/utils/types.dart';
import 'package:edtech/features/recording/models/speaking_attempt.dart';

class SpeakingApi {
  final ApiClient api;

  SpeakingApi(this.api);

  /// What the recorder writes — `record` encodes AAC-LC into an MPEG-4
  /// container, which is what the backend expects alongside the m4a extension.
  static const String contentType = 'audio/mp4';
  static const String fileExtension = 'm4a';

  /// Creates an attempt and returns it together with a presigned S3 target.
  ///
  /// The response carries a temporary upload URL, so it is deliberately not
  /// logged.
  Future<SpeakingAttempt> createAttempt(String lessonId) {
    return guard<SpeakingAttempt>(() async {
      final response = await api.post(
        '/lessons/$lessonId/speaking-attempts/',
        data: {'content_type': contentType, 'file_extension': fileExtension},
      );
      return SpeakingAttempt.fromJson(response.data as Json);
    });
  }

  /// Confirms the S3 upload and starts processing. Idempotent on the backend.
  Future<SpeakingAttempt> completeUpload(String attemptId) {
    return guard<SpeakingAttempt>(() async {
      final response = await api.post(
        '/speaking-attempts/$attemptId/complete-upload/',
        data: const <String, dynamic>{},
      );
      return SpeakingAttempt.fromJson(response.data as Json);
    });
  }

  Future<SpeakingAttempt> getAttempt(String attemptId) {
    return guard<SpeakingAttempt>(() async {
      final response = await api.get('/speaking-attempts/$attemptId/');
      return SpeakingAttempt.fromJson(response.data as Json);
    });
  }

  /// Newest first, as documented.
  Future<List<SpeakingAttemptSummary>> getHistory(
    String lessonId, {
    int page = 1,
    int pageSize = 20,
  }) {
    return guard<List<SpeakingAttemptSummary>>(() async {
      final response = await api.get(
        '/lessons/$lessonId/speaking-attempts/',
        params: {'page': page, 'page_size': pageSize},
      );
      final results =
          (response.data as Json)['results'] as List<dynamic>? ?? [];
      return results
          .map((item) => SpeakingAttemptSummary.fromJson(item as Json))
          .toList();
    });
  }
}
