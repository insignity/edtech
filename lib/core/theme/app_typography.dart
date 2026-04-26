part of 'app_themes.dart';

abstract class AppFonts {
  static const String roboto = 'Roboto';
}

class AppTextTheme {
  static const mobile = TextTheme(
    headlineMedium: TextStyle(
      fontFamily: AppFonts.roboto,
      fontWeight: FontWeight.w700,
      fontSize: 28,
      height: 38 / 28,
    ),
    titleLarge: TextStyle(
      fontFamily: AppFonts.roboto,
      fontWeight: FontWeight.w600,
      fontSize: 16,
      height: 24 / 16,
    ),
    bodyLarge: TextStyle(
      fontFamily: AppFonts.roboto,
      fontWeight: FontWeight.w400,
      fontSize: 16,
      height: 24 / 16,
    ),
    bodyMedium: TextStyle(
      fontFamily: AppFonts.roboto,
      fontWeight: FontWeight.w400,
      fontSize: 14,
      height: 19 / 14,
    ),
    labelLarge: TextStyle(
      fontFamily: AppFonts.roboto,
      fontWeight: FontWeight.w500,
      fontSize: 14,
      height: 19 / 14,
    ),
  );
}

extension AppTextThemeExtension on TextTheme {
  TextStyle? get hM => headlineMedium;

  TextStyle? get tL => titleLarge;

  TextStyle? get bL => bodyLarge;

  TextStyle? get bM => bodyMedium;

  TextStyle? get lL => labelLarge;
}

extension AppTextStyleExtension on TextStyle {
  TextStyle get bold {
    return copyWith(fontWeight: FontWeight.bold);
  }

  TextStyle get semiBold {
    return copyWith(fontWeight: FontWeight.w600);
  }

  TextStyle get regular {
    return copyWith(fontWeight: FontWeight.normal);
  }

  TextStyle get medium {
    return copyWith(fontWeight: FontWeight.w500);
  }

  TextStyle get italic {
    return copyWith(fontStyle: FontStyle.italic);
  }

  TextStyle get underline {
    return copyWith(decoration: TextDecoration.underline);
  }

  double? get lineHeight {
    return fontSize != null && height != null ? fontSize! * height! : null;
  }

  TextStyle opacity(int percent) {
    assert(percent >= 0 && percent <= 100);
    return copyWith(color: color?.withOpacity(percent / 100.0));
  }

  TextStyle size(double size) {
    return copyWith(fontSize: size);
  }

  TextStyle weight(FontWeight weight) {
    return copyWith(fontWeight: weight);
  }

  TextStyle fontStyle(FontStyle fontStyle) {
    return copyWith(fontStyle: fontStyle);
  }

  TextStyle operator +(Color? color) {
    return copyWith(color: color);
  }
}
