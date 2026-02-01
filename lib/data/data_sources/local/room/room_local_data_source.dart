import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import '../preferences/preferences_service.dart';
import '../../../models/room_model.dart';

/// Room Local Data Source
/// Handles local storage operations for rooms
/// Uses PreferencesService for persistence
class RoomLocalDataSource {
  final PreferencesService _preferencesService;
  static const String _roomsKey = 'rooms_cache';
  Completer<void>? _addRoomLock;

  RoomLocalDataSource(this._preferencesService);

  /// Get all cached rooms
  Future<List<RoomModel>> getCachedRooms() async {
    try {
      final String? roomsJson = _preferencesService.getString(_roomsKey);
      List<RoomModel> rooms;

      if (roomsJson == null || roomsJson.isEmpty) {
        rooms = _getDefaultRooms();
      } else {
        final List<dynamic> roomsList = json.decode(roomsJson);
        rooms = roomsList
            .map((roomJson) => RoomModel.fromJson(roomJson))
            .toList();
      }

      // Ensure general room exists
      await _ensureGeneralRoomExists(rooms);

      return rooms;
    } catch (e) {
      // If there's an error parsing, return defaults
      final rooms = _getDefaultRooms();
      await _ensureGeneralRoomExists(rooms);
      return rooms;
    }
  }

  /// Ensure general room exists and is properly configured
  Future<void> _ensureGeneralRoomExists(List<RoomModel> rooms) async {
    const generalRoomId = 'room_general';
    final generalRoomExists = rooms.any((r) => r.id == generalRoomId);

    if (!generalRoomExists) {
      // Create general room
      final generalRoom = RoomModel.mock(
        id: generalRoomId,
        name: 'عمومی', // General/Public in Persian
        icon: Icons.home_rounded,
        deviceIds: [],
        order: -1, // Always first
        floorId: null, // Not tied to any floor
        isGeneral: true,
      );
      rooms.insert(0, generalRoom);
      await cacheRooms(rooms);
    } else {
      // Ensure general room is marked correctly and sorted first
      final generalRoomIndex = rooms.indexWhere((r) => r.id == generalRoomId);
      if (generalRoomIndex != -1) {
        final generalRoom = rooms[generalRoomIndex];
        // Update if not marked as general
        if (!generalRoom.isGeneral || generalRoom.order != -1) {
          rooms[generalRoomIndex] = generalRoom.copyWith(
            isGeneral: true,
            order: -1,
          );
          await cacheRooms(rooms);
        }
        // Move to first position
        if (generalRoomIndex != 0) {
          rooms.removeAt(generalRoomIndex);
          rooms.insert(0, generalRoom.copyWith(isGeneral: true, order: -1));
          await cacheRooms(rooms);
        }
      }
    }
  }

  /// Cache rooms locally
  Future<void> cacheRooms(List<RoomModel> rooms) async {
    final roomsJson = json.encode(rooms.map((room) => room.toJson()).toList());
    await _preferencesService.setString(_roomsKey, roomsJson);
  }

  /// Update a room
  Future<void> updateRoom(RoomModel room) async {
    final rooms = await getCachedRooms();
    final index = rooms.indexWhere((r) => r.id == room.id);

    if (index != -1) {
      rooms[index] = room;
      await cacheRooms(rooms);
    }
  }

