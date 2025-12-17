import 'package:flutter/material.dart';
import '../../../data/models/dashboard_card_model.dart';
import 'animated_delete_button.dart';

/// Base widget for all dashboard cards
/// Provides common functionality like shake animation and delete button in edit mode
class BaseDashboardCard extends StatefulWidget {
  final DashboardCardModel card;
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool isEditMode;
  final VoidCallback? onDelete;
  final Function(CardSize)? onResize;

  const BaseDashboardCard({
    super.key,
    required this.card,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.isEditMode = false,
    this.onDelete,
    this.onResize,
  });

  @override
  State<BaseDashboardCard> createState() => _BaseDashboardCardState();
}

class _BaseDashboardCardState extends State<BaseDashboardCard>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _shakeController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeOut),
    );

    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _shakeAnimation = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );
  }

  @override
  void didUpdateWidget(BaseDashboardCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isEditMode && !oldWidget.isEditMode) {
      _shakeController.repeat(reverse: true);
    } else if (!widget.isEditMode && oldWidget.isEditMode) {
      _shakeController.stop();
      _shakeController.reset();
    }
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_scaleAnimation, _shakeAnimation]),
      child: null,
      builder: (context, child) {
        return Transform.translate(
          offset: widget.isEditMode ? Offset(_shakeAnimation.value, 0) : Offset.zero,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: GestureDetector(
              onTapDown: (_) {
                if (!widget.isEditMode) {
                  _scaleController.forward();
                }
              },
              onTapUp: (_) {
                _scaleController.reverse();
                if (!widget.isEditMode) {
                  widget.onTap?.call();
                }
              },
              onTapCancel: () {
                _scaleController.reverse();
              },
              onLongPress: widget.onLongPress,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Main card content - no background, just child
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: widget.child,
                  ),

                  // Edit mode overlay
                  if (widget.isEditMode)
                    Positioned(
                      top: -8,
                      left: -8,
                      child: AnimatedDeleteButton(
                        onTap: widget.onDelete,
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
