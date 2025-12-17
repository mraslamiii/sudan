import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sudan/core/theme/app_theme.dart';
import 'package:sudan/core/localization/app_localizations.dart';
import 'package:sudan/presentation/viewmodels/scenario_setup_viewmodel.dart';
import 'package:sudan/presentation/widgets/setup/scenario_app_settings_panel.dart';

/// Scenario App Settings Step
/// Third step of scenario setup - app settings configuration
class ScenarioAppSettingsStep extends StatelessWidget {
  const ScenarioAppSettingsStep({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final viewModel = context.watch<ScenarioSetupViewModel>();
    final size = MediaQuery.of(context).size;
    final isTabletLandscape = size.width > 900;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Header Section
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
                  Icons.settings_rounded,
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
                      AppLocalizations.of(context)!.appSettings,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.getTextColor1(isDark),
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      AppLocalizations.of(context)!.configureAppSettings,
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

        // Info Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.getPrimaryBlue(isDark).withOpacity(0.1),
                AppTheme.getPrimaryBlue(isDark).withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppTheme.getPrimaryBlue(isDark).withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                color: AppTheme.getPrimaryBlue(isDark),
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  AppLocalizations.of(context)!.appSettingsInfo,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppTheme.getTextColor1(isDark),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Settings Panel
        ScenarioAppSettingsPanel(
          settings: viewModel.appSettings,
          onSettingsChanged: (settings) {
            viewModel.setAppSettings(settings);
          },
        ),
      ],
    );
  }
}

