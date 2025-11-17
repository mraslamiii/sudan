import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'theme_colors.dart';

class DarkTheme {
  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: ThemeColors.primaryColor,
        brightness: Brightness.dark,
        primary: ThemeColors.primaryColor,
        secondary: ThemeColors.secondaryColor,
        background: ThemeColors.backgroundDark,
        surface: ThemeColors.cardBackgroundDark,
      ),
      scaffoldBackgroundColor: ThemeColors.backgroundDark,
      cardColor: ThemeColors.cardBackgroundDark,
      dividerColor: ThemeColors.dividerDark,
      appBarTheme: const AppBarTheme(
        backgroundColor: ThemeColors.cardBackgroundDark,
        foregroundColor: ThemeColors.textColor1Dark,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
      ),
      cardTheme: CardThemeData(
        color: ThemeColors.cardBackgroundDark,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(color: ThemeColors.textColor1Dark),
        displayMedium: TextStyle(color: ThemeColors.textColor1Dark),
        displaySmall: TextStyle(color: ThemeColors.textColor1Dark),
        headlineLarge: TextStyle(color: ThemeColors.textColor1Dark),
        headlineMedium: TextStyle(color: ThemeColors.textColor1Dark),
        headlineSmall: TextStyle(color: ThemeColors.textColor1Dark),
        titleLarge: TextStyle(color: ThemeColors.textColor1Dark),
        titleMedium: TextStyle(color: ThemeColors.textColor1Dark),
        titleSmall: TextStyle(color: ThemeColors.textColor1Dark),
        bodyLarge: TextStyle(color: ThemeColors.textColor1Dark),
        bodyMedium: TextStyle(color: ThemeColors.textColor1Dark),
        bodySmall: TextStyle(color: ThemeColors.textColor2Dark),
        labelLarge: TextStyle(color: ThemeColors.textColor1Dark),
        labelMedium: TextStyle(color: ThemeColors.textColor2Dark),
        labelSmall: TextStyle(color: ThemeColors.textColor2Dark),
      ),
      iconTheme: const IconThemeData(
        color: ThemeColors.iconColorDark,
      ),
    );
  }
}

