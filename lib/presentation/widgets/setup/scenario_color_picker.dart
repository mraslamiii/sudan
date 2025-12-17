import 'package:flutter/material.dart';

/// Scenario Color Picker Widget
/// Displays a grid of colors for scenario selection
/// 
/// Usage:
/// ```dart
/// ScenarioColorPicker(
///   selectedColor: Colors.blue,
///   onColorSelected: (color) => viewModel.setSelectedColor(color),
/// )
/// ```
class ScenarioColorPicker extends StatelessWidget {
  final Color? selectedColor;
  final ValueChanged<Color> onColorSelected;

  const ScenarioColorPicker({
    super.key,
    this.selectedColor,
    required this.onColorSelected,
  });

  static const List<Color> availableColors = [
    Color(0xFFFFB84D), // Amber
    Color(0xFF5B8DEF), // Blue
    Color(0xFF7B68EE), // Purple
    Color(0xFF68F0C4), // Teal
    Color(0xFFFF6B9D), // Pink
    Color(0xFF4CAF50), // Green
    Color(0xFFFF9800), // Orange
    Color(0xFF9C27B0), // Deep Purple
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: availableColors.map((color) {
        final isSelected = color == selectedColor;
        return GestureDetector(
          onTap: () => onColorSelected(color),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? Colors.white : Colors.transparent,
                width: isSelected ? 3 : 0,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: color.withOpacity(0.5),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ]
                  : null,
            ),
            child: isSelected
                ? const Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 24,
                  )
                : null,
          ),
        );
      }).toList(),
    );
  }
}

