import 'package:flutter/material.dart';
import 'device_entity.dart';

/// Scenario Action
/// Defines what should happen to a device when a scenario is executed
/// 
/// Example:
/// ```dart
/// final action = ScenarioAction(
///   deviceId: 'light_001',
///   targetState: LightState(isOn: true, brightness: 50, color: Colors.warm),
/// );
/// ```
class ScenarioAction {
  final String deviceId;
  final DeviceState targetState;
  final int delayMs; // Delay before executing this action (in milliseconds)

  const ScenarioAction({
    required this.deviceId,
    required this.targetState,
    this.delayMs = 0,
  });

  ScenarioAction copyWith({
    String? deviceId,
    DeviceState? targetState,
    int? delayMs,
  }) {
    return ScenarioAction(
      deviceId: deviceId ?? this.deviceId,
      targetState: targetState ?? this.targetState,
      delayMs: delayMs ?? this.delayMs,
    );
  }
}

/// Scenario Condition (for future use)
/// Can be used to trigger scenarios automatically based on conditions
/// For now, scenarios are triggered manually
class ScenarioCondition {
  final String type; // 'time', 'sensor', 'manual'
  final Map<String, dynamic> parameters;

  const ScenarioCondition({
    required this.type,
    required this.parameters,
  });
}

/// Scenario App Settings
/// Defines app-level settings that should be applied when scenario is executed
/// null values mean "don't change" that setting
class ScenarioAppSettings {
  final ThemeMode? themeMode; // null = don't change theme
  final String? language; // null = don't change language

  const ScenarioAppSettings({
    this.themeMode,
    this.language,
  });

  ScenarioAppSettings copyWith({
    ThemeMode? themeMode,
    String? language,
  }) {
    return ScenarioAppSettings(
      themeMode: themeMode ?? this.themeMode,
      language: language ?? this.language,
    );
  }

  /// Check if any settings are configured
  bool get hasSettings => themeMode != null || language != null;
}

/// Scenario Entity
/// Represents a scenario that can control multiple devices at once
/// 
/// Example usage:
/// ```dart
/// final movieNight = ScenarioEntity(
///   id: 'scenario_movie',
///   name: 'Movie Night',
///   icon: Icons.movie_rounded,
///   color: Color(0xFF5B8DEF),
///   actions: [
///     ScenarioAction(
///       deviceId: 'light_001',
///       targetState: LightState(isOn: true, brightness: 20, color: Colors.warm),
///     ),
///     ScenarioAction(
///       deviceId: 'tv_001',
///       targetState: SimpleState(isOn: true),
///     ),
///     ScenarioAction(
///       deviceId: 'curtain_001',
///       targetState: CurtainState(isOpen: false, position: 0),
///     ),
///   ],
/// );
/// ```
class ScenarioEntity {
  final String id;
  final String name;
  final IconData icon;
  final Color color;
  final List<ScenarioAction> actions;
  final String? description;
  final bool isActive; // Is this scenario currently active/running
  final DateTime createdAt;
  final DateTime? lastExecuted;
  final List<ScenarioCondition>? conditions; // For auto-trigger (future feature)
  final String? roomId; // ID of the room this scenario belongs to
  final ScenarioAppSettings? appSettings; // App settings to apply when scenario executes

  const ScenarioEntity({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.actions,
    this.description,
    this.isActive = false,
    required this.createdAt,
    this.lastExecuted,
    this.conditions,
    this.roomId,
    this.appSettings,
  });

  /// Create a copy with updated fields
  ScenarioEntity copyWith({
    String? id,
    String? name,
    IconData? icon,
    Color? color,
    List<ScenarioAction>? actions,
    String? description,
    bool? isActive,
    DateTime? createdAt,
    DateTime? lastExecuted,
    List<ScenarioCondition>? conditions,
    String? roomId,
    ScenarioAppSettings? appSettings,
  }) {
    return ScenarioEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      actions: actions ?? this.actions,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      lastExecuted: lastExecuted ?? this.lastExecuted,
      conditions: conditions ?? this.conditions,
      roomId: roomId ?? this.roomId,
      appSettings: appSettings ?? this.appSettings,
    );
  }

  /// Mark scenario as executed
  ScenarioEntity markAsExecuted() {
    return copyWith(
      lastExecuted: DateTime.now(),
    );
  }

  /// Add an action to the scenario
  ScenarioEntity addAction(ScenarioAction action) {
    return copyWith(
      actions: [...actions, action],
    );
  }

  /// Remove an action from the scenario
  ScenarioEntity removeAction(String deviceId) {
    return copyWith(
      actions: actions.where((a) => a.deviceId != deviceId).toList(),
    );
  }

  /// Update an action in the scenario
  ScenarioEntity updateAction(String deviceId, DeviceState newState) {
    final updatedActions = actions.map((action) {
      if (action.deviceId == deviceId) {
        return action.copyWith(targetState: newState);
      }
      return action;
    }).toList();
    return copyWith(actions: updatedActions);
  }

  /// Get number of actions in this scenario
  int get actionCount => actions.length;

  /// Check if scenario has any actions
  bool get hasActions => actions.isNotEmpty;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ScenarioEntity &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name;

  @override
  int get hashCode => id.hashCode ^ name.hashCode;
}

