part of 'app_themes.dart';

abstract class AppColors {
  // Brand — lavender
  static const Color primary = Color(0xFF6E64A6);       // Buttons, meters, active tab
  static const Color primaryDark = Color(0xFF5C5390);   // Pressed
  static const Color primaryMuted = Color(0xFFA79FD1);  // 400 — mid peaks, inactive
  static const Color primarySoft = Color(0xFFD5D1EA);   // 200 — quiet peaks
  static const Color primaryLight = Color(0xFFF0EEF8);  // Tint — goal, mic, feedback
  static const Color primaryDeep = Color(0xFF383060);   // Text on tint, headings

  // Secondary
  static const Color accent = Color(0xFFA79FD1);
  static const Color accentLight = Color(0xFFD5D1EA);

  // Score bands: success >= 90, warning 70-89, error < 70 and failures
  static const Color success = Color(0xFF3A7360);
  static const Color successLight = Color(0xFFE7F0EC);
  static const Color warning = Color(0xFF9A7430);
  static const Color warningLight = Color(0xFFF6EFDF);
  static const Color error = Color(0xFFA0463E);
  static const Color errorLight = Color(0xFFF7E9E7);

  // Neutrals
  static const Color darkText = Color(0xFF232130);      // Warm black, violet cast
  static const Color gray = Color(0xFF6F6C7E);          // Captions, metadata
  static const Color textSecondary = gray;
  static const Color grayMuted = Color(0xFF9B98A8);     // Hints, disabled — derived
  static const Color border = Color(0xFFE4E2EC);        // Borders, dividers
  static const Color grayLight = Color(0xFFF4F3F7);     // Card and meter fill
  static const Color white = Color(0xFFFFFFFF);
  static const Color background = Color(0xFFFFFFFF);    // Screens are white
  static const Color surface = Color(0xFFFFFFFF);       // Material base surface
}
