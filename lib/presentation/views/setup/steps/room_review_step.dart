import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sudan/core/theme/app_theme.dart';
import 'package:sudan/presentation/viewmodels/room_setup_viewmodel.dart';

/// Room Review Step
/// Final step of room setup - review and confirm
class RoomReviewStep extends StatelessWidget {
  const RoomReviewStep({super.key});

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
                  Icons.check_circle_outline_rounded,
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
                      'Review & Confirm',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.getTextColor1(isDark),
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Review your room details before saving',
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

          // Room Summary Card
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: AppTheme.getSectionGradient(isDark),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: AppTheme.getSectionBorderColor(isDark)
                    .withOpacity(isDark ? 0.7 : 0.55),
                width: 1.2,
              ),
              boxShadow: AppTheme.getSectionShadows(isDark),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: AppTheme.getPrimaryButtonGradient(isDark),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: AppTheme.getSectionShadows(
                          isDark,
                          elevated: true,
                        ),
                      ),
                      child: Icon(
                        viewModel.selectedIcon ?? Icons.home_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            viewModel.roomName ?? 'Unnamed Room',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.getTextColor1(isDark),
                            ),
                          ),
                          if (viewModel.roomDescription != null &&
                              viewModel.roomDescription!.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              viewModel.roomDescription!,
                              style: TextStyle(
                                fontSize: 14,
                                color: AppTheme.getSecondaryGray(isDark),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    _buildStatItem(
                      context,
                      Icons.devices_other_rounded,
                      '${viewModel.selectedDevices.length}',
                      'Devices',
                      isDark,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Devices List
          if (viewModel.selectedDevices.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text(
              'Devices (${viewModel.selectedDevices.length})',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppTheme.getTextColor1(isDark),
              ),
            ),
            const SizedBox(height: 12),
            ...viewModel.selectedDevices.map((device) {
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: AppTheme.getSectionGradient(isDark),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppTheme.getSectionBorderColor(isDark)
                        .withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      device.icon ?? Icons.device_unknown,
                      color: AppTheme.getPrimaryBlue(isDark),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            device.name,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.getTextColor1(isDark),
                            ),
                          ),
                          Text(
                            device.type.toString().split('.').last,
                            style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.getSecondaryGray(isDark),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],

          // Edit Button
          const SizedBox(height: 24),
          Center(
            child: TextButton.icon(
              onPressed: () => viewModel.goToStep(0),
              icon: const Icon(Icons.edit_rounded),
              label: const Text('Edit Details'),
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.getPrimaryBlue(isDark),
              ),
            ),
          ),
        ],
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    IconData icon,
    String value,
    String label,
    bool isDark,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: AppTheme.getPrimaryBlue(isDark),
        ),
        const SizedBox(width: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppTheme.getTextColor1(isDark),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: AppTheme.getSecondaryGray(isDark),
          ),
        ),
      ],
    );
  }
}

