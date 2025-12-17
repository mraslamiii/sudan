import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../data/models/dashboard_card_model.dart';
import '../../../data/models/masonry_layout_state.dart';
import '../../../core/utils/card_aspect_ratio_helper.dart';
import 'dashboard_card_factory.dart';
import '../shared/animated_card_wrapper.dart';
import '../../../presentation/viewmodels/dashboard_viewmodel.dart';

typedef DeviceCardBuilder = Widget Function(
  BuildContext context,
  int index,
  DashboardCardModel card,
);

/// Dynamic masonry grid that adapts to available width and number of devices
/// Similar to Instagram explore feed - cards are arranged in columns with varying heights
/// Preserves layout state when entering edit mode
class DynamicMasonryGrid extends StatefulWidget {
  final List<DashboardCardModel> cards;
  final double spacing;
  final double itemBaseWidth;
  final int minColumns;
  final int maxColumns;
  final DeviceCardBuilder? itemBuilder;
  final bool isEditMode;
  final Function(DashboardCardModel)? onCardTap;
  final Function()? onCardLongPress;
  final Function(String)? onCardDelete;
  final Function(String, CardSize)? onCardResize;
  final Function(String, Map<String, dynamic>)? onCardDataUpdate;
  final Animation<double>? animation;
  final DashboardViewModel? viewModel; // Optional viewModel for layout state preservation

  const DynamicMasonryGrid({
    super.key,
    required this.cards,
    this.spacing = 12.0,
    this.itemBaseWidth = 200.0,
    this.minColumns = 2,
    this.maxColumns = 4,
    this.itemBuilder,
    this.isEditMode = false,
    this.onCardTap,
    this.onCardLongPress,
    this.onCardDelete,
    this.onCardResize,
    this.onCardDataUpdate,
    this.animation,
    this.viewModel,
  });

  @override
  State<DynamicMasonryGrid> createState() => _DynamicMasonryGridState();
}

class _DynamicMasonryGridState extends State<DynamicMasonryGrid> {
  String? _draggingCardId;
  int? _hoveredColumnIndex;

