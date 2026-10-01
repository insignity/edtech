/// Which backend path a lesson's video should play through, from the
/// `video_source` field. Null means the backend predates this field — fall
/// back to the legacy [LessonModel.video] URL.
enum VideoSource {
  s3,
  youtube,
  none;

  static VideoSource? parse(String? value) => switch (value) {
    's3' => VideoSource.s3,
    'youtube' => VideoSource.youtube,
    'none' => VideoSource.none,
    _ => null,
  };
}

class LessonModel {
  final String id;
  final String name;
  final String? description;
  final String video;
  final String? previewUrl;
  final int course;
  final int owner;
  final bool isCompleted;
  final VideoSource? videoSource;

  LessonModel({
    required this.id,
    required this.name,
    required this.description,
    required this.video,
    required this.previewUrl,
    required this.course,
    required this.owner,
    required this.isCompleted,
    this.videoSource,
  });

  factory LessonModel.fromJson(Map<String, dynamic> json) {
    return LessonModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      video: json['video'] as String? ?? '',
      previewUrl: json['preview_url'] as String?,
      course: json['course'] as int,
      owner: json['owner'] as int,
      isCompleted: json['is_completed'] as bool? ?? false,
      videoSource: VideoSource.parse(json['video_source'] as String?),
    );
  }

  @override
  String toString() =>
      'LessonModel(id: $id, name: $name, completed: $isCompleted)';
}
