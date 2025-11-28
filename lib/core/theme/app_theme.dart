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

  // Dashboard specific color getters
  static Color getPrimaryBlue(bool isDark) {
    return isDark ? ThemeColors.primaryBlueDark : ThemeColors.primaryBlueLight;
  }

  static Color getSecondaryGray(bool isDark) {
    return isDark ? ThemeColors.secondaryGrayDark : ThemeColors.secondaryGrayLight;
  }

  static Color getLightGray(bool isDark) {
    return isDark ? ThemeColors.lightGrayDark : ThemeColors.lightGrayLight;
  }

  static Color getBorderGray(bool isDark) {
    return isDark ? ThemeColors.borderGrayDark : ThemeColors.borderGrayLight;
  }

  static Color getSectionBackground(bool isDark) {
    return isDark ? ThemeColors.sectionBackgroundDark : ThemeColors.sectionBackgroundLight;
  }

  static Color getShadowColor(bool isDark, {bool isHovered = false}) {
    if (isDark) {
      return isHovered ? ThemeColors.shadowColorHoverDark : ThemeColors.shadowColorDark;
    } else {
      return isHovered ? ThemeColors.shadowColorHoverLight : ThemeColors.shadowColorLight;
    }
  }

  static Color getInactiveGray(bool isDark) {
    return isDark ? ThemeColors.inactiveGrayDark : ThemeColors.inactiveGrayLight;
  }

  static Color getCardBorder(bool isDark) {
    return isDark ? ThemeColors.cardBorderDark : ThemeColors.cardBorderLight;
  }

  static Color getSelectedBackground(bool isDark) {
    return isDark ? ThemeColors.selectedBackgroundDark : ThemeColors.selectedBackgroundLight;
  }

  static Color getIconBackground(bool isDark) {
    return isDark ? ThemeColors.iconBackgroundDark : ThemeColors.iconBackgroundLight;
  }

  static Color getAvatarBackground(bool isDark) {
    return isDark ? ThemeColors.avatarBackgroundDark : ThemeColors.avatarBackgroundLight;
  }
}