  @override
  void didUpdateWidget(DynamicMasonryGrid oldWidget) {
    super.didUpdateWidget(oldWidget);
    // When entering edit mode, preserve layout state
    if (widget.isEditMode && !oldWidget.isEditMode && widget.viewModel != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _preserveCurrentLayout();
      });
    }
    // When exiting edit mode, clear drag state
    if (!widget.isEditMode && oldWidget.isEditMode) {
      setState(() {
        _draggingCardId = null;
        _hoveredColumnIndex = null;
      });
    }
  }

  /// Preserve the current layout state when entering edit mode
  void _preserveCurrentLayout() {
    if (widget.viewModel == null) return;
    
    // This will be called after the layout is built
    // We'll capture the layout state in the build method instead
  }

  /// Calculate optimal number of columns based on available width
  int _calculateColumns(double availableWidth) {
    if (availableWidth <= 0) return widget.minColumns;
    
    // Calculate how many columns can fit with spacing
    // Account for spacing between columns: (n-1) * spacing
    // availableWidth = n * columnWidth + (n-1) * spacing
    // Solving for n: n = (availableWidth + spacing) / (itemBaseWidth + spacing)
    final columns = ((availableWidth + widget.spacing) / (widget.itemBaseWidth + widget.spacing)).floor();
    
    // Clamp to min/max range
    return columns.clamp(widget.minColumns, widget.maxColumns);
  }

  /// Calculate card dimensions based on aspect ratio
  Size _calculateCardSize(
    DashboardCardModel card,
    double columnWidth,
  ) {
    final idealAspectRatio = CardAspectRatioHelper.getFinalAspectRatio(
      card.type,
      card.size,
    );

    // Get grid span for the card
    final (widthSpan, heightSpan) = CardAspectRatioHelper.getGridSpan(card.size);

    // Calculate base dimensions
    // Width: spans multiple columns with spacing between
    final baseWidth = columnWidth * widthSpan + widget.spacing * (widthSpan - 1);
    
    // Height: based on aspect ratio, then multiplied by height span
    final baseHeight = baseWidth / idealAspectRatio;
    
    // For cards that span multiple rows, multiply height
    // Note: In masonry layout, we don't actually span rows, but we can make cards taller
    final finalHeight = baseHeight * heightSpan;

    return Size(baseWidth, finalHeight);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.cards.isEmpty) {
      return const SizedBox.shrink();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        
        // Check if we have a preserved layout state
        final preservedState = widget.viewModel?.preservedLayoutState;
        final usePreservedState = widget.isEditMode && 
                                  preservedState != null && 
                                  preservedState.isValidFor(widget.cards) &&
                                  (preservedState.availableWidth - availableWidth).abs() < 50; // Allow small width differences
        
        int columns;
        double columnWidth;
        MasonryLayoutState? layoutStateToPreserve;
        
        if (usePreservedState) {
          // Use preserved layout state
          columns = preservedState.columnCount;
          columnWidth = preservedState.columnWidth;
        } else {
          // Calculate new layout
          columns = _calculateColumns(availableWidth);
          final totalSpacing = widget.spacing * (columns - 1);
          columnWidth = (availableWidth - totalSpacing) / columns;
          
          // If entering edit mode, we'll preserve this layout
          if (widget.isEditMode && widget.viewModel != null) {
            layoutStateToPreserve = _buildLayoutState(
              columns: columns,
              columnWidth: columnWidth,
              availableWidth: availableWidth,
            );
          }
        }

        // Build masonry layout
        final layout = _buildMasonryLayout(
          context: context,
          columns: columns,
          columnWidth: columnWidth,
          availableWidth: availableWidth,
          preservedState: usePreservedState ? preservedState : null,
        );
        
        // Preserve layout state if we just calculated it
        if (layoutStateToPreserve != null && widget.viewModel != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            widget.viewModel!.preserveLayoutState(layoutStateToPreserve!);
          });
        }
        
        return layout;
      },
    );
  }
  
  /// Build layout state from current layout
  MasonryLayoutState _buildLayoutState({
    required int columns,
    required double columnWidth,
    required double availableWidth,
  }) {
    final cardPositions = <String, CardPosition>{};
    final columnHeights = <int, double>{};
    final columnWidgetCounts = List<int>.filled(columns, 0);
    
    // Track height of each column
    final tempColumnHeights = List<double>.filled(columns, 0.0);
    
    // Distribute cards across columns using masonry algorithm
    for (var i = 0; i < widget.cards.length; i++) {
      final card = widget.cards[i];
      
      // Find the shortest column
      final shortestColumnIndex = tempColumnHeights.indexOf(
        tempColumnHeights.reduce(math.min),
      );
      
      // Calculate card size
      final cardSize = _calculateCardSize(card, columnWidth);
      final finalWidth = math.min(cardSize.width, columnWidth);
      final idealAspectRatio = CardAspectRatioHelper.getFinalAspectRatio(
        card.type,
        card.size,
      );
      final finalHeight = finalWidth / idealAspectRatio;
      
      // Store position
      cardPositions[card.id] = CardPosition(
        columnIndex: shortestColumnIndex,
        positionInColumn: columnWidgetCounts[shortestColumnIndex],
        width: finalWidth,
        height: finalHeight,
        yOffset: tempColumnHeights[shortestColumnIndex],
      );
      
      // Update column height
      if (columnWidgetCounts[shortestColumnIndex] > 0) {
        tempColumnHeights[shortestColumnIndex] += widget.spacing;
      }
      tempColumnHeights[shortestColumnIndex] += finalHeight;
      columnWidgetCounts[shortestColumnIndex]++;
    }
    
    // Store final column heights
    for (var i = 0; i < columns; i++) {
      columnHeights[i] = tempColumnHeights[i];
    }
    
    return MasonryLayoutState(
      cardPositions: cardPositions,
      columnCount: columns,
      columnWidth: columnWidth,
      columnHeights: columnHeights,
      spacing: widget.spacing,
      availableWidth: availableWidth,
    );
  }

  Widget _buildMasonryLayout({
    required BuildContext context,
    required int columns,
    required double columnWidth,
    required double availableWidth,
    MasonryLayoutState? preservedState,
  }) {
    // Track height of each column for masonry layout
    final columnHeights = List<double>.filled(columns, 0.0);
    final columnWidgets = List<List<Widget>>.generate(
      columns,
      (_) => <Widget>[],
    );
    
    // Use preserved positions if available
    final usePreservedPositions = preservedState != null && widget.isEditMode;

    // Distribute cards across columns
    if (usePreservedPositions) {
      // Use preserved positions
      final cardsByColumn = <int, List<DashboardCardModel>>{};
      for (var i = 0; i < columns; i++) {
        cardsByColumn[i] = [];
      }
      
      // Group cards by their preserved column
      for (var card in widget.cards) {
        final position = preservedState.getPosition(card.id);
        if (position != null) {
          cardsByColumn[position.columnIndex]!.add(card);
        }
      }
      
      // Sort cards within each column by position
      for (var columnIndex = 0; columnIndex < columns; columnIndex++) {
        final columnCards = cardsByColumn[columnIndex]!;
        columnCards.sort((a, b) {
          final posA = preservedState.getPosition(a.id);
          final posB = preservedState.getPosition(b.id);
          return (posA?.positionInColumn ?? 0).compareTo(posB?.positionInColumn ?? 0);
        });
        
        // Build widgets for this column
        for (var card in columnCards) {
          final cardPosition = preservedState.getPosition(card.id);
          if (cardPosition == null) continue;
          final cardSize = Size(cardPosition.width, cardPosition.height);
          
          // Build card widget
          final cardWidget = _buildCard(
            context: context,
            card: card,
            index: widget.cards.indexOf(card),
            width: cardSize.width,
            height: cardSize.height,
            isDragging: _draggingCardId == card.id,
          );

          // Add spacing before card (except first card in column)
          if (columnWidgets[columnIndex].isNotEmpty) {
            columnWidgets[columnIndex].add(SizedBox(height: widget.spacing));
          }

          // Add card to column
          columnWidgets[columnIndex].add(cardWidget);
          
          // Update column height
          columnHeights[columnIndex] += cardSize.height;
          if (columnWidgets[columnIndex].length > 1) {
            columnHeights[columnIndex] += widget.spacing;
          }
        }
      }
    } else {
      // Use masonry algorithm to distribute cards
      for (var i = 0; i < widget.cards.length; i++) {
        final card = widget.cards[i];
        
        // Find the shortest column
        final shortestColumnIndex = columnHeights.indexOf(
          columnHeights.reduce(math.min),
        );

        // Calculate card size - always constrain to column width for masonry layout
        // Cards that span multiple columns will be scaled down to fit
        final cardSize = _calculateCardSize(card, columnWidth);
        
        // Ensure card fits within column width (masonry layout constraint)
        final finalWidth = math.min(cardSize.width, columnWidth);
        // Adjust height to maintain aspect ratio
        final idealAspectRatio = CardAspectRatioHelper.getFinalAspectRatio(
          card.type,
          card.size,
        );
        final finalHeight = finalWidth / idealAspectRatio;
        
        // Build card widget
        final cardWidget = _buildCard(
          context: context,
          card: card,
          index: i,
          width: finalWidth,
          height: finalHeight,
          isDragging: _draggingCardId == card.id,
        );

        // Add spacing before card (except first card in column)
        if (columnWidgets[shortestColumnIndex].isNotEmpty) {
          columnWidgets[shortestColumnIndex].add(SizedBox(height: widget.spacing));
        }

        // Add card to shortest column
        columnWidgets[shortestColumnIndex].add(cardWidget);
        
        // Update column height
        columnHeights[shortestColumnIndex] += finalHeight;
        if (columnWidgets[shortestColumnIndex].length > 1) {
          columnHeights[shortestColumnIndex] += widget.spacing;
        }
      }
    }

    // Build columns with drag targets
    final columnChildren = <Widget>[];
    for (var i = 0; i < columns; i++) {
      final columnIndex = i;
      columnChildren.add(
        Expanded(
          child: _buildColumnWithDragTarget(
            context: context,
            columnIndex: columnIndex,
            columnWidgets: columnWidgets[i],
          ),
        ),
      );

      // Add spacing between columns (except last)
      if (i < columns - 1) {
        columnChildren.add(SizedBox(width: widget.spacing));
      }
    }

    // Use SingleChildScrollView for vertical scrolling
    // The Row will expand horizontally, and scroll vertically
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: columnChildren,
      ),
    );
  }
  
  /// Build a column with drag target support
  Widget _buildColumnWithDragTarget({
    required BuildContext context,
    required int columnIndex,
    required List<Widget> columnWidgets,
  }) {
    if (!widget.isEditMode) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: columnWidgets,
      );
    }
    
    // In edit mode, wrap with drag target
    return DragTarget<String>(
      onWillAccept: (data) {
        if (data == null || data == _draggingCardId) return false;
        setState(() {
          _hoveredColumnIndex = columnIndex;
        });
        return true;
      },
      onLeave: (_) {
        setState(() {
          if (_hoveredColumnIndex == columnIndex) {
            _hoveredColumnIndex = null;
          }
        });
      },
      onAccept: (cardId) {
        if (cardId == _draggingCardId) return;
        
        // Find target position in column
        final targetPosition = _calculateDropPosition(columnIndex);
        
        // Update layout state
        if (widget.viewModel != null) {
          widget.viewModel!.reorderCardInMasonry(
            cardId,
            columnIndex,
            targetPosition,
          );
        }
        
        setState(() {
          _draggingCardId = null;
          _hoveredColumnIndex = null;
        });
      },
      builder: (context, candidateData, rejectedData) {
        final isHovered = _hoveredColumnIndex == columnIndex && candidateData.isNotEmpty;
        
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          decoration: isHovered
              ? BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.4),
                    width: 2,
                  ),
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.05),
                )
              : null,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: columnWidgets,
          ),
        );
      },
    );
  }
  
  /// Calculate drop position in a column
  int _calculateDropPosition(int columnIndex) {
    final preservedState = widget.viewModel?.preservedLayoutState;
    if (preservedState == null) return 0;
    
    // Count cards in this column
    int count = 0;
    for (var card in widget.cards) {
      final position = preservedState.getPosition(card.id);
      if (position != null && position.columnIndex == columnIndex && card.id != _draggingCardId) {
        count++;
      }
    }
    
    return count;
  }

  Widget _buildCard({
    required BuildContext context,
    required DashboardCardModel card,
    required int index,
    required double width,
    required double height,
    bool isDragging = false,
  }) {
    Widget cardContent;
    
    if (widget.itemBuilder != null) {
      cardContent = widget.itemBuilder!(context, index, card);
    } else {
      cardContent = DashboardCardFactory.createCard(
        card: card,
        isEditMode: widget.isEditMode,
        onTap: widget.onCardTap != null ? () => widget.onCardTap!(card) : null,
        onLongPress: widget.onCardLongPress,
        onDelete: widget.onCardDelete != null ? () => widget.onCardDelete!(card.id) : null,
        onResize: widget.onCardResize != null
            ? (newSize) => widget.onCardResize!(card.id, newSize)
            : null,
        onDataUpdate: widget.onCardDataUpdate != null
            ? (newData) => widget.onCardDataUpdate!(card.id, newData)
            : null,
      );
    }

    // Wrap with animation if provided
    if (widget.animation != null) {
      cardContent = AnimatedCardWrapper(
        key: ValueKey(card.id),
        index: index,
        animation: widget.animation!,
        child: cardContent,
      );
    }

    // In edit mode, make cards draggable
    if (widget.isEditMode) {
      return _buildDraggableCard(
        context: context,
        card: card,
        width: width,
        height: height,
        child: cardContent,
        isDragging: isDragging,
      );
    }

    return SizedBox(
      width: width,
      height: height,
      child: cardContent,
    );
  }
  
  /// Build a draggable card widget
  Widget _buildDraggableCard({
    required BuildContext context,
    required DashboardCardModel card,
    required double width,
    required double height,
    required Widget child,
    required bool isDragging,
  }) {
    return LongPressDraggable<String>(
      data: card.id,
      dragAnchorStrategy: pointerDragAnchorStrategy,
      onDragStarted: () {
        setState(() {
          _draggingCardId = card.id;
        });
      },
      onDragEnd: (_) {
        setState(() {
          _draggingCardId = null;
          _hoveredColumnIndex = null;
        });
      },
      onDraggableCanceled: (_, __) {
        setState(() {
          _draggingCardId = null;
          _hoveredColumnIndex = null;
        });
      },
      feedback: Material(
        color: Colors.transparent,
        child: Opacity(
          opacity: 0.8,
          child: Transform.scale(
            scale: 1.05,
            child: SizedBox(
              width: width,
              height: height,
              child: child,
            ),
          ),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.3,
        child: SizedBox(
          width: width,
          height: height,
          child: child,
        ),
      ),
      child: AnimatedScale(
        scale: isDragging ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        child: SizedBox(
          width: width,
          height: height,
          child: child,
        ),
      ),
    );
  }
}

