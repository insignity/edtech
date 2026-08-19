import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:edtech/features/recording/data/services/audio_uploader.dart';
import 'package:edtech/features/recording/models/speaking_attempt.dart';
import 'package:flutter_test/flutter_test.dart';

/// Captures the request instead of sending it, and answers the way S3 does.
class _CapturingAdapter implements HttpClientAdapter {
  final int statusCode;
  RequestOptions? captured;
  final List<int> body = [];

  _CapturingAdapter({this.statusCode = 204});

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    captured = options;
    // Keep the encoded body — it is the only place the field order is visible.
    if (requestStream != null) {
      await for (final chunk in requestStream) {
        body.addAll(chunk);
      }
    }
    return ResponseBody.fromString('', statusCode);
  }

  @override
  void close({bool force = false}) {}

  String get bodyText => String.fromCharCodes(body);
}

AttemptUpload _target({
  Map<String, String> fields = const {
    'key': 'speaking/attempt-1.m4a',
    'Content-Type': 'audio/mp4',
    'policy': 'base64policy',
    'x-amz-signature': 'deadbeef',
  },
  String fileField = 'file',
  int maxSizeBytes = AttemptUpload.defaultMaxSizeBytes,
}) => AttemptUpload(
  url: 'https://bucket.s3.amazonaws.com/',
  method: 'POST',
  fields: fields,
  fileField: fileField,
  maxSizeBytes: maxSizeBytes,
  expiresIn: 900,
);

void main() {
  late Directory dir;
  late File audio;
  late _CapturingAdapter adapter;
  late Dio dio;
  late AudioUploaderImpl uploader;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('uploader_test');
    audio = File('${dir.path}${Platform.pathSeparator}retelling.m4a');
    await audio.writeAsBytes(List<int>.filled(2048, 7));

    adapter = _CapturingAdapter();
    dio = Dio()..httpClientAdapter = adapter;
    uploader = AudioUploaderImpl(dio: dio);
  });

  tearDown(() => dir.delete(recursive: true));

  group('multipart POST', () {
    test('posts to the upload url', () async {
      await uploader.upload(target: _target(), filePath: audio.path);

      expect(adapter.captured!.method, 'POST');
      expect(adapter.captured!.uri.toString(), 'https://bucket.s3.amazonaws.com/');
    });

    test('sends every policy field through unchanged', () async {
      await uploader.upload(target: _target(), filePath: audio.path);

      final form = adapter.captured!.data as FormData;
      expect(
        Map.fromEntries(form.fields),
        {
          'key': 'speaking/attempt-1.m4a',
          'Content-Type': 'audio/mp4',
          'policy': 'base64policy',
          'x-amz-signature': 'deadbeef',
        },
      );
    });

    test('attaches the audio under the field the server named', () async {
      await uploader.upload(
        target: _target(fileField: 'upload_file'),
        filePath: audio.path,
      );

      final form = adapter.captured!.data as FormData;
      expect(form.files, hasLength(1));
      expect(form.files.single.key, 'upload_file');
      expect(form.files.single.value.filename, 'retelling.m4a');
      expect(form.files.single.value.length, 2048);
    });

    // S3 reads the form in order and stops at the file, so the policy fields
    // have to be on the wire before it.
    test('puts the file after the policy fields', () async {
      await uploader.upload(target: _target(), filePath: audio.path);

      final text = adapter.bodyText;
      expect(text, contains('name="policy"'));
      expect(
        text.indexOf('name="policy"'),
        lessThan(text.indexOf('name="file"')),
      );
    });

    test('never carries a JWT to S3', () async {
      await uploader.upload(target: _target(), filePath: audio.path);

      final headers = adapter.captured!.headers.keys.map(
        (key) => key.toLowerCase(),
      );
      expect(headers, isNot(contains('authorization')));
    });

    // Dio owns the boundary; a hand-written header would not match the body.
    test('lets Dio write the multipart content type', () async {
      await uploader.upload(target: _target(), filePath: audio.path);

      final contentType =
          adapter.captured!.headers[Headers.contentTypeHeader] as String?;
      expect(contentType, startsWith('multipart/form-data'));
      expect(contentType, contains('boundary='));
    });

    test('treats 204 as success', () async {
      dio.httpClientAdapter = _CapturingAdapter(statusCode: 204);

      await expectLater(
        uploader.upload(target: _target(), filePath: audio.path),
        completes,
      );
    });
  });

  group('size ceiling', () {
    test('refuses a file over the limit without calling S3', () async {
      await expectLater(
        uploader.upload(
          target: _target(maxSizeBytes: 1024),
          filePath: audio.path,
        ),
        throwsA(
          isA<UploadFailedException>().having(
            (e) => e.message,
            'message',
            contains('limit'),
          ),
        ),
      );

      expect(adapter.captured, isNull);
    });

    test('accepts a file exactly at the limit', () async {
      await expectLater(
        uploader.upload(
          target: _target(maxSizeBytes: 2048),
          filePath: audio.path,
        ),
        completes,
      );
    });
  });

  group('failures', () {
    test('reports an expired policy so a fresh attempt is made', () async {
      dio.httpClientAdapter = _CapturingAdapter(statusCode: 403);

      await expectLater(
        uploader.upload(target: _target(), filePath: audio.path),
        throwsA(isA<UploadUrlExpiredException>()),
      );
    });

    test('reports a rejected body plainly', () async {
      dio.httpClientAdapter = _CapturingAdapter(statusCode: 400);

      await expectLater(
        uploader.upload(target: _target(), filePath: audio.path),
        throwsA(isA<UploadFailedException>()),
      );
    });

    test('reports a missing recording', () async {
      await expectLater(
        uploader.upload(
          target: _target(),
          filePath: '${dir.path}${Platform.pathSeparator}gone.m4a',
        ),
        throwsA(
          isA<UploadFailedException>().having(
            (e) => e.message,
            'message',
            contains('missing'),
          ),
        ),
      );
    });
  });
}
