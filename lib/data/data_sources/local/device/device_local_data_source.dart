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

  /// Initialize with default mock devices
  /// This provides test data for developers to work with
  List<DeviceModel> _getDefaultDevices() {
    return [
      // Living Room Devices
      DeviceModel.mockLight(
        id: 'light_living_001',
        roomId: 'room_living',
        name: 'Living Room Main Light',
        isOn: true,
        brightness: 80,
        color: const Color(0xFFFFFFFF),
      ),
      DeviceModel.mockLight(
        id: 'light_living_002',
        roomId: 'room_living',
        name: 'Living Room Accent Light',
        isOn: false,
        brightness: 50,
        color: const Color(0xFFFF9500),
      ),
      DeviceModel.mockThermostat(
        id: 'thermostat_living_001',
        roomId: 'room_living',
        name: 'Living Room Thermostat',
        isOn: true,
        temperature: 23,
        targetTemperature: 24,
        mode: 'Auto',
      ),
      DeviceModel.mockSimple(
        id: 'tv_living_001',
        roomId: 'room_living',
        type: DeviceType.tv,
        name: 'Living Room TV',
        isOn: false,
        icon: Icons.tv_rounded,
      ),
      DeviceModel.mockCurtain(
        id: 'curtain_living_001',
        roomId: 'room_living',
        name: 'Living Room Curtains',
        isOpen: true,
        position: 80,
      ),
      DeviceModel.mockCamera(
        id: 'camera_living_001',
        roomId: 'room_living',
        name: 'Living Room Camera',
        isOn: true,
        isRecording: false,
        resolution: '4K',
      ),

      // Bedroom Devices
      DeviceModel.mockLight(
        id: 'light_bedroom_001',
        roomId: 'room_bedroom',
        name: 'Bedroom Main Light',
        isOn: false,
        brightness: 60,
        color: const Color(0xFFFF69B4),
      ),
      DeviceModel.mockSimple(
        id: 'fan_bedroom_001',
        roomId: 'room_bedroom',
        type: DeviceType.fan,
        name: 'Bedroom Fan',
        isOn: false,
        icon: Icons.toys_rounded,
      ),
      DeviceModel.mockCurtain(
        id: 'curtain_bedroom_001',
        roomId: 'room_bedroom',
        name: 'Bedroom Curtains',
        isOpen: false,
        position: 0,
      ),
      DeviceModel.mockCamera(
        id: 'camera_bedroom_001',
        roomId: 'room_bedroom',
        name: 'Bedroom Camera',
        isOn: true,
        isRecording: false,
        resolution: '1080p',
      ),

      // Kitchen Devices
      DeviceModel.mockLight(
        id: 'light_kitchen_001',
        roomId: 'room_kitchen',
        name: 'Kitchen Light',
        isOn: true,
        brightness: 90,
        color: const Color(0xFFFFFFFF),
      ),
      DeviceModel.mockSimple(
        id: 'socket_kitchen_001',
        roomId: 'room_kitchen',
        type: DeviceType.socket,
        name: 'Kitchen Socket',
        isOn: true,
        icon: Icons.power_rounded,
      ),
      DeviceModel.mockCamera(
        id: 'camera_kitchen_001',
        roomId: 'room_kitchen',
        name: 'Kitchen Camera',
        isOn: true,
        isRecording: false,
        resolution: '1080p',
      ),

      // Bathroom Devices
      DeviceModel.mockLight(
        id: 'light_bathroom_001',
        roomId: 'room_bathroom',
        name: 'Bathroom Light',
        isOn: false,
        brightness: 100,
        color: const Color(0xFFFFFFFF),
      ),
      DeviceModel.mockSimple(
        id: 'fan_bathroom_001',
        roomId: 'room_bathroom',
        type: DeviceType.fan,
        name: 'Bathroom Fan',
        isOn: false,
        icon: Icons.toys_rounded,
      ),
      DeviceModel.mockCamera(
        id: 'camera_bathroom_001',
        roomId: 'room_bathroom',
        name: 'Bathroom Camera',
        isOn: false,
        isRecording: false,
        resolution: '720p',
      ),

      // Unassigned devices (available for room assignment)
      DeviceModel.mockSimple(
        id: 'socket_tablet_001',
        roomId: '', // No room assigned - available for selection
        type: DeviceType.socket,
        name: 'Tablet Charger',
        isOn: false,
        icon: Icons.power_rounded,
      ),
    ];
  }
}

