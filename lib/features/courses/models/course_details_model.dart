import 'lesson_model.dart';

class CourseDetailsModel {
  final String id;
  final String name;
  final String? description;
  final String? previewUrl;
  final int lessonsCount;
  final bool isSubscribed;
  final List<LessonModel> lessons;

  CourseDetailsModel({
    required this.id,
    required this.name,
    required this.description,
    required this.previewUrl,
    required this.lessonsCount,
    required this.isSubscribed,
    required this.lessons,
  });

  factory CourseDetailsModel.fromJson(Map<String, dynamic> json) {
    final lessons = (json['lessons'] as List)
        .map((e) => LessonModel.fromJson(e as Map<String, dynamic>))
        .toList();

    return CourseDetailsModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      previewUrl: json['preview_url'] as String?,
      lessonsCount: json['lessons_count'] as int,
      isSubscribed: json['is_subscribed'] as bool,
      lessons: lessons,
    );
  }

  CourseDetailsModel copyWith({
    String? id,
    String? name,
    String? description,
    String? previewUrl,
    int? lessonsCount,
    bool? isSubscribed,
    List<LessonModel>? lessons,
  }) {
    return CourseDetailsModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      previewUrl: previewUrl ?? this.previewUrl,
      lessonsCount: lessonsCount ?? this.lessonsCount,
      isSubscribed: isSubscribed ?? this.isSubscribed,
      lessons: lessons ?? this.lessons,
    );
  }
}
