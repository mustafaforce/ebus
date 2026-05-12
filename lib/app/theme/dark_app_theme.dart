import 'package:ebus/app/theme/design_tokens.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DarkAppTheme {
  DarkAppTheme._();

  static ThemeData get theme {
    final ColorScheme colorScheme = const ColorScheme.dark(
      primary: AppColors.primaryOnDark,
      onPrimary: Colors.white,
      secondary: AppColors.primaryOnDark,
      onSecondary: Colors.white,
      surface: AppColors.tile1,
      onSurface: AppColors.bodyOnDark,
      surfaceContainerHighest: AppColors.tile2,
      error: Color(0xFFFF6B6B),
      onError: Colors.white,
      outline: Color(0xFF3A3A3C),
      outlineVariant: Color(0xFF2E2E30),
    );

    final TextTheme base = GoogleFonts.interTextTheme(
      ThemeData(brightness: Brightness.dark).textTheme,
    );

    final TextTheme textTheme = base.copyWith(
      displayLarge: GoogleFonts.inter(
        fontSize: 56,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.28,
        height: 1.07,
        color: AppColors.bodyOnDark,
      ),
      displayMedium: GoogleFonts.inter(
        fontSize: 40,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.4,
        height: 1.10,
        color: AppColors.bodyOnDark,
      ),
      displaySmall: GoogleFonts.inter(
        fontSize: 34,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.374,
        height: 1.18,
        color: AppColors.bodyOnDark,
      ),
      headlineSmall: GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
        height: 1.2,
        color: AppColors.bodyOnDark,
      ),
      titleLarge: GoogleFonts.inter(
        fontSize: 21,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.1,
        color: AppColors.bodyOnDark,
      ),
      titleMedium: GoogleFonts.inter(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.374,
        color: AppColors.bodyOnDark,
      ),
      bodyLarge: GoogleFonts.inter(
        fontSize: 17,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.374,
        height: 1.44,
        color: AppColors.bodyOnDark,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.2,
        height: 1.45,
        color: AppColors.bodyMuted,
      ),
      bodySmall: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.224,
        height: 1.43,
        color: AppColors.bodyMuted,
      ),
      labelLarge: GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        letterSpacing: -0.2,
        color: AppColors.bodyOnDark,
      ),
      labelSmall: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.12,
        color: AppColors.bodyMuted,
      ),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      textTheme: textTheme,
      scaffoldBackgroundColor: AppColors.tile1,
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
      hoverColor: Colors.transparent,
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: AppColors.tile1,
        foregroundColor: AppColors.bodyOnDark,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: textTheme.titleLarge,
        iconTheme: const IconThemeData(color: AppColors.bodyOnDark, size: 22),
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0xFF3A3A3C),
        thickness: 1,
        space: 1,
      ),
      cardTheme: CardThemeData(
        color: AppColors.tile2,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          side: const BorderSide(color: Color(0xFF3A3A3C), width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.tile2,
        hintStyle: textTheme.bodyLarge?.copyWith(color: AppColors.bodyMuted),
        labelStyle: textTheme.bodySmall,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: Color(0xFF3A3A3C), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.primaryOnDark, width: 1.5),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primaryOnDark,
          foregroundColor: Colors.white,
          disabledBackgroundColor: const Color(0xFF3A3A3C),
          disabledForegroundColor: AppColors.bodyMuted,
          minimumSize: const Size.fromHeight(48),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
          textStyle: GoogleFonts.inter(
            fontSize: 17,
            fontWeight: FontWeight.w500,
            letterSpacing: -0.2,
          ),
          shape: const StadiumBorder(),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryOnDark,
          side: const BorderSide(color: AppColors.primaryOnDark, width: 1),
          minimumSize: const Size.fromHeight(48),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
          textStyle: GoogleFonts.inter(
            fontSize: 17,
            fontWeight: FontWeight.w500,
            letterSpacing: -0.2,
          ),
          shape: const StadiumBorder(),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryOnDark,
          textStyle: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            letterSpacing: -0.2,
          ),
        ),
      ),
      iconTheme: const IconThemeData(color: AppColors.bodyOnDark, size: 22),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primaryOnDark,
      ),
    );
  }
}
