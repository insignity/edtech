import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

part 'app_colors.dart';
part 'app_input_decoration.dart';
part 'app_typography.dart';

abstract class AppThemes {
  static final mobile = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
      secondary: AppColors.accent,
      error: AppColors.error,
      surface: AppColors.surface,
    ),
    scaffoldBackgroundColor: AppColors.background,
    textTheme: AppTextTheme.mobile,
    inputDecorationTheme: AppInputDecorationTheme.mobile,

    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.white,
      elevation: 0,
      scrolledUnderElevation: 1,
      shadowColor: AppColors.border,
      centerTitle: true,
      iconTheme: const IconThemeData(color: AppColors.darkText),
      titleTextStyle: GoogleFonts.manrope(
        fontWeight: FontWeight.w700,
        fontSize: 17,
        color: AppColors.darkText,
      ),
    ),

    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: AppColors.white,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.grayMuted,
      selectedLabelStyle: GoogleFonts.manrope(
        fontSize: 11,
        fontWeight: FontWeight.w700,
      ),
      unselectedLabelStyle: GoogleFonts.manrope(
        fontSize: 11,
        fontWeight: FontWeight.w500,
      ),
      elevation: 8,
      type: BottomNavigationBarType.fixed,
    ),

    // Filled surface, no border — matches the design's card language.
    cardTheme: CardThemeData(
      elevation: 0,
      color: AppColors.grayLight,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: EdgeInsets.zero,
    ),

    // Pill CTA: indigo fill, white label, weight 500.
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        textStyle: WidgetStatePropertyAll(
          GoogleFonts.manrope(fontWeight: FontWeight.w500, fontSize: 15),
        ),
        padding: const WidgetStatePropertyAll(
          EdgeInsets.symmetric(vertical: 15, horizontal: 22),
        ),
        shape: const WidgetStatePropertyAll(StadiumBorder()),
        elevation: const WidgetStatePropertyAll(0),
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) return AppColors.grayLight;
          if (states.contains(WidgetState.pressed)) return AppColors.primaryDark;
          return AppColors.primary;
        }),
        foregroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) return AppColors.grayMuted;
          return AppColors.white;
        }),
      ),
    ),

    // Secondary pill: white fill, neutral border and label.
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: ButtonStyle(
        textStyle: WidgetStatePropertyAll(
          GoogleFonts.manrope(fontWeight: FontWeight.w500, fontSize: 15),
        ),
        backgroundColor: const WidgetStatePropertyAll(AppColors.white),
        foregroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) return AppColors.grayMuted;
          return AppColors.textSecondary;
        }),
        side: const WidgetStatePropertyAll(
          BorderSide(color: AppColors.border),
        ),
        padding: const WidgetStatePropertyAll(
          EdgeInsets.symmetric(vertical: 15, horizontal: 22),
        ),
        shape: const WidgetStatePropertyAll(StadiumBorder()),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: ButtonStyle(
        textStyle: WidgetStatePropertyAll(
          GoogleFonts.manrope(fontWeight: FontWeight.w500, fontSize: 15),
        ),
        foregroundColor: const WidgetStatePropertyAll(AppColors.primary),
        padding: const WidgetStatePropertyAll(
          EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        ),
        shape: const WidgetStatePropertyAll(StadiumBorder()),
      ),
    ),

    dividerTheme: const DividerThemeData(
      color: AppColors.border,
      thickness: 1,
      space: 0,
    ),
  );
}
