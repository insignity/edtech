class PasswordResetModel {
  final String detail;
  final String uid;
  final String token;

  PasswordResetModel({
    required this.detail,
    required this.uid,
    required this.token,
  });

  factory PasswordResetModel.fromJson(Map<String, dynamic> json) =>
      PasswordResetModel(
        detail: json['detail'] as String,
        uid: json['uid'] as String,
        token: json['token'] as String,
      );
}
