import 'package:flutter/material.dart';

part 'app_typography.dart';
part 'app_colors.dart';
part 'app_input_decoration.dart';

abstract class AppThemes {
  static final mobile = ThemeData(
    textTheme: AppTextTheme.mobile,
    inputDecorationTheme: AppInputDecorationTheme.mobile,
  );
}