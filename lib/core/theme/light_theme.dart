import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'theme_colors.dart';

class LightTheme {
  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: ThemeColors.primaryColor,
        brightness: Brightness.light,
        primary: ThemeColors.primaryColor,
        secondary: ThemeColors.secondaryColor,
        background: ThemeColors.backgroundLight,
        surface: ThemeColors.cardBackgroundLight,
      ),
      scaffoldBackgroundColor: ThemeColors.backgroundLight,
      cardColor: ThemeColors.cardBackgroundLight,
      dividerColor: ThemeColors.dividerLight,
      appBarTheme: const AppBarTheme(
        backgroundColor: ThemeColors.cardBackgroundLight,
        foregroundColor: ThemeColors.textColor1Light,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),
      ),
      cardTheme: CardThemeData(
        color: ThemeColors.cardBackgroundLight,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(color: ThemeColors.textColor1Light),
        displayMedium: TextStyle(color: ThemeColors.textColor1Light),
        displaySmall: TextStyle(color: ThemeColors.textColor1Light),
        headlineLarge: TextStyle(color: ThemeColors.textColor1Light),
        headlineMedium: TextStyle(color: ThemeColors.textColor1Light),
        headlineSmall: TextStyle(color: ThemeColors.textColor1Light),
        titleLarge: TextStyle(color: ThemeColors.textColor1Light),
        titleMedium: TextStyle(color: ThemeColors.textColor1Light),
        titleSmall: TextStyle(color: ThemeColors.textColor1Light),
        bodyLarge: TextStyle(color: ThemeColors.textColor1Light),
        bodyMedium: TextStyle(color: ThemeColors.textColor1Light),
        bodySmall: TextStyle(color: ThemeColors.textColor2Light),
        labelLarge: TextStyle(color: ThemeColors.textColor1Light),
        labelMedium: TextStyle(color: ThemeColors.textColor2Light),
        labelSmall: TextStyle(color: ThemeColors.textColor2Light),
      ),
      iconTheme: const IconThemeData(
        color: ThemeColors.iconColorLight,
      ),
    );
  }
}

