import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sudan/core/theme/app_theme.dart';
import 'package:sudan/core/localization/app_localizations.dart';
import 'package:sudan/presentation/viewmodels/scenario_setup_viewmodel.dart';
import 'package:sudan/presentation/viewmodels/device_viewmodel.dart';
import 'package:sudan/presentation/viewmodels/room_viewmodel.dart';
import 'package:sudan/presentation/widgets/setup/scenario_device_config_card.dart';
import 'package:sudan/presentation/widgets/common/premium_empty_state.dart';
import 'package:sudan/domain/entities/scenario_entity.dart';
import 'package:sudan/domain/entities/device_entity.dart';

/// Scenario Device Configuration Step
/// Second step of scenario setup - device selection and configuration
class ScenarioDeviceConfigStep extends StatelessWidget {
  const ScenarioDeviceConfigStep({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final setupVM = context.watch<ScenarioSetupViewModel>();
    final deviceVM = context.watch<DeviceViewModel>();
    final roomVM = context.watch<RoomViewModel>();
    final size = MediaQuery.of(context).size;
    final isTabletLandscape = size.width > 900;

    // Get devices from current room or all devices
    final currentRoomId = roomVM.selectedRoomId;
    final availableDevices = currentRoomId != null
        ? deviceVM.devices.where((d) => d.roomId == currentRoomId).toList()
        : deviceVM.devices;

    // Get devices that are already configured
    final configuredDeviceIds = setupVM.actions.map((a) => a.deviceId).toSet();
    final configuredDevices = availableDevices
        .where((d) => configuredDeviceIds.contains(d.id))
        .toList();
    final unconfiguredDevices = availableDevices
        .where((d) => !configuredDeviceIds.contains(d.id))
        .toList();

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
                  Icons.devices_other_rounded,
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
                      AppLocalizations.of(context)!.configureDevices,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.getTextColor1(isDark),
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      AppLocalizations.of(context)!.selectAndConfigureDevices,
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

        // Configured Devices
        if (configuredDevices.isNotEmpty) ...[
          Row(
            children: [
              Text(
                '${AppLocalizations.of(context)!.configuredDevices} (${configuredDevices.length})',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.getTextColor1(isDark),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...configuredDevices.map((device) {
            final action = setupVM.getActionByDeviceId(device.id);
            return ScenarioDeviceConfigCard(
              device: device,
              action: action,
              onRemove: () => setupVM.removeAction(device.id),
            );
          }),
          const SizedBox(height: 24),
        ],

        // Available Devices Section
        if (unconfiguredDevices.isNotEmpty) ...[
          Text(
            AppLocalizations.of(context)!.availableDevices,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppTheme.getTextColor1(isDark),
            ),
          ),
          const SizedBox(height: 12),
          ...unconfiguredDevices.map((device) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: AppTheme.getSectionBackground(isDark),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppTheme.getSectionBorderColor(isDark).withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: ListTile(
                leading: Icon(
                  device.icon ?? Icons.device_unknown,
                  color: AppTheme.getTextColor1(isDark),
                ),
                title: Text(
                  device.name,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.getTextColor1(isDark),
                  ),
                ),
                subtitle: Text(
                  device.type.toString().split('.').last,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.getSecondaryGray(isDark),
                  ),
                ),
                trailing: IconButton(
                  onPressed: () {
                    // Create default action and add device
                    final defaultState = _createDefaultState(device);
                    final action = ScenarioAction(
                      deviceId: device.id,
                      targetState: defaultState,
                    );
                    setupVM.addAction(action);
                  },
                  icon: const Icon(Icons.add_rounded),
                  color: AppTheme.getPrimaryBlue(isDark),
                ),
              ),
            );
          }),
        ],

        // Empty State
        if (availableDevices.isEmpty)
          PremiumEmptyState(
            icon: Icons.devices_other_rounded,
            title: AppLocalizations.of(context)!.noDevicesAvailable,
            message: AppLocalizations.of(context)!.addDevicesToRoomFirst,
            highlights: const [],
            primaryActionLabel: '',
            onPrimaryAction: () {},
            isCompact: true,
          )
        else if (configuredDevices.isEmpty && unconfiguredDevices.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.getSectionBackground(isDark),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.getSecondaryGray(isDark).withOpacity(0.2),
              ),
            ),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    size: 48,
                    color: AppTheme.getSecondaryGray(isDark),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    AppLocalizations.of(context)!.noDevicesConfigured,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.getSecondaryGray(isDark),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppLocalizations.of(context)!.addDevicesToConfigure,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.getSecondaryGray(isDark),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  DeviceState _createDefaultState(DeviceEntity device) {
    final currentState = device.state;
    
    if (currentState is LightState) {
      return LightState(
        isOn: true,
        brightness: 80,
        color: currentState.color,
      );
    } else if (currentState is ThermostatState) {
      return ThermostatState(
        isOn: true,
        temperature: currentState.temperature,
        targetTemperature: 22,
        mode: currentState.mode,
      );
    } else if (currentState is CurtainState) {
      return const CurtainState(isOpen: true, position: 100);
    } else if (currentState is CameraState) {
      return CameraState(
        isOn: true,
        isRecording: false,
        resolution: currentState.resolution,
      );
    } else if (currentState is MusicState) {
      return const MusicState(
        isPlaying: true,
        volume: 50,
      );
    } else if (currentState is SecurityState) {
      return const SecurityState(
        isActive: true,
        status: 'Armed',
      );
    } else if (currentState is ElevatorState) {
      return ElevatorState(
        currentFloor: currentState.currentFloor,
        targetFloor: currentState.currentFloor,
        isMoving: false,
        availableFloors: currentState.availableFloors,
      );
    } else if (currentState is DoorLockState) {
      return const DoorLockState(
        isLocked: false,
        isUnlocking: false,
      );
    } else {
      return const SimpleState(isOn: true);
    }
  }
}

