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
      titleTextStyle: GoogleFonts.poppins(
        fontWeight: FontWeight.w600,
        fontSize: 18,
        color: AppColors.darkText,
      ),
    ),

    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.white,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.gray,
      selectedLabelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      unselectedLabelStyle: TextStyle(fontSize: 12),
      elevation: 8,
      type: BottomNavigationBarType.fixed,
    ),

    cardTheme: CardThemeData(
      elevation: 0,
      color: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.border),
      ),
      margin: EdgeInsets.zero,
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        textStyle: WidgetStatePropertyAll(
          GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 15,
            letterSpacing: 0.5,
          ),
        ),
        foregroundColor: const WidgetStatePropertyAll(AppColors.white),
        padding: const WidgetStatePropertyAll(
          EdgeInsets.symmetric(vertical: 14),
        ),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        elevation: const WidgetStatePropertyAll(0),
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return AppColors.gray.withOpacity(0.4);
          }
          return AppColors.primary;
        }),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: ButtonStyle(
        textStyle: WidgetStatePropertyAll(
          GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 15),
        ),
        foregroundColor: const WidgetStatePropertyAll(AppColors.primary),
        side: const WidgetStatePropertyAll(
          BorderSide(color: AppColors.primary, width: 1.5),
        ),
        padding: const WidgetStatePropertyAll(
          EdgeInsets.symmetric(vertical: 14),
        ),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    ),

    dividerTheme: const DividerThemeData(
      color: AppColors.border,
      thickness: 1,
      space: 0,
    ),
  );
}
