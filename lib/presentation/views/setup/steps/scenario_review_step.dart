import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sudan/core/theme/app_theme.dart';
import 'package:sudan/core/localization/app_localizations.dart';
import 'package:sudan/presentation/viewmodels/scenario_setup_viewmodel.dart';
import 'package:sudan/presentation/viewmodels/device_viewmodel.dart';
import 'package:sudan/domain/entities/device_entity.dart';
import 'package:sudan/domain/entities/scenario_entity.dart';

/// Scenario Review Step
/// Final step of scenario setup - review and confirm
class ScenarioReviewStep extends StatelessWidget {
  const ScenarioReviewStep({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final viewModel = context.watch<ScenarioSetupViewModel>();
    final deviceVM = context.watch<DeviceViewModel>();
    final size = MediaQuery.of(context).size;
    final isTabletLandscape = size.width > 900;

    // Get devices for actions
    final devices = viewModel.actions.map((action) {
      try {
        return deviceVM.devices.firstWhere((d) => d.id == action.deviceId);
      } catch (e) {
        return null;
      }
    }).whereType<DeviceEntity>().toList();

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
                      AppLocalizations.of(context)!.reviewAndConfirm,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.getTextColor1(isDark),
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      AppLocalizations.of(context)!.reviewScenarioDetails,
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

        // Scenario Summary Card
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
                      gradient: LinearGradient(
                        colors: [
                          viewModel.selectedColor ?? AppTheme.getPrimaryBlue(isDark),
                          (viewModel.selectedColor ?? AppTheme.getPrimaryBlue(isDark))
                              .withOpacity(0.7),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: AppTheme.getSectionShadows(
                        isDark,
                        elevated: true,
                      ),
                    ),
                    child: Icon(
                      viewModel.selectedIcon ?? Icons.auto_awesome_rounded,
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
                          viewModel.scenarioName ?? AppLocalizations.of(context)!.scenarioName,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.getTextColor1(isDark),
                          ),
                        ),
                        if (viewModel.scenarioDescription != null &&
                            viewModel.scenarioDescription!.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            viewModel.scenarioDescription!,
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
                    '${viewModel.actions.length}',
                    AppLocalizations.of(context)!.devices,
                    isDark,
                  ),
                  if (viewModel.appSettings?.hasSettings == true) ...[
                    const SizedBox(width: 24),
                    _buildStatItem(
                      context,
                      Icons.settings_rounded,
                      '1',
                      AppLocalizations.of(context)!.appSettings,
                      isDark,
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),

        // Devices List
        if (viewModel.actions.isNotEmpty) ...[
          const SizedBox(height: 24),
          Text(
            '${AppLocalizations.of(context)!.devices} (${viewModel.actions.length})',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppTheme.getTextColor1(isDark),
            ),
          ),
          const SizedBox(height: 12),
          ...viewModel.actions.map((action) {
            final device = devices.firstWhere(
              (d) => d.id == action.deviceId,
              orElse: () => DeviceEntity(
                id: action.deviceId,
                name: AppLocalizations.of(context)!.noDevicesAvailable,
                type: DeviceType.light,
                roomId: '',
                state: const SimpleState(isOn: false),
                lastUpdated: DateTime.now(),
              ),
            );
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: AppTheme.getSectionGradient(isDark),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppTheme.getSectionBorderColor(isDark).withOpacity(0.3),
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
                        const SizedBox(height: 4),
                        Text(
                          _getActionDescription(context, action),
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.getSecondaryGray(isDark),
                          ),
                        ),
                        if (action.delayMs > 0) ...[
                          const SizedBox(height: 2),
                          Text(
                            '${AppLocalizations.of(context)!.delay}: ${action.delayMs}ms',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppTheme.getSecondaryGray(isDark),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],

        // App Settings Summary
        if (viewModel.appSettings?.hasSettings == true) ...[
          const SizedBox(height: 24),
          Text(
            AppLocalizations.of(context)!.appSettings,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppTheme.getTextColor1(isDark),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: AppTheme.getSectionGradient(isDark),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppTheme.getSectionBorderColor(isDark).withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (viewModel.appSettings?.themeMode != null) ...[
                  _buildSettingRow(
                    context,
                    Icons.palette_rounded,
                    AppLocalizations.of(context)!.themeMode,
                    _getThemeModeLabel(context, viewModel.appSettings!.themeMode!),
                    isDark,
                  ),
                ],
                if (viewModel.appSettings?.language != null) ...[
                  if (viewModel.appSettings?.themeMode != null)
                    const SizedBox(height: 12),
                  _buildSettingRow(
                    context,
                    Icons.language_rounded,
                    AppLocalizations.of(context)!.language,
                    viewModel.appSettings!.language == 'en' 
                        ? AppLocalizations.of(context)!.english 
                        : AppLocalizations.of(context)!.persian,
                    isDark,
                  ),
                ],
              ],
            ),
          ),
        ],

        // Edit Button
        const SizedBox(height: 24),
        Center(
          child: TextButton.icon(
            onPressed: () => viewModel.goToStep(0),
            icon: const Icon(Icons.edit_rounded),
            label: Text(AppLocalizations.of(context)!.editDetails),
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

  Widget _buildSettingRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
    bool isDark,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: AppTheme.getPrimaryBlue(isDark),
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppTheme.getTextColor1(isDark),
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            color: AppTheme.getSecondaryGray(isDark),
          ),
        ),
      ],
    );
  }

  String _getActionDescription(BuildContext context, ScenarioAction action) {
    final state = action.targetState;
    if (state is LightState) {
      return state.isOn
          ? '${AppLocalizations.of(context)!.turnOn} (${state.brightness}%)'
          : AppLocalizations.of(context)!.turnOff;
    } else if (state is ThermostatState) {
      return state.isOn
          ? '${AppLocalizations.of(context)!.setTo} ${state.targetTemperature}°C'
          : AppLocalizations.of(context)!.turnOff;
    } else if (state is CurtainState) {
      return state.isOpen
          ? '${AppLocalizations.of(context)!.open} (${state.position}%)'
          : AppLocalizations.of(context)!.close;
    } else if (state is CameraState) {
      return state.isOn
          ? AppLocalizations.of(context)!.turnOn
          : AppLocalizations.of(context)!.turnOff;
    } else if (state is MusicState) {
      return state.isPlaying
          ? '${AppLocalizations.of(context)!.play} (${state.volume}%)'
          : AppLocalizations.of(context)!.stop;
    } else if (state is SecurityState) {
      return state.isActive
          ? AppLocalizations.of(context)!.arm
          : AppLocalizations.of(context)!.disarm;
    } else if (state is SimpleState) {
      return state.isOn
          ? AppLocalizations.of(context)!.turnOn
          : AppLocalizations.of(context)!.turnOff;
    }
    return AppLocalizations.of(context)!.setState;
  }

  String _getThemeModeLabel(BuildContext context, ThemeMode mode) {
    final l10n = AppLocalizations.of(context)!;
    switch (mode) {
      case ThemeMode.light:
        return l10n.light;
      case ThemeMode.dark:
        return l10n.dark;
      case ThemeMode.system:
        return l10n.system;
    }
  }
}

