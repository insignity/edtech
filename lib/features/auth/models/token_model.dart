import '../../../../core/utils/types.dart';

class TokenModel {
  final String access;
  final String refresh;

  TokenModel({required this.access, required this.refresh});

  factory TokenModel.fromJson(Json json) => TokenModel(
        access: json['access'] as String,
        refresh: json['refresh'] as String,
      );
}
