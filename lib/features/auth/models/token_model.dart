import '../../../../core/utils/types.dart';

class TokenModel {
  final String access;

  TokenModel({required this.access});

  factory TokenModel.fromJson(Json json) =>
      TokenModel(access: json['access'] as String);
}

//{
//   "refresh": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3NTcxMTg0MiwiaWF0IjoxNzc1MTA3MDQyLCJqdGkiOiJjZGFkN2I4MGRmMzA0ZjI1YmJmODFiNmVkNDJjZDllNSIsInVzZXJfaWQiOiI3In0.880m1cjfR3ma38_hRDZru1x-XPsvENFBZ9SLYUNKHww",
//   "access": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoiYWNjZXNzIiwiZXhwIjoxNzc1MTEwNjQyLCJpYXQiOjE3NzUxMDcwNDIsImp0aSI6ImE4YWVkZGU3MDMxNDRmYmM4MDBmMGNiYzIyMTNiODc1IiwidXNlcl9pZCI6IjcifQ.eQEQFTTy5L2VsJgN-GROlE0shRzTVQ75tN02EDJ6_ck"
// }
