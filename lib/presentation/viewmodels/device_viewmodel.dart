import 'package:flutter/material.dart';
import '../../core/base/base_viewmodel.dart';
import '../../domain/entities/device_entity.dart';
import '../../domain/use_cases/device/get_all_devices_use_case.dart';
import '../../domain/use_cases/device/get_devices_by_room_use_case.dart';
import '../../domain/use_cases/device/update_device_use_case.dart';
import '../../domain/use_cases/device/toggle_device_use_case.dart';
import '../../domain/use_cases/device/get_device_by_id_use_case.dart';
import 'usb_serial_viewmodel.dart';

/// LED Preset data class
class LEDPreset {
  final String name;
  final Color color;

  const LEDPreset({required this.name, required this.color});
}

/// Thermostat Mode data class
class ThermostatMode {
  final String name;
  final IconData icon;
  final Color color;

  const ThermostatMode({
    required this.name,
    required this.icon,
    required this.color,
  });
}

/// Device ViewModel
/// Manages all device-related state and operations
///
/// Usage in widgets:
/// ```dart
/// final viewModel = context.watch<DeviceViewModel>();
/// final devices = viewModel.devices;
///
/// // Toggle a device
/// await viewModel.toggleDevice('light_001');
///
/// // Update device state
/// await viewModel.updateDeviceState(
///   deviceId: 'light_001',
///   newState: LightState(isOn: true, brightness: 80, color: Colors.white),
/// );
///
/// // LED Control
/// viewModel.updateLEDColor(Colors.blue);
/// viewModel.updateLEDBrightness(80);
/// viewModel.updateLEDPreset('Reading');
///
/// // Thermostat Control
/// viewModel.changeTemperature(1); // Increase by 1
/// viewModel.updateThermostatMode('Cool');
/// ```
class DeviceViewModel extends BaseViewModel {
  final GetAllDevicesUseCase _getAllDevicesUseCase;
  final GetDevicesByRoomUseCase _getDevicesByRoomUseCase;
  final UpdateDeviceUseCase _updateDeviceUseCase;
  final ToggleDeviceUseCase _toggleDeviceUseCase;
  final GetDeviceByIdUseCase _getDeviceByIdUseCase;
  final UsbSerialViewModel? _usbSerialViewModel;

  List<DeviceEntity> _devices = [];
  String? _selectedRoomId;

  DeviceViewModel(
    this._getAllDevicesUseCase,
    this._getDevicesByRoomUseCase,
    this._updateDeviceUseCase,
    this._toggleDeviceUseCase,
    this._getDeviceByIdUseCase, [
    this._usbSerialViewModel,
  ]);

  // ==================== BASE GETTERS ====================

  List<DeviceEntity> get devices => _devices;
  String? get selectedRoomId => _selectedRoomId;

  /// Get devices filtered by current room
  List<DeviceEntity> get filteredDevices {
    if (_selectedRoomId == null) return _devices;
    // Return only devices that belong to the selected room
    return _devices.where((d) => d.roomId == _selectedRoomId).toList();
  }

  /// Get devices by type
  List<DeviceEntity> getDevicesByType(DeviceType type) {
    return filteredDevices.where((d) => d.type == type).toList();
  }

  /// Get a specific device by ID
  DeviceEntity? getDeviceById(String deviceId) {
    try {
      return _devices.firstWhere((d) => d.id == deviceId);
    } catch (e) {
      return null;
    }
  }

  // ==================== LED CONTROL ====================

  /// Available LED presets
  static const List<LEDPreset> ledPresets = [
    LEDPreset(name: 'Reading', color: Color(0xFF5AC8FA)),
    LEDPreset(name: 'Working', color: Colors.white),
    LEDPreset(name: 'Romantic', color: Color(0xFFFF69B4)),
  ];

  /// Get the first LED light device (filtered by selected room)
  DeviceEntity? get ledDevice {
    try {
      final devices = _selectedRoomId != null
          ? _devices.where(
              (d) => d.roomId == _selectedRoomId && d.type == DeviceType.light,
            )
          : _devices.where((d) => d.type == DeviceType.light);
      return devices.first;
    } catch (e) {
      return null;
    }
  }

