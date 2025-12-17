import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/dashboard_card_model.dart';

enum ResizeHandlePosition {
  topLeft,
  topRight,
  bottomLeft,
  bottomRight,
  top,
  bottom,
  left,
  right,
}

/// A resize handle that can be dragged to resize a card
class ResizeDragHandle extends StatefulWidget {
  final ResizeHandlePosition position;
  final CardSize currentSize;
  final Function(CardSize)? onResize;
  final VoidCallback? onResizeStart;
  final VoidCallback? onResizeEnd;

  const ResizeDragHandle({
    super.key,
    required this.position,
    required this.currentSize,
    this.onResize,
    this.onResizeStart,
    this.onResizeEnd,
  });

  @override
  State<ResizeDragHandle> createState() => _ResizeDragHandleState();
}

class _ResizeDragHandleState extends State<ResizeDragHandle>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isHovered = false;
  bool _isDragging = false;
  Offset? _dragStartPosition;
  CardSize? _initialSize;

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

  /// Get the cursor for this handle position
  MouseCursor _getCursor() {
    switch (widget.position) {
      case ResizeHandlePosition.topLeft:
      case ResizeHandlePosition.bottomRight:
        return SystemMouseCursors.resizeUpDown;
      case ResizeHandlePosition.topRight:
      case ResizeHandlePosition.bottomLeft:
        return SystemMouseCursors.resizeUpDown;
      case ResizeHandlePosition.top:
      case ResizeHandlePosition.bottom:
        return SystemMouseCursors.resizeUpDown;
      case ResizeHandlePosition.left:
      case ResizeHandlePosition.right:
        return SystemMouseCursors.resizeLeftRight;
    }
  }

  /// Calculate new size based on drag delta
  CardSize? _calculateNewSize(Offset delta) {
    if (_initialSize == null) return null;

    // Determine resize direction based on handle position
    final isHorizontal = widget.position == ResizeHandlePosition.left ||
        widget.position == ResizeHandlePosition.right;
    final isVertical = widget.position == ResizeHandlePosition.top ||
        widget.position == ResizeHandlePosition.bottom;
    final isCorner = !isHorizontal && !isVertical;

    // Calculate size change based on drag distance
    // For simplicity, we'll cycle through sizes based on drag distance
    final dragDistance = isHorizontal
        ? delta.dx.abs()
        : isVertical
            ? delta.dy.abs()
            : (delta.dx.abs() + delta.dy.abs()) / 2;

    // Threshold for size change (50 pixels)
    const threshold = 50.0;
    if (dragDistance < threshold) return null;

    // Cycle through sizes
    final sizeOrder = [
      CardSize.small,
      CardSize.medium,
      CardSize.large,
      CardSize.wide,
    ];
    final currentIndex = sizeOrder.indexOf(_initialSize!);
    if (currentIndex == -1) return null;

    // Determine direction based on drag
    final isIncreasing = (isHorizontal && delta.dx > 0) ||
        (isVertical && delta.dy > 0) ||
        (isCorner && (delta.dx + delta.dy) > 0);

    int newIndex;
    if (isIncreasing) {
      newIndex = (currentIndex + 1) % sizeOrder.length;
    } else {
      newIndex = (currentIndex - 1 + sizeOrder.length) % sizeOrder.length;
    }

    return sizeOrder[newIndex];
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final handleSize = _isDragging ? 12.0 : 8.0;
    final handleColor = _isDragging || _isHovered
        ? AppTheme.getPrimaryBlue(isDark)
        : AppTheme.getPrimaryBlue(isDark).withOpacity(0.6);

    return MouseRegion(
      cursor: _getCursor(),
      onEnter: (_) {
        setState(() => _isHovered = true);
        _controller.forward();
      },
      onExit: (_) {
        if (!_isDragging) {
          setState(() => _isHovered = false);
          _controller.reverse();
        }
      },
      child: GestureDetector(
        onPanStart: (details) {
          setState(() {
            _isDragging = true;
            _dragStartPosition = details.localPosition;
            _initialSize = widget.currentSize;
          });
          _controller.forward();
          widget.onResizeStart?.call();
        },
        onPanUpdate: (details) {
          if (_dragStartPosition == null || _initialSize == null) return;

          final delta = details.localPosition - _dragStartPosition!;
          final newSize = _calculateNewSize(delta);

          if (newSize != null && newSize != widget.currentSize) {
            widget.onResize?.call(newSize);
            setState(() {
              _initialSize = newSize;
              _dragStartPosition = details.localPosition;
            });
          }
        },
        onPanEnd: (_) {
          setState(() {
            _isDragging = false;
            _dragStartPosition = null;
            _initialSize = null;
            if (!_isHovered) {
              _controller.reverse();
            }
          });
          widget.onResizeEnd?.call();
        },
        onPanCancel: () {
          setState(() {
            _isDragging = false;
            _dragStartPosition = null;
            _initialSize = null;
            if (!_isHovered) {
              _controller.reverse();
            }
          });
          widget.onResizeEnd?.call();
        },
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.scale(
              scale: 1.0 + (_controller.value * 0.2),
              child: Container(
                width: handleSize,
                height: handleSize,
                decoration: BoxDecoration(
                  color: handleColor,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isDark ? Colors.white : Colors.white,
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2 * _controller.value),
                      blurRadius: 4 * _controller.value,
                      offset: Offset(0, 2 * _controller.value),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

