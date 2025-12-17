import 'package:flutter/material.dart';
import '../../../domain/repositories/config_repository.dart';

/// Implementation of ConfigRepository
/// Provides centralized access to app configuration data
class ConfigRepositoryImpl implements ConfigRepository {
  // LED Presets
  static const List<LEDPresetConfig> _ledPresets = [
    LEDPresetConfig(name: 'Reading', color: Color(0xFF5AC8FA)),
    LEDPresetConfig(name: 'Working', color: Colors.white),
    LEDPresetConfig(name: 'Romantic', color: Color(0xFFFF69B4)),
  ];

  // Thermostat Modes
  static const List<ThermostatModeConfig> _thermostatModes = [
    ThermostatModeConfig(
      name: 'Cool',
      icon: Icons.ac_unit_rounded,
      color: Color(0xFF5AC8FA),
    ),
    ThermostatModeConfig(
      name: 'Heat',
      icon: Icons.local_fire_department_rounded,
      color: Color(0xFFFF9500),
    ),
    ThermostatModeConfig(
      name: 'Fan',
      icon: Icons.air_rounded,
      color: Color(0xFF8E8E93),
    ),
    ThermostatModeConfig(
      name: 'Auto',
      icon: Icons.sync_rounded,
      color: Color(0xFF34C759),
    ),
  ];

  // Scenario Icons
  static const List<IconData> _scenarioIcons = [
    Icons.wb_sunny_rounded,
    Icons.movie_rounded,
    Icons.bedtime_rounded,
    Icons.home_rounded,
    Icons.celebration_rounded,
    Icons.work_rounded,
    Icons.restaurant_rounded,
    Icons.menu_book_rounded,
    Icons.fitness_center_rounded,
    Icons.spa_rounded,
    Icons.auto_awesome_rounded,
    Icons.music_note_rounded,
    Icons.coffee_rounded,
    Icons.nights_stay_rounded,
    Icons.wb_twilight_rounded,
  ];

  // Scenario Colors
  static const List<Color> _scenarioColors = [
    Color(0xFFFFB84D), // Orange
    Color(0xFF5B8DEF), // Blue
    Color(0xFF7B68EE), // Purple
    Color(0xFF68F0C4), // Mint
    Color(0xFFFF6B9D), // Pink
    Color(0xFF4CAF50), // Green
    Color(0xFFFF9800), // Amber
    Color(0xFF9C27B0), // Deep Purple
    Color(0xFF00BCD4), // Cyan
    Color(0xFFE91E63), // Rose
  ];

  @override
  List<LEDPresetConfig> getLEDPresets() => _ledPresets;

  @override
  List<ThermostatModeConfig> getThermostatModes() => _thermostatModes;

  @override
  List<IconData> getScenarioIcons() => _scenarioIcons;

  @override
  List<Color> getScenarioColors() => _scenarioColors;

  @override
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

  @override
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

  @override
  Color getPresetColor(String presetName) {
    try {
      return _ledPresets.firstWhere((p) => p.name == presetName).color;
    } catch (e) {
      return Colors.white;
    }
  }

  @override
  ThermostatModeConfig? getModeByName(String modeName) {
    try {
      return _thermostatModes.firstWhere((m) => m.name == modeName);
    } catch (e) {
      return null;
    }
  }
}

