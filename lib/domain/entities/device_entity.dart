import 'package:flutter/material.dart';

/// Device types supported by the smart home system
enum DeviceType {
  light,
  thermostat,
  curtain,
  tv,
  fan,
  security,
  music,
  camera,
  socket,
  lock,
  elevator,
  doorLock,
  iphone,
}

/// Device state for different device types
/// This is a sealed class pattern - use specific state classes for each device type
abstract class DeviceState {
  const DeviceState();
}

/// Light device state
class LightState extends DeviceState {
  final bool isOn;
  final int brightness; // 0-100
  final Color color;
  final String? preset; // 'Reading', 'Working', 'Romantic', etc.

  const LightState({
    required this.isOn,
    required this.brightness,
    required this.color,
    this.preset,
  });

  LightState copyWith({
    bool? isOn,
    int? brightness,
    Color? color,
    String? preset,
  }) {
    return LightState(
      isOn: isOn ?? this.isOn,
      brightness: brightness ?? this.brightness,
      color: color ?? this.color,
      preset: preset ?? this.preset,
    );
  }
}

/// Thermostat device state
class ThermostatState extends DeviceState {
  final bool isOn;
  final int temperature; // Current temperature
  final int targetTemperature; // Desired temperature
  final String mode; // 'Cool', 'Heat', 'Fan', 'Auto'

  const ThermostatState({
    required this.isOn,
    required this.temperature,
    required this.targetTemperature,
    required this.mode,
  });

  ThermostatState copyWith({
    bool? isOn,
    int? temperature,
    int? targetTemperature,
    String? mode,
  }) {
    return ThermostatState(
      isOn: isOn ?? this.isOn,
      temperature: temperature ?? this.temperature,
      targetTemperature: targetTemperature ?? this.targetTemperature,
      mode: mode ?? this.mode,
    );
  }
}

/// Curtain device state
class CurtainState extends DeviceState {
  final bool isOpen;
  final int position; // 0-100, where 0 is closed and 100 is fully open

  const CurtainState({
    required this.isOpen,
    required this.position,
  });

  CurtainState copyWith({
    bool? isOpen,
    int? position,
  }) {
    return CurtainState(
      isOpen: isOpen ?? this.isOpen,
      position: position ?? this.position,
    );
  }
}

/// Camera device state
class CameraState extends DeviceState {
  final bool isOn;
  final bool isRecording;
  final String resolution; // '4K', '1080p', '720p'
  final String? currentRoom; // Room being monitored

  const CameraState({
    required this.isOn,
    required this.isRecording,
    required this.resolution,
    this.currentRoom,
  });

  CameraState copyWith({
    bool? isOn,
    bool? isRecording,
    String? resolution,
    String? currentRoom,
  }) {
    return CameraState(
      isOn: isOn ?? this.isOn,
      isRecording: isRecording ?? this.isRecording,
      resolution: resolution ?? this.resolution,
      currentRoom: currentRoom ?? this.currentRoom,
    );
  }
}

/// Generic device state for simple on/off devices
class SimpleState extends DeviceState {
  final bool isOn;
  final Map<String, dynamic>? additionalData;

  const SimpleState({
    required this.isOn,
    this.additionalData,
  });

  SimpleState copyWith({
    bool? isOn,
    Map<String, dynamic>? additionalData,
  }) {
    return SimpleState(
      isOn: isOn ?? this.isOn,
      additionalData: additionalData ?? this.additionalData,
    );
  }
}

/// Music player device state
class MusicState extends DeviceState {
  final bool isPlaying;
  final String? title;
  final String? artist;
  final int volume; // 0-100

  const MusicState({
    required this.isPlaying,
    this.title,
    this.artist,
    required this.volume,
  });

  MusicState copyWith({
    bool? isPlaying,
    String? title,
    String? artist,
    int? volume,
  }) {
    return MusicState(
      isPlaying: isPlaying ?? this.isPlaying,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      volume: volume ?? this.volume,
    );
  }
}

/// Security system state
class SecurityState extends DeviceState {
  final bool isActive;
  final String status; // 'Armed', 'Disarmed', 'Triggered'
  final List<String>? zones;

  const SecurityState({
    required this.isActive,
    required this.status,
    this.zones,
  });

