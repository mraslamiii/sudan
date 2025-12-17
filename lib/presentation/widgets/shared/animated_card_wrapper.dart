import 'package:flutter/material.dart';

/// Animated Card Wrapper for stagger effect
/// Provides slide-up and fade-in animation for cards in a grid
/// 
/// Usage:
/// ```dart
/// AnimatedCardWrapper(
///   key: ValueKey(card.id),
///   index: index,
///   animation: fadeController,
///   child: MyCardWidget(...),
/// )
/// ```
class AnimatedCardWrapper extends StatelessWidget {
  final int index;
  final Animation<double> animation;
  final Widget child;

  const AnimatedCardWrapper({
    super.key,
    required this.index,
    required this.animation,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final delay = index * 0.05;
    final adjustedAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: animation,
        curve: Interval(
          delay.clamp(0.0, 0.8),
          (delay + 0.3).clamp(0.0, 1.0),
          curve: Curves.easeOutCubic,
        ),
      ),
    );

    return AnimatedBuilder(
      animation: adjustedAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - adjustedAnimation.value)),
          child: Opacity(
            opacity: adjustedAnimation.value,
            child: Transform.scale(
              scale: 0.9 + (0.1 * adjustedAnimation.value),
              child: child,
            ),
          ),
        );
      },
      child: child,
    );
  }
}