  /// Get LED state
  LightState? get ledState => ledDevice?.state as LightState?;

  /// Get current LED color
  Color get ledColor => ledState?.color ?? const Color(0xFFFF9500);

  /// Get current LED brightness
  int get ledBrightness => ledState?.brightness ?? 80;

  /// Get if LED is on
  bool get isLedOn => ledState?.isOn ?? false;

  /// Get current LED preset
  String get ledPreset => ledState?.preset ?? 'Working';

  /// Get preset color by name
  Color getPresetColor(String presetName) {
    try {
      return ledPresets.firstWhere((p) => p.name == presetName).color;
    } catch (e) {
      return Colors.white;
    }
  }

  /// Update LED color
  Future<void> updateLEDColor(Color color) async {
    final device = ledDevice;
    final state = ledState;
    if (device != null && state != null) {
      await updateDeviceState(
        deviceId: device.id,
        newState: state.copyWith(color: color),
      );
    }
  }

  /// Update LED brightness
  Future<void> updateLEDBrightness(int brightness) async {
    final device = ledDevice;
    final state = ledState;
    if (device != null && state != null) {
      await updateDeviceState(
        deviceId: device.id,
        newState: state.copyWith(brightness: brightness.clamp(0, 100)),
      );
    }
  }

  /// Update LED intensity (alias for brightness in some contexts)
  Future<void> updateLEDIntensity(int intensity) async {
    await updateLEDBrightness(intensity);
  }

  /// Update LED preset
  Future<void> updateLEDPreset(String preset) async {
    final device = ledDevice;
    final state = ledState;
    if (device != null && state != null) {
      await updateDeviceState(
        deviceId: device.id,
        newState: state.copyWith(preset: preset),
      );
    }
  }

  /// Toggle LED on/off
  Future<void> toggleLED() async {
    final device = ledDevice;
    final state = ledState;
    if (device != null && state != null) {
      await updateDeviceState(
        deviceId: device.id,
        newState: state.copyWith(isOn: !state.isOn),
      );
    }
  }

  /// Set LED on/off state
  Future<void> setLEDOn(bool isOn) async {
    final device = ledDevice;
    final state = ledState;
    if (device != null && state != null) {
      await updateDeviceState(
        deviceId: device.id,
        newState: state.copyWith(isOn: isOn),
      );
    }
  }

  // ==================== THERMOSTAT CONTROL ====================

  /// Available thermostat modes
  static const List<ThermostatMode> thermostatModes = [
    ThermostatMode(
      name: 'Cool',
      icon: Icons.ac_unit_rounded,
      color: Color(0xFF5AC8FA),
    ),
    ThermostatMode(
      name: 'Heat',
      icon: Icons.local_fire_department_rounded,
      color: Color(0xFFFF9500),
    ),
    ThermostatMode(
      name: 'Fan',
      icon: Icons.air_rounded,
      color: Color(0xFF8E8E93),
    ),
    ThermostatMode(
      name: 'Auto',
      icon: Icons.sync_rounded,
      color: Color(0xFF34C759),
    ),
  ];

  /// Get the first thermostat device (filtered by selected room)
  DeviceEntity? get thermostatDevice {
    try {
      final devices = _selectedRoomId != null
          ? _devices.where(
              (d) =>
                  d.roomId == _selectedRoomId &&
                  d.type == DeviceType.thermostat,
            )
          : _devices.where((d) => d.type == DeviceType.thermostat);
      return devices.first;
    } catch (e) {
      return null;
    }
  }

  /// Get thermostat state
  ThermostatState? get thermostatState =>
      thermostatDevice?.state as ThermostatState?;

  /// Get current temperature
  int get currentTemperature => thermostatState?.temperature ?? 22;

  /// Get target temperature
  int get targetTemperature => thermostatState?.targetTemperature ?? 22;

  /// Get if thermostat is on
  bool get isThermostatOn => thermostatState?.isOn ?? false;

  /// Get current thermostat mode
  String get thermostatMode => thermostatState?.mode ?? 'Auto';

