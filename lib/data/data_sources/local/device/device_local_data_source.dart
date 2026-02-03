import 'dart:convert';
import 'package:flutter/material.dart';
import '../preferences/preferences_service.dart';
import '../../../models/device_model.dart';
import '../../../../domain/entities/device_entity.dart';

/// Device Local Data Source
/// Handles local storage operations for devices
/// Uses PreferencesService for persistence
///
/// Future developers: This can be replaced with a database (e.g. SQLite/Hive)
/// for better performance with large numbers of devices
class DeviceLocalDataSource {
  final PreferencesService _preferencesService;
  static const String _devicesKey = 'devices_cache';

  DeviceLocalDataSource(this._preferencesService);

  /// Get all cached devices
  Future<List<DeviceModel>> getCachedDevices() async {
    try {
      final String? devicesJson = _preferencesService.getString(_devicesKey);
      if (devicesJson == null || devicesJson.isEmpty) {
        return _getDefaultDevices();
      }

      final List<dynamic> devicesList = json.decode(devicesJson);
      return devicesList
          .map((deviceJson) => DeviceModel.fromJson(deviceJson))
          .toList();
    } catch (e) {
      // If there's an error parsing, return defaults
      return _getDefaultDevices();
    }
  }

  /// Cache devices locally
  Future<void> cacheDevices(List<DeviceModel> devices) async {
    final devicesJson = json.encode(
      devices.map((device) => device.toJson()).toList(),
    );
    await _preferencesService.setString(_devicesKey, devicesJson);
  }

  /// Update a single device in cache
  Future<void> updateDevice(DeviceModel device) async {
    final devices = await getCachedDevices();
    final index = devices.indexWhere((d) => d.id == device.id);

    if (index != -1) {
      devices[index] = device;
    } else {
      devices.add(device);
    }

    await cacheDevices(devices);
  }

  /// Delete a device from cache
  Future<void> deleteDevice(String deviceId) async {
    final devices = await getCachedDevices();
    devices.removeWhere((d) => d.id == deviceId);
    await cacheDevices(devices);
  }

  /// Clear all cached devices
  Future<void> clearCache() async {
    await _preferencesService.remove(_devicesKey);
  }

  /// Default when cache is empty: no devices.
  /// Real device list is loaded from microcontroller via USB when connected.
  List<DeviceModel> _getDefaultDevices() {
    return [];
  }
}
