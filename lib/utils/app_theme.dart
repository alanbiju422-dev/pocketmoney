import 'package:flutter/material.dart';

/// Design system for Pocket Money Tracker.
/// Follows the Classic Editorial + Premium Minimalist direction.
/// Strict Light Theme with Warm Ivory, Soft Cream, Sage Green, and Muted Terracotta.
/// Sophisticated Dark Theme with deep muted tones (#171916, #232721, #2C322B, #F2F0E8, #AAAFA4).
class AppColors {
  AppColors._();

  // Core Backgrounds (Light mode constants preserved 100%)
  static const Color mainBackground = Color(0xFFF8F6F0); // Warm ivory
  static const Color secondaryBackground = Color(0xFFF1EEE5); // Soft cream
  static const Color cardBackground = Color(0xFFFFFFFF); // Pure white

  // Accents
  static const Color primarySage = Color(0xFF91A58B); // Muted sage green
  static const Color primarySageDark = Color(0xFF7A8F74);
  static const Color primarySageLight = Color(0xFFE8ECE6);

  static const Color secondaryOlive = Color(0xFFB2B99A); // Soft olive
  static const Color secondaryOliveLight = Color(0xFFEFF1EA);

  static const Color supportingTerracotta = Color(0xFFC58F78); // Muted terracotta
  static const Color terracottaLight = Color(0xFFF9F1ED);

  // Borders & Dividers
  static const Color borderBeige = Color(0xFFE6E1D6); // Warm beige
  static const Color borderSubtle = Color(0xFFECE8E0);

  // Typography
  static const Color textPrimary = Color(0xFF514E46); // Warm charcoal
  static const Color textSecondary = Color(0xFF918D83); // Muted grey
  static const Color textTertiary = Color(0xFFB0ACA4);

  // Financial Indicators
  static const Color incomeGreen = Color(0xFF5D8563); // Natural soft green
  static const Color incomeGreenBackground = Color(0xFFEFF5F0);
  static const Color expenseTerracotta = Color(0xFFC58F78); // Muted terracotta
  static const Color expenseBackground = Color(0xFFFBF3EF);

  // Surface tints
  static const Color surfaceElevation = Color(0x0A514E46);

  // Light Scheme Definition
  static const AppColorScheme light = AppColorScheme(
    isDark: false,
    mainBackground: mainBackground,
    secondaryBackground: secondaryBackground,
    cardBackground: cardBackground,
    primarySage: primarySage,
    primarySageDark: primarySageDark,
    primarySageLight: primarySageLight,
    secondaryOlive: secondaryOlive,
    secondaryOliveLight: secondaryOliveLight,
    supportingTerracotta: supportingTerracotta,
    terracottaLight: terracottaLight,
    borderBeige: borderBeige,
    borderSubtle: borderSubtle,
    textPrimary: textPrimary,
    textSecondary: textSecondary,
    textTertiary: textTertiary,
    incomeGreen: incomeGreen,
    incomeGreenBackground: incomeGreenBackground,
    expenseTerracotta: expenseTerracotta,
    expenseBackground: expenseBackground,
    surfaceElevation: surfaceElevation,
  );

  // Dark Scheme Definition
  static const AppColorScheme dark = AppColorScheme(
    isDark: true,
    mainBackground: Color(0xFF171916), // #171916
    secondaryBackground: Color(0xFF2C322B), // #2C322B
    cardBackground: Color(0xFF232721), // #232721
    primarySage: Color(0xFF91A58B), // #91A58B
    primarySageDark: Color(0xFFA8BCA3),
    primarySageLight: Color(0xFF293427),
    secondaryOlive: Color(0xFFB2B99A),
    secondaryOliveLight: Color(0xFF323B30),
    supportingTerracotta: Color(0xFFD49A83), // #D49A83
    terracottaLight: Color(0xFF382923),
    borderBeige: Color(0xFF383F36), // #383F36
    borderSubtle: Color(0xFF2B3229),
    textPrimary: Color(0xFFF2F0E8), // #F2F0E8
    textSecondary: Color(0xFFAAAFA4), // #AAAFA4
    textTertiary: Color(0xFF767D70),
    incomeGreen: Color(0xFF7EAA84),
    incomeGreenBackground: Color(0xFF1F2F22),
    expenseTerracotta: Color(0xFFD49A83),
    expenseBackground: Color(0xFF382721),
    surfaceElevation: Color(0x24000000),
  );

  /// Resolves the active theme color palette based on current brightness
  static AppColorScheme of(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? dark : light;
  }
}

