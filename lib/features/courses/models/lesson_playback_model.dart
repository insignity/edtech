import 'package:edtech/core/utils/types.dart';
import 'package:edtech/features/courses/models/lesson_model.dart';

/// Response of `GET /lessons/{id}/playback/` — a freshly signed, short-lived
/// URL plus enough metadata to pick and size the right player. Must be
/// requested anew every time a lesson's video is opened; never cached across
/// visits or persisted alongside the lesson.
class LessonPlaybackModel {
  final VideoSource source;
  final String? url;
  final String? contentType;
  final int? expiresIn;
  final int? width;
  final int? height;
  final double? durationSeconds;

  const LessonPlaybackModel({
    required this.source,
    required this.url,
    required this.contentType,
    required this.expiresIn,
    required this.width,
    required this.height,
    required this.durationSeconds,
  });

  factory LessonPlaybackModel.fromJson(Json json) => LessonPlaybackModel(
    source: VideoSource.parse(json['source'] as String?) ?? VideoSource.none,
    url: json['url'] as String?,
    contentType: json['content_type'] as String?,
    expiresIn: json['expires_in'] as int?,
    width: json['width'] as int?,
    height: json['height'] as int?,
    durationSeconds: (json['duration_seconds'] as num?)?.toDouble(),
  );

  // url is a short-lived signed link — never print it.
  @override
  String toString() => 'LessonPlaybackModel(source: ${source.name})';
}
