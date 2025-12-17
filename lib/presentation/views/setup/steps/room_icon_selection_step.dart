import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sudan/core/theme/app_theme.dart';
import 'package:sudan/presentation/viewmodels/room_setup_viewmodel.dart';
import 'package:sudan/presentation/widgets/setup/room_icon_picker.dart';

/// Room Icon Selection Step
/// Second step of room setup - icon selection
class RoomIconSelectionStep extends StatelessWidget {
  const RoomIconSelectionStep({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final viewModel = context.watch<RoomSetupViewModel>();
    final size = MediaQuery.of(context).size;
    final isTabletLandscape = size.width > 900;

    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
        children: [
        if (!isTabletLandscape) ...[
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
                  Icons.palette_outlined,
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
                      'Choose Icon',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.getTextColor1(isDark),
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Select an icon that represents your room',
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
          const SizedBox(height: 32),
        ],

          Text(
          'Select Room Icon',
            style: TextStyle(
            fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.getTextColor1(isDark),
            ),
          ),
        const SizedBox(height: 16),
          RoomIconPicker(
            selectedIcon: viewModel.selectedIcon,
            onIconSelected: (icon) => viewModel.setSelectedIcon(icon),
          ),
        ],
    );
  }
}

