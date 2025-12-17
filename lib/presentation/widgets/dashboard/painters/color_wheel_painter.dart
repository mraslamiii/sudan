import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Minimal Color Wheel Painter for LED control panel
/// Renders a circular color wheel with smooth gradient and selected color indicator
/// 
/// Usage:
/// ```dart
/// CustomPaint(
///   size: const Size(240, 240),
///   painter: ColorWheelPainter(selectedColor, isOn),
/// )
/// ```
class ColorWheelPainter extends CustomPainter {
  final Color selectedColor;
  final bool isOn;

  ColorWheelPainter(this.selectedColor, this.isOn);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final outerRadius = size.width / 2 - 5;
    final innerRadius = outerRadius - 18; // Less ring width = thinner ring, bigger inner circle
    final ringWidth = outerRadius - innerRadius;
    final ringCenterRadius = (outerRadius + innerRadius) / 2;

    if (!isOn) {
      // Draw grayed out wheel when off
      final grayPaint = Paint()
        ..color = Colors.grey.withOpacity(0.2)
        ..style = PaintingStyle.stroke
        ..strokeWidth = ringWidth
        ..strokeCap = StrokeCap.round;
      canvas.drawCircle(center, ringCenterRadius, grayPaint);
      return;
    }

    // Create color wheel using SweepGradient for smooth transitions
    // Start from top (12 o'clock) going clockwise
    final rect = Rect.fromCircle(center: center, radius: ringCenterRadius);
    final gradient = SweepGradient(
      startAngle: -math.pi / 2, // Start from top (12 o'clock)
      endAngle: 3 * math.pi / 2, // End at top after full rotation
      colors: const [
        Color(0xFFFF0000), // Red (top)
        Color(0xFFFF7F00), // Orange
        Color(0xFFFFFF00), // Yellow
        Color(0xFF00FF00), // Green
        Color(0xFF0000FF), // Blue
        Color(0xFF4B0082), // Indigo
        Color(0xFF9400D3), // Violet
        Color(0xFFFF0000), // Back to Red
      ],
      stops: const [0.0, 0.14, 0.28, 0.42, 0.57, 0.71, 0.85, 1.0],
    );

    // Draw the color wheel ring
    final wheelPaint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = ringWidth
      ..strokeCap = StrokeCap.round;
    
    canvas.drawCircle(center, ringCenterRadius, wheelPaint);

    // Draw subtle inner border
    final innerBorderPaint = Paint()
      ..color = Colors.black.withOpacity(0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawCircle(center, innerRadius, innerBorderPaint);

    // Draw subtle outer border
    final outerBorderPaint = Paint()
      ..color = Colors.black.withOpacity(0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawCircle(center, outerRadius, outerBorderPaint);

    // Draw selected color indicator
    final hsv = HSVColor.fromColor(selectedColor);
    // Convert hue (0-360 degrees) to radians
    // Hue 0° = Red = top position, so we start from -90° (top)
    final hueRadians = (hsv.hue * math.pi / 180) - (math.pi / 2);
    final indicatorPos = Offset(
      center.dx + ringCenterRadius * math.cos(hueRadians),
      center.dy + ringCenterRadius * math.sin(hueRadians),
    );

    // Outer glow for indicator (minimal)
    final glowPaint = Paint()
      ..color = selectedColor.withOpacity(0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawCircle(indicatorPos, 14, glowPaint);

    // White background circle for indicator
    final indicatorBgPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(indicatorPos, 11, indicatorBgPaint);

    // Selected color border (minimal, clean)
    final borderPaint = Paint()
      ..color = selectedColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawCircle(indicatorPos, 11, borderPaint);

    // Inner dot for precision
    final innerDotPaint = Paint()
      ..color = selectedColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(indicatorPos, 3, innerDotPaint);
  }

  @override
  bool shouldRepaint(ColorWheelPainter oldDelegate) =>
      oldDelegate.selectedColor != selectedColor || oldDelegate.isOn != isOn;
}

