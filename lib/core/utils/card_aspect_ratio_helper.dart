import '../../data/models/dashboard_card_model.dart';

/// Helper class to manage aspect ratios and default sizes for different card types
/// This ensures each card type maintains its design proportions
class CardAspectRatioHelper {
  /// Get the ideal aspect ratio for a card type
  /// Returns width/height ratio
  static double getAspectRatioForType(CardType type) {
    switch (type) {
      case CardType.light:
        // LED control panel works best with a wider aspect ratio
        // Color wheel + lamp visual need horizontal space
        return 1.15; // Slightly wider than square
      
      case CardType.thermostat:
        // Thermostat dial needs more vertical space
        return 0.95; // Slightly taller than square
      
      case CardType.camera:
        // Camera feed is typically 16:9 or 4:3
        return 1.33; // 4:3 ratio
      
      case CardType.elevator:
        // Elevator panel needs space for floor grid
        return 1.0; // Square
      
      case CardType.doorLock:
        // Door lock is compact
        return 1.0; // Square
      
      case CardType.music:
        // Music player benefits from wider layout
        return 1.2; // Wider
      
      case CardType.tv:
        // TV control is compact
        return 1.0; // Square
      
      case CardType.curtain:
        // Curtain control is compact
        return 1.0; // Square
      
      case CardType.fan:
        // Fan control is compact
        return 1.0; // Square
      
      case CardType.security:
        // Security panel is compact
        return 1.0; // Square
      
      default:
        return 1.0; // Default square
    }
  }

  /// Get the default size for a card type based on its design requirements
  static CardSize getDefaultSizeForType(CardType type) {
    switch (type) {
      case CardType.light:
        // LED control panel needs medium size to show color wheel properly
        return CardSize.medium;
      
      case CardType.thermostat:
        // Thermostat needs medium size for dial
        return CardSize.medium;
      
      case CardType.camera:
        // Camera needs large size for video feed
        return CardSize.large;
      
      case CardType.elevator:
        // Elevator needs medium size for floor grid
        return CardSize.medium;
      
      case CardType.doorLock:
        // Door lock needs medium size for better UI
        return CardSize.medium;
      
      case CardType.music:
        // Music player benefits from wider layout
        return CardSize.wide;
      
      case CardType.tv:
        // TV control is compact
        return CardSize.small;
      
      case CardType.curtain:
        // Curtain control is compact
        return CardSize.small;
      
      case CardType.fan:
        // Fan control is compact
        return CardSize.small;
      
      case CardType.security:
        // Security panel is compact
        return CardSize.small;
      
      default:
        return CardSize.medium;
    }
  }

  /// Calculate the aspect ratio multiplier for a card size
  /// This helps adjust the base aspect ratio based on size
  static double getSizeMultiplier(CardSize size) {
    switch (size) {
      case CardSize.small:
        return 1.0; // No change
      case CardSize.medium:
        return 1.0; // No change
      case CardSize.large:
        return 1.1; // Slightly wider for large cards
      case CardSize.wide:
        return 1.8; // Much wider for wide cards
    }
  }

  /// Get the final aspect ratio for a card (type + size)
  static double getFinalAspectRatio(CardType type, CardSize size) {
    final baseRatio = getAspectRatioForType(type);
    final sizeMultiplier = getSizeMultiplier(size);
    return baseRatio * sizeMultiplier;
  }

  /// Get the grid cell span for a card size
  /// Returns (widthSpan, heightSpan) in grid cells
  static (int, int) getGridSpan(CardSize size) {
    switch (size) {
      case CardSize.small:
        return (1, 1); // 1x1
      case CardSize.medium:
        return (1, 1); // 1x1 (but with different aspect ratio)
      case CardSize.large:
        return (2, 2); // 2x2
      case CardSize.wide:
        return (2, 1); // 2x1
    }
  }
}