  /// Add a new room
  /// Uses a lock to prevent race conditions when multiple rooms are added simultaneously
  Future<void> addRoom(RoomModel room) async {
    print('🟠 [ROOM_DS] addRoom called');
    print('   - ID: ${room.id}');
    print('   - Name: ${room.name}');
    print('   - FloorId: ${room.floorId}');
    print('   - Current lock: ${_addRoomLock != null ? "EXISTS" : "null"}');

    // Wait for any ongoing addRoom operation to complete
    while (_addRoomLock != null) {
      print('🟠 [ROOM_DS] Waiting for lock to be released...');
      await _addRoomLock!.future;
    }

    // Create a new lock for this operation
    _addRoomLock = Completer<void>();
    print('🟠 [ROOM_DS] Lock acquired');

    try {
      // Read the latest rooms from cache
      print('🟠 [ROOM_DS] Reading cached rooms...');
      final rooms = await getCachedRooms();
      print('🟠 [ROOM_DS] Found ${rooms.length} rooms in cache');
      for (var r in rooms) {
        print('   - ${r.name} (ID: ${r.id}, FloorId: ${r.floorId})');
      }

      // Check if room with same ID already exists
      if (rooms.any((r) => r.id == room.id)) {
        print('🔴 [ROOM_DS] ERROR: Room with ID ${room.id} already exists!');
        throw Exception('Room with ID ${room.id} already exists');
      }

      // Check if room with same name already exists (case-insensitive)
      if (rooms.any((r) => r.name.toLowerCase() == room.name.toLowerCase())) {
        print(
          '🔴 [ROOM_DS] ERROR: Room with name "${room.name}" already exists!',
        );
        throw Exception('Room with name "${room.name}" already exists');
      }

      // Double-check after reading cache again to prevent race conditions
      print('🟠 [ROOM_DS] Double-checking cache...');
      final latestRooms = await getCachedRooms();
      print('🟠 [ROOM_DS] Latest cache has ${latestRooms.length} rooms');
      if (latestRooms.any((r) => r.id == room.id)) {
        print(
          '🔴 [ROOM_DS] ERROR: Room with ID ${room.id} already exists in latest cache!',
        );
        throw Exception('Room with ID ${room.id} already exists');
      }
      if (latestRooms.any(
        (r) => r.name.toLowerCase() == room.name.toLowerCase(),
      )) {
        print(
          '🔴 [ROOM_DS] ERROR: Room with name "${room.name}" already exists in latest cache!',
        );
        throw Exception('Room with name "${room.name}" already exists');
      }

      print('🟠 [ROOM_DS] All checks passed, adding room...');
      latestRooms.add(room);
      print(
        '🟠 [ROOM_DS] Room added to list. New count: ${latestRooms.length}',
      );
      await cacheRooms(latestRooms);
      print('🟠 [ROOM_DS] Rooms cached successfully');
    } finally {
      // Release the lock
      print('🟠 [ROOM_DS] Releasing lock');
      _addRoomLock?.complete();
      _addRoomLock = null;
    }
  }

  /// Delete a room
  Future<void> deleteRoom(String roomId) async {
    // Prevent deletion of general room
    if (roomId == 'room_general') {
      throw Exception('Cannot delete general room');
    }
    final rooms = await getCachedRooms();
    rooms.removeWhere((r) => r.id == roomId);
    await cacheRooms(rooms);
  }

  /// Delete all rooms belonging to a specific floor
  Future<void> deleteRoomsByFloorId(String floorId) async {
    print('🟠 [ROOM_DS] deleteRoomsByFloorId called for floorId: $floorId');
    final rooms = await getCachedRooms();
    final roomsToDelete = rooms.where((r) => r.floorId == floorId).toList();
    print(
      '🟠 [ROOM_DS] Found ${roomsToDelete.length} rooms to delete for floor $floorId',
    );
    for (var room in roomsToDelete) {
      print('   - ${room.name} (ID: ${room.id})');
    }

    rooms.removeWhere((r) => r.floorId == floorId);
    await cacheRooms(rooms);
    print(
      '🟠 [ROOM_DS] Deleted ${roomsToDelete.length} rooms for floor $floorId',
    );
  }

  /// Clear all cached rooms
  Future<void> clearCache() async {
    await _preferencesService.remove(_roomsKey);
  }

  /// Replace cache with rooms received from microcontroller (USB).
  /// Ensures general room exists and is first. Use when USB is connected and micro sends room list.
  Future<void> setRoomsFromMicro(List<RoomModel> roomsFromMicro) async {
    final rooms = List<RoomModel>.from(roomsFromMicro);
    await _ensureGeneralRoomExists(rooms);
    await cacheRooms(rooms);
  }

  /// Default rooms when cache is empty: only general room.
  /// Real room list is loaded from microcontroller via USB when connected.
  List<RoomModel> _getDefaultRooms() {
    return [
      RoomModel.mock(
        id: 'room_general',
        name: 'عمومی',
        icon: Icons.home_rounded,
        deviceIds: [],
        order: -1,
        floorId: null,
        isGeneral: true,
      ),
    ];
  }
}
