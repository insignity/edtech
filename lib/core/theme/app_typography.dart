part of 'app_themes.dart';

abstract class AppFonts {
  static const String manrope = 'Manrope';
}

class AppTextTheme {
  // Manrope, three weights only: 400 / 500 / 700.
  static TextTheme get mobile => TextTheme(
    displaySmall: GoogleFonts.manrope(
      fontWeight: FontWeight.w700,
      fontSize: 38,
      height: 1.1,
      color: AppColors.darkText,
    ),
    headlineMedium: GoogleFonts.manrope(
      fontWeight: FontWeight.w700,
      fontSize: 26,
      height: 1.25,
      color: AppColors.darkText,
    ),
    headlineSmall: GoogleFonts.manrope(
      fontWeight: FontWeight.w700,
      fontSize: 22,
      height: 1.3,
      color: AppColors.darkText,
    ),
    titleLarge: GoogleFonts.manrope(
      fontWeight: FontWeight.w700,
      fontSize: 17,
      height: 1.4,
      color: AppColors.darkText,
    ),
    titleMedium: GoogleFonts.manrope(
      fontWeight: FontWeight.w500,
      fontSize: 15,
      height: 1.4,
      color: AppColors.darkText,
    ),
    bodyLarge: GoogleFonts.manrope(
      fontWeight: FontWeight.w400,
      fontSize: 15,
      height: 1.55,
      color: AppColors.textSecondary,
    ),
    bodyMedium: GoogleFonts.manrope(
      fontWeight: FontWeight.w400,
      fontSize: 14,
      height: 1.5,
      color: AppColors.gray,
    ),
    labelLarge: GoogleFonts.manrope(
      fontWeight: FontWeight.w500,
      fontSize: 15,
      height: 1.4,
    ),
    labelMedium: GoogleFonts.manrope(
      fontWeight: FontWeight.w500,
      fontSize: 13,
      height: 1.4,
      color: AppColors.gray,
    ),
    // Pill badges and uppercase section labels.
    labelSmall: GoogleFonts.manrope(
      fontWeight: FontWeight.w700,
      fontSize: 11,
      height: 1.3,
      letterSpacing: 0.5,
      color: AppColors.gray,
    ),
  );
}

extension AppTextThemeExtension on TextTheme {
  TextStyle? get hM => headlineMedium;
  TextStyle? get hS => headlineSmall;
  TextStyle? get tL => titleLarge;
  TextStyle? get tM => titleMedium;
  TextStyle? get bL => bodyLarge;
  TextStyle? get bM => bodyMedium;
  TextStyle? get lL => labelLarge;
  TextStyle? get lM => labelMedium;
  TextStyle? get lS => labelSmall;
}

extension AppTextStyleExtension on TextStyle {
  TextStyle get bold => copyWith(fontWeight: FontWeight.bold);
  TextStyle get semiBold => copyWith(fontWeight: FontWeight.w600);
  TextStyle get regular => copyWith(fontWeight: FontWeight.normal);
  TextStyle get medium => copyWith(fontWeight: FontWeight.w500);
  TextStyle get italic => copyWith(fontStyle: FontStyle.italic);
  TextStyle get underline => copyWith(decoration: TextDecoration.underline);

  double? get lineHeight =>
      fontSize != null && height != null ? fontSize! * height! : null;

  TextStyle opacity(int percent) {
    assert(percent >= 0 && percent <= 100);
    return copyWith(color: color?.withOpacity(percent / 100.0));
  }

  TextStyle size(double size) => copyWith(fontSize: size);
  TextStyle weight(FontWeight weight) => copyWith(fontWeight: weight);
  TextStyle fontStyle(FontStyle fontStyle) => copyWith(fontStyle: fontStyle);

  TextStyle operator +(Color? color) => copyWith(color: color);
}
