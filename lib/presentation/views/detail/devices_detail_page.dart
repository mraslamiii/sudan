import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/theme_colors.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../data/models/dashboard_card_model.dart';
import '../../viewmodels/dashboard_viewmodel.dart';
import '../../widgets/dashboard/dashboard_card_factory.dart';
import '../../widgets/dashboard/base_dashboard_card.dart';

/// Full-screen detail page for devices - Optimized for 9" tablet landscape
class DevicesDetailPage extends StatelessWidget {
  const DevicesDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppTheme.getBackgroundColor(isDark),
      body: SafeArea(
        child: Column(
          children: [
            // Compact header
            _buildHeader(context, isDark, l10n),
            
            // Content - grid, no scroll
            Expanded(
              child: Consumer<DashboardViewModel>(
                builder: (context, dashboardVM, _) {
                  // Only show devices that don't have dedicated components
                  // These are devices that appear in the deviceCards list
                  final deviceCards = dashboardVM.deviceCards;

                  if (deviceCards.isEmpty) {
                    return _buildEmptyState(context, isDark, l10n);
                  }

                  return _buildDevicesGrid(context, dashboardVM, deviceCards, isDark, screenSize);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.getSectionBackground(isDark),
        border: Border(
          bottom: BorderSide(
            color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back_rounded, color: AppTheme.getTextColor1(isDark)),
            onPressed: () => Navigator.of(context).pop(),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: ThemeColors.primaryBlueLight.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.devices_rounded,
              size: 18,
              color: ThemeColors.primaryBlueLight,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              l10n.devices,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppTheme.getTextColor1(isDark),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isDark, AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.getSectionBackground(isDark),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.devices_rounded,
              size: 48,
              color: ThemeColors.primaryBlueLight,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No devices',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.getTextColor1(isDark),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add devices to control them from here',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.getSecondaryGray(isDark),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDevicesGrid(
    BuildContext context,
    DashboardViewModel dashboardVM,
    List<DashboardCardModel> deviceCards,
    bool isDark,
    Size screenSize,
  ) {
    // Calculate optimal columns based on screen width
    final availableWidth = screenSize.width - 40; // padding
    final cardWidth = 180.0;
    final spacing = 16.0;
    final columns = ((availableWidth + spacing) / (cardWidth + spacing)).floor().clamp(4, 8);
    
    return Padding(
      padding: const EdgeInsets.all(20),
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columns,
          crossAxisSpacing: spacing,
          mainAxisSpacing: spacing,
          childAspectRatio: 0.85,
        ),
        itemCount: deviceCards.length,
        itemBuilder: (context, index) {
          final card = deviceCards[index];
          return BaseDashboardCard(
            card: card,
            isEditMode: false,
            onTap: () {
              final currentState = card.data['isOn'] as bool? ?? false;
              dashboardVM.updateCardData(card.id, {'isOn': !currentState});
            },
            child: DashboardCardFactory.createCard(
              card: card,
              isEditMode: false,
              onTap: () {
                final currentState = card.data['isOn'] as bool? ?? false;
                dashboardVM.updateCardData(card.id, {'isOn': !currentState});
              },
              onDataUpdate: (data) => dashboardVM.updateCardData(card.id, data),
            ),
          );
        },
      ),
    );
  }
}
