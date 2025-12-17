import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

/// Dashboard background with subtle glows for both light and dark themes.
class DashboardBackground extends StatelessWidget {
  final bool isDark;

  const DashboardBackground({
    super.key,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final gradient = AppTheme.getDashboardBackgroundGradient(isDark);

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: gradient,
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (isDark) ...[
            _buildGlow(
              alignment: const Alignment(-1.1, -0.9),
              size: 320,
              color: Colors.white.withOpacity(0.08),
            ),
            _buildGlow(
              alignment: const Alignment(1.05, -0.6),
              size: 260,
              color: Colors.white.withOpacity(0.05),
            ),
            _buildGlow(
              alignment: const Alignment(-0.2, 1.2),
              size: 400,
              color: Colors.white.withOpacity(0.035),
            ),
          ] else ...[
            _buildGlow(
              alignment: const Alignment(-1.0, -0.9),
              size: 260,
              color: const Color(0xFFBFDBFE).withOpacity(0.35),
            ),
            _buildGlow(
              alignment: const Alignment(1.1, 1.0),
              size: 320,
              color: const Color(0xFFAAF0D1).withOpacity(0.28),
            ),
          ],
          _buildTextureOverlay(),
        ],
      ),
    );
  }

  Widget _buildGlow({
    required Alignment alignment,
    required double size,
    required Color color,
  }) {
    return Align(
      alignment: alignment,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              color,
              color.withOpacity(0),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextureOverlay() {
    return IgnorePointer(
      ignoring: true,
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: Container(
            color: (isDark ? Colors.white : Colors.black).withOpacity(isDark ? 0.015 : 0.012),
          ),
        ),
      ),
    );
  }
}

