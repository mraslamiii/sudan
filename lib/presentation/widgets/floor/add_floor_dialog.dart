import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/theme_colors.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/utils/pin_protection.dart';

/// Add Floor Dialog
/// Dialog for creating a new floor with name and icon selection
class AddFloorDialog extends StatefulWidget {
  final Function(String name, IconData icon) onConfirm;

  const AddFloorDialog({
    super.key,
    required this.onConfirm,
  });

  static Future<void> show(
    BuildContext context,
    Function(String name, IconData icon) onConfirm,
  ) async {
    if (!context.mounted) {
      return;
    }

    // Check PIN protection
    final verified = await PinProtection.requirePinVerification(
      context,
      title: AppLocalizations.of(context)!.pinRequired,
      subtitle: AppLocalizations.of(context)!.pinRequiredForAction,
    );

    if (!context.mounted) {
      return;
    }

    if (!verified) {
      return; // User cancelled or PIN verification failed
    }

    if (!context.mounted) {
      return;
    }

    return showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.6),
      builder: (dialogContext) => AddFloorDialog(onConfirm: onConfirm),
    );
  }

  @override
  State<AddFloorDialog> createState() => _AddFloorDialogState();
}

class _AddFloorDialogState extends State<AddFloorDialog> {
  final TextEditingController _nameController = TextEditingController();
  IconData _selectedIcon = Icons.layers_rounded;

  final List<IconData> _availableIcons = [
    Icons.layers_rounded,
    Icons.home_rounded,
    Icons.apartment_rounded,
    Icons.business_rounded,
    Icons.villa_rounded,
    Icons.stairs_rounded,
  ];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _handleConfirm() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.pleaseEnterFloorName),
          backgroundColor: ThemeColors.errorRed,
        ),
      );
      return;
    }
    widget.onConfirm(name, _selectedIcon);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = AppTheme.getPrimaryBlue(isDark);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 480, maxHeight: 600),
        decoration: BoxDecoration(
          gradient: AppTheme.getSectionGradient(isDark),
          borderRadius: BorderRadius.circular(36),
          border: Border.all(
            color: AppTheme.getSectionBorderColor(isDark)
                .withOpacity(isDark ? 0.7 : 0.55),
            width: 1.2,
          ),
          boxShadow: AppTheme.getSectionShadows(isDark, elevated: true),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(36),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: AppTheme.getPrimaryButtonGradient(isDark),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: AppTheme.getSectionShadows(
                          isDark,
                          elevated: true,
                        ),
                      ),
                      child: const Icon(
                        Icons.add_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.addNewFloor,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.getTextColor1(isDark),
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            AppLocalizations.of(context)!.createNewFloor,
                            style: TextStyle(
                              fontSize: 13,
                              color: AppTheme.getSecondaryGray(isDark),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Scrollable content
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Floor name input
                        Text(
                          AppLocalizations.of(context)!.floorName,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.getTextColor1(isDark),
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: _nameController,
                          autofocus: true,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.getTextColor1(isDark),
                          ),
                          decoration: InputDecoration(
                            hintText: AppLocalizations.of(context)!.floorNameHint,
                            hintStyle: TextStyle(
                              color: AppTheme.getSecondaryGray(isDark),
                            ),
                            filled: true,
                            fillColor: isDark
                                ? Colors.white.withOpacity(0.06)
                                : Colors.black.withOpacity(0.04),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                color: AppTheme.getSectionBorderColor(isDark)
                                    .withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                color: AppTheme.getSectionBorderColor(isDark)
                                    .withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                color: accentColor.withOpacity(0.6),
                                width: 2,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 16,
                            ),
                          ),
                          onSubmitted: (_) => _handleConfirm(),
                        ),
                        const SizedBox(height: 20),
                        // Icon selection
                        Text(
                          AppLocalizations.of(context)!.icon,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.getTextColor1(isDark),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: _availableIcons.map((icon) {
                            final isSelected = icon == _selectedIcon;
                            return GestureDetector(
                              onTap: () => setState(() => _selectedIcon = icon),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  gradient: isSelected
                                      ? AppTheme.getPrimaryButtonGradient(isDark)
                                      : null,
                                  color: isSelected
                                      ? null
                                      : isDark
                                          ? Colors.white.withOpacity(0.06)
                                          : Colors.black.withOpacity(0.04),
                                  borderRadius: BorderRadius.circular(14),
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
                                            blurRadius: 12,
                                            offset: const Offset(0, 6),
                                          ),
                                        ]
                                      : null,
                                ),
                                child: Icon(
                                  icon,
                                  color: isSelected
                                      ? Colors.white
                                      : AppTheme.getTextColor1(isDark),
                                  size: 22,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.getSecondaryGray(isDark),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: _handleConfirm,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ).copyWith(
                        elevation: MaterialStateProperty.all(0),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: AppTheme.getPrimaryButtonGradient(isDark),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: accentColor.withOpacity(0.3),
                              blurRadius: 16,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        child: const Text(
                          'Create',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

