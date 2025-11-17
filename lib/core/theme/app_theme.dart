import 'package:flutter/material.dart';
import 'dark_theme.dart';
import 'light_theme.dart';
import 'theme_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData getLightTheme() => LightTheme.theme;
  static ThemeData getDarkTheme() => DarkTheme.theme;

  static Color getBackgroundColor(bool isDark) {
    return isDark ? ThemeColors.backgroundDark : ThemeColors.backgroundLight;
  }

  static Color getTextColor1(bool isDark) {
    return isDark ? ThemeColors.textColor1Dark : ThemeColors.textColor1Light;
  }

  static Color getTextColor2(bool isDark) {
    return isDark ? ThemeColors.textColor2Dark : ThemeColors.textColor2Light;
  }

  static Color getCardBackground(bool isDark) {
    return isDark ? ThemeColors.cardBackgroundDark : ThemeColors.cardBackgroundLight;
  }

  static Color getDividerColor(bool isDark) {
    return isDark ? ThemeColors.dividerDark : ThemeColors.dividerLight;
  }

  static Color getIconColor(bool isDark) {
    return isDark ? ThemeColors.iconColorDark : ThemeColors.iconColorLight;
  }
}

