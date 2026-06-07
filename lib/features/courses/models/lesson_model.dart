class LessonModel {
  final String id;
  final String name;
  final String? description;
  final String video;
  final String? previewUrl;

  LessonModel({
    required this.id,
    required this.name,
    required this.description,
    required this.video,
    required this.previewUrl,
  });

  factory LessonModel.fromJson(Map<String, dynamic> json) {
    return LessonModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      video: json['video'] as String,
      previewUrl: json['preview_url'] as String?,
    );
  }
}
