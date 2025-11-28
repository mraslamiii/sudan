import 'package:flutter/material.dart';
import '../../../data/models/dashboard_card_model.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/theme_colors.dart';

/// Base widget for all dashboard cards
/// Provides common functionality like resize handles, drag indicators, etc.
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
  bool _isHovered = false;
  late AnimationController _scaleController;
  late AnimationController _glowController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeOut),
    );
    _glowAnimation = Tween<double>(begin: 0.3, end: 0.6).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_scaleAnimation, _glowAnimation]),
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: MouseRegion(
            onEnter: (_) {
              if (!widget.isEditMode) {
                setState(() => _isHovered = true);
              }
            },
            onExit: (_) {
              setState(() => _isHovered = false);
            },
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
                children: [
                  // Main card content with modern gradient background
                  Builder(
                    builder: (context) {
                      final isDark = Theme.of(context).brightness == Brightness.dark;
                      final gradientStart = isDark ? const Color(0xFF2A2A2E) : const Color(0xFFFFFFFF);
                      final gradientEnd = isDark ? const Color(0xFF1F1F23) : const Color(0xFFF8F8FA);
                      
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeOut,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [gradientStart, gradientEnd],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            border: widget.isEditMode
                                ? Border.all(
                                    color: AppTheme.getPrimaryBlue(isDark),
                                    width: 2,
                                  )
                                : Border.all(
                                    color: isDark 
                                        ? Colors.white.withOpacity(0.08) 
                                        : Colors.black.withOpacity(0.06),
                                    width: 1,
                                  ),
                            boxShadow: [
                              BoxShadow(
                                color: isDark 
                                    ? Colors.black.withOpacity(_isHovered ? 0.5 : 0.3)
                                    : Colors.black.withOpacity(_isHovered ? 0.12 : 0.06),
                                blurRadius: _isHovered ? 24 : 16,
                                offset: Offset(0, _isHovered ? 6 : 3),
                                spreadRadius: 0,
                              ),
                            ],
                          ),
                          child: widget.child,
                        ),
                      );
                    },
                  ),

                  // Edit mode overlay
                  if (widget.isEditMode) ...[
                    // Delete button with animation
                    Positioned(
                      top: 10,
                      right: 10,
                      child: _AnimatedDeleteButton(
                        onTap: widget.onDelete,
                      ),
                    ),

                    // Resize handles
                    Positioned(
                      bottom: 10,
                      right: 10,
                      child: _ResizeHandle(
                        currentSize: widget.card.size,
                        onResize: widget.onResize,
                      ),
                    ),

                    // Drag indicator with animation
                    Positioned(
                      top: 10,
                      left: 10,
                      child: _AnimatedDragIndicator(),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _AnimatedDeleteButton extends StatefulWidget {
  final VoidCallback? onTap;

  const _AnimatedDeleteButton({this.onTap});

  @override
  State<_AnimatedDeleteButton> createState() => _AnimatedDeleteButtonState();
}

class _AnimatedDeleteButtonState extends State<_AnimatedDeleteButton>
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
            final isDark = Theme.of(context).brightness == Brightness.dark;
            return Transform.scale(
              scale: 1.0 + (_controller.value * 0.05),
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: ThemeColors.errorRed,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1 * _controller.value),
                      blurRadius: 8 * _controller.value,
                      offset: Offset(0, 2 * _controller.value),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.close_rounded,
                  color: AppTheme.getSectionBackground(isDark),
                  size: 16,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _AnimatedDragIndicator extends StatefulWidget {
  @override
  State<_AnimatedDragIndicator> createState() => _AnimatedDragIndicatorState();
}

class _AnimatedDragIndicatorState extends State<_AnimatedDragIndicator>
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
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.getIconBackground(isDark),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.drag_handle_rounded,
                        color: AppTheme.getSecondaryGray(isDark),
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Drag',
                        style: TextStyle(
                          color: AppTheme.getSecondaryGray(isDark),
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
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

class _ResizeHandle extends StatefulWidget {
  final CardSize currentSize;
  final Function(CardSize)? onResize;

  const _ResizeHandle({
    required this.currentSize,
    this.onResize,
  });

  @override
  State<_ResizeHandle> createState() => _ResizeHandleState();
}

class _ResizeHandleState extends State<_ResizeHandle>
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
      child: PopupMenuButton<CardSize>(
        icon: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.scale(
              scale: 1.0 + (_controller.value * 0.05),
              child: Builder(
                builder: (context) {
                  final isDark = Theme.of(context).brightness == Brightness.dark;
                  return Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppTheme.getIconBackground(isDark),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05 * _controller.value),
                          blurRadius: 6 * _controller.value,
                          offset: Offset(0, 2 * _controller.value),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.open_in_full_rounded,
                      color: AppTheme.getPrimaryBlue(isDark),
                      size: 16,
                    ),
                  );
                },
              ),
            );
          },
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        color: Theme.of(context).cardColor,
        elevation: 8,
        onSelected: widget.onResize,
        itemBuilder: (context) => [
          _buildMenuItem(
            CardSize.small,
            Icons.crop_square_rounded,
            'Small (1x1)',
          ),
          _buildMenuItem(
            CardSize.medium,
            Icons.crop_landscape_rounded,
            'Medium (2x1)',
          ),
          _buildMenuItem(
            CardSize.large,
            Icons.crop_din_rounded,
            'Large (2x2)',
          ),
          _buildMenuItem(
            CardSize.wide,
            Icons.crop_16_9_rounded,
            'Wide (3x1)',
          ),
        ],
      ),
    );
  }

  PopupMenuItem<CardSize> _buildMenuItem(
    CardSize size,
    IconData icon,
    String label,
  ) {
    final isSelected = widget.currentSize == size;
    return PopupMenuItem(
      value: size,
      child: Builder(
        builder: (context) {
          final isDark = Theme.of(context).brightness == Brightness.dark;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            decoration: BoxDecoration(
              color: isSelected ? AppTheme.getSelectedBackground(isDark) : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 18,
                  color: isSelected
                      ? AppTheme.getPrimaryBlue(isDark)
                      : AppTheme.getSecondaryGray(isDark),
                ),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: TextStyle(
                    color: isSelected
                        ? AppTheme.getPrimaryBlue(isDark)
                        : AppTheme.getTextColor1(isDark),
                    fontSize: 15,
                    fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                  ),
                ),
                if (isSelected) ...[
                  const Spacer(),
                  Icon(
                    Icons.check_rounded,
                    size: 18,
                    color: AppTheme.getPrimaryBlue(isDark),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

