import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Thermostat Dial Painter for thermostat control panel
/// Renders a premium arc-style dial with temperature markers and active track
/// 
/// Usage:
/// ```dart
/// CustomPaint(
///   size: const Size(240, 240),
///   painter: ThermostatDialPainter(
///     startAngle: startAngle,
///     sweepAngle: sweepAngle,
///     isOn: true,
///     modeColor: Colors.blue,
///   ),
/// )
/// ```
class ThermostatDialPainter extends CustomPainter {
  final double startAngle;
  final double sweepAngle;
  final bool isOn;
  final Color modeColor;

  ThermostatDialPainter({
    required this.startAngle,
    required this.sweepAngle,
    required this.isOn,
    required this.modeColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Validate size
    if (size.width <= 0 || size.height <= 0) {
      return;
    }
    
    final center = Offset(size.width / 2, size.height / 2);
    final baseStroke = size.shortestSide * 0.06;
    final strokeWidth = baseStroke.clamp(10.0, 16.0);
    final radius = (size.shortestSide / 2) - (strokeWidth / 2) - 4;
    
    // Ensure radius is valid
    if (radius <= 0) {
      return;
    }

    // Background track
    final backgroundPaint = Paint()
      ..color = isOn
          ? const Color(0xFF2C2C2E).withOpacity(0.3)
          : const Color(0xFF2C2C2E).withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -135 * math.pi / 180,
      270 * math.pi / 180,
      false,
      backgroundPaint,
    );

    if (isOn) {
      // Validate angles
      if (startAngle.isFinite && sweepAngle.isFinite && sweepAngle > 0) {
        // Active track with gradient
        final gradientRect = Rect.fromCircle(center: center, radius: radius);
        // Ensure gradient rect is valid and has positive dimensions
        if (gradientRect.width > 0 && 
            gradientRect.height > 0 && 
            gradientRect.width.isFinite && 
            gradientRect.height.isFinite) {
          try {
            final gradient = SweepGradient(
              startAngle: startAngle,
              endAngle: startAngle + sweepAngle,
              colors: [
                modeColor,
                modeColor.withOpacity(0.7),
              ],
            );

            final shader = gradient.createShader(gradientRect);
            final activePaint = Paint()
              ..shader = shader
              ..style = PaintingStyle.stroke
              ..strokeWidth = strokeWidth
              ..strokeCap = StrokeCap.round;

            canvas.drawArc(
              gradientRect,
              startAngle,
              sweepAngle,
              false,
              activePaint,
            );
          } catch (e) {
            // Fallback: draw without gradient if shader creation fails
            final fallbackPaint = Paint()
              ..color = modeColor
              ..style = PaintingStyle.stroke
              ..strokeWidth = strokeWidth
              ..strokeCap = StrokeCap.round;
            
            canvas.drawArc(
              gradientRect,
              startAngle,
              sweepAngle,
              false,
              fallbackPaint,
            );
          }
        }
      }

      // Handle with glow
      if (startAngle.isFinite && sweepAngle.isFinite) {
        final handleAngle = startAngle + sweepAngle;
        final handleX = center.dx + radius * math.cos(handleAngle);
        final handleY = center.dy + radius * math.sin(handleAngle);
        
        // Validate handle position
        if (handleX.isFinite && handleY.isFinite) {
          final handlePos = Offset(handleX, handleY);

          // Outer glow
          final glowPaint = Paint()
            ..color = modeColor.withOpacity(0.3)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
          canvas.drawCircle(handlePos, 16, glowPaint);

          // Handle
          final handleRect = Rect.fromCircle(center: handlePos, radius: 12);
          // Ensure handle rect is valid and has positive dimensions
          if (handleRect.width > 0 && 
              handleRect.height > 0 && 
              handleRect.width.isFinite && 
              handleRect.height.isFinite) {
            try {
              final handleGradient = RadialGradient(
                colors: [
                  Colors.white,
                  modeColor,
                ],
              );
              final shader = handleGradient.createShader(handleRect);
              final handlePaint = Paint()
                ..shader = shader;
              canvas.drawCircle(handlePos, 12, handlePaint);
            } catch (e) {
              // Fallback: draw without gradient if shader creation fails
              final fallbackPaint = Paint()
                ..color = modeColor;
              canvas.drawCircle(handlePos, 12, fallbackPaint);
            }
          }

          // Handle border
          final handleBorderPaint = Paint()
            ..color = modeColor
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2;
          canvas.drawCircle(handlePos, 12, handleBorderPaint);
        }
      }
    }

    // Temperature markers
    if (isOn) {
      final markerPaint = Paint()
        ..color = Colors.white.withOpacity(0.3)
        ..style = PaintingStyle.fill;

      for (int i = 0; i <= 14; i++) {
        final angle = -135 + (i / 14) * 270;
        final angleRad = angle * math.pi / 180;

        final markerX = center.dx + radius * math.cos(angleRad);
        final markerY = center.dy + radius * math.sin(angleRad);
        final markerPos = Offset(markerX, markerY);

        // Draw marker
        if (i % 2 == 0) {
          // Major marker
          canvas.drawCircle(markerPos, 3, markerPaint);
        } else {
          // Minor marker
          canvas.drawCircle(markerPos, 1.5, markerPaint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(ThermostatDialPainter oldDelegate) =>
      oldDelegate.startAngle != startAngle ||
      oldDelegate.sweepAngle != sweepAngle ||
      oldDelegate.isOn != isOn ||
      oldDelegate.modeColor != modeColor;
}

