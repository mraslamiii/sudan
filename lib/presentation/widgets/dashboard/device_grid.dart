import 'package:flutter/material.dart';

import '../../../data/models/dashboard_card_model.dart';

typedef DeviceCardBuilder =
    Widget Function(BuildContext context, int index, DashboardCardModel card);

/// Custom device grid with drag & drop support and variable tile sizing.
class EditableDeviceGrid extends StatefulWidget {
  final List<DashboardCardModel> cards;
  final bool isEditMode;
  final DeviceCardBuilder itemBuilder;
  final void Function(int oldIndex, int newIndex) onReorder;
  final double spacing;
  final int maxColumns;

  const EditableDeviceGrid({
    super.key,
    required this.cards,
    required this.isEditMode,
    required this.itemBuilder,
    required this.onReorder,
    this.spacing = 12,
    this.maxColumns = 3,
  });

  @override
  State<EditableDeviceGrid> createState() => _EditableDeviceGridState();
}

class _EditableDeviceGridState extends State<EditableDeviceGrid> {
  int? _hoverIndex;
  int? _draggingIndex;
  static const int _trailingDropZoneIndex = -1;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final spacing = widget.spacing;
        final columns = widget.maxColumns.clamp(1, 6);
        final totalSpacing = spacing * (columns - 1);
        final baseWidth = (constraints.maxWidth - totalSpacing) / columns;
        final baseHeight = baseWidth * 1.2;

        final children = <Widget>[];

        for (var index = 0; index < widget.cards.length; index++) {
          final card = widget.cards[index];
          final metrics = _DeviceTileMetrics.forSize(
            card.size,
            baseWidth: baseWidth,
            baseHeight: baseHeight,
            spacing: spacing,
            maxWidth: constraints.maxWidth,
          );

          children.add(
            _buildTile(context, index: index, metrics: metrics, card: card),
          );
        }

        if (widget.isEditMode) {
          children.add(
            _buildTrailingDropZone(width: baseWidth, height: baseHeight),
          );
        }

        return Align(
          alignment: Alignment.topLeft,
          child: Wrap(
            spacing: spacing,
            runSpacing: spacing,
            children: children,
          ),
        );
      },
    );
  }

  Widget _buildTile(
    BuildContext context, {
    required int index,
    required _DeviceTileMetrics metrics,
    required DashboardCardModel card,
  }) {
    final isEditMode = widget.isEditMode;

    Widget buildCard() {
      return SizedBox(
        width: metrics.width,
        height: metrics.height,
        child: widget.itemBuilder(context, index, card),
      );
    }

    if (!isEditMode) {
      return buildCard();
    }

    final highlight = _hoverIndex == index;

    return SizedBox(
      width: metrics.width,
      height: metrics.height,
      child: LongPressDraggable<int>(
        data: index,
        dragAnchorStrategy: pointerDragAnchorStrategy,
        onDragStarted: () {
          if (!mounted) return;
          setState(() {
            _draggingIndex = index;
          });
        },
        onDraggableCanceled: (_, __) {
          if (!mounted) return;
          setState(() {
            _draggingIndex = null;
            _hoverIndex = null;
          });
        },
        onDragEnd: (_) {
          if (!mounted) return;
          setState(() {
            _draggingIndex = null;
            _hoverIndex = null;
          });
        },
        feedback: Opacity(
          opacity: 0.78,
          child: Material(
            color: Colors.transparent,
            child: SizedBox(
              width: metrics.width,
              height: metrics.height,
              child: widget.itemBuilder(context, index, card),
            ),
          ),
        ),
        childWhenDragging: Opacity(opacity: 0.18, child: buildCard()),
        child: DragTarget<int>(
          onWillAccept: (candidate) {
            if (candidate == null || candidate == index) {
              return false;
            }
            if (!mounted) return true;
            setState(() {
              _hoverIndex = index;
            });
            return true;
          },
          onLeave: (_) {
            if (!mounted) return;
            if (_hoverIndex == index) {
              setState(() => _hoverIndex = null);
            }
          },
          onAccept: (oldIndex) {
            if (!mounted) return;
            setState(() {
              _hoverIndex = null;
              _draggingIndex = null;
            });
            widget.onReorder(oldIndex, index);
          },
          builder: (context, candidateData, rejectedData) {
            final showHighlight =
                highlight ||
                candidateData.isNotEmpty ||
                _draggingIndex == index;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeOutCubic,
              decoration: showHighlight
                  ? BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withOpacity(0.55),
                        width: 2,
                      ),
                    )
                  : null,
              child: buildCard(),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTrailingDropZone({
    required double width,
    required double height,
  }) {
    final theme = Theme.of(context);
    return DragTarget<int>(
      onWillAccept: (_) {
        if (!mounted) return true;
        setState(() {
          _hoverIndex = _trailingDropZoneIndex;
        });
        return true;
      },
      onLeave: (_) {
        if (!mounted) return;
        if (_hoverIndex == _trailingDropZoneIndex) {
          setState(() {
            _hoverIndex = null;
          });
        }
      },
      onAccept: (oldIndex) {
        if (!mounted) return;
        setState(() {
          _hoverIndex = null;
          _draggingIndex = null;
        });
        widget.onReorder(oldIndex, widget.cards.length);
      },
      builder: (context, candidateData, rejectedData) {
        final isActive =
            candidateData.isNotEmpty || _hoverIndex == _trailingDropZoneIndex;
        return SizedBox(
          width: width,
          height: height,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeOutCubic,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isActive
                    ? theme.colorScheme.primary.withOpacity(0.55)
                    : theme.colorScheme.primary.withOpacity(0.18),
                width: isActive ? 2 : 1.2,
              ),
              color: isActive
                  ? theme.colorScheme.primary.withOpacity(0.08)
                  : theme.colorScheme.primary.withOpacity(0.04),
            ),
            child: Center(
              child: Icon(
                Icons.add_rounded,
                color: theme.colorScheme.primary.withOpacity(
                  isActive ? 0.9 : 0.5,
                ),
                size: 20,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _DeviceTileMetrics {
  final double width;
  final double height;

  const _DeviceTileMetrics({required this.width, required this.height});

  factory _DeviceTileMetrics.forSize(
    CardSize size, {
    required double baseWidth,
    required double baseHeight,
    required double spacing,
    required double maxWidth,
  }) {
    double widthFactor;
    double heightFactor;

    switch (size) {
      case CardSize.small:
        widthFactor = 1;
        heightFactor = 1.0;
        break;
      case CardSize.medium:
        widthFactor = 1;
        heightFactor = 1.2;
        break;
      case CardSize.large:
        widthFactor = 1;
        heightFactor = 1.6;
        break;
      case CardSize.wide:
        widthFactor = 2;
        heightFactor = 1.2;
        break;
    }

    final spacingAddition =
        spacing * ((widthFactor - 1).clamp(0, 2)).toDouble();
    var computedWidth = (baseWidth * widthFactor) + spacingAddition;
    computedWidth = computedWidth.clamp(baseWidth, maxWidth);

    final computedHeight = (baseHeight * heightFactor).clamp(
      baseHeight * 0.75,
      baseHeight * 1.8,
    );

    return _DeviceTileMetrics(width: computedWidth, height: computedHeight);
  }
}
