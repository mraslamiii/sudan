import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

/// Scenario Icon Picker Widget
/// Displays a grid of scenario icons for selection
/// 
/// Usage:
/// ```dart
/// ScenarioIconPicker(
///   selectedIcon: Icons.movie_rounded,
///   onIconSelected: (icon) => viewModel.setSelectedIcon(icon),
/// )
/// ```
class ScenarioIconPicker extends StatelessWidget {
  final IconData? selectedIcon;
  final Color? selectedColor;
  final ValueChanged<IconData> onIconSelected;

  const ScenarioIconPicker({
    super.key,
    this.selectedIcon,
    this.selectedColor,
    required this.onIconSelected,
  });

  static const List<IconData> availableIcons = [
    Icons.wb_sunny_rounded,
    Icons.movie_rounded,
    Icons.bedtime_rounded,
    Icons.home_rounded,
    Icons.celebration_rounded,
    Icons.work_rounded,
    Icons.restaurant_rounded,
    Icons.menu_book_rounded,
    Icons.fitness_center_rounded,
    Icons.spa_rounded,
    Icons.auto_awesome_rounded,
    Icons.star_rounded,
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = selectedColor ?? AppTheme.getPrimaryBlue(isDark);

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: availableIcons.map((icon) {
        final isSelected = icon == selectedIcon;
        return GestureDetector(
          onTap: () => onIconSelected(icon),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: isSelected
                  ? LinearGradient(
                      colors: [
                        accentColor,
                        accentColor.withOpacity(0.7),
                      ],
                    )
                  : null,
              color: isSelected
                  ? null
                  : isDark
                      ? Colors.white.withOpacity(0.06)
                      : Colors.black.withOpacity(0.04),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected
                    ? Colors.transparent
                    : AppTheme.getSectionBorderColor(isDark)
                        .withOpacity(0.3),
                width: isSelected ? 0 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: accentColor.withOpacity(0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ]
                  : null,
            ),
            child: Icon(
              icon,
              color: isSelected
                  ? Colors.white
                  : AppTheme.getTextColor1(isDark),
              size: 24,
            ),
          ),
        );
      }).toList(),
    );
  }
}

