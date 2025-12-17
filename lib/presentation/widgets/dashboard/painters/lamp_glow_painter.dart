import 'package:flutter/material.dart';

/// Lamp Glow Painter for LED control panel
/// Renders a soft, multi-layered glow effect behind the lamp visual
/// 
/// Usage:
/// ```dart
/// CustomPaint(
///   size: const Size(320, 400),
///   painter: LampGlowPainter(lightColor, brightness, glowIntensity),
/// )
/// ```
class LampGlowPainter extends CustomPainter {
  final Color lightColor;
  final double brightness;
  final double glowIntensity;

  LampGlowPainter(this.lightColor, this.brightness, this.glowIntensity);

  @override
  void paint(Canvas canvas, Size size) {
    // Position glow to cover behind and around the lamp
    // Glow container: 320x400, starts at top: -60
    // Center should be higher to cover lamp and spread around
    // Bulb is approximately at 35% from top of glow container
    final glowCenter = Offset(size.width / 2, size.height * 0.35);
    final baseOpacity = brightness * glowIntensity;

    // Mix light color with white for more natural warm glow
    final warmWhite = Color.lerp(Colors.white, lightColor, 0.5) ?? lightColor;
    final glowColor = Color.lerp(warmWhite, lightColor, 0.5) ?? lightColor;

    // Layer 1: Extra large soft outer halo (very subtle, natural spread)
    final outerHaloPaint = Paint()
      ..color = glowColor.withOpacity(0.04 * baseOpacity)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 120);
    canvas.drawCircle(glowCenter, 130 * brightness, outerHaloPaint);

    // Layer 2: Large soft outer halo (soft spread)
    final largeHaloPaint = Paint()
      ..color = glowColor.withOpacity(0.06 * baseOpacity)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 100);
    canvas.drawCircle(glowCenter, 110 * brightness, largeHaloPaint);

    // Layer 3: Medium soft halo (gentle spread around and behind)
    final mediumHaloPaint = Paint()
      ..color = glowColor.withOpacity(0.10 * baseOpacity)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 80);
    canvas.drawCircle(glowCenter, 90 * brightness, mediumHaloPaint);

    // Layer 4: Inner soft core (around bulb area)
    final innerCorePaint = Paint()
      ..color = glowColor.withOpacity(0.15 * baseOpacity)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 60);
    canvas.drawCircle(glowCenter, 70 * brightness, innerCorePaint);

    // Layer 5: Soft center (natural light source at bulb)
    final centerCorePaint = Paint()
      ..color = glowColor.withOpacity(0.20 * baseOpacity)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 45);
    canvas.drawCircle(glowCenter, 50 * brightness, centerCorePaint);

    // Layer 6: Core light (softest point at bulb)
    final coreLightPaint = Paint()
      ..color = glowColor.withOpacity(0.25 * baseOpacity)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 30);
    canvas.drawCircle(glowCenter, 30 * brightness, coreLightPaint);
  }

  @override
  bool shouldRepaint(LampGlowPainter oldDelegate) =>
      oldDelegate.lightColor != lightColor ||
      oldDelegate.brightness != brightness ||
      oldDelegate.glowIntensity != glowIntensity;
}