  /// Get color based on temperature value
  Color getTemperatureColor(int temperature) {
    if (temperature <= 18) {
      return const Color(0xFF5AC8FA); // Cold - Blue
    } else if (temperature <= 22) {
      return const Color(0xFF64D2FF); // Cool - Light Blue
    } else if (temperature <= 25) {
      return const Color(0xFF34C759); // Moderate - Green
    } else if (temperature <= 27) {
      return const Color(0xFFFFCC00); // Warm - Yellow/Orange
    } else {
      return const Color(0xFFFF9500); // Hot - Red/Orange
    }
  }

  /// Get temperature state description
  Map<String, dynamic> getTemperatureState(int temperature) {
    if (temperature <= 18) {
      return {'text': 'Cold', 'icon': Icons.ac_unit_rounded};
    } else if (temperature <= 22) {
      return {'text': 'Cool', 'icon': Icons.wb_twilight_rounded};
    } else if (temperature <= 25) {
      return {'text': 'Comfort', 'icon': Icons.wb_sunny_rounded};
    } else if (temperature <= 27) {
      return {'text': 'Warm', 'icon': Icons.wb_incandescent_rounded};
    } else {
      return {'text': 'Hot', 'icon': Icons.local_fire_department_rounded};
    }
  }

  /// Get mode data by name
  ThermostatMode? getModeByName(String modeName) {
    try {
      return thermostatModes.firstWhere((m) => m.name == modeName);
    } catch (e) {
      return null;
    }
  }

  /// Change temperature by delta
  Future<void> changeTemperature(int delta) async {
    final device = thermostatDevice;
    final state = thermostatState;
    if (device != null && state != null) {
      final newTemp = (state.targetTemperature + delta).clamp(16, 30);
      await updateDeviceState(
        deviceId: device.id,
        newState: state.copyWith(targetTemperature: newTemp),
      );
    }
  }

  /// Set target temperature
  Future<void> setTemperature(int temperature) async {
    final device = thermostatDevice;
    final state = thermostatState;
    if (device != null && state != null) {
      await updateDeviceState(
        deviceId: device.id,
        newState: state.copyWith(targetTemperature: temperature.clamp(16, 30)),
      );
    }
  }

  /// Update thermostat mode
  Future<void> updateThermostatMode(String mode) async {
    final device = thermostatDevice;
    final state = thermostatState;
    if (device != null && state != null) {
      await updateDeviceState(
        deviceId: device.id,
        newState: state.copyWith(mode: mode),
      );
    }
  }

  /// Toggle thermostat on/off
  Future<void> toggleThermostat() async {
    final device = thermostatDevice;
    final state = thermostatState;
    if (device != null && state != null) {
      await updateDeviceState(
        deviceId: device.id,
        newState: state.copyWith(isOn: !state.isOn),
      );
    }
  }

  /// Set thermostat on/off state
  Future<void> setThermostatOn(bool isOn) async {
    final device = thermostatDevice;
    final state = thermostatState;
    if (device != null && state != null) {
      await updateDeviceState(
        deviceId: device.id,
        newState: state.copyWith(isOn: isOn),
      );
    }
  }

  // ==================== TABLET CHARGER CONTROL ====================

  /// Get the first socket device (tablet charger) (filtered by selected room)
  DeviceEntity? get tabletChargerDevice {
    try {
      final devices = _selectedRoomId != null
          ? _devices.where(
              (d) => d.roomId == _selectedRoomId && d.type == DeviceType.socket,
            )
          : _devices.where((d) => d.type == DeviceType.socket);
      return devices.first;
    } catch (e) {
      return null;
    }
  }

  /// Get tablet charger state
  SimpleState? get tabletChargerState =>
      tabletChargerDevice?.state as SimpleState?;

  /// Get tablet battery level (simulated, 0-100)
  int get tabletBatteryLevel {
    // In a real app, this would come from device state or battery API
    // For now, return a simulated value
    return 75;
  }

  /// Get if tablet is charging
  bool get isTabletCharging {
    // This would be tracked in device state or via socket commands
    return false; // Will be updated via socket commands
  }

  /// Get if tablet is discharging
  bool get isTabletDischarging {
    // This would be tracked in device state or via socket commands
    return false; // Will be updated via socket commands
  }

