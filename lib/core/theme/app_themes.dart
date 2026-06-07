import 'package:flutter/material.dart';

part 'app_colors.dart';
part 'app_input_decoration.dart';
part 'app_typography.dart';

abstract class AppThemes {
  static final mobile = ThemeData(
    textTheme: AppTextTheme.mobile,
    inputDecorationTheme: AppInputDecorationTheme.mobile,
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        textStyle: WidgetStatePropertyAll(
          TextStyle(
            fontFamily: AppFonts.roboto,
            fontWeight: FontWeight.w600,
            fontSize: 16,
            height: 21 / 16,
          ),
        ),
        foregroundColor: WidgetStatePropertyAll(AppColors.white),
        padding: const WidgetStatePropertyAll(
          EdgeInsets.symmetric(vertical: 12),
        ),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        shadowColor: const WidgetStatePropertyAll(AppColors.gray),
        backgroundColor: WidgetStateProperty.resolveWith((
          Set<WidgetState> states,
        ) {
          if (states.contains(WidgetState.disabled)) {
            return AppColors.gray;
          } else {
            return AppColors.primary;
          }
        }),
      ),
    ),
  );
}