  SecurityState copyWith({
    bool? isActive,
    String? status,
    List<String>? zones,
  }) {
    return SecurityState(
      isActive: isActive ?? this.isActive,
      status: status ?? this.status,
      zones: zones ?? this.zones,
    );
  }
}

/// Elevator device state
class ElevatorState extends DeviceState {
  final int currentFloor;
  final int? targetFloor;
  final bool isMoving;
  final String? direction; // 'up', 'down', null
  final List<int> availableFloors;

  const ElevatorState({
    required this.currentFloor,
    this.targetFloor,
    required this.isMoving,
    this.direction,
    required this.availableFloors,
  });

  ElevatorState copyWith({
    int? currentFloor,
    int? targetFloor,
    bool? isMoving,
    String? direction,
    List<int>? availableFloors,
  }) {
    return ElevatorState(
      currentFloor: currentFloor ?? this.currentFloor,
      targetFloor: targetFloor ?? this.targetFloor,
      isMoving: isMoving ?? this.isMoving,
      direction: direction ?? this.direction,
      availableFloors: availableFloors ?? this.availableFloors,
    );
  }
}

/// Door lock device state
class DoorLockState extends DeviceState {
  final bool isLocked;
  final bool isUnlocking; // for animation
  final DateTime? lastUnlocked;

  const DoorLockState({
    required this.isLocked,
    required this.isUnlocking,
    this.lastUnlocked,
  });

  DoorLockState copyWith({
    bool? isLocked,
    bool? isUnlocking,
    DateTime? lastUnlocked,
  }) {
    return DoorLockState(
      isLocked: isLocked ?? this.isLocked,
      isUnlocking: isUnlocking ?? this.isUnlocking,
      lastUnlocked: lastUnlocked ?? this.lastUnlocked,
    );
  }
}

/// iPhone device state
class IPhoneState extends DeviceState {
  final bool isActive;
  final String? deviceName;
  final int batteryLevel; // 0-100
  final bool isCharging;

  const IPhoneState({
    required this.isActive,
    this.deviceName,
    this.batteryLevel = 100,
    this.isCharging = false,
  });

  IPhoneState copyWith({
    bool? isActive,
    String? deviceName,
    int? batteryLevel,
    bool? isCharging,
  }) {
    return IPhoneState(
      isActive: isActive ?? this.isActive,
      deviceName: deviceName ?? this.deviceName,
      batteryLevel: batteryLevel ?? this.batteryLevel,
      isCharging: isCharging ?? this.isCharging,
    );
  }
}

/// Main Device Entity
/// This is the core entity that represents any smart device in the system
/// 
/// Example usage:
/// ```dart
/// final lightDevice = DeviceEntity(
///   id: 'light_001',
///   name: 'Living Room Light',
///   type: DeviceType.light,
///   roomId: 'room_living',
///   state: LightState(
///     isOn: true,
///     brightness: 80,
///     color: Colors.white,
///   ),
/// );
/// ```
class DeviceEntity {
  final String id;
  final String name;
  final DeviceType type;
  final String roomId;
  final DeviceState state;
  final IconData? icon;
  final bool isOnline;
  final DateTime lastUpdated;

  const DeviceEntity({
    required this.id,
    required this.name,
    required this.type,
    required this.roomId,
    required this.state,
    this.icon,
    this.isOnline = true,
    required this.lastUpdated,
  });

  /// Create a copy with updated fields
  DeviceEntity copyWith({
    String? id,
    String? name,
    DeviceType? type,
    String? roomId,
    DeviceState? state,
    IconData? icon,
    bool? isOnline,
    DateTime? lastUpdated,
  }) {
    return DeviceEntity(
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

  /// Helper method to check if device is on/active
  bool get isActive {
    final s = state;
    if (s is LightState) return s.isOn;
    if (s is ThermostatState) return s.isOn;
    if (s is CameraState) return s.isOn;
    if (s is SimpleState) return s.isOn;
    if (s is MusicState) return s.isPlaying;
    if (s is SecurityState) return s.isActive;
    if (s is CurtainState) return s.isOpen;
    if (s is ElevatorState) return s.isMoving;
    if (s is DoorLockState) return !s.isLocked;
    if (s is IPhoneState) return s.isActive;
    return false;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DeviceEntity &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          type == other.type &&
          roomId == other.roomId;

  @override
  int get hashCode =>
      id.hashCode ^ name.hashCode ^ type.hashCode ^ roomId.hashCode;
}

