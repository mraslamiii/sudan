import 'package:flutter/material.dart';
import '../../domain/entities/device_entity.dart';

/// Device Model - Data layer implementation of DeviceEntity
/// Includes JSON serialization for API/storage communication
/// 
/// This model extends the domain entity and adds:
/// - fromJson: Convert JSON data to model
/// - toJson: Convert model to JSON for storage/API
/// - mock factory: Create test data easily
class DeviceModel extends DeviceEntity {
  const DeviceModel({
    required super.id,
    required super.name,
    required super.type,
    required super.roomId,
    required super.state,
    super.icon,
    super.isOnline,
    required super.lastUpdated,
  });

  /// Create DeviceModel from JSON
  factory DeviceModel.fromJson(Map<String, dynamic> json) {
    final type = deviceTypeFromString(json['type'] as String? ?? 'light');
    final state = stateFromJson(type, json['state'] as Map<String, dynamic>? ?? {});
    
    return DeviceModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      type: type,
      roomId: json['roomId'] as String? ?? '',
      state: state,
      icon: _iconFromString(json['icon'] as String?),
      isOnline: json['isOnline'] as bool? ?? true,
      lastUpdated: json['lastUpdated'] != null
          ? DateTime.parse(json['lastUpdated'] as String)
          : DateTime.now(),
    );
  }

  /// Convert DeviceModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': deviceTypeToString(type),
      'roomId': roomId,
      'state': stateToJson(state),
      'icon': _iconToString(icon),
      'isOnline': isOnline,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  /// Create a mock device for testing
  /// 
  /// Example:
  /// ```dart
  /// final mockLight = DeviceModel.mockLight(
  ///   id: 'light_001',
  ///   roomId: 'room_living',
  ///   isOn: true,
  /// );
  /// ```
  factory DeviceModel.mockLight({
    required String id,
    required String roomId,
    String name = 'Living Room Light',
    bool isOn = false,
    int brightness = 80,
    Color color = Colors.white,
  }) {
    return DeviceModel(
      id: id,
      name: name,
      type: DeviceType.light,
      roomId: roomId,
      state: LightState(
        isOn: isOn,
        brightness: brightness,
        color: color,
      ),
      icon: Icons.lightbulb_rounded,
      isOnline: true,
      lastUpdated: DateTime.now(),
    );
  }

  factory DeviceModel.mockThermostat({
    required String id,
    required String roomId,
    String name = 'Thermostat',
    bool isOn = true,
    int temperature = 22,
    int targetTemperature = 22,
    String mode = 'Auto',
  }) {
    return DeviceModel(
      id: id,
      name: name,
      type: DeviceType.thermostat,
      roomId: roomId,
      state: ThermostatState(
        isOn: isOn,
        temperature: temperature,
        targetTemperature: targetTemperature,
        mode: mode,
      ),
      icon: Icons.thermostat_rounded,
      isOnline: true,
      lastUpdated: DateTime.now(),
    );
  }

  factory DeviceModel.mockCamera({
    required String id,
    required String roomId,
    String name = 'Security Camera',
    bool isOn = true,
    bool isRecording = false,
    String resolution = '4K',
  }) {
    return DeviceModel(
      id: id,
      name: name,
      type: DeviceType.camera,
      roomId: roomId,
      state: CameraState(
        isOn: isOn,
        isRecording: isRecording,
        resolution: resolution,
        currentRoom: roomId,
      ),
      icon: Icons.videocam_rounded,
      isOnline: true,
      lastUpdated: DateTime.now(),
    );
  }

  factory DeviceModel.mockCurtain({
    required String id,
    required String roomId,
    String name = 'Curtains',
    bool isOpen = false,
    int position = 0,
  }) {
    return DeviceModel(
      id: id,
      name: name,
      type: DeviceType.curtain,
      roomId: roomId,
      state: CurtainState(
        isOpen: isOpen,
        position: position,
      ),
      icon: Icons.curtains_rounded,
      isOnline: true,
      lastUpdated: DateTime.now(),
    );
  }

  factory DeviceModel.mockSimple({
    required String id,
    required String roomId,
    required DeviceType type,
    required String name,
    bool isOn = false,
    IconData? icon,
  }) {
    return DeviceModel(
      id: id,
      name: name,
      type: type,
      roomId: roomId,
      state: SimpleState(isOn: isOn),
      icon: icon ?? _defaultIconForType(type),
      isOnline: true,
      lastUpdated: DateTime.now(),
    );
  }

  factory DeviceModel.mockElevator({
    required String id,
    required String roomId,
    required String name,
    int currentFloor = 1,
    int? targetFloor,
    bool isMoving = false,
    String? direction,
    List<int> availableFloors = const [1, 2, 3, 4, 5],
  }) {
    return DeviceModel(
      id: id,
      name: name,
      type: DeviceType.elevator,
      roomId: roomId,
      state: ElevatorState(
        currentFloor: currentFloor,
        targetFloor: targetFloor,
        isMoving: isMoving,
        direction: direction,
        availableFloors: availableFloors,
      ),
      icon: Icons.elevator_rounded,
      isOnline: true,
      lastUpdated: DateTime.now(),
    );
  }

  // Helper methods for serialization

  // Public static methods for serialization (used by ScenarioModel too)
  static DeviceType deviceTypeFromString(String type) {
    switch (type.toLowerCase()) {
      case 'light':
        return DeviceType.light;
      case 'thermostat':
        return DeviceType.thermostat;
      case 'curtain':
        return DeviceType.curtain;
      case 'tv':
        return DeviceType.tv;
      case 'fan':
        return DeviceType.fan;
      case 'security':
        return DeviceType.security;
      case 'music':
        return DeviceType.music;
      case 'camera':
        return DeviceType.camera;
      case 'socket':
        return DeviceType.socket;
      case 'lock':
        return DeviceType.lock;
      case 'elevator':
        return DeviceType.elevator;
      case 'doorlock':
        return DeviceType.doorLock;
      case 'iphone':
        return DeviceType.iphone;
      default:
        return DeviceType.light;
    }
  }

  static String deviceTypeToString(DeviceType type) {
    return type.toString().split('.').last;
  }

  static DeviceState stateFromJson(DeviceType type, Map<String, dynamic> json) {
    switch (type) {
      case DeviceType.light:
        return LightState(
          isOn: json['isOn'] as bool? ?? false,
          brightness: json['brightness'] as int? ?? 80,
          color: Color(json['color'] as int? ?? Colors.white.value),
          preset: json['preset'] as String?,
        );
      case DeviceType.thermostat:
        return ThermostatState(
          isOn: json['isOn'] as bool? ?? true,
          temperature: json['temperature'] as int? ?? 22,
          targetTemperature: json['targetTemperature'] as int? ?? 22,
          mode: json['mode'] as String? ?? 'Auto',
        );
      case DeviceType.camera:
        return CameraState(
          isOn: json['isOn'] as bool? ?? true,
          isRecording: json['isRecording'] as bool? ?? false,
          resolution: json['resolution'] as String? ?? '4K',
          currentRoom: json['currentRoom'] as String?,
        );
      case DeviceType.curtain:
        return CurtainState(
          isOpen: json['isOpen'] as bool? ?? false,
          position: json['position'] as int? ?? 0,
        );
      case DeviceType.music:
        return MusicState(
          isPlaying: json['isPlaying'] as bool? ?? false,
          title: json['title'] as String?,
          artist: json['artist'] as String?,
          volume: json['volume'] as int? ?? 50,
        );
      case DeviceType.security:
        return SecurityState(
          isActive: json['isActive'] as bool? ?? false,
          status: json['status'] as String? ?? 'Disarmed',
          zones: (json['zones'] as List?)?.cast<String>(),
        );
      case DeviceType.elevator:
        return ElevatorState(
          currentFloor: json['currentFloor'] as int? ?? 1,
          targetFloor: json['targetFloor'] as int?,
          isMoving: json['isMoving'] as bool? ?? false,
          direction: json['direction'] as String?,
          availableFloors: (json['availableFloors'] as List?)?.cast<int>() ?? [1, 2, 3, 4, 5],
        );
      case DeviceType.doorLock:
        return DoorLockState(
          isLocked: json['isLocked'] as bool? ?? true,
          isUnlocking: json['isUnlocking'] as bool? ?? false,
          lastUnlocked: json['lastUnlocked'] != null 
              ? DateTime.parse(json['lastUnlocked'] as String)
              : null,
        );
      case DeviceType.iphone:
        return IPhoneState(
          isActive: json['isActive'] as bool? ?? false,
          deviceName: json['deviceName'] as String?,
          batteryLevel: json['batteryLevel'] as int? ?? 100,
          isCharging: json['isCharging'] as bool? ?? false,
        );
      case DeviceType.tv:
      case DeviceType.fan:
      case DeviceType.socket:
      case DeviceType.lock:
        return SimpleState(
          isOn: json['isOn'] as bool? ?? false,
          additionalData: json['additionalData'] as Map<String, dynamic>?,
        );
    }
  }

  static Map<String, dynamic> stateToJson(DeviceState state) {
    if (state is LightState) {
      return {
        'isOn': state.isOn,
        'brightness': state.brightness,
        'color': state.color.value,
        'preset': state.preset,
      };
    } else if (state is ThermostatState) {
      return {
        'isOn': state.isOn,
        'temperature': state.temperature,
        'targetTemperature': state.targetTemperature,
        'mode': state.mode,
      };
    } else if (state is CameraState) {
      return {
        'isOn': state.isOn,
        'isRecording': state.isRecording,
        'resolution': state.resolution,
        'currentRoom': state.currentRoom,
      };
    } else if (state is CurtainState) {
      return {
        'isOpen': state.isOpen,
        'position': state.position,
      };
    } else if (state is MusicState) {
      return {
        'isPlaying': state.isPlaying,
        'title': state.title,
        'artist': state.artist,
        'volume': state.volume,
      };
    } else if (state is SecurityState) {
      return {
        'isActive': state.isActive,
        'status': state.status,
        'zones': state.zones,
      };
    } else if (state is ElevatorState) {
      return {
        'currentFloor': state.currentFloor,
        'targetFloor': state.targetFloor,
        'isMoving': state.isMoving,
        'direction': state.direction,
        'availableFloors': state.availableFloors,
      };
    } else if (state is DoorLockState) {
      return {
        'isLocked': state.isLocked,
        'isUnlocking': state.isUnlocking,
        'lastUnlocked': state.lastUnlocked?.toIso8601String(),
      };
    } else if (state is IPhoneState) {
      return {
        'isActive': state.isActive,
        'deviceName': state.deviceName,
        'batteryLevel': state.batteryLevel,
        'isCharging': state.isCharging,
      };
    } else if (state is SimpleState) {
      return {
        'isOn': state.isOn,
        'additionalData': state.additionalData,
      };
    }
    return {'isOn': false};
  }

  static IconData? _iconFromString(String? iconString) {
    if (iconString == null) return null;
    // Simple icon mapping - can be extended
    switch (iconString) {
      case 'lightbulb':
        return Icons.lightbulb_rounded;
      case 'thermostat':
        return Icons.thermostat_rounded;
      case 'camera':
        return Icons.videocam_rounded;
      case 'curtains':
        return Icons.curtains_rounded;
      case 'tv':
        return Icons.tv_rounded;
      case 'fan':
        return Icons.toys_rounded;
      case 'music':
        return Icons.music_note_rounded;
      case 'security':
        return Icons.shield_rounded;
      case 'socket':
        return Icons.power_rounded;
      case 'lock':
        return Icons.lock_rounded;
      case 'elevator':
        return Icons.elevator_rounded;
      case 'door_lock':
        return Icons.door_front_door_rounded;
      case 'iphone':
        return Icons.doorbell_rounded;
      default:
        return null;
    }
  }

  static String? _iconToString(IconData? icon) {
    if (icon == null) return null;
    if (icon == Icons.lightbulb_rounded) return 'lightbulb';
    if (icon == Icons.thermostat_rounded) return 'thermostat';
    if (icon == Icons.videocam_rounded) return 'camera';
    if (icon == Icons.curtains_rounded) return 'curtains';
    if (icon == Icons.tv_rounded) return 'tv';
    if (icon == Icons.toys_rounded) return 'fan';
    if (icon == Icons.music_note_rounded) return 'music';
    if (icon == Icons.shield_rounded) return 'security';
    if (icon == Icons.power_rounded) return 'socket';
    if (icon == Icons.lock_rounded) return 'lock';
    if (icon == Icons.elevator_rounded) return 'elevator';
    if (icon == Icons.door_front_door_rounded) return 'door_lock';
    if (icon == Icons.doorbell_rounded) return 'iphone';
    return null;
  }

  static IconData _defaultIconForType(DeviceType type) {
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

  @override
  DeviceModel copyWith({
    String? id,
    String? name,
    DeviceType? type,
    String? roomId,
    DeviceState? state,
    IconData? icon,
    bool? isOnline,
    DateTime? lastUpdated,
  }) {
    return DeviceModel(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      roomId: roomId ?? this.roomId,
      state: state ?? this.state,
      icon: icon ?? this.icon,
      isOnline: isOnline ?? this.isOnline,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

