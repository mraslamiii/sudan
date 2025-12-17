import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/dashboard_card_model.dart';

/// Resize Handle for dashboard cards
/// Provides a popup menu to change card size
/// 
/// Usage:
/// ```dart
/// ResizeHandle(
///   currentSize: card.size,
///   onResize: (newSize) => resizeCard(card.id, newSize),
/// )
/// ```
class ResizeHandle extends StatefulWidget {
  final CardSize currentSize;
  final Function(CardSize)? onResize;

  const ResizeHandle({
    super.key,
    required this.currentSize,
    this.onResize,
  });

  @override
  State<ResizeHandle> createState() => _ResizeHandleState();
}

class _ResizeHandleState extends State<ResizeHandle>
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

