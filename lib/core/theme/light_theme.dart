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
      fontFamily: 'IRANYekan',
      textTheme: const TextTheme(
        displayLarge: TextStyle(color: ThemeColors.textColor1Light, fontFamily: 'IRANYekan'),
        displayMedium: TextStyle(color: ThemeColors.textColor1Light, fontFamily: 'IRANYekan'),
        displaySmall: TextStyle(color: ThemeColors.textColor1Light, fontFamily: 'IRANYekan'),
        headlineLarge: TextStyle(color: ThemeColors.textColor1Light, fontFamily: 'IRANYekan'),
        headlineMedium: TextStyle(color: ThemeColors.textColor1Light, fontFamily: 'IRANYekan'),
        headlineSmall: TextStyle(color: ThemeColors.textColor1Light, fontFamily: 'IRANYekan'),
        titleLarge: TextStyle(color: ThemeColors.textColor1Light, fontFamily: 'IRANYekan'),
        titleMedium: TextStyle(color: ThemeColors.textColor1Light, fontFamily: 'IRANYekan'),
        titleSmall: TextStyle(color: ThemeColors.textColor1Light, fontFamily: 'IRANYekan'),
        bodyLarge: TextStyle(color: ThemeColors.textColor1Light, fontFamily: 'IRANYekan'),
        bodyMedium: TextStyle(color: ThemeColors.textColor1Light, fontFamily: 'IRANYekan'),
        bodySmall: TextStyle(color: ThemeColors.textColor2Light, fontFamily: 'IRANYekan'),
        labelLarge: TextStyle(color: ThemeColors.textColor1Light, fontFamily: 'IRANYekan'),
        labelMedium: TextStyle(color: ThemeColors.textColor2Light, fontFamily: 'IRANYekan'),
        labelSmall: TextStyle(color: ThemeColors.textColor2Light, fontFamily: 'IRANYekan'),
      ),
      iconTheme: const IconThemeData(
        color: ThemeColors.iconColorLight,
      ),
    );
  }
}

