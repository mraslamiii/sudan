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
      fontFamily: 'IRANYekan',
      textTheme: const TextTheme(
        displayLarge: TextStyle(color: ThemeColors.textColor1Dark, fontFamily: 'IRANYekan'),
        displayMedium: TextStyle(color: ThemeColors.textColor1Dark, fontFamily: 'IRANYekan'),
        displaySmall: TextStyle(color: ThemeColors.textColor1Dark, fontFamily: 'IRANYekan'),
        headlineLarge: TextStyle(color: ThemeColors.textColor1Dark, fontFamily: 'IRANYekan'),
        headlineMedium: TextStyle(color: ThemeColors.textColor1Dark, fontFamily: 'IRANYekan'),
        headlineSmall: TextStyle(color: ThemeColors.textColor1Dark, fontFamily: 'IRANYekan'),
        titleLarge: TextStyle(color: ThemeColors.textColor1Dark, fontFamily: 'IRANYekan'),
        titleMedium: TextStyle(color: ThemeColors.textColor1Dark, fontFamily: 'IRANYekan'),
        titleSmall: TextStyle(color: ThemeColors.textColor1Dark, fontFamily: 'IRANYekan'),
        bodyLarge: TextStyle(color: ThemeColors.textColor1Dark, fontFamily: 'IRANYekan'),
        bodyMedium: TextStyle(color: ThemeColors.textColor1Dark, fontFamily: 'IRANYekan'),
        bodySmall: TextStyle(color: ThemeColors.textColor2Dark, fontFamily: 'IRANYekan'),
        labelLarge: TextStyle(color: ThemeColors.textColor1Dark, fontFamily: 'IRANYekan'),
        labelMedium: TextStyle(color: ThemeColors.textColor2Dark, fontFamily: 'IRANYekan'),
        labelSmall: TextStyle(color: ThemeColors.textColor2Dark, fontFamily: 'IRANYekan'),
      ),
      iconTheme: const IconThemeData(
        color: ThemeColors.iconColorDark,
      ),
    );
  }
}

