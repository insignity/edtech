import 'package:edtech/core/utils/types.dart';

import 'course_model.dart';

class CoursesModel {
  final List<CourseModel> courses;
  final int count;
  final String? next;
  final String? previous;

  CoursesModel({
    required this.courses,
    required this.count,
    this.next,
    this.previous,
  });

  factory CoursesModel.fromJson(Json json) {
    return CoursesModel(
      courses: (json['results'] as List<dynamic>)
          .map((item) => CourseModel.fromJson(item as Json))
          .toList(),
      count: json['count'] as int,
      next: json['next'] as String?,
      previous: json['previous'] as String?,
    );
  }

  @override
  String toString() {
    return "Courses([${courses}])";
  }
}
