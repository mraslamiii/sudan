import 'package:flutter/services.dart';

class LauncherService {
  static const MethodChannel _channel = MethodChannel('com.example.sudan/launcher');

  /// Check if this app is set as the default launcher
  static Future<bool> isDefaultLauncher() async {
    try {
      final bool result = await _channel.invokeMethod('isDefaultLauncher');
      return result;
    } catch (e) {
      return false;
    }
  }

  /// Open launcher settings to allow user to set this app as default
  static Future<void> openLauncherSettings() async {
    try {
      await _channel.invokeMethod('openLauncherSettings');
    } catch (e) {
      // Handle error silently
    }
  }
}

