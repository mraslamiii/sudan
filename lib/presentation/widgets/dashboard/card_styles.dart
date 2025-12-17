import 'package:flutter/material.dart';

/// Apple-inspired unified styling system for dashboard cards
/// Creates consistent, minimal, and beautiful UI across all widgets
class CardStyles {
  CardStyles._();

  // ═══════════════════════════════════════════════════════════════════════════
  // SPACING SYSTEM - 4pt grid
  // ═══════════════════════════════════════════════════════════════════════════
  static const double space2 = 2;
  static const double space4 = 4;
  static const double space6 = 6;
  static const double space8 = 8;
  static const double space12 = 12;
  static const double space16 = 16;
  static const double space20 = 20;
  static const double space24 = 24;

  // ═══════════════════════════════════════════════════════════════════════════
  // TYPOGRAPHY - SF Pro inspired
  // ═══════════════════════════════════════════════════════════════════════════
  static TextStyle cardTitle(bool isDark, {bool isCompact = false}) => TextStyle(
        fontSize: isCompact ? 15 : 17,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.4,
        color: isDark ? Colors.white : const Color(0xFF1D1D1F),
      );

  static TextStyle cardSubtitle(bool isDark, {bool isCompact = false}) => TextStyle(
        fontSize: isCompact ? 11 : 12,
        fontWeight: FontWeight.w500,
        letterSpacing: -0.1,
        color: isDark ? Colors.white.withOpacity(0.55) : const Color(0xFF86868B),
      );

  static TextStyle labelStyle(bool isDark, {bool isCompact = false}) => TextStyle(
        fontSize: isCompact ? 10 : 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.3,
        color: isDark ? Colors.white.withOpacity(0.45) : const Color(0xFF86868B),
      );

  static TextStyle valueStyle(bool isDark, Color? accentColor, {bool isCompact = false}) => TextStyle(
        fontSize: isCompact ? 13 : 14,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
        color: accentColor ?? (isDark ? Colors.white : const Color(0xFF1D1D1F)),
      );

  static TextStyle largeValueStyle(bool isDark, Color? accentColor, {bool isCompact = false}) => TextStyle(
        fontSize: isCompact ? 28 : 34,
        fontWeight: FontWeight.w300,
        letterSpacing: -1.0,
        height: 1.0,
        color: accentColor ?? (isDark ? Colors.white : const Color(0xFF1D1D1F)),
      );

  // ═══════════════════════════════════════════════════════════════════════════
  // ACCENT COLORS - Apple-style semantic colors
  // ═══════════════════════════════════════════════════════════════════════════
  static const Color accentBlue = Color(0xFF007AFF);
  static const Color accentGreen = Color(0xFF34C759);
  static const Color accentOrange = Color(0xFFFF9500);
  static const Color accentRed = Color(0xFFFF3B30);
  static const Color accentPurple = Color(0xFFAF52DE);
  static const Color accentPink = Color(0xFFFF2D55);
  static const Color accentTeal = Color(0xFF5AC8FA);
  static const Color accentIndigo = Color(0xFF5856D6);
  static const Color accentMint = Color(0xFF00C7BE);

  // Card-specific accent colors
  static const Color securityAccent = Color(0xFFFF453A);
  static const Color curtainAccent = Color(0xFF64D2FF);
  static const Color musicAccent = Color(0xFFBF5AF2);
  static const Color thermostatAccent = Color(0xFF30D158);
  static const Color elevatorAccent = Color(0xFF5E5CE6);
  static const Color doorLockAccent = Color(0xFFFFD60A);

  // ═══════════════════════════════════════════════════════════════════════════
  // SURFACE COLORS & EFFECTS
  // ═══════════════════════════════════════════════════════════════════════════
  static Color surfaceColor(bool isDark) =>
      isDark ? const Color(0xFF1C1C1E) : Colors.white;

  static Color surfaceSecondary(bool isDark) =>
      isDark ? const Color(0xFF2C2C2E) : const Color(0xFFF2F2F7);

  static Color surfaceTertiary(bool isDark) =>
      isDark ? const Color(0xFF3A3A3C) : const Color(0xFFE5E5EA);

