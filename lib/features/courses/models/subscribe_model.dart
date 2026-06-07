import '../../../core/utils/types.dart';

class SubscribeModel {
  final String courseId;
  final bool isSubscribed;
  final String? message;

  SubscribeModel({
    required this.courseId,
    required this.isSubscribed,
    this.message,
  });

  factory SubscribeModel.fromJson(Json json) => SubscribeModel(
    courseId: json['course_id'] as String,
    isSubscribed: json['is_subscribed'] as bool,
    message: json['message'] as String?,
  );
}
