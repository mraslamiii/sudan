import 'package:flutter/material.dart';
import '../../../core/di/injection_container.dart';

import '../../../data/models/dashboard_card_model.dart';
import 'card_widgets/device_card.dart';
import 'cctv_camera_widget.dart';
import 'led_control_panel.dart';
import 'thermostat_control_panel.dart';
import 'music_player_control_panel.dart';
import 'security_control_panel.dart';
import 'curtain_control_panel.dart';
import 'elevator_control_panel.dart';
import 'door_lock_control_panel.dart';
import 'iphone_control_panel.dart';
import 'usb_serial_status_panel.dart';
import 'base_dashboard_card.dart';
import '../../../presentation/viewmodels/usb_serial_viewmodel.dart';

/// Factory class to create appropriate card widget based on card type
class DashboardCardFactory {
  static Widget createCard({
    required DashboardCardModel card,
    required bool isEditMode,
    VoidCallback? onTap,
    VoidCallback? onLongPress,
    VoidCallback? onDelete,
    Function(CardSize)? onResize,
    Function(Map<String, dynamic>)? onDataUpdate,
  }) {
    // Camera cards use the special CCTV widget
    if (card.type == CardType.camera) {
      final isOn = card.data['isOn'] as bool? ?? true;
      final isRecording = card.data['isRecording'] as bool? ?? false;
      final currentRoom = card.data['location'] as String? ?? 'Living Room';
      final availableRooms = card.data['availableRooms'] as List<dynamic>? ?? 
          ['Living Room', 'Bed Room', 'Kitchen', 'Bathroom'];
      final imagePath = card.data['imagePath'] as String?;

      return BaseDashboardCard(
        card: card,
        isEditMode: isEditMode,
        onTap: onTap,
        onLongPress: onLongPress,
        onDelete: onDelete,
        onResize: onResize,
        child: isOn
            ? CCTVCameraWidget(
                currentRoom: currentRoom,
                availableRooms: availableRooms.cast<String>(),
                isRecording: isRecording,
                isLive: isOn,
                imagePath: imagePath,
                onRoomChanged: (newRoom) {
                  onDataUpdate?.call({
                    'location': newRoom,
                  });
                },
              )
            : Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1C1C1E),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.videocam_off_rounded,
                        color: Colors.white54,
                        size: 48,
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Camera Offline',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      );
    }

    // Thermostat and Air Conditioner cards use the special ThermostatControlPanel
    if (card.type == CardType.thermostat || card.type == CardType.airConditioner) {
      final targetTemperature = card.data['targetTemperature'] as int? ?? 25;
      final mode = card.data['mode'] as String? ?? 'Auto';
      final isOn = card.data['isOn'] as bool? ?? true;

      return BaseDashboardCard(
        card: card,
        isEditMode: isEditMode,
        onTap: onTap,
        onLongPress: onLongPress,
        onDelete: onDelete,
        onResize: onResize,
        child: ThermostatControlPanel(
          temperature: targetTemperature,
          mode: mode,
          isOn: isOn,
          onTemperatureChanged: (newTemp) {
            onDataUpdate?.call({
              'targetTemperature': newTemp,
            });
          },
          onModeChanged: (newMode) {
            onDataUpdate?.call({
              'mode': newMode,
            });
          },
          onToggle: (newIsOn) {
            onDataUpdate?.call({
              'isOn': newIsOn,
            });
          },
        ),
      );
    }

    // Music cards use the special MusicPlayerControlPanel
    if (card.type == CardType.music) {
      final isPlaying = card.data['isPlaying'] as bool? ?? false;
      final title = card.data['title'] as String?;
      final artist = card.data['artist'] as String?;
      final volume = card.data['volume'] as int? ?? 50;

      return BaseDashboardCard(
        card: card,
        isEditMode: isEditMode,
        onTap: onTap,
        onLongPress: onLongPress,
        onDelete: onDelete,
        onResize: onResize,
        child: MusicPlayerControlPanel(
          isPlaying: isPlaying,
          title: title,
          artist: artist,
          volume: volume,
          onPlayPause: (playing) {
            onDataUpdate?.call({
              'isPlaying': playing,
            });
          },
          onPrevious: () {
            // Send USB Serial command for previous track
            final deviceId = card.data['deviceId'] as String?;
            if (deviceId != null) {
              try {
                final usbSerialVM = getIt<UsbSerialViewModel>();
                if (usbSerialVM.isUsbConnected) {
                  usbSerialVM.sendMusicPreviousCommand(deviceId);
                }
              } catch (e) {
                print('❌ [DASHBOARD_CARD_FACTORY] Failed to send music previous command: $e');
              }
            }
          },
          onNext: () {
            // Send USB Serial command for next track
            final deviceId = card.data['deviceId'] as String?;
            if (deviceId != null) {
              try {
                final usbSerialVM = getIt<UsbSerialViewModel>();
                if (usbSerialVM.isUsbConnected) {
                  usbSerialVM.sendMusicNextCommand(deviceId);
                }
              } catch (e) {
                print('❌ [DASHBOARD_CARD_FACTORY] Failed to send music next command: $e');
              }
            }
          },
          onVolumeChanged: (newVolume) {
            onDataUpdate?.call({
              'volume': newVolume,
            });
          },
        ),
      );
    }

    // Security cards use the special SecurityControlPanel
    if (card.type == CardType.security) {
      final isActive = card.data['isActive'] as bool? ?? false;
      final status = card.data['status'] as String? ?? 'Disarmed';
      final zones = (card.data['zones'] as List<dynamic>?)?.cast<String>();

      return BaseDashboardCard(
        card: card,
        isEditMode: isEditMode,
        onTap: onTap,
        onLongPress: onLongPress,
        onDelete: onDelete,
        onResize: onResize,
        child: SecurityControlPanel(
          isActive: isActive,
          status: status,
          zones: zones,
          onArmDisarm: (armed) {
            onDataUpdate?.call({
              'isActive': armed,
              'status': armed ? 'Armed' : 'Disarmed',
            });
          },
          onStatusChanged: (newStatus) {
            onDataUpdate?.call({
              'status': newStatus,
              'isActive': newStatus == 'Armed',
            });
          },
        ),
      );
    }

    // Curtain cards use the special CurtainControlPanel
    if (card.type == CardType.curtain) {
      final isOpen = card.data['isOpen'] as bool? ?? false;
      final position = card.data['position'] as int? ?? 0;

      return BaseDashboardCard(
        card: card,
        isEditMode: isEditMode,
        onTap: onTap,
        onLongPress: onLongPress,
        onDelete: onDelete,
        onResize: onResize,
        child: CurtainControlPanel(
          isOpen: isOpen,
          position: position,
          onOpenClose: (open) {
            onDataUpdate?.call({
              'isOpen': open,
              'position': open ? 100 : 0,
            });
          },
          onPositionChanged: (newPosition) {
            onDataUpdate?.call({
              'position': newPosition,
              'isOpen': newPosition > 0,
            });
          },
        ),
      );
    }

    // Light cards use the special LEDControlPanel for full control
    if (card.type == CardType.light) {
      // Parse color from string or use default
      Color parseColor(String? colorString) {
        if (colorString == null) return const Color(0xFFFF9500);
        try {
          // Handle hex color strings like '#FF9500' or 'FF9500'
          final hex = colorString.replaceAll('#', '');
          return Color(int.parse('FF$hex', radix: 16));
        } catch (e) {
          return const Color(0xFFFF9500);
        }
      }

      final isOn = card.data['isOn'] as bool? ?? false;
      final brightness = card.data['brightness'] as int? ?? 80;
      final intensity = card.data['intensity'] as int? ?? 80;
      final colorString = card.data['color'] as String? ?? '#FF9500';
      final selectedColor = parseColor(colorString);
      final selectedPreset = card.data['preset'] as String? ?? 'Working';

      return BaseDashboardCard(
        card: card,
        isEditMode: isEditMode,
        onTap: onTap,
        onLongPress: onLongPress,
        onDelete: onDelete,
        onResize: onResize,
        child: LEDControlPanel(
          selectedColor: selectedColor,
          brightness: brightness,
          intensity: intensity,
          isOn: isOn,
          selectedPreset: selectedPreset,
          onColorChanged: (color) {
            // Convert color to hex string for storage
            final hex = color.value.toRadixString(16).substring(2).toUpperCase();
            onDataUpdate?.call({
              'color': '#$hex',
            });
          },
          onBrightnessChanged: (newBrightness) {
            onDataUpdate?.call({
              'brightness': newBrightness,
            });
          },
          onIntensityChanged: (newIntensity) {
            onDataUpdate?.call({
              'intensity': newIntensity,
            });
          },
          onToggle: (newIsOn) {
            onDataUpdate?.call({
              'isOn': newIsOn,
            });
          },
          onPresetChanged: (newPreset) {
            onDataUpdate?.call({
              'preset': newPreset,
            });
          },
        ),
      );
    }

    // Elevator cards use the special ElevatorControlPanel
    if (card.type == CardType.elevator) {
      final currentFloor = card.data['currentFloor'] as int? ?? 1;
      final targetFloor = card.data['targetFloor'] as int?;
      final isMoving = card.data['isMoving'] as bool? ?? false;
      final direction = card.data['direction'] as String?;
      final availableFloors = (card.data['availableFloors'] as List<dynamic>?)
              ?.map((e) => e as int)
              .toList() ??
          [1, 2, 3, 4, 5];

      return BaseDashboardCard(
        card: card,
        isEditMode: isEditMode,
        onTap: onTap,
        onLongPress: onLongPress,
        onDelete: onDelete,
        onResize: onResize,
        child: ElevatorControlPanel(
          currentFloor: currentFloor,
          targetFloor: targetFloor,
          isMoving: isMoving,
          direction: direction,
          availableFloors: availableFloors,
          onFloorSelected: (floor) {
            onDataUpdate?.call({
              'targetFloor': floor,
              'isMoving': true,
              'direction': floor > currentFloor ? 'up' : 'down',
            });
          },
          onToggle: (moving) {
            onDataUpdate?.call({
              'isMoving': moving,
            });
          },
        ),
      );
    }

    // Door lock cards use the special DoorLockControlPanel
    if (card.type == CardType.doorLock) {
      final isLocked = card.data['isLocked'] as bool? ?? true;
      final isUnlocking = card.data['isUnlocking'] as bool? ?? false;

      return BaseDashboardCard(
        card: card,
        isEditMode: isEditMode,
        onTap: onTap,
        onLongPress: onLongPress,
        onDelete: onDelete,
        onResize: onResize,
        child: DoorLockControlPanel(
          isLocked: isLocked,
          isUnlocking: isUnlocking,
          onLockToggled: (locked) {
            onDataUpdate?.call({
              'isLocked': locked,
              'isUnlocking': !locked,
            });
          },
          onToggle: (locked) {
            onDataUpdate?.call({
              'isLocked': locked,
            });
          },
          onStateUpdate: (state) {
            onDataUpdate?.call(state);
          },
        ),
      );
    }

    // iPhone cards use the special IPhoneControlPanel
    if (card.type == CardType.iphone) {
      final isActive = card.data['isActive'] as bool? ?? false;
      final deviceName = card.data['name'] as String? ?? 'iPhone';
      final batteryLevel = card.data['batteryLevel'] as int? ?? 100;
      final isCharging = card.data['isCharging'] as bool? ?? false;

      return BaseDashboardCard(
        card: card,
        isEditMode: isEditMode,
        onTap: onTap,
        onLongPress: onLongPress,
        onDelete: onDelete,
        onResize: onResize,
        child: IPhoneControlPanel(
          isActive: isActive,
          deviceName: deviceName,
          batteryLevel: batteryLevel,
          isCharging: isCharging,
          onToggle: () {
            onDataUpdate?.call({
              'isActive': !isActive,
            });
          },
          onOpen: () {
            onTap?.call();
          },
        ),
      );
    }

    // USB Serial cards use the special UsbSerialStatusPanel
    if (card.type == CardType.usbSerial) {
      return BaseDashboardCard(
        card: card,
        isEditMode: isEditMode,
        onTap: onTap,
        onLongPress: onLongPress,
        onDelete: onDelete,
        onResize: onResize,
        child: const UsbSerialStatusPanel(),
      );
    }

    // All other device cards use the unified DeviceCard
    return DeviceCard(
      card: card,
      isEditMode: isEditMode,
      onTap: onTap,
      onLongPress: onLongPress,
      onDelete: onDelete,
      onResize: onResize,
      onDataUpdate: onDataUpdate,
    );
  }
}

