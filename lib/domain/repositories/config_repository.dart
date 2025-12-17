import 'package:flutter/material.dart';

/// LED Preset configuration
class LEDPresetConfig {
  final String name;
  final Color color;

  const LEDPresetConfig({required this.name, required this.color});
}

/// Thermostat Mode configuration
class ThermostatModeConfig {
  final String name;
  final IconData icon;
  final Color color;

  const ThermostatModeConfig({
    required this.name,
    required this.icon,
    required this.color,
  });
}

/// Config Repository interface
/// Provides access to app configuration data like presets, modes, icons, colors
abstract class ConfigRepository {
  /// Get LED presets
  List<LEDPresetConfig> getLEDPresets();

  /// Get thermostat modes
  List<ThermostatModeConfig> getThermostatModes();

  /// Get available scenario icons
  List<IconData> getScenarioIcons();

  /// Get available scenario colors
  List<Color> getScenarioColors();

  /// Get temperature color mapping
  Color getTemperatureColor(int temperature);

  /// Get temperature state description
  Map<String, dynamic> getTemperatureState(int temperature);

  /// Get preset color by name
  Color getPresetColor(String presetName);

  /// Get mode data by name
  ThermostatModeConfig? getModeByName(String modeName);
}

