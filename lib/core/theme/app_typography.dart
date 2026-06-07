part of 'app_themes.dart';

abstract class AppFonts {
  static const String poppins = 'Poppins';
  static const String roboto = 'Roboto';
}

class AppTextTheme {
  static TextTheme get mobile => TextTheme(
    displaySmall: GoogleFonts.poppins(
      fontWeight: FontWeight.w700,
      fontSize: 32,
      height: 1.2,
      color: AppColors.darkText,
    ),
    headlineMedium: GoogleFonts.poppins(
      fontWeight: FontWeight.w700,
      fontSize: 28,
      height: 1.3,
      color: AppColors.darkText,
    ),
    headlineSmall: GoogleFonts.poppins(
      fontWeight: FontWeight.w600,
      fontSize: 22,
      height: 1.3,
      color: AppColors.darkText,
    ),
    titleLarge: GoogleFonts.poppins(
      fontWeight: FontWeight.w600,
      fontSize: 16,
      height: 1.5,
      color: AppColors.darkText,
    ),
    titleMedium: GoogleFonts.poppins(
      fontWeight: FontWeight.w500,
      fontSize: 14,
      height: 1.5,
      color: AppColors.darkText,
    ),
    bodyLarge: GoogleFonts.roboto(
      fontWeight: FontWeight.w400,
      fontSize: 16,
      height: 1.5,
      color: AppColors.darkText,
    ),
    bodyMedium: GoogleFonts.roboto(
      fontWeight: FontWeight.w400,
      fontSize: 14,
      height: 1.5,
      color: AppColors.gray,
    ),
    labelLarge: GoogleFonts.poppins(
      fontWeight: FontWeight.w600,
      fontSize: 14,
      height: 1.4,
      letterSpacing: 0.5,
    ),
    labelMedium: GoogleFonts.roboto(
      fontWeight: FontWeight.w500,
      fontSize: 12,
      height: 1.4,
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
