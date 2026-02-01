import 'dart:convert';
import '../preferences/preferences_service.dart';
import '../../../models/floor_model.dart';

/// Floor Local Data Source
/// Handles local storage operations for floors
/// Uses PreferencesService for persistence
class FloorLocalDataSource {
  final PreferencesService _preferencesService;
  static const String _floorsKey = 'floors_cache';

  FloorLocalDataSource(this._preferencesService);

  /// Get all cached floors
  Future<List<FloorModel>> getCachedFloors() async {
    try {
      final String? floorsJson = _preferencesService.getString(_floorsKey);
      if (floorsJson == null || floorsJson.isEmpty) {
        return _getDefaultFloors();
      }

      final List<dynamic> floorsList = json.decode(floorsJson);
      return floorsList
          .map((floorJson) => FloorModel.fromJson(floorJson))
          .toList();
    } catch (e) {
      // If there's an error parsing, return defaults
      return _getDefaultFloors();
    }
  }

  /// Cache floors locally
  Future<void> cacheFloors(List<FloorModel> floors) async {
    final floorsJson = json.encode(
      floors.map((floor) => floor.toJson()).toList(),
    );
    await _preferencesService.setString(_floorsKey, floorsJson);
  }

  /// Update a floor
  Future<void> updateFloor(FloorModel floor) async {
    final floors = await getCachedFloors();
    final index = floors.indexWhere((f) => f.id == floor.id);

    if (index != -1) {
      floors[index] = floor;
      await cacheFloors(floors);
    }
  }

  /// Add a new floor
  Future<void> addFloor(FloorModel floor) async {
    final floors = await getCachedFloors();
    floors.add(floor);
    await cacheFloors(floors);
  }

  /// Delete a floor
  Future<void> deleteFloor(String floorId) async {
    final floors = await getCachedFloors();
    floors.removeWhere((f) => f.id == floorId);
    await cacheFloors(floors);
  }

  /// Clear all cached floors
  Future<void> clearCache() async {
    await _preferencesService.remove(_floorsKey);
  }

  /// Replace cache with floors received from microcontroller (USB).
  /// Use when USB is connected and micro sends floor list.
  Future<void> setFloorsFromMicro(List<FloorModel> floorsFromMicro) async {
    final floors = List<FloorModel>.from(floorsFromMicro);
    await cacheFloors(floors);
  }

  /// Default when cache is empty: no floors (list from micro when USB connected).
  List<FloorModel> _getDefaultFloors() {
    return [];
  }
}
