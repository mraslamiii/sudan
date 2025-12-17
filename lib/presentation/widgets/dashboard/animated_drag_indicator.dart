import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

/// Animated Drag Indicator for dashboard edit mode
/// Shows a floating "Drag" label with subtle animation
/// 
/// Usage:
/// ```dart
/// AnimatedDragIndicator()
/// ```
class AnimatedDragIndicator extends StatefulWidget {
  const AnimatedDragIndicator({super.key});

  @override
  State<AnimatedDragIndicator> createState() => _AnimatedDragIndicatorState();
}

class _AnimatedDragIndicatorState extends State<AnimatedDragIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, -1 * _controller.value),
          child: Builder(
            builder: (context) {
              final isDark = Theme.of(context).brightness == Brightness.dark;
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 7,
                ),
                decoration: ShapeDecoration(
                  color: AppTheme.getIconBackground(isDark),
                  shape: ContinuousRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.drag_handle_rounded,
                      color: AppTheme.getSecondaryGray(isDark),
                      size: 15,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Drag',
                      style: TextStyle(
                        color: AppTheme.getSecondaryGray(isDark),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}