  /// Get if tablet charger is connected
  bool get isTabletChargerConnected => tabletChargerDevice?.isOnline ?? false;

  /// Start tablet charging
  Future<void> startTabletCharge() async {
    final device = tabletChargerDevice;
    if (device != null) {
      // Send charge command via socket
      // This would typically go through SocketViewModel
      // For now, we'll update the device state
      final state = tabletChargerState;
      if (state != null) {
        await updateDeviceState(
          deviceId: device.id,
          newState: state.copyWith(isOn: true),
        );
      }
    }
  }

  /// Start tablet discharging
  Future<void> startTabletDischarge() async {
    final device = tabletChargerDevice;
    if (device != null) {
      // Send discharge command via socket
      // This would typically go through SocketViewModel
      // For now, we'll update the device state
      final state = tabletChargerState;
      if (state != null) {
        await updateDeviceState(
          deviceId: device.id,
          newState: state.copyWith(isOn: false),
        );
      }
    }
  }

  /// Toggle tablet charger on/off
  Future<void> toggleTabletCharger(bool isOn) async {
    final device = tabletChargerDevice;
    if (device != null) {
      final state = tabletChargerState;
      if (state != null) {
        await updateDeviceState(
          deviceId: device.id,
          newState: state.copyWith(isOn: isOn),
        );
      }
    }
  }

  // ==================== BASE OPERATIONS ====================

  @override
  void init() {
    super.init();
    loadDevices();
  }

  /// Load all devices
  Future<void> loadDevices() async {
    try {
      setLoading(true);
      clearError();

      _devices = await _getAllDevicesUseCase();
      notifyListeners();
    } catch (e) {
      setError('Failed to load devices: ${e.toString()}');
    } finally {
      setLoading(false);
    }
  }

  /// Set selected room and filter devices
  Future<void> selectRoom(String? roomId) async {
    if (_selectedRoomId == roomId) return;

    _selectedRoomId = roomId;
    notifyListeners();
  }

  /// Load devices for a specific room (uses repository)
  Future<List<DeviceEntity>> loadDevicesForRoom(String roomId) async {
    return await _getDevicesByRoomUseCase(roomId);
  }

  /// Toggle device on/off
  Future<void> toggleDevice(String deviceId) async {
    try {
      final device = await _getDeviceByIdUseCase(deviceId);
      final updatedDevice = await _toggleDeviceUseCase(deviceId);
      _updateDeviceInList(updatedDevice);

      _sendStateToMicro(deviceId, device.type, updatedDevice.state);

      // If in general room, apply changes to all similar devices in the house
      if (_selectedRoomId == 'room_general') {
        await _applyToAllSimilarDevices(
          device.type,
          updatedDevice.state,
          deviceId,
        );
      }

      notifyListeners();
    } catch (e) {
      setError('Failed to toggle device: ${e.toString()}');
    }
  }

  /// Update device state
  Future<void> updateDeviceState({
    required String deviceId,
    required DeviceState newState,
  }) async {
    try {
      final device = await _getDeviceByIdUseCase(deviceId);
      final updatedDevice = device.copyWith(state: newState);
      final result = await _updateDeviceUseCase(updatedDevice);
      _updateDeviceInList(result);

      _sendStateToMicro(deviceId, device.type, newState);

      // If in general room, apply changes to all similar devices in the house
      if (_selectedRoomId == 'room_general') {
        await _applyToAllSimilarDevices(device.type, newState, deviceId);
      }

      notifyListeners();
    } catch (e) {
      setError('Failed to update device: ${e.toString()}');
    }
  }

  /// Update entire device
  Future<void> updateDevice(DeviceEntity device) async {
    try {
      final updatedDevice = await _updateDeviceUseCase(device);
      _updateDeviceInList(updatedDevice);
      notifyListeners();
    } catch (e) {
      setError('Failed to update device: ${e.toString()}');
    }
  }

  /// Refresh devices
  Future<void> refresh() async {
    await loadDevices();
  }

