import 'package:flutter/material.dart';

/// Custom Squircle Clipper for iOS-style smooth corners
/// Uses superellipse approximation for smooth, continuous corner curves
/// 
/// Usage:
/// ```dart
/// ClipPath(
///   clipper: SquircleClipper(borderRadius: 36),
///   child: Container(...),
/// )
/// ```
class SquircleClipper extends CustomClipper<Path> {
  final double borderRadius;

  SquircleClipper({required this.borderRadius});

  @override
  Path getClip(Size size) {
    final path = Path();
    final radius = borderRadius;
    
    // iOS uses a superellipse formula for smooth corners
    // This is a simplified approximation
    path.moveTo(0, radius);
    
    // Top-left corner
    path.cubicTo(0, radius * 0.45, radius * 0.45, 0, radius, 0);
    
    // Top edge
    path.lineTo(size.width - radius, 0);
    
    // Top-right corner
    path.cubicTo(size.width - radius * 0.45, 0, size.width, radius * 0.45, size.width, radius);
    
    // Right edge
    path.lineTo(size.width, size.height - radius);
    
    // Bottom-right corner
    path.cubicTo(size.width, size.height - radius * 0.45, size.width - radius * 0.45, size.height, size.width - radius, size.height);
    
    // Bottom edge
    path.lineTo(radius, size.height);
    
    // Bottom-left corner
    path.cubicTo(radius * 0.45, size.height, 0, size.height - radius * 0.45, 0, size.height - radius);
    
    // Close path
    path.close();
    
    return path;
  }

  @override
  bool shouldReclip(SquircleClipper oldClipper) => oldClipper.borderRadius != borderRadius;
}

