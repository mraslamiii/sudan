import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

/// Room Icon Picker Widget
/// Displays a grid of room icons for selection
/// 
/// Usage:
/// ```dart
/// RoomIconPicker(
///   selectedIcon: Icons.living_rounded,
///   onIconSelected: (icon) => viewModel.setSelectedIcon(icon),
/// )
/// ```
class RoomIconPicker extends StatelessWidget {
  final IconData? selectedIcon;
  final ValueChanged<IconData> onIconSelected;

  const RoomIconPicker({
    super.key,
    this.selectedIcon,
    required this.onIconSelected,
  });

  static const List<IconData> availableIcons = [
    Icons.living_rounded,
    Icons.bed_rounded,
    Icons.kitchen_rounded,
    Icons.bathroom_rounded,
    Icons.work_rounded,
    Icons.garage_rounded,
    Icons.grass_rounded,
    Icons.home_rounded,
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = AppTheme.getPrimaryBlue(isDark);

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
                  ? AppTheme.getPrimaryButtonGradient(isDark)
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