  static Color borderColor(bool isDark) =>
      isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.04);

  static Color dividerColor(bool isDark) =>
      isDark ? Colors.white.withOpacity(0.12) : Colors.black.withOpacity(0.08);

  // ═══════════════════════════════════════════════════════════════════════════
  // CARD CONTAINER STYLES
  // ═══════════════════════════════════════════════════════════════════════════
  static BoxDecoration cardDecoration(bool isDark, {Color? accentColor, bool isActive = false}) {
    final baseColor = surfaceColor(isDark);
    
    return BoxDecoration(
      color: isActive && accentColor != null
          ? Color.lerp(baseColor, accentColor, isDark ? 0.08 : 0.05)
          : baseColor,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
        color: isActive && accentColor != null
            ? accentColor.withOpacity(isDark ? 0.25 : 0.15)
            : borderColor(isDark),
        width: 1,
      ),
      boxShadow: [
        BoxShadow(
          color: isDark
              ? Colors.black.withOpacity(0.4)
              : Colors.black.withOpacity(0.04),
          blurRadius: 20,
          offset: const Offset(0, 4),
        ),
        if (isActive && accentColor != null)
          BoxShadow(
            color: accentColor.withOpacity(isDark ? 0.15 : 0.08),
            blurRadius: 24,
            spreadRadius: -4,
            offset: const Offset(0, 8),
          ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // CONTROL BUTTON STYLES
  // ═══════════════════════════════════════════════════════════════════════════
  static BoxDecoration powerButtonDecoration(bool isDark, Color accentColor, bool isActive) {
    return BoxDecoration(
      gradient: isActive
          ? LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                accentColor,
                Color.lerp(accentColor, Colors.black, 0.15)!,
              ],
            )
          : null,
      color: isActive ? null : (isDark ? const Color(0xFF3A3A3C) : const Color(0xFFE5E5EA)),
      shape: BoxShape.circle,
      boxShadow: isActive
          ? [
              BoxShadow(
                color: accentColor.withOpacity(0.4),
                blurRadius: 12,
                spreadRadius: -2,
                offset: const Offset(0, 4),
              ),
            ]
          : null,
    );
  }

  static BoxDecoration actionButtonDecoration(
    bool isDark,
    Color accentColor, {
    bool isSelected = false,
    bool isOutlined = false,
  }) {
    if (isOutlined) {
      return BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? accentColor : dividerColor(isDark),
          width: 1.5,
        ),
      );
    }
    
    return BoxDecoration(
      color: isSelected
          ? accentColor.withOpacity(isDark ? 0.2 : 0.12)
          : (isDark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.04)),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: isSelected ? accentColor.withOpacity(0.4) : Colors.transparent,
        width: 1,
      ),
    );
  }

  static BoxDecoration pillButtonDecoration(bool isDark, Color accentColor, bool isSelected) {
    return BoxDecoration(
      color: isSelected
          ? accentColor
          : (isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.05)),
      borderRadius: BorderRadius.circular(100),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SLIDER STYLES
  // ═══════════════════════════════════════════════════════════════════════════
  static SliderThemeData sliderTheme(BuildContext context, bool isDark, Color accentColor, {bool isCompact = false}) {
    return SliderTheme.of(context).copyWith(
      activeTrackColor: accentColor,
      inactiveTrackColor: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.08),
      thumbColor: Colors.white,
      overlayColor: accentColor.withOpacity(0.15),
      thumbShape: RoundSliderThumbShape(
        enabledThumbRadius: isCompact ? 7 : 8,
        elevation: 2,
        pressedElevation: 4,
      ),
      overlayShape: RoundSliderOverlayShape(overlayRadius: isCompact ? 14 : 16),
      trackHeight: isCompact ? 4 : 5,
      trackShape: const RoundedRectSliderTrackShape(),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // ICON STYLES
  // ═══════════════════════════════════════════════════════════════════════════
  static Color iconColor(bool isDark, {bool isActive = false, Color? accentColor}) {
    if (isActive && accentColor != null) return accentColor;
    return isDark ? Colors.white.withOpacity(0.6) : const Color(0xFF8E8E93);
  }

  static BoxDecoration iconBadgeDecoration(bool isDark, Color accentColor, bool isActive) {
    return BoxDecoration(
      color: isActive
          ? accentColor.withOpacity(isDark ? 0.2 : 0.12)
          : (isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.05)),
      shape: BoxShape.circle,
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // STATUS INDICATOR STYLES
  // ═══════════════════════════════════════════════════════════════════════════
  static BoxDecoration statusPillDecoration(bool isDark, Color color) {
    return BoxDecoration(
      color: color.withOpacity(isDark ? 0.15 : 0.1),
      borderRadius: BorderRadius.circular(100),
      border: Border.all(
        color: color.withOpacity(0.3),
        width: 1,
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // ANIMATION DURATIONS
  // ═══════════════════════════════════════════════════════════════════════════
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 250);
  static const Duration slow = Duration(milliseconds: 400);
  static const Duration verySlow = Duration(milliseconds: 600);

  // ═══════════════════════════════════════════════════════════════════════════
  // HELPER WIDGETS
  // ═══════════════════════════════════════════════════════════════════════════
  
  /// Unified card header widget
  static Widget buildHeader({
    required BuildContext context,
    required String title,
    String? subtitle,
    required bool isDark,
    required bool isCompact,
    required Color accentColor,
    required bool isActive,
    VoidCallback? onPowerTap,
    bool showPowerButton = true,
    IconData? customIcon,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: cardTitle(isDark, isCompact: isCompact),
              ),
              if (subtitle != null) ...[
                SizedBox(height: isCompact ? 4 : 6),
                Text(
                  subtitle,
                  style: cardSubtitle(isDark, isCompact: isCompact).copyWith(
                    color: isActive ? accentColor : null,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (showPowerButton)
          Padding(
            padding: EdgeInsets.only(top: isCompact ? 0 : 2),
            child: GestureDetector(
              onTap: onPowerTap,
              child: AnimatedContainer(
                duration: normal,
                width: isCompact ? 32 : 36,
                height: isCompact ? 32 : 36,
                decoration: powerButtonDecoration(isDark, accentColor, isActive),
                child: Icon(
                  customIcon ?? (isActive ? Icons.power_settings_new : Icons.power_settings_new_outlined),
                  color: Colors.white,
                  size: isCompact ? 16 : 18,
                ),
              ),
            ),
          ),
      ],
    );
  }

  /// Unified action button widget
  static Widget buildActionButton({
    required BuildContext context,
    required String label,
    required IconData icon,
    required bool isDark,
    required bool isCompact,
    required Color accentColor,
    required bool isSelected,
    required VoidCallback? onTap,
    bool showLabel = true,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: normal,
        padding: EdgeInsets.symmetric(
          horizontal: isCompact ? 12 : 16,
          vertical: isCompact ? 8 : 10,
        ),
        decoration: actionButtonDecoration(isDark, accentColor, isSelected: isSelected),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? accentColor : iconColor(isDark),
              size: isCompact ? 16 : 18,
            ),
            if (showLabel) ...[
              SizedBox(width: isCompact ? 6 : 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: isCompact ? 12 : 13,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.2,
                  color: isSelected ? accentColor : (isDark ? Colors.white.withOpacity(0.7) : const Color(0xFF3C3C43)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

