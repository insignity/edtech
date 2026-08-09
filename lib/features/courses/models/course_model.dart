import 'lesson_model.dart';

class CourseModel {
  final String id;
  final String name;
  final String? description;
  final String? previewUrl;
  final int lessonsCount;
  final List<LessonModel>? lessons;

  CourseModel({
    required this.id,
    required this.name,
    required this.description,
    required this.previewUrl,
    required this.lessonsCount,
    required this.lessons,
  });

  factory CourseModel.fromJson(Map<String, dynamic> json) {
    List<LessonModel>? lessons;
    if (json['lessons'] != null) {
      lessons = (json['lessons'] as List)
          .map((e) => LessonModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return CourseModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      previewUrl: json['preview_url'] as String?,
      lessonsCount: json['lessons_count'] as int,
      lessons: lessons,
    );
  }
}
