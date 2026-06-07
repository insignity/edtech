part of 'app_themes.dart';

class AppInputDecorationTheme {
  static final borderRadius = BorderRadius.circular(12);

  static final mobile = InputDecorationTheme(
    filled: true,
    fillColor: AppColors.grayLight,
    labelStyle: TextStyle(color: AppColors.gray, fontSize: 14),
    floatingLabelStyle: TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w500),
    enabledBorder: OutlineInputBorder(
      borderRadius: borderRadius,
      borderSide: const BorderSide(color: AppColors.border),
    ),
    disabledBorder: OutlineInputBorder(
      borderRadius: borderRadius,
      borderSide: const BorderSide(color: AppColors.border),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: borderRadius,
      borderSide: const BorderSide(color: AppColors.primary, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: borderRadius,
      borderSide: const BorderSide(color: AppColors.error),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: borderRadius,
      borderSide: const BorderSide(color: AppColors.error, width: 2),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
  );
}
