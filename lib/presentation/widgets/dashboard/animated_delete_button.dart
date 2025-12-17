import 'package:flutter/material.dart';
import '../../../core/theme/theme_colors.dart';

/// Animated Delete Button for dashboard edit mode
/// Provides hover and press animations with shadow effects
/// 
/// Usage:
/// ```dart
/// AnimatedDeleteButton(
///   onTap: () => deleteCard(cardId),
/// )
/// ```
class AnimatedDeleteButton extends StatefulWidget {
  final VoidCallback? onTap;

  const AnimatedDeleteButton({super.key, this.onTap});

  @override
  State<AnimatedDeleteButton> createState() => _AnimatedDeleteButtonState();
}

class _AnimatedDeleteButtonState extends State<AnimatedDeleteButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        _controller.forward();
      },
      onExit: (_) {
        _controller.reverse();
      },
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.scale(
              scale: 1.0 + (_controller.value * 0.05),
              child: Container(
                width: 34,
                height: 34,
                decoration: ShapeDecoration(
                  color: ThemeColors.errorRed,
                  shape: ContinuousRectangleBorder(
                    borderRadius: BorderRadius.circular(34),
                  ),
                  shadows: [
                    BoxShadow(
                      color: ThemeColors.errorRed.withOpacity(0.3 * _controller.value),
                      blurRadius: 12 * _controller.value,
                      offset: Offset(0, 3 * _controller.value),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.close_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

