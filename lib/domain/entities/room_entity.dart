import 'package:flutter/material.dart';

/// Room Entity
/// Represents a room in the smart home system
/// 
/// Example usage:
/// ```dart
/// final livingRoom = RoomEntity(
///   id: 'room_living',
///   name: 'Living Room',
///   icon: Icons.living_rounded,
///   deviceIds: ['light_001', 'tv_001', 'curtain_001'],
/// );
/// ```
class RoomEntity {
  final String id;
  final String name;
  final IconData icon;
  final List<String> deviceIds; // List of device IDs in this room
  final String? imageUrl; // Optional background image for the room
  final int order; // Display order
  final String? floorId; // ID of the floor this room belongs to
  final bool isGeneral; // Whether this is the general/public room that applies to whole house

  const RoomEntity({
    required this.id,
    required this.name,
    required this.icon,
    required this.deviceIds,
    this.imageUrl,
    this.order = 0,
    this.floorId,
    this.isGeneral = false,
  });

  /// Create a copy with updated fields
  RoomEntity copyWith({
    String? id,
    String? name,
    IconData? icon,
    List<String>? deviceIds,
    String? imageUrl,
    int? order,
    String? floorId,
    bool? isGeneral,
  }) {
    return RoomEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      deviceIds: deviceIds ?? this.deviceIds,
      imageUrl: imageUrl ?? this.imageUrl,
      order: order ?? this.order,
      floorId: floorId ?? this.floorId,
      isGeneral: isGeneral ?? this.isGeneral,
    );
  }

  /// Add a device to this room
  RoomEntity addDevice(String deviceId) {
    if (deviceIds.contains(deviceId)) {
      return this;
    }
    return copyWith(
      deviceIds: [...deviceIds, deviceId],
    );
  }

  /// Remove a device from this room
  RoomEntity removeDevice(String deviceId) {
    return copyWith(
      deviceIds: deviceIds.where((id) => id != deviceId).toList(),
    );
  }

  /// Get number of devices in this room
  int get deviceCount => deviceIds.length;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RoomEntity &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name;

  @override
  int get hashCode => id.hashCode ^ name.hashCode;
}