/// Dynamic theme-aware color palette
class AppColorScheme {
  final bool isDark;
  final Color mainBackground;
  final Color secondaryBackground;
  final Color cardBackground;
  final Color primarySage;
  final Color primarySageDark;
  final Color primarySageLight;
  final Color secondaryOlive;
  final Color secondaryOliveLight;
  final Color supportingTerracotta;
  final Color terracottaLight;
  final Color borderBeige;
  final Color borderSubtle;
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;
  final Color incomeGreen;
  final Color incomeGreenBackground;
  final Color expenseTerracotta;
  final Color expenseBackground;
  final Color surfaceElevation;

  const AppColorScheme({
    required this.isDark,
    required this.mainBackground,
    required this.secondaryBackground,
    required this.cardBackground,
    required this.primarySage,
    required this.primarySageDark,
    required this.primarySageLight,
    required this.secondaryOlive,
    required this.secondaryOliveLight,
    required this.supportingTerracotta,
    required this.terracottaLight,
    required this.borderBeige,
    required this.borderSubtle,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.incomeGreen,
    required this.incomeGreenBackground,
    required this.expenseTerracotta,
    required this.expenseBackground,
    required this.surfaceElevation,
  });

  /// Standard border color for containers and cards
  Color get border => borderBeige;

  /// Subtle elevation shadow color
  Color get shadow => surfaceElevation;
}

extension ThemeContextX on BuildContext {
  AppColorScheme get colors => AppColors.of(this);
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;
}

class AppFonts {
  AppFonts._();

  static const String headingFont = 'Lora';
  static const String bodyFont = 'SourceSans3';
}

class AppTheme {
  AppTheme._();

