import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:sudan/core/theme/app_theme.dart';
import 'package:sudan/domain/entities/device_entity.dart';
import 'package:sudan/data/models/device_model.dart';
import 'package:sudan/presentation/viewmodels/room_setup_viewmodel.dart';
import 'package:sudan/presentation/viewmodels/device_viewmodel.dart';

/// Room Device Selection Step
/// Third step of room setup - device selection
class RoomDeviceSelectionStep extends StatelessWidget {
  const RoomDeviceSelectionStep({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final setupVM = context.watch<RoomSetupViewModel>();
    final deviceVM = context.watch<DeviceViewModel>();
    
    // Get all devices that don't have a room assigned (available devices)
    // A device is available if roomId is empty or null
    // Filter out elevator and doorLock devices as they shouldn't be selectable
    // This is dynamic - it reads from DeviceViewModel which loads from repository
    final allDevices = deviceVM.devices.where((device) {
      final roomId = device.roomId;
      // Filter out elevator and doorLock
      if (device.type == DeviceType.elevator || device.type == DeviceType.doorLock) {
        return false;
      }
      return roomId.isEmpty || roomId == 'null' || roomId == '';
    }).toList();
    
    // Get selected devices (both existing and newly created)
    final selectedDevices = setupVM.selectedDevices;
    final selectedDeviceIds = selectedDevices.map((d) => d.id).toSet();
    
    // Get newly created devices that haven't been saved yet
    final newDevices = setupVM.newDevicesToCreate;
    final newDeviceIds = newDevices.map((d) => d.id).toSet();
    
    // Combine: available devices are those not selected and not newly created
    final availableDevices = allDevices.where((device) {
      return !selectedDeviceIds.contains(device.id) && !newDeviceIds.contains(device.id);
    }).toList();
    
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
                      'Add Devices',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.getTextColor1(isDark),
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Select existing devices or create new ones',
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

          // Device Types Grid
          Text(
            'Create New Devices',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppTheme.getTextColor1(isDark),
            ),
          ),
          const SizedBox(height: 12),
          _buildDeviceTypesGrid(context, setupVM, isDark),
          const SizedBox(height: 24),

          // Existing Devices Section
          if (availableDevices.isNotEmpty) ...[
            Text(
              'Available Devices',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppTheme.getTextColor1(isDark),
              ),
            ),
            const SizedBox(height: 12),
            ...availableDevices.map((device) {
              final isSelected = selectedDeviceIds.contains(device.id);
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? LinearGradient(
                          colors: [
                            AppTheme.getPrimaryBlue(isDark).withOpacity(0.15),
                            AppTheme.getPrimaryBlue(isDark).withOpacity(0.08),
                          ],
                        )
                      : null,
                  color: isSelected
                      ? null
                      : AppTheme.getSectionBackground(isDark),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected
                        ? AppTheme.getPrimaryBlue(isDark).withOpacity(0.4)
                        : AppTheme.getSectionBorderColor(isDark)
                            .withOpacity(0.3),
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                child: CheckboxListTile(
                  value: isSelected,
                  onChanged: (value) {
                    if (value == true) {
                      setupVM.addDevice(device);
                    } else {
                      setupVM.removeDevice(device.id);
                    }
                  },
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
                  secondary: Icon(
                    device.icon ?? Icons.device_unknown,
                    color: isSelected
                        ? AppTheme.getPrimaryBlue(isDark)
                        : AppTheme.getTextColor1(isDark),
                  ),
                  activeColor: AppTheme.getPrimaryBlue(isDark),
                ),
              );
            }),
          ],

          // Selected Devices Section
          if (selectedDevices.isNotEmpty) ...[
            const SizedBox(height: 32),
            Text(
              'Selected Devices (${selectedDevices.length})',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppTheme.getTextColor1(isDark),
              ),
            ),
            const SizedBox(height: 12),
            ...selectedDevices.map((device) {
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.getPrimaryBlue(isDark).withOpacity(0.15),
                      AppTheme.getPrimaryBlue(isDark).withOpacity(0.08),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppTheme.getPrimaryBlue(isDark).withOpacity(0.4),
                    width: 1.5,
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
                    IconButton(
                      onPressed: () => setupVM.removeDevice(device.id),
                      icon: const Icon(Icons.close_rounded),
                      color: AppTheme.getSecondaryGray(isDark),
                    ),
                  ],
                ),
              );
            }),
          ],
        ],
    );
  }

  Widget _buildDeviceTypesGrid(
    BuildContext context,
    RoomSetupViewModel setupVM,
    bool isDark,
  ) {
    final selectedDeviceTypes = setupVM.newDevicesToCreate
        .map((d) => d.type)
        .toSet();
    
    final deviceTypes = _getAvailableDeviceTypes();
    
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 2.5,
      ),
      itemCount: deviceTypes.length,
      itemBuilder: (context, index) {
        final deviceType = deviceTypes[index];
        final isSelected = selectedDeviceTypes.contains(deviceType.type);
        final template = deviceType;
        
        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              if (isSelected) {
                // Remove device
                setupVM.removeNewDeviceByType(template.type);
              } else {
                // Add device with default name
                final device = _createDeviceWithDefaultName(template.type);
                setupVM.addNewDevice(device);
              }
            },
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? LinearGradient(
                        colors: [
                          template.color.withOpacity(isDark ? 0.25 : 0.2),
                          template.color.withOpacity(isDark ? 0.15 : 0.12),
                        ],
                      )
                    : null,
                color: isSelected
                    ? null
                    : AppTheme.getSectionBackground(isDark),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected
                      ? template.color.withOpacity(0.5)
                      : AppTheme.getSectionBorderColor(isDark).withOpacity(0.3),
                  width: isSelected ? 1.5 : 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          template.color.withOpacity(isDark ? 0.4 : 0.3),
                          template.color.withOpacity(isDark ? 0.25 : 0.18),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      template.icon,
                      color: template.color,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      template.title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.getTextColor1(isDark),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Checkbox(
                    value: isSelected,
                    onChanged: (value) {
                      if (value == true) {
                        final device = _createDeviceWithDefaultName(template.type);
                        setupVM.addNewDevice(device);
                      } else {
                        setupVM.removeNewDeviceByType(template.type);
                      }
                    },
                    activeColor: template.color,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  List<_DeviceTemplateData> _getAvailableDeviceTypes() {
    return [
      _DeviceTemplateData(
        type: DeviceType.light,
        title: 'Light',
        icon: Icons.lightbulb_rounded,
        color: const Color(0xFFFFB74D),
      ),
      _DeviceTemplateData(
        type: DeviceType.curtain,
        title: 'Curtain',
        icon: Icons.curtains_rounded,
        color: const Color(0xFF80CBC4),
      ),
      _DeviceTemplateData(
        type: DeviceType.thermostat,
        title: 'Thermostat',
        icon: Icons.thermostat_rounded,
        color: const Color(0xFF90CAF9),
      ),
      _DeviceTemplateData(
        type: DeviceType.tv,
        title: 'TV',
        icon: Icons.tv_rounded,
        color: const Color(0xFF90CAF9),
      ),
      _DeviceTemplateData(
        type: DeviceType.music,
        title: 'Music Player',
        icon: Icons.music_note_rounded,
        color: const Color(0xFF9575CD),
      ),
      _DeviceTemplateData(
        type: DeviceType.fan,
        title: 'Fan',
        icon: Icons.toys_rounded,
        color: const Color(0xFF4FC3F7),
      ),
      _DeviceTemplateData(
        type: DeviceType.security,
        title: 'Security',
        icon: Icons.shield_rounded,
        color: const Color(0xFFEF9A9A),
      ),
      _DeviceTemplateData(
        type: DeviceType.camera,
        title: 'Camera',
        icon: Icons.videocam_rounded,
        color: const Color(0xFF81D4FA),
      ),
      _DeviceTemplateData(
        type: DeviceType.socket,
        title: 'Socket',
        icon: Icons.power_rounded,
        color: const Color(0xFF4CAF50),
      ),
      _DeviceTemplateData(
        type: DeviceType.lock,
        title: 'Lock',
        icon: Icons.lock_rounded,
        color: const Color(0xFF9E9E9E),
      ),
      _DeviceTemplateData(
        type: DeviceType.iphone,
        title: 'آیفون درب',
        icon: Icons.doorbell_rounded,
        color: const Color(0xFF007AFF),
      ),
    ];
  }

  DeviceEntity _createDeviceWithDefaultName(DeviceType type) {
    final deviceId = const Uuid().v4();
    final deviceName = _getDefaultNameForType(type);
    final defaultState = _getDefaultStateForType(type);
    final icon = _getIconForType(type);

    return DeviceModel(
      id: deviceId,
      name: deviceName,
      type: type,
      roomId: '', // Will be set when added to room
      state: defaultState,
      icon: icon,
      isOnline: true,
      lastUpdated: DateTime.now(),
    );
  }

  String _getDefaultNameForType(DeviceType type) {
    switch (type) {
      case DeviceType.light:
        return 'Light';
      case DeviceType.thermostat:
        return 'Thermostat';
      case DeviceType.curtain:
        return 'Curtain';
      case DeviceType.tv:
        return 'TV';
      case DeviceType.fan:
        return 'Fan';
      case DeviceType.security:
        return 'Security System';
      case DeviceType.music:
        return 'Music Player';
      case DeviceType.camera:
        return 'Camera';
      case DeviceType.socket:
        return 'Tablet Charger';
      case DeviceType.lock:
        return 'Lock';
      case DeviceType.elevator:
        return 'Elevator';
      case DeviceType.doorLock:
        return 'Door Lock';
      case DeviceType.iphone:
        return 'آیفون درب';
    }
  }

  IconData _getIconForType(DeviceType type) {
    switch (type) {
      case DeviceType.light:
        return Icons.lightbulb_rounded;
      case DeviceType.thermostat:
        return Icons.thermostat_rounded;
      case DeviceType.curtain:
        return Icons.curtains_rounded;
      case DeviceType.tv:
        return Icons.tv_rounded;
      case DeviceType.fan:
        return Icons.toys_rounded;
      case DeviceType.security:
        return Icons.shield_rounded;
      case DeviceType.music:
        return Icons.music_note_rounded;
      case DeviceType.camera:
        return Icons.videocam_rounded;
      case DeviceType.socket:
        return Icons.power_rounded;
      case DeviceType.lock:
        return Icons.lock_rounded;
      case DeviceType.elevator:
        return Icons.elevator_rounded;
      case DeviceType.doorLock:
        return Icons.door_front_door_rounded;
      case DeviceType.iphone:
        return Icons.doorbell_rounded;
    }
  }

  DeviceState _getDefaultStateForType(DeviceType type) {
    switch (type) {
      case DeviceType.light:
        return const LightState(
          isOn: false,
          brightness: 80,
          color: Color(0xFFFFFFFF),
        );
      case DeviceType.thermostat:
        return const ThermostatState(
          isOn: true,
          temperature: 22,
          targetTemperature: 22,
          mode: 'Auto',
        );
      case DeviceType.curtain:
        return const CurtainState(isOpen: false, position: 0);
      case DeviceType.camera:
        return const CameraState(
          isOn: true,
          isRecording: false,
          resolution: '4K',
        );
      case DeviceType.music:
        return const MusicState(
          isPlaying: false,
          volume: 50,
        );
      case DeviceType.security:
        return const SecurityState(
          isActive: false,
          status: 'Disarmed',
        );
      case DeviceType.elevator:
        return const ElevatorState(
          currentFloor: 1,
          isMoving: false,
          availableFloors: [1, 2, 3, 4, 5],
        );
      case DeviceType.iphone:
        return const IPhoneState(
          isActive: false,
          batteryLevel: 100,
          isCharging: false,
        );
      default:
        return const SimpleState(isOn: false);
    }
  }
}

class _DeviceTemplateData {
  final DeviceType type;
  final String title;
  final IconData icon;
  final Color color;

  const _DeviceTemplateData({
    required this.type,
    required this.title,
    required this.icon,
    required this.color,
  });
}