  // Helper method to update device in local list
  void _updateDeviceInList(DeviceEntity updatedDevice) {
    final index = _devices.indexWhere((d) => d.id == updatedDevice.id);
    if (index != -1) {
      _devices[index] = updatedDevice;
    }
  }

  /// Send current device state to microcontroller when USB is connected
  void _sendStateToMicro(
    String deviceId,
    DeviceType deviceType,
    DeviceState state,
  ) {
    final usb = _usbSerialViewModel;
    if (usb == null || !usb.isUsbConnected) return;
    try {
      switch (deviceType) {
        case DeviceType.light:
          if (state is LightState) {
            usb.sendLightCommand(deviceId, state.isOn);
            usb.sendLEDBrightnessCommand(deviceId, state.brightness);
            final hex =
                '#${state.color.red.toRadixString(16).padLeft(2, '0')}${state.color.green.toRadixString(16).padLeft(2, '0')}${state.color.blue.toRadixString(16).padLeft(2, '0')}';
            usb.sendLEDColorCommand(deviceId, hex);
          }
          break;
        case DeviceType.curtain:
          if (state is CurtainState) {
            usb.sendCurtainPositionCommand(deviceId, state.position);
          }
          break;
        case DeviceType.thermostat:
          if (state is ThermostatState) {
            usb.sendThermostatTemperatureCommand(
              deviceId,
              state.targetTemperature,
            );
            usb.sendThermostatModeCommand(deviceId, state.mode);
          }
          break;
        case DeviceType.music:
          if (state is MusicState) {
            usb.sendMusicPlayPauseCommand(deviceId, state.isPlaying);
            usb.sendMusicVolumeCommand(deviceId, state.volume);
          }
          break;
        case DeviceType.security:
          if (state is SecurityState) {
            usb.sendSecurityCommand(deviceId, state.isActive);
          }
          break;
        case DeviceType.elevator:
          if (state is ElevatorState && state.targetFloor != null) {
            usb.sendElevatorCallCommand(deviceId, state.targetFloor!);
          }
          break;
        case DeviceType.doorLock:
          if (state is DoorLockState) {
            usb.sendDoorLockCommand(deviceId, state.isLocked);
          }
          break;
        case DeviceType.iphone:
          if (state is IPhoneState) {
            usb.sendIPhoneCommand(deviceId, state.isActive);
          }
          break;
        case DeviceType.socket:
          if (state is SimpleState) {
            usb.sendSocketCommand(deviceId, state.isOn);
          }
          break;
        case DeviceType.tv:
        case DeviceType.fan:
        case DeviceType.camera:
          if (state is SimpleState) {
            usb.sendSocketCommand(deviceId, state.isOn);
          }
          break;
        default:
          if (state is SimpleState) {
            usb.sendSocketCommand(deviceId, state.isOn);
          }
          break;
      }
    } catch (e) {
      print('❌ [DEVICE_VM] Failed to send state to micro: $e');
    }
  }

  /// Apply state changes to all similar devices in the house (for general room)
  Future<void> _applyToAllSimilarDevices(
    DeviceType deviceType,
    DeviceState newState,
    String excludeDeviceId,
  ) async {
    try {
      // Get all devices of the same type in the house (excluding the one we just updated)
      final similarDevices = _devices
          .where(
            (d) =>
                d.type == deviceType &&
                d.id !=
                    excludeDeviceId, // Don't update the device we just updated
          )
          .toList();

      print(
        '🟢 [DEVICE_VM] Applying changes to ${similarDevices.length} similar devices of type $deviceType',
      );

      // Apply the same state to all similar devices
      for (final similarDevice in similarDevices) {
        try {
          final updatedDevice = similarDevice.copyWith(state: newState);
          final result = await _updateDeviceUseCase(updatedDevice);
          _updateDeviceInList(result);
          print('🟢 [DEVICE_VM] Updated device ${similarDevice.id}');
        } catch (e) {
          // Continue with other devices even if one fails
          print(
            '🔴 [DEVICE_VM] Failed to update similar device ${similarDevice.id}: $e',
          );
        }
      }
    } catch (e) {
      print('🔴 [DEVICE_VM] Error applying changes to similar devices: $e');
    }
  }
}
