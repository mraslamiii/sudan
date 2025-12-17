import 'dashboard_card_model.dart';

/// Position of a card in the masonry layout
class CardPosition {
  final int columnIndex;
  final int positionInColumn; // Position within the column (0 = first card)
  final double width;
  final double height;
  final double yOffset; // Vertical offset from top of column

  const CardPosition({
    required this.columnIndex,
    required this.positionInColumn,
    required this.width,
    required this.height,
    required this.yOffset,
  });

  CardPosition copyWith({
    int? columnIndex,
    int? positionInColumn,
    double? width,
    double? height,
    double? yOffset,
  }) {
    return CardPosition(
      columnIndex: columnIndex ?? this.columnIndex,
      positionInColumn: positionInColumn ?? this.positionInColumn,
      width: width ?? this.width,
      height: height ?? this.height,
      yOffset: yOffset ?? this.yOffset,
    );
  }
}

/// State of the masonry layout to preserve when entering edit mode
class MasonryLayoutState {
  /// Map of card ID to its position in the layout
  final Map<String, CardPosition> cardPositions;
  
  /// Number of columns in the layout
  final int columnCount;
  
  /// Width of each column
  final double columnWidth;
  
  /// Height of each column (columnIndex -> height)
  final Map<int, double> columnHeights;
  
  /// Spacing between cards
  final double spacing;
  
  /// Available width when layout was created
  final double availableWidth;

  const MasonryLayoutState({
    required this.cardPositions,
    required this.columnCount,
    required this.columnWidth,
    required this.columnHeights,
    required this.spacing,
    required this.availableWidth,
  });

  /// Create an empty layout state
  factory MasonryLayoutState.empty() {
    return const MasonryLayoutState(
      cardPositions: {},
      columnCount: 0,
      columnWidth: 0,
      columnHeights: {},
      spacing: 12.0,
      availableWidth: 0,
    );
  }

  /// Check if this layout state is valid for the given cards
  bool isValidFor(List<DashboardCardModel> cards) {
    if (cardPositions.isEmpty && cards.isEmpty) return true;
    if (cardPositions.length != cards.length) return false;
    
    final cardIds = cards.map((c) => c.id).toSet();
    final positionIds = cardPositions.keys.toSet();
    
    return cardIds.length == positionIds.length && 
           cardIds.every((id) => positionIds.contains(id));
  }

  /// Get position for a card, or null if not found
  CardPosition? getPosition(String cardId) {
    return cardPositions[cardId];
  }

  /// Create a copy with updated card position
  MasonryLayoutState copyWithCardPosition(
    String cardId,
    CardPosition position,
  ) {
    final newPositions = Map<String, CardPosition>.from(cardPositions);
    newPositions[cardId] = position;
    
    return MasonryLayoutState(
      cardPositions: newPositions,
      columnCount: columnCount,
      columnWidth: columnWidth,
      columnHeights: Map<int, double>.from(columnHeights),
      spacing: spacing,
      availableWidth: availableWidth,
    );
  }

  /// Create a copy with updated column heights
  MasonryLayoutState copyWithColumnHeights(Map<int, double> newHeights) {
    return MasonryLayoutState(
      cardPositions: cardPositions,
      columnCount: columnCount,
      columnWidth: columnWidth,
      columnHeights: newHeights,
      spacing: spacing,
      availableWidth: availableWidth,
    );
  }
}

