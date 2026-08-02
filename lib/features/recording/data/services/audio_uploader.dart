import 'dart:io';

import 'package:dio/dio.dart';
import 'package:edtech/features/recording/models/speaking_attempt.dart';

/// Raised when S3 rejects the presigned URL — it expired or was already used.
/// The only cure is a fresh attempt.
class UploadUrlExpiredException implements Exception {
  const UploadUrlExpiredException();
}

class UploadFailedException implements Exception {
  final String message;

  const UploadFailedException(this.message);

  @override
  String toString() => message;
}

/// Puts the raw recording straight into S3.
///
/// Runs on its own bare [Dio]: the app client would attach the JWT and log the
/// request as curl, and neither may ever reach Amazon.
abstract class AudioUploader {
  Future<void> upload({
    required AttemptUpload target,
    required String filePath,
  });
}

class AudioUploaderImpl implements AudioUploader {
  final Dio _dio;

  AudioUploaderImpl({Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              connectTimeout: const Duration(seconds: 15),
              // A two-minute take over a weak connection needs far longer than
              // the 10s the JSON endpoints get.
              sendTimeout: const Duration(minutes: 2),
              receiveTimeout: const Duration(seconds: 30),
              // S3 answers with an empty body on success.
              responseType: ResponseType.plain,
            ),
          );

  @override
  Future<void> upload({
    required AttemptUpload target,
    required String filePath,
  }) async {
    final file = File(filePath);
    if (!await file.exists()) {
      throw const UploadFailedException('The recording file is missing.');
    }

    final length = await file.length();

    try {
      await _dio.putUri<void>(
        Uri.parse(target.url),
        // Streamed so a long take is not held in memory twice. Dio needs the
        // length spelled out when the body is a stream.
        data: file.openRead(),
        options: Options(
          headers: {...target.headers, Headers.contentLengthHeader: length},
        ),
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 403) {
        throw const UploadUrlExpiredException();
      }
      throw const UploadFailedException(
        'Upload was interrupted. Check your connection and try again.',
      );
    }
  }
}
