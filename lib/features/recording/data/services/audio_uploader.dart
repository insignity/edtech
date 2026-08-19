import 'dart:io';

import 'package:dio/dio.dart';
import 'package:edtech/features/recording/models/speaking_attempt.dart';

/// Raised when S3 rejects the signed policy — it expired or was already used.
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
/// request as curl, and neither may ever reach Amazon. S3 authorises the upload
/// through the signed policy carried in the form itself.
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
    if (length > target.maxSizeBytes) {
      throw UploadFailedException(
        'This recording is ${_mb(length)} MB, over the '
        '${_mb(target.maxSizeBytes)} MB limit. Please record a shorter take.',
      );
    }

    try {
      await _dio.postUri<void>(
        Uri.parse(target.url),
        data: await _form(target, filePath),
        options: Options(
          // No Authorization and no Content-Type of our own: Dio writes the
          // multipart header with the boundary it generated, and overriding it
          // would break the body S3 parses.
          validateStatus: (status) =>
              status != null && status >= 200 && status < 300,
        ),
      );
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      if (status == 403) {
        throw const UploadUrlExpiredException();
      }
      if (status == 400) {
        // The policy refused the body — wrong field, wrong type, or a size the
        // pre-flight check did not catch.
        throw const UploadFailedException(
          'The server rejected this recording. Please try again.',
        );
      }
      throw const UploadFailedException(
        'Upload was interrupted. Check your connection and try again.',
      );
    }
  }

  /// Policy fields first, binary last — S3 validates the form in order and
  /// stops reading at the file, so anything after it is ignored.
  Future<FormData> _form(AttemptUpload target, String filePath) async {
    final form = FormData();
    target.fields.forEach(
      (name, value) => form.fields.add(MapEntry(name, value)),
    );
    form.files.add(
      MapEntry(
        target.fileField,
        await MultipartFile.fromFile(filePath, filename: _basename(filePath)),
      ),
    );
    return form;
  }

  static String _basename(String path) =>
      path.split(Platform.pathSeparator).last;

  static String _mb(int bytes) =>
      (bytes / (1024 * 1024)).toStringAsFixed(1).replaceAll('.0', '');
}