  /// Light theme — Exactly preserved without any modifications
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.mainBackground,
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: AppColors.primarySage,
        onPrimary: Colors.white,
        secondary: AppColors.secondaryOlive,
        onSecondary: AppColors.textPrimary,
        error: AppColors.supportingTerracotta,
        onError: Colors.white,
        surface: AppColors.cardBackground,
        onSurface: AppColors.textPrimary,
      ),
      fontFamily: AppFonts.bodyFont,
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontFamily: AppFonts.headingFont,
          fontSize: 34,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
          letterSpacing: -0.5,
        ),
        displayMedium: TextStyle(
          fontFamily: AppFonts.headingFont,
          fontSize: 28,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
          letterSpacing: -0.3,
        ),
        displaySmall: TextStyle(
          fontFamily: AppFonts.headingFont,
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        headlineLarge: TextStyle(
          fontFamily: AppFonts.headingFont,
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        headlineMedium: TextStyle(
          fontFamily: AppFonts.headingFont,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        headlineSmall: TextStyle(
          fontFamily: AppFonts.headingFont,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        titleLarge: TextStyle(
          fontFamily: AppFonts.headingFont,
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
        titleMedium: TextStyle(
          fontFamily: AppFonts.bodyFont,
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        titleSmall: TextStyle(
          fontFamily: AppFonts.bodyFont,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        bodyLarge: TextStyle(
          fontFamily: AppFonts.bodyFont,
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: AppColors.textPrimary,
          height: 1.4,
        ),
        bodyMedium: TextStyle(
          fontFamily: AppFonts.bodyFont,
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: AppColors.textPrimary,
          height: 1.35,
        ),
        bodySmall: TextStyle(
          fontFamily: AppFonts.bodyFont,
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: AppColors.textSecondary,
        ),
        labelLarge: TextStyle(
          fontFamily: AppFonts.bodyFont,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
          letterSpacing: 0.2,
        ),
        labelMedium: TextStyle(
          fontFamily: AppFonts.bodyFont,
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: AppColors.textSecondary,
          letterSpacing: 0.1,
        ),
        labelSmall: TextStyle(
          fontFamily: AppFonts.bodyFont,
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: AppColors.textSecondary,
          letterSpacing: 0.1,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.mainBackground,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: AppColors.textPrimary),
        titleTextStyle: TextStyle(
          fontFamily: AppFonts.headingFont,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.cardBackground,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.borderBeige, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.borderBeige,
        thickness: 1,
        space: 1,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.cardBackground,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.borderBeige, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.borderBeige, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primarySage, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.supportingTerracotta, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.supportingTerracotta, width: 1.5),
        ),
        hintStyle: const TextStyle(
          fontFamily: AppFonts.bodyFont,
          color: AppColors.textTertiary,
          fontSize: 14,
        ),
        labelStyle: const TextStyle(
          fontFamily: AppFonts.bodyFont,
          color: AppColors.textSecondary,
          fontSize: 14,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primarySage,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: const TextStyle(
            fontFamily: AppFonts.bodyFont,
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primarySageDark,
          textStyle: const TextStyle(
            fontFamily: AppFonts.bodyFont,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.cardBackground,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
    );
  }

  /// Dark theme — Carefully crafted to complement the existing editorial design
  static ThemeData get darkTheme {
    final darkColors = AppColors.dark;

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkColors.mainBackground,
      colorScheme: ColorScheme(
        brightness: Brightness.dark,
        primary: darkColors.primarySage,
        onPrimary: Colors.white,
        secondary: darkColors.secondaryOlive,
        onSecondary: darkColors.textPrimary,
        error: darkColors.supportingTerracotta,
        onError: Colors.white,
        surface: darkColors.cardBackground,
        onSurface: darkColors.textPrimary,
      ),
      fontFamily: AppFonts.bodyFont,
      textTheme: TextTheme(
        displayLarge: TextStyle(
          fontFamily: AppFonts.headingFont,
          fontSize: 34,
          fontWeight: FontWeight.w600,
          color: darkColors.textPrimary,
          letterSpacing: -0.5,
        ),
        displayMedium: TextStyle(
          fontFamily: AppFonts.headingFont,
          fontSize: 28,
          fontWeight: FontWeight.w600,
          color: darkColors.textPrimary,
          letterSpacing: -0.3,
        ),
        displaySmall: TextStyle(
          fontFamily: AppFonts.headingFont,
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: darkColors.textPrimary,
        ),
        headlineLarge: TextStyle(
          fontFamily: AppFonts.headingFont,
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: darkColors.textPrimary,
        ),
        headlineMedium: TextStyle(
          fontFamily: AppFonts.headingFont,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: darkColors.textPrimary,
        ),
        headlineSmall: TextStyle(
          fontFamily: AppFonts.headingFont,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: darkColors.textPrimary,
        ),
        titleLarge: TextStyle(
          fontFamily: AppFonts.headingFont,
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: darkColors.textPrimary,
        ),
        titleMedium: TextStyle(
          fontFamily: AppFonts.bodyFont,
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: darkColors.textPrimary,
        ),
        titleSmall: TextStyle(
          fontFamily: AppFonts.bodyFont,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: darkColors.textPrimary,
        ),
        bodyLarge: TextStyle(
          fontFamily: AppFonts.bodyFont,
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: darkColors.textPrimary,
          height: 1.4,
        ),
        bodyMedium: TextStyle(
          fontFamily: AppFonts.bodyFont,
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: darkColors.textPrimary,
          height: 1.35,
        ),
        bodySmall: TextStyle(
          fontFamily: AppFonts.bodyFont,
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: darkColors.textSecondary,
        ),
        labelLarge: TextStyle(
          fontFamily: AppFonts.bodyFont,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: darkColors.textPrimary,
          letterSpacing: 0.2,
        ),
        labelMedium: TextStyle(
          fontFamily: AppFonts.bodyFont,
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: darkColors.textSecondary,
          letterSpacing: 0.1,
        ),
        labelSmall: TextStyle(
          fontFamily: AppFonts.bodyFont,
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: darkColors.textSecondary,
          letterSpacing: 0.1,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: darkColors.mainBackground,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: darkColors.textPrimary),
        titleTextStyle: TextStyle(
          fontFamily: AppFonts.headingFont,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: darkColors.textPrimary,
        ),
      ),
      cardTheme: CardThemeData(
        color: darkColors.cardBackground,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: darkColors.borderBeige, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      dividerTheme: DividerThemeData(
        color: darkColors.borderBeige,
        thickness: 1,
        space: 1,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: darkColors.cardBackground,
        surfaceTintColor: Colors.transparent,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkColors.cardBackground,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: darkColors.borderBeige, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: darkColors.borderBeige, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: darkColors.primarySage, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: darkColors.supportingTerracotta, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: darkColors.supportingTerracotta, width: 1.5),
        ),
        hintStyle: TextStyle(
          fontFamily: AppFonts.bodyFont,
          color: darkColors.textTertiary,
          fontSize: 14,
        ),
        labelStyle: TextStyle(
          fontFamily: AppFonts.bodyFont,
          color: darkColors.textSecondary,
          fontSize: 14,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: darkColors.primarySage,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: const TextStyle(
            fontFamily: AppFonts.bodyFont,
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: darkColors.primarySageDark,
          textStyle: const TextStyle(
            fontFamily: AppFonts.bodyFont,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: darkColors.cardBackground,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
    );
  }
}
