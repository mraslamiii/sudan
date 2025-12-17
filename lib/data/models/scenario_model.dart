import 'package:flutter/material.dart';
import '../../domain/entities/scenario_entity.dart';
import '../../domain/entities/device_entity.dart';
import 'device_model.dart';

/// Scenario Model - Data layer implementation of ScenarioEntity
/// Includes JSON serialization for API/storage communication
class ScenarioModel extends ScenarioEntity {
  const ScenarioModel({
    required super.id,
    required super.name,
    required super.icon,
    required super.color,
    required super.actions,
    super.description,
    super.isActive,
    required super.createdAt,
    super.lastExecuted,
    super.conditions,
    super.roomId,
    super.appSettings,
  });

  /// Create ScenarioModel from JSON
  factory ScenarioModel.fromJson(Map<String, dynamic> json) {
    final actions = (json['actions'] as List?)
            ?.map((actionJson) =>
                _actionFromJson(actionJson as Map<String, dynamic>))
            .toList() ??
        [];

    ScenarioAppSettings? appSettings;
    if (json['appSettings'] != null) {
      appSettings = _appSettingsFromJson(json['appSettings'] as Map<String, dynamic>);
    }

    return ScenarioModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      icon: _iconFromString(json['icon'] as String? ?? 'star'),
      color: Color(json['color'] as int? ?? Colors.blue.value),
      actions: actions,
      description: json['description'] as String?,
      isActive: json['isActive'] as bool? ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      lastExecuted: json['lastExecuted'] != null
          ? DateTime.parse(json['lastExecuted'] as String)
          : null,
      roomId: json['roomId'] as String?,
      appSettings: appSettings,
    );
  }

  /// Convert ScenarioModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': _iconToString(icon),
      'color': color.value,
      'actions': actions.map((a) => _actionToJson(a)).toList(),
      'description': description,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'lastExecuted': lastExecuted?.toIso8601String(),
      'roomId': roomId,
      if (appSettings != null) 'appSettings': _appSettingsToJson(appSettings!),
    };
  }

  /// Create mock scenario for testing
  /// 
  /// Example:
  /// ```dart
  /// final movieNight = ScenarioModel.mock(
  ///   id: 'scenario_movie',
  ///   name: 'Movie Night',
  ///   icon: Icons.movie_rounded,
  ///   color: Color(0xFF5B8DEF),
  ///   actions: [...],
  /// );
  /// ```
  factory ScenarioModel.mock({
    required String id,
    required String name,
    required IconData icon,
    required Color color,
    List<ScenarioAction>? actions,
    String? description,
  }) {
    return ScenarioModel(
      id: id,
      name: name,
      icon: icon,
      color: color,
      actions: actions ?? [],
      description: description,
      createdAt: DateTime.now(),
    );
  }

  // Helper methods for serialization

  static ScenarioAction _actionFromJson(Map<String, dynamic> json) {
    final deviceType = DeviceModel.deviceTypeFromString(
      json['deviceType'] as String? ?? 'light',
    );
    final state = DeviceModel.stateFromJson(
      deviceType,
      json['targetState'] as Map<String, dynamic>? ?? {},
    );

    return ScenarioAction(
      deviceId: json['deviceId'] as String? ?? '',
      targetState: state,
      delayMs: json['delayMs'] as int? ?? 0,
    );
  }

  static Map<String, dynamic> _actionToJson(ScenarioAction action) {
    // Determine device type from state
    String deviceType = 'simple';
    if (action.targetState is LightState) {
      deviceType = 'light';
    } else if (action.targetState is ThermostatState) {
      deviceType = 'thermostat';
    } else if (action.targetState is CameraState) {
      deviceType = 'camera';
    } else if (action.targetState is CurtainState) {
      deviceType = 'curtain';
    } else if (action.targetState is MusicState) {
      deviceType = 'music';
    } else if (action.targetState is SecurityState) {
      deviceType = 'security';
    }

    return {
      'deviceId': action.deviceId,
      'deviceType': deviceType,
      'targetState': DeviceModel.stateToJson(action.targetState),
      'delayMs': action.delayMs,
    };
  }

  static IconData _iconFromString(String iconString) {
    switch (iconString.toLowerCase()) {
      case 'sunny':
        return Icons.wb_sunny_rounded;
      case 'movie':
        return Icons.movie_rounded;
      case 'bedtime':
        return Icons.bedtime_rounded;
      case 'home':
        return Icons.home_rounded;
      case 'party':
        return Icons.celebration_rounded;
      case 'work':
        return Icons.work_rounded;
      case 'dinner':
        return Icons.restaurant_rounded;
      case 'reading':
        return Icons.menu_book_rounded;
      default:
        return Icons.auto_awesome_rounded;
    }
  }

  static String _iconToString(IconData icon) {
    if (icon == Icons.wb_sunny_rounded) return 'sunny';
    if (icon == Icons.movie_rounded) return 'movie';
    if (icon == Icons.bedtime_rounded) return 'bedtime';
    if (icon == Icons.home_rounded) return 'home';
    if (icon == Icons.celebration_rounded) return 'party';
    if (icon == Icons.work_rounded) return 'work';
    if (icon == Icons.restaurant_rounded) return 'dinner';
    if (icon == Icons.menu_book_rounded) return 'reading';
    return 'star';
  }

  static ScenarioAppSettings _appSettingsFromJson(Map<String, dynamic> json) {
    ThemeMode? themeMode;
    if (json['themeMode'] != null) {
      final modeString = json['themeMode'] as String;
      switch (modeString) {
        case 'light':
          themeMode = ThemeMode.light;
          break;
        case 'dark':
          themeMode = ThemeMode.dark;
          break;
        case 'system':
          themeMode = ThemeMode.system;
          break;
      }
    }

    return ScenarioAppSettings(
      themeMode: themeMode,
      language: json['language'] as String?,
    );
  }

  static Map<String, dynamic> _appSettingsToJson(ScenarioAppSettings settings) {
    String? themeModeString;
    if (settings.themeMode != null) {
      switch (settings.themeMode!) {
        case ThemeMode.light:
          themeModeString = 'light';
          break;
        case ThemeMode.dark:
          themeModeString = 'dark';
          break;
        case ThemeMode.system:
          themeModeString = 'system';
          break;
      }
    }

    return {
      if (themeModeString != null) 'themeMode': themeModeString,
      if (settings.language != null) 'language': settings.language,
    };
  }

  @override
  ScenarioModel copyWith({
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
    return ScenarioModel(
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

  @override
  ScenarioModel markAsExecuted() {
    return copyWith(
      lastExecuted: DateTime.now(),
    );
  }

  @override
  ScenarioModel addAction(ScenarioAction action) {
    return copyWith(
      actions: [...actions, action],
    );
  }

  @override
  ScenarioModel removeAction(String deviceId) {
    return copyWith(
      actions: actions.where((a) => a.deviceId != deviceId).toList(),
    );
  }

  @override
  ScenarioModel updateAction(String deviceId, DeviceState newState) {
    final updatedActions = actions.map((action) {
      if (action.deviceId == deviceId) {
        return action.copyWith(targetState: newState);
      }
      return action;
    }).toList();
    return copyWith(actions: updatedActions);
  }
}

